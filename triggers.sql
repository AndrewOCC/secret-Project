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
      INSERT INTO Sport_Venue VALUES (NEW.name);
    ELSIF (NEW.type LIKE 'Accomodation') THEN
      INSERT INTO Accomodation VALUES (NEW.name);
    END IF;
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER classify_place
AFTER INSERT ON Place
FOR EACH ROW EXECUTE PROCEDURE classify_place();

CREATE OR REPLACE FUNCTION valid_located_entry() RETURNS trigger AS
$$ DECLARE
   parent_type  VARCHAR(20);
   child_type   VARCHAR(20);

  BEGIN
   parent_type = (SELECT type FROM Location WHERE name LIKE NEW.is_in);
   child_type = (SELECT type FROM Location WHERE name LIKE NEW.location);

   IF (NOT((child_type LIKE 'Suburb' AND parent_type LIKE 'Area') OR
   (child_type LIKE 'Area' AND parent_type LIKE 'District'))) THEN
    RAISE EXCEPTION '% and % is not a valid located_in pairing', NEW.location, NEW.is_in;
   END IF;
   RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER valid_located_entry BEFORE INSERT OR UPDATE ON located_in
FOR EACH ROW EXECUTE PROCEDURE valid_located_entry();

--assertion for checking nbooked
-- CREATE ASSERTION valid_nbooked
-- CHECK (NEW.nbooked =
--   (SELECT COUNT(*)
--    FROM JourneyBooking
--    WHERE start_time = NEW.start_time
--    AND start_date = NEW.start_date
--   AND vehicle_code = NEW.assigned))


--this function makes it so that nbooked is automatically incremented
--when you add someone to the journey
CREATE OR REPLACE FUNCTION inc_nbooked() RETURNS trigger AS
$$ BEGIN
    UPDATE Journey
    SET nbooked = nbooked + 1
    WHERE (start_date = NEW.start_date
           AND start_time = NEW.start_time
           AND assigned = NEW.vehicle_code);
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER inc_nbooked AFTER INSERT ON JourneyBooking
FOR EACH ROW EXECUTE PROCEDURE inc_nbooked();


CREATE OR REPLACE FUNCTION check_capacity() RETURNS trigger AS
$$ BEGIN
   capacity := (SELECT capacity FROM Vehicle WHERE code = NEW.vehicle_code);

   current_count := (SELECT COUNT(*) FROM JourneyBooking
                      WHERE start_time = NEW.start_time
                      AND start_date = NEW.start_date
                      AND vehicle_code = NEW.vehicle_code);

    IF (current_count >= capacity) THEN
      RAISE EXCEPTION 'Vehicle with code % is full', NEW.vehicle_code;
    END IF;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_capacity BEFORE INSERT OR UPDATE ON JourneyBooking
FOR EACH ROW EXECUTE PROCEDURE check_capacity();

CREATE OR REPLACE FUNCTION insert_as_competitor() RETURNS trigger AS
$$ BEGIN
    INSERT INTO Competitor VALUES (NEW.id);
    RETURN NULL;
   END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_athlete_as_competitor
AFTER INSERT ON Athlete
FOR EACH ROW EXECUTE PROCEDURE insert_as_competitor();

CREATE TRIGGER insert_team_as_competitor
AFTER INSERT ON Team
FOR EACH ROW EXECUTE PROCEDURE insert_as_competitor();
