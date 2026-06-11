import React, { useState, useEffect, useCallback } from 'react';
import { Search, Trash2, Flag, MessageSquare, Heart, X, AlertTriangle, Loader2, ChevronLeft, ChevronRight } from 'lucide-react';
import { adminGetPosts, adminFlagPost, adminUnflagPost, adminDeletePost } from '../services/api';
import { toast } from 'sonner';

const TOPIC_TAGS = ['All', 'IELTS', 'PTE', 'General'];;

export function Community() {
  const [posts, setPosts] = useState<any[]>([]);
  const [stats, setStats] = useState<any>(null);
  const [meta, setMeta] = useState<any>({ page: 1, totalPages: 1, total: 0 });
  const [search, setSearch] = useState('');
  const [filterFlag, setFilterFlag] = useState('');
  const [filterTag, setFilterTag] = useState('All');
  const [page, setPage] = useState(1);
  const [selected, setSelected] = useState<string[]>([]);
  const [showDelete, setShowDelete] = useState<string | null>(null);
  const [showFlag, setShowFlag] = useState<string | null>(null);
  const [flagReason, setFlagReason] = useState('');
  const [deleteReason, setDeleteReason] = useState('');
  const [showBulkDelete, setShowBulkDelete] = useState(false);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);

  const loadPosts = useCallback(async () => {
    try {
      setLoading(true);
      const res = await adminGetPosts({
        page,
        topic_tag: filterTag !== 'All' ? filterTag : undefined,
        filter: filterFlag || undefined,
        search: search || undefined,
      });
      if (res.success) {
        setPosts(res.data || []);
        setStats(res.stats || null);
        setMeta(res.meta || { page: 1, totalPages: 1, total: 0 });
      }
    } catch (err: any) {
      toast.error('Failed to load posts: ' + (err.message || 'Unknown error'));
    } finally { setLoading(false); }
  }, [page, filterTag, filterFlag, search]);

  useEffect(() => { loadPosts(); }, [loadPosts]);

  const handleFlag = async (id: string) => {
    setActionLoading(true);
    try {
      const post = posts.find(p => p.id === id);
      if (post?.is_flagged) {
        await adminUnflagPost(id);
        toast.success('Post unflagged.');
      } else {
        setShowFlag(id);
        setActionLoading(false);
        return;
      }
      loadPosts();
    } catch (err: any) { toast.error(err.data?.message || err.message); }
    finally { setActionLoading(false); }
  };

  const submitFlag = async () => {
    if (!showFlag) return;
    setActionLoading(true);
    try {
      await adminFlagPost(showFlag, flagReason);
      toast.success('Post flagged.');
      setShowFlag(null);
      setFlagReason('');
      loadPosts();
    } catch (err: any) { toast.error(err.data?.message || err.message); }
    finally { setActionLoading(false); }
  };

  const handleDelete = async (id: string) => {
    setActionLoading(true);
    try {
      await adminDeletePost(id, deleteReason);
      toast.success('Post deleted.');
      setShowDelete(null);
      setDeleteReason('');
      setSelected(prev => prev.filter(s => s !== id));
      loadPosts();
    } catch (err: any) { toast.error(err.data?.message || err.message); }
    finally { setActionLoading(false); }
  };

  const handleBulkDelete = async () => {
    setActionLoading(true);
    try {
      for (const id of selected) { await adminDeletePost(id); }
      toast.success(`${selected.length} posts deleted.`);
      setSelected([]);
      setShowBulkDelete(false);
      loadPosts();
    } catch (err: any) { toast.error(err.message); }
    finally { setActionLoading(false); }
  };

  const toggleSelect = (id: string) => {
    setSelected(prev => prev.includes(id) ? prev.filter(s => s !== id) : [...prev, id]);
  };
  const selectAll = () => {
    if (selected.length === posts.length) setSelected([]);
    else setSelected(posts.map(p => p.id));
  };

  return (
    <div className="space-y-5 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 style={{ color: '#1A1A1A' }}>Community Moderation</h1>
          <p className="text-sm text-gray-500 mt-0.5">
            {loading ? 'Loading...' : `${meta.total} posts`}
            {stats && ` · ${stats.flagged_posts || 0} flagged`}
            {' · GET /api/v1/community/admin/posts'}
          </p>
        </div>
        <div className="flex items-center gap-2">
          {selected.length > 0 && (
            <button onClick={() => setShowBulkDelete(true)} className="flex items-center gap-2 px-4 py-2 rounded-lg text-white text-sm font-medium" style={{ background: '#DC3545' }}>
              <Trash2 size={15} /> Delete Selected ({selected.length})
            </button>
          )}
        </div>
      </div>

      {/* Stats Banner */}
      {stats && (
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          {[
            { label: 'Total Posts', value: stats.total_posts ?? meta.total, color: '#007BFF' },
            { label: 'Clean Posts', value: stats.clean_posts ?? 0, color: '#28A745' }, // UPDATED: Displays Clean posts count
            { label: 'Flagged', value: stats.flagged_posts ?? 0, color: '#DC3545' },
            { label: 'Today Posts', value: stats.today_posts ?? 0, color: '#8B5CF6' }, // RETAINED: Displays Today's posts count
          ].map(s => (
            <div key={s.label} className="bg-white rounded-xl border p-3 shadow-sm flex items-center gap-3" style={{ borderColor: '#E5E7EB' }}>
              <span className="text-lg font-bold" style={{ color: s.color }}>{s.value}</span>
              <span className="text-xs text-gray-500">{s.label}</span>
            </div>
          ))}
        </div>
      )}

      {/* Filters */}
      <div className="bg-white rounded-xl border p-4 shadow-sm flex flex-wrap gap-3 items-center" style={{ borderColor: '#E5E7EB' }}>
        <div className="relative flex-1 min-w-48">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} placeholder="Search By User..."
            className="w-full pl-9 pr-3 py-2 text-sm rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }} />
        </div>
        <select value={filterTag} onChange={e => { setFilterTag(e.target.value); setPage(1); }} className="text-sm px-3 py-2 rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}>
          {TOPIC_TAGS.map(t => <option key={t} value={t}>{t}</option>)}
        </select>
        <select value={filterFlag} onChange={e => { setFilterFlag(e.target.value); setPage(1); }} className="text-sm px-3 py-2 rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}>
          <option value="">All Posts</option>
          <option value="flagged">Flagged Only</option>
          <option value="clean">Clean Only</option>
        </select>
      </div>

      {/* Table */}
      {loading ? (
        <div className="flex items-center justify-center py-20"><Loader2 className="animate-spin text-blue-500" size={32} /></div>
      ) : (
        <div className="bg-white rounded-xl border shadow-sm overflow-hidden" style={{ borderColor: '#E5E7EB' }}>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr style={{ background: '#F9FAFB', borderBottom: '1px solid #E5E7EB' }}>
                  <th className="px-4 py-3 w-10">
                    <input type="checkbox" checked={selected.length > 0 && selected.length === posts.length} onChange={selectAll}
                      className="rounded" style={{ accentColor: '#007BFF' }} />
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">User</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Title</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Content</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Tag</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Engagement</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Date</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Status</th>
                  <th className="px-4 py-3 text-right text-xs font-semibold text-gray-500 uppercase">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y" style={{ borderColor: '#F5F7FA' }}>
                {posts.length === 0 ? (
                  <tr><td colSpan={9} className="text-center py-10 text-gray-400 text-sm">No posts found.</td></tr>
                ) : posts.map(post => (
                  <tr key={post.id} className={`hover:bg-gray-50 transition-colors ${post.is_flagged ? 'bg-red-50/30' : ''}`}>
                    <td className="px-4 py-3">
                      <input type="checkbox" checked={selected.includes(post.id)} onChange={() => toggleSelect(post.id)}
                        className="rounded" style={{ accentColor: '#007BFF' }} />
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        {post.avatar_url ? (
                          <img src={post.avatar_url} className="w-7 h-7 rounded-full object-cover" alt="" />
                        ) : (
                          <div className="w-7 h-7 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0" style={{ background: '#007BFF' }}>
                            {(post.full_name || post.user || '?').charAt(0).toUpperCase()}
                          </div>
                        )}
                        <p className="text-xs text-gray-600 truncate max-w-24">{post.full_name || post.user || 'Unknown'}</p>
                      </div>
                    </td>
                    <td className="px-4 py-3 max-w-32"><p className="text-xs text-gray-700 font-medium truncate">{post.title || '-'}</p></td>
                    <td className="px-4 py-3 max-w-xs"><p className="text-sm text-gray-700 line-clamp-2">{post.content}</p></td>
                    <td className="px-4 py-3">
                      <span className="text-xs px-2 py-0.5 rounded-full font-medium" style={{ background: '#007BFF18', color: '#007BFF' }}>{post.topic_tag || '-'}</span>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3 text-xs text-gray-400">
                        <span className="flex items-center gap-1"><Heart size={12} style={{ color: '#DC3545' }} /> {post.like_count ?? post.likes ?? 0}</span>
                        <span className="flex items-center gap-1"><MessageSquare size={12} style={{ color: '#007BFF' }} /> {post.comment_count ?? post.replies ?? 0}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-400">{post.created_at ? new Date(post.created_at).toLocaleDateString() : post.date}</td>
                    <td className="px-4 py-3">
                      {post.is_flagged ? (
                        <span className="flex items-center gap-1 text-xs px-2 py-0.5 rounded-full font-medium" style={{ background: '#DC354515', color: '#DC3545' }}>
                          <AlertTriangle size={10} /> Flagged
                        </span>
                      ) : (
                        <span className="text-xs px-2 py-0.5 rounded-full font-medium" style={{ background: '#28A74515', color: '#28A745' }}>Clean</span>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center justify-end gap-1">
                        <button onClick={() => handleFlag(post.id)} title={post.is_flagged ? 'Unflag' : 'Flag'} disabled={actionLoading}
                          className={`p-1.5 rounded-lg transition-colors ${post.is_flagged ? 'text-yellow-500 bg-yellow-50' : 'text-gray-400 hover:text-yellow-500 hover:bg-yellow-50'}`}>
                          <Flag size={14} />
                        </button>
                        <button onClick={() => setShowDelete(post.id)} disabled={actionLoading} className="p-1.5 rounded-lg hover:bg-red-50 text-gray-400 hover:text-red-500 transition-colors">
                          <Trash2 size={14} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          {meta.totalPages > 1 && (
            <div className="px-5 py-3 border-t flex items-center justify-between" style={{ borderColor: '#E5E7EB' }}>
              <p className="text-xs text-gray-400">Page {meta.page} of {meta.totalPages} ({meta.total} total)</p>
              <div className="flex gap-2">
                <button disabled={page <= 1} onClick={() => setPage(p => p - 1)} className="text-xs px-3 py-1.5 rounded-lg border disabled:opacity-40" style={{ borderColor: '#E5E7EB' }}><ChevronLeft size={14} /></button>
                <button disabled={page >= meta.totalPages} onClick={() => setPage(p => p + 1)} className="text-xs px-3 py-1.5 rounded-lg border disabled:opacity-40" style={{ borderColor: '#E5E7EB' }}><ChevronRight size={14} /></button>
              </div>
            </div>
          )}
        </div>
      )}

      {/* Flag Reason Modal */}
      {showFlag && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl p-6 w-full max-w-sm">
            <h3 className="font-semibold mb-3" style={{ color: '#1A1A1A' }}>Flag Post</h3>
            <p className="text-sm text-gray-500 mb-3">Provide a reason for flagging (optional). An email will be sent to the author.</p>
            <textarea value={flagReason} onChange={e => setFlagReason(e.target.value)} placeholder="Reason for flagging..." rows={3}
              className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none resize-none mb-4" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }} />
            <div className="flex gap-3">
              <button onClick={() => { setShowFlag(null); setFlagReason(''); }} className="flex-1 py-2 rounded-lg border text-sm" style={{ borderColor: '#E5E7EB', color: '#6B7280' }}>Cancel</button>
              <button onClick={submitFlag} disabled={actionLoading} className="flex-1 py-2 rounded-lg text-white text-sm font-medium" style={{ background: '#F59E0B' }}>
                {actionLoading ? 'Flagging...' : 'Flag Post'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Single Modal */}
      {showDelete && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl p-6 w-full max-w-sm text-center">
            <div className="w-14 h-14 rounded-full flex items-center justify-center mx-auto mb-4" style={{ background: '#DC354515' }}>
              <Trash2 size={24} style={{ color: '#DC3545' }} />
            </div>
            <h3 className="font-semibold mb-2" style={{ color: '#1A1A1A' }}>Delete Post?</h3>
            <p className="text-sm text-gray-500 mb-3">This post will be permanently removed. An email will be sent to the author.</p>
            <textarea value={deleteReason} onChange={e => setDeleteReason(e.target.value)} placeholder="Reason (optional)..." rows={2}
              className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none resize-none mb-4" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }} />
            <div className="flex gap-3">
              <button onClick={() => { setShowDelete(null); setDeleteReason(''); }} className="flex-1 py-2 rounded-lg border text-sm" style={{ borderColor: '#E5E7EB', color: '#6B7280' }}>Cancel</button>
              <button onClick={() => handleDelete(showDelete)} disabled={actionLoading} className="flex-1 py-2 rounded-lg text-white text-sm font-medium" style={{ background: '#DC3545' }}>
                {actionLoading ? 'Deleting...' : 'Delete'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Bulk Delete Modal */}
      {showBulkDelete && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl p-6 w-full max-w-sm text-center">
            <div className="w-14 h-14 rounded-full flex items-center justify-center mx-auto mb-4" style={{ background: '#DC354515' }}>
              <Trash2 size={24} style={{ color: '#DC3545' }} />
            </div>
            <h3 className="font-semibold mb-2" style={{ color: '#1A1A1A' }}>Delete {selected.length} Posts?</h3>
            <p className="text-sm text-gray-500 mb-6">All selected posts will be permanently removed.</p>
            <div className="flex gap-3">
              <button onClick={() => setShowBulkDelete(false)} className="flex-1 py-2 rounded-lg border text-sm" style={{ borderColor: '#E5E7EB', color: '#6B7280' }}>Cancel</button>
              <button onClick={handleBulkDelete} disabled={actionLoading} className="flex-1 py-2 rounded-lg text-white text-sm font-medium" style={{ background: '#DC3545' }}>
                {actionLoading ? 'Deleting...' : 'Delete All'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
