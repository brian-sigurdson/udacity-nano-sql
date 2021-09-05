-- GitHub:  https://github.com/brian-sigurdson/udacity-courses/tree/main/nano_sql/1_mgmt_rdbms_nosql/project
-- file: udiddit_migration.sql

-- the following code will migrate the data from the old tables into the new tables

-------------------------------------------------------------------------------------------------------
-- populate udiddit_users table
-- get usernames from bad_comments.username
INSERT INTO udiddit_users (user_name)
SELECT DISTINCT left(trim(bc.username),25)
FROM bad_comments bc
LEFT OUTER JOIN udiddit_users u ON left(trim(bc.username),25) = u.user_name
WHERE trim(u.user_name) IS NULL;

-- get usernames from bad_posts.username
INSERT INTO udiddit_users (user_name)
SELECT DISTINCT left(trim(bp.username),25)
FROM bad_posts bp
LEFT OUTER JOIN udiddit_users u ON left(trim(bp.username),25) = u.user_name
WHERE trim(u.user_name) IS NULL;

-- get usernames from bad_posts.upvotes
INSERT INTO udiddit_users (user_name)
WITH split_table AS (
    SELECT DISTINCT left(trim(regexp_split_to_table(bp.upvotes ,',')),25) user_name
    FROM bad_posts bp
)
SELECT st.user_name
FROM split_table st
LEFT OUTER JOIN udiddit_users u ON st.user_name = u.user_name
WHERE trim(u.user_name) IS NULL;

-- get usernames from bad_posts.downvotes
INSERT INTO udiddit_users (user_name)
WITH split_table AS (
    SELECT DISTINCT left(trim(regexp_split_to_table(bp.downvotes ,',')),25) user_name
    FROM bad_posts bp
)
SELECT st.user_name
FROM split_table st
LEFT OUTER JOIN udiddit_users u ON st.user_name = u.user_name
WHERE trim(u.user_name) IS NULL;

-------------------------------------------------------------------------------------------------------
-- populate topics table
INSERT INTO udiddit_topics (topic_name)
SELECT DISTINCT left(trim(bp.topic),30)
FROM bad_posts bp
JOIN udiddit_users u ON left(trim(bp.username),25) = u.user_name;

-------------------------------------------------------------------------------------------------------
-- populate posts table
INSERT INTO udiddit_posts (post_id, post_title, post_url, post_content, post_topic_id, post_user_id)
SELECT bp.id post_id, left(trim(bp.title), 100) post_title, trim(bp.url) post_url, trim(bp.text_content) post_content,
       t.topic_id post_topic_id, u.user_id post_user_id
FROM bad_posts bp
JOIN udiddit_users u on left(trim(bp.username),25) = u.user_name
JOIN udiddit_topics t on t.topic_name = left(trim(bp.topic),30);

-------------------------------------------------------------------------------------------------------
-- populate comments table
INSERT INTO udiddit_comments (comment_text, comment_post_id, comment_user_id)
SELECT left(trim(bc.text_content), 100) comment_text, bc.post_id comment_post_id, u.user_id comment_user_id
FROM bad_comments bc
JOIN udiddit_users u on left(trim(bc.username),25) = u.user_name;

-------------------------------------------------------------------------------------------------------
-- populate votes table
-- upvotes
INSERT INTO udiddit_votes (votes_vote, votes_post_id, votes_user_id)
WITH upvoter_names AS
         (
            SELECT bp1.id AS post_id, left(trim(regexp_split_to_table(bp1.upvotes, ',')), 25) AS username
            FROM bad_posts bp1
         )
SELECT 1 AS vote, uvn.post_id AS post_id, u.user_id AS user_id
FROM udiddit_users u
JOIN upvoter_names uvn ON uvn.username = u.user_name;

-- downvotes
INSERT INTO udiddit_votes (votes_vote, votes_post_id, votes_user_id)
WITH downvoter_names AS
         (
            SELECT bp1.id AS post_id, left(trim(regexp_split_to_table(bp1.downvotes, ',')), 25) AS username
            FROM bad_posts bp1
         )
SELECT -1 AS vote, dvn.post_id AS post_id, u.user_id AS user_id
FROM udiddit_users u
JOIN downvoter_names dvn ON dvn.username = u.user_name;