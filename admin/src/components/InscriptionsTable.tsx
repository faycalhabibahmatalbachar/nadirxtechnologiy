'use client';

import { format } from 'date-fns';
import { fr } from 'date-fns/locale';
import { ExternalLink, Eye } from 'lucide-react';
import type { Inscription } from '@/lib/supabase';

interface InscriptionsTableProps {
  inscriptions: Inscription[];
  onViewDetails?: (inscription: Inscription) => void;
}

const StatusBadge = ({ status }: { status: string }) => {
  const colors: Record<string, string> = {
    confirme: 'bg-primary/20 text-primary',
    en_attente: 'bg-secondary/20 text-secondary',
    rejetee: 'bg-error/20 text-error',
  };

  const labels: Record<string, string> = {
    confirme: 'Confirmé ✓',
    en_attente: 'En attente',
    rejetee: 'Rejeté',
  };

  return (
    <span className={`px-3 py-1 rounded text-xs font-mono ${colors[status] || ''}`}>
      {labels[status] || status}
    </span>
  );
};

export default function InscriptionsTable({ inscriptions, onViewDetails }: InscriptionsTableProps) {
  return (
    <div className="border border-border/30 rounded-lg overflow-hidden bg-surface/20">
      <div className="overflow-x-auto">
        <table className="w-full text-sm font-mono">
          <thead>
            <tr className="border-b border-border/30 bg-surface/50">
              <th className="px-6 py-4 text-left text-primary font-bold">ID</th>
              <th className="px-6 py-4 text-left text-primary font-bold">Nom Prénom</th>
              <th className="px-6 py-4 text-left text-primary font-bold">Email</th>
              <th className="px-6 py-4 text-left text-primary font-bold">Téléphone</th>
              <th className="px-6 py-4 text-left text-primary font-bold">Ville</th>
              <th className="px-6 py-4 text-left text-primary font-bold">Statut</th>
              <th className="px-6 py-4 text-left text-primary font-bold">Date</th>
              <th className="px-6 py-4 text-left text-primary font-bold">Actions</th>
            </tr>
          </thead>
          <tbody>
            {inscriptions.length === 0 ? (
              <tr>
                <td colSpan={8} className="px-6 py-12 text-center text-secondary">
                  Aucune inscription trouvée
                </td>
              </tr>
            ) : (
              inscriptions.map((inscription, idx) => (
                <tr
                  key={inscription.id}
                  className={`border-b border-border/20 hover:bg-primary/5 transition-colors ${
                    idx % 2 === 0 ? 'bg-background/30' : ''
                  }`}
                >
                  <td className="px-6 py-4">
                    <span className="text-xs text-secondary opacity-75">
                      {inscription.id.substring(0, 8)}...
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <span className="text-primary font-bold">
                      {inscription.prenom} {inscription.nom}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-secondary">{inscription.email}</td>
                  <td className="px-6 py-4 text-secondary">{inscription.telephone}</td>
                  <td className="px-6 py-4 text-secondary">{inscription.ville}</td>
                  <td className="px-6 py-4">
                    <StatusBadge status={inscription.statut} />
                  </td>
                  <td className="px-6 py-4 text-secondary text-xs">
                    {format(new Date(inscription.created_at), 'dd MMM yyyy', {
                      locale: fr,
                    })}
                  </td>
                  <td className="px-6 py-4">
                    <button
                      onClick={() => onViewDetails?.(inscription)}
                      className="inline-flex items-center gap-2 px-3 py-1 bg-secondary/10 hover:bg-secondary/20 border border-secondary/50 rounded text-xs text-secondary transition-colors"
                    >
                      <Eye className="w-3 h-3" />
                      Détails
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
