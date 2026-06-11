import { io, Socket } from 'socket.io-client';

/**
 * Socket.io Frontend Service
 * Connects specifically to the /community namespace
 */

// Use environment variable for the backend URL
const SOCKET_URL = 'http://localhost:5000';
const NAMESPACE = '/community';

class SocketService {
  public socket: Socket | null = null;

  /**
   * Initialize connection with the JWT token
   * @param token - User authentication token
   */
  connect(token: string) {
    if (this.socket?.connected) return;

    // Initialize the socket with the community namespace
    this.socket = io(`${SOCKET_URL}${NAMESPACE}`, {
      auth: {
        token: token, // Matches socket.handshake.auth?.token in your backend
      },
      transports: ['websocket'], // Faster, preferred transport
      reconnection: true,
      reconnectionAttempts: 5,
      reconnectionDelay: 5000,
    });

    this.socket.on('connect', () => {
      console.log('[Socket] Connected to /community namespace');
    });

    this.socket.on('connected', (data) => {
      // Matches your backend emission: socket.emit("connected", { userId, rooms })
      console.log('[Socket] Room Confirmation:', data.rooms);
    });

    this.socket.on('connect_error', (error) => {
      console.error('[Socket] Connection Error:', error.message);
      if (error.message === 'UNAUTHORIZED') {
        // Handle token expiration or invalidity
        this.disconnect();
      }
    });

    this.socket.on('disconnect', (reason) => {
      console.log('[Socket] Disconnected:', reason);
    });
  }

  /**
   * Helper to register listeners
   */
  on(event: string, callback: (...args: any[]) => void) {
    this.socket?.on(event, callback);
  }

  /**
   * Helper to remove listeners
   */
  off(event: string, callback: (...args: any[]) => void) {
    this.socket?.off(event, callback);
  }

  /**
   * Safely disconnect
   */
  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
    }
  }
}

export const socketService = new SocketService();