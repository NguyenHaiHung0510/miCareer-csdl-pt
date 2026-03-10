-- 1
USE master;
GO
SELECT 
    session_id AS [ID], 
    status AS [Trạng thái], 
    login_name AS [Tên User], 
    host_name AS [Máy chủ], 
    program_name AS [Phần mềm đang dùng]
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('miCareer_DB');
-- Nếu cần dừng session nào đó, dùng lệnh 'KILL {id}'
KILL 111
-- 2
SELECT 
    name AS [Tên Database], 
    state_desc AS [Trạng thái hoạt động], 
    user_access_desc AS [Quyền truy cập],
    is_published AS [Đang Publish?], 
    is_subscribed AS [Đang Subscribe?]
FROM sys.databases
WHERE name = 'miCareer_DB';

-- 3
SELECT @@SERVERNAME AS [Node Đang Đứng];