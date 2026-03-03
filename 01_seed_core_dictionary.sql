/* ============================================================
   FILE: 01_seed_core_dictionary.sql
   PURPOSE: Seed core dictionary & system configuration tables
   ============================================================ */

USE miCareer_DB;
GO

/* ============================================================
   1️⃣ PROVINCE (BẮC - TRUNG - NAM)
   HANOI_NODE  -> Miền Bắc
   DANANG_NODE -> Miền Trung
   SAIGON_NODE -> Miền Nam
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


/* ============================================================
   2️⃣ HR POSITION
   ============================================================ */

INSERT INTO HRPosition (posName, [desc]) VALUES
(N'Recruiter',        N'Handles candidate sourcing and screening'),
(N'Senior Recruiter', N'Handles complex hiring and negotiation'),
(N'HR Manager',       N'Manages HR team and recruitment strategy');
GO


/* ============================================================
   3️⃣ ADMIN ROLE
   ============================================================ */

INSERT INTO AdminRole (roleName, [desc]) VALUES
('SuperAdmin',  N'Full system control and permission management'),
('ContentMod',  N'Manages content and moderate company/job data');
GO


/* ============================================================
   4️⃣ PERMISSION
   ============================================================ */

INSERT INTO Permission (permCode, [desc]) VALUES
('CAN_DEL_JOB',           N'Can delete job postings'),
('CAN_BAN_USER',          N'Can ban or activate users'),
('CAN_MANAGE_TEMPLATE',   N'Can manage email templates'),
('CAN_VIEW_LOG',          N'Can view system email logs');
GO


/* ============================================================
   5️⃣ ROLE - PERMISSION MAPPING
   SuperAdmin -> full permission
   ContentMod -> limited permission
   ============================================================ */

-- SuperAdmin gets all permissions
INSERT INTO RolePermission (roleId, permId)
SELECT r.roleId, p.permId
FROM AdminRole r
CROSS JOIN Permission p
WHERE r.roleName = 'SuperAdmin';

-- ContentMod gets limited permissions
INSERT INTO RolePermission (roleId, permId)
SELECT r.roleId, p.permId
FROM AdminRole r
JOIN Permission p ON p.permCode IN ('CAN_MANAGE_TEMPLATE')
WHERE r.roleName = 'ContentMod';
GO


/* ============================================================
   6️⃣ SKILL (Backend + Frontend + Cloud + AI + DevOps)
   ============================================================ */

INSERT INTO Skill (skillName, [desc]) VALUES
-- Backend
(N'Java',            N'Java core and enterprise development'),
(N'Spring Boot',     N'Java Spring Boot framework'),
(N'C++',             N'Advanced C++ programming'),
(N'.NET',            N'Microsoft .NET platform'),
(N'NodeJS',          N'NodeJS backend runtime'),

-- Frontend
(N'React',           N'ReactJS frontend framework'),
(N'Angular',         N'Angular frontend framework'),

-- Database
(N'SQL',             N'Relational database querying and design'),
(N'MongoDB',         N'NoSQL document database'),

-- DevOps & Cloud
(N'Docker',          N'Containerization platform'),
(N'Kubernetes',      N'Container orchestration system'),
(N'AWS',             N'Amazon Web Services cloud platform'),

-- AI / Data
(N'Python',          N'Python programming for backend and AI'),
(N'Machine Learning',N'Machine learning fundamentals'),
(N'Data Engineering',N'Data pipeline and ETL systems');
GO


/* ============================================================
   7️⃣ EMAIL TYPE
   ============================================================ */

INSERT INTO EmailType (typeName, [desc]) VALUES
(N'ApplicationConfirmation', N'Auto confirmation when candidate applies'),
(N'InterviewInvitation',     N'Manual interview invitation email'),
(N'OfferLetter',             N'Official job offer email'),
(N'RejectionNotice',         N'Rejection notification email');
GO