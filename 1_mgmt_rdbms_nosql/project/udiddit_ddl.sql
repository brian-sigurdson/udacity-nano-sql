-- GitHub:  https://github.com/brian-sigurdson/udacity-courses/tree/main/nano_sql/1_mgmt_rdbms_nosql/project
-- file: udiddit_ddl.sql

-- GUIDELINE #4
-- Your new database schema will be composed of five (5) tables that should have an auto-incrementing id as their primary key.

-------------------------------------------------------------------------------------------------------
-- drop the tables, if exist
DROP TABLE IF EXISTS udiddit_votes CASCADE;
DROP TABLE IF EXISTS udiddit_comments CASCADE;
DROP TABLE IF EXISTS udiddit_posts CASCADE;
DROP TABLE IF EXISTS udiddit_topics CASCADE;
DROP TABLE IF EXISTS udiddit_users CASCADE;

-------------------------------------------------------------------------------------------------------
-- users
CREATE TABLE udiddit_users (
    user_id SERIAL PRIMARY KEY,
    user_name VARCHAR(25) UNIQUE CHECK ( LENGTH("user_name") > 0 ),
    user_last_login DATE DEFAULT NULL,
    user_created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX users_last_login_date_idx ON udiddit_users (user_last_login);

-------------------------------------------------------------------------------------------------------
-- topics
CREATE TABLE udiddit_topics (
    topic_id SERIAL PRIMARY KEY,
    topic_name VARCHAR(30) UNIQUE CHECK ( LENGTH("topic_name") > 0 ),
    topic_description VARCHAR(500) DEFAULT NULL,
    -- According to this comment https://knowledge.udacity.com/questions/340724 a user_id is not required.
    topic_created_at TIMESTAMP DEFAULT NOW()
);

-------------------------------------------------------------------------------------------------------
-- posts
CREATE TABLE udiddit_posts (
    post_id SERIAL PRIMARY KEY,
    post_title VARCHAR(100) CHECK ( LENGTH("post_title") > 0 ),
    post_url VARCHAR(4000) DEFAULT NULL,
    post_content TEXT DEFAULT NULL,
    post_topic_id INTEGER REFERENCES udiddit_topics (topic_id) ON DELETE CASCADE NOT NULL,
    post_user_id INTEGER REFERENCES udiddit_users (user_id) ON DELETE SET NULL,
    post_created_at TIMESTAMP DEFAULT NOW(),
    -- "Posts should contain either a URL or a text post_content, but not both."
    CONSTRAINT posts_url_post_content_check CHECK (
        -- url and post_content cannot both be null
        NOT (post_url IS NULL AND post_content IS NULL) AND
        -- url and post_content cannot both be non-null
        NOT (LENGTH("post_url") > 0 AND LENGTH("post_content") > 0)
    )
);

CREATE INDEX posts_title_idx ON udiddit_posts (post_title);
CREATE INDEX posts_url_idx ON udiddit_posts (post_url);
CREATE INDEX posts_topic_id_idx ON udiddit_posts (post_topic_id);
CREATE INDEX posts_user_id_idx ON udiddit_posts (post_user_id);
CREATE INDEX posts_post_id_created_at_idx ON udiddit_posts (post_id, post_created_at);
CREATE INDEX posts_user_id_created_at_idx ON udiddit_posts (post_user_id, post_created_at);

-------------------------------------------------------------------------------------------------------
-- comments
CREATE TABLE udiddit_comments (
    comment_id SERIAL PRIMARY KEY,
    comment_text VARCHAR(100) CHECK ( LENGTH("comment_text") > 0 ),
    comment_post_id INTEGER REFERENCES udiddit_posts (post_id) ON DELETE CASCADE NOT NULL,
    comment_user_id INTEGER REFERENCES udiddit_users (user_id) ON DELETE SET NULL,
    parent_comment_id INTEGER REFERENCES udiddit_comments (comment_id) ON DELETE CASCADE DEFAULT NULL,
    comment_created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX comments_comment_text_idx ON udiddit_comments (comment_text);
CREATE INDEX comments_parent_comment_id_idx ON udiddit_comments (parent_comment_id);
CREATE INDEX comments_user_id_created_at_idx ON udiddit_comments (comment_user_id, comment_created_at);

-------------------------------------------------------------------------------------------------------
-- votes
CREATE TABLE udiddit_votes (
    votes_id SERIAL PRIMARY KEY,
    -- only -1 and 1 are acceptable values
    votes_vote SMALLINT CHECK ( votes_vote IN (-1, 1) ),
    votes_post_id INTEGER REFERENCES udiddit_posts (post_id) ON DELETE CASCADE NOT NULL,
    votes_user_id INTEGER REFERENCES udiddit_users (user_id) ON DELETE SET NULL,
    CONSTRAINT votes_post_id_user_id_key UNIQUE (votes_post_id, votes_user_id),
    votes_created_at TIMESTAMP DEFAULT NOW()
);

