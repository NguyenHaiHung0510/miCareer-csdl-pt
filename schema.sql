
-- 0 Khởi tạo database (xóa và tạo)
USE master;
GO

-- Kiểm tra nếu database đã tồn tại thì thực hiện xóa
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'miCareer_DB')
BEGIN
    -- Chuyển DB về chế độ đơn người dùng và ngắt các kết nối khác
    ALTER DATABASE miCareer_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    
    DROP DATABASE miCareer_DB;
    
    PRINT 'Da xoa database miCareer_DB thanh cong';
END
GO

-- Tạo lại database mới
CREATE DATABASE miCareer_DB;
PRINT 'Da tao moi database miCareer_DB';
GO

USE miCareer_DB;
GO


-- 1. Bảng User (Người dùng hệ thống)
CREATE TABLE [User] (
    userId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    userName VARCHAR(50) UNIQUE NOT NULL,
    pwd VARCHAR(255) NOT NULL,
    fName NVARCHAR(50) NOT NULL,
    lName NVARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    stat VARCHAR(30) NOT NULL,
    [role] VARCHAR(30) NOT NULL,
    prov NVARCHAR(50),
    ward NVARCHAR(50),
    street NVARCHAR(100),
    createdAt DATETIME2(0) DEFAULT SYSDATETIME()
);

-- 2. Bảng Candidate (Ứng viên)
CREATE TABLE Candidate (
    userId UNIQUEIDENTIFIER PRIMARY KEY,
    bio NVARCHAR(MAX),
    cvUrl VARCHAR(255),
    dob DATE,
    expYears NUMERIC(4,1),
    CONSTRAINT FK_Candidate_User FOREIGN KEY (userId) REFERENCES [User](userId)
);

-- 3. Bảng HRPosition (Danh mục chức vụ HR)
CREATE TABLE HRPosition (
    posId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    posName NVARCHAR(50) UNIQUE NOT NULL,
    [desc] NVARCHAR(MAX)
);

-- 4. Bảng HR (Nhân sự tuyển dụng)
CREATE TABLE HR (
    userId UNIQUEIDENTIFIER PRIMARY KEY,
    posId UNIQUEIDENTIFIER,
    emailSign NVARCHAR(MAX),
    CONSTRAINT FK_HR_User FOREIGN KEY (userId) REFERENCES [User](userId),
    CONSTRAINT FK_HR_HRPosition FOREIGN KEY (posId) REFERENCES HRPosition(posId)
);

-- 5. Bảng AdminRole (Danh mục vai trò Admin)
CREATE TABLE AdminRole (
    roleId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    roleName VARCHAR(50) UNIQUE NOT NULL,
    [desc] NVARCHAR(MAX)
);

-- 6. Bảng Admin (Quản trị viên hệ thống)
CREATE TABLE Admin (
    userId UNIQUEIDENTIFIER PRIMARY KEY,
    lastIp VARCHAR(45),
    roleId UNIQUEIDENTIFIER,
    CONSTRAINT FK_Admin_User FOREIGN KEY (userId) REFERENCES [User](userId),
    CONSTRAINT FK_Admin_AdminRole FOREIGN KEY (roleId) REFERENCES AdminRole(roleId)
);

-- 7. Bảng Permission (Danh mục quyền hạn)
CREATE TABLE Permission (
    permId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    permCode VARCHAR(50) UNIQUE NOT NULL,
    [desc] NVARCHAR(MAX)
);

-- 8. Bảng RolePermission (Phân quyền)
CREATE TABLE RolePermission (
    roleId UNIQUEIDENTIFIER,
    permId UNIQUEIDENTIFIER,
    PRIMARY KEY (roleId, permId),
    CONSTRAINT FK_RolePerm_AdminRole FOREIGN KEY (roleId) REFERENCES AdminRole(roleId),
    CONSTRAINT FK_RolePerm_Permission FOREIGN KEY (permId) REFERENCES Permission(permId)
);

-- 9. Bảng Company (Thông tin doanh nghiệp)
CREATE TABLE Company (
    compId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    compName NVARCHAR(100) NOT NULL,
    taxCode VARCHAR(20) UNIQUE NOT NULL,
    webUrl VARCHAR(255),
    logoUrl VARCHAR(255),
    contactEmail VARCHAR(100),
    prov NVARCHAR(50),
    ward NVARCHAR(50),
    street NVARCHAR(100)
);

-- 10. Bảng JobPosting (Tin tuyển dụng)
CREATE TABLE JobPosting (
    jobPostId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    compId UNIQUEIDENTIFIER,
    title NVARCHAR(150) NOT NULL,
    [desc] NVARCHAR(MAX) NOT NULL,
    minSalary NUMERIC(15,2),
    maxSalary NUMERIC(15,2),
    workLoc NVARCHAR(100),
    workMode VARCHAR(30),
    createdAt DATETIME2(0) DEFAULT SYSDATETIME(),
    expAt DATETIME2(0) NOT NULL,
    CONSTRAINT FK_JobPosting_Company FOREIGN KEY (compId) REFERENCES Company(compId)
);

-- 11. Bảng Skill (Kỹ năng)
CREATE TABLE Skill (
    skillId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    skillName NVARCHAR(50) UNIQUE NOT NULL,
    [desc] NVARCHAR(MAX)
);

-- 12. Bảng JobRequirement (Yêu cầu kỹ năng công việc)
CREATE TABLE JobRequirement (
    jobPostId UNIQUEIDENTIFIER,
    skillId UNIQUEIDENTIFIER,
    PRIMARY KEY (jobPostId, skillId),
    CONSTRAINT FK_JobReq_JobPosting FOREIGN KEY (jobPostId) REFERENCES JobPosting(jobPostId),
    CONSTRAINT FK_JobReq_Skill FOREIGN KEY (skillId) REFERENCES Skill(skillId)
);

-- 13. Bảng CandidateSkill (Kỹ năng ứng viên)
CREATE TABLE CandidateSkill (
    userId UNIQUEIDENTIFIER,
    skillId UNIQUEIDENTIFIER,
    PRIMARY KEY (userId, skillId),
    CONSTRAINT FK_CandSkill_Candidate FOREIGN KEY (userId) REFERENCES Candidate(userId),
    CONSTRAINT FK_CandSkill_Skill FOREIGN KEY (skillId) REFERENCES Skill(skillId)
);

-- 14. Bảng JobApplication (Hồ sơ ứng tuyển)
CREATE TABLE JobApplication (
    jobAppId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    jobPostId UNIQUEIDENTIFIER,
    candidateId UNIQUEIDENTIFIER,
    appliedAt DATETIME2(0) DEFAULT SYSDATETIME(),
    stat VARCHAR(30) NOT NULL,
    cvSnapUrl VARCHAR(255) NOT NULL,
    coverLetter NVARCHAR(MAX),
    CONSTRAINT FK_JobApp_JobPosting FOREIGN KEY (jobPostId) REFERENCES JobPosting(jobPostId),
    CONSTRAINT FK_JobApp_Candidate FOREIGN KEY (candidateId) REFERENCES Candidate(userId)
);

-- 15. Bảng AppStatusHistory (Lịch sử trạng thái hồ sơ)
CREATE TABLE AppStatusHistory (
    histId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    jobAppId UNIQUEIDENTIFIER,
    hrId UNIQUEIDENTIFIER,
    oldStat VARCHAR(30),
    newStat VARCHAR(30),
    changeAt DATETIME2(0) DEFAULT SYSDATETIME(),
    CONSTRAINT FK_AppHist_JobApp FOREIGN KEY (jobAppId) REFERENCES JobApplication(jobAppId),
    CONSTRAINT FK_AppHist_HR FOREIGN KEY (hrId) REFERENCES HR(userId)
);

-- 16. Bảng Interview (Buổi phỏng vấn)
CREATE TABLE Interview (
    intervId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    jobAppId UNIQUEIDENTIFIER,
    startAt DATETIME2(0) NOT NULL,
    endAt DATETIME2(0) NOT NULL,
    mode VARCHAR(30),
    linkMeet VARCHAR(255),
    loc NVARCHAR(255),
    CONSTRAINT FK_Interview_JobApp FOREIGN KEY (jobAppId) REFERENCES JobApplication(jobAppId)
);

-- 17. Bảng InterviewFeedback (Đánh giá phỏng vấn)
CREATE TABLE InterviewFeedback (
    feedbackId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    intervId UNIQUEIDENTIFIER,
    hrId UNIQUEIDENTIFIER,
    score NUMERIC(4,2),
    cmt NVARCHAR(MAX),
    subAt DATETIME2(0),
    CONSTRAINT FK_Feedback_Interview FOREIGN KEY (intervId) REFERENCES Interview(intervId),
    CONSTRAINT FK_Feedback_HR FOREIGN KEY (hrId) REFERENCES HR(userId)
);

-- 18. Bảng Offer (Đề nghị tuyển dụng)
CREATE TABLE Offer (
    offerId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    jobAppId UNIQUEIDENTIFIER,
    salary NUMERIC(15,2) NOT NULL,
    [desc] NVARCHAR(MAX),
    stat VARCHAR(30),
    subAt DATETIME2(0),
    ver INT NOT NULL,
    CONSTRAINT FK_Offer_JobApp FOREIGN KEY (jobAppId) REFERENCES JobApplication(jobAppId)
);

-- 19. Bảng EmailType (Loại Email)
CREATE TABLE EmailType (
    typeId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    typeName NVARCHAR(50) UNIQUE NOT NULL,
    [desc] NVARCHAR(MAX)
);

-- 20. Bảng EmailTemplate (Mẫu Email)
CREATE TABLE EmailTemplate (
    tmplId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    subj NVARCHAR(200),
    body NVARCHAR(MAX),
    [desc] NVARCHAR(MAX),
    typeId UNIQUEIDENTIFIER,
    CONSTRAINT FK_EmailTmpl_EmailType FOREIGN KEY (typeId) REFERENCES EmailType(typeId)
);

-- 21. Bảng EmailLog (Lịch sử gửi Email)
CREATE TABLE EmailLog (
    logId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tmplId UNIQUEIDENTIFIER,
    jobAppId UNIQUEIDENTIFIER,
    hrId UNIQUEIDENTIFIER,
    content NVARCHAR(MAX) NOT NULL,
    sentAt DATETIME2(0) DEFAULT SYSDATETIME(),
    rcvEmail VARCHAR(100) NOT NULL,
    CONSTRAINT FK_EmailLog_EmailTmpl FOREIGN KEY (tmplId) REFERENCES EmailTemplate(tmplId),
    CONSTRAINT FK_EmailLog_JobApp FOREIGN KEY (jobAppId) REFERENCES JobApplication(jobAppId),
    CONSTRAINT FK_EmailLog_HR FOREIGN KEY (hrId) REFERENCES HR(userId)
);