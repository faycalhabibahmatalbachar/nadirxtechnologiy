import { NextResponse } from 'next/server';

const ADMIN_USERNAME = 'faycalhabibahmat';
const ADMIN_USERNAME_EMAIL = 'faycalhabibahmat@gmail.com';
const ADMIN_PASSWORD = 'Password235@#!';

export async function POST(req: Request) {
  const body = await req.json().catch(() => null);
  const username = (body?.username ?? '').toString().trim().toLowerCase();
  const password = (body?.password ?? '').toString();

  const okUser = username === ADMIN_USERNAME || username === ADMIN_USERNAME_EMAIL;

  if (!okUser || password !== ADMIN_PASSWORD) {
    return NextResponse.json(
      { ok: false, error: 'Accès non autorisé' },
      { status: 401 },
    );
  }

  const res = NextResponse.json({ ok: true });
  res.cookies.set('nadirx_admin', '1', {
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    path: '/',
  });
  return res;
}
