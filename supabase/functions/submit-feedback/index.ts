import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

const githubRepository = 'jaywapp/card-radar'
const feedbackLabel = '제보'
const maxBodyBytes = 4096
const rateLimitWindowMs = 10 * 60 * 1000
const rateLimitMaxRequests = 5
const allowedPlatforms = new Set([
  'android',
  'ios',
  'web',
  'windows',
  'macos',
  'linux',
  'fuchsia',
])
const requestsByClient = new Map<string, number[]>()

function corsHeaders(req: Request): Record<string, string> {
  const origin = req.headers.get('origin')
  if (!origin) return {}

  const allowedOrigins = (Deno.env.get('FEEDBACK_ALLOWED_ORIGINS') ?? '')
    .split(',')
    .map((value) => value.trim())
    .filter(Boolean)

  return allowedOrigins.includes(origin)
    ? {
        'Access-Control-Allow-Origin': origin,
        'Access-Control-Allow-Headers': 'authorization, content-type, apikey, x-client-info',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        Vary: 'Origin',
      }
    : {}
}

function jsonResponse(
  req: Request,
  body: Record<string, unknown>,
  status: number,
  extraHeaders: Record<string, string> = {},
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-store',
      ...corsHeaders(req),
      ...extraHeaders,
    },
  })
}

function cleanText(value: unknown, maxLength: number): string {
  if (typeof value !== 'string') return ''
  return value
    .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, '')
    .trim()
    .slice(0, maxLength + 1)
}

function escapeMarkdown(value: string): string {
  return value.replace(/([\\`*_[\]<>])/g, '\\$1')
}

function isRateLimited(req: Request): boolean {
  const client = req.headers.get('x-forwarded-for')?.split(',')[0]?.trim() ||
    req.headers.get('cf-connecting-ip') ||
    'unknown'
  const now = Date.now()
  const recent = (requestsByClient.get(client) ?? []).filter(
    (timestamp) => now - timestamp < rateLimitWindowMs,
  )
  if (recent.length >= rateLimitMaxRequests) {
    requestsByClient.set(client, recent)
    return true
  }
  requestsByClient.set(client, [...recent, now])
  return false
}

async function ensureFeedbackLabel(token: string): Promise<boolean> {
  const labelUrl = `https://api.github.com/repos/${githubRepository}/labels/${encodeURIComponent(feedbackLabel)}`
  const headers = {
    Authorization: `Bearer ${token}`,
    Accept: 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28',
  }
  const existing = await fetch(labelUrl, { headers })
  if (existing.ok) return true
  if (existing.status !== 404) return false

  const created = await fetch(
    `https://api.github.com/repos/${githubRepository}/labels`,
    {
      method: 'POST',
      headers: { ...headers, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: feedbackLabel,
        color: 'D4C5F9',
        description: '앱 사용자가 제보 기능으로 등록한 의견',
      }),
    },
  )
  return created.ok || created.status === 422
}

serve(async (req: Request) => {
  const origin = req.headers.get('origin')
  if (origin && !corsHeaders(req)['Access-Control-Allow-Origin']) {
    return jsonResponse(req, { error: 'origin_not_allowed' }, 403)
  }
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders(req) })
  }
  if (req.method !== 'POST') {
    return jsonResponse(req, { error: 'method_not_allowed' }, 405)
  }
  const contentLength = Number(req.headers.get('content-length') ?? 0)
  if (contentLength > maxBodyBytes) {
    return jsonResponse(req, { error: 'payload_too_large' }, 413)
  }
  if (isRateLimited(req)) {
    return jsonResponse(req, { error: 'rate_limited' }, 429, {
      'Retry-After': String(rateLimitWindowMs / 1000),
    })
  }

  const token = Deno.env.get('GH_ISSUE_TOKEN')
  if (!token) {
    return jsonResponse(req, { error: 'service_unavailable' }, 503)
  }

  let payload: Record<string, unknown>
  try {
    const rawBody = await req.text()
    if (new TextEncoder().encode(rawBody).length > maxBodyBytes) {
      return jsonResponse(req, { error: 'payload_too_large' }, 413)
    }
    const parsed: unknown = JSON.parse(rawBody)
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
      return jsonResponse(req, { error: 'invalid_json' }, 400)
    }
    payload = parsed as Record<string, unknown>
  } catch {
    return jsonResponse(req, { error: 'invalid_json' }, 400)
  }

  const title = cleanText(payload.title, 100).replace(/[\r\n]+/g, ' ')
  const description = cleanText(payload.description, 500)
  const contact = cleanText(payload.contact, 200)
  const appVersion = cleanText(payload.appVersion, 32)
  const platform = cleanText(payload.platform, 16)
  const type = payload.type === 'improvement' ? 'improvement' : 'bug'

  if (
    !title ||
    title.length > 100 ||
    !description ||
    description.length > 500 ||
    contact.length > 200 ||
    !appVersion ||
    appVersion.length > 32 ||
    !allowedPlatforms.has(platform)
  ) {
    return jsonResponse(req, { error: 'invalid_input' }, 400)
  }

  const typeLabel = type === 'bug' ? '버그' : '개선 의견'
  const bodyParts = [
    `**유형**: ${typeLabel}`,
    `**앱 버전**: ${escapeMarkdown(appVersion)}`,
    `**플랫폼**: ${escapeMarkdown(platform)}`,
    '',
    '**내용**:',
    escapeMarkdown(description),
  ]
  if (contact) {
    bodyParts.push('', '**연락처(사용자 제공)**:', escapeMarkdown(contact))
  }
  bodyParts.push('', '---', '*앱의 제보 기능에서 등록되었습니다.*')

  try {
    if (!(await ensureFeedbackLabel(token))) {
      return jsonResponse(req, { error: 'upstream_error' }, 502)
    }
    const response = await fetch(
      `https://api.github.com/repos/${githubRepository}/issues`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          Accept: 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          title: `[제보] ${title}`,
          body: bodyParts.join('\n'),
          labels: [feedbackLabel],
        }),
      },
    )
    if (!response.ok) {
      return jsonResponse(req, { error: 'upstream_error' }, 502)
    }
    const issue = await response.json()
    return jsonResponse(req, { ok: true, issueNumber: issue.number }, 201)
  } catch {
    return jsonResponse(req, { error: 'upstream_unavailable' }, 502)
  }
})
