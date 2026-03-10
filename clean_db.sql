USE master;
GO

-- 1. Tranh quyền ưu tiên cao nhất để không bị Deadlock làm phiền
SET DEADLOCK_PRIORITY HIGH;
GO

-- 2. Ép DB về trạng thái nhiều người dùng, tự động ngắt các kết nối ngầm đang kẹt
ALTER DATABASE miCareer_DB SET MULTI_USER WITH ROLLBACK IMMEDIATE;
GO

-- 3. Gỡ bỏ mọi Replication ẩn
EXEC sp_removedbreplication 'miCareer_DB';
GO

-- 4. An toàn xóa bỏ Database cũ
DROP DATABASE miCareer_DB;
PRINT 'Da xoa miCareer_DB thanh cong!';
GO

-- 5. Tạo lại Database mới tinh tươm
CREATE DATABASE miCareer_DB;
PRINT 'Da tao moi database miCareer_DB san sang de su dung!';
GO