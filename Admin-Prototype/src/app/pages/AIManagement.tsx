import React, { useState } from 'react';
import { Bot, Zap, Key, Play, RefreshCw, Check, X, Activity, AlertCircle, Eye } from 'lucide-react';
import { dummyAILogs } from '../data/dummyData';
import { toast } from 'sonner';

const AI_STATS = [
  { label: 'Total API Calls', value: '1,247', sub: 'Last 30 days', color: '#007BFF' },
  { label: 'Success Rate', value: '98.4%', sub: '↑ 0.3% vs last month', color: '#28A745' },
  { label: 'Estimated Cost', value: '$12.40', sub: 'March 2026', color: '#F59E0B' },
  { label: 'Avg. Response Time', value: '1.2s', sub: 'Across all endpoints', color: '#8B5CF6' },
];

const AI_FEATURES = [
  { id: 'essay', label: 'Essay Feedback', desc: 'AI evaluates IELTS/TOEFL essays', enabled: true },
  { id: 'audio', label: 'Audio Transcription', desc: 'Convert speaking responses to text', enabled: true },
  { id: 'qgen', label: 'Question Generation', desc: 'Auto-generate MCQs from content', enabled: false },
  { id: 'moderation', label: 'Content Moderation', desc: 'Auto-flag toxic community posts', enabled: true },
  { id: 'recommend', label: 'Study Recommendations', desc: 'Personalized study plan per user', enabled: false },
];

export function AIManagement() {
  const [features, setFeatures] = useState(AI_FEATURES);
  const [showTest, setShowTest] = useState(false);
  const [testInput, setTestInput] = useState('');
  const [testType, setTestType] = useState('essay');
  const [testing, setTesting] = useState(false);
  const [testResult, setTestResult] = useState('');
  const [showLog, setShowLog] = useState<string | null>(null);
  const [apiKey, setApiKey] = useState('sk-••••••••••••••••••••••••••••');
  const [editApiKey, setEditApiKey] = useState(false);
  const [newApiKey, setNewApiKey] = useState('');

  const toggleFeature = (id: string) => {
    setFeatures(prev => prev.map(f => f.id === id ? { ...f, enabled: !f.enabled } : f));
    const feat = features.find(f => f.id === id);
    toast.success(`${feat?.label} ${feat?.enabled ? 'disabled' : 'enabled'}.`);
  };

  const handleTest = async () => {
    if (!testInput.trim()) { toast.error('Please enter test input.'); return; }
    setTesting(true);
    setTestResult('');
    await new Promise(r => setTimeout(r, 2500));
    setTesting(false);
    const results: Record<string, string> = {
      essay: 'IELTS Band Score: 7.5\n\nCoherence & Cohesion: 8.0\nLexical Resource: 7.5\nGrammatical Range: 7.0\nTask Achievement: 7.5\n\nFeedback: Your essay demonstrates clear argumentation with effective use of linking words. Minor grammatical errors noted in paragraphs 2 and 4. Consider varying sentence structure more. Overall strong performance.',
      audio: 'Transcription (98.7% confidence):\n"The main topic of the lecture was climate change and its effects on global weather patterns. The professor mentioned three key factors..."\n\nFluency Score: 7.0\nPronunciation: 6.5\nVocabulary: 7.5',
      qgen: 'Generated 5 MCQ Questions:\n\nQ1: What is the primary cause of climate change?\nA) Solar flares  B) Human activities ✓  C) Ocean currents  D) Volcanic activity\n\nQ2: The term "carbon footprint" refers to...\n[3 more questions generated]',
      moderation: 'Content Analysis Result:\n\nToxicity Score: 0.12 (Clean)\nSpam Probability: 0.08 (Low)\nHateful Content: Not detected\nSuggested Action: No moderation needed.\n\n✓ Content is safe to publish.',
    };
    setTestResult(results[testType] || 'AI processing complete. Results generated successfully.');
    toast.success('AI test completed successfully!');
  };

  const logDetails = dummyAILogs.find(l => l.id === showLog);

  return (
    <div className="space-y-5 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 style={{ color: '#1A1A1A' }}>AI Management</h1>
          <p className="text-sm text-gray-500 mt-0.5">Configure and monitor AI features</p>
        </div>
        <button onClick={() => { setShowTest(true); setTestResult(''); }} className="flex items-center gap-2 px-4 py-2 rounded-lg text-white text-sm font-medium hover:opacity-90" style={{ background: '#8B5CF6' }}>
          <Play size={15} /> Test AI
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        {AI_STATS.map(stat => (
          <div key={stat.label} className="bg-white rounded-xl p-5 border shadow-sm" style={{ borderColor: '#E5E7EB' }}>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: `${stat.color}18` }}>
                <Activity size={18} style={{ color: stat.color }} />
              </div>
              <div>
                <p className="text-sm text-gray-500">{stat.label}</p>
                <p className="font-bold mt-0.5" style={{ color: '#1A1A1A', fontSize: '18px' }}>{stat.value}</p>
                <p className="text-xs text-gray-400 mt-0.5">{stat.sub}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* AI Features Toggle */}
        <div className="bg-white rounded-xl border shadow-sm" style={{ borderColor: '#E5E7EB' }}>
          <div className="px-5 py-4 border-b" style={{ borderColor: '#E5E7EB' }}>
            <h3 style={{ color: '#1A1A1A' }}>AI Feature Toggles</h3>
            <p className="text-xs text-gray-400 mt-0.5">Enable or disable AI capabilities</p>
          </div>
          <div className="divide-y" style={{ borderColor: '#F5F7FA' }}>
            {features.map(feat => (
              <div key={feat.id} className="flex items-center gap-3 px-5 py-4">
                <div className="w-9 h-9 rounded-lg flex items-center justify-center" style={{ background: feat.enabled ? '#8B5CF618' : '#F5F7FA' }}>
                  <Bot size={16} style={{ color: feat.enabled ? '#8B5CF6' : '#9CA3AF' }} />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium" style={{ color: '#1A1A1A' }}>{feat.label}</p>
                  <p className="text-xs text-gray-400">{feat.desc}</p>
                </div>
                <button
                  onClick={() => toggleFeature(feat.id)}
                  className="w-11 h-6 rounded-full relative transition-all duration-200 flex-shrink-0"
                  style={{ background: feat.enabled ? '#8B5CF6' : '#E5E7EB' }}
                >
                  <span className="absolute top-0.5 w-5 h-5 rounded-full bg-white shadow transition-all duration-200"
                    style={{ left: feat.enabled ? 'calc(100% - 22px)' : '2px' }} />
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* API Configuration */}
        <div className="space-y-4">
          <div className="bg-white rounded-xl border shadow-sm" style={{ borderColor: '#E5E7EB' }}>
            <div className="px-5 py-4 border-b" style={{ borderColor: '#E5E7EB' }}>
              <h3 style={{ color: '#1A1A1A' }}>API Configuration</h3>
              <p className="text-xs text-gray-400 mt-0.5">Manage OpenAI API credentials</p>
            </div>
            <div className="p-5 space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1.5" style={{ color: '#1A1A1A' }}>
                  <Key size={14} className="inline mr-1.5" /> OpenAI API Key
                </label>
                {editApiKey ? (
                  <div className="flex gap-2">
                    <input type="text" value={newApiKey} onChange={e => setNewApiKey(e.target.value)}
                      placeholder="sk-xxxxxxxxxxxxxxxx"
                      className="flex-1 px-3 py-2 text-sm rounded-lg border focus:outline-none font-mono" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }} />
                    <button onClick={() => { if (newApiKey) { setApiKey(newApiKey.slice(0, 5) + '••••••••••••••••••••••'); setEditApiKey(false); setNewApiKey(''); toast.success('API key updated.'); } }} className="px-3 py-2 rounded-lg text-white text-sm" style={{ background: '#28A745' }}><Check size={14} /></button>
                    <button onClick={() => { setEditApiKey(false); setNewApiKey(''); }} className="px-3 py-2 rounded-lg border text-sm" style={{ borderColor: '#E5E7EB' }}><X size={14} /></button>
                  </div>
                ) : (
                  <div className="flex gap-2">
                    <div className="flex-1 px-3 py-2 text-sm rounded-lg border font-mono" style={{ borderColor: '#E5E7EB', background: '#F9FAFB', color: '#6B7280' }}>{apiKey}</div>
                    <button onClick={() => setEditApiKey(true)} className="px-3 py-2 rounded-lg border text-sm hover:bg-gray-50 transition-colors" style={{ borderColor: '#E5E7EB', color: '#007BFF' }}>Edit</button>
                  </div>
                )}
              </div>
              <div>
                <label className="block text-sm font-medium mb-1.5" style={{ color: '#1A1A1A' }}>AI Model</label>
                <select className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}>
                  <option>gpt-4o (Recommended)</option>
                  <option>gpt-4-turbo</option>
                  <option>gpt-3.5-turbo (Economy)</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1.5" style={{ color: '#1A1A1A' }}>Monthly Token Limit</label>
                <input type="number" defaultValue={500000} className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }} />
              </div>
              <button onClick={() => toast.success('AI settings saved!')} className="w-full py-2 rounded-lg text-white text-sm font-medium" style={{ background: '#007BFF' }}>Save Configuration</button>
            </div>
          </div>

          <div className="bg-white rounded-xl border shadow-sm p-5" style={{ borderColor: '#E5E7EB' }}>
            <div className="flex items-center gap-2 p-3 rounded-lg" style={{ background: '#F59E0B10', border: '1px solid #F59E0B30' }}>
              <AlertCircle size={16} style={{ color: '#F59E0B' }} className="flex-shrink-0" />
              <p className="text-xs" style={{ color: '#92400E' }}>API keys are stored securely. Never share your API credentials. Replace placeholder with actual keys before deployment.</p>
            </div>
          </div>
        </div>
      </div>

      {/* AI Logs Table */}
      <div className="bg-white rounded-xl border shadow-sm overflow-hidden" style={{ borderColor: '#E5E7EB' }}>
        <div className="px-5 py-4 border-b" style={{ borderColor: '#E5E7EB' }}>
          <h3 style={{ color: '#1A1A1A' }}>Recent AI Call Logs</h3>
          <p className="text-xs text-gray-400 mt-0.5">Latest API requests and responses</p>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr style={{ background: '#F9FAFB', borderBottom: '1px solid #E5E7EB' }}>
                {['Log ID', 'Type', 'User', 'Timestamp', 'Status', 'Cost', 'Actions'].map(h => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase whitespace-nowrap">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y" style={{ borderColor: '#F5F7FA' }}>
              {dummyAILogs.map(log => (
                <tr key={log.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-4 py-3 text-xs font-mono text-gray-400">{log.id}</td>
                  <td className="px-4 py-3">
                    <span className="text-xs px-2 py-0.5 rounded-full font-medium" style={{ background: '#8B5CF618', color: '#8B5CF6' }}>{log.type}</span>
                  </td>
                  <td className="px-4 py-3 text-xs text-gray-500 max-w-32 truncate">{log.user}</td>
                  <td className="px-4 py-3 text-xs text-gray-400">{log.timestamp}</td>
                  <td className="px-4 py-3">
                    <span className="text-xs px-2 py-0.5 rounded-full font-medium"
                      style={log.status === 'success' ? { background: '#28A74515', color: '#28A745' } : { background: '#DC354515', color: '#DC3545' }}>
                      {log.status}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-xs font-mono" style={{ color: '#1A1A1A' }}>
                    {log.cost > 0 ? `$${log.cost.toFixed(2)}` : 'Free'}
                  </td>
                  <td className="px-4 py-3">
                    <button onClick={() => setShowLog(log.id)} className="p-1.5 rounded-lg hover:bg-blue-50 text-gray-400 hover:text-blue-500 transition-colors">
                      <Eye size={14} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Test AI Modal */}
      {showTest && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-xl">
            <div className="flex items-center justify-between px-6 py-4 border-b" style={{ borderColor: '#E5E7EB' }}>
              <div>
                <h3 className="font-semibold" style={{ color: '#1A1A1A' }}>Test AI Features</h3>
                <p className="text-xs text-gray-400">Simulate AI responses with dummy input</p>
              </div>
              <button onClick={() => setShowTest(false)} className="text-gray-400"><X size={18} /></button>
            </div>
            <div className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">AI Feature to Test</label>
                <select value={testType} onChange={e => { setTestType(e.target.value); setTestResult(''); }}
                  className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }}>
                  <option value="essay">Essay Feedback</option>
                  <option value="audio">Audio Transcription</option>
                  <option value="qgen">Question Generation</option>
                  <option value="moderation">Content Moderation</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">
                  {testType === 'essay' ? 'Essay Text' : testType === 'audio' ? 'Audio Transcript' : 'Input Content'}
                </label>
                <textarea value={testInput} onChange={e => setTestInput(e.target.value)}
                  placeholder={testType === 'essay' ? 'Paste essay text here...' : 'Enter input for AI processing...'}
                  rows={4} className="w-full px-3 py-2 text-sm rounded-lg border focus:outline-none resize-none" style={{ borderColor: '#E5E7EB', background: '#F9FAFB' }} />
              </div>

              {testResult && (
                <div className="p-4 rounded-xl whitespace-pre-wrap text-sm" style={{ background: '#F9FAFB', border: '1px solid #E5E7EB', color: '#1A1A1A', fontFamily: 'monospace', fontSize: '12px' }}>
                  <p className="text-xs font-semibold text-gray-500 mb-2 font-sans">AI RESPONSE:</p>
                  {testResult}
                </div>
              )}
            </div>
            <div className="px-6 py-4 border-t flex gap-3" style={{ borderColor: '#E5E7EB' }}>
              <button onClick={() => setShowTest(false)} className="flex-1 py-2 rounded-lg border text-sm" style={{ borderColor: '#E5E7EB', color: '#6B7280' }}>Close</button>
              <button onClick={handleTest} disabled={testing} className="flex-1 py-2 rounded-lg text-white text-sm font-medium flex items-center justify-center gap-2 hover:opacity-90 disabled:opacity-70" style={{ background: '#8B5CF6' }}>
                {testing ? <><RefreshCw size={14} className="animate-spin" /> Processing...</> : <><Zap size={14} /> Run AI Test</>}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Log Details Modal */}
      {showLog && logDetails && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-md">
            <div className="flex items-center justify-between px-6 py-4 border-b" style={{ borderColor: '#E5E7EB' }}>
              <h3 className="font-semibold">Log Details – {logDetails.id}</h3>
              <button onClick={() => setShowLog(null)} className="text-gray-400"><X size={18} /></button>
            </div>
            <div className="p-6 space-y-3">
              {[
                { label: 'Type', value: logDetails.type },
                { label: 'User', value: logDetails.user },
                { label: 'Timestamp', value: logDetails.timestamp },
                { label: 'Status', value: logDetails.status },
                { label: 'Cost', value: logDetails.cost > 0 ? `$${logDetails.cost}` : 'Free' },
              ].map(row => (
                <div key={row.label} className="flex items-start gap-3">
                  <span className="text-xs text-gray-400 w-24 flex-shrink-0">{row.label}</span>
                  <span className="text-sm font-medium" style={{ color: '#1A1A1A' }}>{row.value}</span>
                </div>
              ))}
              <div>
                <span className="text-xs text-gray-400 block mb-1">Result Snippet</span>
                <div className="p-3 rounded-lg text-xs" style={{ background: '#F5F7FA', color: '#374151', fontFamily: 'monospace' }}>{logDetails.result}</div>
              </div>
            </div>
            <div className="px-6 py-4 border-t" style={{ borderColor: '#E5E7EB' }}>
              <button onClick={() => setShowLog(null)} className="w-full py-2 rounded-lg border text-sm" style={{ borderColor: '#E5E7EB', color: '#6B7280' }}>Close</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
