CREATE TABLE Member (
  id CHAR(10) PRIMARY KEY,
  first_name VARCHAR(20),
  last_name VARCHAR(20),
  title VARCHAR(5),
  CONSTRAINT valid_title CHECK (title IN ('Ms', 'Mr', 'Mrs', 'Dr', 'Miss')),
  CONSTRAINT valid_id CHECK (id SIMILAR TO '^[0-9]*$') --checks that is numeric
);
