create table dorm(
dorm_id number NOT NULL,
resident_id number NOT NULL,
dorm_capacity number NOT NULL,
dorm_state varchar(50) NOT NULL,
dorm_zip char(5) NOT NULL,
dorm_address_line1 varchar(50) NOT NULL,
dorm_address_line2 varchar(50),
CONSTRAINT dorm_unique PRIMARY KEY (dorm_id),
CONSTRAINT dorm_resident_fk FOREIGN KEY (resident_id)
        REFERENCES resident(resident_id)
);

create table utility_type_master(
utility_id number NOT NULL,
utility_name varchar(50) NOT NULL,
utility_desc varchar(100) NOT NULL,
CONSTRAINT utility_master_unique PRIMARY KEY (utility_id)
);

create table utility(
utility_id number,
access_date date NOT NULL,
dorm_id number,
resident_id number NOT NULL,
CONSTRAINT utility_master_fk FOREIGN KEY (utility_id)
        REFERENCES utility_type_master(utility_id),
CONSTRAINT utility_dorm_fk FOREIGN KEY (dorm_id)
        REFERENCES dorm(dorm_id),
CONSTRAINT utility_unique PRIMARY KEY (utility_id, access_date, dorm_id)      
);

create table swipe_log(
resident_id number,
dorm_id number,
swipe_time date NOT NULL,
CONSTRAINT swipe_dorm_fk FOREIGN KEY (dorm_id)
        REFERENCES dorm(dorm_id),
CONSTRAINT swipe_resident_fk FOREIGN KEY (resident_id)
        REFERENCES resident(resident_id),
CONSTRAINT swipe_unique PRIMARY KEY (resident_id,dorm_id, swipe_time) 
);

