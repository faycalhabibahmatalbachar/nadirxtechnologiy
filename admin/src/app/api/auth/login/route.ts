import { NextResponse } from 'next/server';

function getAllowedIdentifiers(): string[] {
  const raw = (process.env.ADMIN_LOGIN_IDENTIFIERS || '').trim();
  if (!raw) return [];
  return raw
    .split(',')
    .map(s => s.trim().toLowerCase())
    .filter(Boolean);
}

export async function POST(req: Request) {
  const body = await req.json().catch(() => null);
  const username = (body?.username ?? '').toString().trim().toLowerCase();
  const password = (body?.password ?? '').toString();

  const allowed = getAllowedIdentifiers();
  const okUser = allowed.length > 0 ? allowed.includes(username) : false;
  const adminPassword = process.env.ADMIN_PASSWORD || '';

  if (!okUser || !adminPassword || password !== adminPassword) {
    return NextResponse.json(
      { ok: false, error: 'Accès non autorisé' },
      { status: 401 },
    );
  }

  const token = process.env.ADMIN_SESSION_TOKEN || '1';
  const res = NextResponse.json({ ok: true });
  res.cookies.set('nadirx_admin', token, {
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    path: '/',
  });
  return res;
}

