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
    [desc] NVARCHAR(500)
);

-- Bảng AdminRole: Vai trò của Admin
CREATE TABLE AdminRole (
    roleId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    -- Quy ước tên vai trò Admin trong hệ thống sẽ là mã, không có dấu
    roleName VARCHAR(50) NOT NULL UNIQUE,
    [desc] NVARCHAR(500)
);

-- Bảng Permission: Các quyền trong hệ thống của Admin
CREATE TABLE Permission (
    permId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    permCode VARCHAR(50) NOT NULL UNIQUE,
    [desc] NVARCHAR(500)
);

-- Bảng Skill: Danh mục các kỹ năng của ứng viên
CREATE TABLE Skill (
    skillId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    skillName NVARCHAR(50) NOT NULL UNIQUE,
    [desc] NVARCHAR(500)
);

-- Bảng EmailType: Loại email
CREATE TABLE EmailType (
    typeId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    typeName NVARCHAR(50) NOT NULL UNIQUE,
    [desc] NVARCHAR(500)
);

-- Bảng Province: Danh mục Tỉnh/Thành phố trực thuộc TW
-- Bảng này cũng chứa ánh xạ Node cho CSDL phân tán
CREATE TABLE Province (
    -- provId ở đây không cần sử dụng UUID vì danh mục Tỉnh là tĩnh (tạm tính cho 20-30 năm)
    provId VARCHAR(10) PRIMARY KEY,
    provName NVARCHAR(80) NOT NULL UNIQUE,
    -- Mã Node quản lý thông tin từ Tỉnh này
    nodeCode VARCHAR(30) NOT NULL
);

-- 3. Các bảng nghiệp vụ
-- Bảng RolePermission: Bảng ánh xạ AdminRole với các quyền tương ứng trong Permission
CREATE TABLE RolePermission (
    roleId UNIQUEIDENTIFIER NOT NULL,
    permId UNIQUEIDENTIFIER NOT NULL,

    PRIMARY KEY (roleId, permId),
    FOREIGN KEY (roleId) REFERENCES AdminRole (roleId),
    FOREIGN KEY (permId) REFERENCES Permission (permId)
);

-- Bảng EmailTemplate: Các mẫu Email
CREATE TABLE EmailTemplate (
    tmplId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    typeId UNIQUEIDENTIFIER NOT NULL,
    subj NVARCHAR(200),
    body NVARCHAR(MAX),
    [desc] NVARCHAR(500),

    FOREIGN KEY (typeId) REFERENCES EmailType (typeId)
);

CREATE TABLE [User] (
    userId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    userName VARCHAR(50) NOT NULL UNIQUE,
    pwd VARCHAR(300) NOT NULL,  -- Dự trù cho việc băm mật khẩu
    fName NVARCHAR(50) NOT NULL,
    lName NVARCHAR(50) NOT NULL,

    email VARCHAR(400) NOT NULL UNIQUE,
    phone VARCHAR(20) UNIQUE,
    stat VARCHAR(30) NOT NULL,
    [role] VARCHAR(30) NOT NULL,
    
    provId VARCHAR(10), 
    ward NVARCHAR(80),
    street NVARCHAR(150),    
    createdAt DATETIME2(0) DEFAULT GETDATE(),
    
    FOREIGN KEY (provId) REFERENCES Province (provId)
);

CREATE TABLE Company (
    compId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    compName NVARCHAR(200) NOT NULL,
    taxCode VARCHAR(20) NOT NULL UNIQUE,
    webUrl VARCHAR(500),
    logoUrl VARCHAR(500),
    contactEmail VARCHAR(400),
    
    provId VARCHAR(10), 
    ward NVARCHAR(80),
    street NVARCHAR(150),
    
    FOREIGN KEY (provId) REFERENCES Province (provId)
);

CREATE TABLE Candidate (
    candidateId UNIQUEIDENTIFIER PRIMARY KEY,
    bio NVARCHAR(MAX),
    cvUrl VARCHAR(500),
    dob DATE,
    -- Số năm kinh nghiệp được lưu dạng số thực. dự trù có 4 chữ số, trong đó có 1 chữ số thập phân (MAX = 999,9)
    expYears NUMERIC(4, 1),
    FOREIGN KEY (candidateId) REFERENCES [User] (userId)
);

CREATE TABLE HR (
    hrId UNIQUEIDENTIFIER PRIMARY KEY,
    posId UNIQUEIDENTIFIER,
    emailSign NVARCHAR(500),

    FOREIGN KEY (hrId) REFERENCES [User] (userId),
    FOREIGN KEY (posId) REFERENCES HRPosition (posId)
);

CREATE TABLE Admin (
    adminId UNIQUEIDENTIFIER PRIMARY KEY,
    lastIp VARCHAR(80), -- Mặc dù 45 ký tự là đủ để lưu cả IPv4 và IPv6 nhưng dự trù tới 80 ký tự cho cả những cập nhật trong tương lai (nếu có)
    roleId UNIQUEIDENTIFIER,

    FOREIGN KEY (adminId) REFERENCES [User] (userId),
    FOREIGN KEY (roleId) REFERENCES AdminRole (roleId)
);

-- Bảng CandidateSkill: Bảng trung gian ánh xạ Candidate - Skill
CREATE TABLE CandidateSkill (
    candidateId UNIQUEIDENTIFIER,
    skillId UNIQUEIDENTIFIER,
    PRIMARY KEY (candidateId, skillId),
    FOREIGN KEY (candidateId) REFERENCES Candidate (candidateId),
    FOREIGN KEY (skillId) REFERENCES Skill (skillId)
);

CREATE TABLE JobPosting (
    jobPostId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    compId UNIQUEIDENTIFIER,
    title NVARCHAR(150) NOT NULL,
    [desc] NVARCHAR(MAX) NOT NULL,
    
    minSalary NUMERIC(15,2),
    maxSalary NUMERIC(15,2),
    
    workLoc NVARCHAR(150),
    workMode VARCHAR(30),
    createdAt DATETIME2(0) DEFAULT SYSDATETIME(),
    expAt DATETIME2(0) NOT NULL,
    
    FOREIGN KEY (compId) REFERENCES Company (compId)
);

-- Bảng JobRequirement: ánh xạ giữa JobPosting và Skill (N - N)
CREATE TABLE JobRequirement (
    jobPostId UNIQUEIDENTIFIER,
    skillId UNIQUEIDENTIFIER,

    PRIMARY KEY (jobPostId, skillId),
    FOREIGN KEY (jobPostId) REFERENCES JobPosting (jobPostId),
    FOREIGN KEY (skillId) REFERENCES Skill (skillId)
);

CREATE TABLE JobApplication (
    jobAppId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    jobPostId UNIQUEIDENTIFIER NOT NULL,
    candidateId UNIQUEIDENTIFIER NOT NULL,
    appliedAt DATETIME2(0) DEFAULT SYSDATETIME(),
    stat VARCHAR(30) NOT NULL,
    cvSnapUrl VARCHAR(500) NOT NULL,
    coverLetter NVARCHAR(MAX),

    FOREIGN KEY (jobPostId) REFERENCES JobPosting (jobPostId),
    FOREIGN KEY (candidateId) REFERENCES Candidate (candidateId)
);

CREATE TABLE AppStatusHistory (
    histId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    jobAppId UNIQUEIDENTIFIER NOT NULL,
    userId UNIQUEIDENTIFIER NOT NULL,
    oldStat VARCHAR(30),
    newStat VARCHAR(30),
    changeAt DATETIME2(0) DEFAULT SYSDATETIME(),
    
    FOREIGN KEY (jobAppId) REFERENCES JobApplication (jobAppId),
    FOREIGN KEY (userId) REFERENCES [User] (userId)
);

CREATE TABLE Interview (
    intervId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    jobAppId UNIQUEIDENTIFIER NOT NULL,
    startAt DATETIME2(0) NOT NULL,
    endAt DATETIME2(0) NOT NULL,
    mode VARCHAR(30),
    linkMeet VARCHAR(500),
    loc NVARCHAR(150),

    FOREIGN KEY (jobAppId) REFERENCES JobApplication (jobAppId)
);

CREATE TABLE InterviewFeedback (
    feedbackId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    intervId UNIQUEIDENTIFIER NOT NULL,
    hrId UNIQUEIDENTIFIER NOT NULL,
    score NUMERIC(4,2), -- Max 10.00 (Tổng 4 chữ số, 2 chữ số thập phân)
    cmt NVARCHAR(MAX),
    subAt DATETIME2(0) DEFAULT SYSDATETIME(),

    FOREIGN KEY (intervId) REFERENCES Interview (intervId),
    FOREIGN KEY (hrId) REFERENCES HR (hrId)
);

CREATE TABLE Offer (
    offerId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    jobAppId UNIQUEIDENTIFIER NOT NULL,
    salary NUMERIC(15,2) NOT NULL,
    [desc] NVARCHAR(MAX),
    stat VARCHAR(30),
    subAt DATETIME2(0) DEFAULT SYSDATETIME(),
    ver INT NOT NULL,
    hrId UNIQUEIDENTIFIER NOT NULL,

    FOREIGN KEY (hrId) REFERENCES HR (hrId),
    FOREIGN KEY (jobAppId) REFERENCES JobApplication (jobAppId)
);

CREATE TABLE EmailLog (
    logId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tmplId UNIQUEIDENTIFIER,
    jobAppId UNIQUEIDENTIFIER,
    userId UNIQUEIDENTIFIER NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    sentAt DATETIME2(0) DEFAULT SYSDATETIME(),
    rcvEmail VARCHAR(400) NOT NULL,
    
    FOREIGN KEY (tmplId) REFERENCES EmailTemplate (tmplId),
    FOREIGN KEY (jobAppId) REFERENCES JobApplication (jobAppId),
    FOREIGN KEY (userId) REFERENCES [User] (userId)
);
GO