import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

const jsonHeaders = { 'Content-Type': 'application/json' }

function errorResponse(error: string, status: number): Response {
  return new Response(JSON.stringify({ error }), { status, headers: jsonHeaders })
}

function buildBankTranId(prefix: string): string {
  const suffix = crypto.randomUUID().replaceAll('-', '').slice(0, 9).toUpperCase()
  return `${prefix}${suffix}`
}

serve(async (req: Request) => {
  if (req.method !== 'POST') return errorResponse('method_not_allowed', 405)

  const clientId = Deno.env.get('KFTC_CLIENT_ID')
  const clientSecret = Deno.env.get('KFTC_CLIENT_SECRET')
  const redirectUri = Deno.env.get('KFTC_REDIRECT_URI')
  const baseUrl = Deno.env.get('KFTC_BASE_URL') ?? 'https://testapi.openbanking.or.kr'
  const bankTranIdPrefix = Deno.env.get('KFTC_BANK_TRAN_ID_PREFIX')

  if (!clientId || !clientSecret || !redirectUri || !bankTranIdPrefix) {
    return errorResponse('service_unavailable', 503)
  }

  let payload: Record<string, unknown>
  try {
    payload = await req.json()
  } catch {
    return errorResponse('invalid_json', 400)
  }

  const code = typeof payload.code === 'string' ? payload.code.trim() : ''
  if (!code || code.length > 2048) return errorResponse('invalid_code', 400)

  try {
    const tokenResponse = await fetch(`${baseUrl}/oauth/2.0/token`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code,
        client_id: clientId,
        client_secret: clientSecret,
        redirect_uri: redirectUri,
      }),
    })

    if (!tokenResponse.ok) return errorResponse('token_exchange_failed', 502)

    const token = await tokenResponse.json() as Record<string, unknown>
    const accessToken = typeof token.access_token === 'string' ? token.access_token : ''
    const userSeqNo = typeof token.user_seq_no === 'string' ? token.user_seq_no : ''
    if (!accessToken || !userSeqNo) return errorResponse('invalid_token_response', 502)

    const cardsUrl = new URL(`${baseUrl}/v2.0/cards`)
    cardsUrl.search = new URLSearchParams({
      bank_tran_id: buildBankTranId(bankTranIdPrefix),
      user_seq_no: userSeqNo,
      card_co_code: '999',
      include_cancel_yn: 'N',
      next_page_yn: 'N',
    }).toString()

    const cardsResponse = await fetch(cardsUrl, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
    })
    if (!cardsResponse.ok) return errorResponse('card_lookup_failed', 502)

    const data = await cardsResponse.json() as Record<string, unknown>
    const cards = Array.isArray(data.card_list) ? data.card_list : []
    const cardNames = cards
      .map((card) => {
        if (typeof card !== 'object' || card === null) return ''
        const name = (card as Record<string, unknown>).card_nm
        return typeof name === 'string' ? name : ''
      })
      .filter((name) => name.length > 0)

    return new Response(JSON.stringify({ card_names: cardNames }), {
      status: 200,
      headers: jsonHeaders,
    })
  } catch {
    return errorResponse('upstream_unavailable', 502)
  }
})
