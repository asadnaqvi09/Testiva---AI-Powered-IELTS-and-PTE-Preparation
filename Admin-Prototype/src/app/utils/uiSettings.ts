// Apply light / dark / system theme to <html>
export function applyTheme(theme: string) {
  const root = window.document.documentElement;
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  const dark = theme === 'dark' || (theme === 'system' && prefersDark);
  root.classList.toggle('dark', dark);
}

export type NotifPrefs = {
  newUser: boolean;
  subChange: boolean;
  newPost: boolean;
  preferenceChange: boolean;
};

export const DEFAULT_NOTIF_PREFS: NotifPrefs = {
  newUser: true,
  subChange: true,
  newPost: true,
  preferenceChange: true,
};

export function normalizeNotifPrefs(prefs?: Partial<NotifPrefs> | null): NotifPrefs {
  return { ...DEFAULT_NOTIF_PREFS, ...(prefs || {}) };
}

// Map notification type → Settings notif_prefs key
export function notifTypeAllowed(type: string, prefs: NotifPrefs): boolean {
  switch (type) {
    case 'admin_new_user':
      return prefs.newUser !== false;
    case 'admin_subscription_changed':
      return prefs.subChange !== false;
    case 'admin_new_post':
      return prefs.newPost !== false;
    case 'preference_change_request':
      return prefs.preferenceChange !== false;
    default:
      return true;
  }
}
