import React, { useState } from 'react';
import { useNavigate, Navigate } from 'react-router';
import { Eye, EyeOff, GraduationCap, AlertCircle, X, CheckCircle2 } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { forgotPasswordAPI, verifyOtpAPI, resetPasswordAPI, resendOtpAPI } from '../services/api';
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
  const [forgotStep, setForgotStep] = useState<'email' | 'otp' | 'password' | 'done'>('email');
  const [forgotEmail, setForgotEmail] = useState('');
  const [forgotOtp, setForgotOtp] = useState('');
  const [forgotPassword, setForgotPassword] = useState('');
  const [forgotLoading, setForgotLoading] = useState(false);
  const [forgotError, setForgotError] = useState('');

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

  const resetForgot = () => {
    setShowForgot(false);
    setForgotStep('email');
    setForgotEmail('');
    setForgotOtp('');
    setForgotPassword('');
    setForgotError('');
  };

  const handleForgotSendOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    setForgotError('');
    if (!forgotEmail.trim()) {
      setForgotError('Email is required');
      return;
    }
    setForgotLoading(true);
    try {
      await forgotPasswordAPI(forgotEmail.trim().toLowerCase());
      setForgotStep('otp');
      toast.success('OTP sent to your email');
    } catch (err: any) {
      setForgotError(err?.message || 'Failed to send OTP');
      toast.error(err?.message || 'Failed to send OTP');
    } finally {
      setForgotLoading(false);
    }
  };

  const handleForgotVerifyOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    setForgotError('');
    if (!forgotOtp.trim()) {
      setForgotError('OTP is required');
      return;
    }
    setForgotLoading(true);
    try {
      await verifyOtpAPI(forgotEmail.trim().toLowerCase(), forgotOtp.trim(), 'reset');
      setForgotStep('password');
      toast.success('OTP verified');
    } catch (err: any) {
      setForgotError(err?.message || 'Invalid OTP');
      toast.error(err?.message || 'Invalid OTP');
    } finally {
      setForgotLoading(false);
    }
  };

  const handleForgotResetPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setForgotError('');
    if (forgotPassword.length < 8) {
      setForgotError('Password must be at least 8 characters');
      return;
    }
    setForgotLoading(true);
    try {
      await resetPasswordAPI({
        email: forgotEmail.trim().toLowerCase(),
        new_password: forgotPassword,
      });
      setForgotStep('done');
      toast.success('Password reset successful');
    } catch (err: any) {
      setForgotError(err?.message || 'Reset failed');
      toast.error(err?.message || 'Reset failed');
    } finally {
      setForgotLoading(false);
    }
  };

  const handleResendOtp = async () => {
    setForgotLoading(true);
    try {
      await resendOtpAPI(forgotEmail.trim().toLowerCase(), 'reset');
      toast.success('OTP resent');
    } catch (err: any) {
      toast.error(err?.message || 'Resend failed');
    } finally {
      setForgotLoading(false);
    }
  };

  const fillCredential = (type: 'admin') => {
    if (type === 'admin') { setEmail('ragesr56@gmail.com'); setPassword('TestFlow12345@sk'); }
    setError('');
  };

  return (
    <div className="min-h-screen flex" style={{ background: '#F5F7FA' }}>
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
                <button type="button" onClick={() => { setShowForgot(true); setForgotStep('email'); }} className="text-sm font-medium" style={{ color: '#007BFF' }}>
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

      {showForgot && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl p-6 w-full max-w-sm">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-semibold" style={{ color: '#1A1A1A' }}>Reset Password</h3>
              <button onClick={resetForgot} className="text-gray-400 hover:text-gray-600">
                <X size={18} />
              </button>
            </div>

            {forgotError && (
              <p className="text-sm text-red-600 mb-3">{forgotError}</p>
            )}

            {forgotStep === 'done' ? (
              <div className="text-center py-4">
                <CheckCircle2 size={40} className="mx-auto mb-3" style={{ color: '#28A745' }} />
                <p className="font-medium text-sm" style={{ color: '#1A1A1A' }}>Password updated</p>
                <p className="text-xs text-gray-400 mt-1">You can sign in with your new password.</p>
                <button onClick={resetForgot} className="mt-4 text-sm font-medium" style={{ color: '#007BFF' }}>Close</button>
              </div>
            ) : forgotStep === 'email' ? (
              <form onSubmit={handleForgotSendOtp} className="space-y-4">
                <p className="text-sm text-gray-500">Enter your admin email. We will send a one-time OTP.</p>
                <input
                  type="email"
                  value={forgotEmail}
                  onChange={e => setForgotEmail(e.target.value)}
                  placeholder="admin@example.com"
                  className="w-full px-4 py-2.5 rounded-lg border text-sm focus:outline-none"
                  style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}
                />
                <button type="submit" disabled={forgotLoading} className="w-full py-2.5 rounded-lg text-white text-sm font-medium" style={{ background: '#007BFF' }}>
                  {forgotLoading ? 'Sending…' : 'Send OTP'}
                </button>
              </form>
            ) : forgotStep === 'otp' ? (
              <form onSubmit={handleForgotVerifyOtp} className="space-y-4">
                <p className="text-sm text-gray-500">Enter the OTP sent to {forgotEmail}</p>
                <input
                  type="text"
                  value={forgotOtp}
                  onChange={e => setForgotOtp(e.target.value)}
                  placeholder="4-digit OTP"
                  className="w-full px-4 py-2.5 rounded-lg border text-sm focus:outline-none"
                  style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}
                />
                <button type="submit" disabled={forgotLoading} className="w-full py-2.5 rounded-lg text-white text-sm font-medium" style={{ background: '#007BFF' }}>
                  {forgotLoading ? 'Verifying…' : 'Verify OTP'}
                </button>
                <button type="button" onClick={handleResendOtp} disabled={forgotLoading} className="w-full text-sm" style={{ color: '#007BFF' }}>
                  Resend OTP
                </button>
              </form>
            ) : (
              <form onSubmit={handleForgotResetPassword} className="space-y-4">
                <p className="text-sm text-gray-500">Choose a new password</p>
                <input
                  type="password"
                  value={forgotPassword}
                  onChange={e => setForgotPassword(e.target.value)}
                  placeholder="New password"
                  className="w-full px-4 py-2.5 rounded-lg border text-sm focus:outline-none"
                  style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}
                />
                <button type="submit" disabled={forgotLoading} className="w-full py-2.5 rounded-lg text-white text-sm font-medium" style={{ background: '#007BFF' }}>
                  {forgotLoading ? 'Saving…' : 'Reset password'}
                </button>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
