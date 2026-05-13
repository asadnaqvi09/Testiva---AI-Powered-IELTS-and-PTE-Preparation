import pool from '../../../config/db.js';

export const createPost = async ({ userId, topicTag, title, content }) => {
  const result = await pool.query(
    `INSERT INTO posts (user_id, topic_tag, title, content)
     VALUES ($1, $2, $3, $4)
     RETURNING id, user_id, topic_tag, title, content, is_flagged,created_at`,
    [userId, topicTag, title, content]
  );
  return result.rows[0];
};

export const getPostById = async (postId) => {
  const result = await pool.query(
    `SELECT 
        p.id,
        p.user_id,
        p.topic_tag,
        p.title,
        p.content,
        p.is_flagged,
        p.flagged_by,
        p.flag_reason,
        p.created_at,
        p.updated_at,
        u.full_name,
        u.avatar_url,
        u.subscription AS subscription_type,
        COUNT(DISTINCT pl.user_id)::INT AS like_count,
        COUNT(DISTINCT c.id)::INT AS comment_count,
        COUNT(DISTINCT ps.id)::INT AS share_count
     FROM posts p
     JOIN users u 
        ON u.id = p.user_id
     LEFT JOIN post_likes pl
        ON pl.post_id = p.id
     LEFT JOIN comments c
        ON c.post_id = p.id
        AND c.deleted_at IS NULL
     LEFT JOIN post_shares ps
        ON ps.post_id = p.id
     WHERE p.id = $1
     AND p.deleted_at IS NULL
     GROUP BY 
        p.id,
        u.full_name,
        u.avatar_url,
        u.subscription`,
    [postId]
  );
  return result.rows[0] || null;
};

export const getPostWithUserEmail = async (postId) => {
  const result = await pool.query(
    `SELECT p.id, p.title, p.user_id,
            u.full_name, u.email
     FROM posts p
     JOIN users u ON u.id = p.user_id
     WHERE p.id = $1 AND p.deleted_at IS NULL`,
    [postId]
  );
  return result.rows[0] || null;
};

export const getPostsPaginated = async ({ topicTag, filter, search, limit, offset, userId }) => {
  const conditions = ['p.deleted_at IS NULL'];
  const params = [];
  let i = 1;
  if (topicTag && topicTag !== 'ALL') {
    conditions.push(`p.topic_tag = $${i++}`);
    params.push(topicTag);
  }
  if (filter === 'flagged') {
    conditions.push('p.is_flagged = TRUE');
  } else if (filter === 'clean') {
    conditions.push('p.is_flagged = FALSE');
  }
  if (search) {
    conditions.push(`(u.full_name ILIKE $${i} OR u.email ILIKE $${i} OR p.topic_tag::TEXT ILIKE $${i})`);
    params.push(`%${search}%`);
    i++;
  }
  const where = conditions.join(' AND ');
  const likedIdx = i;       
  const limitIdx = i + 1;   
  const offsetIdx = i + 2;  
  const dataParams = [...params, userId, limit, offset];
  const countParams = [...params];
  const [rows, countRow] = await Promise.all([
    pool.query(
      `SELECT p.id, p.user_id, p.topic_tag, p.title, p.content,
              p.is_flagged, p.flagged_by, p.flag_reason,
              p.created_at, p.updated_at,
              u.full_name, u.avatar_url, u.email,
              COUNT(DISTINCT pl.user_id)::INT AS like_count,
              COUNT(DISTINCT c.id)::INT        AS comment_count,
              COUNT(DISTINCT ps.id)::INT       AS share_count,
              EXISTS(
                SELECT 1 FROM post_likes pl2
                WHERE pl2.post_id = p.id AND pl2.user_id = $${likedIdx}
              ) AS liked_by_me
       FROM posts p
       JOIN users u ON u.id = p.user_id
       LEFT JOIN post_likes pl   ON pl.post_id = p.id
       LEFT JOIN comments c      ON c.post_id = p.id AND c.deleted_at IS NULL
       LEFT JOIN post_shares ps  ON ps.post_id = p.id
       WHERE ${where}
       GROUP BY p.id, u.full_name, u.avatar_url, u.email -- FIXED: u.email added here to satisfy Postgres rules
       ORDER BY p.created_at DESC
       LIMIT $${limitIdx} OFFSET $${offsetIdx}`,
      dataParams
    ),
    pool.query(
      `SELECT COUNT(DISTINCT p.id)::INT AS total
       FROM posts p
       JOIN users u ON u.id = p.user_id
       WHERE ${where}`,
      countParams
    ),
  ]);
  return { posts: rows.rows, total: countRow.rows[0]?.total || 0 };
};

export const updatePost = async ({ postId, userId, title, content }) => {
  const result = await pool.query(
    `UPDATE posts
     SET title = COALESCE($1, title),
         content = COALESCE($2, content),
         updated_at = NOW()
     WHERE id = $3 AND user_id = $4 AND deleted_at IS NULL
     RETURNING id, title, content, updated_at`,
    [title, content, postId, userId]
  );
  return result.rows[0] || null;
};

export const softDeletePost = async ({ postId, userId }) => {
  const result = await pool.query(
    `UPDATE posts SET deleted_at = NOW()
     WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL
     RETURNING id`,
    [postId, userId]
  );
  return result.rows[0] || null;
};

export const adminDeletePost = async (postId) => {
  const result = await pool.query(
    `UPDATE posts SET deleted_at = NOW()
     WHERE id = $1 AND deleted_at IS NULL
     RETURNING id`,
    [postId]
  );
  return result.rows[0] || null;
};

export const flagPost = async ({ postId, flaggedBy, flagReason }) => {
  const result = await pool.query(
    `UPDATE posts
     SET is_flagged = TRUE, flagged_by = $1, flag_reason = $2, updated_at = NOW()
     WHERE id = $3 AND deleted_at IS NULL
     RETURNING id, is_flagged, flagged_by, flag_reason`,
    [flaggedBy, flagReason, postId]
  );
  return result.rows[0] || null;
};

export const unflagPost = async (postId) => {
  const result = await pool.query(
    `UPDATE posts
     SET is_flagged = FALSE, flagged_by = NULL, flag_reason = NULL, updated_at = NOW()
     WHERE id = $1 AND deleted_at IS NULL
     RETURNING id`,
    [postId]
  );
  return result.rows[0] || null;
};

export const getAdminPostStats = async ({ search, filter, topicTag }) => {
  const conditions = ['p.deleted_at IS NULL'];
  const params = [];
  let i = 1;
  if (topicTag && topicTag !== 'ALL') {
    conditions.push(`p.topic_tag = $${i++}`);
    params.push(topicTag);
  }
  if (filter === 'flagged') {
    conditions.push('p.is_flagged = TRUE');
  } else if (filter === 'clean') {
    conditions.push('p.is_flagged = FALSE');
  }
  if (search) {
    conditions.push(`(u.full_name ILIKE $${i} OR u.email ILIKE $${i} OR p.topic_tag::TEXT ILIKE $${i})`);
    params.push(`%${search}%`);
    i++;
  }
  const whereClause = conditions.join(' AND ');
  const result = await pool.query(
    `SELECT
       COUNT(DISTINCT p.id)::INT AS total_posts,
       COUNT(DISTINCT p.id) FILTER (WHERE p.is_flagged = TRUE)::INT AS flagged_posts,
       COUNT(DISTINCT p.id) FILTER (WHERE p.is_flagged = FALSE)::INT AS clean_posts, -- ADDED: Clean posts counter
       COUNT(DISTINCT p.id) FILTER (WHERE p.created_at >= CURRENT_DATE)::INT AS today_posts
     FROM posts p
     JOIN users u ON u.id = p.user_id
     WHERE ${whereClause}`,
    params
  );
  return result.rows[0] || { total_posts: 0, flagged_posts: 0, clean_posts: 0, today_posts: 0 };
};