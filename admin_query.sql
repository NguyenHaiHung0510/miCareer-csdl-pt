--1. Xem thống kê tổng số ứng viên theo từng Node:
SELECT p.nodeCode, COUNT(u.userId) AS TotalCandidates 
FROM [User] u 
JOIN Province p ON u.provId = p.provId 
WHERE u.[role] = 'Candidate' 
GROUP BY p.nodeCode;

--2. Quản lý danh mục: Thêm một kỹ năng mới:
INSERT INTO Skill (skillId, skillName, [desc]) 
VALUES (NEWID(), N'Hệ quản trị CSDL phân tán', N'Kiến thức thiết kế và chuẩn hóa CSDL phân tán đa miền');

--3. Kiểm tra danh sách AdminRole và số lượng User quản trị:
SELECT ar.roleName, COUNT(a.adminId) AS AdminCount
FROM AdminRole ar 
LEFT JOIN [Admin] a ON ar.roleId = a.roleId 
GROUP BY ar.roleName;

--4. Khóa (Banned) một tài khoản vi phạm:
UPDATE [User] 
SET stat = 'Banned' 
WHERE userId = '11111111-1111-1111-1111-111111111111';

--5. Thống kê top 5 công việc có nhiều lượt ứng tuyển nhất:
SELECT TOP 5 jp.title, COUNT(ja.jobAppId) AS AppCount
FROM JobPosting jp 
JOIN JobApplication ja ON jp.jobPostId = ja.jobPostId
GROUP BY jp.jobPostId, jp.title 
ORDER BY AppCount DESC;

--6. Đối soát hệ thống: Truy xuất lịch sử gửi Email:
SELECT el.sentAt, el.rcvEmail, et.typeName, el.content
FROM EmailLog el 
LEFT JOIN EmailTemplate tmpl ON el.tmplId = tmpl.tmplId
LEFT JOIN EmailType et ON tmpl.typeId = et.typeId
WHERE el.sentAt BETWEEN '2026-03-01 00:00:00' AND '2026-03-31 23:59:59';

--7. Tạo một Email Template mới chuẩn hóa:
INSERT INTO EmailTemplate (tmplId, typeId, subj, body, [desc])
VALUES (NEWID(), '00000000-0000-0000-0000-000000000000', N'Thư mời nhận việc chính thức', N'Chào bạn, công ty xin gửi offer...', N'Mẫu email gửi offer chính thức từ hệ thống');

--8. Quản lý phân quyền: Thêm một quyền cho Role:
INSERT INTO RolePermission (roleId, permId) 
VALUES ('12345678-1234-1234-1234-123456789012', '87654321-4321-4321-4321-210987654321');

--9. Xem báo cáo tỷ lệ trạng thái Offer toàn cục:
SELECT stat, COUNT(offerId) AS TotalOffers
FROM Offer 
GROUP BY stat;

--10. Lấy danh sách doanh nghiệp kèm Node quản lý và số lượng tin tuyển dụng:
SELECT c.compName, p.nodeCode, COUNT(jp.jobPostId) AS TotalPosts
FROM Company c 
JOIN Province p ON c.provId = p.provId
LEFT JOIN JobPosting jp ON c.compId = jp.compId
GROUP BY c.compId, c.compName, p.nodeCode 
ORDER BY TotalPosts DESC;