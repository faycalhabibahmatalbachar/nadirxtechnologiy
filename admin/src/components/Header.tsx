'use client';

import { Download, LogOut } from 'lucide-react';

interface HeaderProps {
  totalInscriptions: number;
  onExport: () => void;
}

export default function Header({ totalInscriptions, onExport }: HeaderProps) {
  const logout = async () => {
    try {
      await fetch('/api/auth/logout', { method: 'POST' });
    } finally {
      window.location.href = '/login';
    }
  };

  return (
    <header className="border-b border-border/30 bg-surface/50 backdrop-blur-sm sticky top-0 z-50">
      <div className="container mx-auto px-4 py-6 flex items-center justify-between max-w-7xl">
        <div className="flex items-center gap-3">
          <img
            src="/logo.png"
            alt="NADIRX TECHNOLOGY"
            className="w-9 h-9 rounded border border-border/30 bg-surface/30 object-contain"
          />
          <div>
            <h1 className="text-2xl font-bold font-mono glow-primary">
              NADIRX TECHNOLOGY
            </h1>
            <p className="text-xs text-secondary font-mono">
              Admin — Inscriptions
            </p>
          </div>
        </div>

        <div className="flex items-center gap-6">
          <div className="text-right">
            <p className="text-primary font-mono font-bold text-xl glow-primary">
              {totalInscriptions}
            </p>
            <p className="text-xs text-secondary font-mono">Inscriptions</p>
          </div>

          <div className="flex gap-3">
            <button
              onClick={onExport}
              className="flex items-center gap-2 px-4 py-2 bg-primary/10 hover:bg-primary/20 border border-primary rounded transition-colors text-primary font-mono text-sm"
            >
              <Download className="w-4 h-4" />
              Export CSV
            </button>
            <button
              onClick={logout}
              className="flex items-center gap-2 px-4 py-2 bg-error/10 hover:bg-error/20 border border-error rounded transition-colors text-error font-mono text-sm"
            >
              <LogOut className="w-4 h-4" />
              Déconnexion
            </button>
          </div>
        </div>
      </div>
    </header>
  );
}
