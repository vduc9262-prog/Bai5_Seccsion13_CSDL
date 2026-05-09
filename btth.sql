create database btth;

use btth;


delimiter $$

create trigger auto_deduct_wallet
before insert on service_usages
for each row
begin

    if (select status from wallets where patient_id = new.patient_id) = 'inactive' then
        signal sqlstate '45000'
        set message_text = 'thất bại: ví trả trước đang bị khóa';
    end if;

    if (select balance from wallets where patient_id = new.patient_id) <
       (select price from services where service_id = new.service_id) then
        signal sqlstate '45000'
        set message_text = 'thất bại: số dư ví không đủ để thanh toán';
    end if;

    set new.actual_price =
    (select price from services where service_id = new.service_id);

    update wallets
    set balance = balance - new.actual_price
    where patient_id = new.patient_id;

end$$

delimiter ;

insert into service_usages (patient_id, service_id)
values (1, 1);

select * from wallets where patient_id = 1;

insert into service_usages (patient_id, service_id)
values (2, 1);

insert into service_usages (patient_id, service_id)
values (3, 2);