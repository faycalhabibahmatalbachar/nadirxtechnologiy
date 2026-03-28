import { NextResponse } from 'next/server';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, X-Debug-Session-Id, X-Debug-Secret',
};

/**
 * Réception des logs d’instrumentation (app Flutter).
 * Les entrées apparaissent dans Vercel → Projet → Logs (fonction /api/debug-ingest).
 *
 * Variables optionnelles Vercel :
 * - DEBUG_INGEST_SECRET : si défini, le client doit envoyer le même en-tête X-Debug-Secret
 *   (voir dart-define DEBUG_INGEST_SECRET côté Flutter).
 */
export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: cors });
}

export async function POST(request: Request) {
  const expected = process.env.DEBUG_INGEST_SECRET;
  if (expected) {
    const got = request.headers.get('x-debug-secret') ?? '';
    if (got !== expected) {
      return NextResponse.json(
        { ok: false, error: 'unauthorized' },
        { status: 401, headers: { ...cors } },
      );
    }
  }

  try {
    const body = await request.json();
    console.log('[debug-ingest]', JSON.stringify(body));
  } catch (e) {
    console.error('[debug-ingest] parse error', e);
  }

  return NextResponse.json({ ok: true }, { headers: cors });
}
