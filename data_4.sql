USE miCareer_DB;
GO

PRINT N'Insert dữ liệu cho Cụm 4 (Ứng tuyển, Phỏng vấn, Offer)';

-------------------------------------------------------------------
-- 1. Sinh EmailType và EmailTemplate
-------------------------------------------------------------------
DECLARE @EmailTypeTbl TABLE (typeId UNIQUEIDENTIFIER, typeName NVARCHAR(50));
DECLARE @EmailTmplTbl TABLE (tmplId UNIQUEIDENTIFIER, typeName NVARCHAR(50));
DECLARE @TempOutput TABLE (tmplId UNIQUEIDENTIFIER, typeId UNIQUEIDENTIFIER);

-- 1.1 Insert EmailType
INSERT INTO EmailType (typeName, [desc])
OUTPUT INSERTED.typeId, INSERTED.typeName INTO @EmailTypeTbl
VALUES 
    ('Apply_Success', N'Email xác nhận ứng tuyển thành công'),
    ('Interview_Invite', N'Email mời tham gia phỏng vấn'),
    ('Offer_Letter', N'Email gửi lời mời làm việc');

-- 1.2 Insert EmailTemplate
INSERT INTO EmailTemplate (typeId, subj, body, [desc])
OUTPUT INSERTED.tmplId, INSERTED.typeId INTO @TempOutput
SELECT 
    t.typeId,
    CASE t.typeName
        WHEN 'Apply_Success' THEN N'Xác nhận ứng tuyển thành công'
        WHEN 'Interview_Invite' THEN N'Thư mời tham dự phỏng vấn'
        WHEN 'Offer_Letter' THEN N'Chúc mừng! Thư mời nhận việc (Offer Letter)'
    END,
    CASE t.typeName
        WHEN 'Apply_Success' THEN N'Cảm ơn bạn đã ứng tuyển. Chúng tôi sẽ xem xét CV của bạn sớm nhất.'
        WHEN 'Interview_Invite' THEN N'Chúc mừng bạn đã lọt vào vòng phỏng vấn. Vui lòng kiểm tra lịch.'
        WHEN 'Offer_Letter' THEN N'Chúng tôi rất vui mừng chào đón bạn gia nhập công ty. Vui lòng xem chi tiết Offer đính kèm.'
    END,
    N'Template mặc định của hệ thống'
FROM @EmailTypeTbl t;

-- Join lại để lấy thông tin tmplId và typeName
INSERT INTO @EmailTmplTbl (tmplId, typeName)
SELECT o.tmplId, t.typeName
FROM @TempOutput o
JOIN @EmailTypeTbl t ON o.typeId = t.typeId;

PRINT N'Đã khởi tạo EmailType và EmailTemplate.';

-------------------------------------------------------------------
-- 2. Sinh JobApplication
-------------------------------------------------------------------
DECLARE @AppTable TABLE (
    jobAppId UNIQUEIDENTIFIER, 
    jobPostId UNIQUEIDENTIFIER, 
    candidateId UNIQUEIDENTIFIER, 
    appliedAt DATETIME2(0), 
    stat VARCHAR(30)
);

INSERT INTO JobApplication (jobPostId, candidateId, appliedAt, stat, cvSnapUrl)
OUTPUT INSERTED.jobAppId, INSERTED.jobPostId, INSERTED.candidateId, INSERTED.appliedAt, INSERTED.stat
INTO @AppTable
SELECT 
    T.jobPostId, 
    T.candidateId, 
    DATEADD(hour, R.RandHour, T.createdAt) as appliedAt,
    -- Dùng con số cố định từ CROSS APPLY để gán trạng thái
    CASE R.RandStatIndex
        WHEN 0 THEN 'Applied'
        WHEN 1 THEN 'Screening'
        WHEN 2 THEN 'Interviewing'
        WHEN 3 THEN 'Rejected'
        WHEN 4 THEN 'Offered'
    END as stat,
    'https://storage.micareer.vn/cv_snap/' + CAST(T.candidateId AS VARCHAR(36)) + '_' + CAST(T.jobPostId AS VARCHAR(36)) + '.pdf'
FROM (
    -- Subquery lấy an toàn 40 cặp
    SELECT TOP 40 j.jobPostId, c.candidateId, j.createdAt
    FROM JobPosting j 
    CROSS JOIN Candidate c 
    WHERE NOT EXISTS (
        SELECT 1 FROM JobApplication ja
        WHERE ja.jobPostId = j.jobPostId AND ja.candidateId = c.candidateId
    )
    ORDER BY NEWID()
) T
-- Tính toán hàm NEWID() đúng 1 lần duy nhất cho mỗi dòng
CROSS APPLY (
    SELECT 
        ABS(CHECKSUM(NEWID())) % 5 AS RandStatIndex, 
        ABS(CHECKSUM(NEWID())) % 168 + 1 AS RandHour
) R;

PRINT N'Đã thêm ' + CAST(@@ROWCOUNT AS VARCHAR) + N' lượt JobApplication.';

-------------------------------------------------------------------
-- 3. Sinh AppStatusHistory (Lịch sử trạng thái)
-------------------------------------------------------------------
INSERT INTO AppStatusHistory (jobAppId, userId, oldStat, newStat, changeAt)
SELECT
    a.jobAppId,
    H.hrId,
    'Applied', 
    a.stat,
    DATEADD(hour, R.RandLogHour, a.appliedAt) 
FROM @AppTable a
CROSS APPLY (SELECT TOP 1 hrId FROM HR ORDER BY NEWID()) H
CROSS APPLY (SELECT ABS(CHECKSUM(NEWID())) % 48 + 1 AS RandLogHour) R
WHERE a.stat != 'Applied'; 

PRINT N'Đã cập nhật AppStatusHistory.';

-------------------------------------------------------------------
-- 4. Sinh Interview & InterviewFeedback (Khoảng 15 Phỏng vấn)
-------------------------------------------------------------------
DECLARE @InterviewsToInsert TABLE (
    jobAppId UNIQUEIDENTIFIER, startAt DATETIME2(0), endAt DATETIME2(0), hrId UNIQUEIDENTIFIER
);

INSERT INTO @InterviewsToInsert (jobAppId, startAt, endAt, hrId)
SELECT TOP 15
    a.jobAppId,
    T.startAt,
    DATEADD(hour, R.RandDuration, T.startAt),
    H.hrId
FROM @AppTable a
CROSS APPLY (SELECT DATEADD(hour, 48 + ABS(CHECKSUM(NEWID())) % 120, a.appliedAt) AS startAt) T
CROSS APPLY (SELECT TOP 1 hrId FROM HR ORDER BY NEWID()) H
CROSS APPLY (SELECT 1 + ABS(CHECKSUM(NEWID())) % 2 AS RandDuration) R
WHERE a.stat IN ('Interviewing', 'Offered')
ORDER BY NEWID();

DECLARE @InsertedInterviews TABLE (intervId UNIQUEIDENTIFIER, jobAppId UNIQUEIDENTIFIER);

-- Insert Interview (Fix an toàn cho mode)
INSERT INTO Interview (jobAppId, startAt, endAt, mode, linkMeet, loc)
OUTPUT INSERTED.intervId, INSERTED.jobAppId INTO @InsertedInterviews
SELECT 
    jobAppId, startAt, endAt, 
    CASE R.RandMode WHEN 0 THEN 'Online' ELSE 'Offline' END, 
    'https://meet.google.com/mock-id', 
    N'Văn phòng công ty'
FROM @InterviewsToInsert
CROSS APPLY (SELECT ABS(CHECKSUM(NEWID())) % 2 AS RandMode) R;

-- Insert Feedback
INSERT INTO InterviewFeedback (intervId, hrId, score, cmt)
SELECT 
    i.intervId,
    t.hrId,
    5.0 + (ABS(CHECKSUM(NEWID())) % 46) / 10.0,
    N'Ứng viên thể hiện thái độ tốt, kiến thức chuyên môn đáp ứng được yêu cầu cơ bản.'
FROM @InsertedInterviews i
JOIN @InterviewsToInsert t ON i.jobAppId = t.jobAppId;

PRINT N'Đã tạo lịch Interview và Feedback.';

-------------------------------------------------------------------
-- 5. Sinh Offer (Khoảng 5 Offer)
-------------------------------------------------------------------
INSERT INTO Offer (jobAppId, salary, [desc], stat, ver, hrId)
SELECT TOP 5
    a.jobAppId,
    j.minSalary + (ABS(CHECKSUM(NEWID())) % CAST((j.maxSalary - j.minSalary + 1) AS INT)),
    N'Mức lương khởi điểm thử việc 85%. Kèm phụ cấp ăn trưa.',
    'Pending',
    1,
    H.hrId
FROM @AppTable a
JOIN JobPosting j ON a.jobPostId = j.jobPostId
CROSS APPLY (SELECT TOP 1 hrId FROM HR ORDER BY NEWID()) H
WHERE a.stat = 'Offered'
ORDER BY NEWID();

PRINT N'Đã tạo Offer cho các ứng viên trúng tuyển.';

-------------------------------------------------------------------
-- 6. Sinh EmailLog
-------------------------------------------------------------------
-- Log: Gửi email Apply Success
INSERT INTO EmailLog (tmplId, jobAppId, userId, content, rcvEmail)
SELECT 
    (SELECT tmplId FROM @EmailTmplTbl WHERE typeName = 'Apply_Success'),
    a.jobAppId,
    a.candidateId,
    N'Hệ thống đã ghi nhận hồ sơ ứng tuyển của bạn.',
    u.email
FROM @AppTable a
JOIN [User] u ON a.candidateId = u.userId;

-- Log: Gửi email Offer
INSERT INTO EmailLog (tmplId, jobAppId, userId, content, rcvEmail)
SELECT 
    (SELECT tmplId FROM @EmailTmplTbl WHERE typeName = 'Offer_Letter'),
    o.jobAppId,
    a.candidateId,
    N'Vui lòng kiểm tra Offer Letter đính kèm và phản hồi trước ngày mai.',
    u.email
FROM Offer o
JOIN @AppTable a ON o.jobAppId = a.jobAppId
JOIN [User] u ON a.candidateId = u.userId;

PRINT N'Đã ghi nhận EmailLog.';
GO