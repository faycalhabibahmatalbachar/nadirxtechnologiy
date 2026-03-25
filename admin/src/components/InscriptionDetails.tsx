'use client';

import { useMemo, useState } from 'react';
import {
  X,
  Download,
  Phone,
  Calendar,
  MapPin,
  Briefcase,
  Code,
  Edit2,
  Save,
  ShieldCheck,
  Flag,
} from 'lucide-react';
import type { Inscription } from '@/lib/supabase';
import { supabase } from '@/lib/supabase';
import { format } from 'date-fns';
import { fr } from 'date-fns/locale';

interface InscriptionDetailsProps {
  inscription: Inscription;
  onClose: () => void;
  onUpdate?: (inscription: Inscription) => void;
}

type Status = 'confirme' | 'en_attente' | 'rejetee';

function formatDate(date: string) {
  return format(new Date(date), 'dd MMMM yyyy', { locale: fr });
}

function normalizeUrl(pathOrUrl?: string | null) {
  if (!pathOrUrl) return null;
  if (pathOrUrl.startsWith('http')) return pathOrUrl;
  return `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/participants/${pathOrUrl}`;
}

export default function InscriptionDetails({
  inscription,
  onClose,
  onUpdate,
}: InscriptionDetailsProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [isUpdating, setIsUpdating] = useState(false);
  const [editedData, setEditedData] = useState({
    note_admin: inscription.note_admin || '',
    tag_admin: inscription.tag_admin || '',
    statut: inscription.statut as Status,
    admin_viewed: inscription.admin_viewed ?? false,
  });

  const photoUrl = useMemo(
    () => normalizeUrl(inscription.photo_participant_url),
    [inscription.photo_participant_url],
  );
  const cvUrl = useMemo(() => normalizeUrl(inscription.cv_url), [inscription.cv_url]);

  const handleDownload = async (url: string | null, filename: string) => {
    if (!url) return;
    try {
      const response = await fetch(url);
      const blob = await response.blob();
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = filename;
      a.click();
    } catch (error) {
      console.error('Download error:', error);
    }
  };

  const handleUpdate = async () => {
    if (!onUpdate) return;

    setIsUpdating(true);
    try {
      const { error } = await supabase
        .from('inscriptions')
        .update({
          note_admin: editedData.note_admin,
          tag_admin: editedData.tag_admin,
          statut: editedData.statut,
          admin_viewed: editedData.admin_viewed,
        })
        .eq('id', inscription.id);

      if (error) throw error;

      onUpdate({
        ...inscription,
        ...editedData,
        admin_viewed: editedData.admin_viewed,
      });
      setIsEditing(false);
    } catch (error) {
      console.error('Update error:', error);
    } finally {
      setIsUpdating(false);
    }
  };

  const StatusSelect = ({ value, onChange }: { value: Status; onChange: (v: Status) => void }) => (
    <select
      value={value}
      onChange={(e) => onChange(e.target.value as Status)}
      className="px-3 py-2 bg-surface border border-border/30 rounded text-sm font-mono text-white"
    >
      <option value="confirme">Confirmé</option>
      <option value="en_attente">En attente</option>
      <option value="rejetee">Rejeté</option>
    </select>
  );

  const StatusBadge = ({ status }: { status: Status }) => {
    const colors: Record<Status, string> = {
      confirme: 'bg-primary/20 text-primary border border-primary/30',
      en_attente: 'bg-secondary/20 text-secondary border border-secondary/30',
      rejetee: 'bg-error/20 text-error border border-error/30',
    };

    const labels: Record<Status, string> = {
      confirme: 'Confirmé ✓',
      en_attente: 'En attente',
      rejetee: 'Rejeté',
    };

    return (
      <span className={`inline-block px-3 py-2 rounded text-xs font-mono font-bold ${colors[status]}`}>
        {labels[status]}
      </span>
    );
  };

  const fullName = `${inscription.prenom} ${inscription.nom}`.trim();

  return (
    <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4 overflow-y-auto">
      <div className="bg-surface border border-border/30 rounded-lg max-w-4xl w-full max-h-[90vh] overflow-y-auto my-8">
        <div className="sticky top-0 bg-surface/95 border-b border-border/30 px-6 py-4 flex items-center justify-between">
          <div>
            <h2 className="text-lg font-bold font-mono text-primary">{fullName}</h2>
            <p className="text-xs text-secondary font-mono">ID: {inscription.id}</p>
          </div>

          <button
            onClick={onClose}
            className="p-2 hover:bg-border/20 rounded transition-colors"
            aria-label="Fermer"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="p-6 space-y-4">
          {photoUrl && (
            <div className="border border-primary/30 rounded-lg p-4 bg-primary/5">
              <h3 className="text-xs font-bold font-mono text-primary mb-3">PHOTO PARTICIPANT</h3>
              <div className="w-full flex justify-center mb-3">
                <div className="w-48 h-48 border border-border/30 rounded bg-surface/30 flex items-center justify-center overflow-hidden">
                  <img src={photoUrl} alt="Photo" className="w-full h-full object-contain" />
                </div>
              </div>
              <button
                onClick={() => handleDownload(photoUrl, `${inscription.prenom}-${inscription.nom}-photo.png`)}
                className="w-full px-3 py-2 bg-primary/20 hover:bg-primary/30 text-primary rounded text-xs font-mono flex items-center justify-center gap-2 transition"
              >
                <Download className="w-3 h-3" />
                Télécharger
              </button>
            </div>
          )}

          {cvUrl && (
            <div className="border border-secondary/30 rounded-lg p-4 bg-secondary/5">
              <h3 className="text-xs font-bold font-mono text-secondary mb-3">CURRICULUM VITAE</h3>
              <button
                onClick={() => handleDownload(cvUrl, `${inscription.prenom}-${inscription.nom}-cv.pdf`)}
                className="w-full px-3 py-2 bg-secondary/20 hover:bg-secondary/30 text-secondary rounded text-xs font-mono flex items-center justify-center gap-2 transition"
              >
                <Download className="w-3 h-3" />
                Télécharger CV
              </button>
            </div>
          )}

          <div className="border border-border/30 rounded-lg p-4 bg-surface/30">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xs font-bold font-mono text-primary">ADMINISTRATION</h3>
              {onUpdate && (
                <button
                  onClick={() => (isEditing ? handleUpdate() : setIsEditing(true))}
                  disabled={isUpdating}
                  className="inline-flex items-center gap-2 px-3 py-2 bg-primary/10 hover:bg-primary/20 border border-primary/30 rounded text-xs font-mono text-primary disabled:opacity-50"
                >
                  {isEditing ? <Save className="w-3 h-3" /> : <Edit2 className="w-3 h-3" />}
                  {isEditing ? 'Enregistrer' : 'Modifier'}
                </button>
              )}
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="text-xs text-secondary/70 font-mono mb-2 block">Statut</label>
                {isEditing ? (
                  <StatusSelect
                    value={editedData.statut}
                    onChange={(v) => setEditedData({ ...editedData, statut: v })}
                  />
                ) : (
                  <StatusBadge status={inscription.statut as Status} />
                )}
              </div>

              <div>
                <label className="text-xs text-secondary/70 font-mono mb-2 block">Catégorie</label>
                {isEditing ? (
                  <select
                    value={editedData.tag_admin}
                    onChange={(e) => setEditedData({ ...editedData, tag_admin: e.target.value })}
                    className="w-full px-3 py-2 bg-surface border border-border/30 rounded text-xs font-mono text-white"
                  >
                    <option value="">—</option>
                    <option value="prioritaire">Prioritaire</option>
                    <option value="a_rappeler">À rappeler</option>
                    <option value="doublon">Doublon</option>
                    <option value="vip">VIP</option>
                  </select>
                ) : (
                  <span className="inline-block px-3 py-2 bg-border/20 text-secondary rounded text-xs font-mono">
                    {inscription.tag_admin || '—'}
                  </span>
                )}
              </div>

              <div>
                <label className="text-xs text-secondary/70 font-mono mb-2 block">Examiné</label>
                {isEditing ? (
                  <label className="inline-flex items-center gap-2 px-3 py-2 bg-surface border border-border/30 rounded text-xs font-mono text-white">
                    <input
                      type="checkbox"
                      checked={editedData.admin_viewed}
                      onChange={(e) =>
                        setEditedData({
                          ...editedData,
                          admin_viewed: e.target.checked,
                        })
                      }
                    />
                    {editedData.admin_viewed ? '✓ Oui' : '✗ Non'}
                  </label>
                ) : (
                  <span
                    className={`inline-block px-3 py-2 rounded text-xs font-mono font-bold ${
                      inscription.admin_viewed ? 'bg-primary/20 text-primary' : 'bg-error/20 text-error'
                    }`}
                  >
                    {inscription.admin_viewed ? '✓ Oui' : '✗ Non'}
                  </span>
                )}
              </div>
            </div>
          </div>

          <div className="border border-border/30 rounded-lg p-4 bg-surface/30">
            <h3 className="text-xs font-bold font-mono text-primary mb-4">NOTES INTERNES</h3>
            {isEditing ? (
              <textarea
                value={editedData.note_admin}
                onChange={(e) => setEditedData({ ...editedData, note_admin: e.target.value })}
                className="w-full min-h-24 px-3 py-2 bg-background border border-border/30 rounded text-sm font-mono text-white"
                placeholder="Ajouter une note..."
              />
            ) : (
              <p className="text-sm font-mono text-secondary">
                {inscription.note_admin?.trim() ? inscription.note_admin : '(Aucune note)'}
              </p>
            )}
          </div>

          <div className="border border-border/30 rounded-lg p-4 bg-surface/30">
            <h3 className="text-xs font-bold font-mono text-primary mb-4">INFORMATIONS PERSONNELLES</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <div className="flex items-start gap-3 pb-3 border-b border-border/20">
                <div className="text-secondary flex-shrink-0 mt-0.5">
                  <Calendar className="w-4 h-4" />
                </div>
                <div className="flex-1">
                  <p className="text-xs text-secondary/70 font-mono mb-0.5">Date de naissance</p>
                  <p className="text-sm text-white font-mono">{formatDate(inscription.date_naissance)}</p>
                </div>
              </div>

              <div className="flex items-start gap-3 pb-3 border-b border-border/20">
                <div className="text-secondary flex-shrink-0 mt-0.5">
                  <Phone className="w-4 h-4" />
                </div>
                <div className="flex-1">
                  <p className="text-xs text-secondary/70 font-mono mb-0.5">Téléphone</p>
                  <p className="text-sm text-white font-mono">{inscription.telephone}</p>
                </div>
              </div>

              <div className="flex items-start gap-3 pb-3 border-b border-border/20">
                <div className="text-secondary flex-shrink-0 mt-0.5">
                  <MapPin className="w-4 h-4" />
                </div>
                <div className="flex-1">
                  <p className="text-xs text-secondary/70 font-mono mb-0.5">Ville</p>
                  <p className="text-sm text-white font-mono">{inscription.ville}</p>
                  {inscription.quartier && (
                    <p className="text-xs text-secondary/70 font-mono mt-0.5">{inscription.quartier}</p>
                  )}
                </div>
              </div>

              <div className="flex items-start gap-3 pb-3 border-b border-border/20">
                <div className="text-secondary flex-shrink-0 mt-0.5">
                  <Flag className="w-4 h-4" />
                </div>
                <div className="flex-1">
                  <p className="text-xs text-secondary/70 font-mono mb-0.5">Nationalité</p>
                  <p className="text-sm text-white font-mono">{inscription.nationalite || '—'}</p>
                </div>
              </div>

              <div className="flex items-start gap-3 pb-3 border-b border-border/20">
                <div className="text-secondary flex-shrink-0 mt-0.5">
                  <span className="w-4 h-4 inline-flex items-center justify-center text-xs">♀♂</span>
                </div>
                <div className="flex-1">
                  <p className="text-xs text-secondary/70 font-mono mb-0.5">Genre</p>
                  <p className="text-sm text-white font-mono">{inscription.genre || '—'}</p>
                </div>
              </div>

              <div className="flex items-start gap-3 pb-3 border-b border-border/20">
                <div className="text-secondary flex-shrink-0 mt-0.5">
                  <ShieldCheck className="w-4 h-4" />
                </div>
                <div className="flex-1">
                  <p className="text-xs text-secondary/70 font-mono mb-0.5">RGPD</p>
                  <p className="text-sm text-white font-mono">
                    {inscription.consentement_rgpd ? '✓ Accepté' : '✗ Non'}
                  </p>
                </div>
              </div>
            </div>
          </div>

          <div className="border border-border/30 rounded-lg p-4 bg-surface/30">
            <h3 className="text-xs font-bold font-mono text-primary mb-4">PROFIL PROFESSIONNEL</h3>
            <div className="space-y-3">
              <div className="flex items-start gap-3 pb-3 border-b border-border/20">
                <div className="text-secondary flex-shrink-0 mt-0.5">
                  <Briefcase className="w-4 h-4" />
                </div>
                <div className="flex-1">
                  <p className="text-xs text-secondary/70 font-mono mb-0.5">Situation</p>
                  <p className="text-sm text-white font-mono">
                    {inscription.situation_actuelle.replace(/_/g, ' ')}
                  </p>
                </div>
              </div>

              <div className="flex items-start gap-3 pb-3 border-b border-border/20">
                <div className="text-secondary flex-shrink-0 mt-0.5">
                  <Code className="w-4 h-4" />
                </div>
                <div className="flex-1">
                  <p className="text-xs text-secondary/70 font-mono mb-0.5">Niveau IT</p>
                  <p className="text-sm text-white font-mono">{inscription.niveau_informatique}</p>
                </div>
              </div>

              {inscription.domaine_activite && (
                <div className="flex items-start gap-3 pb-3 border-b border-border/20">
                  <div className="text-secondary flex-shrink-0 mt-0.5">
                    <span className="w-4 h-4 inline-flex items-center justify-center text-xs">💼</span>
                  </div>
                  <div className="flex-1">
                    <p className="text-xs text-secondary/70 font-mono mb-0.5">Domaine</p>
                    <p className="text-sm text-white font-mono">{inscription.domaine_activite}</p>
                  </div>
                </div>
              )}

              <div className="flex items-start gap-3">
                <div className="text-secondary flex-shrink-0 mt-0.5">
                  <span className="w-4 h-4 inline-flex items-center justify-center text-xs">🎯</span>
                </div>
                <div className="flex-1">
                  <p className="text-xs text-secondary/70 font-mono mb-0.5">Objectif</p>
                  <p className="text-sm text-white font-mono whitespace-pre-wrap">
                    {inscription.objectif_formation}
                  </p>
                </div>
              </div>

              <div className="flex items-start gap-3 pt-3 border-t border-border/20">
                <div className="text-secondary flex-shrink-0 mt-0.5">
                  <span className="w-4 h-4 inline-flex items-center justify-center text-xs">🗓</span>
                </div>
                <div className="flex-1">
                  <p className="text-xs text-secondary/70 font-mono mb-0.5">Inscrit</p>
                  <p className="text-sm text-white font-mono">{formatDate(inscription.created_at)}</p>
                </div>
              </div>
            </div>
          </div>

          {isEditing && (
            <div className="flex justify-end">
              <button
                onClick={handleUpdate}
                disabled={isUpdating}
                className="inline-flex items-center gap-2 px-4 py-2 bg-primary/20 hover:bg-primary/30 border border-primary/40 rounded text-primary font-mono text-sm transition disabled:opacity-50"
              >
                <Save className="w-4 h-4" />
                {isUpdating ? 'Enregistrement…' : 'Enregistrer'}
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

