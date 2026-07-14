import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

const jsonHeaders = { 'Content-Type': 'application/json' }

serve(async (req: Request) => {
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'method_not_allowed' }), {
      status: 405,
      headers: jsonHeaders,
    })
  }

  const token = Deno.env.get('GH_ISSUE_TOKEN')
  if (!token) {
    return new Response(JSON.stringify({ error: 'service_unavailable' }), {
      status: 503,
      headers: jsonHeaders,
    })
  }

  let payload: Record<string, unknown>
  try {
    payload = await req.json()
  } catch {
    return new Response(JSON.stringify({ error: 'invalid_json' }), {
      status: 400,
      headers: jsonHeaders,
    })
  }

  const title = typeof payload.title === 'string' ? payload.title.trim() : ''
  const description = typeof payload.description === 'string'
    ? payload.description.trim()
    : ''
  const type = payload.type === 'improvement' ? 'improvement' : 'bug'

  if (!title || title.length > 100 || description.length > 500) {
    return new Response(JSON.stringify({ error: 'invalid_input' }), {
      status: 400,
      headers: jsonHeaders,
    })
  }

  const label = type === 'bug' ? 'bug' : 'enhancement'
  const typeLabel = type === 'bug' ? '🐛 버그' : '💡 불편사항'
  const body = `**유형**: ${typeLabel}\n\n**내용**:\n${description}\n\n---\n*앱에서 직접 제보된 이슈입니다.*`

  try {
    const response = await fetch('https://api.github.com/repos/jaywapp/card-radar/issues', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        Accept: 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ title, body, labels: [label] }),
    })

    if (!response.ok) {
      return new Response(JSON.stringify({ error: 'upstream_error' }), {
        status: 502,
        headers: jsonHeaders,
      })
    }

    return new Response(JSON.stringify({ ok: true }), {
      status: 201,
      headers: jsonHeaders,
    })
  } catch {
    return new Response(JSON.stringify({ error: 'upstream_unavailable' }), {
      status: 502,
      headers: jsonHeaders,
    })
  }
})
