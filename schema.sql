-- 1. Khởi tạo Database
USE master;
GO

-- Giai đoạn thiết kế DB sẽ được xóa đi và tạo lại với kiến trúc mới liên tục
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'miCareer_DB')
BEGIN
    -- Ngắt kết nối các user đang dùng để tránh lỗi
    ALTER DATABASE miCareer_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE miCareer_DB;
    PRINT 'Da xoa database miCareer_DB thanh cong';
END
GO

-- Tạo mới cơ sở dữ liệu
CREATE DATABASE miCareer_DB;
PRINT 'Da tao moi database miCareer_DB';
GO

USE miCareer_DB;
GO

-- 2. Các bảng danh mục

-- Bảng HRPosition: Chức vụ của HR
CREATE TABLE HRPosition (
    posId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    posName NVARCHAR(50) NOT NULL UNIQUE,
    [desc] NVARCHAR(MAX)
);

-- Bảng AdminRole: Vai trò của Admin
CREATE TABLE AdminRole (
    roleId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    -- Quy ước tên vai trò Admin trong hệ thống sẽ là mã, không có dấu
    roleName VARCHAR(50) NOT NULL UNIQUE,
    [desc] NVARCHAR(MAX)
);

-- Bảng Permission: Quyền hạn hệ thống
CREATE TABLE Permission (
    permId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    permCode VARCHAR(50) NOT NULL UNIQUE,
    [desc] NVARCHAR(MAX)
);

-- Bảng Skill: Danh mục kỹ năng
CREATE TABLE Skill (
    skillId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    skillName NVARCHAR(50) NOT NULL UNIQUE,
    [desc] NVARCHAR(MAX)
);

-- Bảng EmailType: Loại email
CREATE TABLE EmailType (
    typeId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    typeName NVARCHAR(50) NOT NULL UNIQUE,
    [desc] NVARCHAR(MAX)
);

-- Bảng Province: Danh mục Tỉnh/Thành phố (BẢNG MỚI NÂNG CẤP)
-- Phục vụ ánh xạ Node cho CSDL phân tán
CREATE TABLE Province (
    -- VARCHAR(10): Mã tỉnh là chữ không dấu (VD: 'HN', 'HCM'), chỉ cần 10 ký tự là đủ.
    -- Không dùng UUID vì dữ liệu tỉnh thành là tĩnh, ít thay đổi, mã tự đặt sẽ dễ quản lý hơn.
    provId VARCHAR(10) PRIMARY KEY,
    
    provName NVARCHAR(50) NOT NULL UNIQUE,
    
    -- VARCHAR(30): Mã Node quản lý (VD: 'HANOI_NODE'). 30 ký tự là dư dả.
    nodeCode VARCHAR(30) NOT NULL
);

-- =============================================
-- 3. TẠO CÁC BẢNG CÓ QUAN HỆ CẤP 1 (PHỤ THUỘC VÀO CÁC BẢNG TRÊN)
-- =============================================

-- Bảng RolePermission: Phân quyền (Bảng trung gian N-N)
CREATE TABLE RolePermission (
    roleId UNIQUEIDENTIFIER,
    permId UNIQUEIDENTIFIER,
    -- Khóa chính kép: Kết hợp cả 2 cột để tạo thành 1 định danh duy nhất (1 role không thể có 2 quyền giống hệt nhau).
    PRIMARY KEY (roleId, permId),
    -- Khóa ngoại: Ràng buộc tính toàn vẹn dữ liệu, roleId phải tồn tại trong bảng AdminRole.
    FOREIGN KEY (roleId) REFERENCES AdminRole (roleId),
    FOREIGN KEY (permId) REFERENCES Permission (permId)
);

-- Bảng EmailTemplate: Mẫu Email
CREATE TABLE EmailTemplate (
    tmplId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    typeId UNIQUEIDENTIFIER,
    -- NVARCHAR(200): Tiêu đề email thường không quá dài, 200 ký tự là chuẩn.
    subj NVARCHAR(200),
    body NVARCHAR(MAX),
    [desc] NVARCHAR(MAX),
    FOREIGN KEY (typeId) REFERENCES EmailType (typeId)
);

-- Bảng User: Bảng cha quản lý thông tin đăng nhập (CẬP NHẬT TỈNH THÀNH)
CREATE TABLE [User] (
    userId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    userName VARCHAR(50) NOT NULL UNIQUE,
    -- Mật khẩu đã hash thường dài nên để VARCHAR(255). Không dùng NVARCHAR vì password sinh ra là các ký tự mã hóa Latin.
    pwd VARCHAR(255) NOT NULL,
    fName NVARCHAR(50) NOT NULL,
    lName NVARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) UNIQUE,
    stat VARCHAR(30) NOT NULL,
    [role] VARCHAR(30) NOT NULL,
    
    -- Thay NVARCHAR(50) bằng VARCHAR(10) để tham chiếu tới bảng Province
    provId VARCHAR(10), 
    ward NVARCHAR(50),
    street NVARCHAR(100),
    
    -- DATETIME2(0): Kiểu thời gian lưu cả ngày lẫn giờ. Số (0) nghĩa là lấy độ chính xác tới đơn vị Giây (không lấy phần nghìn giây).
    -- DEFAULT GETDATE(): Tự động lấy ngày giờ hiện tại của hệ thống máy chủ SQL lúc chèn dữ liệu.
    createdAt DATETIME2(0) DEFAULT GETDATE(),
    
    -- Ràng buộc khóa ngoại cho Tỉnh/Thành
    FOREIGN KEY (provId) REFERENCES Province (provId)
);

-- Bảng Company: Thông tin doanh nghiệp (CẬP NHẬT TỈNH THÀNH)
CREATE TABLE Company (
    compId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    compName NVARCHAR(100) NOT NULL,
    taxCode VARCHAR(20) NOT NULL UNIQUE,
    webUrl VARCHAR(255),
    logoUrl VARCHAR(255),
    contactEmail VARCHAR(100),
    
    -- Thay NVARCHAR(50) bằng VARCHAR(10) để làm khóa ngoại
    provId VARCHAR(10), 
    ward NVARCHAR(50),
    street NVARCHAR(100),
    
    FOREIGN KEY (provId) REFERENCES Province (provId)
);

-- =============================================
-- 4. TẠO CÁC BẢNG LIÊN QUAN ĐẾN USER (CANDIDATE, HR, ADMIN)
-- =============================================

CREATE TABLE Candidate (
    -- Dùng chung userId từ bảng User làm khóa chính, thể hiện quan hệ 1-1.
    userId UNIQUEIDENTIFIER PRIMARY KEY,
    bio NVARCHAR(MAX),
    cvUrl VARCHAR(255),
    -- DATE: Chỉ lưu ngày tháng năm sinh (không cần giờ phút).
    dob DATE,
    -- NUMERIC(4,1): Kiểu số thực. Tổng cộng có 4 chữ số, trong đó có 1 chữ số thập phân (VD: 999.5 năm kinh nghiệm).
    expYears NUMERIC(4, 1),
    FOREIGN KEY (userId) REFERENCES [User] (userId)
);

CREATE TABLE HR (
    userId UNIQUEIDENTIFIER PRIMARY KEY,
    posId UNIQUEIDENTIFIER,
    emailSign NVARCHAR(MAX),
    FOREIGN KEY (userId) REFERENCES [User] (userId),
    FOREIGN KEY (posId) REFERENCES HRPosition (posId)
);

CREATE TABLE Admin (
    userId UNIQUEIDENTIFIER PRIMARY KEY,
    lastIp VARCHAR(45), -- 45 ký tự là đủ để lưu cả IPv4 và IPv6.
    roleId UNIQUEIDENTIFIER,
    FOREIGN KEY (userId) REFERENCES [User] (userId),
    FOREIGN KEY (roleId) REFERENCES AdminRole (roleId)
);

-- Bảng CandidateSkill (Bảng trung gian N-N)
CREATE TABLE CandidateSkill (
    userId UNIQUEIDENTIFIER,
    skillId UNIQUEIDENTIFIER,
    PRIMARY KEY (userId, skillId),
    FOREIGN KEY (userId) REFERENCES Candidate (userId),
    FOREIGN KEY (skillId) REFERENCES Skill (skillId)
);

-- =============================================
-- 5. TẠO CÁC BẢNG NGHIỆP VỤ CỐT LÕI (TUYỂN DỤNG, ỨNG TUYỂN, EMAIL)
-- =============================================

CREATE TABLE JobPosting (
    jobPostId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    compId UNIQUEIDENTIFIER,
    title NVARCHAR(150) NOT NULL,
    [desc] NVARCHAR(MAX) NOT NULL,
    
    -- NUMERIC(15,2): Số lưu tiền tệ cực tốt. Tổng 15 chữ số, lấy 2 số sau dấu phẩy (VD: 9,999,999,999,999.99).
    minSalary NUMERIC(15,2),
    maxSalary NUMERIC(15,2),
    
    workLoc NVARCHAR(100),
    workMode VARCHAR(30),
    createdAt DATETIME2(0) DEFAULT GETDATE(),
    expAt DATETIME2(0) NOT NULL,
    FOREIGN KEY (compId) REFERENCES Company (compId)
);

CREATE TABLE JobRequirement (
    jobPostId UNIQUEIDENTIFIER,
    skillId UNIQUEIDENTIFIER,
    PRIMARY KEY (jobPostId, skillId),
    FOREIGN KEY (jobPostId) REFERENCES JobPosting (jobPostId),
    FOREIGN KEY (skillId) REFERENCES Skill (skillId)
);

CREATE TABLE JobApplication (
    jobAppId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    jobPostId UNIQUEIDENTIFIER,
    candidateId UNIQUEIDENTIFIER,
    appliedAt DATETIME2(0) DEFAULT GETDATE(),
    stat VARCHAR(30) NOT NULL,
    cvSnapUrl VARCHAR(255) NOT NULL,
    coverLetter NVARCHAR(MAX),
    FOREIGN KEY (jobPostId) REFERENCES JobPosting (jobPostId),
    FOREIGN KEY (candidateId) REFERENCES Candidate (userId)
);

CREATE TABLE AppStatusHistory (
    histId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    jobAppId UNIQUEIDENTIFIER,
    hrId UNIQUEIDENTIFIER,
    oldStat VARCHAR(30),
    newStat VARCHAR(30),
    changeAt DATETIME2(0) DEFAULT GETDATE(),
    FOREIGN KEY (jobAppId) REFERENCES JobApplication (jobAppId),
    FOREIGN KEY (hrId) REFERENCES HR (userId)
);

CREATE TABLE Interview (
    intervId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    jobAppId UNIQUEIDENTIFIER,
    startAt DATETIME2(0) NOT NULL,
    endAt DATETIME2(0) NOT NULL,
    mode VARCHAR(30),
    linkMeet VARCHAR(255),
    loc NVARCHAR(255),
    FOREIGN KEY (jobAppId) REFERENCES JobApplication (jobAppId)
);

CREATE TABLE InterviewFeedback (
    feedbackId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    intervId UNIQUEIDENTIFIER,
    hrId UNIQUEIDENTIFIER,
    score NUMERIC(4,2), -- Max 10.00 (Tổng 4 chữ số, 2 chữ số thập phân)
    cmt NVARCHAR(MAX),
    subAt DATETIME2(0) DEFAULT GETDATE(),
    FOREIGN KEY (intervId) REFERENCES Interview (intervId),
    FOREIGN KEY (hrId) REFERENCES HR (userId)
);

CREATE TABLE Offer (
    offerId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    jobAppId UNIQUEIDENTIFIER,
    salary NUMERIC(15,2) NOT NULL,
    [desc] NVARCHAR(MAX),
    stat VARCHAR(30),
    subAt DATETIME2(0) DEFAULT GETDATE(),
    -- INT: Kiểu số nguyên 4 byte (phạm vi từ -2 tỷ đến +2 tỷ). Đủ dùng cho việc đếm version.
    ver INT NOT NULL, 
    FOREIGN KEY (jobAppId) REFERENCES JobApplication (jobAppId)
);

CREATE TABLE EmailLog (
    logId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tmplId UNIQUEIDENTIFIER,
    jobAppId UNIQUEIDENTIFIER,
    hrId UNIQUEIDENTIFIER,
    content NVARCHAR(MAX) NOT NULL,
    sentAt DATETIME2(0) DEFAULT GETDATE(),
    rcvEmail VARCHAR(100) NOT NULL,
    FOREIGN KEY (tmplId) REFERENCES EmailTemplate (tmplId),
    FOREIGN KEY (jobAppId) REFERENCES JobApplication (jobAppId),
    FOREIGN KEY (hrId) REFERENCES HR (userId)
);
GO