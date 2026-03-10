USE miCareer_DB;
GO

PRINT N'Insert dữ liệu danh mục';

-------------------------------------------------------------------
-- 1. Insert dữ liệu cho bảng Province (34 Tỉnh/Thành phố)
-------------------------------------------------------------------
INSERT INTO Province (provId, provName, nodeCode) VALUES
-- HANOI_NODE: 15 tỉnh miền Bắc
('HN', N'TP Hà Nội', 'HANOI_NODE'),
('CB', N'Cao Bằng', 'HANOI_NODE'),
('TQ', N'Tuyên Quang', 'HANOI_NODE'),
('DB', N'Điện Biên', 'HANOI_NODE'),
('LC', N'Lai Châu', 'HANOI_NODE'),
('SL', N'Sơn La', 'HANOI_NODE'),
('LCAI', N'Lào Cai', 'HANOI_NODE'),
('TN', N'Thái Nguyên', 'HANOI_NODE'),
('LS', N'Lạng Sơn', 'HANOI_NODE'),
('QN', N'Quảng Ninh', 'HANOI_NODE'),
('BN', N'Bắc Ninh', 'HANOI_NODE'),
('PT', N'Phú Thọ', 'HANOI_NODE'),
('HP', N'TP Hải Phòng', 'HANOI_NODE'),
('HY', N'Hưng Yên', 'HANOI_NODE'),
('NB', N'Ninh Bình', 'HANOI_NODE'),

-- DANANG_NODE: 11 tỉnh miền Trung
('TH', N'Thanh Hóa', 'DANANG_NODE'),
('NA', N'Nghệ An', 'DANANG_NODE'),
('HT', N'Hà Tĩnh', 'DANANG_NODE'),
('QT', N'Quảng Trị', 'DANANG_NODE'),
('HUE', N'TP Huế', 'DANANG_NODE'),
('DN', N'TP Đà Nẵng', 'DANANG_NODE'),
('QNG', N'Quảng Ngãi', 'DANANG_NODE'),
('GL', N'Gia Lai', 'DANANG_NODE'),
('KH', N'Khánh Hòa', 'DANANG_NODE'),
('DLK', N'Đắk Lắk', 'DANANG_NODE'),
('LD', N'Lâm Đồng', 'DANANG_NODE'),

-- SAIGON_NODE: 8 tỉnh miền Nam
('HCM', N'TP. Hồ Chí Minh', 'SAIGON_NODE'),
('DNAI', N'Đồng Nai', 'SAIGON_NODE'),
('TNI', N'Tây Ninh', 'SAIGON_NODE'),
('CT', N'TP Cần Thơ', 'SAIGON_NODE'),
('VL', N'Vĩnh Long', 'SAIGON_NODE'),
('DTH', N'Đồng Tháp', 'SAIGON_NODE'),
('CM', N'Cà Mau', 'SAIGON_NODE'),
('AG', N'An Giang', 'SAIGON_NODE');
PRINT N'Insert bảng Province thành công (34 dòng).';


-------------------------------------------------------------------
-- 2. Insert dữ liệu cho bảng Skill (15 Kỹ năng)
-------------------------------------------------------------------
INSERT INTO Skill (skillName, [desc]) VALUES
-- Nhóm Backend
('Java', N'Ngôn ngữ và hệ sinh thái lập trình Backend (Spring Boot)'),
('C#', N'Nền tảng lập trình .NET Core cho Backend'),
('Node.js', N'Môi trường chạy JavaScript phía máy chủ'),
('Golang', N'Ngôn ngữ lập trình Backend hiệu năng cao'),
('PHP', N'Ngôn ngữ lập trình web Backend (Laravel, Symfony)'),

-- Nhóm Frontend
('React', N'Thư viện JavaScript phổ biến để xây dựng UI'),
('Vue.js', N'Framework Frontend linh hoạt, dễ tích hợp'),
('Angular', N'Framework Frontend toàn diện của Google'),
('HTML/CSS', N'Nền tảng xây dựng và định dạng giao diện Web'),
('TypeScript', N'Ngôn ngữ mở rộng của JS, hỗ trợ type-checking'),

-- Nhóm AI/Data
('Python', N'Ngôn ngữ lập trình cốt lõi cho Data và AI'),
('Machine Learning', N'Kỹ năng xây dựng các mô hình học máy'),
('Deep Learning', N'Kỹ năng làm việc với mạng nơ-ron sâu'),
('SQL', N'Kỹ năng truy vấn, phân tích cơ sở dữ liệu quan hệ'),
('Data Engineering', N'Thiết kế và xây dựng đường ống dữ liệu (ETL)');
PRINT N'Insert bảng Skill thành công (15 dòng).';


-------------------------------------------------------------------
-- 3. Insert dữ liệu cho bảng HRPosition (3 Chức vụ)
-------------------------------------------------------------------
INSERT INTO HRPosition (posName, [desc]) VALUES
('Intern', N'Thực tập sinh nhân sự, hỗ trợ lọc CV và thủ tục tuyển dụng'),
('Recruiter', N'Chuyên viên tuyển dụng, tìm kiếm và phỏng vấn ứng viên'),
('HR Manager', N'Trưởng phòng nhân sự, quản lý quy trình và ra quyết định Offer');
PRINT N'Insert bảng HRPosition thành công (3 dòng).';


-------------------------------------------------------------------
-- 4. Insert AdminRole, Permission và map RolePermission
-------------------------------------------------------------------
-- Tạo biến bảng để hứng các UUID tự động sinh ra
DECLARE @RolesTbl TABLE (roleId UNIQUEIDENTIFIER, roleName VARCHAR(50));
DECLARE @PermsTbl TABLE (permId UNIQUEIDENTIFIER, permCode VARCHAR(50));

-- Insert AdminRole và lưu ID vào bảng tạm @RolesTbl
INSERT INTO AdminRole (roleName, [desc])
OUTPUT INSERTED.roleId, INSERTED.roleName INTO @RolesTbl
VALUES 
('SuperAdmin', N'Quản trị viên hệ thống có toàn quyền thao tác'),
('ContentMod', N'Người điều phối, duyệt nội dung và xem hoạt động');

-- Insert Permission và lưu ID vào bảng tạm @PermsTbl
INSERT INTO Permission (permCode, [desc])
OUTPUT INSERTED.permId, INSERTED.permCode INTO @PermsTbl
VALUES
('VIEW_LOG', N'Quyền xem nhật ký hệ thống (Email Log, Audit Log)'),
('BAN_USER', N'Quyền cấm/mở khóa tài khoản người dùng'),
('MANAGE_POST', N'Quyền duyệt/chỉnh sửa/xóa bài đăng tuyển dụng'),
('MANAGE_ROLE', N'Quyền phân quyền hoặc tạo role mới');

-- Map RolePermission: SuperAdmin (Được cấp TẤT CẢ các quyền)
INSERT INTO RolePermission (roleId, permId)
SELECT r.roleId, p.permId
FROM @RolesTbl r
CROSS JOIN @PermsTbl p
WHERE r.roleName = 'SuperAdmin';

-- Map RolePermission: ContentMod (Chỉ cấp quyền VIEW_LOG và MANAGE_POST)
INSERT INTO RolePermission (roleId, permId)
SELECT r.roleId, p.permId
FROM @RolesTbl r
CROSS JOIN @PermsTbl p
WHERE r.roleName = 'ContentMod' 
  AND p.permCode IN ('VIEW_LOG', 'MANAGE_POST');

PRINT N'Insert bảng AdminRole, Permission và RolePermission thành công.';
GO