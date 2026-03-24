'use client';

import { useState, useEffect } from 'react';
import { X, Download, MapPin, Mail, Phone, Calendar, Briefcase, Code, FileText, Image, Edit2, Save, Trash2 } from 'lucide-react';
import type { Inscription } from '@/lib/supabase';
import { supabase } from '@/lib/supabase';
import { format } from 'date-fns';
import { fr } from 'date-fns/locale';

interface InscriptionDetailsProps {
  inscription: Inscription;
  onClose: () => void;
  onUpdate?: (inscription: Inscription) => void;
}

export default function InscriptionDetails({ inscription, onClose, onUpdate }: InscriptionDetailsProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [isUpdating, setIsUpdating] = useState(false);
  const [editedData, setEditedData] = useState({
    note_admin: inscription.note_admin || '',
    tag_admin: inscription.tag_admin || '',
    statut: inscription.statut,
  });

  const getImageUrl = (path: string) => {
    if (!path) return null;
    if (path.startsWith('http')) return path;
    return `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/participant-photos/${path}`;
  };

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
          admin_viewed: true,
          updated_at: new Date().toISOString(),
        })
        .eq('id', inscription.id);

      if (error) throw error;

      const updated = {
        ...inscription,
        ...editedData,
        admin_viewed: true,
      };
      
      onUpdate(updated);
      setIsEditing(false);
    } catch (error) {
      console.error('Update error:', error);
    } finally {
      setIsUpdating(false);
    }
  };

  const StatusSelect = ({ value, onChange }: { value: string; onChange: (v: 'confirme' | 'en_attente' | 'rejetee') => void }) => (
    <select
      value={value}
      onChange={(e) => onChange(e.target.value as 'confirme' | 'en_attente' | 'rejetee')}
      className="px-3 py-2 bg-surface border border-border/30 rounded text-sm font-mono text-white"
    >
      <option value="confirme">Confirmé</option>
      <option value="en_attente">En attente</option>
      <option value="rejetee">Rejeté</option>
    </select>
  );

  const StatusBadge = ({ status }: { status: string }) => {
    const colors: Record<string, string> = {
      confirme: 'bg-primary/20 text-primary border border-primary/30',
      en_attente: 'bg-secondary/20 text-secondary border border-secondary/30',
      rejetee: 'bg-error/20 text-error border border-error/30',
    };

    const labels: Record<string, string> = {
      confirme: 'Confirmé ✓',
      en_attente: 'En attente',
      rejetee: 'Rejeté',
    };

    return (
      <span className={`px-4 py-2 rounded text-xs font-bold font-mono ${colors[status] || ''}`}>
        {labels[status] || status}
      </span>
    );
  };

  const formatDate = (date: string) => {
    return format(new Date(date), 'dd MMMM yyyy', { locale: fr });
  };

  const photoUrl = getImageUrl(inscription.photo_participant_url);

  // Helper to show/hide sections based on data
  const hasValue = (value: any) => value && value !== '' && value !== '—';
  const hasPDF = (value: any) => value && value !== '';

  const InfoRow = ({
    icon: Icon,
    label,
    value,
  }: {
    icon: React.ReactNode;
    label: string;
    value: string | null | undefined;
  }) => {
    if (!hasValue(value)) return null;

    return (
      <div className="flex items-start gap-3 pb-3 border-b border-border/20 last:border-0">
        <div className="text-secondary flex-shrink-0 mt-0.5">{Icon}</div>
        <div className="flex-1">
          <p className="text-xs text-secondary/70 font-mono mb-0.5">{label}</p>
          <p className="text-sm text-white font-mono">{value}</p>
        </div>
      </div>
    );
  };

  return (
    <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4 overflow-y-auto">
      <div className="bg-surface border border-border/30 rounded-lg max-w-3xl w-full max-h-[90vh] overflow-y-auto my-8">
        {/* Header */}
        <div className="sticky top-0 bg-surface/95 border-b border-border/30 px-6 py-4 flex items-center justify-between backdrop-blur">
          <div>
            <h2 className="text-2xl font-bold font-mono text-primary glow-primary">
              {inscription.prenom} {inscription.nom}
            </h2>
            <p className="text-xs text-secondary font-mono mt-1">
              ID: {inscription.id}
            </p>
          </div>
          <button
            onClick={onClose}
            className="p-2 hover:bg-error/20 rounded-lg transition text-error"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="p-6 space-y-4">
          {/* Photo Section */}
          {photoUrl && (
            <div className="border border-primary/30 rounded-lg p-4 bg-primary/5">
              <h3 className="text-xs font-bold font-mono text-primary mb-3">PHOTO PARTICIPANT</h3>
              <img
                src={photoUrl}
                alt="Photo"
                className="w-full h-64 object-cover rounded border border-border/30 mb-3"
              />
              <button
                onClick={() => handleDownload(photoUrl, `${inscription.prenom}-${inscription.nom}-photo.jpg`)}
                className="w-full px-3 py-2 bg-primary/20 hover:bg-primary/30 text-primary rounded text-xs font-mono flex items-center justify-center gap-2 transition"
              >
                <Download className="w-3 h-3" />
                Télécharger
              </button>
            </div>
          )}

          {/* CV Section */}
          {hasPDF(inscription.cv_url) && (
            <div className="border border-secondary/30 rounded-lg p-4 bg-secondary/5">
              <h3 className="text-xs font-bold font-mono text-secondary mb-3">CURRICULUM VITAE</h3>
              <button
                onClick={() => handleDownload(
                  `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/participant-cvs/${inscription.cv_url}`,
                  `${inscription.prenom}-${inscription.nom}-cv.pdf`
                )}
                className="w-full px-3 py-2 bg-secondary/20 hover:bg-secondary/30 text-secondary rounded text-xs font-mono flex items-center justify-center gap-2 transition"
              >
                <Download className="w-3 h-3" />
                Télécharger CV
              </button>
            </div>
          )}

          {/* Admin Controls */}
          <div className="border border-border/30 rounded-lg p-4 bg-surface/30">
            <h3 className="text-xs font-bold font-mono text-primary mb-4">ADMININSTRATION</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="text-xs text-secondary/70 font-mono mb-2 block">Statut</label>
                {isEditing ? (
                  <StatusSelect
                    value={editedData.statut}
                    onChange={(v) => setEditedData({ ...editedData, statut: v })}
                  />
                ) : (
                  <StatusBadge status={inscription.statut} />
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
                    <option value="prioritaire">🔴 Prioritaire</option>
                    <option value="a_rappeler">🔔 À rappeler</option>
                    <option value="doublon">⚠ Doublon</option>
                    <option value="vip">⭐ VIP</option>
                  </select>
                ) : (
                  <span className="inline-block px-3 py-2 bg-border/20 text-secondary rounded text-xs font-mono">
                    {inscription.tag_admin || '—'}
                  </span>
                )}
              </div>
              <div>
                <label className="text-xs text-secondary/70 font-mono mb-2 block">Examiné</label>
                <span className={`inline-block px-3 py-2 rounded text-xs font-mono font-bold ${
                  inscription.admin_viewed
                    ? 'bg-primary/20 text-primary'
                    : 'bg-error/20 text-error'
                }`}>
                  {inscription.admin_viewed ? '✓ Oui' : '✗ Non'}
                </span>
              </div>
            </div>
          </div>

          {/* Notes Admin */}
          <div className="border border-border/30 rounded-lg p-4 bg-surface/30">
            <label className="text-xs font-bold font-mono text-primary mb-2 block">NOTES INTERNES</label>
            {isEditing ? (
              <textarea
                value={editedData.note_admin}
                onChange={(e) => setEditedData({ ...editedData, note_admin: e.target.value })}
                className="w-full h-20 px-3 py-2 bg-surface border border-border/30 rounded text-xs font-mono text-white resize-none"
                placeholder="Ajouter une note..."
              />
            ) : (
              <p className={`text-xs font-mono leading-relaxed ${inscription.note_admin ? 'text-white' : 'text-secondary/50'}`}>
                {inscription.note_admin || '(Aucune note)'}
              </p>
            )}
          </div>

          {/* Informations Personnelles */}
          <div className="border border-border/30 rounded-lg p-4 bg-surface/30">
            <h3 className="text-xs font-bold font-mono text-primary mb-4">INFORMATIONS PERSONNELLES</h3>
            <div className="space-y-2">
              <div className="flex items-center gap-3 font-bold text-lg text-primary glow-primary">
                {inscription.prenom} {inscription.nom}
              </div>
              <InfoRow icon={<Calendar className="w-4 h-4" />} label="Date de Naissance" value={formatDate(inscription.date_naissance)} />
              {hasValue(inscription.genre) && <InfoRow icon={<span>♀♂</span>} label="Genre" value={inscription.genre} />}
              <InfoRow icon={<Phone className="w-4 h-4" />} label="Téléphone" value={inscription.telephone} />
              <InfoRow icon={<Mail className="w-4 h-4" />} label="Email" value={inscription.email} />
              <InfoRow icon={<MapPin className="w-4 h-4" />} label="Ville" value={inscription.ville} />
              {hasValue(inscription.quartier) && <InfoRow icon={<MapPin className="w-4 h-4" />} label="Quartier" value={inscription.quartier} />}
              {hasValue(inscription.nationalite) && <InfoRow icon={<span>🌍</span>} label="Nationalité" value={inscription.nationalite} />}
            </div>
          </div>

          {/* Profil Professionnel */}
          <div className="border border-border/30 rounded-lg p-4 bg-surface/30">
            <h3 className="text-xs font-bold font-mono text-secondary mb-4">PROFIL PROFESSIONNEL</h3>
            <div className="space-y-2">
              {hasValue(inscription.situation_actuelle) && <InfoRow icon={<Briefcase className="w-4 h-4" />} label="Situation" value={inscription.situation_actuelle} />}
              {hasValue(inscription.domaine_activite) && <InfoRow icon={<Briefcase className="w-4 h-4" />} label="Domaine" value={inscription.domaine_activite} />}
              {hasValue(inscription.niveau_informatique) && <InfoRow icon={<Code className="w-4 h-4" />} label="Niveau IT" value={inscription.niveau_informatique} />}
              {hasValue(inscription.comment_connu) && <InfoRow icon={<span>ℹ</span>} label="Vous nous avez connu par" value={inscription.comment_connu} />}
            </div>
          </div>

          {/* Metadata */}
          <div className="border border-border/30 rounded p-3 bg-surface/20 text-xs font-mono space-y-1">
            <div className="flex justify-between text-secondary/70">
              <span>Inscrit:</span>
              <span className="text-white">{formatDate(inscription.created_at)}</span>
            </div>
            {inscription.consentement_rgpd && (
              <div className="flex justify-between text-secondary/70">
                <span>RGPD:</span>
                <span className="text-primary">✓ Accepté</span>
              </div>
            )}
          </div>

          {/* Action Buttons */}
          <div className="flex gap-2 justify-end pt-2">
            {isEditing ? (
              <>
                <button
                  onClick={() => setIsEditing(false)}
                  className="px-4 py-2 bg-surface border border-border/30 hover:border-border text-secondary rounded text-xs font-mono transition"
                >
                  Annuler
                </button>
                <button
                  onClick={handleUpdate}
                  disabled={isUpdating}
                  className="px-4 py-2 bg-primary/20 hover:bg-primary/30 text-primary rounded text-xs font-mono transition disabled:opacity-50 flex items-center gap-2"
                >
                  <Save className="w-3 h-3" />
                  {isUpdating ? 'Enregistrement...' : 'Enregistrer'}
                </button>
              </>
            ) : (
              <button
                onClick={() => setIsEditing(true)}
                className="px-4 py-2 bg-primary/20 hover:bg-primary/30 text-primary rounded text-xs font-mono transition flex items-center gap-2"
              >
                <Edit2 className="w-3 h-3" />
                Modifier
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
