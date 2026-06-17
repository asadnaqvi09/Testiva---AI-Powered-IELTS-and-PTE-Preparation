import type { BuilderQuestion, BuilderSection, BuilderState, ExtendedMock } from '../context/MocksContext';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export function isUuid(id: string): boolean {
  return UUID_RE.test(id);
}

export function toApiDifficulty(d: string): 'easy' | 'medium' | 'hard' {
  const v = (d || 'medium').toLowerCase();
  if (v === 'easy' || v === 'hard') return v;
  return 'medium';
}

export function toUiDifficulty(d: string): string {
  const v = (d || 'medium').toLowerCase();
  return v.charAt(0).toUpperCase() + v.slice(1);
}

export function moduleToSectionType(moduleType: string): string {
  const m = moduleType.toLowerCase();
  if (m.includes('reading')) return 'reading';
  if (m.includes('listening')) return 'listening';
  if (m.includes('writing')) return 'writing';
  if (m.includes('speaking')) return 'speaking';
  return m;
}

export function sectionTypeToModule(sectionType: string, examType: string): string {
  const s = (sectionType || '').toLowerCase();
  if (s === 'reading') return 'Reading';
  if (s === 'listening') return 'Listening';
  if (s === 'writing') return examType === 'PTE' ? 'Speaking & Writing' : 'Writing';
  if (s === 'speaking') return 'Speaking';
  return sectionType;
}

const QUESTION_TYPE_MAP: Record<string, { question_type: string; sub_question_type: string | null }> = {
  MCQ: { question_type: 'mcq', sub_question_type: 'mcq' },
  'Multi-select': { question_type: 'multi_select', sub_question_type: 'multi_select' },
  'True/False/NG': { question_type: 'true_false', sub_question_type: 'tf_not_given' },
  'Yes/No/NG': { question_type: 'yes_no', sub_question_type: 'yn_not_given' },
  Matching: { question_type: 'matching', sub_question_type: 'matching' },
  'Sentence Completion': { question_type: 'sentence_completion', sub_question_type: 'sentence_completion' },
  'Short Answer': { question_type: 'short_answer', sub_question_type: 'short_answer' },
  'Form Fill': { question_type: 'form_fill', sub_question_type: 'form_fill' },
  'Task 1 Essay': { question_type: 'essay', sub_question_type: 'task_1' },
  'Task 2 Essay': { question_type: 'essay', sub_question_type: 'task_2' },
  'Part 1: Interview': { question_type: 'speaking', sub_question_type: 'part_1' },
  'Part 2: Cue Card': { question_type: 'speaking', sub_question_type: 'part_2' },
  'Part 3: Discussion': { question_type: 'speaking', sub_question_type: 'part_3' },
  'Chart Description': { question_type: 'writing', sub_question_type: 'chart_description' },
  'Request Information': { question_type: 'writing', sub_question_type: 'request_information' },
  'Explain Situation': { question_type: 'writing', sub_question_type: 'explain_situation' },
  'Provide Opinion': { question_type: 'writing', sub_question_type: 'provide_opinion' },
  'Opinion': { question_type: 'writing', sub_question_type: 'opinion' },
  'Discussion': { question_type: 'writing', sub_question_type: 'discussion' },
  'Problem & Solution': { question_type: 'writing', sub_question_type: 'problem_solution' },
  'Advantages & Disadvantages': { question_type: 'writing', sub_question_type: 'advantages_disadvantages' },
  'Two-Part Question': { question_type: 'writing', sub_question_type: 'two_part_question' },
};

const WRITING_UI_TYPES = new Set([
  "Chart Description",
  "Request Information",
  "Explain Situation",
  "Provide Opinion",
  "Opinion",
  "Discussion",
  "Problem & Solution",
  "Advantages & Disadvantages",
  "Two-Part Question",
  "Task 1 Essay",
  "Task 2 Essay",
]);

function isWritingUiType(type: string): boolean {
  if (WRITING_UI_TYPES.has(type)) return true;
  const mapped = QUESTION_TYPE_MAP[type];
  return mapped?.question_type === "writing" || mapped?.question_type === "essay";
}

function isTask2WritingQuestion(q: BuilderQuestion, section: BuilderSection): boolean {
  if (section.writingTask === "Task 2") return isWritingUiType(q.type);
  return q.type === "Task 2 Essay";
}

const REVERSE_QUESTION_TYPE: Record<string, string> = {
  mcq: 'MCQ',
  multi_select: 'Multi-select',
  true_false: 'True/False/NG',
  yes_no: 'Yes/No/NG',
  matching: 'Matching',
  sentence_completion: 'Sentence Completion',
  short_answer: 'Short Answer',
  form_fill: 'Form Fill',
  essay_task_1: 'Task 1 Essay',
  essay_task_2: 'Task 2 Essay',
  chart_description: 'Chart Description',
  request_information: 'Request Information',
  explain_situation: 'Explain Situation',
  provide_opinion: 'Provide Opinion',
  opinion: 'Opinion',
  discussion: 'Discussion',
  problem_solution: 'Problem & Solution',
  advantages_disadvantages: 'Advantages & Disadvantages',
  two_part_question: 'Two-Part Question',
};

function uiQuestionType(question_type: string, sub_question_type?: string | null): string {
  const qt = (question_type || '').toLowerCase();
  const sub = (sub_question_type || '').toLowerCase();
  if (qt === 'essay') return sub === 'task_2' ? 'Task 2 Essay' : 'Task 1 Essay';
  if (qt === 'writing') return REVERSE_QUESTION_TYPE[sub] || 'Writing';
  if (qt === 'speaking') {
    if (sub === 'part_2') return 'Part 2: Cue Card';
    if (sub === 'part_3') return 'Part 3: Discussion';
    return 'Part 1: Interview';
  }
  return REVERSE_QUESTION_TYPE[qt] || REVERSE_QUESTION_TYPE[sub] || question_type;
}

function buildCorrectAnswer(q: BuilderQuestion): unknown {
  if (q.type === 'Multi-select') return q.multiSelectAnswers.filter(Boolean);
  if (q.type === 'Matching') {
    return q.matchingPairs.filter(p => p.key || p.value);
  }
  if (['Short Answer', 'Sentence Completion', 'Form Fill'].includes(q.type)) {
    return q.correctAnswer || q.answer || '';
  }
  return q.answer || q.correctAnswer || '';
}

function parseCorrectAnswer(ca: unknown, uiType: string): Partial<BuilderQuestion> {
  if (uiType === 'Multi-select' && Array.isArray(ca)) {
    return { multiSelectAnswers: ca.map(String), answer: '' };
  }
  if (uiType === 'Matching' && Array.isArray(ca)) {
    return {
      matchingPairs: ca.map((p: { key?: string; value?: string }) => ({
        key: p.key ?? '',
        value: p.value ?? '',
      })),
    };
  }
  const str = typeof ca === 'string' ? ca : ca != null ? JSON.stringify(ca) : '';
  return { answer: str, correctAnswer: str };
}

function parseOptions(options: unknown): string[] {
  if (Array.isArray(options)) return options.map(String);
  return [];
}

/** Expand PTE combined section into speaking + writing for API full_mock rules. */
export function expandSectionsForApi(state: BuilderState): BuilderSection[] {
  const { sections, testType, mode } = state;
  if (testType !== 'PTE' || mode !== 'full') {
    return sections;
  }
  const out: BuilderSection[] = [];
  for (const sec of sections) {
    if (sec.moduleType === 'Speaking & Writing') {
      const speakingQs = sec.questions.filter(q => q.type.startsWith("Part"));
      const writingQs = sec.questions.filter(q => isWritingUiType(q.type));
      out.push({
        ...sec,
        id: isUuid(sec.id) ? `${sec.id}-speaking` : `${sec.id}_speak`,
        moduleType: 'Speaking',
        questions: speakingQs,
        cueCard: sec.cueCard,
        audioFile: sec.audioFile,
        audioFileData: sec.audioFileData,
      });
      out.push({
        ...sec,
        id: isUuid(sec.id) ? `${sec.id}-writing` : `${sec.id}_write`,
        moduleType: 'Writing',
        questions: writingQs,
        writingTask: sec.writingTask,
        minWordLimit: sec.minWordLimit,
        chartImage: sec.chartImage,
        chartImageData: sec.chartImageData,
      });
    } else {
      out.push(sec);
    }
  }
  return out;
}

/** Merge API speaking + writing back into PTE combined section for the builder UI. */
function collapsePteSections(
  apiSections: Array<Record<string, unknown>>,
  examType: string,
): Array<Record<string, unknown>> {
  if (examType !== 'PTE') return apiSections;
  const speaking = apiSections.find(s => (s.section_type as string)?.toLowerCase() === 'speaking');
  const writing = apiSections.find(s => (s.section_type as string)?.toLowerCase() === 'writing');
  const others = apiSections.filter(s => {
    const t = (s.section_type as string)?.toLowerCase();
    return t !== 'speaking' && t !== 'writing';
  });
  if (speaking && writing) {
    const questions = [
      ...((speaking.questions as unknown[]) || []),
      ...((writing.questions as unknown[]) || []),
    ];
    return [
      {
        ...speaking,
        section_name: 'Speaking & Writing',
        section_type: 'writing',
        _uiModuleType: 'Speaking & Writing',
        questions,
        _writingMeta: writing,
      },
      ...others,
    ];
  }
  return apiSections;
}

export function mapQuestionToApi(
  q: BuilderQuestion,
  section: BuilderSection,
  order: number,
  sectionAudioUrl?: string | null,
  sectionImageUrl?: string | null,
): Record<string, unknown> {
  const mapped = QUESTION_TYPE_MAP[q.type] || {
    question_type: q.type.toLowerCase().replace(/\s+/g, '_'),
    sub_question_type: null,
  };
  const payload: Record<string, unknown> = {
    question_type: mapped.question_type,
    sub_question_type: mapped.sub_question_type,
    passage_text: section.passage || null,
    question_text: q.text || '(No question text)',
    word_limit_instruction:
      isTask2WritingQuestion(q, section) && section.minWordLimit
        ? `Write at least ${section.minWordLimit} words.`
        : section.writingTask === "Task 1" && section.minWordLimit
          ? `Write at least ${section.minWordLimit} words.`
          : null,
    options: q.options.filter(o => o !== undefined),
    correct_answer: buildCorrectAnswer(q),
    content: {},
    audio_url: sectionAudioUrl || null,
    image_url: sectionImageUrl || null,
    order_number: order,
    marks: 1,
    difficulty: toApiDifficulty('medium'),
    min_words: isWritingUiType(q.type)
      ? isTask2WritingQuestion(q, section)
        ? section.minWordLimit || 250
        : section.minWordLimit || 150
      : 0,
    max_words: q.wordLimit || 0,
    prep_time_seconds: q.prepTime || 0,
    record_time_seconds: q.recordingLimit || 0,
    tags: [],
  };
  if (isUuid(q.id)) payload.id = q.id;
  if (section.cueCard && q.type === 'Part 2: Cue Card') {
    payload.content = { cue_card: section.cueCard };
  }
  return payload;
}

export function mapSectionToApi(
  section: BuilderSection,
  order: number,
  audioUrl?: string | null,
  imageUrl?: string | null,
  durationMinutes?: number,
): Record<string, unknown> {
  const sectionType = moduleToSectionType(section.moduleType);
  const questions = section.questions.length
    ? section.questions.map((q, i) =>
        mapQuestionToApi(q, section, i + 1, audioUrl, imageUrl),
      )
    : [
        {
          question_type: 'placeholder',
          sub_question_type: null,
          passage_text: section.passage || null,
          question_text: `${section.moduleType} section placeholder`,
          word_limit_instruction: null,
          options: [],
          correct_answer: {},
          content: section.cueCard ? { cue_card: section.cueCard } : {},
          audio_url: audioUrl || null,
          image_url: imageUrl || null,
          order_number: 1,
          marks: 1,
          difficulty: 'medium',
          min_words: section.minWordLimit || 0,
          max_words: 0,
          prep_time_seconds: 0,
          record_time_seconds: 0,
          tags: [],
        },
      ];

  const payload: Record<string, unknown> = {
    section_name: section.moduleType,
    section_type: sectionType,
    sub_type: section.writingTask || null,
    time_limit_minutes: Math.max(1, durationMinutes ?? 30),
    order_number: order,
    instructions: section.cueCard || null,
    question_types_allowed: section.questions.map(q => q.type),
    task_count: 1,
    questions,
  };
  if (isUuid(section.id)) payload.id = section.id;
  return payload;
}

export function builderToCreatePayload(
  state: BuilderState,
  isPublished: boolean,
  sectionUrls?: Map<string, { audio?: string | null; image?: string | null }>,
) {
  const expanded = expandSectionsForApi(state);
  const perSectionMin = Math.max(1, Math.floor(state.duration / Math.max(1, expanded.length)));
  return {
    title: state.title.trim(),
    exam_type: state.testType === 'PTE' ? 'PTE' : 'IELTS',
    test_category: state.mode === 'single' ? 'singular_module' : 'full_mock',
    difficulty_level: toApiDifficulty(state.difficulty),
    passing_score: 6.5,
    min_required_band: 6.0,
    total_duration: Math.max(30, state.duration),
    is_premium: false,
    is_published: isPublished,
    sections: expanded.map((s, i) => {
      const urls = resolveSectionUrls(s, sectionUrls);
      return mapSectionToApi(
        s,
        i + 1,
        urls?.audio ?? null,
        urls?.image ?? null,
        perSectionMin,
      );
    }),
  };
}

export function builderToNestedPayload(
  state: BuilderState,
  isPublished: boolean,
  _existingId: string,
  sectionUrls?: Map<string, { audio?: string | null; image?: string | null }>,
) {
  const expanded = expandSectionsForApi(state);
  const perSectionMin = Math.max(1, Math.floor(state.duration / Math.max(1, expanded.length)));
  return {
    test: {
      title: state.title.trim(),
      exam_type: state.testType === 'PTE' ? 'PTE' : 'IELTS',
      test_category: state.mode === 'single' ? 'singular_module' : 'full_mock',
      difficulty_level: toApiDifficulty(state.difficulty),
      total_duration: Math.max(30, state.duration),
      is_published: isPublished,
    },
    sections: expanded.map((s, i) => {
      const urls = resolveSectionUrls(s, sectionUrls);
      return mapSectionToApi(
        s,
        i + 1,
        urls?.audio ?? null,
        urls?.image ?? null,
        perSectionMin,
      );
    }),
  };
}

function resolveSectionUrls(
  section: BuilderSection,
  map?: Map<string, { audio?: string | null; image?: string | null }>,
) {
  if (!map) return undefined;
  return (
    map.get(section.id) ||
    map.get(section.id.replace(/-speaking$|-writing$|_speak$|_write$/, ''))
  );
}

export function buildSectionUrlMap(sections: BuilderSection[]): Map<string, { audio?: string | null; image?: string | null }> {
  const map = new Map<string, { audio?: string | null; image?: string | null }>();
  for (const s of sections) {
    map.set(s.id, {
      audio: s.audioFile?.startsWith('http') ? s.audioFile : null,
      image: s.chartImage?.startsWith('http') ? s.chartImage : null,
    });
  }
  return map;
}

export function apiRowToExtendedMock(row: Record<string, unknown>): ExtendedMock {
  const examType = String(row.exam_type || 'IELTS');
  const category = String(row.test_category || 'full_mock');
  const isPte = examType === 'PTE';
  let sections: string[];
  if (category === 'singular_module') {
    sections = ['Single module'];
  } else if (isPte) {
    sections = ['Speaking & Writing', 'Reading', 'Listening'];
  } else {
    sections = ['Reading', 'Listening', 'Writing', 'Speaking'];
  }

  return {
    id: String(row.id),
    displayId: row.display_id ? String(row.display_id) : undefined,
    title: String(row.title || ''),
    testType: examType,
    sections,
    questionsCount: Number(row.question_count ?? row.total_questions ?? 0),
    duration: Number(row.total_duration ?? 0),
    difficulty: toUiDifficulty(String(row.difficulty_level || 'medium')),
    createdDate: String(row.created_at || '').slice(0, 10),
    status: row.is_published ? 'published' : 'draft',
    questions: [],
  };
}

export function apiDetailToBuilderState(detail: Record<string, unknown>): BuilderState {
  const examType = String(detail.exam_type || 'IELTS');
  const category = String(detail.test_category || 'full_mock');
  const mode = category === 'singular_module' ? 'single' : 'full';
  let rawSections = (detail.sections as Array<Record<string, unknown>>) || [];
  rawSections = collapsePteSections(rawSections, examType);

  const sections: BuilderSection[] = rawSections.map(sec => {
    const uiModule =
      (sec._uiModuleType as string) ||
      sectionTypeToModule(String(sec.section_type || ''), examType);
    const questions = ((sec.questions as Array<Record<string, unknown>>) || []).map(q => {
      const uiType = uiQuestionType(
        String(q.question_type || ''),
        q.sub_question_type as string | null,
      );
      const parsed = parseCorrectAnswer(q.correct_answer, uiType);
      const content = (q.content as Record<string, unknown>) || {};
      return {
        id: String(q.id || `q_${Date.now()}`),
        type: uiType,
        text: String(q.question_text || ''),
        options: parseOptions(q.options),
        answer: typeof parsed.answer === 'string' ? parsed.answer : '',
        matchingPairs: parsed.matchingPairs || [{ key: '', value: '' }],
        wordLimit: Number(q.max_words) || 50,
        correctAnswer: typeof parsed.correctAnswer === 'string' ? parsed.correctAnswer : '',
        prepTime: Number(q.prep_time_seconds) || 0,
        recordingLimit: Number(q.record_time_seconds) || 0,
        multiSelectAnswers: parsed.multiSelectAnswers || [],
        _audioUrl: q.audio_url as string | null,
        _imageUrl: q.image_url as string | null,
      } as BuilderQuestion & { _audioUrl?: string | null; _imageUrl?: string | null };
    });

    const firstQ = questions[0] as (BuilderQuestion & { _audioUrl?: string }) | undefined;
    const writingMeta = sec._writingMeta as Record<string, unknown> | undefined;

    return {
      id: String(sec.id || `sec_${Date.now()}`),
      moduleType: uiModule,
      locked: mode === 'full',
      passage: String(
        (sec.questions as Array<Record<string, unknown>>)?.[0]?.passage_text || '',
      ),
      audioFile: firstQ?._audioUrl || null,
      audioFileData: null,
      writingTask: String(sec.sub_type || writingMeta?.sub_type || 'Task 1'),
      chartImage: (questions[0] as { _imageUrl?: string })?._imageUrl || null,
      chartImageData: null,
      minWordLimit: Number(
        (sec.questions as Array<Record<string, unknown>>)?.find(
          q => (q.sub_question_type as string) === 'task_2',
        )?.min_words || 0,
      ),
      cueCard: String(sec.instructions || contentCue(sec) || ''),
      questions: questions.map(({ _audioUrl, _imageUrl, ...rest }) => rest as BuilderQuestion),
      collapsed: false,
    };
  });

  const singleModule =
    mode === 'single' && sections[0] ? sections[0].moduleType : 'Reading';

  return {
    title: String(detail.title || ''),
    testType: examType,
    difficulty: toUiDifficulty(String(detail.difficulty_level || 'medium')),
    duration: Number(detail.total_duration) || 60,
    mode,
    singleModule,
    sections,
  };
}

function contentCue(sec: Record<string, unknown>): string {
  const qs = (sec.questions as Array<Record<string, unknown>>) || [];
  for (const q of qs) {
    const c = q.content as Record<string, unknown> | undefined;
    if (c?.cue_card) return String(c.cue_card);
  }
  return '';
}
