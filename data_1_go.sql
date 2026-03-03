
USE miCareer_DB;
GO

/* ============================================================
   1️⃣ CORE DICTIONARY (TỪ ĐIỂN DỮ LIỆU LÕI)
   ============================================================ */
INSERT INTO Province (provId, provName, nodeCode) VALUES
('HN',  N'Hà Nội',            'HANOI_NODE'),
('HP',  N'Hải Phòng',         'HANOI_NODE'),
('TH',  N'Thanh Hóa',         'HANOI_NODE'),
('DN',  N'Đà Nẵng',           'DANANG_NODE'),
('HUE', N'Thừa Thiên Huế',    'DANANG_NODE'),
('QN',  N'Quảng Nam',         'DANANG_NODE'),
('HCM', N'TP Hồ Chí Minh',    'SAIGON_NODE'),
('BD',  N'Bình Dương',        'SAIGON_NODE'),
('CT',  N'Cần Thơ',           'SAIGON_NODE');
GO

INSERT INTO HRPosition (posName, [desc]) VALUES
(N'Recruiter',        N'Handles candidate sourcing and screening'),
(N'Senior Recruiter', N'Handles complex hiring and negotiation'),
(N'HR Manager',       N'Manages HR team and recruitment strategy');

INSERT INTO AdminRole (roleName, [desc]) VALUES
('SuperAdmin',  N'Full system control and permission management'),
('ContentMod',  N'Manages content and moderate company/job data');

INSERT INTO Permission (permCode, [desc]) VALUES
('CAN_DEL_JOB',           N'Can delete job postings'),
('CAN_BAN_USER',          N'Can ban or activate users'),
('CAN_MANAGE_TEMPLATE',   N'Can manage email templates'),
('CAN_VIEW_LOG',          N'Can view system email logs');

INSERT INTO RolePermission (roleId, permId)
SELECT r.roleId, p.permId FROM AdminRole r CROSS JOIN Permission p WHERE r.roleName = 'SuperAdmin';

INSERT INTO RolePermission (roleId, permId)
SELECT r.roleId, p.permId FROM AdminRole r JOIN Permission p ON p.permCode IN ('CAN_MANAGE_TEMPLATE') WHERE r.roleName = 'ContentMod';

INSERT INTO Skill (skillName, [desc]) VALUES
(N'Java', N'Java core and enterprise development'),
(N'Spring Boot', N'Java Spring Boot framework'),
(N'C++', N'Advanced C++ programming'),
(N'.NET', N'Microsoft .NET platform'),
(N'NodeJS', N'NodeJS backend runtime'),
(N'React', N'ReactJS frontend framework'),
(N'Angular', N'Angular frontend framework'),
(N'SQL', N'Relational database querying and design'),
(N'MongoDB', N'NoSQL document database'),
(N'Docker', N'Containerization platform'),
(N'Kubernetes', N'Container orchestration system'),
(N'AWS', N'Amazon Web Services cloud platform'),
(N'Python', N'Python programming for backend and AI'),
(N'Machine Learning', N'Machine learning fundamentals'),
(N'Data Engineering', N'Data pipeline and ETL systems');

INSERT INTO EmailType (typeName, [desc]) VALUES
(N'ApplicationConfirmation', N'Auto confirmation when candidate applies'),
(N'InterviewInvitation', N'Manual interview invitation email'),
(N'OfferLetter', N'Official job offer email'),
(N'RejectionNotice', N'Rejection notification email');
GO

/* ============================================================
   2️⃣ USERS, COMPANIES & CANDIDATES
   ============================================================ */
-- Cập nhật Company với thông tin bắt buộc
INSERT INTO Company (compName, taxCode, provId, contactEmail) VALUES
(N'MicroTech', 'TAX-MT-001', 'HN', 'contact@microtech.vn'),
(N'CloudNine', 'TAX-CN-001', 'DN', 'contact@cloudnine.vn'),
(N'AI Solutions', 'TAX-AI-001', 'HCM', 'contact@aisolutions.vn');

-- Cập nhật Users (HR)
INSERT INTO [User] (userName,pwd,fName,lName,email,phone,stat,role,provId) VALUES
('hr_mt_1','hashed',N'Anh',N'Nam','hr1@microtech.vn',CONCAT('09',ABS(CHECKSUM(NEWID())) % 100000000),'Active','HR','HN'),
('hr_mt_2','hashed',N'Lan',N'Anh','hr2@microtech.vn',CONCAT('09',ABS(CHECKSUM(NEWID())) % 100000000),'Active','HR','HN'),
('hr_cn_1','hashed',N'Minh',N'Tuấn','hr1@cloudnine.vn',CONCAT('09',ABS(CHECKSUM(NEWID())) % 100000000),'Active','HR','DN'),
('hr_ai_1','hashed',N'Hải',N'Long','hr1@ai.vn',CONCAT('09',ABS(CHECKSUM(NEWID())) % 100000000),'Active','HR','HCM');

-- Ánh xạ HR
INSERT INTO HR (hrId,posId,emailSign)
SELECT u.userId, (SELECT TOP 1 posId FROM HRPosition ORDER BY NEWID()), N'<p>Best regards,<br/>HR Team</p>'
FROM [User] u WHERE u.role = 'HR';

-- Cập nhật Users (Candidate - Test Data)
INSERT INTO [User] (userName, pwd, fName, lName, email, phone, stat, role, provId) VALUES
('cand_khoa', 'hashed', N'Đăng', N'Khoa', 'khoa@email.com', '0911223344', 'Active', 'Candidate', 'DN'),
('cand_tminh', 'hashed', N'Tuấn', N'Minh', 'tuanminh@email.com', '0922334455', 'Active', 'Candidate', 'HN'),
('cand_hminh', 'hashed', N'Hoàng', N'Minh', 'hoangminh@email.com', '0933445566', 'Active', 'Candidate', 'HCM'),
('cand_duong', 'hashed', N'Thùy', N'Dương', 'duong@email.com', '0944556677', 'Active', 'Candidate', 'DN'),
('cand_kien', 'hashed', N'Trung', N'Kiên', 'kien@email.com', '0955667788', 'Active', 'Candidate', 'HN');

-- Ánh xạ Candidate
INSERT INTO Candidate (candidateId, bio, expYears)
SELECT u.userId, N'Lập trình viên đam mê thực chiến và tạo ra sản phẩm.', ABS(CHECKSUM(NEWID())) % 4 + 1
FROM [User] u WHERE u.role = 'Candidate';
GO

/* ============================================================
   3️⃣ JOBS & REQUIREMENTS
   ============================================================ */
DECLARE @JobTable TABLE (jobPostId UNIQUEIDENTIFIER, title NVARCHAR(150));

INSERT INTO JobPosting (compId, title, [desc], minSalary, maxSalary, workLoc, workMode, expAt)
OUTPUT INSERTED.jobPostId, INSERTED.title INTO @JobTable
SELECT c.compId, v.title, v.[desc], v.minSalary, v.maxSalary, v.workLoc, v.workMode, DATEADD(DAY, 60, GETDATE())
FROM (VALUES
(N'MicroTech', N'Backend Java Developer', N'Build enterprise backend systems using Java & Servlets/JSP.', 15000000, 30000000, N'Hà Nội', 'Onsite'),
(N'CloudNine', N'Cloud Engineer', N'Design scalable cloud infrastructure.', 18000000, 35000000, N'Đà Nẵng', 'Onsite'),
(N'AI Solutions', N'Machine Learning Engineer', N'Build ML models and AI systems.', 25000000, 50000000, N'TP Hồ Chí Minh', 'Hybrid')
) v(compName, title, [desc], minSalary, maxSalary, workLoc, workMode)
JOIN Company c ON c.compName = v.compName;

INSERT INTO JobRequirement (jobPostId, skillId)
SELECT j.jobPostId, s.skillId FROM @JobTable j JOIN Skill s ON s.skillName IN ('Java','Spring Boot','SQL') WHERE j.title = N'Backend Java Developer';

INSERT INTO JobRequirement (jobPostId, skillId)
SELECT j.jobPostId, s.skillId FROM @JobTable j JOIN Skill s ON s.skillName IN ('AWS','Docker','Kubernetes') WHERE j.title = N'Cloud Engineer';

INSERT INTO JobRequirement (jobPostId, skillId)
SELECT j.jobPostId, s.skillId FROM @JobTable j JOIN Skill s ON s.skillName IN ('Python','Machine Learning','SQL') WHERE j.title = N'Machine Learning Engineer';
GO

/* ============================================================
   4️⃣ APPLICATIONS, INTERVIEWS & OFFERS
   ============================================================ */
DECLARE @AppTable TABLE (jobAppId UNIQUEIDENTIFIER, jobPostId UNIQUEIDENTIFIER, candidateId UNIQUEIDENTIFIER, appliedAt DATETIME2(0));

INSERT INTO JobApplication (jobPostId, candidateId, appliedAt, stat, cvSnapUrl, coverLetter)
OUTPUT INSERTED.jobAppId, INSERTED.jobPostId, INSERTED.candidateId, INSERTED.appliedAt INTO @AppTable
SELECT TOP 10 jp.jobPostId, c.candidateId, DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 10, GETDATE()), 'Applied', CONCAT('https://snapshot/', c.candidateId, '_', jp.jobPostId, '.pdf'), N'I am very interested in this position.'
FROM JobPosting jp CROSS JOIN Candidate c ORDER BY NEWID();

-- Cập nhật trạng thái
INSERT INTO AppStatusHistory (jobAppId, userId, oldStat, newStat, changeAt)
SELECT a.jobAppId, (SELECT TOP 1 hrId FROM HR ORDER BY NEWID()), 'Applied', 'Screening', DATEADD(HOUR,1,a.appliedAt) FROM @AppTable a;

INSERT INTO AppStatusHistory (jobAppId, userId, oldStat, newStat, changeAt)
SELECT a.jobAppId, (SELECT TOP 1 hrId FROM HR ORDER BY NEWID()), 'Screening', 'Interviewing', DATEADD(HOUR,5,a.appliedAt)
FROM @AppTable a WHERE ABS(CHECKSUM(a.jobAppId)) % 10 < 7;

-- Interview
DECLARE @InterviewTable TABLE (intervId UNIQUEIDENTIFIER, jobAppId UNIQUEIDENTIFIER);
INSERT INTO Interview (jobAppId, startAt, endAt, mode, linkMeet, loc)
OUTPUT INSERTED.intervId, INSERTED.jobAppId INTO @InterviewTable
SELECT a.jobAppId, DATEADD(DAY,1,a.appliedAt), DATEADD(HOUR,2,DATEADD(DAY,1,a.appliedAt)), 'Online', 'https://meet.link/session', N'Company Meeting Room'
FROM @AppTable a WHERE EXISTS (SELECT 1 FROM AppStatusHistory h WHERE h.jobAppId = a.jobAppId AND h.newStat = 'Interviewing');

-- Feedback & Offer
INSERT INTO InterviewFeedback (intervId, hrId, score, cmt, subAt)
SELECT i.intervId, (SELECT TOP 1 hrId FROM HR ORDER BY NEWID()), 8.5, N'Good system design mindset.', GETDATE() FROM @InterviewTable i;

INSERT INTO Offer (jobAppId, salary, [desc], stat, subAt, ver, hrId)
SELECT TOP 3 a.jobAppId, 25000000, N'Initial offer package.', 'Pending', GETDATE(), 1, (SELECT TOP 1 hrId FROM HR ORDER BY NEWID()) FROM @AppTable a;
GO

/* ============================================================
   5️⃣ EMAIL SYSTEM
   ============================================================ */
INSERT INTO EmailTemplate (typeId, subj, body, [desc])
SELECT et.typeId, N'Application Received - {{JobTitle}}', N'Dear {{CandidateName}},<br/>Your application has been received successfully.', N'Auto confirmation email'
FROM EmailType et WHERE et.typeName = 'ApplicationConfirmation';

INSERT INTO EmailTemplate (typeId, subj, body, [desc])
SELECT et.typeId, N'Interview Invitation - {{JobTitle}}', N'Dear {{CandidateName}},<br/>You are invited to attend an interview.', N'Interview invitation template'
FROM EmailType et WHERE et.typeName = 'InterviewInvitation';

-- Log Auto Email (Đã fix lỗi NULL)
INSERT INTO EmailLog (tmplId, jobAppId, userId, content, sentAt, rcvEmail)
SELECT t.tmplId, ja.jobAppId, ja.candidateId, REPLACE(REPLACE(t.body,'{{CandidateName}}',u.fName),'{{JobTitle}}',jp.title), DATEADD(MINUTE,5,ja.appliedAt), u.email
FROM JobApplication ja
JOIN Candidate c ON c.candidateId = ja.candidateId
JOIN [User] u ON u.userId = c.candidateId
JOIN JobPosting jp ON jp.jobPostId = ja.jobPostId
JOIN EmailTemplate t ON t.typeId = (SELECT typeId FROM EmailType WHERE typeName = 'ApplicationConfirmation');

-- Log Interview Invitation Email
INSERT INTO EmailLog (tmplId, jobAppId, userId, content, sentAt, rcvEmail)
SELECT t.tmplId, i.jobAppId, ja.candidateId, REPLACE(REPLACE(t.body,'{{CandidateName}}',u.fName),'{{JobTitle}}',jp.title), DATEADD(DAY, -1, i.startAt), u.email
FROM Interview i
JOIN JobApplication ja ON i.jobAppId = ja.jobAppId
JOIN [User] u ON u.userId = ja.candidateId
JOIN JobPosting jp ON jp.jobPostId = ja.jobPostId
JOIN EmailTemplate t ON t.typeId = (SELECT typeId FROM EmailType WHERE typeName = 'InterviewInvitation');
GO