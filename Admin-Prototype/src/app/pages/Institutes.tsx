import React, { useState } from 'react';
import { Building2, Plus, Edit2, Trash2, Search, Users, X, Check, AlertCircle } from 'lucide-react';
import { dummyInstitutes } from '../data/dummyData';
import { toast } from 'sonner';

export function Institutes() {
  const [institutes, setInstitutes] = useState(dummyInstitutes);
  const [search, setSearch] = useState('');
  const [showAdd, setShowAdd] = useState(false);
  const [showDelete, setShowDelete] = useState<string | null>(null);
  const [showEdit, setShowEdit] = useState<string | null>(null);
  const [form, setForm] = useState({ name: '', slug: '', adminEmail: '', plan: 'Basic', fee: 15000 });
  const [formError, setFormError] = useState('');

  const filtered = institutes.filter(i =>
    i.name.toLowerCase().includes(search.toLowerCase()) ||
    i.adminEmail.toLowerCase().includes(search.toLowerCase()) ||
    i.slug.toLowerCase().includes(search.toLowerCase())
  );

  const handleAdd = () => {
    if (!form.name || !form.adminEmail || !form.slug) { setFormError('Please fill all required fields.'); return; }
    const id = `INS${institutes.length + 1}`;
    setInstitutes(prev => [...prev, { ...form, id, students: 0, status: 'active', joinDate: '2026-03-06' }]);
    setShowAdd(false);
    setForm({ name: '', slug: '', adminEmail: '', plan: 'Basic', fee: 15000 });
    setFormError('');
    toast.success('Institute added successfully!');
  };

  const handleDelete = (id: string) => {
    setInstitutes(prev => prev.filter(i => i.id !== id));
    setShowDelete(null);
    toast.success('Institute removed.');
  };

  const editInst = institutes.find(i => i.id === showEdit);

  const totalStudents = institutes.reduce((acc, i) => acc + i.students, 0);
  const totalRevenue = institutes.reduce((acc, i) => acc + i.fee, 0);

  return (
    <div className="space-y-5 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 style={{ color: '#1A1A1A' }}>Institute Management</h1>
          <p className="text-sm text-gray-500 mt-0.5">B2B – {institutes.length} institutes · API: GET /institutes</p>
        </div>
        <button onClick={() => setShowAdd(true)} className="flex items-center gap-2 px-4 py-2 rounded-lg text-white text-sm font-medium hover:opacity-90" style={{ background: '#007BFF' }}>
          <Plus size={16} /> Add Institute
        </button>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="bg-white rounded-xl p-5 border shadow-sm" style={{ borderColor: '#E5E7EB' }}>
          <p className="text-sm text-gray-500">Total Institutes</p>
          <p className="font-bold mt-1" style={{ color: '#1A1A1A', fontSize: '24px' }}>{institutes.length}</p>
          <p className="text-xs text-gray-400 mt-0.5">{institutes.filter(i => i.status === 'active').length} active</p>
        </div>
        <div className="bg-white rounded-xl p-5 border shadow-sm" style={{ borderColor: '#E5E7EB' }}>
          <p className="text-sm text-gray-500">Total Students</p>
          <p className="font-bold mt-1" style={{ color: '#1A1A1A', fontSize: '24px' }}>{totalStudents}</p>
          <p className="text-xs text-gray-400 mt-0.5">Across all institutes</p>
        </div>
        <div className="bg-white rounded-xl p-5 border shadow-sm" style={{ borderColor: '#E5E7EB' }}>
          <p className="text-sm text-gray-500">Monthly B2B Revenue</p>
          <p className="font-bold mt-1" style={{ color: '#28A745', fontSize: '24px' }}>₨{totalRevenue.toLocaleString()}</p>
          <p className="text-xs text-gray-400 mt-0.5">All institute fees</p>
        </div>
      </div>

      {/* Search */}
      <div className="bg-white rounded-xl border p-4 shadow-sm" style={{ borderColor: '#E5E7EB' }}>
        <div className="relative max-w-sm">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search institutes..."
            className="w-full pl-9 pr-3 py-2 text-sm rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }} />
        </div>
      </div>

      {/* Institutes Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
        {filtered.map(inst => (
          <div key={inst.id} className="bg-white rounded-xl border shadow-sm hover:shadow-md transition-all" style={{ borderColor: '#E5E7EB' }}>
            <div className="p-5">
              <div className="flex items-start justify-between mb-3">
                <div className="w-11 h-11 rounded-xl flex items-center justify-center" style={{ background: '#8B5CF618' }}>
                  <Building2 size={20} style={{ color: '#8B5CF6' }} />
                </div>
                <div className="flex gap-1.5">
                  <span className="text-xs px-2 py-0.5 rounded-full font-medium"
                    style={inst.plan === 'Premium' ? { background: '#28A74515', color: '#28A745' } : { background: '#007BFF15', color: '#007BFF' }}>
                    {inst.plan}
                  </span>
                  <span className="text-xs px-2 py-0.5 rounded-full font-medium"
                    style={inst.status === 'active' ? { background: '#28A74515', color: '#28A745' } : { background: '#DC354515', color: '#DC3545' }}>
                    {inst.status}
                  </span>
                </div>
              </div>
              <h3 className="font-semibold mb-0.5" style={{ color: '#1A1A1A', fontSize: '15px' }}>{inst.name}</h3>
              <p className="text-xs font-mono text-gray-400 mb-3">{inst.slug}</p>
              <div className="space-y-1.5 text-xs text-gray-500">
                <div className="flex justify-between"><span>Admin Email</span><span className="text-gray-700 truncate ml-2 max-w-36">{inst.adminEmail}</span></div>
                <div className="flex justify-between"><span>Students</span><span className="font-medium flex items-center gap-1"><Users size={10} />{inst.students}</span></div>
                <div className="flex justify-between"><span>Monthly Fee</span><span className="font-semibold" style={{ color: '#28A745' }}>₨{inst.fee.toLocaleString()}</span></div>
                <div className="flex justify-between"><span>Joined</span><span>{inst.joinDate}</span></div>
              </div>
            </div>
            <div className="px-5 py-3 border-t flex gap-2" style={{ borderColor: '#F5F7FA' }}>
              <button onClick={() => setShowEdit(inst.id)} className="flex-1 flex items-center justify-center gap-1.5 py-1.5 rounded-lg text-xs font-medium transition-colors hover:bg-yellow-50" style={{ color: '#F59E0B' }}>
                <Edit2 size={12} /> Edit
              </button>
              <button onClick={() => setShowDelete(inst.id)} className="flex-1 flex items-center justify-center gap-1.5 py-1.5 rounded-lg text-xs font-medium transition-colors hover:bg-red-50" style={{ color: '#DC3545' }}>
                <Trash2 size={12} /> Remove
              </button>
            </div>
          </div>
        ))}
        {filtered.length === 0 && (
          <div className="col-span-3 text-center py-16 text-gray-400">
            <Building2 size={40} className="mx-auto mb-3 opacity-30" />
            <p>No institutes found.</p>
          </div>
        )}
      </div>

      {/* Add Modal */}
      {showAdd && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl p-6 w-full max-w-md">
            <div className="flex items-center justify-between mb-5">
              <h3 className="font-semibold" style={{ color: '#1A1A1A' }}>Add New Institute</h3>
              <button onClick={() => { setShowAdd(false); setFormError(''); }} className="text-gray-400"><X size={18} /></button>
            </div>
            {formError && <div className="flex items-center gap-2 px-3 py-2 rounded-lg mb-4 text-sm" style={{ background: '#DC354515', color: '#DC3545' }}><AlertCircle size={14} />{formError}</div>}
            <div className="space-y-3">
              <div><label className="block text-sm font-medium mb-1">Institute Name *</label><input value={form.name} onChange={e => setForm(p => ({ ...p, name: e.target.value }))} placeholder="e.g. Lahore English Academy" className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }} /></div>
              <div><label className="block text-sm font-medium mb-1">Slug / Code *</label><input value={form.slug} onChange={e => setForm(p => ({ ...p, slug: e.target.value.toUpperCase() }))} placeholder="INS6-LHR" className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none font-mono" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }} /></div>
              <div><label className="block text-sm font-medium mb-1">Admin Email *</label><input type="email" value={form.adminEmail} onChange={e => setForm(p => ({ ...p, adminEmail: e.target.value }))} placeholder="admin@lahoreacademy.pk" className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }} /></div>
              <div className="grid grid-cols-2 gap-3">
                <div><label className="block text-sm font-medium mb-1">Plan</label>
                  <select value={form.plan} onChange={e => setForm(p => ({ ...p, plan: e.target.value, fee: e.target.value === 'Premium' ? 25000 : 15000 }))}
                    className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}>
                    <option>Basic</option><option>Premium</option>
                  </select>
                </div>
                <div><label className="block text-sm font-medium mb-1">Monthly Fee (₨)</label>
                  <input type="number" value={form.fee} onChange={e => setForm(p => ({ ...p, fee: Number(e.target.value) }))} className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }} />
                </div>
              </div>
            </div>
            <div className="flex gap-3 mt-6">
              <button onClick={() => { setShowAdd(false); setFormError(''); }} className="flex-1 py-2 rounded-lg border text-sm" style={{ borderColor: '#E5E7EB', color: '#6B7280' }}>Cancel</button>
              <button onClick={handleAdd} className="flex-1 py-2 rounded-lg text-white text-sm font-medium flex items-center justify-center gap-1.5" style={{ background: '#007BFF' }}>
                <Check size={14} /> Add Institute
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Edit Modal */}
      {showEdit && editInst && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl p-6 w-full max-w-md">
            <div className="flex items-center justify-between mb-5">
              <h3 className="font-semibold">Edit Institute</h3>
              <button onClick={() => setShowEdit(null)} className="text-gray-400"><X size={18} /></button>
            </div>
            <div className="space-y-3">
              <div><label className="block text-sm font-medium mb-1">Name</label><input defaultValue={editInst.name} className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }} /></div>
              <div><label className="block text-sm font-medium mb-1">Admin Email</label><input defaultValue={editInst.adminEmail} className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }} /></div>
              <div className="grid grid-cols-2 gap-3">
                <div><label className="block text-sm font-medium mb-1">Plan</label><select defaultValue={editInst.plan} className="w-full px-3 py-2 text-sm rounded-lg border" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}><option>Basic</option><option>Premium</option></select></div>
                <div><label className="block text-sm font-medium mb-1">Status</label><select defaultValue={editInst.status} className="w-full px-3 py-2 text-sm rounded-lg border" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}><option>active</option><option>inactive</option></select></div>
              </div>
            </div>
            <div className="flex gap-3 mt-6">
              <button onClick={() => setShowEdit(null)} className="flex-1 py-2 rounded-lg border text-sm" style={{ borderColor: '#E5E7EB', color: '#6B7280' }}>Cancel</button>
              <button onClick={() => { setShowEdit(null); toast.success('Institute updated!'); }} className="flex-1 py-2 rounded-lg text-white text-sm font-medium" style={{ background: '#28A745' }}>Save Changes</button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Modal */}
      {showDelete && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl p-6 w-full max-w-sm text-center">
            <div className="w-14 h-14 rounded-full flex items-center justify-center mx-auto mb-4" style={{ background: '#DC354515' }}>
              <Building2 size={24} style={{ color: '#DC3545' }} />
            </div>
            <h3 className="font-semibold mb-2" style={{ color: '#1A1A1A' }}>Remove Institute?</h3>
            <p className="text-sm text-gray-500 mb-6">This will remove the institute and deactivate all associated student accounts.</p>
            <div className="flex gap-3">
              <button onClick={() => setShowDelete(null)} className="flex-1 py-2 rounded-lg border text-sm" style={{ borderColor: '#E5E7EB', color: '#6B7280' }}>Cancel</button>
              <button onClick={() => handleDelete(showDelete)} className="flex-1 py-2 rounded-lg text-white text-sm font-medium" style={{ background: '#DC3545' }}>Remove</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
