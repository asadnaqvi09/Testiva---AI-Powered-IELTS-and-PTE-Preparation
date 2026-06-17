const BASE_URL = '/api/v1/notifications';

const getHeaders = () => {
  const token = localStorage.getItem('accessToken');

  return {
    'Content-Type': 'application/json',
    ...(token && {
      Authorization: `Bearer ${token}`,
    }),
  };
};

export const fetchNotificationsAPI = async (limit = 20, offset = 0) => {
  const response = await fetch(`${BASE_URL}?limit=${limit}&offset=${offset}`, {
    method: 'GET',
    headers: getHeaders(),
  });

  if (!response.ok) {
    throw new Error('Failed to fetch notifications');
  }

  return response.json();
};

export const fetchUnreadCountAPI = async () => {
  const response = await fetch(`${BASE_URL}/unread-count`, {
    method: 'GET',
    headers: getHeaders(),
  });

  if (!response.ok) {
    throw new Error('Failed to fetch unread count');
  }

  return response.json();
};

export const markNotificationReadAPI = async (id: string) => {
  const response = await fetch(`${BASE_URL}/${id}/read`, {
    method: 'PATCH',
    headers: getHeaders(),
  });

  if (!response.ok) {
    throw new Error('Failed to mark notification as read');
  }

  return response.json();
};

export const markAllNotificationsReadAPI = async () => {
  const response = await fetch(`${BASE_URL}/read-all`, {
    method: 'PATCH',
    headers: getHeaders(),
  });

  if (!response.ok) {
    throw new Error('Failed to mark all notifications as read');
  }

  return response.json();
};

export const deleteNotificationAPI = async (id: string) => {
  const response = await fetch(`${BASE_URL}/${id}`, {
    method: 'DELETE',
    headers: getHeaders(),
  });

  if (!response.ok) {
    throw new Error('Failed to delete notification');
  }

  return response.json();
};