const USER_ROOM_PREFIX = "user:";
const COMMUNITY_ROOM_PREFIX = "community:";
const ADMIN_ROOM = "admin:room";

export const getUserRoom = (userId) => `${USER_ROOM_PREFIX}${userId}`;

export const getCommunityRoom = (tag) => `${COMMUNITY_ROOM_PREFIX}${tag || "GENERAL"}`;

export const getAdminRoom = () => ADMIN_ROOM;

export const resolveUserRooms = (user) => {
  const rooms = [getUserRoom(user.id)];
  if (user.preferences === "ALL") {
    rooms.push(getCommunityRoom("IELTS"), getCommunityRoom("PTE"));
  } else {
    rooms.push(getCommunityRoom(user.preferences || "GENERAL"));
  }
  if (user.role === "admin") rooms.push(getAdminRoom());
  return rooms;
};

export const switchUserCommunityRoom = (socket, newPreference) => {
  for (const room of socket.rooms) {
    if (room.startsWith(COMMUNITY_ROOM_PREFIX)) {
      socket.leave(room);
    }
  }
  if (newPreference === "ALL") {
    socket.join([getCommunityRoom("IELTS"), getCommunityRoom("PTE")]);
  } else {
    socket.join(getCommunityRoom(newPreference || "GENERAL"));
  }
};