USE miCareer_DB;
GO

PRINT N'Insert dữ liệu cho Cụm 3 (Tin tuyển dụng và Kỹ năng)';

-------------------------------------------------------------------
-- 1. Khai báo biến bảng để lưu UUID và ánh xạ thông tin
-------------------------------------------------------------------
-- Lưu lại các jobPostId vừa được sinh ra
DECLARE @JobTable TABLE (jobPostId UNIQUEIDENTIFIER);

-- Bảng tạm ánh xạ Company và Province để lấy chính xác workLoc (tên Tỉnh)
DECLARE @CompMapping TABLE (
    RowID INT IDENTITY(1,1), 
    compId UNIQUEIDENTIFIER, 
    workLoc NVARCHAR(150)
);

INSERT INTO @CompMapping (compId, workLoc)
SELECT c.compId, p.provName 
FROM Company c 
INNER JOIN Province p ON c.provId = p.provId;


-------------------------------------------------------------------
-- 2. Sinh dữ liệu JobPosting (15 Jobs)
-------------------------------------------------------------------
-- createdAt luôn được set = DATEADD(day, -35, expAt) để đảm bảo khoảng cách >= 30 ngày.
INSERT INTO JobPosting (compId, title, [desc], minSalary, maxSalary, workLoc, workMode, createdAt, expAt)
OUTPUT INSERTED.jobPostId INTO @JobTable
SELECT 
    c.compId,
    j.title,
    j.[desc],
    j.minSalary,
    j.maxSalary,
    c.workLoc,
    j.workMode,
    DATEADD(day, -35, j.expAt), -- Đảm bảo createdAt trước expAt 35 ngày
    j.expAt
FROM (
    -- === 3 JOBS ĐÃ HẾT HẠN (expAt < SYSDATETIME()) ===
    SELECT 1 AS RowID, N'Java Backend Developer (Spring Boot)' AS title, N'Yêu cầu 2 năm kinh nghiệm thiết kế API với Java.' AS [desc], 15000000 AS minSalary, 25000000 AS maxSalary, 'Hybrid' AS workMode, DATEADD(day, -10, SYSDATETIME()) AS expAt UNION ALL
    SELECT 2, N'Senior .NET Engineer', N'Thiết kế kiến trúc microservices với C# và .NET Core.', 30000000, 50000000, 'On-site', DATEADD(day, -5, SYSDATETIME()) UNION ALL
    SELECT 3, N'ReactJS Frontend Developer', N'Phát triển giao diện web mượt mà, tối ưu hiệu năng.', 12000000, 20000000, 'Remote', DATEADD(day, -2, SYSDATETIME()) UNION ALL
    
    -- === 12 JOBS ĐANG MỞ (expAt > SYSDATETIME()) ===
    SELECT 4, N'Data Engineer (ETL/Pipeline)', N'Xây dựng Data Warehouse và xử lý luồng dữ liệu lớn.', 25000000, 40000000, 'Hybrid', DATEADD(day, 20, SYSDATETIME()) UNION ALL
    SELECT 5, N'Machine Learning Engineer', N'Nghiên cứu và triển khai các mô hình AI dự đoán.', 35000000, 60000000, 'On-site', DATEADD(day, 25, SYSDATETIME()) UNION ALL
    SELECT 6, N'Node.js Backend Developer', N'Phát triển Backend tốc độ cao với Node.js và Express.', 18000000, 28000000, 'Remote', DATEADD(day, 10, SYSDATETIME()) UNION ALL
    SELECT 1, N'Golang Developer (High Performance)', N'Tối ưu hóa hệ thống Backend xử lý lượng truy cập lớn.', 25000000, 45000000, 'Hybrid', DATEADD(day, 15, SYSDATETIME()) UNION ALL
    SELECT 2, N'Vue.js Frontend Specialist', N'Bảo trì và phát triển SPA bằng hệ sinh thái Vue 3.', 15000000, 25000000, 'On-site', DATEADD(day, 28, SYSDATETIME()) UNION ALL
    SELECT 3, N'AI Research Scientist', N'Nghiên cứu thuật toán Deep Learning cho nhận diện hình ảnh.', 40000000, 80000000, 'Remote', DATEADD(day, 18, SYSDATETIME()) UNION ALL
    SELECT 4, N'Fullstack Developer (React/Node)', N'Phụ trách toàn bộ tính năng từ Frontend đến Backend.', 20000000, 35000000, 'Hybrid', DATEADD(day, 22, SYSDATETIME()) UNION ALL
    SELECT 5, N'Junior Python Developer', N'Hỗ trợ crawl data, làm sạch dữ liệu và viết script tự động hóa.', 10000000, 15000000, 'On-site', DATEADD(day, 30, SYSDATETIME()) UNION ALL
    SELECT 6, N'Senior Data Analyst (SQL/Python)', N'Phân tích dữ liệu người dùng, tạo dashboard báo cáo.', 25000000, 35000000, 'Hybrid', DATEADD(day, 14, SYSDATETIME()) UNION ALL
    SELECT 1, N'Angular Frontend Engineer', N'Phát triển ứng dụng CRM nội bộ công ty với Angular.', 18000000, 28000000, 'On-site', DATEADD(day, 29, SYSDATETIME()) UNION ALL
    SELECT 2, N'PHP Laravel Developer', N'Phát triển và bảo trì hệ thống backend bằng Laravel.', 15000000, 22000000, 'Remote', DATEADD(day, 16, SYSDATETIME()) UNION ALL
    SELECT 3, N'ML Ops Engineer', N'Triển khai mô hình AI lên môi trường production.', 30000000, 50000000, 'Hybrid', DATEADD(day, 12, SYSDATETIME())
) j
-- Dùng phép Modulo rải đều 15 Jobs cho 6 Công ty (RowID từ 1 đến 6)
INNER JOIN @CompMapping c ON c.RowID = ((j.RowID - 1) % 6) + 1;

PRINT N'Đã thêm 15 bài đăng tuyển dụng (JobPosting).';


-------------------------------------------------------------------
-- 3. Map ngẫu nhiên 2-4 kỹ năng cho MỖI Job (JobRequirement)
-------------------------------------------------------------------
INSERT INTO JobRequirement (jobPostId, skillId)
SELECT jobPostId, skillId
FROM (
    SELECT 
        j.jobPostId, 
        s.skillId,
        ROW_NUMBER() OVER(PARTITION BY j.jobPostId ORDER BY NEWID()) as rn,
        -- Random target từ 2 đến 4
        ABS(CHECKSUM(NEWID())) % 3 + 2 as TargetSkills
    FROM @JobTable j
    CROSS JOIN Skill s
) t
WHERE rn <= TargetSkills;

PRINT N'Đã map ngẫu nhiên 2-4 kỹ năng cho mỗi Job.';


-------------------------------------------------------------------
-- 4. Map ngẫu nhiên 3-5 kỹ năng cho MỖI Candidate (CandidateSkill)
-------------------------------------------------------------------
INSERT INTO CandidateSkill (candidateId, skillId)
SELECT candidateId, skillId
FROM (
    SELECT 
        c.candidateId, 
        s.skillId,
        ROW_NUMBER() OVER(PARTITION BY c.candidateId ORDER BY NEWID()) as rn,
        -- Random target từ 3 đến 5
        ABS(CHECKSUM(NEWID())) % 3 + 3 as TargetSkills
    FROM Candidate c
    CROSS JOIN Skill s
) t
WHERE rn <= TargetSkills;

PRINT N'Đã map ngẫu nhiên 3-5 kỹ năng cho mỗi Candidate.';
GO