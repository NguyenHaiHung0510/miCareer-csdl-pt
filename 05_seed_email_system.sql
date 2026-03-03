USE miCareer_DB;
GO

/* ============================================================
   SAFE CLEAN
   ============================================================ */

DELETE FROM EmailLog;
DELETE FROM EmailTemplate;
GO


/* ============================================================
   1️⃣ EMAIL TEMPLATE
   ============================================================ */

INSERT INTO EmailTemplate (typeId, subj, body, [desc])
SELECT 
    et.typeId,
    N'Application Received - {{JobTitle}}',
    N'Dear {{CandidateName}},<br/>Your application has been received successfully.',
    N'Auto confirmation email'
FROM EmailType et
WHERE et.typeName = 'ApplicationConfirmation';

INSERT INTO EmailTemplate (typeId, subj, body, [desc])
SELECT 
    et.typeId,
    N'Interview Invitation - {{JobTitle}}',
    N'Dear {{CandidateName}},<br/>You are invited to attend an interview.',
    N'Interview invitation template'
FROM EmailType et
WHERE et.typeName = 'InterviewInvitation';

INSERT INTO EmailTemplate (typeId, subj, body, [desc])
SELECT 
    et.typeId,
    N'Offer Letter - {{JobTitle}}',
    N'Congratulations! We are pleased to offer you {{Salary}} VND.',
    N'Official offer letter template'
FROM EmailType et
WHERE et.typeName = 'OfferLetter';

INSERT INTO EmailTemplate (typeId, subj, body, [desc])
SELECT 
    et.typeId,
    N'Rejection Notice - {{JobTitle}}',
    N'Thank you for applying. Unfortunately, you were not selected.',
    N'Rejection email template'
FROM EmailType et
WHERE et.typeName = 'RejectionNotice';

GO


/* ============================================================
   2️⃣ AUTO EMAIL - APPLICATION CONFIRMATION
   ============================================================ */

INSERT INTO EmailLog (tmplId, jobAppId, userId, content, sentAt, rcvEmail)
SELECT 
    t.tmplId,
    ja.jobAppId,
    NULL,
    REPLACE(REPLACE(t.body,'{{CandidateName}}',u.fName),'{{JobTitle}}',jp.title),
    DATEADD(MINUTE,5,ja.appliedAt),
    u.email
FROM JobApplication ja
JOIN Candidate c ON c.candidateId = ja.candidateId
JOIN [User] u ON u.userId = c.candidateId
JOIN JobPosting jp ON jp.jobPostId = ja.jobPostId
JOIN EmailTemplate t ON t.typeId = (
    SELECT typeId FROM EmailType WHERE typeName = 'ApplicationConfirmation'
);

GO

/* ============================================================
   2️⃣ AUTO EMAIL - APPLICATION CONFIRMATION
   ============================================================ */
INSERT INTO EmailLog (tmplId, jobAppId, userId, content, sentAt, rcvEmail)
SELECT 
    t.tmplId,
    ja.jobAppId,
    ja.candidateId, -- SỬA LỖI NULL: Lấy trực tiếp CandidateId (chính là userId)
    REPLACE(REPLACE(t.body,'{{CandidateName}}',u.fName),'{{JobTitle}}',jp.title),
    DATEADD(MINUTE,5,ja.appliedAt),
    u.email
FROM JobApplication ja
JOIN Candidate c ON c.candidateId = ja.candidateId
JOIN [User] u ON u.userId = c.candidateId
JOIN JobPosting jp ON jp.jobPostId = ja.jobPostId
JOIN EmailTemplate t ON t.typeId = (
    SELECT typeId FROM EmailType WHERE typeName = 'ApplicationConfirmation'
);
GO

/* ============================================================
   3️⃣ INTERVIEW INVITATION EMAIL (Khắc phục lỗi bị cắt cụt)
   ============================================================ */
INSERT INTO EmailLog (tmplId, jobAppId, userId, content, sentAt, rcvEmail)
SELECT 
    t.tmplId,
    i.jobAppId,
    ja.candidateId,
    REPLACE(REPLACE(t.body,'{{CandidateName}}',u.fName),'{{JobTitle}}',jp.title),
    DATEADD(DAY, -1, i.startAt),
    u.email
FROM Interview i
JOIN JobApplication ja ON i.jobAppId = ja.jobAppId
JOIN [User] u ON u.userId = ja.candidateId
JOIN JobPosting jp ON jp.jobPostId = ja.jobPostId
JOIN EmailTemplate t ON t.typeId = (
    SELECT typeId FROM EmailType WHERE typeName = 'InterviewInvitation'
);
GO