/* ============================================================
   3️⃣ HR (FINAL FIXED VERSION)
   ============================================================ */

-- Bước 1: Insert User

INSERT INTO [User]
(userName,pwd,fName,lName,email,phone,stat,role,provId)
VALUES
('hr_mt_1','hashed',N'Anh',N'Nam','hr1@microtech.vn',CONCAT('09',ABS(CHECKSUM(NEWID())) % 100000000),'Active','HR','HN'),
('hr_mt_2','hashed',N'Lan',N'Anh','hr2@microtech.vn',CONCAT('09',ABS(CHECKSUM(NEWID())) % 100000000),'Active','HR','HN'),
('hr_cn_1','hashed',N'Minh',N'Tuấn','hr1@cloudnine.vn',CONCAT('09',ABS(CHECKSUM(NEWID())) % 100000000),'Active','HR','DN'),
('hr_cn_2','hashed',N'Thảo',N'Vy','hr2@cloudnine.vn',CONCAT('09',ABS(CHECKSUM(NEWID())) % 100000000),'Active','HR','DN'),
('hr_ai_1','hashed',N'Hải',N'Long','hr1@ai.vn',CONCAT('09',ABS(CHECKSUM(NEWID())) % 100000000),'Active','HR','HCM'),
('hr_ai_2','hashed',N'Ngọc',N'Bích','hr2@ai.vn',CONCAT('09',ABS(CHECKSUM(NEWID())) % 100000000),'Active','HR','HCM');


-- Bước 2: Insert HR bằng cách JOIN lại qua userName

INSERT INTO HR (hrId,posId,emailSign)
SELECT u.userId,
       (SELECT TOP 1 posId FROM HRPosition ORDER BY NEWID()),
       N'<p>Best regards,<br/>HR Team</p>'
FROM [User] u
WHERE u.role = 'HR'
AND NOT EXISTS (
    SELECT 1 FROM HR h WHERE h.hrId = u.userId
);

INSERT INTO Company (compName, taxCode, provId) VALUES
(N'MicroTech', 'TAX-MT-001', 'HN'),
(N'CloudNine', 'TAX-CN-001', 'DN'),
(N'AI Solutions', 'TAX-AI-001', 'HCM');
GO

-- Tạo User là Candidate
INSERT INTO [User] (userName, pwd, fName, lName, email, phone, stat, role, provId) VALUES
('cand_1', 'hashed', N'Huy', N'Trần', 'huy.tran@email.com', '0911223344', 'Active', 'Candidate', 'HN'),
('cand_2', 'hashed', N'Linh', N'Phạm', 'linh.pham@email.com', '0922334455', 'Active', 'Candidate', 'HCM');

-- Bắn ID từ User sang bảng Candidate
INSERT INTO Candidate (candidateId, bio, expYears)
SELECT u.userId, N'Tôi là một lập trình viên đầy nhiệt huyết.', 2.5
FROM [User] u
WHERE u.role = 'Candidate';
GO