DROP TABLE dorm;
DROP TABLE  utility_type_master;
DROP TABLE utility;
DROP TABLE  swipe_log;

CREATE TABLE dorm (
    dorm_id            NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY START WITH 1 NOT NULL,
    resident_id        NUMBER NOT NULL,
    dorm_capacity      NUMBER NOT NULL,
    dorm_state         VARCHAR(50) NOT NULL,
    dorm_zip           CHAR(5) NOT NULL,
    dorm_address_line1 VARCHAR(50) NOT NULL,
    dorm_address_line2 VARCHAR(50),
    CONSTRAINT dorm_unique PRIMARY KEY ( dorm_id ),
    CONSTRAINT dorm_resident_fk FOREIGN KEY ( resident_id )
        REFERENCES resident ( resident_id )
            ON DELETE CASCADE
);

CREATE TABLE utility_type_master (
    utility_id   NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY START WITH 1 NOT NULL,
    utility_name VARCHAR(50) NOT NULL,
    utility_desc VARCHAR(100) NOT NULL,
    CONSTRAINT utility_master_unique PRIMARY KEY ( utility_id )
);

CREATE TABLE utility (
    utility_id  NUMBER,
    access_date DATE NOT NULL,
    dorm_id     NUMBER,
    resident_id NUMBER NOT NULL,
    CONSTRAINT utility_master_fk FOREIGN KEY ( utility_id )
        REFERENCES utility_type_master ( utility_id )
            ON DELETE CASCADE,
    CONSTRAINT utility_dorm_fk FOREIGN KEY ( dorm_id )
        REFERENCES dorm ( dorm_id )
            ON DELETE CASCADE,
    CONSTRAINT utility_unique PRIMARY KEY ( utility_id,
                                            access_date,
                                            dorm_id )
);

CREATE TABLE swipe_log (
    resident_id NUMBER,
    dorm_id     NUMBER,
    swipe_time  DATE NOT NULL,
    CONSTRAINT swipe_dorm_fk FOREIGN KEY ( dorm_id )
        REFERENCES dorm ( dorm_id )
            ON DELETE CASCADE,
    CONSTRAINT swipe_resident_fk FOREIGN KEY ( resident_id )
        REFERENCES resident ( resident_id )
            ON DELETE CASCADE,
    CONSTRAINT swipe_unique PRIMARY KEY ( resident_id,
                                          dorm_id,
                                          swipe_time )
);