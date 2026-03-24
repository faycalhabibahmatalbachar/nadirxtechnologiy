'use client';

import { BarChart3, Users, CheckCircle, Clock, XCircle, FileText, Camera, MapPin } from 'lucide-react';
import type { Inscription } from '@/lib/supabase';

interface StatsProps {
  inscriptions: Inscription[];
}

export default function Stats({ inscriptions }: StatsProps) {
  const stats = {
    total: inscriptions.length,
    confirmed: inscriptions.filter(i => i.statut === 'confirme').length,
    pending: inscriptions.filter(i => i.statut === 'en_attente').length,
    rejected: inscriptions.filter(i => i.statut === 'rejetee').length,
    withCV: inscriptions.filter(i => i.cv_url).length,
    withPhoto: inscriptions.filter(i => i.photo_participant_url).length,
    unviewed: inscriptions.filter(i => !i.admin_viewed).length,
    tagged: inscriptions.filter(i => i.tag_admin).length,
    cities: [...new Set(inscriptions.map(i => i.ville))].length,
  };

  const confirmationRate = inscriptions.length > 0 
    ? Math.round((stats.confirmed / inscriptions.length) * 100) 
    : 0;

  const StatCard = ({
    icon: Icon,
    label,
    value,
    subtext,
    color = 'primary',
    trend,
  }: {
    icon: React.ReactNode;
    label: string;
    value: number | string;
    subtext?: string;
    color?: 'primary' | 'secondary' | 'success' | 'error' | 'warning';
    trend?: number;
  }) => {
    const colorClasses = {
      primary: 'border-primary/30 bg-primary/5 text-primary glow-primary',
      secondary: 'border-secondary/30 bg-secondary/5 text-secondary',
      success: 'border-primary/30 bg-primary/5 text-primary',
      error: 'border-error/30 bg-error/5 text-error',
      warning: 'border-secondary/30 bg-secondary/5 text-secondary',
    };

    return (
      <div className={`border rounded-lg p-4 ${colorClasses[color]} transition-all hover:border-opacity-100`}>
        <div className="flex items-start justify-between mb-3">
          <div className="text-xs font-bold font-mono uppercase tracking-wider">{label}</div>
          <div className="text-lg opacity-60">{Icon}</div>
        </div>
        <div className="text-2xl font-bold font-mono mb-1">{value}</div>
        {subtext && <div className="text-xs font-mono opacity-60">{subtext}</div>}
        {trend !== undefined && (
          <div className={`text-xs font-mono mt-1 ${trend >= 0 ? 'text-primary' : 'text-error'}`}>
            {trend >= 0 ? '↑' : '↓'} {Math.abs(trend)}%
          </div>
        )}
      </div>
    );
  };

  return (
    <div className="space-y-6">
      {/* Main Stats Grid */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        <StatCard
          icon={<Users className="w-4 h-4" />}
          label="Inscriptions"
          value={stats.total}
          color="primary"
        />
        <StatCard
          icon={<CheckCircle className="w-4 h-4" />}
          label="Confirmés"
          value={stats.confirmed}
          subtext={`${confirmationRate}%`}
          color="success"
        />
        <StatCard
          icon={<Clock className="w-4 h-4" />}
          label="En attente"
          value={stats.pending}
          color="warning"
        />
        <StatCard
          icon={<XCircle className="w-4 h-4" />}
          label="Rejetés"
          value={stats.rejected}
          color="error"
        />
        <StatCard
          icon={<FileText className="w-4 h-4" />}
          label="Avec CV"
          value={stats.withCV}
          subtext={`${Math.round((stats.withCV / stats.total) * 100) || 0}%`}
          color="secondary"
        />
        <StatCard
          icon={<Camera className="w-4 h-4" />}
          label="Photos"
          value={stats.withPhoto}
          subtext={`${Math.round((stats.withPhoto / stats.total) * 100) || 0}%`}
          color="secondary"
        />
        <StatCard
          icon={<MapPin className="w-4 h-4" />}
          label="Villes"
          value={stats.cities}
          color="secondary"
        />
        <StatCard
          icon={<span className="text-xs">👁</span>}
          label="À voir"
          value={stats.unviewed}
          color={stats.unviewed > 0 ? 'error' : 'success'}
        />
      </div>

      {/* Detailed Stats */}
      {inscriptions.length > 0 && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {/* Status Distribution */}
          <div className="border border-border/30 rounded-lg p-4 bg-surface/20">
            <div className="flex items-center gap-2 mb-4">
              <BarChart3 className="w-4 h-4 text-primary" />
              <h3 className="text-sm font-bold font-mono text-primary">Distribution Statut</h3>
            </div>
            <div className="space-y-3">
              <div>
                <div className="flex justify-between items-center mb-1">
                  <span className="text-xs text-secondary font-mono">Confirmés</span>
                  <span className="text-xs text-primary font-bold">{stats.confirmed}</span>
                </div>
                <div className="w-full bg-surface/50 rounded h-2 overflow-hidden">
                  <div
                    className="bg-primary h-full"
                    style={{
                      width: `${(stats.confirmed / stats.total) * 100 || 0}%`,
                    }}
                  />
                </div>
              </div>
              <div>
                <div className="flex justify-between items-center mb-1">
                  <span className="text-xs text-secondary font-mono">En attente</span>
                  <span className="text-xs text-secondary font-bold">{stats.pending}</span>
                </div>
                <div className="w-full bg-surface/50 rounded h-2 overflow-hidden">
                  <div
                    className="bg-secondary h-full"
                    style={{
                      width: `${(stats.pending / stats.total) * 100 || 0}%`,
                    }}
                  />
                </div>
              </div>
              <div>
                <div className="flex justify-between items-center mb-1">
                  <span className="text-xs text-secondary font-mono">Rejetés</span>
                  <span className="text-xs text-error font-bold">{stats.rejected}</span>
                </div>
                <div className="w-full bg-surface/50 rounded h-2 overflow-hidden">
                  <div
                    className="bg-error h-full"
                    style={{
                      width: `${(stats.rejected / stats.total) * 100 || 0}%`,
                    }}
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Top Cities */}
          {inscriptions.length > 0 && (
            <div className="border border-border/30 rounded-lg p-4 bg-surface/20">
              <div className="flex items-center gap-2 mb-4">
                <MapPin className="w-4 h-4 text-secondary" />
                <h3 className="text-sm font-bold font-mono text-secondary">Top Villes</h3>
              </div>
              <div className="space-y-2.5">
                {[...inscriptions]
                  .reduce(
                    (acc, i) => {
                      const existing = acc.find(x => x.city === i.ville);
                      if (existing) {
                        existing.count++;
                      } else {
                        acc.push({ city: i.ville, count: 1 });
                      }
                      return acc;
                    },
                    [] as Array<{ city: string; count: number }>
                  )
                  .sort((a, b) => b.count - a.count)
                  .slice(0, 5)
                  .map(({ city, count }) => (
                    <div key={city}>
                      <div className="flex justify-between items-center mb-1">
                        <span className="text-xs text-secondary font-mono">{city}</span>
                        <span className="text-xs text-primary font-bold">{count}</span>
                      </div>
                      <div className="w-full bg-surface/50 rounded h-1.5 overflow-hidden">
                        <div
                          className="bg-secondary h-full"
                          style={{
                            width: `${(count / stats.total) * 100}%`,
                          }}
                        />
                      </div>
                    </div>
                  ))}
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
