const BASE = '/api/v1';

  export function getAccessToken(): string | null {
    return localStorage.getItem('accessToken');
  }

  export function getRefreshToken(): string | null {
    return localStorage.getItem('refreshToken');
  }

  export function setTokens(access: string, refresh: string) {
    localStorage.setItem('accessToken', access);
    localStorage.setItem('refreshToken', refresh);
  }

  export function clearTokens() {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
  }

  async function apiFetch<T = any>(
    endpoint: string,
    options: RequestInit = {},
  ): Promise<T> {
    const token = getAccessToken();
    const headers: Record<string, string> = {
      ...(options.headers as Record<string, string> || {}),
    };

    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }
    if (!(options.body instanceof FormData)) {
      headers['Content-Type'] = 'application/json';
    }

    let res: Response;
    try {
      res = await fetch(`${BASE}${endpoint}`, { ...options, headers });
    } catch (fetchErr) {
      throw new Error('Backend unreachable. Make sure the server is running on port 3000.');
    }

    if (res.status === 401) {
      const refreshed = await tryRefreshToken();
      if (refreshed) {
        headers['Authorization'] = `Bearer ${getAccessToken()}`;
        const retryRes = await fetch(`${BASE}${endpoint}`, { ...options, headers });
        const retryText = await retryRes.text();
        const retryData = retryText ? JSON.parse(retryText) : {};
        if (!retryRes.ok) throw { status: retryRes.status, ...retryData };
        return retryData as T;
      }
      clearTokens();
      window.location.href = '/login';
      throw new Error('Session expired');
    }

    const text = await res.text();
    let data: any;
    try {
      data = text ? JSON.parse(text) : {};
    } catch {
      throw new Error(`Backend returned invalid JSON (status ${res.status}). Is the server running?`);
    }

    if (!res.ok) {
      const err: any = new Error(data.message || `API Error (${res.status})`);
      err.status = res.status;
      err.data = data;
      throw err;
    }
    return data as T;
  }

  async function tryRefreshToken(): Promise<boolean> {
    const refresh = getRefreshToken();
    if (!refresh) return false;
    try {
      const res = await fetch(`${BASE}/auth/refresh-token`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken: refresh }),
      });
      if (!res.ok) return false;
      const data = await res.json();
      if (data.success && data.accessToken && data.refreshToken) {
        setTokens(data.accessToken, data.refreshToken);
        return true;
      }
      return false;
    } catch {
      return false;
    }
  }

  export async function registerAPI(body: any) {
    return apiFetch('/auth/register', {
      method: 'POST',
      body: JSON.stringify(body),
    });
  }

  export async function loginAPI(email: string, password: string) {
    return apiFetch<{
      success: boolean;
      accessToken: string;
      refreshToken: string;
      expiresIn: string;
      user: {
        id: string;
        full_name: string;
        email: string;
        role: string;
        subscription: string;
        preference: string | null;
      };
    }>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
  }

  export async function verifyOtpAPI(email: string, otp: string) {
    return apiFetch('/auth/verify-otp', {
      method: 'POST',
      body: JSON.stringify({ email, otp }),
    });
  }

  export async function resendOtpAPI(email: string) {
    return apiFetch('/auth/resend-otp', {
      method: 'POST',
      body: JSON.stringify({ email }),
    });
  }

  export async function forgotPasswordAPI(email: string) {
    return apiFetch('/auth/forgot-password', {
      method: 'POST',
      body: JSON.stringify({ email }),
    });
  }

  export async function resetPasswordAPI(body: any) {
    return apiFetch('/auth/reset-password', {
      method: 'POST',
      body: JSON.stringify(body),
    });
  }

  export async function googleAuthAPI(idToken: string) {
    return apiFetch('/auth/google', {
      method: 'POST',
      body: JSON.stringify({ token: idToken }),
    });
  }

  export async function refreshTokenAPI(refreshToken: string) {
    return apiFetch('/auth/refresh-token', {
      method: 'POST',
      body: JSON.stringify({ refreshToken }),
    });
  }

  export async function logoutAPI(refreshToken: string) {
    return apiFetch('/auth/logout', {
      method: 'POST',
      body: JSON.stringify({ refreshToken }),
    });
  }

  export async function logoutAllDevicesAPI(refreshToken: string) {
    return apiFetch('/auth/logout-all', {
      method: 'POST',
      body: JSON.stringify({ refreshToken }),
    });
  }

  export async function setUserPreferenceAPI(preference: string, targetUserId?: string) {
    return apiFetch('/auth/user/preferences', {
      method: 'POST',
      body: JSON.stringify({ preference, targetUserId }),
    });
  }

  export async function getUserProfileAPI() {
    return apiFetch<{
      success: boolean;
      user: any;
    }>('/user/profile');
  }

  export async function updateUserProfileAPI(body: { full_name?: string; bio?: string }) {
    return apiFetch<{
      success: boolean;
      message: string;
      user: any;
    }>('/user/profile', {
      method: 'PUT',
      body: JSON.stringify(body),
    });
  }

  export async function changeUserPasswordAPI(body: any) {
    return apiFetch<{
      success: boolean;
      message: string;
      user: any;
    }>('/user/password', {
      method: 'PUT',
      body: JSON.stringify(body),
    });
  }

  export async function uploadUserAvatarAPI(file: File) {
    const fd = new FormData();
    fd.append('avatar', file);
    return apiFetch<{
      success: boolean;
      message: string;
      user: any;
    }>('/user/avatar', {
      method: 'POST',
      body: fd,
    });
  }

  export async function updateFcmTokenAPI(fcm_token: string) {
    return apiFetch('/user/fcm-token', {
      method: 'PUT',
      body: JSON.stringify({ fcm_token }),
    });
  }

  export async function requestPreferenceChangeAPI(feedback: string, targetPreference: 'IELTS' | 'PTE') {
    return apiFetch<{
      success: boolean;
      message: string;
    }>('/user/request-preference-change', {
      method: 'POST',
      body: JSON.stringify({ feedback, targetPreference }),
    });
  }

  export async function getDashboardStats() {
    return apiFetch<{
      success: boolean;
      data: any;
    }>('/admin/stats');
  }

  export async function getAllUsersAPI(params: {
    page?: number;
    limit?: number;
    search?: string;
    subscription?: string;
    preference?: string;
  } = {}) {
    const q = new URLSearchParams();
    if (params.page) q.set('page', String(params.page));
    if (params.limit) q.set('limit', String(params.limit));
    if (params.search) q.set('search', params.search);
    if (params.subscription) q.set('subscription', params.subscription);
    if (params.preference) q.set('preference', params.preference);

    return apiFetch<{
      success: boolean;
      message: string;
      count: number;
      totalUsers: number;
      page: number;
      totalPages: number;
      data: any[];
    }>(`/admin/users?${q}`);
  }

  export async function updateUserSubscriptionAPI(targetID: string, newSubscription: string) {
    return apiFetch<{
      success: boolean;
      message: string;
      data: any;
    }>('/admin/users/subscription', {
      method: 'PUT',
      body: JSON.stringify({ targetID, newSubscription }),
    });
  }

  export async function fetchAllTests(page = 1, limit = 20, exam_type?: string) {
    const params = new URLSearchParams({ page: String(page), limit: String(limit) });
    if (exam_type) params.set('exam_type', exam_type);
    return apiFetch<{
      success: boolean;
      count: number;
      data: any[];
    }>(`/content/test/all-tests?${params}`);
  }

  export async function fetchAdminMocks(params: {
    page?: number;
    limit?: number;
    search?: string;
    exam_type?: string;
  } = {}) {
    const q = new URLSearchParams();
    q.set('page', String(params.page ?? 1));
    q.set('limit', String(params.limit ?? 50));
    if (params.search) q.set('search', params.search);
    if (params.exam_type && params.exam_type !== 'All') q.set('exam_type', params.exam_type);
    return apiFetch<{
      success: boolean;
      cached?: boolean;
      page: number;
      limit: number;
      count: number;
      data: any[];
    }>(`/content/test/admin/mocks?${q}`);
  }

  export async function getTestById(id: string) {
    return apiFetch<{
      success: boolean;
      data: any;
    }>(`/content/test/${id}`);
  }

  export async function createFullTest(body: any) {
    return apiFetch<{
      success: boolean;
      data: { id: string; display_id?: string; title: string };
    }>('/content/test/create-full-test', {
      method: 'POST',
      body: JSON.stringify(body),
    });
  }

  export async function upsertTestNested(id: string, body: unknown) {
    return apiFetch<{
      success: boolean;
      data: Record<string, unknown>;
    }>(`/content/test/${id}/nested`, {
      method: 'PUT',
      body: JSON.stringify(body),
    });
  }

  export async function getTestPreview(id: string) {
    return apiFetch<{
      success: boolean;
      data: Record<string, unknown>;
    }>(`/content/test/${id}/preview`);
  }

  export async function uploadTestAsset(file: File) {
    const fd = new FormData();
    fd.append('file', file);
    return apiFetch<{
      success: boolean;
      data: { url: string; public_id: string };
    }>('/content/test/mocks/assets', {
      method: 'POST',
      body: fd,
    });
  }

  export async function updateTestHeader(id: string, body: any) {
    return apiFetch('/content/test/header/' + id, {
      method: 'PUT',
      body: JSON.stringify(body),
    });
  }

  export async function addQuestionToSection(body: any) {
    return apiFetch('/content/test/questions', {
      method: 'PUT',
      body: JSON.stringify(body),
    });
  }

  export async function updateQuestion(id: string, body: any) {
    return apiFetch('/content/test/questions/' + id, {
      method: 'PUT',
      body: JSON.stringify(body),
    });
  }

  export async function deleteQuestionAPI(id: string) {
    return apiFetch('/content/test/questions/' + id, { method: 'DELETE' });
  }

  export async function deleteTestAPI(id: string) {
    return apiFetch('/content/test/' + id, { method: 'DELETE' });
  }

  export async function adminGetPosts(params: {
    page?: number;
    topic_tag?: string;
    filter?: string;
    search?: string;
  } = {}) {
    const q = new URLSearchParams();
    if (params.page) q.set('page', String(params.page));
    if (params.topic_tag && params.topic_tag !== 'All') q.set('topic_tag', params.topic_tag);
    if (params.filter) q.set('filter', params.filter);
    if (params.search) q.set('search', params.search);
    return apiFetch<{
      success: boolean;
      data: any[];
      stats: any;
      meta: { page: number; limit: number; total: number; totalPages: number };
    }>(`/community/admin/posts?${q}`);
  }

  export async function adminFlagPost(postId: string, reason?: string) {
    return apiFetch(`/community/admin/posts/${postId}/flag`, {
      method: 'POST',
      body: JSON.stringify({ reason: reason || '' }),
    });
  }

  export async function adminUnflagPost(postId: string) {
    return apiFetch(`/community/admin/posts/${postId}/unflag`, {
      method: 'POST',
      body: JSON.stringify({}),
    });
  }

  export async function adminDeletePost(postId: string, reason?: string) {
    return apiFetch(`/community/admin/posts/${postId}`, {
      method: 'DELETE',
      body: JSON.stringify({ reason: reason || '' }),
    });
  }

  export async function getPrepLessons(filters?: {
    test_type?: string;
    section?: string;
    search?: string;
  }) {
    const q = new URLSearchParams();
    if (filters?.test_type) q.set('test_type', filters.test_type);
    if (filters?.section) q.set('section', filters.section);
    if (filters?.search) q.set('search', filters.search);
    return apiFetch<{
      success: boolean;
      count: number;
      data: any[];
    }>(`/content/preparations?${q}`);
  }

  export async function getPrepDetails(id: string) {
    return apiFetch<{
      success: boolean;
      data: any;
    }>(`/content/preparations/lesson/${id}`);
  }

  export async function createPrepLesson(body: any) {
    return apiFetch<{
      success: boolean;
      message: string;
      data: { id: string };
    }>('/content/preparations/create-lesson', {
      method: 'POST',
      body: JSON.stringify(body),
    });
  }

  export async function updatePrepLesson(id: string, body: any) {
    return apiFetch('/content/preparations/lesson/' + id, {
      method: 'PUT',
      body: JSON.stringify(body),
    });
  }

  export async function deletePrepLesson(id: string) {
    return apiFetch('/content/preparations/lesson/' + id, { method: 'DELETE' });
  }

  export async function uploadPrepPdf(file: File) {
    const fd = new FormData();
    fd.append('file', file);
    return apiFetch<{
      success: boolean;
      data: {
        file_url: string;   // ← it's data.file_url, not root .url
        file_name: string;
        file_size: number;
        file_type: string;
      };
      message: string;
    }>('/content/preparations/upload-pdf', {
      method: 'POST',
      body: fd,
    });
  }