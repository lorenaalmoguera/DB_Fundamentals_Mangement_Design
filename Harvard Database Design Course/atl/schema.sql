CREATE TABLE PASSENGERS (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT,
    last_name TEXT,
    age INTEGER
);

CREATE TABLE AIRLINES (
    name TEXT,
    concourse TEXT,
    PRIMARY KEY (name),
    CHECK (concourse IN ('A', 'B', 'C', 'D', 'E', 'F', 'T'))
);

CREATE TABLE FLIGHTS (
    flight_number INTEGER,
    airline TEXT,
    airport_code_dep TEXT,
    airport_code_ar TEXT,
    expected_del DATE,
    expected_ar DATE,
    PRIMARY KEY (flight_number),
    FOREIGN KEY (airline) REFERENCES AIRLINES(name)
);

CREATE TABLE CHECK_INS (
    check_in_time DATE,
    passenger_id INTEGER,
    flight_number INTEGER,
    PRIMARY KEY (check_in_time,passenger_id),
    FOREIGN KEY (passenger_id) REFERENCES PASSENGERS(id),
    FOREIGN KEY (flight_number) REFERENCES FLIGHTS(flight_number)
);

