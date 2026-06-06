import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

serve((req: Request) => {
  const url = new URL(req.url)
  const code  = url.searchParams.get('code')
  const state = url.searchParams.get('state') ?? ''
  const error = url.searchParams.get('error')

  if (error) {
    return Response.redirect(`cardradar://auth?error=${encodeURIComponent(error)}`, 302)
  }

  if (code) {
    const redirect = `cardradar://auth?code=${encodeURIComponent(code)}&state=${encodeURIComponent(state)}`
    return Response.redirect(redirect, 302)
  }

  return new Response('invalid callback', { status: 400 })
})
