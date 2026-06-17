import { io, Socket } from 'socket.io-client';

const NAMESPACE = '/community';

/** Same origin in dev (Vite proxies /socket.io). Set VITE_SOCKET_URL at build time for production. */
const resolveSocketUrl = () => {
  if (typeof window === 'undefined') return 'http://localhost:5173';
  const envUrl = (window as Window & { __SOCKET_URL__?: string }).__SOCKET_URL__;
  return envUrl || window.location.origin;
};

type ConnectListener = () => void;

class SocketService {
  public socket: Socket | null = null;
  private connectListeners = new Set<ConnectListener>();

  connect(token: string) {
    if (this.socket) {
      this.socket.removeAllListeners();
      this.socket.disconnect();
      this.socket = null;
    }

    this.socket = io(`${resolveSocketUrl()}${NAMESPACE}`, {
      auth: { token },
      transports: ['websocket', 'polling'],
      reconnection: true,
      reconnectionAttempts: 10,
      reconnectionDelay: 3000,
    });

    this.socket.on('connect', () => {
      console.log('[Socket] Connected to /community namespace');
      this.connectListeners.forEach((cb) => cb());
    });

    this.socket.on('connected', (data: { userId: string; rooms: string[] }) => {
      console.log('[Socket] Room confirmation:', data.rooms);
    });

    this.socket.on('connect_error', (error: Error) => {
      console.error('[Socket] Connection error:', error.message);
      if (error.message === 'UNAUTHORIZED') {
        this.disconnect();
      }
    });

    this.socket.on('disconnect', (reason: string) => {
      console.log('[Socket] Disconnected:', reason);
    });
  }

  onConnect(callback: ConnectListener) {
    this.connectListeners.add(callback);
    if (this.socket?.connected) {
      callback();
    }
    return () => this.connectListeners.delete(callback);
  }

  on(event: string, callback: (...args: any[]) => void) {
    this.socket?.on(event, callback);
  }

  off(event: string, callback: (...args: any[]) => void) {
    this.socket?.off(event, callback);
  }

  disconnect() {
    this.connectListeners.clear();
    if (this.socket) {
      this.socket.removeAllListeners();
      this.socket.disconnect();
      this.socket = null;
    }
  }
}

export const socketService = new SocketService();
