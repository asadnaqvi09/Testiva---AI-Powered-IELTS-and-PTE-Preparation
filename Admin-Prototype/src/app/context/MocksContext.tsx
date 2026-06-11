import React, {
  createContext,
  useCallback,
  useContext,
  useState,
} from 'react';
import {
  createFullTest,
  deleteTestAPI,
  fetchAdminMocks,
  getTestById,
  upsertTestNested,
} from '../services/api';
import {
  apiDetailToBuilderState,
  apiRowToExtendedMock,
  builderToCreatePayload,
  builderToNestedPayload,
  buildSectionUrlMap,
} from '../services/mockTestMapper';
import { uploadSectionAssets } from '../services/mockTestAssets';

// ─── Shared Builder Types (used by both MocksContext and TestBuilder) ──────────

export interface BuilderQuestion {
  id: string;
  type: string;
  text: string;
  options: string[];
  answer: string;
  matchingPairs: { key: string; value: string }[];
  wordLimit: number;
  correctAnswer: string;
  prepTime: number;
  recordingLimit: number;
  multiSelectAnswers: string[];
}

export interface BuilderSection {
  id: string;
  moduleType: string;
  locked: boolean;
  passage: string;
  audioFile: string | null;
  audioFileData?: File | null;
  writingTask: string;
  chartImage: string | null;
  chartImageData?: File | null;
  minWordLimit: number;
  cueCard: string;
  questions: BuilderQuestion[];
  collapsed: boolean;
}

export interface BuilderState {
  title: string;
  testType: string;
  difficulty: string;
  duration: number;
  mode: string;
  singleModule: string;
  sections: BuilderSection[];
}

export interface ExtendedMock {
  id: string;
  displayId?: string;
  title: string;
  testType: string;
  sections: string[];
  questionsCount: number;
  duration: number;
  difficulty: string;
  createdDate: string;
  status: 'published' | 'draft';
  questions: {
    id: string;
    text: string;
    type: string;
    options: string[];
    answer: string;
    difficulty: string;
  }[];
  builderState?: BuilderState;
}

/** @deprecated Use saveMockFromBuilder — kept for type compatibility */
export function buildMockRecord(
  state: BuilderState,
  status: 'published' | 'draft',
  existingId?: string,
): ExtendedMock {
  const allQuestions = state.sections.flatMap(s =>
    s.questions.map(q => ({
      id: q.id,
      text: q.text,
      type: q.type,
      options: q.options,
      answer: q.answer,
      difficulty: state.difficulty,
    })),
  );
  return {
    id: existingId ?? '',
    title: state.title,
    testType: state.testType,
    sections: state.sections.map(s => s.moduleType),
    questionsCount: allQuestions.length,
    duration: state.duration,
    difficulty: state.difficulty,
    createdDate: new Date().toISOString().slice(0, 10),
    status,
    questions: allQuestions,
    builderState: state,
  };
}

interface MocksContextValue {
  mockList: ExtendedMock[];
  loading: boolean;
  error: string | null;
  refreshMocks: (params?: {
    search?: string;
    exam_type?: string;
    page?: number;
  }) => Promise<void>;
  deleteMock: (id: string) => Promise<void>;
  loadMockForEdit: (id: string) => Promise<BuilderState | null>;
  saveMockFromBuilder: (
    state: BuilderState,
    published: boolean,
    existingId?: string,
  ) => Promise<{ id: string }>;
}

const MocksContext = createContext<MocksContextValue | null>(null);

export function MocksProvider({ children }: { children: React.ReactNode }) {
  const [mockList, setMockList] = useState<ExtendedMock[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const refreshMocks = useCallback(
    async (params?: { search?: string; exam_type?: string; page?: number }) => {
      setLoading(true);
      setError(null);
      try {
        const res = await fetchAdminMocks({
          page: params?.page ?? 1,
          limit: 100,
          search: params?.search,
          exam_type: params?.exam_type,
        });
        setMockList((res.data || []).map(row => apiRowToExtendedMock(row)));
      } catch (e: unknown) {
        const msg = e instanceof Error ? e.message : 'Failed to load mock tests';
        setError(msg);
        setMockList([]);
      } finally {
        setLoading(false);
      }
    },
    [],
  );

  const deleteMock = useCallback(
    async (id: string) => {
      await deleteTestAPI(id);
      setMockList(prev => prev.filter(m => m.id !== id));
    },
    [],
  );

  const loadMockForEdit = useCallback(async (id: string): Promise<BuilderState | null> => {
    const res = await getTestById(id);
    if (!res.data) return null;
    return apiDetailToBuilderState(res.data);
  }, []);

  const saveMockFromBuilder = useCallback(
    async (
      state: BuilderState,
      published: boolean,
      existingId?: string,
    ): Promise<{ id: string }> => {
      const sectionsWithUrls = await uploadSectionAssets(state.sections);
      const stateWithAssets: BuilderState = { ...state, sections: sectionsWithUrls };
      const urlMap = buildSectionUrlMap(sectionsWithUrls);

      if (existingId) {
        const payload = builderToNestedPayload(
          stateWithAssets,
          published,
          existingId,
          urlMap,
        );
        await upsertTestNested(existingId, payload);
        await refreshMocks();
        return { id: existingId };
      }

      const payload = builderToCreatePayload(stateWithAssets, published, urlMap);
      const res = await createFullTest(payload);
      await refreshMocks();
      return { id: res.data.id };
    },
    [refreshMocks],
  );

  return (
    <MocksContext.Provider
      value={{
        mockList,
        loading,
        error,
        refreshMocks,
        deleteMock,
        loadMockForEdit,
        saveMockFromBuilder,
      }}
    >
      {children}
    </MocksContext.Provider>
  );
}

export function useMocks() {
  const ctx = useContext(MocksContext);
  if (!ctx) throw new Error('useMocks must be used inside MocksProvider');
  return ctx;
}
