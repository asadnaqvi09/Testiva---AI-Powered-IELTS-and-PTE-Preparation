import * as PostModel from '../models/post.model.js';
import * as CommentModel from '../models/comment.model.js';
import * as LikeModel from '../models/like.model.js';
import * as ShareModel from '../models/share.model.js';
import * as FlagModel from '../models/flag.model.js';
import { validateCreatePost, validateUpdatePost, validatePostId, validateGetPosts, validateSharePost, validateCreateComment, validateUpdateComment, validateCommentId, validateAdminFlagPost, validateAdminDeletePost } from '../validator/community.validator.js';
import { getOnlineCount } from '../../M6_AI/services/presence.service.js';
import { sendPostFlaggedEmail } from '../../../email_templates/email.service.js';
import { DEFAULT_MODERATION_REASON } from '../../../utils/email.moderation.js';
import { emitPostCreated, emitPostLiked, emitCommentCreated, emitCommentLiked, emitToUser } from '../../M9_Notification/socketIO/event.engine.js';
import { handlePostCreatedNotification, handleLikeNotification, handleCommentNotification, handleReplyNotification, handleModerationNotification, handleAdminNewPostNotification } from '../../M9_Notification/engine/notification.engine.js';
import { sendError, buildPagination } from '../../../utils/helpers.js';

const USER_PAGE_LIMIT = 10;
const ADMIN_PAGE_LIMIT = 8;

const buildCommentTree = (comments, parentId = null) =>
  comments
    .filter((comment) => (comment.parent_id ?? null) === parentId)
    .map((comment) => ({
      ...comment,
      replies: buildCommentTree(comments, comment.id),
    }));

export const createPost = async (req, res) => {
  try {
    const body = validateCreatePost(req.body);
    const post = await PostModel.createPost({
      userId: req.user.id,
      topicTag: body.topic_tag,
      title: body.title,
      content: body.content,
    });
    const fullPost = await PostModel.getPostById(post.id);
    emitPostCreated(req.io, fullPost);
    handlePostCreatedNotification(req.io, fullPost).catch(console.error);
    handleAdminNewPostNotification(req.io, fullPost).catch(console.error);
    return res.status(201).json({ success: true, data: fullPost });
  } catch (err) { return sendError(res, err); }
};

export const getPosts = async (req, res) => {
  try {
    const query = validateGetPosts(req.query);
    const page = Number(query.page || 1);
    const limit = USER_PAGE_LIMIT;
    const offset = (page - 1) * limit;
    const { posts, total } = await PostModel.getPostsPaginated({
      topicTag: query.topic_tag || 'All',
      filter: query.filter,
      search: query.search,
      limit, offset, userId: req.user.id,
    });
    return res.json({ success: true, data: posts, meta: buildPagination({ page, limit, total }) });
  } catch (err) { return sendError(res, err); }
};

export const getPostDetail = async (req, res) => {
  try {
    const { postId } = validatePostId(req.params);
    const post = await PostModel.getPostById(postId);
    if (!post) return res.status(404).json({ success: false, message: 'Post not found' });
    return res.json({ success: true, data: post });
  } catch (err) { return sendError(res, err); }
};

export const updatePost = async (req, res) => {
  try {
    const { postId } = validatePostId(req.params);
    const body = validateUpdatePost(req.body);
    const updated = await PostModel.updatePost({
      postId, userId: req.user.id, title: body.title, content: body.content,
    });
    if (!updated) return res.status(404).json({ success: false, message: 'Post not found or unauthorized' });
    const fullPost = await PostModel.getPostById(postId);
    return res.json({ success: true, data: fullPost });
  } catch (err) { return sendError(res, err); }
};

export const deletePost = async (req, res) => {
  try {
    const { postId } = validatePostId(req.params);
    const deleted = await PostModel.softDeletePost({ postId, userId: req.user.id });
    if (!deleted) return res.status(404).json({ success: false, message: 'Post not found or unauthorized' });
    return res.json({ success: true, message: 'Post deleted successfully' });
  } catch (err) { return sendError(res, err); }
};

export const togglePostLike = async (req, res) => {
  try {
    const { postId } = validatePostId(req.params);
    const result = await LikeModel.togglePostLike({ postId, userId: req.user.id });
    const likeCount = await LikeModel.getPostLikeCount(postId);
    const post = await PostModel.getPostById(postId);
    emitPostLiked(req.io, { postId, userId: req.user.id, topic_tag: post.topic_tag, likeCount });
    if (result.liked) {
      await handleLikeNotification(req.io, {
        actorId: req.user.id, actorName: req.user.full_name, postOwnerId: post.user_id, postId
      });
    }
    return res.json({ success: true, data: { ...result, like_count: likeCount } });
  } catch (err) { return sendError(res, err); }
};

export const createComment = async (req, res) => {
  try {
    const { postId } = validatePostId(req.params);
    const body = validateCreateComment(req.body);
    let parentComment = null;
    if (body.parent_id) {
      parentComment = await CommentModel.getParentCommentPostId(body.parent_id);
      if (!parentComment || parentComment.post_id !== postId) {
        return res.status(400).json({ success: false, message: 'Invalid parent comment' });
      }
    }
    const comment = await CommentModel.createComment({
      postId, userId: req.user.id, parentId: body.parent_id || null, content: body.content,
    });
    const fullComment = await CommentModel.getCommentById(comment.id);
    const post = await PostModel.getPostById(postId);
    emitCommentCreated(req.io, { comment: fullComment, topic_tag: post.topic_tag });
    try {
      if (body.parent_id && parentComment) {
        await handleReplyNotification(req.io, {
          actorId: req.user.id,
          actorName: req.user.full_name,
          parentCommentOwnerId: parentComment.user_id,
          postId,
          commentId: comment.id,
        });
      } else {
        await handleCommentNotification(req.io, {
          actorId: req.user.id, actorName: req.user.full_name, postOwnerId: post.user_id, postId
        });
      }
    } catch (notificationErr) {
      console.error("Comment notification error:", notificationErr.message);
    }
    return res.status(201).json({ success: true, data: fullComment });
  } catch (err) { return sendError(res, err); }
};

export const getComments = async (req, res) => {
  try {
    const { postId } = validatePostId(req.params);
    if (!req.user?.id) {
      return res.status(401).json({
        success: false,
        message: "Unauthorized"
      });
    }
    const comments = await CommentModel.getCommentsForPost({
      postId,
      userId: req.user.id
    });
    const nestedComments = buildCommentTree(comments);
    return res.json({ success: true, data: nestedComments });
  } catch (err) {
    console.error("getComments error:", err);
    return sendError(res, err);
  }
};

export const updateComment = async (req, res) => {
  try {
    const { commentId } = validateCommentId(req.params);
    const body = validateUpdateComment(req.body);
    const updated = await CommentModel.updateComment({
      commentId, userId: req.user.id, content: body.content,
    });
    if (!updated) return res.status(404).json({ success: false, message: 'Comment not found or unauthorized' });
    const fullComment = await CommentModel.getCommentById(commentId);
    return res.json({ success: true, data: fullComment });
  } catch (err) { return sendError(res, err); }
};

export const deleteComment = async (req, res) => {
  try {
    const { commentId } = validateCommentId(req.params);
    const deleted = await CommentModel.softDeleteComment({ commentId, userId: req.user.id });
    if (!deleted) return res.status(404).json({ success: false, message: 'Comment not found or unauthorized' });
    return res.json({ success: true, message: 'Comment deleted successfully' });
  } catch (err) { return sendError(res, err); }
};

export const toggleCommentLike = async (req, res) => {
  try {
    const { commentId } = validateCommentId(req.params);
    const result = await LikeModel.toggleCommentLike({ commentId, userId: req.user.id });
    const likeCount = await LikeModel.getCommentLikeCount(commentId);
    const comment = await CommentModel.getCommentById(commentId);
    const post = await PostModel.getPostById(comment.post_id);
    emitCommentLiked(req.io, { commentId, userId: req.user.id, topic_tag: post.topic_tag, likeCount });
    return res.json({ success: true, data: { ...result, like_count: likeCount } });
  } catch (err) { return sendError(res, err); }
};

export const getOnlineUsers = async (req, res) => {
  try {
    const onlineCount = await getOnlineCount();
    return res.json({ success: true, data: { online_count: onlineCount } });
  } catch (err) { return sendError(res, err); }
};

export const sharePost = async (req, res) => {
  try {
    const { postId } = validatePostId(req.params);
    const body = validateSharePost(req.body);
    const post = await PostModel.getPostById(postId);
    if (!post) return res.status(404).json({ success: false, message: 'Post not found' });
    await ShareModel.recordShare({ postId, userId: req.user.id, platform: body.platform });
    return res.json({ success: true, message: 'Share recorded' });
  } catch (err) { return sendError(res, err); }
};

export const adminGetPosts = async (req, res) => {
  try {
    const query = validateGetPosts(req.query);
    const page = Number(query.page || 1);
    const limit = ADMIN_PAGE_LIMIT || 10;
    const offset = (page - 1) * limit;
    const [stats, postData] = await Promise.all([
      PostModel.getAdminPostStats({
        search: query.search,
        filter: query.filter,
        topicTag: query.topic_tag
      }),
      PostModel.getPostsPaginated({
        topicTag: query.topic_tag,
        filter: query.filter,
        search: query.search,
        limit,
        offset,
        userId: req.user?.id,
      }),
    ]);
    return res.json({
      success: true,
      data: postData.posts,
      stats,
      meta: buildPagination({ page, limit, total: postData.total }),
    });
  } catch (err) {
    console.log("Error in adminGetPosts controller: ", err);
    return sendError(res, err);
  }
};

export const adminFlagPost = async (req, res) => {
  try {
    const { postId } = validatePostId(req.params);
    const body = validateAdminFlagPost(req.body);
    const post = await PostModel.getPostWithUserEmail(postId);
    if (!post) return res.status(404).json({ success: false, message: 'Post not found' });
    const adminFeedback = body.reason?.trim() || DEFAULT_MODERATION_REASON;
    await PostModel.flagPost({ postId, flaggedBy: 'admin', flagReason: adminFeedback });
    await sendPostFlaggedEmail({ email: post.email, userName: post.full_name, postTitle: post.title, adminFeedback });
    await FlagModel.insertModerationLog({ adminId: req.user.id, targetId: postId, action: 'flag', adminFeedback, emailSent: true });
    await handleModerationNotification(req.io, { postId, postOwnerId: post.user_id, adminFeedback, action: 'flag' });
    return res.json({ success: true, message: 'Post flagged' });
  } catch (err) {
    console.log("Error in adminFlagPost...", err)
    return sendError(res, err);
  }
};

export const adminUnflagPost = async (req, res) => {
  try {
    const { postId } = validatePostId(req.params);
    const post = await PostModel.getPostById(postId);
    if (!post) return res.status(404).json({ success: false, message: 'Post not found' });
    const unflagged = await PostModel.unflagPost(postId);
    if (!unflagged) return res.status(404).json({ success: false, message: 'Post not found' });
    await FlagModel.insertModerationLog({ adminId: req.user.id, targetId: postId, action: 'unflag' });
    await handleModerationNotification(req.io, { postId, postOwnerId: post.user_id, action: 'unflag' });
    return res.json({ success: true, data: unflagged });
  } catch (err) {
    console.log("Error in adminUnFlagPost...", err)
    return sendError(res, err);
  }
};

export const adminDeletePost = async (req, res) => {
  try {
    const { postId } = validatePostId(req.params);
    const body = validateAdminDeletePost(req.body);
    const post = await PostModel.getPostWithUserEmail(postId);
    if (!post) return res.status(404).json({ success: false, message: 'Post not found' });
    const adminFeedback = body.reason?.trim() || DEFAULT_MODERATION_REASON;
    await PostModel.adminDeletePost(postId);
    await sendPostFlaggedEmail({ email: post.email, userName: post.full_name, postTitle: post.title, adminFeedback });
    await FlagModel.insertModerationLog({ adminId: req.user.id, targetId: postId, action: 'delete', adminFeedback, emailSent: true });
    await handleModerationNotification(req.io, { postId, postOwnerId: post.user_id, adminFeedback, action: 'delete' });
    return res.json({ success: true, message: 'Post deleted' });
  } catch (err) { return sendError(res, err); }
};