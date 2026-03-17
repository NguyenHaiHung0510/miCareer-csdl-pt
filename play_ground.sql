use master;
use miCareer_DB;
select * from [User];

:connect LANESTRA\HANOI_NODE -U sa -P hungklv123 -C
use master;
use miCareer_DB;
select * from Province;

:connect LANESTRA\DANANG_NODE -U sa -P hungklv123 -C
use master;
use miCareer_DB;
select * from Province;


DELETE FROM Province WHERE provId = 'QT';
