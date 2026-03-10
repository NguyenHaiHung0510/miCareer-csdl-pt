USE miCareer_DB;
GO

PRINT N'Insert dữ liệu cho cụm thực thể chính';

-- 1. Khai báo các biến bảng tạm để lưu UUID
DECLARE @CompanyTable TABLE (compId UNIQUEIDENTIFIER, compName NVARCHAR(200), provId VARCHAR(10));
DECLARE @UserTable TABLE (userId UNIQUEIDENTIFIER, [role] VARCHAR(30), provId VARCHAR(10));

-------------------------------------------------------------------
-- 2. Insert bảng Company (6 công ty, 2 công ty mỗi Node)
-------------------------------------------------------------------
-- HN thuộc HANOI_NODE | DN thuộc DANANG_NODE | HCM thuộc SAIGON_NODE
INSERT INTO Company (compName, taxCode, webUrl, contactEmail, provId)
OUTPUT INSERTED.compId, INSERTED.compName, INSERTED.provId INTO @CompanyTable
VALUES
-- HANOI_NODE
(N'TechCore Solutions', '0101234567', 'techcore.vn', 'contact@techcore.vn', 'HN'),
(N'DevMaster Hanoi', '0101234568', 'devmaster.vn', 'hr@devmaster.vn', 'HN'),
-- DANANG_NODE
(N'DataMinds Da Nang', '0401234567', 'dataminds.vn', 'contact@dataminds.vn', 'DN'),
(N'CloudX Central', '0401234568', 'cloudx.vn', 'hr@cloudx.vn', 'DN'),
-- SAIGON_NODE
(N'AI Vision HCM', '0301234567', 'aivision.vn', 'contact@aivision.vn', 'HCM'),
(N'Saigon TechHub', '0301234568', 'sgtechhub.vn', 'hr@sgtechhub.vn', 'HCM');

PRINT N'Insert bảng Company thành công (6 dòng).';

-------------------------------------------------------------------
-- 3. Insert bảng [User] (30 tài khoản: 3 Admin, 6 HR, 21 Candidate)
-------------------------------------------------------------------
INSERT INTO [User] (userName, pwd, fName, lName, email, phone, stat, [role], provId)
OUTPUT INSERTED.userId, INSERTED.[role], INSERTED.provId INTO @UserTable
VALUES
-- === 3 ADMINS (Rải đều 3 miền) ===
('admin_hn', 'hashed_123', N'Nguyễn', N'Văn Quản Trị', 'admin1@micareer.vn', '0901000001', 'Active', 'Admin', 'HN'),
('admin_dn', 'hashed_123', N'Trần', N'Thị Điều Hành', 'admin2@micareer.vn', '0901000002', 'Active', 'Admin', 'DN'),
('admin_hcm', 'hashed_123', N'Lê', N'Văn Hệ Thống', 'admin3@micareer.vn', '0901000003', 'Active', 'Admin', 'HCM'),

-- === 6 HRS (2 HR mỗi Node) ===
('hr_hn1', 'hashed_123', N'Phạm', N'Thị Dung', 'hr1@techcore.vn', '0902000001', 'Active', 'HR', 'HN'),
('hr_hn2', 'hashed_123', N'Hoàng', N'Văn Đạt', 'hr2@devmaster.vn', '0902000002', 'Active', 'HR', 'HN'),
('hr_dn1', 'hashed_123', N'Đỗ', N'Thị Lan', 'hr1@dataminds.vn', '0902000003', 'Active', 'HR', 'DN'),
('hr_dn2', 'hashed_123', N'Ngô', N'Trọng Nghĩa', 'hr2@cloudx.vn', '0902000004', 'Active', 'HR', 'DN'),
('hr_hcm1', 'hashed_123', N'Bùi', N'Thị Hà', 'hr1@aivision.vn', '0902000005', 'Active', 'HR', 'HCM'),
('hr_hcm2', 'hashed_123', N'Đinh', N'Văn Hùng', 'hr2@sgtechhub.vn', '0902000006', 'Active', 'HR', 'HCM'),

-- === 21 CANDIDATES (7 Candidate mỗi Node) ===
-- HANOI_NODE
('cand_hn1', 'hashed_123', N'Nguyễn', N'Hải Anh', 'cand_hn1@gmail.com', '0903000101', 'Active', 'Candidate', 'HN'),
('cand_hn2', 'hashed_123', N'Trần', N'Đức Bảo', 'cand_hn2@gmail.com', '0903000102', 'Active', 'Candidate', 'HN'),
('cand_hn3', 'hashed_123', N'Lê', N'Thị Châu', 'cand_hn3@gmail.com', '0903000103', 'Active', 'Candidate', 'HN'),
('cand_hn4', 'hashed_123', N'Phạm', N'Văn Duy', 'cand_hn4@gmail.com', '0903000104', 'Active', 'Candidate', 'HN'),
('cand_hn5', 'hashed_123', N'Hoàng', N'Thanh Nga', 'cand_hn5@gmail.com', '0903000105', 'Active', 'Candidate', 'HN'),
('cand_hn6', 'hashed_123', N'Vũ', N'Đình Phúc', 'cand_hn6@gmail.com', '0903000106', 'Active', 'Candidate', 'HN'),
('cand_hn7', 'hashed_123', N'Đặng', N'Thị Mai', 'cand_hn7@gmail.com', '0903000107', 'Active', 'Candidate', 'HN'),

-- DANANG_NODE
('cand_dn1', 'hashed_123', N'Bùi', N'Văn An', 'cand_dn1@gmail.com', '0903000201', 'Active', 'Candidate', 'DN'),
('cand_dn2', 'hashed_123', N'Đỗ', N'Thị Bình', 'cand_dn2@gmail.com', '0903000202', 'Active', 'Candidate', 'DN'),
('cand_dn3', 'hashed_123', N'Ngô', N'Trọng Cảnh', 'cand_dn3@gmail.com', '0903000203', 'Active', 'Candidate', 'DN'),
('cand_dn4', 'hashed_123', N'Dương', N'Thị Dung', 'cand_dn4@gmail.com', '0903000204', 'Active', 'Candidate', 'DN'),
('cand_dn5', 'hashed_123', N'Lý', N'Văn Đạt', 'cand_dn5@gmail.com', '0903000205', 'Active', 'Candidate', 'DN'),
('cand_dn6', 'hashed_123', N'Đào', N'Thị Hoa', 'cand_dn6@gmail.com', '0903000206', 'Active', 'Candidate', 'DN'),
('cand_dn7', 'hashed_123', N'Trịnh', N'Văn Kiên', 'cand_dn7@gmail.com', '0903000207', 'Active', 'Candidate', 'DN'),

-- SAIGON_NODE
('cand_hcm1', 'hashed_123', N'Đinh', N'Thị Lan', 'cand_hcm1@gmail.com', '0903000301', 'Active', 'Candidate', 'HCM'),
('cand_hcm2', 'hashed_123', N'Lâm', N'Văn Minh', 'cand_hcm2@gmail.com', '0903000302', 'Active', 'Candidate', 'HCM'),
('cand_hcm3', 'hashed_123', N'Phùng', N'Thị Ngọc', 'cand_hcm3@gmail.com', '0903000303', 'Active', 'Candidate', 'HCM'),
('cand_hcm4', 'hashed_123', N'Mai', N'Văn Phú', 'cand_hcm4@gmail.com', '0903000304', 'Active', 'Candidate', 'HCM'),
('cand_hcm5', 'hashed_123', N'Tô', N'Thị Quỳnh', 'cand_hcm5@gmail.com', '0903000305', 'Active', 'Candidate', 'HCM'),
('cand_hcm6', 'hashed_123', N'Hồ', N'Văn Sơn', 'cand_hcm6@gmail.com', '0903000306', 'Active', 'Candidate', 'HCM'),
('cand_hcm7', 'hashed_123', N'Châu', N'Thị Tâm', 'cand_hcm7@gmail.com', '0903000307', 'Active', 'Candidate', 'HCM');

PRINT N'Insert bảng [User] thành công (30 dòng).';

-------------------------------------------------------------------
-- 4. Phân phối dữ liệu vào các bảng Candidate, HR, Admin
-------------------------------------------------------------------

-- 4.1. Bảng Candidate (Lấy 21 users có role 'Candidate')
INSERT INTO Candidate (candidateId, bio, cvUrl, expYears)
SELECT 
    userId,
    N'Lập trình viên đam mê công nghệ, luôn tìm kiếm cơ hội học hỏi và phát triển bản thân.',
    'https://storage.micareer.vn/cv/' + CAST(userId AS VARCHAR(50)) + '.pdf',
    -- Random số năm kinh nghiệm từ 0.0 đến 10.0 (1 chữ số thập phân)
    ROUND(RAND(CHECKSUM(NEWID())) * 10, 1)
FROM @UserTable
WHERE [role] = 'Candidate';
PRINT N'Đã phân vai trò cho 21 Candidate.';

-- 4.2. Bảng HR (Lấy 6 users có role 'HR')
-- Tìm sẵn posId của 'Recruiter' từ bảng HRPosition để gán cho các HR này
DECLARE @RecruiterPosId UNIQUEIDENTIFIER = (SELECT TOP 1 posId FROM HRPosition WHERE posName = 'Recruiter');

INSERT INTO HR (hrId, posId, emailSign)
SELECT 
    userId,
    @RecruiterPosId,
    N'Trân trọng,\nPhòng Tuyển dụng & Thu hút nhân tài'
FROM @UserTable
WHERE [role] = 'HR';
PRINT N'Đã phân vai trò cho 6 HR.';

-- 4.3. Bảng Admin (Lấy 3 users có role 'Admin')
-- Tìm sẵn roleId của 'SuperAdmin' từ bảng AdminRole để gán cho các Admin
DECLARE @SuperAdminRoleId UNIQUEIDENTIFIER = (SELECT TOP 1 roleId FROM AdminRole WHERE roleName = 'SuperAdmin');

INSERT INTO [Admin] (adminId, roleId, lastIp)
SELECT 
    userId,
    @SuperAdminRoleId,
    -- Giả lập IP ngẫu nhiên
    '192.168.1.' + CAST(ABS(CHECKSUM(NEWID()) % 255) AS VARCHAR)
FROM @UserTable
WHERE [role] = 'Admin';
PRINT N'Đã phân vai trò cho 3 Admin.';

GO