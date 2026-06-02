CREATE TABLE USERS(
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT,
    last_name TEXT,
    username TEXT,
    passwrd TEXT
);

CREATE TABLE SCHOOLS_AND_UNIVERSITIES(
    name TEXT,
    type TEXT,
    location TEXT,
    year INTEGER,
    PRIMARY KEY(name)
);

CREATE TABLE COMPANIES(
    name TEXT,
    industry TEXT,
    location TEXT,
    PRIMARY KEY(name)
);

CREATE TABLE CONNECTIONS_WITH_PEOPLE(
    first_user_id INTEGER,
    second_user_id INTEGER,
    PRIMARY KEY(first_user_id, second_user_id),
    FOREIGN KEY(first_user_id) REFERENCES USERS,
    FOREIGN KEY(second_user_id) REFERENCES USERS
);

CREATE TABLE SCHOOL_AFFILIATION_USER(
    user_id INTEGER,
    school TEXT,
    start_date DATE NOT NULL,
    end_date DATE,
    type TEXT,
    PRIMARY KEY(user_id, school),
    FOREIGN KEY(user_id) REFERENCES USERS,
    FOREIGN KEY(school) REFERENCES SCHOOLS_AND_UNIVERSITIES
);

CREATE TABLE COMPANY_AFFILIATION_WITH_USER(
    user_id INTEGER,
    company TEXT,
    start_date DATE NOT NULL,
    end_date DATE,
    title TEXT,
    PRIMARY KEY(user_id, company),
    FOREIGN KEY(user_id) REFERENCES USERS(user_id),
    FOREIGN KEY(company) REFERENCES COMPANIES(name)
);


