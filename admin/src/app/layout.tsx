import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'NADIRX Admin - Inscriptions',
  description: 'Admin dashboard for NADIRX TECHNOLOGIE inscriptions management',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="bg-dark text-white font-sans">
        {children}
      </body>
    </html>
  );
}
