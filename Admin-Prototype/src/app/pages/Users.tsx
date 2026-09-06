import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { Search, Plus, Edit2, Trash2, Eye, ChevronUp, ChevronDown, Filter, X, AlertCircle, RefreshCw, Check, Ban } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { getAllUsersAPI, updateUserSubscriptionAPI, setUserPreferenceAPI } from '../services/api'; 
import { toast } from 'sonner';

type SortKey = 'name' | 'subscription' | 'lastActive' | 'score';
type SortDir = 'asc' | 'desc';

const TEST_TYPES = ['IELTS', 'PTE']; 
const SUBSCRIPTION_TYPES = ['free', 'basic', 'premium'];
const UNLOCK_OPTIONS = [
  { value: '', label: 'Clear (none)' },
  { value: 'IELTS', label: 'IELTS only' },
  { value: 'PTE', label: 'PTE only' },
  { value: 'BOTH', label: 'Both exams' },
];
const PLAN_LABELS: Record<string, string> = { free: 'Free', basic: 'Basic ₨399', premium: 'Premium ₨699' };

export function Users() {
  const { user } = useAuth();
  const isInstAdmin = user?.role === 'institute_admin';
  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [search, setSearch] = useState('');
  const [filterSub, setFilterSub] = useState('');
  const [filterTest, setFilterTest] = useState('');
  const [currentPage, setCurrentPage] = useState<number>(1);
  const [totalPages, setTotalPages] = useState<number>(1);
  const [totalUsers, setTotalUsers] = useState<number>(0);
  const limit = 10; 
  const [sortKey, setSortKey] = useState<SortKey>('name');
  const [sortDir, setSortDir] = useState<SortDir>('asc');
  const [showAdd, setShowAdd] = useState(false);
  const [showDelete, setShowDelete] = useState<string | null>(null);
  const [showEdit, setShowEdit] = useState<string | null>(null);
  const [selectedUser, setSelectedUser] = useState<any | null>(null);
  const [editSubscription, setEditSubscription] = useState<string>('free');
  const [editPreference, setEditPreference] = useState<string>('IELTS');
  const [editUnlockedExam, setEditUnlockedExam] = useState<string>('');
  const [mutationLoading, setMutationLoading] = useState<boolean>(false);

  /* ==========================================================================
     SERVER SIDE READ QUERY REFETCHING MECHANISM
     ========================================================================== */
  const fetchBackendUsers = useCallback(async () => {
    try {
      setLoading(true);
      const response = await getAllUsersAPI({
        page: currentPage,
        limit: limit,
        search: search || undefined,
        subscription: filterSub || undefined,
        preference: filterTest || undefined 
      });

      if (response.success) {
        setUsers(response.data);
        setTotalPages(response.totalPages);
        setTotalUsers(response.totalUsers);
      }
    } catch (err: any) {
      toast.error(err.message || 'Failed to fetch user directory from database');
    } finally {
      setLoading(false);
    }
  }, [currentPage, search, filterSub, filterTest]);

  useEffect(() => {
    fetchBackendUsers();
  }, [fetchBackendUsers]);

  useEffect(() => {
    setCurrentPage(1);
  }, [search, filterSub, filterTest]);

  /* ==========================================================================
     UX PIPELINE FILTER: EXCLUSIVELY SHOW USERS WITH ROLE 'USER'
     ========================================================================== */
  const filteredAndSortedUsers = useMemo(() => {
    // Structural Filter: Filter only actual students/users to display in the management table
    const onlyUsers = users.filter(u => u.role === 'user' || u.role === 'registered');

    // Client side Sorting Layer
    return onlyUsers.sort((a, b) => {
      let av = a[sortKey] || '';
      let bv = b[sortKey] || '';
      
      if (sortKey === 'name') {
        av = a.full_name || '';
        bv = b.full_name || '';
      }

      return sortDir === 'asc' 
        ? String(av).localeCompare(String(bv)) 
        : String(bv).localeCompare(String(av));
    });
  }, [users, sortKey, sortDir]);

  const toggleSort = (key: SortKey) => {
    if (sortKey === key) setSortDir(d => d === 'asc' ? 'desc' : 'asc');
    else { setSortKey(key); setSortDir('asc'); }
  };

  const SortIcon = ({ k }: { k: SortKey }) => (
    <span className="ml-1 inline-flex flex-col opacity-40">
      <ChevronUp size={10} className={sortKey === k && sortDir === 'asc' ? 'opacity-100 text-blue-500' : ''} style={{ marginBottom: -2 }} />
      <ChevronDown size={10} className={sortKey === k && sortDir === 'desc' ? 'opacity-100 text-blue-500' : ''} />
    </span>
  );

  /* ==========================================================================
     API MUTATION EXECUTIONERS (DUAL PIPELINE FIX)
     ========================================================================== */
  const handleOpenEditModal = (userData: any) => {
    setSelectedUser(userData);
    setEditSubscription(userData.subscription || 'free');
    setEditPreference(userData.preference || 'IELTS');
    setEditUnlockedExam(userData.unlocked_exam || '');
    setShowEdit(userData.id);
  };

  const handleUpdateUserSave = async () => {
  if (!selectedUser) return;
  try {
    setMutationLoading(true);
    let unlockedPayload: string | null | undefined = editUnlockedExam || null;
    if (editSubscription === 'free') unlockedPayload = null;
    else if (editSubscription === 'premium') unlockedPayload = 'BOTH';
    const subRes = await updateUserSubscriptionAPI(
      selectedUser.id,
      editSubscription,
      unlockedPayload,
    );
    if (subRes && subRes.success === false) {
      throw new Error(subRes.message || 'Subscription update failed.');
    }
    const prefRes = await setUserPreferenceAPI(editPreference, selectedUser.id);
    if (prefRes && prefRes.success === false) {
      throw new Error(prefRes.message || 'Preference override failed.');
    }
    toast.success('User parameters synchronized successfully!');
    setShowEdit(null);
    fetchBackendUsers();
  } catch (err: any) {
    console.error("Frontend Mutation Error:", err);
    toast.error(err.message || 'Operation transaction failed.');
  } finally {
    setMutationLoading(false);
  }
};

  // Process Requests directly from queue matrix
  const handleApproveRequest = async (reqId: string, targetUserId: string, targetTest: 'IELTS' | 'PTE') => {
    try {
      // FIX: Added targetUserId parameter constraint to structural remote context mapping
      await setUserPreferenceAPI(targetTest, targetUserId);
      toast.success(`Migration request authorized. Portal calibrated to ${targetTest}.`);
      fetchBackendUsers();
    } catch (err: any) {
      toast.error('Could not process bypass approval state.');
    }
  };

  const subBadge = (sub: string) => {
    const styles: Record<string, React.CSSProperties> = {
      free: { background: '#6C757D18', color: '#6C757D' },
      basic: { background: '#007BFF18', color: '#007BFF' },
      premium: { background: '#28A74518', color: '#28A745' },
    };
    return <span className="text-xs px-2 py-0.5 rounded-full font-medium uppercase" style={styles[sub] || styles.free}>{sub}</span>;
  };

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold" style={{ color: '#1A1A1A' }}>{isInstAdmin ? 'Student Management' : 'User Management'}</h1>
          <p className="text-sm text-gray-500 mt-0.5">{filteredAndSortedUsers.length} active students tracked live</p>
        </div>
        <button onClick={() => setShowAdd(true)} className="flex items-center gap-2 px-4 py-2 rounded-lg text-white text-sm font-medium hover:opacity-90 transition-all" style={{ background: '#007BFF' }}>
          <Plus size={16} /> Add {isInstAdmin ? 'Student' : 'User'}
        </button>
      </div>

      {/* Filters Form Block */}
      <div className="bg-white rounded-xl border p-4 shadow-sm flex flex-wrap gap-3 items-center" style={{ borderColor: '#E5E7EB' }}>
        <div className="relative flex-1 min-w-48">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search by student name or unique ID..."
            className="w-full pl-9 pr-3 py-2 text-sm rounded-lg border focus:outline-none focus:border-blue-400"
            style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }} />
        </div>
        <div className="flex items-center gap-2 flex-wrap">
          <Filter size={14} className="text-gray-400" />
          <select value={filterSub} onChange={e => setFilterSub(e.target.value)} className="text-sm px-3 py-2 rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}>
            <option value="">All Plans</option>
            {SUBSCRIPTION_TYPES.map(s => <option key={s} value={s}>{s.toUpperCase()}</option>)}
          </select>
          <select value={filterTest} onChange={e => setFilterTest(e.target.value)} className="text-sm px-3 py-2 rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}>
            <option value="">All Preferences</option>
            {TEST_TYPES.map(t => <option key={t} value={t}>{t}</option>)}
          </select>
        </div>
      </div>

      {/* Data Grid Table View */}
      <div className="bg-white rounded-xl border shadow-sm overflow-hidden" style={{ borderColor: '#E5E7EB' }}>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr style={{ background: '#F9FAFB', borderBottom: '1px solid #E5E7EB' }}>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Sys Custom ID</th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide cursor-pointer select-none" onClick={() => toggleSort('name')}>
                  Student Information <SortIcon k="name" />
                </th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Active Exam Track</th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide cursor-pointer select-none" onClick={() => toggleSort('subscription')}>
                  Access Tier Level <SortIcon k="subscription" />
                </th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Unlocked Exam</th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Role</th>
                <th className="px-4 py-3 text-right text-xs font-semibold text-gray-500 uppercase tracking-wide">Action Controls</th>
              </tr>
            </thead>
            <tbody className="divide-y" style={{ borderColor: '#F5F7FA' }}>
              {loading ? (
                <tr>
                  <td colSpan={7} className="text-center py-12 text-sm text-gray-400">
                    <div className="flex items-center justify-center gap-2">
                      <div className="w-5 h-5 border-2 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
                      Fetching records from server pipeline...
                    </div>
                  </td>
                </tr>
              ) : filteredAndSortedUsers.length === 0 ? (
                <tr><td colSpan={7} className="text-center py-10 text-gray-400 text-sm">No synchronized student records matching criteria.</td></tr>
              ) : filteredAndSortedUsers.map(u => (
                <tr key={u.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-4 py-3 text-xs font-mono text-gray-500 font-semibold">{u.customID || `USR-${u.id.substring(0, 5)}`}</td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0" style={{ background: '#007BFF' }}>
                        {(u.full_name || 'U').charAt(0).toUpperCase()}
                      </div>
                      <div>
                        <p className="text-sm font-medium" style={{ color: '#1A1A1A' }}>{u.full_name}</p>
                        <p className="text-xs text-gray-400">{u.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-sm text-gray-600 font-medium">
                    {u.preference ? <span className="bg-blue-50 text-blue-700 px-2.5 py-0.5 rounded text-xs font-bold">{u.preference}</span> : <span className="text-gray-300 text-xs italic">Not Selected</span>}
                  </td>
                  <td className="px-4 py-3">{subBadge(u.subscription || 'free')}</td>
                  <td className="px-4 py-3">
                    {u.unlocked_exam ? (
                      <span className="text-xs px-2 py-0.5 rounded-full font-medium bg-emerald-50 text-emerald-700">{u.unlocked_exam}</span>
                    ) : (
                      <span className="text-xs text-gray-300 italic">—</span>
                    )}
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-xs px-2 py-0.5 rounded-full font-medium capitalize bg-gray-100 text-gray-700">
                      {u.role}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center justify-end gap-1">
                      <button onClick={() => handleOpenEditModal(u)} className="p-1.5 rounded-lg hover:bg-yellow-50 transition-colors text-gray-400 hover:text-yellow-600" title="Modify Student Parameters">
                        <Edit2 size={15} />
                      </button>
                      <button onClick={() => setShowDelete(u.id)} className="p-1.5 rounded-lg hover:bg-red-50 transition-colors text-gray-400 hover:text-red-500" title="Purge Record">
                        <Trash2 size={15} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Upgraded Multi-Parameter Edit Modal */}
      {showEdit && selectedUser && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl p-6 w-full max-w-md">
            <div className="flex items-center justify-between mb-5">
              <h3 className="font-semibold text-lg" style={{ color: '#1A1A1A' }}>Update Student Parameters</h3>
              <button onClick={() => setShowEdit(null)} className="text-gray-400 hover:text-gray-600"><X size={18} /></button>
            </div>
            <div className="space-y-4">
              <div className="bg-gray-50 p-3 rounded-lg text-sm space-y-1">
                <p><strong>Student Name:</strong> {selectedUser.full_name}</p>
                <p><strong>System ID:</strong> {selectedUser.customID || selectedUser.id}</p>
              </div>
              
              {/* Parameter 1: Access Tier Selection */}
              <div>
                <label className="block text-xs font-bold text-gray-700 uppercase tracking-wide mb-1">Access Subscription Plan</label>
                <select
                  value={editSubscription}
                  onChange={e => {
                    const next = e.target.value;
                    setEditSubscription(next);
                    if (next === 'free') setEditUnlockedExam('');
                    else if (next === 'premium') setEditUnlockedExam('BOTH');
                    else if (next === 'basic' && !editUnlockedExam) setEditUnlockedExam('IELTS');
                  }}
                  className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none focus:border-blue-500 bg-white" style={{ borderColor: '#E5E7EB' }}>
                  {SUBSCRIPTION_TYPES.map(s => <option key={s} value={s}>{PLAN_LABELS[s]}</option>)}
                </select>
              </div>

              {/* Parameter 1b: Exam unlock */}
              <div>
                <label className="block text-xs font-bold text-gray-700 uppercase tracking-wide mb-1">Unlocked Exam Access</label>
                <select
                  value={editSubscription === 'free' ? '' : (editSubscription === 'premium' ? 'BOTH' : editUnlockedExam)}
                  disabled={editSubscription === 'free' || editSubscription === 'premium'}
                  onChange={e => setEditUnlockedExam(e.target.value)}
                  className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none focus:border-blue-500 bg-white disabled:bg-gray-100 disabled:text-gray-400"
                  style={{ borderColor: '#E5E7EB' }}
                >
                  {UNLOCK_OPTIONS.map(o => (
                    <option key={o.value || 'clear'} value={o.value}>{o.label}</option>
                  ))}
                </select>
                <p className="text-[11px] text-gray-400 mt-1">
                  Free clears unlock. Premium forces BOTH. Basic: choose IELTS, PTE, BOTH, or clear.
                </p>
              </div>

              {/* Parameter 2: Manual Exam Track Override */}
              <div>
                <label className="block text-xs font-bold text-gray-700 uppercase tracking-wide mb-1">Assigned Preparation Track</label>
                <select value={editPreference} onChange={e => setEditPreference(e.target.value)}
                  className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none focus:border-blue-500 bg-white" style={{ borderColor: '#E5E7EB' }}>
                  {TEST_TYPES.map(t => <option key={t} value={t}>{t} Portal Workspace</option>)}
                </select>
              </div>
            </div>
            
            <div className="flex gap-3 mt-6">
              <button disabled={mutationLoading} onClick={() => setShowEdit(null)} className="flex-1 py-2 rounded-lg border text-sm font-medium text-gray-500 hover:bg-gray-50" style={{ borderColor: '#E5E7EB' }}>Cancel</button>
              <button disabled={mutationLoading} onClick={handleUpdateUserSave} className="flex-1 py-2 rounded-lg text-white text-sm font-medium flex items-center justify-center disabled:opacity-50" style={{ background: '#007BFF' }}>
                {mutationLoading ? 'Syncing...' : 'Save Student Changes'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Placeholders Contain Protected */}
      {showAdd && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl p-6 w-full max-w-md">
            <div className="flex items-center justify-between mb-5">
              <h3 className="font-semibold" style={{ color: '#1A1A1A' }}>Add Student</h3>
              <button onClick={() => setShowAdd(false)} className="text-gray-400 hover:text-gray-600"><X size={18} /></button>
            </div>
            <div className="space-y-3">
              <p className="text-sm text-gray-500">Please trigger open signup workflow registration logic via authorization system controllers.</p>
            </div>
            <div className="flex gap-3 mt-6">
              <button onClick={() => setShowAdd(false)} className="w-full py-2 rounded-lg border text-sm font-medium text-gray-500" style={{ borderColor: '#E5E7EB' }}>Close</button>
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
            <h3 className="font-semibold mb-2" style={{ color: '#1A1A1A' }}>Delete Operations Protected</h3>
            <p className="text-sm text-gray-500 mb-6">User deletion must go through standard database archival parameters to prevent test progress data loss.</p>
            <button onClick={() => setShowDelete(null)} className="w-full py-2 rounded-lg border text-sm font-medium text-gray-500 hover:bg-gray-50" style={{ borderColor: '#E5E7EB' }}>Acknowledge</button>
          </div>
        </div>
      )}
    </div>
  );
}