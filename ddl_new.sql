CREATE TABLE Member (
  id CHAR(10) PRIMARY KEY ON DELETE CASCADE,
  first_name VARCHAR(20),
  last_name VARCHAR(20),
  title VARCHAR(5),
  origin CHAR(2) NOT NULL FOREIGN KEY REFERENCES Country(code),
  type VARCHAR(20) NOT NULL,
  CONSTRAINT valid_title CHECK (title IN ('Ms', 'Mr', 'Mrs', 'Dr', 'Miss')),
  CONSTRAINT valid_id CHECK (id SIMILAR TO '^[0-9]*$'), --checks that is numeric
  CONSTRAINT valid_type CHECK (type IN ('Staff', 'Athlete', 'Official'))
);

--this function automatically inserts a member id into the appropriate table
--(staff, athlete, official) depending on the type given.
-- i also want to disallow any real person from inserting into these tables
-- by themself.
CREATE OR REPLACE FUNCTION classify_member() RETURNS trigger AS $classify_member$
  BEGIN
  -- check which type, insert into the appropriate table
    IF (NEW.type LIKE 'Staff') THEN
      INSERT INTO Staff VALUES (NEW.id);
    ELSIF (NEW.type LIKE 'Athlete') THEN
      INSERT INTO Athlete VALUES (NEW.id);
    ELSIF (NEW.type LIKE 'Official') THEN
      INSERT INTO Official (NEW.id);
    END IF;
    RETURN NULL;
  END;
$classify_member$ LANGUAGE plpgsql;

--creating the trigger that does the function
CREATE TRIGGER classify_member
AFTER INSERT ON Member
FOR EACH ROW EXECUTE PROCEDURE classify_member();

CREATE TABLE Country (
	code CHAR(2) PRIMARY KEY, -- guessing this is like the shortcode on grok
	name VARCHAR(20)
);

CREATE TABLE Athlete (
  id CHAR(10) PRIMARY KEY FOREIGN KEY REFERENCES Member(id)
);

CREATE TABLE Official (
id CHAR(10) PRIMARY KEY FOREIGN KEY REFERENCES Member(id)
);

CREATE TABLE Staff (
id CHAR(10) PRIMARY KEY FOREIGN KEY REFERENCES Member(id)
);
