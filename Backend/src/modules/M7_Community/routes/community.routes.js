import express from 'express';
import * as controller from '../controller/community.controller.js';
import { authenticate } from '../../../middleware/auth.middleware.js';
import { authorizeRoles } from '../../../middleware/role.middleware.js';

const router = express.Router();

router.get('/meta/online-users',authenticate,authorizeRoles('user', 'admin'),controller.getOnlineUsers);
router.get('/admin/posts',authenticate,authorizeRoles('admin'),controller.adminGetPosts);
router.post('/admin/posts/:postId/flag',authenticate,authorizeRoles('admin'),controller.adminFlagPost);
router.post('/admin/posts/:postId/unflag',authenticate,authorizeRoles('admin'),controller.adminUnflagPost);
router.delete('/admin/posts/:postId',authenticate,authorizeRoles('admin'),controller.adminDeletePost);
router.post('/',authenticate,authorizeRoles('user'),controller.createPost);
router.get('/',authenticate,authorizeRoles('user', 'admin'),controller.getPosts);
router.get('/:postId',authenticate,authorizeRoles('user', 'admin'),controller.getPostDetail);
router.patch('/:postId',authenticate,authorizeRoles('user'),controller.updatePost);
router.delete('/:postId',authenticate,authorizeRoles('user'),controller.deletePost);
router.post('/:postId/like',authenticate,authorizeRoles('user'),controller.togglePostLike);
router.post('/:postId/share',authenticate,authorizeRoles('user'),controller.sharePost);
router.post('/:postId/comments',authenticate,authorizeRoles('user'),controller.createComment);
router.get('/:postId/comments',authenticate,authorizeRoles('user', 'admin'),controller.getComments);
router.patch('/comments/:commentId',authenticate,authorizeRoles('user'),controller.updateComment);
router.delete('/comments/:commentId',authenticate,authorizeRoles('user'),controller.deleteComment);
router.post('/comments/:commentId/like',authenticate,authorizeRoles('user'),controller.toggleCommentLike);

export default router;