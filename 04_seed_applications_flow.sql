USE miCareer_DB;
GO

/* ============================================================
   SAFE CLEAN
   ============================================================ */

DELETE FROM Offer;
DELETE FROM InterviewFeedback;
DELETE FROM Interview;
DELETE FROM AppStatusHistory;
DELETE FROM JobApplication;
GO


/* ============================================================
   1️⃣ CREATE JOB APPLICATION
   Logic: random candidate apply random job
   (đảm bảo có data trước, rồi mới tối ưu matching sau)
   ============================================================ */

DECLARE @AppTable TABLE (
    jobAppId UNIQUEIDENTIFIER,
    jobPostId UNIQUEIDENTIFIER,
    candidateId UNIQUEIDENTIFIER,
    appliedAt DATETIME2(0)
);

INSERT INTO JobApplication
(jobPostId, candidateId, appliedAt, stat, cvSnapUrl, coverLetter)
OUTPUT INSERTED.jobAppId, INSERTED.jobPostId, INSERTED.candidateId, INSERTED.appliedAt
INTO @AppTable
SELECT TOP 20
    jp.jobPostId,
    c.candidateId,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 10, GETDATE()),
    'Applied',
    CONCAT('https://snapshot/', c.candidateId, '_', jp.jobPostId, '.pdf'),
    N'I am very interested in this position.'
FROM JobPosting jp
CROSS JOIN Candidate c
ORDER BY NEWID();


/* ============================================================
   2️⃣ STATUS HISTORY
   ============================================================ */

-- Applied → Screening
INSERT INTO AppStatusHistory (jobAppId, userId, oldStat, newStat, changeAt)
SELECT a.jobAppId,
       (SELECT TOP 1 hrId FROM HR ORDER BY NEWID()),
       'Applied',
       'Screening',
       DATEADD(HOUR,1,a.appliedAt)
FROM @AppTable a;

-- Screening → Interviewing (70%)
INSERT INTO AppStatusHistory (jobAppId, userId, oldStat, newStat, changeAt)
SELECT a.jobAppId,
       (SELECT TOP 1 hrId FROM HR ORDER BY NEWID()),
       'Screening',
       'Interviewing',
       DATEADD(HOUR,5,a.appliedAt)
FROM @AppTable a
WHERE ABS(CHECKSUM(a.jobAppId)) % 10 < 7;

-- Screening → Rejected (30%)
INSERT INTO AppStatusHistory (jobAppId, userId, oldStat, newStat, changeAt)
SELECT a.jobAppId,
       (SELECT TOP 1 hrId FROM HR ORDER BY NEWID()),
       'Screening',
       'Rejected',
       DATEADD(HOUR,5,a.appliedAt)
FROM @AppTable a
WHERE ABS(CHECKSUM(a.jobAppId)) % 10 >= 7;


/* ============================================================
   3️⃣ INTERVIEW
   ============================================================ */

DECLARE @InterviewTable TABLE (
    intervId UNIQUEIDENTIFIER,
    jobAppId UNIQUEIDENTIFIER
);

INSERT INTO Interview
(jobAppId, startAt, endAt, mode, linkMeet, loc)
OUTPUT INSERTED.intervId, INSERTED.jobAppId
INTO @InterviewTable
SELECT
    a.jobAppId,
    DATEADD(DAY,1,a.appliedAt),
    DATEADD(HOUR,2,DATEADD(DAY,1,a.appliedAt)),
    CASE WHEN ABS(CHECKSUM(a.jobAppId)) % 2 = 0 THEN 'Online' ELSE 'Offline' END,
    'https://meet.link/session',
    N'Company Meeting Room'
FROM @AppTable a
WHERE EXISTS (
    SELECT 1 FROM AppStatusHistory h
    WHERE h.jobAppId = a.jobAppId
      AND h.newStat = 'Interviewing'
);


/* ============================================================
   4️⃣ INTERVIEW FEEDBACK
   ============================================================ */

INSERT INTO InterviewFeedback (intervId, hrId, score, cmt, subAt)
SELECT i.intervId,
       (SELECT TOP 1 hrId FROM HR ORDER BY NEWID()),
       CAST((ABS(CHECKSUM(NEWID())) % 40 + 60) / 10.0 AS NUMERIC(4,2)),
       N'Good technical skills.',
       GETDATE()
FROM @InterviewTable i;

INSERT INTO InterviewFeedback (intervId, hrId, score, cmt, subAt)
SELECT i.intervId,
       (SELECT TOP 1 hrId FROM HR ORDER BY NEWID()),
       CAST((ABS(CHECKSUM(NEWID())) % 40 + 40) / 10.0 AS NUMERIC(4,2)),
       N'Needs improvement in communication.',
       GETDATE()
FROM @InterviewTable i;


/* ============================================================
   5️⃣ OFFER
   ============================================================ */

INSERT INTO Offer (jobAppId, salary, [desc], stat, subAt, ver, hrId)
SELECT TOP 5
    a.jobAppId,
    25000000,
    N'Initial offer package.',
    'Pending',
    GETDATE(),
    1,
    (SELECT TOP 1 hrId FROM HR ORDER BY NEWID())
FROM @AppTable a;

INSERT INTO Offer (jobAppId, salary, [desc], stat, subAt, ver, hrId)
SELECT TOP 2
    jobAppId,
    28000000,
    N'Revised offer after negotiation.',
    'Accepted',
    GETDATE(),
    2,
    (SELECT TOP 1 hrId FROM HR ORDER BY NEWID())
FROM Offer
WHERE ver = 1;

GO