import React, { useState, useRef, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router';
import {
  ChevronRight, ChevronLeft, Plus, Trash2, ChevronDown, ChevronUp,
  Mic, BookOpen, Headphones, PenTool, MessageCircle, AlertTriangle,
  CheckCircle2, Save, Upload, X, Lock, Info, Layers, FileText,
  Volume2, Image as ImageIcon, Eye, ArrowRight, Loader2,
  BarChart2, MessageSquare, HelpCircle, Lightbulb, AlignLeft,
  ThumbsUp, Scale, BookOpen as BookOpenIcon,
} from 'lucide-react';
import { toast } from 'sonner';
import {
  useMocks,
  type BuilderSection, type BuilderQuestion,
} from '../context/MocksContext';

// ─── Types ────────────────────────────────────────────────────────────────────

type TestSection  = BuilderSection;
type TestQuestion = BuilderQuestion;
type TestType     = 'IELTS' | 'PTE';
type Difficulty   = 'Easy' | 'Medium' | 'Hard';
type TestMode     = 'full' | 'single';
type ModuleType   = 'Reading' | 'Listening' | 'Writing' | 'Speaking' | 'Speaking & Writing';
type WritingTask  = 'Task 1' | 'Task 2';
type Task1Track   = 'Academic' | 'General Training';
type Task1GeneralType = 'Request Information' | 'Explain Situation' | 'Provide Opinion';
type Task2Type = 'Opinion' | 'Discussion' | 'Problem & Solution' | 'Advantages & Disadvantages' | 'Two-Part Question';

// ─── Static config ────────────────────────────────────────────────────────────

const QUESTION_TYPES: Record<string, string[]> = {
  Reading:              ['MCQ', 'True/False/NG', 'Yes/No/NG', 'Matching', 'Sentence Completion', 'Short Answer'],
  Listening:            ['MCQ', 'Multi-select', 'Form Fill', 'Matching', 'Short Answer'],
  Speaking:             ['Part 1: Interview', 'Part 2: Cue Card', 'Part 3: Discussion'],
  'Speaking & Writing': ['Part 1: Interview', 'Part 2: Cue Card'],
};

// Derives writing question types dynamically based on current section config.
// Task 1 Academic   → single "Chart Description" question (no type picker, just text)
// Task 1 General    → letter sub-types replace question types
// Task 2            → essay sub-types replace question types
function getWritingQuestionTypes(section: TestSection): string[] {
  if (section.moduleType !== 'Writing' && section.moduleType !== 'Speaking & Writing') return [];
  if (section.writingTask === 'Task 1') {
    if (section.task1Track === 'Academic') {
      return ['Chart Description'];          // single fixed type
    }
    // General Training: letter types become the question types
    return ['Request Information', 'Explain Situation', 'Provide Opinion'];
  }
  // Task 2: essay types become the question types
  return ['Opinion', 'Discussion', 'Problem & Solution', 'Advantages & Disadvantages', 'Two-Part Question'];
}

// Returns the question types available for a given section (non-writing uses static table)
function getQuestionTypes(section: TestSection): string[] {
  const isWriting = section.moduleType === 'Writing' || section.moduleType === 'Speaking & Writing';
  if (isWriting) return getWritingQuestionTypes(section);
  return QUESTION_TYPES[section.moduleType] || [];
}

const IELTS_FULL_MODULES:   ModuleType[] = ['Reading', 'Listening', 'Writing', 'Speaking'];
const PTE_FULL_MODULES:     ModuleType[] = ['Speaking & Writing', 'Reading', 'Listening'];
const IELTS_SINGLE_MODULES: ModuleType[] = ['Reading', 'Listening', 'Writing', 'Speaking'];

const MODULE_COLOR: Record<string, string> = {
  Reading:              '#007BFF',
  Listening:            '#28A745',
  Writing:              '#8B5CF6',
  Speaking:             '#F59E0B',
  'Speaking & Writing': '#EC4899',
};

const MODULE_ICON: Record<string, React.ReactNode> = {
  Reading:              <BookOpen size={15} />,
  Listening:            <Headphones size={15} />,
  Writing:              <PenTool size={15} />,
  Speaking:             <Mic size={15} />,
  'Speaking & Writing': <MessageCircle size={15} />,
};

const STEPS = [
  { n: 1, label: 'Initialization',     sub: 'Basic Info & Mode' },
  { n: 2, label: 'Section Builder',    sub: 'Sections & Questions' },
  { n: 3, label: 'Mapping Review',     sub: 'Relational Structure' },
  { n: 4, label: 'Validate & Publish', sub: 'Final Checks' },
];

// ─── Writing-specific static data ────────────────────────────────────────────

const TASK2_TYPES: { key: Task2Type; icon: React.ReactNode; desc: string }[] = [
  { key: 'Opinion',                     icon: <ThumbsUp size={14} />,     desc: 'To what extent do you agree or disagree?' },
  { key: 'Discussion',                  icon: <MessageSquare size={14} />, desc: 'Discuss both views and give your opinion.' },
  { key: 'Problem & Solution',          icon: <Lightbulb size={14} />,    desc: 'Causes of this problem and proposed solutions.' },
  { key: 'Advantages & Disadvantages', icon: <Scale size={14} />,         desc: 'Do the advantages outweigh the disadvantages?' },
  { key: 'Two-Part Question',           icon: <HelpCircle size={14} />,   desc: 'Answer two separate but related questions.' },
];

const TASK1_GENERAL_TYPES: { key: Task1GeneralType; icon: React.ReactNode; desc: string }[] = [
  { key: 'Request Information', icon: <AlignLeft size={14} />,    desc: 'Write a letter requesting information or action.' },
  { key: 'Explain Situation',   icon: <FileText size={14} />,     desc: 'Explain a situation or circumstance to someone.' },
  { key: 'Provide Opinion',     icon: <MessageSquare size={14} />, desc: 'Give your views on a topic in letter form.' },
];

const WRITING_PROMPT_PLACEHOLDERS: Record<string, string> = {
  Academic:
    'The chart below shows… Summarise the information by selecting and reporting the main features, and make comparisons where relevant.',
  'Request Information':
    'You recently purchased a product that was faulty. Write a letter to the company.\nIn your letter:\n• Describe what you bought\n• Explain the problem\n• Say what you would like the company to do',
  'Explain Situation':
    'You are unable to attend a course you have enrolled on. Write a letter to the course director.\nIn your letter:\n• Explain why you enrolled\n• Describe your situation\n• Say what you would like to happen',
  'Provide Opinion':
    'Your local council is planning to build a new sports centre. Write a letter to the council.\nIn your letter:\n• Give your opinion\n• Describe the benefits or drawbacks\n• Suggest an alternative if necessary',
  Opinion:
    'Some people believe that… To what extent do you agree or disagree?\nGive reasons for your answer and include any relevant examples from your own knowledge or experience.',
  Discussion:
    'Some people think that… Others believe that… Discuss both these views and give your own opinion.',
  'Problem & Solution':
    'In many countries… What are the causes of this problem and what measures could be taken to solve it?',
  'Advantages & Disadvantages':
    'In some countries… Do the advantages of this development outweigh the disadvantages?',
  'Two-Part Question':
    'Nowadays… Why is this happening? Do you think this is a positive or negative development?',
};

// ─── UID helper ───────────────────────────────────────────────────────────────

let _ctr = 0;
const uid = (p: string) => `${p}_${++_ctr}_${Date.now() % 1e6}`;

// ─── Factory helpers ──────────────────────────────────────────────────────────

const makeQuestion = (type: string): TestQuestion => ({
  id: uid('q'),
  type,
  text: '',
  options: ['MCQ', 'Multi-select'].includes(type) ? ['', '', '', ''] : [],
  answer: '',
  matchingPairs: type === 'Matching' ? [{ key: '', value: '' }] : [],
  wordLimit: ['Short Answer', 'Sentence Completion'].includes(type) ? 50 : 0,
  correctAnswer: '',
  prepTime: type.startsWith('Part') ? 60 : 0,
  recordingLimit: type.startsWith('Part') ? 120 : 0,
  multiSelectAnswers: [],
});

const makeSection = (moduleType: ModuleType, locked: boolean): TestSection => ({
  id: uid('sec'),
  moduleType,
  locked,
  passage: '',
  audioFile: null,
  audioFileData: null,
  // Writing fields
  writingTask: 'Task 1',
  task1Track: 'Academic',
  task1GeneralType: null,
  task2Type: null,
  writingPromptText: '',
  chartImage: null,
  chartImageData: null,
  minWordLimit: 150,
  // Speaking
  cueCard: '',
  questions: [],
  collapsed: false,
});

const buildSections = (testType: TestType, mode: TestMode, singleMod: ModuleType): TestSection[] => {
  if (mode === 'full') {
    const mods = testType === 'PTE' ? PTE_FULL_MODULES : IELTS_FULL_MODULES;
    return mods.map(m => makeSection(m, true));
  }
  return [makeSection(singleMod, false)];
};

// ─── Small shared form atoms ──────────────────────────────────────────────────

const Label = ({ children }: { children: React.ReactNode }) => (
  <label className="block text-xs font-semibold text-gray-600 mb-1 uppercase tracking-wide">{children}</label>
);

const Inp = ({ value, onChange, placeholder, type = 'text', className = '' }: {
  value: string | number; onChange: (v: string) => void;
  placeholder?: string; type?: string; className?: string;
}) => (
  <input
    type={type} value={value} onChange={e => onChange(e.target.value)}
    placeholder={placeholder}
    className={`w-full px-3 py-2 border border-gray-200 rounded-lg text-sm outline-none focus:border-blue-400 transition-colors ${className}`}
  />
);

const Textarea = ({ value, onChange, placeholder, rows = 3 }: {
  value: string; onChange: (v: string) => void; placeholder?: string; rows?: number;
}) => (
  <textarea
    rows={rows} value={value} onChange={e => onChange(e.target.value)}
    placeholder={placeholder}
    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm outline-none focus:border-blue-400 resize-none transition-colors"
  />
);

// ─── SelectCard ───────────────────────────────────────────────────────────────

function SelectCard({
  active, color, icon, label, desc, onClick,
}: {
  active: boolean; color: string; icon: React.ReactNode;
  label: string; desc: string; onClick: () => void;
}) {
  return (
    <button
      type="button" onClick={onClick}
      className="text-left rounded-xl border-2 p-3 transition-all w-full"
      style={active ? { borderColor: color, background: color + '10' } : { borderColor: '#E5E7EB', background: 'white' }}
    >
      <div className="flex items-center gap-2 mb-0.5" style={{ color: active ? color : '#374151' }}>
        {icon}
        <span className="text-xs font-semibold">{label}</span>
      </div>
      <p className="text-xs text-gray-400 leading-snug">{desc}</p>
    </button>
  );
}

// ─── WritingTaskPanel ─────────────────────────────────────────────────────────
// All writing-specific UI, scoped to one section

function WritingTaskPanel({
  section, color, onUpdate,
}: {
  section: TestSection;
  color: string;
  onUpdate: (id: string, u: Partial<TestSection>) => void;
}) {
  const chartRef = useRef<HTMLInputElement>(null);
  const [promptOpen, setPromptOpen] = useState(true);

  const up = (u: Partial<TestSection>) => onUpdate(section.id, u);

  const isTask1   = section.writingTask === 'Task 1';
  const isTask2   = section.writingTask === 'Task 2';
  const isAcademic = isTask1 && section.task1Track === 'Academic';
  const isGeneral  = isTask1 && section.task1Track === 'General Training';

  const wordLimitMin     = isTask2 ? 250 : 150;
  const wordLimitDefault = isTask2 ? 250 : 150;
  const wordLimitMax     = isTask2 ? 400 : 250;

  const promptPlaceholder = isTask2
    ? WRITING_PROMPT_PLACEHOLDERS[section.task2Type ?? 'Opinion']
    : isAcademic
    ? WRITING_PROMPT_PLACEHOLDERS['Academic']
    : WRITING_PROMPT_PLACEHOLDERS[section.task1GeneralType ?? 'Request Information'];

  return (
    <div className="space-y-5">

      {/* Task 1 / Task 2 toggle */}
      <div>
        <Label>Writing Task</Label>
        <div className="flex items-center gap-2 flex-wrap">
          {(['Task 1', 'Task 2'] as WritingTask[]).map(t => (
            <button
              key={t} type="button"
              onClick={() => up({
                writingTask: t,
                task1Track: 'Academic',
                task1GeneralType: null,
                task2Type: null,
                writingPromptText: '',
                chartImage: null,
                chartImageData: null,
                minWordLimit: t === 'Task 2' ? 250 : 150,
              })}
              className="px-4 py-1.5 rounded-full border text-xs font-semibold transition-all"
              style={section.writingTask === t
                ? { borderColor: color, background: color + '18', color }
                : { borderColor: '#E5E7EB', color: '#6B7280', background: 'white' }}
            >
              {t}
            </button>
          ))}
          <span className="ml-auto text-xs text-gray-400 flex items-center gap-1">
            <Info size={12} /> Min {wordLimitMin} words
          </span>
        </div>
      </div>

      {/* ─── TASK 1 branch ─────────────────────────────────────────── */}
      {isTask1 && (
        <>
          {/* Academic / General Training */}
          <div>
            <Label>Task 1 Track</Label>
            <div className="grid grid-cols-2 gap-3">
              <SelectCard
                active={section.task1Track === 'Academic'} color={color}
                icon={<BarChart2 size={14} />}
                label="Academic"
                desc="Describe a visual — chart, graph, table, or diagram."
                onClick={() => up({ task1Track: 'Academic', task1GeneralType: null, writingPromptText: '' })}
              />
              <SelectCard
                active={section.task1Track === 'General Training'} color={color}
                icon={<BookOpenIcon size={14} />}
                label="General Training"
                desc="Write a letter — formal, semi-formal, or informal."
                onClick={() => up({
                  task1Track: 'General Training',
                  task1GeneralType: 'Request Information',
                  chartImage: null, chartImageData: null,
                  writingPromptText: '',
                })}
              />
            </div>
          </div>

          {/* Academic: chart upload */}
          {isAcademic && (
            <div>
              <Label>Chart / Visual *</Label>
              <div
                className="border-2 border-dashed rounded-xl p-5 flex flex-col items-center gap-2 cursor-pointer transition-colors"
                style={section.chartImage
                  ? { borderColor: color, background: color + '08' }
                  : { borderColor: '#E5E7EB', background: 'white' }}
                onClick={() => chartRef.current?.click()}
              >
                <input
                  ref={chartRef} type="file" accept="image/*" className="hidden"
                  onChange={e => {
                    const f = e.target.files?.[0];
                    if (f) up({ chartImage: f.name, chartImageData: f });
                  }}
                />
                {section.chartImage ? (
                  <>
                    <ImageIcon size={22} style={{ color }} />
                    <span className="text-xs font-medium" style={{ color }}>{section.chartImage}</span>
                    <button
                      className="text-xs text-gray-400 hover:text-red-500 transition-colors"
                      onClick={e => { e.stopPropagation(); up({ chartImage: null, chartImageData: null }); }}
                    >
                      Remove
                    </button>
                  </>
                ) : (
                  <>
                    <Upload size={22} className="text-gray-300" />
                    <span className="text-xs text-gray-500 font-medium">Upload chart, graph, table or diagram</span>
                    <span className="text-xs text-gray-400">PNG, JPG, SVG accepted</span>
                    <span className="text-xs text-red-400 font-medium mt-1">Required for Academic Task 1</span>
                  </>
                )}
              </div>
            </div>
          )}

          {/* General Training: letter type
          {isGeneral && (
            <div>
              <Label>Letter Type</Label>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
                {TASK1_GENERAL_TYPES.map(({ key, icon, desc }) => (
                  <SelectCard
                    key={key}
                    active={section.task1GeneralType === key} color={color}
                    icon={icon} label={key} desc={desc}
                    onClick={() => up({ task1GeneralType: key, writingPromptText: '' })}
                  />
                ))}
              </div>
            </div>
          )} */}
        </>
      )}

      {/* ─── TASK 2 branch ─────────────────────────────────────────── */}
      {/* {isTask2 && (
        <div>
          <Label>Essay Type</Label>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
            {TASK2_TYPES.map(({ key, icon, desc }) => (
              <SelectCard
                key={key}
                active={section.task2Type === key} color={color}
                icon={icon} label={key} desc={desc}
                onClick={() => up({ task2Type: key, writingPromptText: '' })}
              />
            ))}
          </div>
        </div>
      )} */}

      {/* ─── Word Limit ─────────────────────────────────────────────── */}
      <div>
        <Label>Minimum Word Limit</Label>
        <div className="flex items-center gap-3">
          <input
            type="range"
            min={wordLimitMin} max={wordLimitMax} step={25}
            value={section.minWordLimit || wordLimitDefault}
            onChange={e => up({ minWordLimit: Number(e.target.value) })}
            className="flex-1"
            style={{ accentColor: color }}
          />
          <div
            className="text-sm font-bold px-3 py-1 rounded-lg min-w-[72px] text-center"
            style={{ background: color + '15', color }}
          >
            {section.minWordLimit || wordLimitDefault} w
          </div>
        </div>
        <p className="text-xs text-gray-400 mt-1">
          IELTS recommends at least {wordLimitDefault} words for {section.writingTask}.
        </p>
      </div>

    </div>
  );
}

// ─── Writing question type helpers ───────────────────────────────────────────

const WRITING_Q_ICONS: Record<string, React.ReactNode> = {
  'Chart Description':          <BarChart2 size={13} />,
  'Request Information':        <AlignLeft size={13} />,
  'Explain Situation':          <FileText size={13} />,
  'Provide Opinion':            <MessageSquare size={13} />,
  'Opinion':                    <ThumbsUp size={13} />,
  'Discussion':                 <MessageSquare size={13} />,
  'Problem & Solution':         <Lightbulb size={13} />,
  'Advantages & Disadvantages': <Scale size={13} />,
  'Two-Part Question':          <HelpCircle size={13} />,
};

const WRITING_Q_PLACEHOLDER: Record<string, string> = {
  'Chart Description':
    'The chart below shows… Summarise the information by selecting and reporting the main features.',
  'Request Information':
    'You recently purchased a product that was faulty.\nIn your letter:\n• Describe what you bought\n• Explain the problem\n• Say what you would like the company to do',
  'Explain Situation':
    'You are unable to attend a course you enrolled on.\nIn your letter:\n• Explain why you enrolled\n• Describe your situation\n• Say what you would like to happen',
  'Provide Opinion':
    'Your local council is planning to build a new sports centre.\nIn your letter:\n• Give your opinion\n• Describe the benefits or drawbacks\n• Suggest an alternative if necessary',
  'Opinion':
    'Some people believe that… To what extent do you agree or disagree?\nGive reasons and include relevant examples.',
  'Discussion':
    'Some people think… Others believe… Discuss both views and give your own opinion.',
  'Problem & Solution':
    'In many countries… What are the causes of this problem and what measures could be taken to solve it?',
  'Advantages & Disadvantages':
    'In some countries… Do the advantages of this development outweigh the disadvantages?',
  'Two-Part Question':
    'Nowadays… Why is this happening? Do you think this is a positive or negative development?',
};

// True for question types that belong to the writing module (no MCQ, TF, etc.)
const WRITING_Q_TYPES = new Set([
  'Chart Description', 'Request Information', 'Explain Situation', 'Provide Opinion',
  'Opinion', 'Discussion', 'Problem & Solution', 'Advantages & Disadvantages', 'Two-Part Question',
]);

// ─── QuestionForm ─────────────────────────────────────────────────────────────

function QuestionForm({ q, sectionId, onUpdate, onRemove, index, sectionColor }: {
  q: TestQuestion; sectionId: string; index: number; sectionColor?: string;
  onUpdate: (sid: string, qid: string, u: Partial<TestQuestion>) => void;
  onRemove: (sid: string, qid: string) => void;
}) {
  const [open, setOpen] = useState(true);
  const up = (u: Partial<TestQuestion>) => onUpdate(sectionId, q.id, u);

  const isWritingQ = WRITING_Q_TYPES.has(q.type);

  const tfOptions = !isWritingQ && q.type.includes('/NG')
    ? (q.type.startsWith('True') ? ['True', 'False', 'Not Given'] : ['Yes', 'No', 'Not Given'])
    : [];

  const color = sectionColor || '#8B5CF6';

  // ── Writing question: just a labelled text field, no extra controls ──
  if (isWritingQ) {
    return (
      <div className="border border-gray-200 rounded-lg overflow-hidden bg-white">
        {/* Header */}
        <div
          className="flex items-center gap-2 px-3 py-2 cursor-pointer hover:bg-gray-50 transition-colors"
          onClick={() => setOpen(!open)}
        >
          <span
            className="w-5 h-5 rounded-full flex items-center justify-center text-xs font-bold text-white"
            style={{ background: color, fontSize: '10px' }}
          >
            {index + 1}
          </span>
          <span
            className="text-xs font-medium px-2 py-0.5 rounded-full flex items-center gap-1"
            style={{ background: color + '15', color }}
          >
            {WRITING_Q_ICONS[q.type]}
            {q.type}
          </span>
          <span className="text-xs text-gray-400 truncate flex-1">{q.text || '(no prompt yet)'}</span>
          <button
            onClick={e => { e.stopPropagation(); onRemove(sectionId, q.id); }}
            className="text-red-400 hover:text-red-600 p-1 rounded transition-colors"
          >
            <X size={13} />
          </button>
          {open ? <ChevronUp size={14} className="text-gray-400" /> : <ChevronDown size={14} className="text-gray-400" />}
        </div>

        {/* Body — just the prompt textarea */}
        {open && (
          <div className="px-3 pb-3 pt-3 border-t border-gray-100 space-y-2">
            <Label>
              {q.type === 'Chart Description' ? 'Task Instructions / Prompt' : 'Letter / Essay Prompt'}
            </Label>
            <Textarea
              value={q.text}
              onChange={v => up({ text: v })}
              placeholder={WRITING_Q_PLACEHOLDER[q.type] || 'Enter prompt text…'}
              rows={4}
            />
            <p className="text-xs text-gray-400 flex items-center gap-1">
              <Info size={11} />
              Students will see this prompt when attempting the {q.type === 'Chart Description' ? 'chart description' : q.type === 'Opinion' || q.type === 'Discussion' || q.type === 'Problem & Solution' || q.type === 'Advantages & Disadvantages' || q.type === 'Two-Part Question' ? 'essay' : 'letter'} task.
            </p>
          </div>
        )}
      </div>
    );
  }

  // ── Standard question (Reading / Listening / Speaking) ──
  return (
    <div className="border border-gray-200 rounded-lg overflow-hidden bg-white">
      <div
        className="flex items-center gap-2 px-3 py-2 cursor-pointer hover:bg-gray-50 transition-colors"
        onClick={() => setOpen(!open)}
      >
        <span
          className="w-5 h-5 rounded-full flex items-center justify-center text-xs font-bold text-white"
          style={{ background: '#6B7280', fontSize: '10px' }}
        >
          {index + 1}
        </span>
        <span className="text-xs font-medium px-2 py-0.5 rounded-full" style={{ background: '#F3F4F6', color: '#374151' }}>
          {q.type}
        </span>
        <span className="text-xs text-gray-400 truncate flex-1">{q.text || '(no text)'}</span>
        <button
          onClick={e => { e.stopPropagation(); onRemove(sectionId, q.id); }}
          className="text-red-400 hover:text-red-600 p-1 rounded transition-colors"
        >
          <X size={13} />
        </button>
        {open ? <ChevronUp size={14} className="text-gray-400" /> : <ChevronDown size={14} className="text-gray-400" />}
      </div>

      {open && (
        <div className="px-3 pb-3 space-y-3 border-t border-gray-100">
          <div className="pt-2">
            <Label>Question / Instructions</Label>
            <Textarea value={q.text} onChange={v => up({ text: v })} placeholder="Enter question text..." rows={2} />
          </div>

          {q.type === 'MCQ' && (
            <div className="space-y-2">
              <Label>Options</Label>
              {q.options.map((opt, oi) => (
                <div key={oi} className="flex gap-2 items-center">
                  <span className="text-xs text-gray-400 w-4">{String.fromCharCode(65 + oi)}.</span>
                  <Inp
                    value={opt}
                    onChange={v => { const opts = [...q.options]; opts[oi] = v; up({ options: opts }); }}
                    placeholder={`Option ${String.fromCharCode(65 + oi)}`}
                  />
                </div>
              ))}
              <div>
                <Label>Correct Answer</Label>
                <select
                  value={q.answer} onChange={e => up({ answer: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm outline-none focus:border-blue-400"
                >
                  <option value="">-- Select --</option>
                  {q.options.map((opt, oi) => opt && (
                    <option key={oi} value={opt}>{String.fromCharCode(65 + oi)}. {opt}</option>
                  ))}
                </select>
              </div>
            </div>
          )}

          {q.type === 'Multi-select' && (
            <div className="space-y-2">
              <Label>Options (check correct answers)</Label>
              {q.options.map((opt, oi) => (
                <div key={oi} className="flex gap-2 items-center">
                  <input
                    type="checkbox" checked={q.multiSelectAnswers.includes(opt)}
                    onChange={e => {
                      const msa = e.target.checked
                        ? [...q.multiSelectAnswers, opt]
                        : q.multiSelectAnswers.filter(x => x !== opt);
                      up({ multiSelectAnswers: msa });
                    }}
                    className="accent-blue-500"
                  />
                  <Inp
                    value={opt}
                    onChange={v => { const opts = [...q.options]; opts[oi] = v; up({ options: opts }); }}
                    placeholder={`Option ${oi + 1}`}
                  />
                </div>
              ))}
              <button onClick={() => up({ options: [...q.options, ''] })} className="text-xs text-blue-500 hover:underline">
                + Add Option
              </button>
            </div>
          )}

          {tfOptions.length > 0 && (
            <div>
              <Label>Correct Answer</Label>
              <div className="flex gap-2">
                {tfOptions.map(opt => (
                  <button
                    key={opt} onClick={() => up({ answer: opt })}
                    className="flex-1 py-1.5 rounded-lg border text-xs font-medium transition-all"
                    style={q.answer === opt
                      ? { borderColor: '#007BFF', background: '#007BFF15', color: '#007BFF' }
                      : { borderColor: '#E5E7EB', color: '#6B7280' }}
                  >
                    {opt}
                  </button>
                ))}
              </div>
            </div>
          )}

          {q.type === 'Matching' && (
            <div>
              <Label>Match Pairs</Label>
              <div className="space-y-2">
                {q.matchingPairs.map((pair, pi) => (
                  <div key={pi} className="flex gap-2 items-center">
                    <Inp
                      value={pair.key}
                      onChange={v => {
                        const pairs = q.matchingPairs.map((p, i) => i === pi ? { ...p, key: v } : p);
                        up({ matchingPairs: pairs });
                      }}
                      placeholder="Left column" className="flex-1"
                    />
                    <ArrowRight size={14} className="text-gray-300 shrink-0" />
                    <Inp
                      value={pair.value}
                      onChange={v => {
                        const pairs = q.matchingPairs.map((p, i) => i === pi ? { ...p, value: v } : p);
                        up({ matchingPairs: pairs });
                      }}
                      placeholder="Right column" className="flex-1"
                    />
                    {q.matchingPairs.length > 1 && (
                      <button
                        onClick={() => up({ matchingPairs: q.matchingPairs.filter((_, i) => i !== pi) })}
                        className="text-red-400 hover:text-red-600"
                      >
                        <X size={13} />
                      </button>
                    )}
                  </div>
                ))}
                <button
                  onClick={() => up({ matchingPairs: [...q.matchingPairs, { key: '', value: '' }] })}
                  className="text-xs text-blue-500 hover:underline"
                >
                  + Add Pair
                </button>
              </div>
            </div>
          )}

          {['Short Answer', 'Sentence Completion', 'Form Fill'].includes(q.type) && (
            <div className="grid grid-cols-2 gap-3">
              <div>
                <Label>Word Limit</Label>
                <div className="flex items-center gap-2">
                  <input
                    type="range" min={5} max={200} step={5} value={q.wordLimit}
                    onChange={e => up({ wordLimit: Number(e.target.value) })}
                    className="flex-1 accent-blue-500"
                  />
                  <span className="text-xs text-gray-500 w-12 text-right">{q.wordLimit}w</span>
                </div>
              </div>
              <div>
                <Label>Correct Answer / Key</Label>
                <Inp value={q.correctAnswer} onChange={v => up({ correctAnswer: v })} placeholder="Model answer..." />
              </div>
            </div>
          )}

          {q.type.startsWith('Part') && (
            <div className="grid grid-cols-2 gap-3">
              <div>
                <Label>Prep Time (seconds)</Label>
                <div className="flex items-center gap-2">
                  <input
                    type="range" min={0} max={120} step={15} value={q.prepTime}
                    onChange={e => up({ prepTime: Number(e.target.value) })}
                    className="flex-1 accent-amber-500"
                  />
                  <span className="text-xs text-gray-500 w-10 text-right">{q.prepTime}s</span>
                </div>
              </div>
              <div>
                <Label>Recording Limit (seconds)</Label>
                <div className="flex items-center gap-2">
                  <input
                    type="range" min={30} max={300} step={15} value={q.recordingLimit}
                    onChange={e => up({ recordingLimit: Number(e.target.value) })}
                    className="flex-1 accent-amber-500"
                  />
                  <span className="text-xs text-gray-500 w-10 text-right">{q.recordingLimit}s</span>
                </div>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

// ─── SectionPanel ─────────────────────────────────────────────────────────────

function SectionPanel({
  section, index, onUpdate, onRemove, onAddQuestion, onRemoveQuestion, onUpdateQuestion, canRemove,
}: {
  section: TestSection; index: number; canRemove: boolean;
  onUpdate: (id: string, u: Partial<TestSection>) => void;
  onRemove: (id: string) => void;
  onAddQuestion: (sid: string, type: string) => void;
  onRemoveQuestion: (sid: string, qid: string) => void;
  onUpdateQuestion: (sid: string, qid: string, u: Partial<TestQuestion>) => void;
}) {
  const [addingQ, setAddingQ] = useState(false);
  const [selectedQType, setSelectedQType] = useState('');
  const audioRef = useRef<HTMLInputElement>(null);

  const color  = MODULE_COLOR[section.moduleType] || '#007BFF';
  const isWriting = section.moduleType === 'Writing' || section.moduleType === 'Speaking & Writing';

  // Dynamic question types: for writing, derived from current writing config
  const qTypes = getQuestionTypes(section);

  // Task 1 Academic: no type picker — "Add Question" directly creates a Chart Description question
  const isAcademicTask1 = isWriting && section.writingTask === 'Task 1' && section.task1Track === 'Academic';

  const handleAddQ = () => {
    if (!selectedQType) return;
    onAddQuestion(section.id, selectedQType);
    setAddingQ(false);
    setSelectedQType('');
  };

  const handleAddAcademicQ = () => {
    onAddQuestion(section.id, 'Chart Description');
  };

  // Label shown on the "Add Question" picker
  const addQLabel = isWriting
    ? section.writingTask === 'Task 1'
      ? section.task1Track === 'General Training'
        ? 'Select Letter Type'
        : 'Add Prompt'
      : 'Select Essay Type'
    : 'Select Question Type';

  return (
    <div className="rounded-xl border border-gray-200 overflow-hidden shadow-sm" style={{ borderLeft: `4px solid ${color}` }}>
      {/* Header */}
      <div className="flex items-center gap-3 px-4 py-3 bg-white">
        <div className="w-7 h-7 rounded-lg flex items-center justify-center text-white" style={{ background: color }}>
          {MODULE_ICON[section.moduleType]}
        </div>
        <div>
          <div className="flex items-center gap-2">
            <span className="text-sm font-semibold text-gray-800">Section {index + 1} — {section.moduleType}</span>
            {section.locked && (
              <span className="inline-flex items-center gap-1 text-xs px-1.5 py-0.5 rounded text-gray-500 bg-gray-100">
                <Lock size={10} /> Locked
              </span>
            )}
          </div>
          <div className="text-xs text-gray-400">{section.questions.length} question{section.questions.length !== 1 ? 's' : ''}</div>
        </div>
        <div className="ml-auto flex items-center gap-2">
          {canRemove && !section.locked && (
            <button
              onClick={() => onRemove(section.id)}
              className="text-red-400 hover:text-red-600 p-1.5 rounded-lg hover:bg-red-50 transition-colors"
            >
              <Trash2 size={14} />
            </button>
          )}
          <button
            onClick={() => onUpdate(section.id, { collapsed: !section.collapsed })}
            className="text-gray-400 hover:text-gray-600 p-1.5 rounded-lg hover:bg-gray-100 transition-colors"
          >
            {section.collapsed ? <ChevronDown size={16} /> : <ChevronUp size={16} />}
          </button>
        </div>
      </div>

      {/* Body */}
      {!section.collapsed && (
        <div className="border-t border-gray-100 px-4 py-4 bg-gray-50/50 space-y-4">

          {/* Writing: full WritingTaskPanel */}
          {isWriting && (
            <WritingTaskPanel section={section} color={color} onUpdate={onUpdate} />
          )}

          {/* Reading: passage */}
          {section.moduleType === 'Reading' && (
            <div>
              <Label>Reading Passage</Label>
              <Textarea
                value={section.passage}
                onChange={v => onUpdate(section.id, { passage: v })}
                placeholder="Paste or type the reading passage here..."
                rows={5}
              />
            </div>
          )}

          {/* Listening: audio upload */}
          {section.moduleType === 'Listening' && (
            <div>
              <Label>Audio File *</Label>
              <div
                className="border-2 border-dashed rounded-lg p-4 flex flex-col items-center gap-2 cursor-pointer transition-colors"
                style={section.audioFile
                  ? { borderColor: '#28A745', background: '#28A74508' }
                  : { borderColor: '#E5E7EB', background: 'white' }}
                onClick={() => audioRef.current?.click()}
              >
                <input
                  ref={audioRef} type="file" accept="audio/*" className="hidden"
                  onChange={e => {
                    const f = e.target.files?.[0];
                    if (f) onUpdate(section.id, { audioFile: f.name, audioFileData: f });
                  }}
                />
                {section.audioFile ? (
                  <>
                    <Volume2 size={20} style={{ color: '#28A745' }} />
                    <span className="text-xs font-medium text-green-700">{section.audioFile}</span>
                    <button
                      className="text-xs text-gray-400 hover:text-red-500"
                      onClick={e => { e.stopPropagation(); onUpdate(section.id, { audioFile: null }); }}
                    >
                      Remove
                    </button>
                  </>
                ) : (
                  <>
                    <Upload size={20} className="text-gray-400" />
                    <span className="text-xs text-gray-500">Click to upload audio (MP3, WAV)</span>
                    <span className="text-xs text-red-400 font-medium">Required to publish</span>
                  </>
                )}
              </div>
            </div>
          )}

          {/* Speaking: cue card */}
          {section.moduleType === 'Speaking' && (
            <div>
              <Label>Part 2 Cue Card Content</Label>
              <Textarea
                value={section.cueCard}
                onChange={v => onUpdate(section.id, { cueCard: v })}
                placeholder={"Describe a person who has influenced you. You should say:\n• Who this person is\n• How you met them\n• What qualities they have"}
                rows={4}
              />
            </div>
          )}

          {/* Questions list */}
          <div>
            <Label>
              {isWriting ? 'Prompts / Tasks' : `Questions (${section.questions.length})`}
              {isWriting && ` (${section.questions.length})`}
            </Label>
            <div className="space-y-2">
              {section.questions.map((q, qi) => (
                <QuestionForm
                  key={q.id} q={q} index={qi} sectionId={section.id}
                  sectionColor={color}
                  onUpdate={onUpdateQuestion} onRemove={onRemoveQuestion}
                />
              ))}
            </div>

            {/* ── Add question area ── */}

            {/* Task 1 Academic: single button, no picker */}
            {isAcademicTask1 && (
              <button
                onClick={handleAddAcademicQ}
                className="mt-3 w-full py-2 border-2 border-dashed rounded-lg text-xs font-medium flex items-center justify-center gap-1.5 transition-colors hover:opacity-80"
                style={{ borderColor: color + '60', color }}
              >
                <Plus size={13} /> Add Chart Description Prompt
              </button>
            )}

            {/* Task 1 General / Task 2 / non-writing: type picker */}
            {!isAcademicTask1 && (
              <>
                {addingQ ? (
                  <div className="mt-3 p-3 bg-white border border-gray-200 rounded-lg space-y-2">
                    <Label>{addQLabel}</Label>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-1.5">
                      {qTypes.map(t => {
                        const icon = isWriting ? WRITING_Q_ICONS[t] : null;
                        return (
                          <button
                            key={t} onClick={() => setSelectedQType(t)}
                            className="text-xs px-3 py-2 rounded-lg border transition-all text-left flex items-center gap-2"
                            style={selectedQType === t
                              ? { borderColor: color, background: color + '15', color }
                              : { borderColor: '#E5E7EB', color: '#374151' }}
                          >
                            {icon && <span style={{ color: selectedQType === t ? color : '#9CA3AF' }}>{icon}</span>}
                            {t}
                          </button>
                        );
                      })}
                    </div>
                    <div className="flex gap-2 pt-1">
                      <button
                        onClick={handleAddQ} disabled={!selectedQType}
                        className="px-4 py-1.5 rounded-lg text-xs font-medium text-white transition-opacity disabled:opacity-40"
                        style={{ background: color }}
                      >
                        Add
                      </button>
                      <button
                        onClick={() => { setAddingQ(false); setSelectedQType(''); }}
                        className="px-3 py-1.5 rounded-lg text-xs text-gray-500 border border-gray-200 hover:bg-gray-50"
                      >
                        Cancel
                      </button>
                    </div>
                  </div>
                ) : (
                  <button
                    onClick={() => setAddingQ(true)}
                    className="mt-3 w-full py-2 border-2 border-dashed rounded-lg text-xs font-medium flex items-center justify-center gap-1.5 transition-colors hover:opacity-80"
                    style={{ borderColor: color + '60', color }}
                  >
                    <Plus size={13} />
                    {isWriting
                      ? section.writingTask === 'Task 1'
                        ? 'Add Letter Prompt'
                        : 'Add Essay Prompt'
                      : 'Add Question'}
                  </button>
                )}
              </>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

// ─── Main TestBuilder ─────────────────────────────────────────────────────────

export function TestBuilder() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const editId = searchParams.get('edit');
  const isEditMode = editId !== null;
  const { loadMockForEdit, saveMockFromBuilder } = useMocks();

  const [step, setStep]               = useState(1);
  const [saving, setSaving]           = useState(false);
  const [editLoading, setEditLoading] = useState(!!editId);

  const [title, setTitle]             = useState('');
  const [testType, setTestType]       = useState<TestType>('IELTS');
  const [difficulty, setDifficulty]   = useState<Difficulty>('Medium');
  const [duration, setDuration]       = useState(60);
  const [mode, setMode]               = useState<TestMode>('full');
  const [singleModule, setSingleModule] = useState<ModuleType>('Reading');
  const [sections, setSections]       = useState<TestSection[]>(() => buildSections('IELTS', 'full', 'Reading'));

  // ── Edit mode loading ──
  useEffect(() => {
    if (!editId) return;
    let cancelled = false;
    (async () => {
      setEditLoading(true);
      try {
        const state = await loadMockForEdit(editId);
        if (cancelled) return;
        if (!state) { toast.error('Mock not found.'); navigate('/mocks'); return; }
        setTitle(state.title);
        setTestType(state.testType as TestType);
        setDifficulty(state.difficulty as Difficulty);
        setDuration(state.duration);
        setMode(state.mode as TestMode);
        setSingleModule(state.singleModule as ModuleType);
        setSections(state.sections as TestSection[]);
        setStep(2);
      } catch (err: unknown) {
        if (!cancelled) {
          toast.error(err instanceof Error ? err.message : 'Failed to load test');
          navigate('/mocks');
        }
      } finally {
        if (!cancelled) setEditLoading(false);
      }
    })();
    return () => { cancelled = true; };
  }, [editId, loadMockForEdit, navigate]);

  // ── Handlers ──
  const handleTestTypeChange = (t: TestType) => {
    setTestType(t);
    const newMode = t === 'PTE' ? 'full' : mode;
    setMode(newMode);
    setSections(buildSections(t, newMode, singleModule));
    toast.info(`Switched to ${t} — sections re-initialised.`);
  };

  const handleModeChange = (m: TestMode) => {
    setMode(m);
    setSections(buildSections(testType, m, singleModule));
  };

  const handleSingleModuleChange = (m: ModuleType) => {
    setSingleModule(m);
    setSections(buildSections(testType, 'single', m));
  };

  const updateSection   = (id: string, u: Partial<TestSection>) =>
    setSections(prev => prev.map(s => s.id === id ? { ...s, ...u } : s));

  const addSection      = () =>
    setSections(prev => [...prev, makeSection(singleModule, false)]);

  const removeSection   = (id: string) => {
    if (sections.length <= 1) { toast.error('At least one section is required.'); return; }
    setSections(prev => prev.filter(s => s.id !== id));
  };

  const addQuestion     = (sid: string, type: string) => {
    setSections(prev => prev.map(s =>
      s.id === sid ? { ...s, questions: [...s.questions, makeQuestion(type)] } : s
    ));
    toast.success(`${type} question added.`);
  };

  const removeQuestion  = (sid: string, qid: string) =>
    setSections(prev => prev.map(s =>
      s.id === sid ? { ...s, questions: s.questions.filter(q => q.id !== qid) } : s
    ));

  const updateQuestion  = (sid: string, qid: string, u: Partial<TestQuestion>) =>
    setSections(prev => prev.map(s =>
      s.id === sid ? { ...s, questions: s.questions.map(q => q.id === qid ? { ...q, ...u } : q) } : s
    ));

  // ── Validation ──
  const getErrors = () => {
    const errors: { type: 'error' | 'warning'; msg: string }[] = [];
    if (!title.trim()) errors.push({ type: 'error', msg: 'Test title is required.' });
    if (sections.length === 0) errors.push({ type: 'error', msg: 'Add at least one section.' });

    sections.forEach((sec, i) => {
      const lbl = `Section ${i + 1} (${sec.moduleType})`;
      const isWriting = sec.moduleType === 'Writing' || sec.moduleType === 'Speaking & Writing';

      if (sec.moduleType === 'Listening' && !sec.audioFile && !sec.audioFileData)
        errors.push({ type: 'error', msg: `${lbl}: Audio file is required to publish.` });

      if (isWriting) {
        // Task 1 Academic: chart required
        if (sec.writingTask === 'Task 1' && sec.task1Track === 'Academic' && !sec.chartImage && !sec.chartImageData)
          errors.push({ type: 'error', msg: `${lbl}: Chart/visual is required for Academic Task 1.` });

        // Word limit
        const wlMin = sec.writingTask === 'Task 2' ? 250 : 150;
        if (!sec.minWordLimit || sec.minWordLimit < wlMin)
          errors.push({ type: 'error', msg: `${lbl}: ${sec.writingTask} word limit must be ≥ ${wlMin} words.` });
      }

      if (sec.questions.length === 0)
        errors.push({ type: 'warning', msg: `${lbl}: No questions added yet.` });

      sec.questions.forEach((q, qi) => {
        if (!q.text.trim())
          errors.push({ type: 'warning', msg: `${lbl} Q${qi + 1}: Question text is empty.` });
      });
    });
    return errors;
  };

  const allErrors      = getErrors();
  const blockingErrors = allErrors.filter(e => e.type === 'error');
  const canPublish     = blockingErrors.length === 0 && title.trim() !== '';
  const totalQuestions = sections.reduce((n, s) => n + s.questions.length, 0);

  const currentBuilderState = () => ({ title, testType, difficulty, duration, mode, singleModule, sections });

  const persistTest = async (published: boolean) => {
    setSaving(true);
    try {
      await saveMockFromBuilder(currentBuilderState(), published, isEditMode ? editId! : undefined);
      toast.success(published
        ? `"${title}" ${isEditMode ? 'updated and published' : 'published'}!`
        : `"${title}" saved as draft.`
      );
      navigate('/mocks');
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to save test');
    } finally {
      setSaving(false);
    }
  };

  const handlePublish = () => {
    if (!canPublish) { toast.error(blockingErrors[0]?.msg || 'Fix all errors first.'); return; }
    void persistTest(true);
  };

  const handleDraft = () => {
    if (!title.trim()) { toast.error('Please enter a test title.'); return; }
    void persistTest(false);
  };

  // ── Step renderers ──

  const renderStep1 = () => (
    <div className="space-y-6">
      <div>
        <Label>Test Title *</Label>
        <input
          type="text" value={title} onChange={e => setTitle(e.target.value)}
          placeholder="e.g., IELTS Academic Full Mock – Batch A (May 2026)"
          className="w-full px-3 py-2.5 border border-gray-200 rounded-lg text-sm outline-none focus:border-blue-400 transition-colors"
        />
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div>
          <Label>Test Type *</Label>
          <div className="flex gap-2">
            {(['IELTS', 'PTE'] as TestType[]).map(t => (
              <button
                key={t} onClick={() => handleTestTypeChange(t)}
                className="flex-1 py-2.5 px-3 rounded-lg border-2 text-sm font-medium transition-all"
                style={testType === t
                  ? { borderColor: '#007BFF', background: '#007BFF12', color: '#007BFF' }
                  : { borderColor: '#E5E7EB', background: 'white', color: '#6B7280' }}
              >
                {t}
              </button>
            ))}
          </div>
        </div>
        <div>
          <Label>Difficulty</Label>
          <select
            value={difficulty} onChange={e => setDifficulty(e.target.value as Difficulty)}
            className="w-full px-3 py-2.5 border border-gray-200 rounded-lg text-sm outline-none focus:border-blue-400 bg-white"
          >
            {['Easy', 'Medium', 'Hard'].map(d => <option key={d}>{d}</option>)}
          </select>
        </div>
        <div>
          <Label>Duration — {duration} min</Label>
          <div className="flex items-center gap-2 pt-1.5">
            <input
              type="range" min={10} max={240} step={5} value={duration}
              onChange={e => setDuration(Number(e.target.value))}
              className="flex-1 accent-blue-500"
            />
            <span className="text-xs text-gray-500 w-14 text-right shrink-0">{duration} min</span>
          </div>
        </div>
      </div>
      <div>
        <Label>Test Mode</Label>
        {testType === 'PTE' ? (
          <div className="p-3 rounded-xl border border-blue-200 bg-blue-50 flex items-center gap-2 text-sm text-blue-700">
            <Lock size={14} />
            <span>PTE always runs as <strong>Full Mock</strong>: Speaking &amp; Writing → Reading → Listening</span>
          </div>
        ) : (
          <div className="grid grid-cols-2 gap-3">
            {[
              { k: 'full' as TestMode, label: 'Full Mock Test', desc: 'All 4 modules (R, L, W, S)', icon: <Layers size={18} /> },
              { k: 'single' as TestMode, label: 'Single Module Practice', desc: 'Focus on one module', icon: <FileText size={18} /> },
            ].map(({ k, label, desc, icon }) => (
              <button
                key={k} onClick={() => handleModeChange(k)}
                className="p-4 rounded-xl border-2 text-left transition-all"
                style={mode === k ? { borderColor: '#007BFF', background: '#007BFF08' } : { borderColor: '#E5E7EB', background: 'white' }}
              >
                <div className="flex items-center gap-2 mb-1" style={{ color: mode === k ? '#007BFF' : '#374151' }}>
                  {icon} <span className="text-sm font-semibold">{label}</span>
                </div>
                <p className="text-xs text-gray-400">{desc}</p>
              </button>
            ))}
          </div>
        )}
      </div>
      {mode === 'single' && testType !== 'PTE' && (
        <div>
          <Label>Select Module</Label>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
            {IELTS_SINGLE_MODULES.map(m => (
              <button
                key={m} onClick={() => handleSingleModuleChange(m)}
                className="py-2.5 px-3 rounded-xl border-2 text-xs font-medium flex items-center justify-center gap-1.5 transition-all"
                style={singleModule === m
                  ? { borderColor: MODULE_COLOR[m], background: MODULE_COLOR[m] + '18', color: MODULE_COLOR[m] }
                  : { borderColor: '#E5E7EB', color: '#6B7280' }}
              >
                {MODULE_ICON[m]} {m}
              </button>
            ))}
          </div>
        </div>
      )}
      <div className="p-3 rounded-xl bg-gray-50 border border-gray-100 text-sm text-gray-500 flex items-start gap-2">
        <Info size={15} className="mt-0.5 shrink-0 text-blue-400" />
        <span>
          {testType === 'PTE'
            ? 'PTE sections are pre-structured and locked. Add questions inside each section in Step 2.'
            : mode === 'full'
              ? 'Full Mock creates 4 locked sections: Reading → Listening → Writing → Speaking.'
              : `Single Module creates 1 "${singleModule}" section. You can add more in Step 2.`}
        </span>
      </div>
    </div>
  );

  const renderStep2 = () => (
    <div className="space-y-4">
      <div className="flex items-center gap-4 p-3 rounded-xl bg-white border border-gray-200 flex-wrap">
        <div className="flex items-center gap-2 text-sm">
          <span className="px-2 py-0.5 rounded-full text-xs font-semibold text-white" style={{ background: '#007BFF' }}>{testType}</span>
          <span className="text-gray-500">{mode === 'full' ? 'Full Mock' : `Single: ${singleModule}`}</span>
        </div>
        <div className="h-4 w-px bg-gray-200" />
        <span className="text-xs text-gray-500">{sections.length} section{sections.length !== 1 ? 's' : ''}</span>
        <div className="h-4 w-px bg-gray-200" />
        <span className="text-xs text-gray-500">{totalQuestions} question{totalQuestions !== 1 ? 's' : ''}</span>
        <div className="h-4 w-px bg-gray-200" />
        <span className="text-xs text-gray-500">{duration} min</span>
      </div>
      <div className="space-y-3">
        {sections.map((sec, i) => (
          <SectionPanel
            key={sec.id} section={sec} index={i} canRemove={sections.length > 1}
            onUpdate={updateSection} onRemove={removeSection}
            onAddQuestion={addQuestion} onRemoveQuestion={removeQuestion} onUpdateQuestion={updateQuestion}
          />
        ))}
      </div>
      {mode === 'single' && (
        <button
          onClick={addSection}
          className="w-full py-3 border-2 border-dashed rounded-xl flex items-center justify-center gap-2 text-sm text-gray-400 hover:text-blue-500 hover:border-blue-300 transition-colors"
        >
          <Plus size={16} /> Add Another {singleModule} Section
        </button>
      )}
    </div>
  );

  const renderStep3 = () => (
    <div className="space-y-4">
      <div className="p-3 bg-blue-50 border border-blue-100 rounded-xl flex items-start gap-2 text-sm text-blue-700">
        <Info size={15} className="mt-0.5 shrink-0" />
        <span>Every question inherits its parent section's <code className="bg-blue-100 px-1 rounded text-xs">section_id</code> and <code className="bg-blue-100 px-1 rounded text-xs">module_type</code>.</span>
      </div>
      <div className="text-xs font-semibold text-gray-400 uppercase tracking-wide px-1">
        Test: <span className="text-gray-700 normal-case">{title || '(untitled)'}</span>
        &nbsp;·&nbsp;{testType} · {difficulty} · {duration} min
      </div>
      {sections.map((sec, si) => {
        const color = MODULE_COLOR[sec.moduleType] || '#007BFF';
        const isWriting = sec.moduleType === 'Writing' || sec.moduleType === 'Speaking & Writing';
        return (
          <div key={sec.id} className="rounded-xl border border-gray-200 overflow-hidden">
            <div
              className="px-4 py-3 flex items-center gap-3 flex-wrap"
              style={{ background: color + '12', borderBottom: `1px solid ${color}30` }}
            >
              <div className="w-6 h-6 rounded-lg flex items-center justify-center text-white" style={{ background: color }}>
                {MODULE_ICON[sec.moduleType]}
              </div>
              <span className="text-sm font-semibold" style={{ color }}>Section {si + 1} — {sec.moduleType}</span>
              <span className="text-xs font-mono px-2 py-0.5 rounded bg-white border text-gray-500">
                section_id: <span className="text-purple-600">{sec.id}</span>
              </span>
              <span className="text-xs font-mono px-2 py-0.5 rounded bg-white border text-gray-500">
                module_type: <span style={{ color }}>{sec.moduleType}</span>
              </span>
              {isWriting && (
                <span className="text-xs px-2 py-0.5 rounded bg-white border text-gray-500">
                  {sec.writingTask}
                  {sec.writingTask === 'Task 1'
                    ? ` · ${sec.task1Track}${sec.task1Track === 'General Training' && sec.task1GeneralType ? ` · ${sec.task1GeneralType}` : ''}`
                    : sec.task2Type ? ` · ${sec.task2Type}` : ''}
                </span>
              )}
              {sec.audioFile  && <span className="ml-auto text-xs flex items-center gap-1 text-green-600"><Volume2 size={12} />{sec.audioFile}</span>}
              {sec.chartImage && <span className="ml-auto text-xs flex items-center gap-1 text-purple-600"><ImageIcon size={12} />{sec.chartImage}</span>}
            </div>
            {sec.questions.length === 0 ? (
              <div className="px-4 py-4 text-sm text-gray-400 flex items-center gap-2">
                <AlertTriangle size={14} className="text-amber-400" /> No questions in this section
              </div>
            ) : (
              <div className="divide-y divide-gray-100">
                {sec.questions.map((q, qi) => (
                  <div key={q.id} className="px-4 py-2.5 flex items-center gap-3 text-sm hover:bg-gray-50/50">
                    <span className="text-xs text-gray-400 w-5 shrink-0">{qi + 1}.</span>
                    <span className="text-xs font-mono px-2 py-0.5 rounded bg-purple-50 text-purple-600">{q.type}</span>
                    <span className="text-gray-700 text-xs truncate flex-1">{q.text || <em className="text-gray-300">(no text)</em>}</span>
                    <span className="text-xs font-mono text-gray-300 shrink-0">← {sec.id}</span>
                  </div>
                ))}
              </div>
            )}
          </div>
        );
      })}
      <div className="grid grid-cols-3 gap-3 pt-2">
        {[
          { label: 'Total Sections',     value: sections.length,   color: '#007BFF' },
          { label: 'Total Questions',    value: totalQuestions,    color: '#28A745' },
          { label: 'Est. Duration',      value: `${duration} min`, color: '#8B5CF6' },
        ].map(({ label, value, color }) => (
          <div key={label} className="p-3 rounded-xl border border-gray-200 bg-white text-center">
            <div className="text-xl font-bold" style={{ color }}>{value}</div>
            <div className="text-xs text-gray-400 mt-0.5">{label}</div>
          </div>
        ))}
      </div>
    </div>
  );

  const renderStep4 = () => {
    const errors = getErrors();
    const errs   = errors.filter(e => e.type === 'error');
    const warns  = errors.filter(e => e.type === 'warning');
    return (
      <div className="space-y-5">
        {errs.length > 0 && (
          <div className="rounded-xl border border-red-200 bg-red-50 overflow-hidden">
            <div className="px-4 py-2.5 border-b border-red-200 flex items-center gap-2">
              <AlertTriangle size={15} className="text-red-500" />
              <span className="text-sm font-semibold text-red-700">{errs.length} error{errs.length !== 1 ? 's' : ''} — cannot publish</span>
            </div>
            <ul className="px-4 py-3 space-y-1">
              {errs.map((e, i) => (
                <li key={i} className="text-xs text-red-600 flex items-start gap-1.5">
                  <span className="mt-0.5 shrink-0">•</span> {e.msg}
                </li>
              ))}
            </ul>
          </div>
        )}
        {warns.length > 0 && (
          <div className="rounded-xl border border-amber-200 bg-amber-50 overflow-hidden">
            <div className="px-4 py-2.5 border-b border-amber-200 flex items-center gap-2">
              <AlertTriangle size={15} className="text-amber-500" />
              <span className="text-sm font-semibold text-amber-700">{warns.length} warning{warns.length !== 1 ? 's' : ''}</span>
            </div>
            <ul className="px-4 py-3 space-y-1">
              {warns.map((w, i) => (
                <li key={i} className="text-xs text-amber-700 flex items-start gap-1.5">
                  <span className="mt-0.5 shrink-0">•</span> {w.msg}
                </li>
              ))}
            </ul>
          </div>
        )}
        {errors.length >= 0 && (
          <div className="rounded-xl border border-green-200 bg-green-50 p-4 flex items-center gap-3">
            <CheckCircle2 size={20} className="text-green-500 shrink-0" />
            <div>
              <div className="text-sm font-semibold text-green-700">All checks passed — ready to {isEditMode ? 'update' : 'publish'}!</div>
              <div className="text-xs text-green-600 mt-0.5">{isEditMode ? 'Changes will be saved immediately.' : 'Your test will go live immediately.'}</div>
            </div>
          </div>
        )}
        <div className="rounded-xl border border-gray-200 bg-white overflow-hidden">
          <div className="px-4 py-3 border-b border-gray-100 font-semibold text-sm text-gray-800 flex items-center gap-2">
            <Eye size={15} className="text-gray-400" /> Test Summary
          </div>
          <div className="px-4 py-4 grid grid-cols-2 gap-x-8 gap-y-3 text-sm">
            <div><span className="text-gray-400 text-xs">Title</span><div className="font-medium text-gray-800 mt-0.5">{title || '—'}</div></div>
            <div><span className="text-gray-400 text-xs">Test Type</span><div className="font-medium text-gray-800 mt-0.5">{testType}</div></div>
            <div><span className="text-gray-400 text-xs">Mode</span><div className="font-medium text-gray-800 mt-0.5">{mode === 'full' ? 'Full Mock' : `Single: ${singleModule}`}</div></div>
            <div><span className="text-gray-400 text-xs">Difficulty</span><div className="font-medium text-gray-800 mt-0.5">{difficulty}</div></div>
            <div><span className="text-gray-400 text-xs">Duration</span><div className="font-medium text-gray-800 mt-0.5">{duration} minutes</div></div>
            <div><span className="text-gray-400 text-xs">Total Questions</span><div className="font-medium text-gray-800 mt-0.5">{totalQuestions}</div></div>
          </div>
          <div className="px-4 pb-4">
            <div className="text-xs text-gray-400 mb-2">Sections</div>
            <div className="flex flex-wrap gap-2">
              {sections.map(s => {
                const isWriting = s.moduleType === 'Writing' || s.moduleType === 'Speaking & Writing';
                const writingLabel = isWriting
                  ? ` · ${s.writingTask}${s.writingTask === 'Task 1' ? ` ${s.task1Track}` : s.task2Type ? ` ${s.task2Type}` : ''}`
                  : '';
                return (
                  <span
                    key={s.id}
                    className="text-xs px-2.5 py-1 rounded-full font-medium inline-flex items-center gap-1"
                    style={{ background: (MODULE_COLOR[s.moduleType] || '#007BFF') + '18', color: MODULE_COLOR[s.moduleType] || '#007BFF' }}
                  >
                    {MODULE_ICON[s.moduleType]}&nbsp;{s.moduleType}{writingLabel} ({s.questions.length}Q)
                  </span>
                );
              })}
            </div>
          </div>
        </div>
        <div className="flex gap-3">
          <button
            onClick={handleDraft} disabled={saving}
            className="flex items-center gap-2 px-5 py-2.5 rounded-xl border border-gray-200 text-sm font-medium text-gray-600 hover:bg-gray-50 transition-colors disabled:opacity-50"
          >
            {saving ? <Loader2 size={15} className="animate-spin" /> : <Save size={15} />}
            Save as Draft
          </button>
          <button
            onClick={handlePublish} disabled={!canPublish || saving}
            className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl text-sm font-semibold text-white transition-all disabled:opacity-40 disabled:cursor-not-allowed"
            style={{ background: canPublish && !saving ? '#007BFF' : '#9CA3AF' }}
          >
            {saving ? <Loader2 size={15} className="animate-spin" /> : <CheckCircle2 size={15} />}
            {isEditMode ? 'Save & Publish Changes' : 'Publish Test'}
          </button>
        </div>
      </div>
    );
  };

  // ── Loading state ──
  if (editLoading) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center gap-3" style={{ background: '#F5F7FA' }}>
        <Loader2 size={32} className="animate-spin text-blue-500" />
        <p className="text-sm text-gray-500">Loading test…</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen" style={{ background: '#F5F7FA' }}>
      <div className="max-w-4xl mx-auto px-4 py-6">
        {/* Breadcrumb */}
        <div className="mb-6">
          <div className="flex items-center gap-2 text-xs text-gray-400 mb-2">
            <button onClick={() => navigate('/mocks')} className="hover:text-blue-500 transition-colors">Mock Tests</button>
            <ChevronRight size={12} />
            <span className="text-gray-600">{isEditMode ? 'Edit Test' : 'Test Builder'}</span>
          </div>
          <div className="flex items-start justify-between gap-4">
            <div>
              <h1 className="text-gray-900 mb-1">{isEditMode ? 'Edit Test' : 'Unified Test Builder'}</h1>
              <p className="text-sm text-gray-400">
                {isEditMode
                  ? `Editing: "${title || '…'}" — make your changes and publish.`
                  : 'Create multi-module IELTS / PTE tests with dynamic sections and question types.'}
              </p>
            </div>
            {isEditMode && (
              <span
                className="text-xs px-3 py-1.5 rounded-full font-semibold"
                style={{ background: '#F59E0B18', color: '#F59E0B', border: '1px solid #F59E0B30' }}
              >
                ✏️ Edit Mode
              </span>
            )}
          </div>
        </div>

        {/* Step indicator */}
        <div className="flex items-center mb-6 gap-0">
          {STEPS.map((s, i) => {
            const isActive = step === s.n;
            const isDone   = step > s.n;
            return (
              <React.Fragment key={s.n}>
                <div className="flex flex-col items-center min-w-0 flex-1">
                  <div
                    className="w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold transition-all"
                    style={isDone
                      ? { background: '#28A745', color: 'white' }
                      : isActive
                      ? { background: '#007BFF', color: 'white' }
                      : { background: '#E5E7EB', color: '#9CA3AF' }}
                  >
                    {isDone ? <CheckCircle2 size={15} /> : s.n}
                  </div>
                  <div className="text-center mt-1 hidden sm:block">
                    <div className="text-xs font-semibold" style={{ color: isActive ? '#007BFF' : isDone ? '#28A745' : '#9CA3AF' }}>
                      {s.label}
                    </div>
                    <div className="text-xs text-gray-400">{s.sub}</div>
                  </div>
                </div>
                {i < STEPS.length - 1 && (
                  <div className="h-0.5 flex-1 mx-2 transition-all" style={{ background: step > s.n ? '#28A745' : '#E5E7EB' }} />
                )}
              </React.Fragment>
            );
          })}
        </div>

        {/* Step content */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-sm overflow-hidden">
          <div
            className="px-6 py-4 border-b border-gray-100"
            style={{ background: step === 1 ? '#007BFF08' : step === 2 ? '#28A74508' : step === 3 ? '#8B5CF608' : '#F59E0B08' }}
          >
            <h2 className="text-base font-bold text-gray-800">{STEPS[step - 1].label}</h2>
            <p className="text-xs text-gray-400 mt-0.5">{STEPS[step - 1].sub}</p>
          </div>
          <div className="px-6 py-6">
            {step === 1 && renderStep1()}
            {step === 2 && renderStep2()}
            {step === 3 && renderStep3()}
            {step === 4 && renderStep4()}
          </div>
        </div>

        {/* Navigation */}
        <div className="flex justify-between items-center mt-4 pt-4">
          {step > 1 ? (
            <button
              onClick={() => setStep(s => s - 1)}
              className="flex items-center gap-2 px-5 py-2.5 rounded-xl border border-gray-200 bg-white text-sm font-medium text-gray-600 hover:bg-gray-50 transition-colors"
            >
              <ChevronLeft size={15} /> Previous
            </button>
          ) : (
            <button
              onClick={() => navigate('/mocks')}
              className="flex items-center gap-2 px-5 py-2.5 rounded-xl border border-gray-200 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 transition-colors"
            >
              <X size={15} /> Cancel
            </button>
          )}
          {step < 4 && (
            <button
              onClick={() => {
                if (step === 1 && !title.trim()) { toast.error('Please enter a test title to continue.'); return; }
                setStep(s => s + 1);
              }}
              className="flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-semibold text-white transition-opacity hover:opacity-90"
              style={{ background: '#007BFF' }}
            >
              Next <ChevronRight size={15} />
            </button>
          )}
        </div>
      </div>
    </div>
  );
}