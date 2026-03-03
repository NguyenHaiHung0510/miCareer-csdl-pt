--1. Đăng nhập ứng viên:
SELECT u.userId, u.userName, u.[role], c.cvUrl 
FROM [User] u 
JOIN Candidate c ON u.userId = c.candidateId 
WHERE u.email = 'hung.nguyen@email.com' AND u.pwd = 'hashed_password_123' AND u.stat = 'Active';

--2. Ứng viên cập nhật thông tin địa chỉ cư trú:
UPDATE [User] 
SET provId = 'BN', ward = N'Võ Cường', street = N'Bồ Sơn' 
WHERE userId = '11111111-1111-1111-1111-111111111111';

--3. Cập nhật kỹ năng ứng viên:
INSERT INTO CandidateSkill (candidateId, skillId) 
VALUES ('11111111-1111-1111-1111-111111111111', '77777777-7777-7777-7777-777777777777');

--4. Tìm kiếm tin tuyển dụng đang mở tại HANOI_NODE:
SELECT jp.jobPostId, jp.title, c.compName, jp.minSalary, jp.maxSalary
FROM JobPosting jp
JOIN Company c ON jp.compId = c.compId
JOIN Province p ON c.provId = p.provId
WHERE p.nodeCode = 'HANOI_NODE' AND jp.expAt > SYSDATETIME();

--5. Lọc tin tuyển dụng tại HANOI_NODE theo danh sách kỹ năng của ứng viên:
SELECT DISTINCT jp.jobPostId, jp.title 
FROM JobPosting jp
JOIN Company c ON jp.compId = c.compId
JOIN Province p ON c.provId = p.provId
JOIN JobRequirement jr ON jp.jobPostId = jr.jobPostId
JOIN CandidateSkill cs ON jr.skillId = cs.skillId
WHERE cs.candidateId = '11111111-1111-1111-1111-111111111111' 
  AND p.nodeCode = 'HANOI_NODE' 
  AND jp.expAt > SYSDATETIME();

--6. Xem chi tiết Job (JD) và công ty:
SELECT jp.*, c.compName, c.logoUrl, p.provName, c.ward, c.street 
FROM JobPosting jp 
JOIN Company c ON jp.compId = c.compId 
LEFT JOIN Province p ON c.provId = p.provId
WHERE jp.jobPostId = '44444444-4444-4444-4444-444444444444';

--7. Nộp đơn ứng tuyển:
INSERT INTO JobApplication (jobAppId, jobPostId, candidateId, stat, cvSnapUrl, coverLetter)
VALUES (NEWID(), '44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'Pending', 'https://storage/cv/my_cv.pdf', N'Kính gửi bộ phận tuyển dụng, em xin phép nộp đơn...');

--8. Lấy danh sách các công việc đã ứng tuyển:
SELECT ja.jobAppId, jp.title, ja.appliedAt, ja.stat
FROM JobApplication ja 
JOIN JobPosting jp ON ja.jobPostId = jp.jobPostId
WHERE ja.candidateId = '11111111-1111-1111-1111-111111111111' 
ORDER BY ja.appliedAt DESC;

--9. Xem chi tiết lịch trình phỏng vấn của một hồ sơ:
SELECT startAt, endAt, mode, linkMeet, loc
FROM Interview 
WHERE jobAppId = '55555555-5555-5555-5555-555555555555';

--10. Lấy Offer mới nhất để đàm phán:
SELECT TOP 1 offerId, salary, [desc], stat, ver 
FROM Offer 
WHERE jobAppId = '55555555-5555-5555-5555-555555555555' 
ORDER BY ver DESC;