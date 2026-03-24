'use client';

import { format } from 'date-fns';
import { fr } from 'date-fns/locale';
import { Eye, Image as ImageIcon } from 'lucide-react';
import type { Inscription } from '@/lib/supabase';

interface EnhancedInscriptionsTableProps {
  inscriptions: Inscription[];
  onViewDetails?: (inscription: Inscription) => void;
}

const StatusBadge = ({ status }: { status: string }) => {
  const colors: Record<string, string> = {
    confirme: 'bg-primary/20 text-primary border border-primary/30',
    en_attente: 'bg-secondary/20 text-secondary border border-secondary/30',
    rejetee: 'bg-error/20 text-error border border-error/30',
  };

  const labels: Record<string, string> = {
    confirme: '✓ Confirmé',
    en_attente: '⧖ En attente',
    rejetee: '✗ Rejeté',
  };

  return (
    <span className={`px-2 py-1 rounded text-xs font-bold font-mono ${colors[status] || ''}`}>
      {labels[status] || status}
    </span>
  );
};

const TagBadge = ({ tag }: { tag?: string }) => {
  if (!tag) return <span className="text-secondary text-xs">—</span>;

  const colors: Record<string, string> = {
    prioritaire: 'bg-error/20 text-error border border-error/30',
    a_rappeler: 'bg-secondary/20 text-secondary border border-secondary/30',
    doublon: 'bg-warning/20 text-warning border border-warning/30',
    vip: 'bg-primary/20 text-primary border border-primary/30',
  };

  const labels: Record<string, string> = {
    prioritaire: '🔴 Prioritaire',
    a_rappeler: '🔔 À rappeler',
    doublon: '⚠ Doublon',
    vip: '⭐ VIP',
  };

  return (
    <span className={`px-2 py-1 rounded text-xs font-bold font-mono border ${colors[tag] || ''}`}>
      {labels[tag] || tag}
    </span>
  );
};

export default function EnhancedInscriptionsTable({
  inscriptions,
  onViewDetails,
}: EnhancedInscriptionsTableProps) {
  const getPhotoUrl = (path: string) => {
    if (!path) return null;
    if (path.startsWith('http')) return path;
    return `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/participant-photos/${path}`;
  };

  return (
    <div className="space-y-4">
      <div className="border border-border/30 rounded-lg overflow-hidden bg-surface/20">
        <div className="overflow-x-auto">
          <table className="w-full text-sm font-mono">
            <thead>
              <tr className="border-b border-border/30 bg-surface/50">
                <th className="px-4 py-3 text-left text-primary font-bold">Photo</th>
                <th className="px-4 py-3 text-left text-primary font-bold">Nom & Contact</th>
                <th className="px-4 py-3 text-left text-primary font-bold">Localisation</th>
                <th className="px-4 py-3 text-left text-primary font-bold">Profil</th>
                <th className="px-4 py-3 text-left text-primary font-bold">Statut</th>
                <th className="px-4 py-3 text-left text-primary font-bold">Tag</th>
                <th className="px-4 py-3 text-left text-primary font-bold">Date</th>
                <th className="px-4 py-3 text-left text-primary font-bold">Actions</th>
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
                inscriptions.map((inscription, idx) => {
                  const photoUrl = getPhotoUrl(inscription.photo_participant_url);
                  return (
                    <tr
                      key={inscription.id}
                      className={`border-b border-border/20 hover:bg-primary/5 transition-colors ${
                        idx % 2 === 0 ? 'bg-background/30' : ''
                      } ${!inscription.admin_viewed ? 'opacity-100 border-l-2 border-l-primary' : ''}`}
                    >
                      {/* Photo */}
                      <td className="px-4 py-3">
                        {photoUrl ? (
                          <img
                            src={photoUrl}
                            alt="Photo"
                            className="w-10 h-10 rounded border border-border/30 object-cover"
                          />
                        ) : (
                          <div className="w-10 h-10 rounded border border-border/30 bg-surface/50 flex items-center justify-center">
                            <ImageIcon className="w-5 h-5 text-secondary/50" />
                          </div>
                        )}
                      </td>

                      {/* Nom & Contact */}
                      <td className="px-4 py-3">
                        <div>
                          <p className="text-primary font-bold">
                            {inscription.prenom} {inscription.nom}
                          </p>
                          <p className="text-xs text-secondary/70">{inscription.email}</p>
                          <p className="text-xs text-secondary/70">{inscription.telephone}</p>
                        </div>
                      </td>

                      {/* Localisation */}
                      <td className="px-4 py-3">
                        <div>
                          <p className="text-white">{inscription.ville}</p>
                          <p className="text-xs text-secondary/70">
                            {inscription.quartier || '—'}
                          </p>
                        </div>
                      </td>

                      {/* Profil */}
                      <td className="px-4 py-3">
                        <div>
                          <p className="text-xs">
                            <span className="text-secondary">Métier:</span> {inscription.situation_actuelle.replace(/_/g, ' ')}
                          </p>
                          <p className="text-xs text-secondary/70 mt-1">
                            Niveau: {inscription.niveau_informatique}
                          </p>
                        </div>
                      </td>

                      {/* Statut */}
                      <td className="px-4 py-3">
                        <StatusBadge status={inscription.statut} />
                      </td>

                      {/* Tag */}
                      <td className="px-4 py-3">
                        <TagBadge tag={inscription.tag_admin} />
                      </td>

                      {/* Date */}
                      <td className="px-4 py-3 text-xs text-secondary">
                        {format(new Date(inscription.created_at), 'dd MMM yyyy', {
                          locale: fr,
                        })}
                      </td>

                      {/* Actions */}
                      <td className="px-4 py-3">
                        <button
                          onClick={() => onViewDetails?.(inscription)}
                          className="inline-flex items-center gap-2 px-3 py-1.5 bg-primary/20 hover:bg-primary/30 border border-primary/50 rounded text-xs text-primary transition-colors font-bold"
                        >
                          <Eye className="w-3 h-3" />
                          Détails
                        </button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Stats Bar */}
      {inscriptions.length > 0 && (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-2 text-xs font-mono">
          <div className="border border-border/30 rounded p-3 bg-surface/20">
            <p className="text-secondary mb-1">Total</p>
            <p className="text-primary font-bold text-lg">{inscriptions.length}</p>
          </div>
          <div className="border border-primary/30 rounded p-3 bg-primary/10">
            <p className="text-primary/70 mb-1">Confirmés</p>
            <p className="text-primary font-bold text-lg">
              {inscriptions.filter(i => i.statut === 'confirme').length}
            </p>
          </div>
          <div className="border border-border/30 rounded p-3 bg-surface/20">
            <p className="text-secondary mb-1">Avec CV</p>
            <p className="text-secondary font-bold text-lg">
              {inscriptions.filter(i => i.cv_url).length}
            </p>
          </div>
          <div className="border border-border/30 rounded p-3 bg-surface/20">
            <p className="text-secondary mb-1">À voir</p>
            <p className="text-secondary font-bold text-lg">
              {inscriptions.filter(i => !i.admin_viewed).length}
            </p>
          </div>
        </div>
      )}
    </div>
  );
}
