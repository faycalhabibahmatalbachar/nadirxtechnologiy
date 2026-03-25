import type { NextRequest } from 'next/server';
import { NextResponse } from 'next/server';

function isPublicPath(pathname: string) {
  if (pathname.startsWith('/_next')) return true;
  if (pathname.startsWith('/api/auth')) return true;
  if (pathname === '/login') return true;
  if (pathname === '/favicon.ico') return true;
  if (pathname === '/logo.png') return true;
  if (pathname === '/robots.txt') return true;
  if (pathname.startsWith('/.well-known')) return true;
  return false;
}

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  if (isPublicPath(pathname)) return NextResponse.next();

  const cookieValue = req.cookies.get('nadirx_admin')?.value;
  const expected = process.env.ADMIN_SESSION_TOKEN || '1';

  if (cookieValue === expected) return NextResponse.next();

  const url = req.nextUrl.clone();
  url.pathname = '/login';
  return NextResponse.redirect(url);
}

export const config = {
  matcher: ['/:path*'],
};

