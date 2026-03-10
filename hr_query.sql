use master;
use miCareer_DB;

--1. Xem danh sách tin tuyển dụng của công ty:
SELECT * FROM JobPosting 
WHERE compId = '66666666-6666-6666-6666-666666666666' 
ORDER BY createdAt DESC;

--2. Đăng tin tuyển dụng mới:
INSERT INTO JobPosting (jobPostId, compId, title, [desc], minSalary, maxSalary, workLoc, workMode, expAt)
VALUES (NEWID(), '66666666-6666-6666-6666-666666666666', N'Lập trình viên Java Web', 
	N'Nghiên cứu và phát triển hệ thống quản lý...', 15000000, 30000000, N'Tòa nhà ABC, Hải Châu, Đà Nẵng', 
	'onsite', '2026-04-30 23:59:59');

--3. Gán kỹ năng yêu cầu cho Job Posting:
INSERT INTO JobRequirement (jobPostId, skillId) 
VALUES ('44444444-4444-4444-4444-444444444444', '77777777-7777-7777-7777-777777777777');

--4. Lọc hồ sơ ứng tuyển vào một Job, ưu tiên ứng viên ở miền Trung:
SELECT ja.jobAppId, u.fName, u.lName, ja.cvSnapUrl, p.provName
FROM JobApplication ja
JOIN [User] u ON ja.candidateId = u.userId
JOIN Province p ON u.provId = p.provId
WHERE ja.jobPostId = '44444444-4444-4444-4444-444444444444' 
  AND ja.stat = 'Pending' 
  AND p.nodeCode = 'DANANG_NODE';

--5. Cập nhật trạng thái Job Application:
UPDATE JobApplication 
SET stat = 'Interviewing' 
WHERE jobAppId = '55555555-5555-5555-5555-555555555555';

--6. Ghi vết lịch sử chuyển đổi trạng thái:
INSERT INTO AppStatusHistory (histId, jobAppId, userId, oldStat, newStat)
VALUES (NEWID(), '55555555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', 'Pending', 'Interviewing');

--7. Lên lịch phỏng vấn cho ứng viên:
INSERT INTO Interview (intervId, jobAppId, startAt, endAt, mode, linkMeet, loc)
VALUES (NEWID(), '55555555-5555-5555-5555-555555555555', '2026-03-10 09:00:00', '2026-03-10 10:30:00', 'online', 'https://meet.google.com/abc-xyz', NULL);

--8. Thêm phiếu đánh giá sau phỏng vấn:
INSERT INTO InterviewFeedback (feedbackId, intervId, hrId, score, cmt)
VALUES (NEWID(), '88888888-8888-8888-8888-888888888888', '22222222-2222-2222-2222-222222222222', 8.5, N'Ứng viên nắm vững kiến thức về Java Servlets, phù hợp dự án.');

--9. Tạo một Offer mới cho ứng viên:
INSERT INTO Offer (offerId, jobAppId, salary, [desc], stat, ver, hrId)
VALUES (NEWID(), '55555555-5555-5555-5555-555555555555', 20000000, N'Thưởng tháng 13, cấp Mac', 'Pending', 1, '22222222-2222-2222-2222-222222222222');

--10. HR gửi Email (Lưu vào EmailLog):
INSERT INTO EmailLog (logId, tmplId, jobAppId, userId, content, rcvEmail)
VALUES (NEWID(), '99999999-9999-9999-9999-999999999999', '55555555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', N'Chào bạn, chúng tôi rất vui mừng thông báo...', 'hung.nguyen@email.com');