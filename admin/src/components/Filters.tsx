'use client';

import { Filter, Phone, Search } from 'lucide-react';

interface FiltersProps {
  filters: {
    name: string;
    phone: string;
  };
  setFilters: (filters: any) => void;
}

export default function Filters({ filters, setFilters }: FiltersProps) {
  return (
    <div className="mb-8 border border-border/30 rounded-lg p-6 bg-surface/30">
      <h2 className="text-lg font-mono font-bold text-primary mb-4 flex items-center gap-2">
        <Filter className="w-4 h-4" />
        RECHERCHE
      </h2>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-mono text-secondary mb-2">
            Nom / prénom
          </label>
          <div className="relative">
            <Search className="absolute left-3 top-3 w-4 h-4 text-secondary" />
            <input
              type="text"
              placeholder="Ex: Habib, Faycal..."
              value={filters.name}
              onChange={(e) => setFilters({ ...filters, name: e.target.value })}
              className="w-full pl-10 pr-4 py-2 bg-background border border-border/50 rounded text-white font-mono text-sm focus:border-primary focus:outline-none transition-colors"
            />
          </div>
        </div>

        <div>
          <label className="block text-sm font-mono text-secondary mb-2">
            Téléphone
          </label>
          <div className="relative">
            <Phone className="absolute left-3 top-3 w-4 h-4 text-secondary" />
            <input
              type="text"
              placeholder="Ex: 68663737"
              value={filters.phone}
              onChange={(e) => setFilters({ ...filters, phone: e.target.value })}
              className="w-full pl-10 pr-4 py-2 bg-background border border-border/50 rounded text-white font-mono text-sm focus:border-primary focus:outline-none transition-colors"
            />
          </div>
        </div>
      </div>
    </div>
  );
}

