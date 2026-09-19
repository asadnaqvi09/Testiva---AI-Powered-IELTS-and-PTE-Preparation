import React, { useState, useEffect, useRef } from 'react';
import { User, Lock, Bell, Palette, Eye, EyeOff, Check, AlertCircle, Moon, Sun, Monitor, Loader2, Camera } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { updateUserProfileAPI, changeUserPasswordAPI, uploadUserAvatarAPI, updateUserSettingsAPI } from '../services/api';
import { applyTheme, normalizeNotifPrefs, type NotifPrefs } from '../utils/uiSettings';
import { toast } from 'sonner';

const NOTIF_SETTINGS: { id: keyof NotifPrefs; label: string; desc: string }[] = [
  { id: 'newUser', label: 'New User Registrations', desc: 'Show new-signup alerts in the TopBar bell' },
  { id: 'subChange', label: 'Subscription Changes', desc: 'Show plan-change alerts in the TopBar bell' },
  { id: 'newPost', label: 'New Community Posts', desc: 'Show new-post alerts in the TopBar bell' },
  { id: 'preferenceChange', label: 'Preference Change Requests', desc: 'Show IELTS/PTE switch requests in the TopBar bell' },
];

export function Settings() {
  const { user, updateUser } = useAuth();
  const [activeTab, setActiveTab] = useState<'profile' | 'security' | 'notifications' | 'appearance'>('profile');
  const [loading, setLoading] = useState(false);
  const [avatarUploading, setAvatarUploading] = useState(false);
  const [showCurrentPass, setShowCurrentPass] = useState(false);
  const [showNewPass, setShowNewPass] = useState(false);
  const [notifPrefs, setNotifPrefs] = useState<NotifPrefs>(() => normalizeNotifPrefs(user?.notifPrefs));
  const [theme, setTheme] = useState(user?.theme || 'light');
  const [settingsSaving, setSettingsSaving] = useState(false);
  const avatarInputRef = useRef<HTMLInputElement>(null);

  const [profileForm, setProfileForm] = useState({
    full_name: user?.name || '',
    email: user?.email || '',
    bio: user?.bio || '',
    avatar_url: user?.avatar || '',
  });

  const [passForm, setPassForm] = useState({ current: '', newPass: '', confirm: '' });
  const [passError, setPassError] = useState('');

  useEffect(() => {
    if (!user) return;
    setProfileForm({
      full_name: user.name || '',
      email: user.email || '',
      bio: user.bio || '',
      avatar_url: user.avatar || '',
    });
    setNotifPrefs(normalizeNotifPrefs(user.notifPrefs));
    setTheme(user.theme || 'light');
  }, [user]);

  const persistSettings = async (payload: { theme?: string; notif_prefs?: NotifPrefs }) => {
    setSettingsSaving(true);
    try {
      const res = await updateUserSettingsAPI(payload);
      if (!res?.success) throw new Error(res?.message || 'Save failed');
      const nextTheme = res.user?.theme || payload.theme || theme;
      const nextPrefs = normalizeNotifPrefs(res.user?.notif_prefs || payload.notif_prefs);
      setTheme(nextTheme);
      setNotifPrefs(nextPrefs);
      applyTheme(nextTheme);
      updateUser({ theme: nextTheme, notifPrefs: nextPrefs });
      toast.success('Settings saved');
    } catch (err: any) {
      toast.error(err?.message || 'Failed to save settings');
    } finally {
      setSettingsSaving(false);
    }
  };

  const handleThemeChange = (selectedTheme: string) => {
    setTheme(selectedTheme);
    applyTheme(selectedTheme);
    persistSettings({ theme: selectedTheme });
  };

  const handleToggleNotif = (id: keyof NotifPrefs) => {
    const next = { ...notifPrefs, [id]: !notifPrefs[id] };
    setNotifPrefs(next);
    persistSettings({ notif_prefs: next });
  };

  const handleAvatarChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    e.target.value = '';
    if (!file) return;
    if (!file.type.startsWith('image/')) {
      toast.error('Please choose an image file.');
      return;
    }
    if (file.size > 5 * 1024 * 1024) {
      toast.error('Image must be under 5MB.');
      return;
    }
    try {
      setAvatarUploading(true);
      const res = await uploadUserAvatarAPI(file);
      if (res?.success) {
        const url = res.user?.avatar_url || profileForm.avatar_url;
        setProfileForm(p => ({ ...p, avatar_url: url || '' }));
        updateUser({ avatar: url });
        toast.success('Avatar updated.');
      } else {
        toast.error((res as { message?: string })?.message || 'Avatar upload failed.');
      }
    } catch {
      toast.error('Avatar upload failed.');
    } finally {
      setAvatarUploading(false);
    }
  };

  const handleSaveProfile = async () => {
    if (!profileForm.full_name.trim()) {
      toast.error('Name field is required.');
      return;
    }
    try {
      setLoading(true);
      const res = await updateUserProfileAPI({
        full_name: profileForm.full_name,
        bio: profileForm.bio,
      });

      if (res?.success) {
        updateUser({
          name: profileForm.full_name,
          bio: profileForm.bio
        });
        toast.success('Profile updated successfully!');
      }
    } catch (err) {
      toast.error('Failed to update profile.');
    } finally {
      setLoading(false);
    }
  };

  const handleChangePassword = async () => {
    if (!passForm.current || !passForm.newPass || !passForm.confirm) {
      setPassError('All password fields are required.');
      return;
    }
    if (passForm.newPass !== passForm.confirm) {
      setPassError('New passwords do not match.');
      return;
    }
    if (passForm.newPass.length < 8) {
      setPassError('Password must be at least 8 characters.');
      return;
    }

    try {
      setLoading(true);
      setPassError('');
      const res = await changeUserPasswordAPI({
        current_password: passForm.current,
        new_password: passForm.newPass,
        confirm_password: passForm.confirm,
      });
      if (res?.success) {
        toast.success('Password updated successfully!');
        setPassForm({ current: '', newPass: '', confirm: '' });
      } else {
        setPassError(res?.message || 'Invalid current password.');
      }
    } catch (err) {
      toast.error('Password update failed.');
    } finally {
      setLoading(false);
    }
  };

  const TABS = [
    { id: 'profile', label: 'Profile Settings', icon: <User size={15} /> },
    { id: 'security', label: 'Security & Access', icon: <Lock size={15} /> },
    { id: 'notifications', label: 'Notification Rules', icon: <Bell size={15} /> },
    { id: 'appearance', label: 'Visual Interface', icon: <Palette size={15} /> },
  ] as const;

  return (
    <div className="max-w-4xl mx-auto space-y-5">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">System Configuration</h1>
        <p className="text-sm text-gray-500 mt-0.5">Manage your account settings and preferences</p>
      </div>

      <div className="flex flex-col lg:flex-row gap-5">
        <div className="lg:w-56 flex-shrink-0 space-y-3">
          <div className="bg-white rounded-xl border shadow-sm p-2">
            {TABS.map(tab => (
              <button key={tab.id} onClick={() => setActiveTab(tab.id)}
                className="w-full flex items-center gap-2.5 px-3 py-2.5 rounded-lg text-sm font-medium transition-all mb-0.5"
                style={activeTab === tab.id ? { background: '#007BFF18', color: '#007BFF' } : { color: '#6B7280' }}>
                {tab.icon} {tab.label}
              </button>
            ))}
          </div>

          <div className="bg-white rounded-xl border shadow-sm p-4 text-center">
            <div className="relative w-16 h-16 mx-auto mb-2 group">
              {profileForm.avatar_url ? (
                <img
                  src={profileForm.avatar_url}
                  alt=""
                  className="w-16 h-16 rounded-full object-cover shadow-inner"
                />
              ) : (
                <div className="w-16 h-16 rounded-full flex items-center justify-center text-white text-2xl font-bold shadow-inner" style={{ background: '#007BFF' }}>
                  {profileForm.full_name?.charAt(0).toUpperCase() || 'U'}
                </div>
              )}
              <button
                type="button"
                disabled={avatarUploading}
                onClick={() => avatarInputRef.current?.click()}
                className="absolute inset-0 bg-black/40 rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity text-white cursor-pointer disabled:opacity-60"
                aria-label="Upload avatar"
              >
                {avatarUploading ? <Loader2 size={14} className="animate-spin" /> : <Camera size={14} />}
              </button>
              <input
                ref={avatarInputRef}
                type="file"
                accept="image/*"
                className="hidden"
                onChange={handleAvatarChange}
              />
            </div>
            <p className="text-sm font-semibold truncate text-gray-900">{profileForm.full_name || 'User'}</p>
            <p className="text-xs text-gray-400 mt-0.5 truncate">Admin</p>
            <p className="text-[10px] text-gray-400 mt-2">Hover avatar to upload</p>
          </div>
        </div>

        <div className="flex-1">
          {activeTab === 'profile' && (
            <div className="bg-white rounded-xl border shadow-sm p-6 space-y-4">
              <div>
                <h3 className="font-semibold text-base text-gray-900">Profile Information</h3>
                <p className="text-xs text-gray-400 mt-0.5">Update your personal details and bio</p>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-gray-600 uppercase mb-1.5">Full Name</label>
                  <input value={profileForm.full_name} onChange={e => setProfileForm(p => ({ ...p, full_name: e.target.value }))}
                    className="w-full px-3 py-2 text-sm rounded-lg border border-gray-200 focus:outline-none focus:border-blue-500 bg-gray-50/50" />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-gray-600 uppercase mb-1.5">Email Address</label>
                  <input type="email" value={profileForm.email} disabled className="w-full px-3 py-2 text-sm rounded-lg border border-gray-200 bg-gray-100 text-gray-400 cursor-not-allowed" />
                </div>
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-600 uppercase mb-1.5">Biography</label>
                <textarea
                  value={profileForm.bio}
                  onChange={e => setProfileForm(p => ({ ...p, bio: e.target.value }))}
                  rows={4}
                  placeholder="Tell us about yourself..."
                  className="w-full px-3 py-2 text-sm rounded-lg border border-gray-200 focus:outline-none focus:border-blue-500 bg-gray-50/50 resize-none"
                />
              </div>
              <button disabled={loading} onClick={handleSaveProfile} className="px-5 py-2.5 rounded-lg text-white text-sm font-medium hover:opacity-90 transition-opacity flex items-center gap-1.5" style={{ background: '#007BFF' }}>
                {loading ? <Loader2 size={14} className="animate-spin" /> : <Check size={14} />} Save Changes
              </button>
            </div>
          )}

          {activeTab === 'security' && (
            <div className="bg-white rounded-xl border shadow-sm p-6 space-y-4">
              <h3 className="font-semibold text-base text-gray-900">Change Password</h3>
              {passError && <div className="flex items-center gap-2 px-3 py-2 rounded-lg text-sm bg-red-50 text-red-600 border border-red-100"><AlertCircle size={14} />{passError}</div>}
              <div className="space-y-3.5">
                <div>
                  <label className="block text-xs font-semibold text-gray-600 uppercase mb-1.5">Current Password</label>
                  <div className="relative">
                    <input type={showCurrentPass ? 'text' : 'password'} value={passForm.current} onChange={e => setPassForm(p => ({ ...p, current: e.target.value }))}
                      className="w-full px-3 py-2 pr-10 text-sm rounded-lg border border-gray-200 focus:outline-none focus:border-blue-500 bg-gray-50/50" />
                    <button onClick={() => setShowCurrentPass(!showCurrentPass)} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400">{showCurrentPass ? <EyeOff size={15} /> : <Eye size={15} />}</button>
                  </div>
                </div>
                <div>
                  <label className="block text-xs font-semibold text-gray-600 uppercase mb-1.5">New Password</label>
                  <div className="relative">
                    <input type={showNewPass ? 'text' : 'password'} value={passForm.newPass} onChange={e => setPassForm(p => ({ ...p, newPass: e.target.value }))}
                      className="w-full px-3 py-2 pr-10 text-sm rounded-lg border border-gray-200 focus:outline-none focus:border-blue-500 bg-gray-50/50" />
                    <button onClick={() => setShowNewPass(!showNewPass)} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400">{showNewPass ? <EyeOff size={15} /> : <Eye size={15} />}</button>
                  </div>
                </div>
                <div>
                  <label className="block text-xs font-semibold text-gray-600 uppercase mb-1.5">Confirm New Password</label>
                  <input type="password" value={passForm.confirm} onChange={e => setPassForm(p => ({ ...p, confirm: e.target.value }))}
                    className="w-full px-3 py-2 text-sm rounded-lg border border-gray-200 focus:outline-none focus:border-blue-500 bg-gray-50/50" />
                </div>
              </div>
              <button disabled={loading} onClick={handleChangePassword} className="px-5 py-2.5 rounded-lg text-white text-sm font-medium hover:opacity-90 transition-opacity flex items-center gap-1.5" style={{ background: '#007BFF' }}>
                {loading ? <Loader2 size={14} className="animate-spin" /> : <Lock size={14} />} Update Password
              </button>
            </div>
          )}

          {activeTab === 'notifications' && (
            <div className="bg-white rounded-xl border shadow-sm p-6">
              <h3 className="font-semibold text-base text-gray-900 mb-1">Notification Preferences</h3>
              <p className="text-xs text-gray-400 mb-4">
                Saved to your account. Controls which alert types appear in the TopBar bell.
                {settingsSaving ? ' Saving…' : ''}
              </p>
              <div className="space-y-1">
                {NOTIF_SETTINGS.map(n => (
                  <div key={n.id} className="flex items-center gap-4 py-3.5 border-b border-gray-50 last:border-0">
                    <div className="flex-1">
                      <p className="text-sm font-medium text-gray-900">{n.label}</p>
                      <p className="text-xs text-gray-400">{n.desc}</p>
                    </div>
                    <button
                      disabled={settingsSaving}
                      onClick={() => handleToggleNotif(n.id)}
                      className="w-10 h-5.5 rounded-full relative transition-all disabled:opacity-50"
                      style={{ background: notifPrefs[n.id] !== false ? '#007BFF' : '#E5E7EB' }}
                      aria-label={`Toggle ${n.label}`}
                    >
                      <span className="absolute top-0.5 w-4.5 h-4.5 rounded-full bg-white shadow transition-all"
                        style={{ left: notifPrefs[n.id] !== false ? '22px' : '2px' }} />
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}

          {activeTab === 'appearance' && (
            <div className="bg-white rounded-xl border shadow-sm p-6 space-y-5">
              <h3 className="font-semibold text-base text-gray-900">Theme Settings</h3>
              <p className="text-xs text-gray-400 -mt-3">Synced to your account across sessions</p>
              <div className="grid grid-cols-3 gap-3">
                {[
                  { id: 'light', label: 'Light', icon: <Sun size={16} /> },
                  { id: 'dark', label: 'Dark', icon: <Moon size={16} /> },
                  { id: 'system', label: 'System', icon: <Monitor size={16} /> },
                ].map(t => (
                  <button key={t.id} disabled={settingsSaving} onClick={() => handleThemeChange(t.id)}
                    className="flex flex-col items-center gap-2 p-3.5 rounded-xl border-2 transition-all text-center disabled:opacity-50"
                    style={theme === t.id ? { borderColor: '#007BFF', background: '#007BFF05' } : { borderColor: '#E5E7EB' }}>
                    <span style={{ color: theme === t.id ? '#007BFF' : '#9CA3AF' }}>{t.icon}</span>
                    <span className="text-xs font-semibold">{t.label}</span>
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
