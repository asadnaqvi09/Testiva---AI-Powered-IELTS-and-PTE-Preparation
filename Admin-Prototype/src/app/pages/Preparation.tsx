import React, { useState, useRef, useEffect, useCallback } from 'react';
import {
  Plus, Search, Edit2, Trash2, BookOpen, X, Check, Filter,
  FileText, Upload, Paperclip, ChevronDown, ChevronUp, Eye,
  Layers, Tag, AlertCircle, Lock, Loader2
} from 'lucide-react';
import { getPrepLessons, getPrepDetails, createPrepLesson, updatePrepLesson, deletePrepLesson, uploadPrepPdf } from '../services/api';
import { useAuth } from '../context/AuthContext';
import { toast } from 'sonner';

const TEST_TYPES = ['IELTS', 'PTE'];
const SECTIONS: Record<string, string[]> = {
  IELTS: ['Reading', 'Writing', 'Listening', 'Speaking'],
  PTE: ['Speaking', 'Writing', 'Reading', 'Listening'],
};

const TYPE_COLORS: Record<string, { bg: string; color: string; border: string }> = {
  IELTS: { bg: '#EFF6FF', color: '#007BFF', border: '#BFDBFE' },
  TOEFL: { bg: '#F0FDF4', color: '#16A34A', border: '#BBF7D0' },
  PTE:   { bg: '#F5F3FF', color: '#7C3AED', border: '#DDD6FE' },
};

const SECTION_COLORS: Record<string, { bg: string; color: string }> = {
  Reading:    { bg: '#FFF7ED', color: '#C2410C' },
  Writing:    { bg: '#FDF4FF', color: '#9333EA' },
  Listening:  { bg: '#F0F9FF', color: '#0369A1' },
  Speaking:   { bg: '#FFF1F2', color: '#E11D48' },
  Vocabulary: { bg: '#ECFDF5', color: '#059669' },
};

const TypeBadge = ({ type }: { type: string }) => {
  const c = TYPE_COLORS[type] || { bg: '#F3F4F6', color: '#6B7280', border: '#E5E7EB' };
  return (
    <span className="text-xs px-2 py-0.5 rounded-full font-semibold"
      style={{ background: c.bg, color: c.color, border: `1px solid ${c.border}` }}>
      {type}
    </span>
  );
};

const SectionBadge = ({ section }: { section: string }) => {
  const c = SECTION_COLORS[section] || { bg: '#F9FAFB', color: '#6B7280' };
  return (
    <span className="text-xs px-2 py-0.5 rounded-full font-medium"
      style={{ background: c.bg, color: c.color }}>
      {section}
    </span>
  );
};

const formatFileSize = (bytes: number) => {
  if (!bytes || bytes <= 0) return '0 KB';
  return bytes > 1024 * 1024 ? `${(bytes / (1024 * 1024)).toFixed(1)} MB` : `${Math.round(bytes / 1024)} KB`;
};

const generateLocalId = () => `f_${Date.now()}_${Math.random().toString(36).slice(2)}`;

type MediaFile = { id: string; name: string; size: string; url: string; bytes: number; uploading?: boolean };
type Part = { title: string; content: string };

type FormState = {
  title: string; testType: string; section: string; summary: string;
  parts: Part[]; mediaFiles: MediaFile[]; instituteOnly: boolean; status: string;
};

const emptyForm = (): FormState => ({
  title: '', testType: 'IELTS', section: 'Reading', summary: '',
  parts: [{ title: '', content: '' }], mediaFiles: [], instituteOnly: false, status: 'published'
});

function ContentFormBody({
  form, setForm, userRole, fileInputRef, onFileChange, onRemoveFile,
}: {
  form: FormState;
  setForm: React.Dispatch<React.SetStateAction<FormState>>;
  userRole?: string;
  fileInputRef: React.RefObject<HTMLInputElement | null>;
  onFileChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  onRemoveFile: (id: string) => void;
}) {
  return (
    <div className="flex-1 overflow-y-auto p-6 space-y-5">
      <section>
        <div className="flex items-center gap-2 mb-3">
          <div className="w-5 h-5 rounded flex items-center justify-center" style={{ background: '#007BFF' }}>
            <Tag size={11} color="white" />
          </div>
          <span className="text-sm font-semibold" style={{ color: '#1A1A1A' }}>Basic Information</span>
        </div>
        <div className="space-y-3 pl-7">
          <div>
            <label className="block text-xs font-medium text-gray-500 mb-1">Title <span style={{ color: '#DC3545' }}>*</span></label>
            <input
              value={form.title}
              onChange={e => setForm(p => ({ ...p, title: e.target.value }))}
              placeholder="e.g. IELTS Academic Writing: Task 2 Guide"
              className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none focus:ring-2"
              style={{ borderColor: '#E5E7EB', background: '#F9FAFB', '--tw-ring-color': '#007BFF40' } as React.CSSProperties}
            />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-medium text-gray-500 mb-1">Test Type</label>
              <select
                value={form.testType}
                onChange={e => setForm(p => ({ ...p, testType: e.target.value, section: SECTIONS[e.target.value][0] }))}
                className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none"
                style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}>
                {TEST_TYPES.map(t => <option key={t} value={t}>{t}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-xs font-medium text-gray-500 mb-1">Section</label>
              <select
                value={form.section}
                onChange={e => setForm(p => ({ ...p, section: e.target.value }))}
                className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none"
                style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}>
                {SECTIONS[form.testType]?.map(s => <option key={s} value={s}>{s}</option>)}
              </select>
            </div>
          </div>
          <div>
            <label className="block text-xs font-medium text-gray-500 mb-1">Content Summary</label>
            <textarea
              value={form.summary}
              onChange={e => setForm(p => ({ ...p, summary: e.target.value }))}
              placeholder="Brief description of this lesson..."
              rows={2}
              className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none resize-none"
              style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}
            />
          </div>
          <div className="flex items-center gap-4 flex-wrap">
            <div>
              <label className="block text-xs font-medium text-gray-500 mb-1">Status</label>
              <select
                value={form.status}
                onChange={e => setForm(p => ({ ...p, status: e.target.value }))}
                className="px-3 py-2 text-sm rounded-lg border focus:outline-none"
                style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}>
                <option value="published">Published</option>
                <option value="draft">Draft</option>
              </select>
            </div>
            {userRole === 'institute_admin' && (
              <label className="flex items-center gap-2 cursor-pointer mt-4">
                <input
                  type="checkbox"
                  checked={form.instituteOnly}
                  onChange={e => setForm(p => ({ ...p, instituteOnly: e.target.checked }))}
                  className="w-4 h-4 rounded"
                  style={{ accentColor: '#007BFF' }}
                />
                <span className="text-sm text-gray-600 flex items-center gap-1">
                  <Lock size={12} className="text-gray-400" /> Visible only to my students
                </span>
              </label>
            )}
          </div>
        </div>
      </section>

      <div className="border-t" style={{ borderColor: '#F0F0F0' }} />

      <section>
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <div className="w-5 h-5 rounded flex items-center justify-center" style={{ background: '#8B5CF6' }}>
              <Layers size={11} color="white" />
            </div>
            <span className="text-sm font-semibold" style={{ color: '#1A1A1A' }}>Content Parts</span>
            <span className="text-xs px-1.5 py-0.5 rounded-full" style={{ background: '#8B5CF618', color: '#8B5CF6' }}>{form.parts.length}</span>
          </div>
          <button
            onClick={() => setForm(p => ({ ...p, parts: [...p.parts, { title: '', content: '' }] }))}
            className="text-xs flex items-center gap-1 px-2.5 py-1 rounded-lg border font-medium"
            style={{ color: '#007BFF', borderColor: '#007BFF30', background: '#007BFF08' }}>
            <Plus size={12} /> Add Part
          </button>
        </div>
        <div className="space-y-3 pl-7">
          {form.parts.map((part, i) => (
            <div key={i} className="border rounded-xl overflow-hidden" style={{ borderColor: '#E5E7EB' }}>
              <div className="flex items-center gap-2 px-3 py-2" style={{ background: '#F8FAFF' }}>
                <span className="text-xs font-mono font-semibold px-1.5 py-0.5 rounded" style={{ background: '#007BFF', color: 'white' }}>
                  {i + 1}
                </span>
                <input
                  value={part.title}
                  onChange={e => { const parts = [...form.parts]; parts[i].title = e.target.value; setForm(p => ({ ...p, parts })); }}
                  placeholder={`Part ${i + 1} title (e.g., Vocabulary Tips)`}
                  className="flex-1 px-2 py-1 text-sm rounded border focus:outline-none"
                  style={{ borderColor: '#E5E7EB', background: 'white' }}
                />
                {form.parts.length > 1 && (
                  <button
                    onClick={() => setForm(p => ({ ...p, parts: p.parts.filter((_, j) => j !== i) }))}
                    className="p-1 rounded hover:bg-red-50 text-gray-300 hover:text-red-400 transition-colors">
                    <X size={14} />
                  </button>
                )}
              </div>
              <div className="px-3 pb-3 pt-2">
                <textarea
                  value={part.content}
                  onChange={e => { const parts = [...form.parts]; parts[i].content = e.target.value; setForm(p => ({ ...p, parts })); }}
                  placeholder="Rich text content, vocabulary lists, tips, examples..."
                  rows={3}
                  className="w-full px-2 py-1.5 text-sm rounded-lg border focus:outline-none resize-none"
                  style={{ borderColor: '#E5E7EB', background: '#FAFBFF' }}
                />
              </div>
            </div>
          ))}
        </div>
      </section>

      <div className="border-t" style={{ borderColor: '#F0F0F0' }} />

      <section>
        <div className="flex items-center gap-2 mb-3">
          <div className="w-5 h-5 rounded flex items-center justify-center" style={{ background: '#F59E0B' }}>
            <Paperclip size={11} color="white" />
          </div>
          <span className="text-sm font-semibold" style={{ color: '#1A1A1A' }}>Media</span>
          {form.mediaFiles.length > 0 && (
            <span className="text-xs px-1.5 py-0.5 rounded-full" style={{ background: '#F59E0B18', color: '#F59E0B' }}>
              {form.mediaFiles.length} file{form.mediaFiles.length !== 1 ? 's' : ''}
            </span>
          )}
        </div>
        <div className="pl-7 space-y-3">
          <div
            onClick={() => fileInputRef.current?.click()}
            className="border-2 border-dashed rounded-xl p-5 text-center cursor-pointer transition-colors hover:border-yellow-400 hover:bg-yellow-50"
            style={{ borderColor: '#E5E7EB' }}>
            <div className="w-10 h-10 rounded-full flex items-center justify-center mx-auto mb-2" style={{ background: '#F59E0B15' }}>
              <Upload size={20} style={{ color: '#F59E0B' }} />
            </div>
            <p className="text-sm font-medium text-gray-600">Click to upload PDF files</p>
            <p className="text-xs text-gray-400 mt-0.5">PDF only · Max 10 MB per file</p>
            <input
              ref={fileInputRef}
              type="file"
              accept=".pdf"
              multiple
              className="hidden"
              onChange={onFileChange}
            />
          </div>

          {form.mediaFiles.length > 0 && (
            <div className="space-y-2">
              {form.mediaFiles.map((f) => (
                <div key={f.id} className="flex items-center gap-3 px-3 py-2.5 rounded-lg border" style={{ borderColor: '#E5E7EB', background: '#FAFAFA' }}>
                  <div className="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0" style={{ background: '#DC354515' }}>
                    {f.uploading ? <Loader2 size={16} className="animate-spin" style={{ color: '#DC3545' }} /> : <FileText size={16} style={{ color: '#DC3545' }} />}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-700 truncate">{f.name}</p>
                    <p className="text-xs text-gray-400">{f.uploading ? 'Uploading...' : f.size}</p>
                  </div>
                  <button
                    onClick={() => onRemoveFile(f.id)}
                    className="p-1 rounded hover:bg-red-50 text-gray-300 hover:text-red-400 transition-colors">
                    <X size={14} />
                  </button>
                </div>
              ))}
            </div>
          )}

          {form.mediaFiles.length === 0 && (
            <div className="flex items-center gap-2 text-xs text-gray-400 px-1">
              <AlertCircle size={12} />
              <span>No PDF files attached yet. Upload study materials, worksheets, or reference guides.</span>
            </div>
          )}
        </div>
      </section>
    </div>
  );
}

export function Preparation() {
  const { user } = useAuth();
  const [prepList, setPrepList] = useState<any[]>([]);
  const [search, setSearch] = useState('');
  const [filterType, setFilterType] = useState('');
  const [filterSection, setFilterSection] = useState('');
  const [showCreate, setShowCreate] = useState(false);
  const [showDelete, setShowDelete] = useState<string | null>(null);
  const [showEdit, setShowEdit] = useState<string | null>(null);
  const [expandedCard, setExpandedCard] = useState<string | null>(null);
  const [pageLoading, setPageLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);

  const [form, setForm] = useState<FormState>(emptyForm());
  const [editForm, setEditForm] = useState<FormState>(emptyForm());

  const createFileRef = useRef<HTMLInputElement | null>(null);
  const editFileRef = useRef<HTMLInputElement | null>(null);

  const allSections = [...new Set(Object.values(SECTIONS).flat())];

  const loadLessons = useCallback(async () => {
    try {
      setPageLoading(true);
      const res = await getPrepLessons({
        test_type: filterType || undefined,
        section: filterSection || undefined,
        search: search || undefined,
      });
      if (res.success) setPrepList(res.data || []);
    } catch (err: any) {
      toast.error('Failed to load lessons: ' + (err.message || 'Unknown error'));
    } finally { setPageLoading(false); }
  }, [filterType, filterSection, search]);

  useEffect(() => { loadLessons(); }, [loadLessons]);

  const filtered = prepList;

  const handleFileChange = async (
    e: React.ChangeEvent<HTMLInputElement>,
    setter: React.Dispatch<React.SetStateAction<FormState>>
  ) => {
    const files = Array.from(e.target.files || []);
    e.target.value = '';
    if (files.length === 0) return;
    const entries = files.map(file => ({ file, id: generateLocalId() }));
    setter(p => ({
      ...p,
      mediaFiles: [
        ...p.mediaFiles,
        ...entries.map(({ file, id }) => ({
          id,
          name: file.name,
          size: formatFileSize(file.size),
          url: '',
          bytes: file.size,
          uploading: true,
        })),
      ],
    }));

    for (const { file, id } of entries) {
      try {
        const res = await uploadPrepPdf(file);
        if (!res.success || !res.data?.file_url) throw new Error('Upload failed');
        setter(p => ({
          ...p,
          mediaFiles: p.mediaFiles.map(m =>
            m.id === id
              ? { ...m, url: res.data.file_url, name: res.data.file_name || m.name, bytes: res.data.file_size || m.bytes, uploading: false }
              : m
          ),
        }));
      } catch (err: any) {
        toast.error(`Failed to upload ${file.name}: ${err.message || 'Unknown error'}`);
        setter(p => ({ ...p, mediaFiles: p.mediaFiles.filter(m => m.id !== id) }));
      }
    }
  };

  const handleCreate = async () => {
    if (!form.title.trim()) { toast.error('Title is required.'); return; }
    if (form.parts.length === 0 || !form.parts[0].title) { toast.error('At least one content part required.'); return; }
    if (form.mediaFiles.some(f => f.uploading)) { toast.error('Please wait for file uploads to finish.'); return; }
    if (form.mediaFiles.some(f => !f.url)) { toast.error('One or more files failed to upload. Remove them and try again.'); return; }
    setActionLoading(true);
    try {
      const payload = {
        title: form.title,
        test_type: form.testType,
        section: form.section,
        summary: form.summary || undefined,
        status: form.status,
        parts: form.parts.map((p, i) => ({ part_title: p.title, part_content: p.content || 'Content pending...', order_index: i + 1 })),
        media: form.mediaFiles.map(f => ({ file_url: f.url, file_name: f.name, file_size: f.bytes || 0 })),
      };
      const res = await createPrepLesson(payload);
      if (res.success) {
        toast.success('Lesson created! ID: ' + res.data.id);
        setShowCreate(false);
        setForm(emptyForm());
        loadLessons();
      }
    } catch (err: any) {
      toast.error(err.data?.message || err.message || 'Create failed');
    } finally { setActionLoading(false); }
  };

  const handleOpenEdit = async (id: string) => {
    try {
      const res = await getPrepDetails(id);
      if (res.success && res.data) {
        const item = res.data;
        setEditForm({
          title: item.title, testType: item.test_type, section: item.section,
          summary: item.summary || '',
          parts: item.parts?.length ? item.parts.map((p: any) => ({ title: p.part_title, content: p.part_content })) : [{ title: '', content: '' }],
          mediaFiles: item.media?.map((m: any) => ({
            id: m.id || generateLocalId(),
            name: m.file_name,
            size: formatFileSize(m.file_size || 0),
            url: m.file_url,
            bytes: m.file_size || 0,
          })) || [],
          instituteOnly: false,
          status: item.status,
        });
        setShowEdit(id);
      }
    } catch (err: any) { toast.error('Failed to load lesson details'); }
  };

  const handleSaveEdit = async () => {
    if (!editForm.title.trim()) { toast.error('Title is required.'); return; }
    if (!showEdit) return;
    if (editForm.mediaFiles.some(f => f.uploading)) { toast.error('Please wait for file uploads to finish.'); return; }
    if (editForm.mediaFiles.some(f => !f.url)) { toast.error('One or more files failed to upload. Remove them and try again.'); return; }
    setActionLoading(true);
    try {
      const payload = {
        title: editForm.title,
        test_type: editForm.testType,
        section: editForm.section,
        summary: editForm.summary || undefined,
        status: editForm.status,
        parts: editForm.parts.map((p, i) => ({ part_title: p.title, part_content: p.content || 'Content pending...', order_index: i + 1 })),
        media: editForm.mediaFiles.map(f => ({ file_url: f.url, file_name: f.name, file_size: f.bytes || 0 })),
      };
      await updatePrepLesson(showEdit, payload);
      toast.success('Lesson updated!');
      setShowEdit(null);
      loadLessons();
    } catch (err: any) {
      toast.error(err.data?.message || err.message || 'Update failed');
    } finally { setActionLoading(false); }
  };

  const handleDelete = async (id: string) => {
    setActionLoading(true);
    try {
      await deletePrepLesson(id);
      toast.success('Lesson deleted.');
      setShowDelete(null);
      loadLessons();
    } catch (err: any) {
      toast.error(err.data?.message || err.message || 'Delete failed');
    } finally { setActionLoading(false); }
  };

  const publishedCount = prepList.filter(p => p.status === 'published').length;
  const draftCount = prepList.filter(p => p.status === 'draft').length;
  const totalMedia = prepList.reduce((acc, p) => acc + (p.mediaFiles?.length || 0), 0);

  return (
    <div className="space-y-5 max-w-7xl mx-auto">

      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 style={{ color: '#1A1A1A' }}>Preparation Content</h1>
          <p className="text-sm text-gray-400 mt-0.5">
            Manage lessons, guides, and study materials for IELTS & PTE · GET /api/v1/content/preparations
          </p>
        </div>
        <button
          onClick={() => { setForm(emptyForm()); setShowCreate(true); }}
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-white text-sm font-medium hover:opacity-90 shadow-sm transition-all"
          style={{ background: 'linear-gradient(135deg, #007BFF, #0056B3)' }}>
          <Plus size={16} /> Add Content
        </button>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        {[
          { label: 'Total Lessons', value: prepList.length, color: '#007BFF', bg: '#EFF6FF' },
          { label: 'Published', value: publishedCount, color: '#16A34A', bg: '#F0FDF4' },
          { label: 'Drafts', value: draftCount, color: '#F59E0B', bg: '#FFFBEB' },
          { label: 'PDF Files', value: totalMedia, color: '#8B5CF6', bg: '#F5F3FF' },
        ].map(s => (
          <div key={s.label} className="bg-white rounded-xl border p-3 shadow-sm flex items-center gap-3" style={{ borderColor: '#E5E7EB' }}>
            <div className="w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0" style={{ background: s.bg }}>
              <span className="text-base font-bold" style={{ color: s.color }}>{s.value}</span>
            </div>
            <span className="text-xs text-gray-500 font-medium">{s.label}</span>
          </div>
        ))}
      </div>

      <div className="bg-white rounded-xl border p-4 shadow-sm flex flex-wrap gap-3 items-center" style={{ borderColor: '#E5E7EB' }}>
        <div className="relative flex-1 min-w-48">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Search by title or description..."
            className="w-full pl-9 pr-3 py-2 text-sm rounded-lg border focus:outline-none"
            style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}
          />
        </div>
        <div className="flex items-center gap-2 flex-wrap">
          <Filter size={14} className="text-gray-400" />
          <select value={filterType} onChange={e => setFilterType(e.target.value)}
            className="text-sm px-3 py-2 rounded-lg border focus:outline-none"
            style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}>
            <option value="">All Types</option>
            {TEST_TYPES.map(t => <option key={t} value={t}>{t}</option>)}
          </select>
          <select value={filterSection} onChange={e => setFilterSection(e.target.value)}
            className="text-sm px-3 py-2 rounded-lg border focus:outline-none"
            style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}>
            <option value="">All Sections</option>
            {allSections.map(s => <option key={s} value={s}>{s}</option>)}
          </select>
          {(filterType || filterSection || search) && (
            <button onClick={() => { setFilterType(''); setFilterSection(''); setSearch(''); }}
              className="text-xs px-2 py-1 rounded-lg flex items-center gap-1"
              style={{ color: '#DC3545', background: '#DC354510' }}>
              <X size={11} /> Clear
            </button>
          )}
        </div>
        <span className="text-xs text-gray-400 ml-auto">{filtered.length} of {prepList.length} lessons</span>
      </div>

      {pageLoading ? (
        <div className="flex items-center justify-center py-20"><Loader2 className="animate-spin text-blue-500" size={32} /></div>
      ) : (
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
        {filtered.map(prep => {
          const isExpanded = expandedCard === prep.id;
          const typeColor = TYPE_COLORS[prep.test_type || prep.testType] || { bg: '#F3F4F6', color: '#6B7280', border: '#E5E7EB' };
          return (
            <div key={prep.id}
              className="bg-white rounded-2xl border shadow-sm hover:shadow-md transition-all flex flex-col group"
              style={{ borderColor: '#E5E7EB' }}>
              <div className="h-1 rounded-t-2xl" style={{ background: typeColor.color }} />

              <div className="p-5 flex-1 space-y-3">
                <div className="flex items-center gap-1.5 flex-wrap">
                  <TypeBadge type={prep.test_type || prep.testType} />
                  <SectionBadge section={prep.section} />
                  {prep.instituteOnly && (
                    <span className="text-xs px-2 py-0.5 rounded-full font-medium flex items-center gap-1"
                      style={{ background: '#FFF1F2', color: '#E11D48' }}>
                      <Lock size={9} /> Institute Only
                    </span>
                  )}
                  <span className="ml-auto text-xs px-2 py-0.5 rounded-full font-medium"
                    style={prep.status === 'published'
                      ? { background: '#F0FDF4', color: '#16A34A' }
                      : { background: '#FFFBEB', color: '#D97706' }}>
                    {prep.status}
                  </span>
                </div>

                <div>
                  <h3 className="font-semibold text-sm leading-snug mb-1" style={{ color: '#1A1A1A' }}>{prep.title}</h3>
                  <p className="text-xs text-gray-400">{prep.id?.slice(0,8)} · {prep.created_at ? new Date(prep.created_at).toLocaleDateString() : prep.date}</p>
                </div>

                <p className="text-xs text-gray-500 line-clamp-2">{prep.summary}</p>

                {isExpanded && prep.partsDetail?.length > 0 && (
                  <div className="space-y-2 pt-1">
                    {prep.partsDetail.map((part, i) => (
                      <div key={i} className="rounded-lg p-2.5" style={{ background: '#F8FAFF', border: '1px solid #E5EDFF' }}>
                        <p className="text-xs font-semibold text-gray-700 mb-1">
                          <span className="inline-block w-4 h-4 rounded text-center mr-1 text-white text-[10px]"
                            style={{ background: '#007BFF', lineHeight: '16px' }}>{i + 1}</span>
                          {part.title || `Part ${i + 1}`}
                        </p>
                        <p className="text-xs text-gray-500 line-clamp-2">{part.content}</p>
                      </div>
                    ))}
                    {(prep.mediaFiles?.length ?? 0) > 0 && (
                      <div className="pt-1">
                        <p className="text-xs font-semibold text-gray-500 mb-1.5 flex items-center gap-1">
                          <Paperclip size={10} /> Attached PDFs
                        </p>
                        {prep.mediaFiles.map((f, i) => (
                          <div key={i} className="flex items-center gap-2 py-1.5 px-2 rounded-lg" style={{ background: '#FFF8F0' }}>
                            <FileText size={12} style={{ color: '#DC3545' }} />
                            <span className="text-xs text-gray-600 flex-1 truncate">{f.name}</span>
                            <span className="text-xs text-gray-400">{f.size}</span>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                )}
              </div>

              <div className="px-5 py-3 border-t flex items-center justify-between" style={{ borderColor: '#F5F7FA' }}>
                <div className="flex items-center gap-3 text-xs text-gray-400">
                  <span className="flex items-center gap-1">
                    <Layers size={11} /> {prep.parts_count ?? prep.parts ?? 0} parts
                  </span>
                  {(prep.mediaFiles?.length ?? 0) > 0 && (
                    <span className="flex items-center gap-1">
                      <Paperclip size={11} /> {prep.mediaFiles.length} PDF{prep.mediaFiles.length !== 1 ? 's' : ''}
                    </span>
                  )}
                </div>
                <div className="flex items-center gap-1">
                  <button
                    onClick={() => setExpandedCard(isExpanded ? null : prep.id)}
                    className="p-1.5 rounded-lg hover:bg-blue-50 text-gray-400 hover:text-blue-500 transition-colors"
                    title={isExpanded ? 'Collapse' : 'Preview'}>
                    {isExpanded ? <ChevronUp size={14} /> : <Eye size={14} />}
                  </button>
                  <button
                    onClick={() => handleOpenEdit(prep.id)}
                    className="p-1.5 rounded-lg hover:bg-yellow-50 text-gray-400 hover:text-yellow-500 transition-colors"
                    title="Edit">
                    <Edit2 size={14} />
                  </button>
                  <button
                    onClick={() => setShowDelete(prep.id)}
                    className="p-1.5 rounded-lg hover:bg-red-50 text-gray-400 hover:text-red-500 transition-colors"
                    title="Delete">
                    <Trash2 size={14} />
                  </button>
                </div>
              </div>
            </div>
          );
        })}

        {filtered.length === 0 && (
          <div className="col-span-3 text-center py-20 text-gray-400">
            <div className="w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4" style={{ background: '#F3F4F6' }}>
              <BookOpen size={30} className="opacity-40" />
            </div>
            <p className="font-medium">No preparation content found</p>
            <p className="text-sm mt-1">Try adjusting your filters or create new content</p>
          </div>
        )}
      </div>
      )}

      {showCreate && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[92vh] flex flex-col">
            <div className="flex items-center justify-between px-6 py-4 border-b" style={{ borderColor: '#E5E7EB' }}>
              <div>
                <h3 className="font-semibold" style={{ color: '#1A1A1A' }}>Create Preparation Content</h3>
                <p className="text-xs text-gray-400 mt-0.5">POST /preparation/create</p>
              </div>
              <button onClick={() => setShowCreate(false)} className="p-1.5 rounded-lg hover:bg-gray-100 text-gray-400 transition-colors">
                <X size={18} />
              </button>
            </div>

            <ContentFormBody
              form={form}
              setForm={setForm}
              userRole={user?.role}
              fileInputRef={createFileRef}
              onFileChange={e => handleFileChange(e, setForm)}
              onRemoveFile={id => setForm(p => ({ ...p, mediaFiles: p.mediaFiles.filter(m => m.id !== id) }))}
            />

            <div className="px-6 py-4 border-t flex gap-3" style={{ borderColor: '#E5E7EB' }}>
              <button
                onClick={() => setShowCreate(false)}
                className="flex-1 py-2.5 rounded-xl border text-sm font-medium transition-colors hover:bg-gray-50"
                style={{ borderColor: '#E5E7EB', color: '#6B7280' }}>
                Cancel
              </button>
              <button
                onClick={handleCreate}
                disabled={actionLoading || form.mediaFiles.some(f => f.uploading)}
                className="flex-1 py-2.5 rounded-xl text-white text-sm font-semibold flex items-center justify-center gap-2 hover:opacity-90 transition-all shadow-sm disabled:opacity-60"
                style={{ background: 'linear-gradient(135deg, #007BFF, #0056B3)' }}>
                {actionLoading ? <Loader2 size={15} className="animate-spin" /> : <Check size={15} />} Create Content
              </button>
            </div>
          </div>
        </div>
      )}

      {showEdit && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[92vh] flex flex-col">
            <div className="flex items-center justify-between px-6 py-4 border-b" style={{ borderColor: '#E5E7EB' }}>
              <div>
                <div className="flex items-center gap-2">
                  <div className="w-6 h-6 rounded-lg flex items-center justify-center" style={{ background: '#F59E0B' }}>
                    <Edit2 size={12} color="white" />
                  </div>
                  <h3 className="font-semibold" style={{ color: '#1A1A1A' }}>Edit Preparation Content</h3>
                </div>
                <p className="text-xs text-gray-400 mt-0.5">PATCH /preparation/{showEdit}</p>
              </div>
              <button onClick={() => setShowEdit(null)} className="p-1.5 rounded-lg hover:bg-gray-100 text-gray-400 transition-colors">
                <X size={18} />
              </button>
            </div>

            <ContentFormBody
              form={editForm}
              setForm={setEditForm}
              userRole={user?.role}
              fileInputRef={editFileRef}
              onFileChange={e => handleFileChange(e, setEditForm)}
              onRemoveFile={id => setEditForm(p => ({ ...p, mediaFiles: p.mediaFiles.filter(m => m.id !== id) }))}
            />

            <div className="px-6 py-4 border-t flex gap-3" style={{ borderColor: '#E5E7EB' }}>
              <button
                onClick={() => setShowEdit(null)}
                className="flex-1 py-2.5 rounded-xl border text-sm font-medium transition-colors hover:bg-gray-50"
                style={{ borderColor: '#E5E7EB', color: '#6B7280' }}>
                Cancel
              </button>
              <button
                onClick={handleSaveEdit}
                disabled={actionLoading || editForm.mediaFiles.some(f => f.uploading)}
                className="flex-1 py-2.5 rounded-xl text-white text-sm font-semibold flex items-center justify-center gap-2 hover:opacity-90 transition-all shadow-sm disabled:opacity-60"
                style={{ background: 'linear-gradient(135deg, #28A745, #1e7e34)' }}>
                {actionLoading ? <Loader2 size={15} className="animate-spin" /> : <Check size={15} />} Save Changes
              </button>
            </div>
          </div>
        </div>
      )}

      {showDelete && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-2xl p-6 w-full max-w-sm text-center">
            <div className="w-14 h-14 rounded-full flex items-center justify-center mx-auto mb-4" style={{ background: '#DC354515' }}>
              <Trash2 size={24} style={{ color: '#DC3545' }} />
            </div>
            <h3 className="font-semibold mb-2" style={{ color: '#1A1A1A' }}>Delete Content?</h3>
            <p className="text-sm text-gray-500 mb-6">
              This preparation content, all its parts, and attached media files will be permanently removed.
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => setShowDelete(null)}
                className="flex-1 py-2.5 rounded-xl border text-sm font-medium"
                style={{ borderColor: '#E5E7EB', color: '#6B7280' }}>
                Cancel
              </button>
              <button
                onClick={() => handleDelete(showDelete!)}
                className="flex-1 py-2.5 rounded-xl text-white text-sm font-semibold"
                style={{ background: '#DC3545' }}>
                Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}