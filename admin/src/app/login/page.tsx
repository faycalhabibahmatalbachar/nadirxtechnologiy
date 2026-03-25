'use client';

import { useState } from 'react';
import { Lock, User } from 'lucide-react';

export default function LoginPage() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const res = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password }),
      });

      if (!res.ok) {
        const data = await res.json().catch(() => null);
        setError(data?.error || 'Accès non autorisé');
        setLoading(false);
        return;
      }

      window.location.href = '/';
    } catch (_) {
      setError('Erreur de connexion');
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background bg-gradient-to-br from-background to-dark flex items-center justify-center p-6">
      <div className="grid-bg fixed inset-0 pointer-events-none opacity-10"></div>

      <div className="relative z-10 w-full max-w-md border border-border/30 rounded-lg bg-surface/40 backdrop-blur p-6">
        <div className="flex items-center gap-3 mb-6">
          <img
            src="/icon.png"
            alt="NADIRX"
            className="w-10 h-10 rounded border border-border/30 bg-surface/30 object-contain"
          />
          <div>
            <h1 className="text-xl font-bold font-mono text-primary glow-primary">
              NADIRX TECHNOLOGY
            </h1>
            <p className="text-xs text-secondary font-mono">Accès administrateur</p>
          </div>
        </div>

        <form onSubmit={submit} className="space-y-4">
          <div>
            <label className="block text-sm font-mono text-secondary mb-2">
              Identifiant
            </label>
            <div className="relative">
              <User className="absolute left-3 top-3 w-4 h-4 text-secondary" />
              <input
                type="text"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                className="w-full pl-10 pr-4 py-2 bg-background border border-border/50 rounded text-white font-mono text-sm focus:border-primary focus:outline-none transition-colors"
                placeholder="Votre identifiant"
                autoComplete="username"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-mono text-secondary mb-2">
              Mot de passe
            </label>
            <div className="relative">
              <Lock className="absolute left-3 top-3 w-4 h-4 text-secondary" />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full pl-10 pr-4 py-2 bg-background border border-border/50 rounded text-white font-mono text-sm focus:border-primary focus:outline-none transition-colors"
                placeholder="Votre mot de passe"
                autoComplete="current-password"
              />
            </div>
          </div>

          {error && (
            <div className="p-3 border border-error/40 bg-error/10 rounded text-error text-sm font-mono">
              {error}
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full px-4 py-2 bg-primary/20 hover:bg-primary/30 text-primary border border-primary/40 rounded font-mono text-sm transition disabled:opacity-50"
          >
            {loading ? 'Connexion...' : 'Se connecter'}
          </button>
        </form>
      </div>
    </div>
  );
}
