let _io = null;

export const setSocketServer = (io) => {
  _io = io;
};

export const getSocketServer = () => _io;
