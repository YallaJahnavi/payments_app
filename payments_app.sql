create table user_details(
user_id serial primary key,
user_name varchar(50) unique not null,
pass_word varchar(20) not null,
first_name varchar(50),
last_name varchar(50),
phone_num varchar(10) unique not null,
email varchar(20) unique not null,
address varchar(50));

insert into user_details(
user_name,
pass_word,
first_name,
last_name,
phone_num,
email,
address) values 
('janu_abc','ABCDE','janu','abc','9876543210','janu_abc@gmail.com','123MainStreet'),
('chotu_def','BCDEF','chotu','def','7698325401','chotu_def@gmail.com','456MainStreet');

create table user_account_details(
user_account_id serial primary key,
user_id int references user_details(user_id) on delete cascade,
account_open_date timestamp default current_timestamp,
current_wallet_balance decimal(10,2) default 0.00,
linked_bank_accounts_count int default 0,
wallet_pin varchar(10) not null);

insert into user_account_details(
user_id, current_wallet_balance, linked_bank_accounts_count, wallet_pin) values
(1,5000.00,1,'1234'),(2,2000.00,1,'5678');

create table bank_accounts(
bank_account_id serial primary key,
account_number varchar(20) unique not null,
ifsc_code varchar(10) not null,
bank_name varchar(50),
bank_account_branch_location varchar(50),
user_id int references user_details (user_id) on delete set null,
is_active boolean default true);

insert into bank_accounts(
account_number,ifsc_code,bank_name,bank_account_branch_location, user_id,is_active)
values
('1234567890','IFSC001','HDFCBank','Mumbai',1,TRUE),
('3412785612','IFSC002','ICICIBank','Delhi',2,TRUE);

create table source_types(
source_id serial primary key,
source_type_code varchar(10) unique not null,
source_type_desc varchar(50) not null);

insert into source_types(
source_type_code, source_type_desc) values
('BA','Bank Account'),('WA','Wallet Account'),('TPT','Third Party Transaction');

create table txn_details(
txn_id serial primary key,
txn_date_time timestamp default current_timestamp,
txn_amount decimal(10,2) not null,
source_id int references source_types(source_id),
target_id int,
source_type_id int references source_types(source_id),
destination_type_id int references source_types(source_id));

insert into txn_details(
txn_amount, source_id, target_id, source_type_id, destination_type_id) values
(1000.00,1,2,1,2),
(500.00,2,1,2,1);

select * from user_details;
select * from bank_accounts;
select * from user_account_details;
select * from source_types;
select * from txn_details;

-- 1.Retrieve all users and their bank accounts
select u.user_id, u.user_name,b.bank_name, b.account_number,b.ifsc_code,
b.bank_account_branch_location from user_details u left join bank_accounts b
on u.user_id = b.user_id;

-- 2.get wallet balance from a user
select user_id, current_wallet_balance from 
user_account_details where user_id = 1;

-- 3.total transactions made from wallet accounts
select count(*) as total_wallet_txns from txn_details where source_type_id=
(select source_id from source_types where source_type_code = 'WA');

-- 4.update wallet balance after a transaction
-- update user_account_details set current_wallet_balance = current_wallet_balance-500 where user_id = 1;

-- 5.retrieve bank accounts linked to each other
select u.user_name, count(b.bank_account_id) as linked_accounts from user_details
u left join bank_accounts b on u.user_id = b.user_id group by u.user_name;

-- 6.getting the highest transaction
select max(txn_amount) as highest_transaction from txn_details;

-- 7.list the transactions done by a specific user
select t.txn_id, t.txn_amount, t.txn_date_time from txn_details t join
bank_accounts b on t.source_id=b.bank_account_id join user_details u
on b.user_id = u.user_id where u.user_id = 1;

-- 8.find users who haven't linked any bank accounts
select u.user_name from user_details u left join bank_accounts b on
u.user_id=b.user_id where b.bank_account_id is null;

-- 9.retrieves user details along with the no of transactions they made
select u.user_name, count(t.txn_id) as total_txns from user_details u join
bank_accounts b on u.user_id = b.user_id join
txn_details t on b.bank_account_id=t.source_id 
group by u.user_name;

-- 10. get the total amount transacted from bank accounts
select sum(txn_amount) as total_amount from txn_details where
source_type_id = (select source_id from source_types where source_type_code='BA');

-- 11. Find the most recent transaction
select * from txn_details order by txn_date_time desc limit 1;

-- 12. show wallet users with a balance less than 1000
select user_id, current_wallet_balance from user_account_details where 
current_wallet_balance < 1000;

-- 13. retrieve all the transactions above 500
select * from txn_details where txn_amount > 500;

-- 14. get total deposits made to wallet
select sum(t.txn_amount) as total_deposits from txn_details t join
source_types s on t.destination_type_id = s.source_id where s.source_type_code = 'WA';

-- 15. List all the transactions sorted by amount (highest to lowest)
select * from txn_details order by txn_amount desc;