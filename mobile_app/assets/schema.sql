PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS employees (
    employee_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    address TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    email TEXT NOT NULL,
    date_of_birth TEXT NOT NULL,
    national_id TEXT NOT NULL,
    id_image_path TEXT,
    passport_number TEXT,
    date_of_employment TEXT NOT NULL,
    position TEXT NOT NULL,
    cv_path TEXT,
    vehicle_registration_number TEXT
);

CREATE TABLE IF NOT EXISTS next_of_kin (
    next_of_kin_id INTEGER PRIMARY KEY,
    phone_number TEXT NOT NULL,
    email TEXT NOT NULL,
    address TEXT NOT NULL,
    relationship TEXT NOT NULL,
    date_of_birth TEXT NOT NULL,
    occupation TEXT NOT NULL,
    id_number TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS directors (
    director_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    address TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    email TEXT NOT NULL,
    date_of_birth TEXT NOT NULL,
    national_id TEXT NOT NULL,
    passport_number TEXT,
    vehicle_registration_number TEXT
);

CREATE TABLE IF NOT EXISTS companies (
    company_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    email TEXT NOT NULL,
    date_of_incorporation TEXT NOT NULL,
    registration_number TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS court_cases (
    court_case_id INTEGER PRIMARY KEY,
    number TEXT NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    date TEXT NOT NULL,
    time TEXT NOT NULL,
    location TEXT NOT NULL,
    description TEXT NOT NULL,
    parties TEXT NOT NULL,
    judge TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS customers (
    customer_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    address TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    email TEXT NOT NULL,
    date_of_birth TEXT NOT NULL,
    national_id TEXT NOT NULL,
    passport_number TEXT,
    vehicle_registration_number TEXT
);

CREATE TABLE IF NOT EXISTS criminal_records (
    criminal_record_id INTEGER PRIMARY KEY,
    description TEXT NOT NULL,
    date TEXT NOT NULL,
    time TEXT NOT NULL,
    location TEXT NOT NULL,
    type TEXT NOT NULL,
    court_case_id INTEGER,
    FOREIGN KEY (court_case_id) REFERENCES court_cases(court_case_id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS previous_transactions (
    previous_transaction_id INTEGER PRIMARY KEY,
    date TEXT NOT NULL,
    time TEXT NOT NULL,
    amount TEXT NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS employment_records (
    employment_record_id INTEGER PRIMARY KEY,
    date TEXT NOT NULL,
    time TEXT NOT NULL,
    description TEXT NOT NULL,
    employee_id INTEGER NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS company_directors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    company_id INTEGER NOT NULL,
    director_id INTEGER NOT NULL,
    UNIQUE(company_id, director_id),
    FOREIGN KEY (company_id) REFERENCES companies(company_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (director_id) REFERENCES directors(director_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS company_employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    company_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    UNIQUE(company_id, employee_id),
    FOREIGN KEY (company_id) REFERENCES companies(company_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS company_next_of_kin (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    company_id INTEGER NOT NULL,
    next_of_kin_id INTEGER NOT NULL,
    UNIQUE(company_id, next_of_kin_id),
    FOREIGN KEY (company_id) REFERENCES companies(company_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (next_of_kin_id) REFERENCES next_of_kin(next_of_kin_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS company_court_cases (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    company_id INTEGER NOT NULL,
    court_case_id INTEGER NOT NULL,
    UNIQUE(company_id, court_case_id),
    FOREIGN KEY (company_id) REFERENCES companies(company_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (court_case_id) REFERENCES court_cases(court_case_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS employee_court_cases (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    court_case_id INTEGER NOT NULL,
    UNIQUE(employee_id, court_case_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (court_case_id) REFERENCES court_cases(court_case_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS employee_criminal_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    criminal_record_id INTEGER NOT NULL,
    UNIQUE(employee_id, criminal_record_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (criminal_record_id) REFERENCES criminal_records(criminal_record_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS customer_criminal_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    criminal_record_id INTEGER NOT NULL,
    UNIQUE(customer_id, criminal_record_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (criminal_record_id) REFERENCES criminal_records(criminal_record_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS customer_transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    previous_transaction_id INTEGER NOT NULL,
    UNIQUE(customer_id, previous_transaction_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (previous_transaction_id) REFERENCES previous_transactions(previous_transaction_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS customer_court_cases (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    court_case_id INTEGER NOT NULL,
    UNIQUE(customer_id, court_case_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (court_case_id) REFERENCES court_cases(court_case_id) ON UPDATE CASCADE ON DELETE CASCADE
);
