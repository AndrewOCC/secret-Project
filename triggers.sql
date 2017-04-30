--this function automatically inserts a member id into the appropriate table
--(staff, athlete, official) depending on the type given.
-- i also want to disallow any real person from inserting into these tables
-- by themself.
CREATE OR REPLACE FUNCTION classify_member() RETURNS trigger AS
$$ BEGIN
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
$$ LANGUAGE plpgsql;

--creating the trigger that does the function
CREATE TRIGGER classify_member
AFTER INSERT ON Member
FOR EACH ROW EXECUTE PROCEDURE classify_member();

CREATE OR REPLACE FUNCTION classify_place() RETURNS trigger AS
$$ BEGIN
    IF (NEW.type LIKE 'Sport Venue') THEN
      INSERT INTO Sport_Venue VALUES (NEW.name)
    ELSEIF (NEW.type LIKE 'Accomodation') THEN
      INSERT INTO Accomodation VALUES (NEW.name)
    END IF;
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER classify_place
AFTER INSERT ON Place
FOR EACH ROW EXECUTE PROCEDURE classify_place();
