USE miCareer_DB;
GO

/* ============================================================
   SAFE CLEAN (để chạy lại nhiều lần không lỗi)
   ============================================================ */

DELETE FROM JobRequirement;
DELETE FROM JobPosting;
GO

/* ============================================================
   1️⃣ JOB POSTING
   ============================================================ */

DECLARE @JobTable TABLE (
    jobPostId UNIQUEIDENTIFIER,
    title NVARCHAR(150)
);

INSERT INTO JobPosting
(compId, title, [desc], minSalary, maxSalary, workLoc, workMode, expAt)
OUTPUT INSERTED.jobPostId, INSERTED.title INTO @JobTable
SELECT 
    c.compId,
    v.title,
    v.[desc],
    v.minSalary,
    v.maxSalary,
    v.workLoc,
    v.workMode,
    DATEADD(DAY, 60, GETDATE())
FROM
(
VALUES
-- MicroTech
(N'MicroTech', N'Backend Java Developer',
 N'Build enterprise backend systems using Java & Spring Boot.',
 15000000, 30000000, N'Hà Nội', 'Onsite'),

(N'MicroTech', N'Frontend React Developer',
 N'Develop modern UI using ReactJS.',
 12000000, 25000000, N'Hà Nội', 'Hybrid'),

(N'MicroTech', N'.NET Developer',
 N'Develop enterprise applications using .NET.',
 15000000, 28000000, N'Hà Nội', 'Onsite'),

-- CloudNine
(N'CloudNine', N'Cloud Engineer',
 N'Design scalable cloud infrastructure.',
 18000000, 35000000, N'Đà Nẵng', 'Onsite'),

(N'CloudNine', N'DevOps Engineer',
 N'Automate CI/CD and container orchestration.',
 20000000, 40000000, N'Đà Nẵng', 'Remote'),

-- AI Solutions
(N'AI Solutions', N'Machine Learning Engineer',
 N'Build ML models and AI systems.',
 25000000, 50000000, N'TP Hồ Chí Minh', 'Hybrid'),

(N'AI Solutions', N'Data Engineer',
 N'Build ETL pipelines and data warehouse.',
 22000000, 45000000, N'TP Hồ Chí Minh', 'Onsite'),

(N'AI Solutions', N'Fullstack Developer',
 N'Work on both frontend and backend systems.',
 18000000, 35000000, N'TP Hồ Chí Minh', 'Hybrid')
) v(compName, title, [desc], minSalary, maxSalary, workLoc, workMode)
JOIN Company c ON c.compName = v.compName;


/* ============================================================
   2️⃣ JOB REQUIREMENT MAPPING
   ============================================================ */

-- Backend Java
INSERT INTO JobRequirement (jobPostId, skillId)
SELECT j.jobPostId, s.skillId
FROM @JobTable j
JOIN Skill s ON s.skillName IN ('Java','Spring Boot','SQL')
WHERE j.title = N'Backend Java Developer';

-- Frontend React
INSERT INTO JobRequirement (jobPostId, skillId)
SELECT j.jobPostId, s.skillId
FROM @JobTable j
JOIN Skill s ON s.skillName IN ('React','SQL')
WHERE j.title = N'Frontend React Developer';

-- .NET
INSERT INTO JobRequirement (jobPostId, skillId)
SELECT j.jobPostId, s.skillId
FROM @JobTable j
JOIN Skill s ON s.skillName IN ('.NET','SQL')
WHERE j.title = N'.NET Developer';

-- Cloud Engineer
INSERT INTO JobRequirement (jobPostId, skillId)
SELECT j.jobPostId, s.skillId
FROM @JobTable j
JOIN Skill s ON s.skillName IN ('AWS','Docker','Kubernetes')
WHERE j.title = N'Cloud Engineer';

-- DevOps
INSERT INTO JobRequirement (jobPostId, skillId)
SELECT j.jobPostId, s.skillId
FROM @JobTable j
JOIN Skill s ON s.skillName IN ('Docker','Kubernetes','AWS')
WHERE j.title = N'DevOps Engineer';

-- ML Engineer
INSERT INTO JobRequirement (jobPostId, skillId)
SELECT j.jobPostId, s.skillId
FROM @JobTable j
JOIN Skill s ON s.skillName IN ('Python','Machine Learning','SQL')
WHERE j.title = N'Machine Learning Engineer';

-- Data Engineer
INSERT INTO JobRequirement (jobPostId, skillId)
SELECT j.jobPostId, s.skillId
FROM @JobTable j
JOIN Skill s ON s.skillName IN ('Python','Data Engineering','SQL')
WHERE j.title = N'Data Engineer';

-- Fullstack
INSERT INTO JobRequirement (jobPostId, skillId)
SELECT j.jobPostId, s.skillId
FROM @JobTable j
JOIN Skill s ON s.skillName IN ('React','NodeJS','SQL')
WHERE j.title = N'Fullstack Developer';

GO