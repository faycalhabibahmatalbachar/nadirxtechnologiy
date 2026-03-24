'use client';

import { Search, Filter } from 'lucide-react';

interface FiltersProps {
  filters: {
    status: string;
    searchTerm: string;
    ville: string;
  };
  setFilters: (filters: any) => void;
  cities: string[];
}

export default function Filters({ filters, setFilters, cities }: FiltersProps) {
  return (
    <div className="mb-8 border border-border/30 rounded-lg p-6 bg-surface/30">
      <h2 className="text-lg font-mono font-bold text-primary mb-4 flex items-center gap-2">
        <Filter className="w-4 h-4" />
        FILTERS
      </h2>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {/* Search */}
        <div>
          <label className="block text-sm font-mono text-secondary mb-2">
            Rechercher
          </label>
          <div className="relative">
            <Search className="absolute left-3 top-3 w-4 h-4 text-secondary" />
            <input
              type="text"
              placeholder="Nom, prénom, email..."
              value={filters.searchTerm}
              onChange={(e) =>
                setFilters({ ...filters, searchTerm: e.target.value })
              }
              className="w-full pl-10 pr-4 py-2 bg-background border border-border/50 rounded text-white font-mono text-sm focus:border-primary focus:outline-none transition-colors"
            />
          </div>
        </div>

        {/* Status */}
        <div>
          <label className="block text-sm font-mono text-secondary mb-2">
            Statut
          </label>
          <select
            value={filters.status}
            onChange={(e) => setFilters({ ...filters, status: e.target.value })}
            className="w-full px-4 py-2 bg-background border border-border/50 rounded text-white font-mono text-sm focus:border-primary focus:outline-none transition-colors"
          >
            <option value="">Tous</option>
            <option value="confirme">Confirmé</option>
            <option value="en_attente">En attente</option>
            <option value="rejetee">Rejeté</option>
          </select>
        </div>

        {/* City */}
        <div>
          <label className="block text-sm font-mono text-secondary mb-2">
            Ville
          </label>
          <select
            value={filters.ville}
            onChange={(e) => setFilters({ ...filters, ville: e.target.value })}
            className="w-full px-4 py-2 bg-background border border-border/50 rounded text-white font-mono text-sm focus:border-primary focus:outline-none transition-colors"
          >
            <option value="">Toutes les villes</option>
            {cities.map((city) => (
              <option key={city} value={city}>
                {city}
              </option>
            ))}
          </select>
        </div>
      </div>
    </div>
  );
}
