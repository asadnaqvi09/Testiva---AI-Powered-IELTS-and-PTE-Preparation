import React, { useState, useEffect, useCallback } from 'react';
import {
  Search, Edit2, Trash2, Eye, FileText, Clock, X, Wrench,
  ChevronRight, Loader2, RefreshCw, AlertCircle,
} from 'lucide-react';
import { useNavigate } from 'react-router';
import { useMocks } from '../context/MocksContext';
import { getTestById } from '../services/api';
import { apiDetailToBuilderState } from '../services/mockTestMapper';
import { toast } from 'sonner';

const TEST_TYPES = ['IELTS', 'PTE'];

const TypeBadge = ({ type }: { type: string }) => {
  const colors: Record<string, React.CSSProperties> = {
    IELTS: { background: '#007BFF18', color: '#007BFF' },
    PTE:   { background: '#8B5CF618', color: '#8B5CF6' },
  };
  return (
    <span className="text-xs px-2 py-0.5 rounded-full font-medium" style={colors[type] || {}}>
      {type}
    </span>
  );
};

const StatusBadge = ({ status }: { status: string }) => (
  <span className="text-xs px-2 py-0.5 rounded-full font-medium"
    style={status === 'published'
      ? { background: '#28A74515', color: '#28A745' }
      : { background: '#F59E0B15', color: '#F59E0B' }}>
    {status}
  </span>
);

export function Mocks() {
  const navigate = useNavigate();
  const { mockList, loading, error, refreshMocks, deleteMock } = useMocks();

  const [search, setSearch] = useState('');
  const [filterType, setFilterType] = useState('');
  const [showDelete, setShowDelete] = useState<string | null>(null);
  const [showPreview, setShowPreview] = useState<string | null>(null);
  const [previewLoading, setPreviewLoading] = useState(false);
  const [previewDetail, setPreviewDetail] = useState<ReturnType<typeof apiDetailToBuilderState> | null>(null);
  const [deleting, setDeleting] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      refreshMocks({
        search: search.trim() || undefined,
        exam_type: filterType || undefined,
      });
    }, search ? 300 : 0);
    return () => clearTimeout(timer);
  }, [search, filterType, refreshMocks]);

  const previewMock = mockList.find(m => m.id === showPreview);

  const openPreview = useCallback(async (id: string) => {
    setShowPreview(id);
    setPreviewDetail(null);
    setPreviewLoading(true);
    try {
      const res = await getTestById(id);
      if (res.data) setPreviewDetail(apiDetailToBuilderState(res.data));
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to load preview');
      setShowPreview(null);
    } finally {
      setPreviewLoading(false);
    }
  }, []);

  const handleDelete = async (id: string) => {
    setDeleting(true);
    try {
      await deleteMock(id);
      setShowDelete(null);
      toast.success('Mock test deleted.');
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Delete failed');
    } finally {
      setDeleting(false);
    }
  };

  const publishedCount = mockList.filter(m => m.status === 'published').length;
  const draftCount = mockList.filter(m => m.status === 'draft').length;

  return (
    <div className="space-y-5 max-w-7xl mx-auto">

      <div className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <h1 style={{ color: '#1A1A1A' }}>Mock Tests</h1>
          <p className="text-sm text-gray-500 mt-0.5">
            {loading ? 'Loading…' : `${mockList.length} tests · ${publishedCount} published · ${draftCount} drafts`}
          </p>
        </div>

        <button
          onClick={() => navigate('/test-builder')}
          className="flex items-center gap-2.5 px-5 py-2.5 rounded-xl text-white text-sm font-semibold shadow-sm hover:opacity-90 transition-all"
          style={{ background: 'linear-gradient(135deg, #007BFF 0%, #0056CC 100%)' }}
        >
          <Wrench size={16} />
          Build New Test
          <ChevronRight size={14} className="opacity-70" />
        </button>
      </div>

      {error && (
        <div className="flex items-center gap-3 p-4 rounded-xl border border-red-200 bg-red-50 text-sm text-red-700">
          <AlertCircle size={18} className="shrink-0" />
          <span className="flex-1">{error}</span>
          <button
            onClick={() => refreshMocks({ search: search.trim() || undefined, exam_type: filterType || undefined })}
            className="flex items-center gap-1 text-xs font-medium px-3 py-1.5 rounded-lg bg-white border border-red-200 hover:bg-red-50"
          >
            <RefreshCw size={13} /> Retry
          </button>
        </div>
      )}

      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        {[
          { label: 'Total Tests', value: mockList.length, color: '#007BFF' },
          { label: 'Published',   value: publishedCount,  color: '#28A745' },
          { label: 'Drafts',      value: draftCount,      color: '#F59E0B' },
          { label: 'IELTS',       value: mockList.filter(m => m.testType === 'IELTS').length, color: '#8B5CF6' },
        ].map(s => (
          <div key={s.label} className="bg-white rounded-xl border p-3.5 shadow-sm flex items-center gap-3" style={{ borderColor: '#E5E7EB' }}>
            <div className="w-2 h-8 rounded-full" style={{ background: s.color }} />
            <div>
              <p className="text-xs text-gray-400">{s.label}</p>
              <p className="font-bold text-lg leading-none mt-0.5" style={{ color: '#1A1A1A' }}>{s.value}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="bg-white rounded-xl border p-4 shadow-sm flex gap-3 flex-wrap" style={{ borderColor: '#E5E7EB' }}>
        <div className="relative flex-1 min-w-48">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search mock tests..."
            className="w-full pl-9 pr-3 py-2 text-sm rounded-lg border focus:outline-none focus:border-blue-400 transition-colors"
            style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}
          />
        </div>
        <select
          value={filterType}
          onChange={e => setFilterType(e.target.value)}
          className="text-sm px-3 py-2 rounded-lg border focus:outline-none bg-white text-gray-600"
          style={{ borderColor: '#E5E7EB' }}
        >
          <option value="">All Test Types</option>
          {TEST_TYPES.map(t => <option key={t} value={t}>{t}</option>)}
        </select>
        {(search || filterType) && (
          <button
            onClick={() => { setSearch(''); setFilterType(''); }}
            className="px-3 py-2 rounded-lg border text-sm text-gray-500 hover:bg-gray-50 flex items-center gap-1"
            style={{ borderColor: '#E5E7EB' }}
          >
            <X size={13} /> Clear
          </button>
        )}
        <button
          onClick={() => refreshMocks({ search: search.trim() || undefined, exam_type: filterType || undefined })}
          disabled={loading}
          className="px-3 py-2 rounded-lg border text-sm text-gray-600 hover:bg-gray-50 flex items-center gap-1 disabled:opacity-50"
          style={{ borderColor: '#E5E7EB' }}
        >
          <RefreshCw size={13} className={loading ? 'animate-spin' : ''} /> Refresh
        </button>
      </div>

      {loading && mockList.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-24 text-gray-400">
          <Loader2 size={36} className="animate-spin text-blue-500 mb-3" />
          <p className="text-sm">Loading mock tests from server…</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {mockList.length === 0 ? (
            <div className="col-span-3 text-center py-20 text-gray-400">
              <div className="w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-4" style={{ background: '#007BFF10' }}>
                <FileText size={28} style={{ color: '#007BFF' }} />
              </div>
              <p className="text-base font-medium text-gray-500 mb-2">No mock tests found</p>
              <p className="text-sm mb-5">Build your first test using the Test Builder</p>
              <button
                onClick={() => navigate('/test-builder')}
                className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-white text-sm font-semibold hover:opacity-90"
                style={{ background: '#007BFF' }}
              >
                <Wrench size={15} /> Open Test Builder
              </button>
            </div>
          ) : (
            mockList.map(mock => (
              <div key={mock.id} className="bg-white rounded-xl border shadow-sm hover:shadow-md transition-all flex flex-col" style={{ borderColor: '#E5E7EB' }}>
                <div className="p-5 flex-1">
                  <div className="flex items-start justify-between gap-2 mb-3">
                    <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: '#007BFF18' }}>
                      <FileText size={18} style={{ color: '#007BFF' }} />
                    </div>
                    <div className="flex gap-1.5 flex-wrap justify-end">
                      <TypeBadge type={mock.testType} />
                      <StatusBadge status={mock.status} />
                    </div>
                  </div>

                  <h3 className="font-semibold mb-1 line-clamp-2" style={{ color: '#1A1A1A', fontSize: '14px' }}>
                    {mock.title}
                  </h3>
                  <p className="text-xs text-gray-400 mb-3">
                    {mock.displayId || mock.id.slice(0, 8)} · {mock.createdDate}
                  </p>

                  <div className="flex flex-wrap gap-1.5 mb-4">
                    {mock.sections.slice(0, 3).map(s => (
                      <span key={s} className="text-xs px-2 py-0.5 rounded-md" style={{ background: '#F5F7FA', color: '#6B7280' }}>
                        {s}
                      </span>
                    ))}
                    {mock.sections.length > 3 && (
                      <span className="text-xs text-gray-400">+{mock.sections.length - 3}</span>
                    )}
                  </div>

                  <div className="flex items-center gap-4 text-xs text-gray-500">
                    <span className="flex items-center gap-1"><FileText size={11} />{mock.questionsCount} Qs</span>
                    <span className="flex items-center gap-1"><Clock size={11} />{mock.duration} min</span>
                    <span className={`font-medium ${mock.difficulty === 'Easy' ? 'text-green-500' : mock.difficulty === 'Hard' ? 'text-red-500' : 'text-yellow-500'}`}>
                      {mock.difficulty}
                    </span>
                  </div>
                </div>

                <div className="px-5 py-3 border-t flex items-center gap-1" style={{ borderColor: '#F5F7FA' }}>
                  <button
                    onClick={() => openPreview(mock.id)}
                    className="flex items-center gap-1.5 text-xs px-2.5 py-1.5 rounded-lg hover:bg-blue-50 transition-colors"
                    style={{ color: '#007BFF' }}
                  >
                    <Eye size={13} /> Preview
                  </button>
                  <button
                    onClick={() => navigate(`/test-builder?edit=${mock.id}`)}
                    className="flex items-center gap-1.5 text-xs px-2.5 py-1.5 rounded-lg hover:bg-amber-50 transition-colors"
                    style={{ color: '#F59E0B' }}
                  >
                    <Edit2 size={13} /> Edit
                  </button>
                  <button
                    onClick={() => setShowDelete(mock.id)}
                    className="flex items-center gap-1.5 text-xs px-2.5 py-1.5 rounded-lg hover:bg-red-50 transition-colors ml-auto"
                    style={{ color: '#DC3545' }}
                  >
                    <Trash2 size={13} /> Delete
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      )}

      {mockList.length > 0 && !loading && (
        <div
          className="rounded-2xl p-5 flex items-center gap-5 cursor-pointer hover:opacity-95 transition-opacity"
          style={{ background: 'linear-gradient(135deg, #007BFF12 0%, #8B5CF612 100%)', border: '1px dashed #007BFF40' }}
          onClick={() => navigate('/test-builder')}
        >
          <div className="w-12 h-12 rounded-2xl flex items-center justify-center flex-shrink-0" style={{ background: '#007BFF18' }}>
            <Wrench size={22} style={{ color: '#007BFF' }} />
          </div>
          <div className="flex-1">
            <p className="font-semibold text-sm" style={{ color: '#007BFF' }}>Create another test with Test Builder</p>
            <p className="text-xs text-gray-500 mt-0.5">
              Build IELTS / PTE tests with dynamic sections, smart question types, and real-time validation.
            </p>
          </div>
          <ChevronRight size={20} style={{ color: '#007BFF' }} className="flex-shrink-0" />
        </div>
      )}

      {showPreview && previewMock && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-2xl max-h-[85vh] flex flex-col">
            <div className="flex items-center justify-between px-6 py-4 border-b" style={{ borderColor: '#E5E7EB' }}>
              <div>
                <h3 className="font-semibold" style={{ color: '#1A1A1A' }}>{previewMock.title}</h3>
                <div className="flex items-center gap-2 mt-1">
                  <TypeBadge type={previewMock.testType} />
                  <StatusBadge status={previewMock.status} />
                </div>
              </div>
              <button onClick={() => { setShowPreview(null); setPreviewDetail(null); }} className="text-gray-400 hover:text-gray-600">
                <X size={18} />
              </button>
            </div>

            <div className="flex-1 overflow-y-auto p-6 space-y-5">
              {previewLoading ? (
                <div className="flex justify-center py-12">
                  <Loader2 size={28} className="animate-spin text-blue-500" />
                </div>
              ) : previewDetail ? (
                <>
                  <div className="grid grid-cols-3 gap-3">
                    {[
                      { label: 'Duration', value: `${previewDetail.duration} min` },
                      { label: 'Questions', value: previewDetail.sections.reduce((n, s) => n + s.questions.length, 0) },
                      { label: 'Difficulty', value: previewDetail.difficulty },
                    ].map(stat => (
                      <div key={stat.label} className="text-center p-3 rounded-xl" style={{ background: '#F5F7FA' }}>
                        <p className="text-xs text-gray-400">{stat.label}</p>
                        <p className="font-semibold mt-0.5 text-sm" style={{ color: '#1A1A1A' }}>{stat.value}</p>
                      </div>
                    ))}
                  </div>
                  <div>
                    <p className="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">Sections</p>
                    <div className="space-y-2">
                      {previewDetail.sections.map((sec, i) => (
                        <div key={sec.id} className="flex items-center justify-between px-3 py-2.5 rounded-lg" style={{ background: '#F9FAFB', border: '1px solid #E5E7EB' }}>
                          <span className="text-sm text-gray-700 font-medium">Section {i + 1} — {sec.moduleType}</span>
                          <span className="text-xs text-gray-400">{sec.questions.length} question{sec.questions.length !== 1 ? 's' : ''}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </>
              ) : null}
            </div>

            <div className="px-6 py-4 border-t flex gap-3" style={{ borderColor: '#E5E7EB' }}>
              <button
                onClick={() => { setShowPreview(null); setPreviewDetail(null); }}
                className="flex-1 py-2 rounded-xl text-sm border font-medium"
                style={{ borderColor: '#E5E7EB', color: '#6B7280' }}
              >
                Close
              </button>
              <button
                onClick={() => { setShowPreview(null); navigate(`/test-builder?edit=${previewMock.id}`); }}
                className="flex-1 py-2 rounded-xl text-sm font-semibold text-white flex items-center justify-center gap-2"
                style={{ background: '#007BFF' }}
              >
                <Edit2 size={14} /> Edit in Builder
              </button>
            </div>
          </div>
        </div>
      )}

      {showDelete && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl p-6 w-full max-w-sm text-center">
            <div className="w-14 h-14 rounded-full flex items-center justify-center mx-auto mb-4" style={{ background: '#DC354515' }}>
              <Trash2 size={24} style={{ color: '#DC3545' }} />
            </div>
            <h3 className="font-semibold mb-2" style={{ color: '#1A1A1A' }}>Delete Mock Test?</h3>
            <p className="text-sm text-gray-500 mb-5">
              <strong>{mockList.find(m => m.id === showDelete)?.title}</strong> and all its questions will be permanently removed.
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => setShowDelete(null)}
                disabled={deleting}
                className="flex-1 py-2 rounded-xl border text-sm"
                style={{ borderColor: '#E5E7EB', color: '#6B7280' }}
              >
                Cancel
              </button>
              <button
                onClick={() => handleDelete(showDelete)}
                disabled={deleting}
                className="flex-1 py-2 rounded-xl text-white text-sm font-semibold flex items-center justify-center gap-2 disabled:opacity-60"
                style={{ background: '#DC3545' }}
              >
                {deleting ? <Loader2 size={14} className="animate-spin" /> : null}
                Delete
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}
