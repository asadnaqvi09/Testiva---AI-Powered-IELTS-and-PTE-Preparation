import React, { useState } from 'react';
import { Search, Loader2 } from 'lucide-react';
import { getProgressResultAPI } from '../services/api';
import { toast } from 'sonner';

// This is a comment: read-only attempt inspector for FYP admin demos
export function AttemptInspector() {
  const [attemptId, setAttemptId] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<any>(null);

  const load = async () => {
    const id = attemptId.trim();
    if (!id) {
      toast.error('Enter attempt UUID');
      return;
    }
    setLoading(true);
    setResult(null);
    try {
      const res = await getProgressResultAPI(id);
      if (!res.success) throw new Error('Failed to load attempt');
      setResult(res.data);
    } catch (err: any) {
      toast.error(err.message || 'Attempt not found');
    } finally {
      setLoading(false);
    }
  };

  const main = result?.main_info || {};
  const scores = result?.scores_breakdown || {};
  const ai = result?.ai_analysis || {};

  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold" style={{ color: '#1A1A1A' }}>
          Attempt Inspector
        </h1>
        <p className="text-sm text-gray-500 mt-0.5">
          Read-only view of student mock attempt bands, status, and AI feedback
        </p>
      </div>

      <div className="bg-white rounded-xl border p-4 flex flex-wrap gap-2" style={{ borderColor: '#E5E7EB' }}>
        <div className="relative flex-1 min-w-64">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            value={attemptId}
            onChange={(e) => setAttemptId(e.target.value)}
            placeholder="Paste attempt UUID…"
            className="w-full pl-9 pr-3 py-2 text-sm rounded-lg border"
            style={{ borderColor: '#E5E7EB' }}
          />
        </div>
        <button
          onClick={load}
          disabled={loading}
          className="px-4 py-2 rounded-lg text-white text-sm font-medium disabled:opacity-50"
          style={{ background: '#007BFF' }}
        >
          {loading ? <Loader2 className="animate-spin" size={16} /> : 'Inspect'}
        </button>
      </div>

      {result && (
        <div className="bg-white rounded-xl border p-5 space-y-4" style={{ borderColor: '#E5E7EB' }}>
          <div>
            <p className="text-lg font-semibold">{main.test_title || 'Untitled test'}</p>
            <p className="text-sm text-gray-500">
              {main.test_type} · status: <strong>{main.status}</strong> · band {main.band_score} · CEFR{' '}
              {main.cefr_level}
            </p>
          </div>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            {(['reading', 'listening', 'writing', 'speaking'] as const).map((k) => (
              <div key={k} className="rounded-lg bg-gray-50 p-3 text-center">
                <p className="text-xs uppercase text-gray-500">{k}</p>
                <p className="text-xl font-bold">{scores[k] ?? 0}</p>
              </div>
            ))}
          </div>
          <div>
            <p className="text-sm font-semibold mb-1">AI feedback</p>
            <p className="text-sm text-gray-700 whitespace-pre-wrap">
              {ai.feedback || 'No AI feedback yet (pending evaluation).'}
            </p>
          </div>
          <div>
            <p className="text-sm font-semibold mb-1">
              Review items ({(result.review || []).length})
            </p>
            <ul className="text-xs text-gray-600 max-h-64 overflow-auto space-y-1">
              {(result.review || []).slice(0, 40).map((r: any, i: number) => (
                <li key={i} className="border-b border-gray-100 pb-1">
                  Q{r.q_no}: {r.section_type} / {r.type} —{' '}
                  {r.is_correct === true ? 'correct' : r.is_correct === false ? 'wrong' : 'n/a'}
                </li>
              ))}
            </ul>
          </div>
        </div>
      )}
    </div>
  );
}
