-- ============================================================
--  SQL-BASED PLAGIARISM DETECTION SYSTEM
--  Course: UCS310 – Database Management Systems
--  Group: Parv Panwar (1024030226) | Manan Dhingra (1024030222)
--  Institute: COE, Thapar Institute of Engineering Technology
--  Academic Year: 2025-2026
-- ============================================================

-- ============================================================
-- SECTION 1: DDL – CREATE TABLES
-- ============================================================

-- Drop tables if they already exist (for re-runs)
DROP TABLE IF EXISTS PLAGIARISM_REPORT;
DROP TABLE IF EXISTS TOKEN;
DROP TABLE IF EXISTS SUBMISSION;
DROP TABLE IF EXISTS ASSIGNMENT;
DROP TABLE IF EXISTS STUDENT;
DROP TABLE IF EXISTS COURSE;
DROP TABLE IF EXISTS FACULTY;

-- FACULTY Table
CREATE TABLE FACULTY (
    Faculty_ID   INT          PRIMARY KEY AUTO_INCREMENT,
    Name         VARCHAR(100) NOT NULL,
    Email        VARCHAR(100) UNIQUE NOT NULL,
    Department   VARCHAR(100) NOT NULL
);

-- COURSE Table
CREATE TABLE COURSE (
    Course_ID    VARCHAR(20)  PRIMARY KEY,
    Course_Name  VARCHAR(100) NOT NULL,
    Faculty_ID   INT,
    Credits      INT CHECK (Credits BETWEEN 1 AND 6),
    FOREIGN KEY (Faculty_ID) REFERENCES FACULTY(Faculty_ID)
        ON DELETE SET NULL
);

-- STUDENT Table
CREATE TABLE STUDENT (
    Student_ID   INT          PRIMARY KEY AUTO_INCREMENT,
    Name         VARCHAR(100) NOT NULL,
    Roll_No      VARCHAR(20)  UNIQUE NOT NULL,
    Email        VARCHAR(100) UNIQUE NOT NULL,
    Course_ID    VARCHAR(20),
    FOREIGN KEY (Course_ID) REFERENCES COURSE(Course_ID)
        ON DELETE SET NULL
);

-- ASSIGNMENT Table
CREATE TABLE ASSIGNMENT (
    Assignment_ID   INT          PRIMARY KEY AUTO_INCREMENT,
    Title           VARCHAR(200) NOT NULL,
    Course_ID       VARCHAR(20)  NOT NULL,
    Due_Date        DATE         NOT NULL,
    Max_Marks       INT          DEFAULT 100,
    FOREIGN KEY (Course_ID) REFERENCES COURSE(Course_ID)
        ON DELETE CASCADE
);

-- SUBMISSION Table
CREATE TABLE SUBMISSION (
    Submission_ID    INT          PRIMARY KEY AUTO_INCREMENT,
    Student_ID       INT          NOT NULL,
    Assignment_ID    INT          NOT NULL,
    Submission_Text  TEXT         NOT NULL,
    Submitted_At     DATETIME     DEFAULT CURRENT_TIMESTAMP,
    Word_Count       INT          DEFAULT 0,
    Is_Flagged       BOOLEAN      DEFAULT FALSE,
    UNIQUE (Student_ID, Assignment_ID),        -- one submission per student per assignment
    FOREIGN KEY (Student_ID)    REFERENCES STUDENT(Student_ID)    ON DELETE CASCADE,
    FOREIGN KEY (Assignment_ID) REFERENCES ASSIGNMENT(Assignment_ID) ON DELETE CASCADE
);

-- TOKEN Table (tokenised words from each submission)
CREATE TABLE TOKEN (
    Token_ID       INT          PRIMARY KEY AUTO_INCREMENT,
    Submission_ID  INT          NOT NULL,
    Token_Text     VARCHAR(100) NOT NULL,
    Frequency      INT          DEFAULT 1,
    FOREIGN KEY (Submission_ID) REFERENCES SUBMISSION(Submission_ID)
        ON DELETE CASCADE
);

-- PLAGIARISM_REPORT Table
CREATE TABLE PLAGIARISM_REPORT (
    Report_ID              INT     PRIMARY KEY AUTO_INCREMENT,
    Submission1_ID         INT     NOT NULL,
    Submission2_ID         INT     NOT NULL,
    Similarity_Percentage  DECIMAL(5,2) NOT NULL
                           CHECK (Similarity_Percentage BETWEEN 0 AND 100),
    Generated_At           DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status                 ENUM('PENDING','REVIEWED','DISMISSED') DEFAULT 'PENDING',
    CHECK (Submission1_ID < Submission2_ID),   -- avoid duplicate pairs
    FOREIGN KEY (Submission1_ID) REFERENCES SUBMISSION(Submission_ID) ON DELETE CASCADE,
    FOREIGN KEY (Submission2_ID) REFERENCES SUBMISSION(Submission_ID) ON DELETE CASCADE
);


-- ============================================================
-- SECTION 2: DML – INSERT SAMPLE DATA
-- ============================================================

-- Faculty
INSERT INTO FACULTY (Name, Email, Department) VALUES
('Dr. Rajesh Kumar',   'rajesh.kumar@tiet.edu',   'Computer Engineering'),
('Dr. Priya Sharma',   'priya.sharma@tiet.edu',    'Computer Engineering'),
('Prof. Anil Verma',   'anil.verma@tiet.edu',      'Computer Engineering');

-- Courses
INSERT INTO COURSE (Course_ID, Course_Name, Faculty_ID, Credits) VALUES
('UCS310', 'Database Management Systems',   1, 4),
('UCS301', 'Data Structures & Algorithms',  2, 4),
('UCS401', 'Operating Systems',             3, 3);

-- Students
INSERT INTO STUDENT (Name, Roll_No, Email, Course_ID) VALUES
('Parv Panwar',    '1024030226', 'parv.panwar@thapar.edu',    'UCS310'),
('Manan Dhingra',  '1024030222', 'manan.dhingra@thapar.edu',  'UCS310'),
('Ayesha Khan',    '1024030201', 'ayesha.khan@thapar.edu',    'UCS310'),
('Rohan Mehra',    '1024030210', 'rohan.mehra@thapar.edu',    'UCS310'),
('Simran Bhatia',  '1024030215', 'simran.bhatia@thapar.edu',  'UCS310'),
('Karan Gupta',    '1024030230', 'karan.gupta@thapar.edu',    'UCS310');

-- Assignments
INSERT INTO ASSIGNMENT (Title, Course_ID, Due_Date, Max_Marks) VALUES
('ER Diagram and Normalization',   'UCS310', '2025-10-15', 30),
('SQL Query Implementation',       'UCS310', '2025-11-10', 40),
('Transactions and Concurrency',   'UCS310', '2025-12-05', 30);

-- Submissions (deliberately overlapping text to trigger similarity)
INSERT INTO SUBMISSION (Student_ID, Assignment_ID, Submission_Text, Word_Count) VALUES
(1, 1,
 'An ER diagram represents entities attributes and relationships in a database system. Normalization removes redundancy and ensures data integrity using 1NF 2NF and 3NF forms.',
 30),
(2, 1,
 'ER diagram represents entities attributes relationships in database. Normalization removes redundancy ensures data integrity using 1NF 2NF 3NF forms to avoid anomalies.',
 28),
(3, 1,
 'Entity Relationship diagram models the data and its associations. We convert it into relational tables and apply normalization to eliminate data redundancy in the schema.',
 29),
(4, 1,
 'Database design starts with identifying entities and their attributes. The ER model is then mapped to relational tables and normalized to achieve consistency and reduce redundancy.',
 30),
(5, 1,
 'An entity relationship diagram shows how data is structured in a relational database. Normalization removes redundancy and maintains data integrity through normal forms.',
 29),
(6, 1,
 'SQL is a language for managing relational databases. Queries like SELECT JOIN and GROUP BY help retrieve and manipulate data stored in multiple related tables effectively.',
 27);

-- Tokens for Submission 1
INSERT INTO TOKEN (Submission_ID, Token_Text, Frequency) VALUES
(1,'er',1),(1,'diagram',2),(1,'represents',1),(1,'entities',2),(1,'attributes',2),
(1,'relationships',1),(1,'database',2),(1,'normalization',2),(1,'removes',1),
(1,'redundancy',1),(1,'ensures',1),(1,'data',3),(1,'integrity',1),
(1,'1nf',1),(1,'2nf',1),(1,'3nf',1);

-- Tokens for Submission 2
INSERT INTO TOKEN (Submission_ID, Token_Text, Frequency) VALUES
(2,'er',1),(2,'diagram',2),(2,'represents',1),(2,'entities',2),(2,'attributes',2),
(2,'relationships',1),(2,'database',2),(2,'normalization',2),(2,'removes',1),
(2,'redundancy',1),(2,'ensures',1),(2,'data',3),(2,'integrity',1),
(2,'1nf',1),(2,'2nf',1),(2,'3nf',1),(2,'forms',1),(2,'avoid',1),(2,'anomalies',1);

-- Tokens for Submission 3-6 (abbreviated)
INSERT INTO TOKEN (Submission_ID, Token_Text, Frequency) VALUES
(3,'entity',1),(3,'relationship',1),(3,'diagram',1),(3,'data',2),(3,'associations',1),
(3,'relational',1),(3,'tables',1),(3,'normalization',1),(3,'redundancy',1),(3,'schema',1);
INSERT INTO TOKEN (Submission_ID, Token_Text, Frequency) VALUES
(4,'database',2),(4,'entities',1),(4,'attributes',1),(4,'er',1),(4,'model',1),
(4,'relational',1),(4,'tables',1),(4,'normalized',1),(4,'consistency',1),(4,'redundancy',1);
INSERT INTO TOKEN (Submission_ID, Token_Text, Frequency) VALUES
(5,'entity',1),(5,'relationship',1),(5,'diagram',1),(5,'data',2),(5,'database',1),
(5,'normalization',1),(5,'removes',1),(5,'redundancy',1),(5,'integrity',1),(5,'forms',1);
INSERT INTO TOKEN (Submission_ID, Token_Text, Frequency) VALUES
(6,'sql',2),(6,'language',1),(6,'relational',1),(6,'databases',1),(6,'queries',1),
(6,'select',1),(6,'join',1),(6,'group',1),(6,'retrieve',1),(6,'tables',2);


-- ============================================================
-- SECTION 3: SELECT QUERIES
-- ============================================================

-- 3.1  All students enrolled in UCS310
SELECT s.Student_ID, s.Name, s.Roll_No, s.Email
FROM   STUDENT s
JOIN   COURSE  c ON s.Course_ID = c.Course_ID
WHERE  c.Course_ID = 'UCS310';

-- 3.2  All submissions for Assignment 1 with student names
SELECT su.Submission_ID,
       st.Name        AS Student_Name,
       st.Roll_No,
       su.Submitted_At,
       su.Word_Count,
       su.Is_Flagged
FROM   SUBMISSION su
JOIN   STUDENT    st ON su.Student_ID = st.Student_ID
WHERE  su.Assignment_ID = 1
ORDER  BY su.Submission_ID;

-- 3.3  Top 10 most frequent tokens across all submissions
SELECT Token_Text,
       SUM(Frequency) AS Total_Frequency
FROM   TOKEN
GROUP  BY Token_Text
ORDER  BY Total_Frequency DESC
LIMIT  10;

-- 3.4  Submissions flagged for plagiarism (Is_Flagged = TRUE)
SELECT su.Submission_ID,
       st.Name        AS Student_Name,
       st.Roll_No,
       a.Title        AS Assignment_Title,
       su.Is_Flagged
FROM   SUBMISSION su
JOIN   STUDENT    st ON su.Student_ID    = st.Student_ID
JOIN   ASSIGNMENT a  ON su.Assignment_ID = a.Assignment_ID
WHERE  su.Is_Flagged = TRUE;

-- 3.5  Count of submissions per assignment
SELECT a.Assignment_ID,
       a.Title,
       COUNT(su.Submission_ID) AS Total_Submissions
FROM   ASSIGNMENT a
LEFT   JOIN SUBMISSION su ON a.Assignment_ID = su.Assignment_ID
GROUP  BY a.Assignment_ID, a.Title;

-- 3.6  Students who have NOT submitted Assignment 1
SELECT s.Student_ID, s.Name, s.Roll_No
FROM   STUDENT s
WHERE  s.Course_ID = 'UCS310'
  AND  s.Student_ID NOT IN (
       SELECT Student_ID FROM SUBMISSION WHERE Assignment_ID = 1
  );

-- 3.7  Average word count per assignment
SELECT a.Title,
       ROUND(AVG(su.Word_Count), 2) AS Avg_Word_Count,
       MIN(su.Word_Count)           AS Min_Words,
       MAX(su.Word_Count)           AS Max_Words
FROM   SUBMISSION su
JOIN   ASSIGNMENT a ON su.Assignment_ID = a.Assignment_ID
GROUP  BY a.Assignment_ID, a.Title;

-- 3.8  Common tokens between Submission 1 and Submission 2
SELECT t1.Token_Text,
       t1.Frequency AS Freq_Sub1,
       t2.Frequency AS Freq_Sub2
FROM   TOKEN t1
JOIN   TOKEN t2 ON t1.Token_Text = t2.Token_Text
WHERE  t1.Submission_ID = 1
  AND  t2.Submission_ID = 2
ORDER  BY t1.Token_Text;

-- 3.9  Similarity % between every pair of submissions for Assignment 1
--      Formula: (common tokens / min(total tokens of each)) * 100
SELECT s1.Submission_ID  AS Sub1,
       st1.Roll_No        AS Student1,
       s2.Submission_ID  AS Sub2,
       st2.Roll_No        AS Student2,
       ROUND(
           (SELECT COUNT(*)
            FROM TOKEN t1
            JOIN TOKEN t2 ON t1.Token_Text = t2.Token_Text
            WHERE t1.Submission_ID = s1.Submission_ID
              AND t2.Submission_ID = s2.Submission_ID)
           /
           NULLIF(
               LEAST(
                   (SELECT COUNT(*) FROM TOKEN WHERE Submission_ID = s1.Submission_ID),
                   (SELECT COUNT(*) FROM TOKEN WHERE Submission_ID = s2.Submission_ID)
               ), 0
           ) * 100
       , 2) AS Similarity_Pct
FROM   SUBMISSION s1
JOIN   SUBMISSION s2  ON s1.Submission_ID < s2.Submission_ID
JOIN   STUDENT    st1 ON s1.Student_ID = st1.Student_ID
JOIN   STUDENT    st2 ON s2.Student_ID = st2.Student_ID
WHERE  s1.Assignment_ID = 1
  AND  s2.Assignment_ID = 1
ORDER  BY Similarity_Pct DESC;


-- ============================================================
-- SECTION 4: VIEWS
-- ============================================================

-- View 1: Full plagiarism report with student names
CREATE OR REPLACE VIEW vw_Plagiarism_Report AS
SELECT
    pr.Report_ID,
    st1.Name             AS Student1_Name,
    st1.Roll_No          AS Student1_Roll,
    st2.Name             AS Student2_Name,
    st2.Roll_No          AS Student2_Roll,
    a.Title              AS Assignment,
    pr.Similarity_Percentage,
    pr.Status,
    pr.Generated_At
FROM   PLAGIARISM_REPORT pr
JOIN   SUBMISSION         s1  ON pr.Submission1_ID = s1.Submission_ID
JOIN   SUBMISSION         s2  ON pr.Submission2_ID = s2.Submission_ID
JOIN   STUDENT            st1 ON s1.Student_ID      = st1.Student_ID
JOIN   STUDENT            st2 ON s2.Student_ID      = st2.Student_ID
JOIN   ASSIGNMENT         a   ON s1.Assignment_ID   = a.Assignment_ID;

-- View 2: High-risk plagiarism pairs (>= 70% similarity)
CREATE OR REPLACE VIEW vw_High_Risk_Pairs AS
SELECT * FROM vw_Plagiarism_Report
WHERE  Similarity_Percentage >= 70.00;

-- View 3: Submission summary per student
CREATE OR REPLACE VIEW vw_Student_Submission_Summary AS
SELECT
    st.Student_ID,
    st.Name,
    st.Roll_No,
    COUNT(su.Submission_ID)        AS Total_Submissions,
    SUM(su.Is_Flagged)             AS Flagged_Count,
    ROUND(AVG(su.Word_Count), 0)   AS Avg_Word_Count
FROM   STUDENT    st
LEFT   JOIN SUBMISSION su ON st.Student_ID = su.Student_ID
GROUP  BY st.Student_ID, st.Name, st.Roll_No;


-- ============================================================
-- SECTION 5: STORED PROCEDURES
-- ============================================================

DELIMITER $$

-- Procedure 1: Calculate similarity between two submissions and insert report
CREATE PROCEDURE sp_Calculate_Similarity(
    IN  p_sub1_id INT,
    IN  p_sub2_id INT,
    OUT p_similarity DECIMAL(5,2)
)
BEGIN
    DECLARE v_common_tokens INT DEFAULT 0;
    DECLARE v_total_sub1    INT DEFAULT 0;
    DECLARE v_total_sub2    INT DEFAULT 0;
    DECLARE v_min_tokens    INT DEFAULT 0;

    -- Count tokens unique to each submission
    SELECT COUNT(*) INTO v_total_sub1 FROM TOKEN WHERE Submission_ID = p_sub1_id;
    SELECT COUNT(*) INTO v_total_sub2 FROM TOKEN WHERE Submission_ID = p_sub2_id;

    -- Count common tokens (matching Token_Text in both submissions)
    SELECT COUNT(*) INTO v_common_tokens
    FROM TOKEN t1
    JOIN TOKEN t2 ON t1.Token_Text = t2.Token_Text
    WHERE t1.Submission_ID = p_sub1_id
      AND t2.Submission_ID = p_sub2_id;

    -- Use the smaller submission as denominator (conservative similarity)
    SET v_min_tokens = LEAST(v_total_sub1, v_total_sub2);

    IF v_min_tokens = 0 THEN
        SET p_similarity = 0.00;
    ELSE
        SET p_similarity = ROUND((v_common_tokens / v_min_tokens) * 100, 2);
    END IF;

    -- Ensure pair ordering: smaller ID first
    IF p_sub1_id > p_sub2_id THEN
        SET @tmp = p_sub1_id;
        SET p_sub1_id = p_sub2_id;
        SET p_sub2_id = @tmp;
    END IF;

    -- Insert or update plagiarism report
    INSERT INTO PLAGIARISM_REPORT
        (Submission1_ID, Submission2_ID, Similarity_Percentage)
    VALUES
        (p_sub1_id, p_sub2_id, p_similarity)
    ON DUPLICATE KEY UPDATE
        Similarity_Percentage = p_similarity,
        Generated_At = CURRENT_TIMESTAMP;

    SELECT CONCAT('Similarity between Sub ', p_sub1_id,
                  ' and Sub ', p_sub2_id,
                  ' = ', p_similarity, '%') AS Result;
END$$


-- Procedure 2: Run similarity check for ALL pairs in one assignment
CREATE PROCEDURE sp_Run_Plagiarism_Check(IN p_assignment_id INT)
BEGIN
    DECLARE v_done  INT DEFAULT FALSE;
    DECLARE v_sub1  INT;
    DECLARE v_sub2  INT;
    DECLARE v_sim   DECIMAL(5,2);

    -- Cursor over all distinct ordered pairs of submissions
    DECLARE cur CURSOR FOR
        SELECT s1.Submission_ID, s2.Submission_ID
        FROM   SUBMISSION s1
        JOIN   SUBMISSION s2 ON s1.Submission_ID < s2.Submission_ID
        WHERE  s1.Assignment_ID = p_assignment_id
          AND  s2.Assignment_ID = p_assignment_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_sub1, v_sub2;
        IF v_done THEN LEAVE read_loop; END IF;
        CALL sp_Calculate_Similarity(v_sub1, v_sub2, v_sim);
    END LOOP;
    CLOSE cur;

    SELECT CONCAT('Plagiarism check complete for Assignment ID: ',
                  p_assignment_id) AS Status;
END$$


-- Procedure 3: Tokenize a submission (split text into word tokens)
CREATE PROCEDURE sp_Tokenize_Submission(IN p_submission_id INT)
BEGIN
    DECLARE v_text      TEXT;
    DECLARE v_word      VARCHAR(100);
    DECLARE v_pos       INT DEFAULT 1;
    DECLARE v_len       INT;
    DECLARE v_space_pos INT;

    -- Fetch and lowercase submission text
    SELECT LOWER(TRIM(Submission_Text))
    INTO   v_text
    FROM   SUBMISSION
    WHERE  Submission_ID = p_submission_id;

    SET v_len = CHAR_LENGTH(v_text);

    -- Clear existing tokens for this submission
    DELETE FROM TOKEN WHERE Submission_ID = p_submission_id;

    -- Simple word-by-word tokenizer (space-delimited)
    WHILE v_pos <= v_len DO
        SET v_space_pos = LOCATE(' ', v_text, v_pos);
        IF v_space_pos = 0 THEN
            SET v_word      = SUBSTRING(v_text, v_pos);
            SET v_pos       = v_len + 1;
        ELSE
            SET v_word      = SUBSTRING(v_text, v_pos, v_space_pos - v_pos);
            SET v_pos       = v_space_pos + 1;
        END IF;

        SET v_word = TRIM(v_word);

        IF v_word <> '' AND CHAR_LENGTH(v_word) > 1 THEN
            -- Upsert: increment frequency if token already exists
            INSERT INTO TOKEN (Submission_ID, Token_Text, Frequency)
            VALUES (p_submission_id, v_word, 1)
            ON DUPLICATE KEY UPDATE Frequency = Frequency + 1;
        END IF;
    END WHILE;

    -- Update word count in SUBMISSION
    UPDATE SUBMISSION
    SET    Word_Count = (SELECT COUNT(*) FROM TOKEN WHERE Submission_ID = p_submission_id)
    WHERE  Submission_ID = p_submission_id;

    SELECT CONCAT('Tokenization complete for Submission ID: ',
                  p_submission_id) AS Status;
END$$

DELIMITER ;


-- ============================================================
-- SECTION 6: FUNCTIONS
-- ============================================================

DELIMITER $$

-- Function 1: Return number of tokens in a submission
CREATE FUNCTION fn_Token_Count(p_submission_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count
    FROM   TOKEN
    WHERE  Submission_ID = p_submission_id;
    RETURN IFNULL(v_count, 0);
END$$

-- Function 2: Return similarity % between two submissions
CREATE FUNCTION fn_Similarity(p_sub1 INT, p_sub2 INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_common INT;
    DECLARE v_min    INT;

    SELECT COUNT(*) INTO v_common
    FROM TOKEN t1
    JOIN TOKEN t2 ON t1.Token_Text = t2.Token_Text
    WHERE t1.Submission_ID = p_sub1
      AND t2.Submission_ID = p_sub2;

    SET v_min = LEAST(fn_Token_Count(p_sub1), fn_Token_Count(p_sub2));

    IF v_min = 0 THEN RETURN 0.00; END IF;
    RETURN ROUND((v_common / v_min) * 100, 2);
END$$

-- Function 3: Check if a submission is high-risk (>= threshold)
CREATE FUNCTION fn_Is_High_Risk(p_submission_id INT, p_threshold DECIMAL(5,2))
RETURNS VARCHAR(3)
DETERMINISTIC
BEGIN
    DECLARE v_max_sim DECIMAL(5,2);

    SELECT COALESCE(MAX(Similarity_Percentage), 0)
    INTO   v_max_sim
    FROM   PLAGIARISM_REPORT
    WHERE  Submission1_ID = p_submission_id
       OR  Submission2_ID = p_submission_id;

    IF v_max_sim >= p_threshold THEN
        RETURN 'YES';
    ELSE
        RETURN 'NO';
    END IF;
END$$

DELIMITER ;


-- ============================================================
-- SECTION 7: TRIGGERS
-- ============================================================

DELIMITER $$

-- Trigger 1: After a plagiarism report is inserted, flag submissions > 70%
CREATE TRIGGER trg_Flag_Plagiarism
AFTER INSERT ON PLAGIARISM_REPORT
FOR EACH ROW
BEGIN
    IF NEW.Similarity_Percentage >= 70.00 THEN
        UPDATE SUBMISSION
        SET    Is_Flagged = TRUE
        WHERE  Submission_ID IN (NEW.Submission1_ID, NEW.Submission2_ID);
    END IF;
END$$

-- Trigger 2: Prevent duplicate (same student, same assignment) submissions
CREATE TRIGGER trg_Prevent_Duplicate_Submission
BEFORE INSERT ON SUBMISSION
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count
    FROM   SUBMISSION
    WHERE  Student_ID    = NEW.Student_ID
      AND  Assignment_ID = NEW.Assignment_ID;

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Student has already submitted this assignment.';
    END IF;
END$$

-- Trigger 3: Log any submission update to console (using SELECT as a signal)
CREATE TRIGGER trg_Log_Submission_Update
AFTER UPDATE ON SUBMISSION
FOR EACH ROW
BEGIN
    -- In production this would INSERT into an AUDIT_LOG table
    IF NEW.Is_Flagged <> OLD.Is_Flagged THEN
        INSERT INTO PLAGIARISM_REPORT (Submission1_ID, Submission2_ID, Similarity_Percentage, Status)
        SELECT Submission1_ID, Submission2_ID, Similarity_Percentage, 'REVIEWED'
        FROM   PLAGIARISM_REPORT
        WHERE  (Submission1_ID = NEW.Submission_ID OR Submission2_ID = NEW.Submission_ID)
          AND  Status = 'PENDING'
        ON DUPLICATE KEY UPDATE Status = 'REVIEWED';
    END IF;
END$$

DELIMITER ;


-- ============================================================
-- SECTION 8: CURSOR EXAMPLE (inside a block / procedure)
-- ============================================================

DELIMITER $$

-- Cursor-based procedure: Print similarity for every pair, one by one
CREATE PROCEDURE sp_Cursor_Compare_All(IN p_assignment_id INT)
BEGIN
    DECLARE v_done   INT DEFAULT FALSE;
    DECLARE v_sub1   INT;
    DECLARE v_sub2   INT;
    DECLARE v_sim    DECIMAL(5,2);
    DECLARE v_roll1  VARCHAR(20);
    DECLARE v_roll2  VARCHAR(20);

    DECLARE cur CURSOR FOR
        SELECT s1.Submission_ID, s2.Submission_ID
        FROM   SUBMISSION s1
        JOIN   SUBMISSION s2 ON s1.Submission_ID < s2.Submission_ID
        WHERE  s1.Assignment_ID = p_assignment_id
          AND  s2.Assignment_ID = p_assignment_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_Comparison_Results (
        Student1 VARCHAR(20),
        Student2 VARCHAR(20),
        Similarity DECIMAL(5,2),
        Risk_Level VARCHAR(10)
    );

    OPEN cur;
    fetch_loop: LOOP
        FETCH cur INTO v_sub1, v_sub2;
        IF v_done THEN LEAVE fetch_loop; END IF;

        SET v_sim = fn_Similarity(v_sub1, v_sub2);

        SELECT Roll_No INTO v_roll1 FROM STUDENT
        WHERE  Student_ID = (SELECT Student_ID FROM SUBMISSION WHERE Submission_ID = v_sub1);

        SELECT Roll_No INTO v_roll2 FROM STUDENT
        WHERE  Student_ID = (SELECT Student_ID FROM SUBMISSION WHERE Submission_ID = v_sub2);

        INSERT INTO tmp_Comparison_Results VALUES (
            v_roll1, v_roll2, v_sim,
            IF(v_sim >= 70, 'HIGH', IF(v_sim >= 40, 'MEDIUM', 'LOW'))
        );
    END LOOP;
    CLOSE cur;

    SELECT * FROM tmp_Comparison_Results ORDER BY Similarity DESC;
    DROP TEMPORARY TABLE tmp_Comparison_Results;
END$$

DELIMITER ;


-- ============================================================
-- SECTION 9: TRANSACTION MANAGEMENT
-- ============================================================

-- Transaction 1: Submit an assignment (atomically insert submission + tokens)
START TRANSACTION;

SAVEPOINT sp_before_submission;

INSERT INTO SUBMISSION (Student_ID, Assignment_ID, Submission_Text, Word_Count)
VALUES (6, 2, 'Transactions ensure ACID properties in a DBMS. Commit saves changes while rollback undoes them.', 16);

-- If the submission insert fails, rollback to savepoint
-- ROLLBACK TO SAVEPOINT sp_before_submission;

INSERT INTO TOKEN (Submission_ID, Token_Text, Frequency) VALUES
(LAST_INSERT_ID(), 'transactions', 1),
(LAST_INSERT_ID(), 'acid', 1),
(LAST_INSERT_ID(), 'properties', 1),
(LAST_INSERT_ID(), 'dbms', 1),
(LAST_INSERT_ID(), 'commit', 1),
(LAST_INSERT_ID(), 'saves', 1),
(LAST_INSERT_ID(), 'rollback', 1);

COMMIT;


-- Transaction 2: Delete a submission and its tokens safely
START TRANSACTION;

SAVEPOINT sp_before_delete;

DELETE FROM TOKEN      WHERE Submission_ID = 7;
DELETE FROM SUBMISSION WHERE Submission_ID = 7;

-- Verify deletion
SELECT COUNT(*) AS Remaining_Tokens FROM TOKEN WHERE Submission_ID = 7;

COMMIT;
-- ROLLBACK;  -- Uncomment to undo instead of committing


-- ============================================================
-- SECTION 10: RUNNING THE FULL PLAGIARISM CHECK
-- ============================================================

-- Step 1: Run comparison for Assignment 1
CALL sp_Run_Plagiarism_Check(1);

-- Step 2: View all generated reports
SELECT * FROM vw_Plagiarism_Report ORDER BY Similarity_Percentage DESC;

-- Step 3: View only high-risk pairs
SELECT * FROM vw_High_Risk_Pairs;

-- Step 4: Check token count function
SELECT fn_Token_Count(1) AS Sub1_Tokens, fn_Token_Count(2) AS Sub2_Tokens;

-- Step 5: Inline similarity check
SELECT fn_Similarity(1, 2) AS Similarity_1_2;

-- Step 6: Cursor-based detailed comparison
CALL sp_Cursor_Compare_All(1);

-- Step 7: Student submission summary
SELECT * FROM vw_Student_Submission_Summary;

-- Step 8: Check which students are flagged
SELECT s.Roll_No, s.Name, su.Submission_ID, su.Is_Flagged
FROM   STUDENT   s
JOIN   SUBMISSION su ON s.Student_ID = su.Student_ID
WHERE  su.Assignment_ID = 1;


-- ============================================================
-- END OF SCRIPT
-- ============================================================
