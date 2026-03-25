'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import type { Inscription } from '@/lib/supabase';
import Header from '@/components/Header';
import EnhancedInscriptionsTable from '@/components/EnhancedInscriptionsTable';
import Filters from '@/components/Filters';
import InscriptionDetails from '@/components/InscriptionDetails';

export default function Dashboard() {
  const [inscriptions, setInscriptions] = useState<Inscription[]>([]);
  const [filteredInscriptions, setFilteredInscriptions] = useState<Inscription[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedInscription, setSelectedInscription] = useState<Inscription | null>(null);
  const [filters, setFilters] = useState({
    name: '',
    phone: '',
  });

  useEffect(() => {
    fetchInscriptions();
  }, []);

  useEffect(() => {
    applyFilters();
  }, [filters, inscriptions]);

  const fetchInscriptions = async () => {
    try {
      setLoading(true);
      const { data, error: fetchError } = await supabase
        .from('inscriptions')
        .select('*')
        .order('created_at', { ascending: false });

      if (fetchError) throw fetchError;
      setInscriptions(data || []);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur lors du chargement');
    } finally {
      setLoading(false);
    }
  };

  const applyFilters = () => {
    let filtered = inscriptions;

    if (filters.name) {
      const term = filters.name.toLowerCase();
      filtered = filtered.filter(
        i => i.nom.toLowerCase().includes(term) || i.prenom.toLowerCase().includes(term),
      );
    }

    if (filters.phone) {
      const digits = filters.phone.replace(/[^0-9]/g, '');
      filtered = filtered.filter(i => i.telephone.replace(/[^0-9]/g, '').includes(digits));
    }

    setFilteredInscriptions(filtered);
  };

  const handleExport = () => {
    const csv = [
      ['ID', 'Prénom', 'Nom', 'Téléphone', 'Ville', 'Statut', 'Date'],
      ...filteredInscriptions.map(i => [
        i.id,
        i.prenom,
        i.nom,
        i.telephone,
        i.ville,
        i.statut,
        new Date(i.created_at).toLocaleDateString('fr-FR'),
      ]),
    ]
      .map(row => row.map(cell => `"${cell}"`).join(','))
      .join('\n');

    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `inscriptions-${new Date().toISOString().split('T')[0]}.csv`;
    a.click();
  };

  const handleInscriptionUpdate = (updatedInscription: Inscription) => {
    setInscriptions(prev => prev.map(i => (i.id === updatedInscription.id ? updatedInscription : i)));
    setSelectedInscription(updatedInscription);
  };

  return (
    <div className="min-h-screen bg-background bg-gradient-to-br from-background to-dark">
      <div className="grid-bg fixed inset-0 pointer-events-none opacity-10"></div>

      <div className="relative z-10">
        <Header totalInscriptions={filteredInscriptions.length} onExport={handleExport} />

        <main className="container mx-auto px-4 py-8 max-w-7xl">
          {error && (
            <div className="mb-6 p-4 border border-error bg-error/10 rounded-lg text-error">
              {error}
            </div>
          )}

          <Filters filters={filters} setFilters={setFilters} />

          {loading ? (
            <div className="flex items-center justify-center h-96">
              <div className="animate-spin border-4 border-primary border-t-transparent rounded-full w-12 h-12"></div>
            </div>
          ) : (
            <EnhancedInscriptionsTable
              inscriptions={filteredInscriptions}
              onViewDetails={setSelectedInscription}
            />
          )}
        </main>
      </div>

      {selectedInscription && (
        <InscriptionDetails
          inscription={selectedInscription}
          onClose={() => setSelectedInscription(null)}
          onUpdate={handleInscriptionUpdate}
        />
      )}
    </div>
  );
}

