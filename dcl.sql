:connect LANESTRA\SAIGON_NODE -U sa -P hungklv123 -C
use master;
go

create login HR_SAIGON_LOGIN with password = 'hellohr';
print N'Đã tạo login HR_SAIGON_LOGIN';
go

:connect LANESTRA\SAIGON_NODE -U sa -P hungklv123 -C
use miCareer_DB;
create user HR_SAIGON_USER for login HR_SAIGON_LOGIN;

:connect LANESTRA\SAIGON_NODE -U sa -P hungklv123 -C
use master;
use miCareer_DB;
delete from [User] where provId = 'BD';
select * from [User];
grant select on dbo.Company to HR_SAIGON_USER;
grant select on dbo.[User] to HR_SAIGON_USER;
grant insert on dbo.[User] to HR_SAIGON_USER;

:connect LANESTRA\SAIGON_NODE -U HR_SAIGON_LOGIN -P hellohr -C
use miCareer_DB;
insert into [User] (userId, userName, pwd, fname, lName, email, phone, stat, [role], provId, ward, street, createdAt) values
(NEWID(),'nguyenhaihung', 'hashed', N'Hưng',
N'Nguyễn Hải', 'nguyenhaihung0510@gmail.com',
'0339968288', 'Active', 'Admin', 'BD', N'Hòa Long', N'510 Kim Cổ Trấn', GETDATE()); 
select * from [User];

:connect LANESTRA\SAIGON_NODE -U HR_SAIGON_LOGIN -P hellohr -C
use miCareer_DB;
select * from Company;

:connect LANESTRA\SAIGON_NODE -U sa -P hungklv123 -C
use master;
use miCareer_DB;
revoke select on dbo.Company from HR_SAIGON_USER;

:connect LANESTRA\SAIGON_NODE -U HR_SAIGON_LOGIN -P hellohr -C
use miCareer_DB;
select * from Company;