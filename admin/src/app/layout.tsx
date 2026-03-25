import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'NADIRX TECHNOLOGY — Admin',
  description: 'Admin dashboard for NADIRX TECHNOLOGY inscriptions management',
  icons: {
    icon: '/logo.png',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="fr">
      <body className="bg-dark text-white font-sans">{children}</body>
    </html>
  );
}
