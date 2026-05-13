import express from 'express';
import * as controller from '../controller/community.controller.js';
import { authenticate } from '../../../middleware/auth.middleware.js';
import { authorizeRoles } from '../../../middleware/role.middleware.js';

const router = express.Router();

router.use(authenticate);

router.get('/meta/online-users', controller.getOnlineUsers);
router.post('/create-post', controller.createPost);
router.get('/get-posts', controller.getPosts);

router.get('/admin/posts', authorizeRoles('admin'), controller.adminGetPosts);
router.post('/admin/posts/:postId/flag', authorizeRoles('admin'), controller.adminFlagPost);
router.post('/admin/posts/:postId/unflag', authorizeRoles('admin'), controller.adminUnflagPost);
router.delete('/admin/posts/:postId', authorizeRoles('admin'), controller.adminDeletePost);

router.get('/get-post/:postId', controller.getPostDetail);
router.patch('/update-post/:postId', controller.updatePost);
router.delete('/delete-post/:postId', controller.deletePost);
router.post('/toggle-post-like/:postId', controller.togglePostLike);
router.post('/share-post/:postId', controller.sharePost);

router.post('/:postId/comments', controller.createComment);
router.get('/:postId/comments', controller.getComments);
router.patch('/comments/:commentId', controller.updateComment);
router.delete('/comments/:commentId', controller.deleteComment);
router.post('/comments/:commentId/like', controller.toggleCommentLike);

export default router;