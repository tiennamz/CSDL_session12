CREATE DATABASE social_network_ss12;
use social_network_ss12;

CREATE TABLE users(
	user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
	post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id  INT,
    content  TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)  ON DELETE CASCADE
);

CREATE TABLE comments (
	comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT ,
    user_id INT ,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, 
    FOREIGN KEY (post_id) REFERENCES  posts(post_id) ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES  users(user_id) ON DELETE CASCADE
);

CREATE TABLE friends(
	user_id INT ,
    friend_id INT, 
    status VARCHAR(20) CHECK (status IN ('pending','accepted')),
    PRIMARY KEY (user_id, friend_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (friend_id) REFERENCES users (user_id) ON DELETE CASCADE,
    CHECK (user_id != friend_id)
);

CREATE TABLE likes(
	user_id INT ,
    post_id INT ,
    PRIMARY KEY (user_id,post_id),
	FOREIGN KEY (user_id)  REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id)  REFERENCES posts(post_id) ON DELETE CASCADE
);

INSERT INTO users(username,password, email) 
VALUES 
('Vu Anh Duc','123','vuanhduc@gmail.com'),
('Nguyen Hai Duong','123','haiduong@gmail.com'),
('Minh Hieu','123','minhhieu@gmail.com');

-- Posts
INSERT INTO posts(user_id, content) VALUES
(1, 'Hello world'),
(2, 'My first post'),
(3, 'Good morning');

-- Likes
INSERT INTO likes(user_id, post_id) VALUES
(2,1),
(3,1),
(1,2);

-- Comments
INSERT INTO comments(user_id, post_id, content) VALUES
(2,1,'Nice'),
(3,1,'Great'),
(1,2,'Cool');

-- Friends
INSERT INTO friends(user_id, friend_id, status) VALUES
(1,2,'accepted'),
(1,3,'accepted'),
(2,3,'pending');

-- REQ-01: Hiển thị hồ sơ người dùng an toàn
CREATE VIEW vw_UserInfo
AS SELECT 
	user_id, 
	username, email, 
	created_at
FROM users;

SELECT * FROM vw_UserInfo;

-- REQ-02: Báo cáo tương tác bài viết
CREATE VIEW vw_PostStatistics
AS SELECT 
	p.post_id,
    p.content,
    u.username,
    COUNT( l.user_id) AS total_likes,
    COUNT( c.comment_id) AS total_comments
FROM posts p
LEFT JOIN comments c
ON c.post_id = p.post_id
LEFT JOIN likes l 
ON l.post_id = p.post_id
INNER JOIN users u
ON u.user_id = p.user_id
GROUP BY 
	p.post_id,	
	p.content,
    u.username;
    
SELECT * FROM vw_PostStatistics;

-- REQ-03: Đăng ký người dùng mới 
DELIMITER //
CREATE PROCEDURE add_user (
	IN u_username VARCHAR(50),
    IN u_password VARCHAR(255),
    IN u_email VARCHAR(100),
    OUT message VARCHAR(50)
)

BEGIN
	IF(u_email IN(
		SELECT email
        FROM users
    )) THEN SET message = 'Email đã được sử dụng';
	ELSE 
		INSERT INTO users(username,password,email) 
        VALUES
			(u_username, u_password, u_email);
    END IF;
END //
 
DELIMITER ;

CALL add_user('TIen Nam', '12345','vuanhducddd@gmail.com', @errorss );

SELECT @errorss


-- REQ-04: Đăng bài viết mới 	    
DELIMITER //
CREATE PROCEDURE add_post (
	IN p_user_id INT,
    IN p_content TEXT,
    OUT p_post_id INT
)

BEGIN
	INSERT INTO posts(user_id,content) 
    VALUES (p_user_id, p_content);
    
    SELECT post_id INTO p_post_id
    FROM posts 
    ORDER BY post_id 
    DESC LIMIT 1;
    
END //
 
DELIMITER ;

    
CALL add_post(1,'mysql', @id);
SELECT @id AS id_post_last;
    
    
-- REQ-05: Lấy danh sách bạn bè phân trang 
DELIMITER //
CREATE PROCEDURE find_friends (
	IN f_user_id INT,
    IN f_limit INT,
    IN f_offset INT
)

BEGIN
	SELECT 
		username, 
        email 
	FROM friends f
    INNER JOIN users u
    ON u.user_id = f.friend_id
    WHERE f.user_id = f_user_id AND f.status = 'accepted'
    LIMIT f_limit
    OFFSET f_offset;
END //
	
DELIMITER ;

CALL find_friends(1, 5, 0);
    
CREATE INDEX idx_posts_created_at 
ON Posts(created_at );
