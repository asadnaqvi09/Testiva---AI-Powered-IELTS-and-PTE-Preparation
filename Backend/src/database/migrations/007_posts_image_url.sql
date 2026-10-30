-- L5: optional image on community posts (Cloudinary URL)
ALTER TABLE posts
  ADD COLUMN IF NOT EXISTS image_url TEXT NULL;
