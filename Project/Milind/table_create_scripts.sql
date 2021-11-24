DROP TABLE police;
DROP TABLE incident;
DROP TABLE police_incident_mapping;

CREATE TABLE police ( 
    police_id NUMBER NOT NULL,
    police_name VARCHAR(50) NOT NULL,
    police_gender CHAR(1) NOT NULL CHECK ( police_gender = 'M'
                                            OR police_gender = 'F' ),
    police_contact VARCHAR(15) NOT NULL CHECK ( police_contact LIKE '(???)???-????' ),
    CONSTRAINT police_pk PRIMARY KEY (police_id)
);

CREATE TABLE incident (
    case_id NUMBER NOT NULL,
    dorm_id NUMBER NOT NULL,
    case_type VARCHAR(50) NOT NULL,
    case_description VARCHAR(100) NOT NULL,
    CONSTRAINT incident_pk PRIMARY KEY ( case_id ),
    CONSTRAINT incident_dorm_fk FOREIGN KEY (dorm_id)
        REFERENCES dorm(dorm_id)
);

CREATE TABLE police_incident_mapping (
    police_id NUMBER NOT NULL,
    case_id NUMBER NOT NULL,
    case_status VARCHAR(50) NOT NULL,
    CONSTRAINT police_case_mapping_pk PRIMARY KEY ( police_id, case_id ),
    CONSTRAINT police_case_mapping_police_fk FOREIGN KEY (police_id)
        REFERENCES police(police_id),
    CONSTRAINT police_case_mapping_incident_fk FOREIGN KEY (case_id)
        REFERENCES incident(case_id)
);