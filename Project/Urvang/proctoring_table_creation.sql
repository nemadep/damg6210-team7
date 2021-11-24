drop table supervisor;
drop table proctor;
drop table shifts;

create table supervisor(
    supervisor_id number not null,
    supervisor_name varchar(50) not null,
    supervisor_address varchar(320) not null,
    supervisor_contact varchar(15) not null 
            check( supervisor_contact like '(???)???-????' ),
    supervisor_email varchar(50) not null 
            check( regexp_like ( supervisor_email, '^(\S+)\@(\S+)\.(\S+)$' ) ),
    constraint supervisor_pk primary key( supervisor_id )
);

create table proctor(
    proctor_id number not null,
    proctor_name varchar(50) not null,
    proctor_contact varchar(15) not null 
            check( proctor_contact like '(???)???-???' ),
    proctor_email varchar(50) not null
            check( regexp_like( proctor_email, '^(\S+)\@(\S+)\.(\S+)$' ) ),
    proctor_address varchar(320) not null,
    proctor_dob date not null,
    constraint proctor_pk primary key( proctor_id )
);

create table shifts(
    shift_type char(4) not null,
    proctor_id number not null,
    shift_date date not null,
    create_at date not null,
    update_at date not null,
    supervisor_id number not null,
    dorm_id number not null,
    constraint shift_pk primary key( shift_type, proctor_id, shift_date ),
    constraint shift_type_fk foreign key( shift_type ) 
            references shifts_type_master( shift_type ),
    constraint proctor_fk foreign key( proctor_id )
            references proctor( proctor_id ),
    constraint supervisor_fk foreign key( supervisor_id )
            references supervisor( supervisor_id ),
    constraint dorm_fk foreign key( dorm_id )
            references dorm( dorm_id )
);