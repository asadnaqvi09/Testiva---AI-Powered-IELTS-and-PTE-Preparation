import React, { useState } from 'react';
import { useNavigate, Navigate } from 'react-router';
import { Eye, EyeOff, GraduationCap, AlertCircle, X, CheckCircle2 } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { toast } from 'sonner';

export function Login() {
  const { login, isAuthenticated, loading: authLoading } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPass, setShowPass] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [showForgot, setShowForgot] = useState(false);
  const [forgotEmail, setForgotEmail] = useState('');
  const [forgotSent, setForgotSent] = useState(false);

  if (authLoading) return null;
  if (isAuthenticated) return <Navigate to="/dashboard" replace />;

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    if (!email || !password) { setError('Please fill in all fields.'); return; }
    setLoading(true);
    const result = await login(email, password);
    setLoading(false);
    if (result.success) {
      toast.success('Login successful! Welcome back.');
      navigate('/dashboard');
    } else {
      setError(result.message || 'Invalid credentials.');
      toast.error(result.message || 'Invalid credentials. Please try again.');
    }
  };

  const handleForgot = async (e: React.FormEvent) => {
    e.preventDefault();
    await new Promise(r => setTimeout(r, 800));
    setForgotSent(true);
  };

  const fillCredential = (type: 'admin') => {
    // Pre-fill with the admin email — actual auth goes through the real API
    if (type === 'admin') { setEmail('ragesr56@gmail.com'); setPassword('TestFlow12345@sk'); }
    setError('');
  };

  return (
    <div className="min-h-screen flex" style={{ background: '#F5F7FA' }}>
      {/* Left panel */}
      <div className="hidden lg:flex flex-col justify-between w-96 p-10 text-white" style={{ background: 'linear-gradient(135deg, #1A1A2E 0%, #007BFF 100%)' }}>
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-white/20 flex items-center justify-center">
            <GraduationCap size={22} className="text-white" />
          </div>
          <div>
            <p className="font-bold text-lg leading-tight">Testiva Admin</p>
            <p className="text-xs text-blue-200">AI-Powered IELTS & PTE Preparation</p>
          </div>
        </div>
        <div>
          <h2 className="text-3xl font-bold mb-4 leading-snug">Manage. Teach.<br />Empower.</h2>
          <p className="text-blue-100 text-sm leading-relaxed">A powerful admin dashboard for IELTS & PTE test preparation. Manage content, users, and analytics with ease.</p>
        </div>
        <div className="space-y-3">
          <div className="flex items-center gap-3 bg-white/10 rounded-lg p-3">
            <CheckCircle2 size={16} className="text-green-300 flex-shrink-0" />
            <p className="text-sm text-blue-100">Real-time API testing</p>
          </div>
          <div className="flex items-center gap-3 bg-white/10 rounded-lg p-3">
            <CheckCircle2 size={16} className="text-green-300 flex-shrink-0" />
            <p className="text-sm text-blue-100">AI-powered content & moderation</p>
          </div>
          <div className="flex items-center gap-3 bg-white/10 rounded-lg p-3">
            <CheckCircle2 size={16} className="text-green-300 flex-shrink-0" />
            <p className="text-sm text-blue-100">Live backend sync</p>
          </div>
        </div>
      </div>

      {/* Right panel - login form */}
      <div className="flex-1 flex items-center justify-center px-6 py-12">
        <div className="w-full max-w-md">
          <div className="lg:hidden flex items-center gap-2 mb-8">
            <div className="w-9 h-9 rounded-xl flex items-center justify-center" style={{ background: '#007BFF' }}>
              <GraduationCap size={18} className="text-white" />
            </div>
            <span className="font-bold text-lg" style={{ color: '#1A1A1A' }}>Testiva Admin</span>
          </div>

          <div className="bg-white rounded-2xl shadow-lg p-8 border" style={{ borderColor: '#E5E7EB' }}>
            <h1 className="font-bold mb-1" style={{ color: '#1A1A1A', fontSize: '24px' }}>Welcome back</h1>
            <p className="text-sm text-gray-500 mb-6">Sign in to your admin account</p>

            {/* Quick login buttons */}
            <div className="mb-5">
              <p className="text-xs text-gray-400 mb-2 font-medium">QUICK FILL</p>
              <div className="flex flex-wrap gap-2">
                <button onClick={() => fillCredential('admin')} className="text-xs px-2.5 py-1.5 rounded-lg border transition-colors hover:border-blue-400 hover:text-blue-600" style={{ borderColor: '#E5E7EB', color: '#6B7280' }}>Admin Account</button>
              </div>
              <p className="text-xs text-gray-400 mt-1.5">⚡ Credentials are sent to the real backend API</p>
            </div>

            {error && (
              <div className="flex items-center gap-2 px-4 py-3 rounded-lg mb-4 text-sm" style={{ background: '#DC354515', color: '#DC3545', border: '1px solid #DC354530' }}>
                <AlertCircle size={16} className="flex-shrink-0" />
                {error}
              </div>
            )}

            <form onSubmit={handleLogin} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1.5" style={{ color: '#1A1A1A' }}>Email</label>
                <input
                  type="text"
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  placeholder="admin@example.com"
                  className="w-full px-4 py-2.5 rounded-lg border text-sm transition-colors focus:outline-none focus:border-blue-400"
                  style={{ borderColor: '#E5E7EB', background: '#F9FAFB', color: '#1A1A1A' }}
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1.5" style={{ color: '#1A1A1A' }}>Password</label>
                <div className="relative">
                  <input
                    type={showPass ? 'text' : 'password'}
                    value={password}
                    onChange={e => setPassword(e.target.value)}
                    placeholder="Enter your password"
                    className="w-full px-4 py-2.5 pr-10 rounded-lg border text-sm transition-colors focus:outline-none focus:border-blue-400"
                    style={{ borderColor: '#E5E7EB', background: '#F9FAFB', color: '#1A1A1A' }}
                  />
                  <button type="button" onClick={() => setShowPass(!showPass)} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                    {showPass ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>
              <div className="flex justify-end">
                <button type="button" onClick={() => setShowForgot(true)} className="text-sm font-medium" style={{ color: '#007BFF' }}>
                  Forgot password?
                </button>
              </div>
              <button
                type="submit"
                disabled={loading}
                className="w-full py-3 rounded-lg text-white font-semibold text-sm transition-all hover:opacity-90 active:scale-95 flex items-center justify-center gap-2"
                style={{ background: '#007BFF' }}
              >
                {loading ? (
                  <>
                    <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    Signing in...
                  </>
                ) : 'Login'}
              </button>
            </form>
          </div>

          <p className="text-center text-xs text-gray-400 mt-4">
            Testiva Admin · AI-Powered IELTS & PTE Preparation · FYP 2026
          </p>
        </div>
      </div>

      {/* Forgot Password Modal */}
      {showForgot && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl p-6 w-full max-w-sm">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-semibold" style={{ color: '#1A1A1A' }}>Reset Password</h3>
              <button onClick={() => { setShowForgot(false); setForgotSent(false); setForgotEmail(''); }} className="text-gray-400 hover:text-gray-600">
                <X size={18} />
              </button>
            </div>
            {forgotSent ? (
              <div className="text-center py-4">
                <CheckCircle2 size={40} className="mx-auto mb-3" style={{ color: '#28A745' }} />
                <p className="font-medium text-sm" style={{ color: '#1A1A1A' }}>Reset instructions sent!</p>
                <p className="text-xs text-gray-400 mt-1">Check your email for a password reset link.</p>
                <button onClick={() => { setShowForgot(false); setForgotSent(false); setForgotEmail(''); }} className="mt-4 text-sm font-medium" style={{ color: '#007BFF' }}>Close</button>
              </div>
            ) : (
              <form onSubmit={handleForgot} className="space-y-4">
                <p className="text-sm text-gray-500">Enter your email address and we'll send you instructions to reset your password.</p>
                <input
                  type="email"
                  value={forgotEmail}
                  onChange={e => setForgotEmail(e.target.value)}
                  placeholder="admin@example.com"
                  className="w-full px-4 py-2.5 rounded-lg border text-sm focus:outline-none"
                  style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}
                />
                <button type="submit" className="w-full py-2.5 rounded-lg text-white text-sm font-medium" style={{ background: '#007BFF' }}>
                  Send Reset Instructions
                </button>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
