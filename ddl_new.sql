CREATE TABLE Member (
  id CHAR(10) PRIMARY KEY ON DELETE CASCADE,
  first_name VARCHAR(20),
  last_name VARCHAR(20),
  title VARCHAR(5),
  origin CHAR(2) NOT NULL FOREIGN KEY REFERENCES Country(code),
  type VARCHAR(20) NOT NULL,
  lives_in VARCHAR(20) REFERENCES Accommodation(name),

  CONSTRAINT valid_title CHECK (title IN ('Ms', 'Mr', 'Mrs', 'Dr', 'Miss')),
  CONSTRAINT valid_id CHECK (id SIMILAR TO '^[0-9]*$'), --checks that is numeric
  CONSTRAINT valid_type CHECK (type IN ('Staff', 'Athlete', 'Official'))
);

CREATE TABLE Country (
	code CHAR(2) PRIMARY KEY, -- guessing this is like the shortcode on grok
	name VARCHAR(20)
);
--end of trigger

--start: tables for athlete, official, staff
CREATE TABLE Athlete (
  id CHAR(10) PRIMARY KEY FOREIGN KEY REFERENCES Member(id)
);

CREATE TABLE Official (
id CHAR(10) PRIMARY KEY REFERENCES Member(id)
);

CREATE TABLE Staff (
id CHAR(10) PRIMARY KEY REFERENCES Member(id)
);
--end: tables for athlete, official, staff

CREATE TABLE Location (
  name VARCHAR(20) PRIMARY KEY, --like "Glebe"
  type VARCHAR(20), -- like Suburb, Area, ..
  CONSTRAINT valid_type CHECK type IN ('Suburb', 'Area', 'District')
);

CREATE TABLE Located_in (
  location REFERENCES Location(name),
  is_in REFERENCES Location(name),

  PRIMARY KEY (location, is_in)
);

CREATE TABLE Place (
  name VARCHAR(20) PRIMARY KEY,
  longitude DECIMAL(9,6),
  latitude DECIMAL(9,6),
  address VARCHAR(20),
  type VARCHAR(20),
  location NOT NULL REFERENCES Location(name),

  CONSTRAINT valid_type CHECK type IN ('Sport Venue', 'Accommodation'),
  UNIQUE(longitude, latitude) --check: what happens for unique(null)?
);

CREATE TABLE Sport_Venue (
  name VARCHAR(20) PRIMARY KEY REFERENCES Place(name)
);

--DONT WANT TO ALLOW DIRECT INSERTION/DELETION
CREATE TABLE Sport (
  name VARCHAR(20) PRIMARY KEY
);

CREATE TABLE Accomodation (
  name VARCHAR(20) PRIMARY KEY REFERENCES Place(name)
);

CREATE TABLE Vehicle (
  code CHAR(8) PRIMARY KEY,
  capacity INTEGER
);

CREATE TABLE Journey (
  start_date DATE,
	start_time TIME,
	nbooked INTEGER,
  dest VARCHAR(20) REFERENCES Place(name),
  origin VARCHAR(20) REFERENCES Place(name),
  assigned CHAR(8) REFERENCES Vehicle(code) NOT NULL,

  PRIMARY KEY (start_date, start_time, assigned),
  CONSTRAINT valid_trip CHECK (dest NOT LIKE origin)
);

CREATE TABLE JourneyBooking (
  person_id CHAR(10) REFERENCES Member(id),
  organizer_id VARCHAR(10) REFERENCES Staff(id),
  start_time TIME,
  start_date DATE,
  vehicle_code CHAR(8),
  --i deleted 'when' attribute because i didn't know its purpose,
  --we already have start_time and start_date
  FOREIGN KEY (start_date, start_time, vehicle_code)
  REFERENCES Journey (start_date, start_time, assigned)
  --that exact combination needs to already exist, isn't it!
);

-- SELECT id, COUNT(*)
-- GROUP BY id
-- -- a view to present all details of an athlete (including those inherited from Member), plus
-- -- columns reporting the number of gold, silver and bronze medals received by that athlete.
-- -- a think it needs to contain all like athletes statistics and you just select athlete id
-- SELECT id, title || first_name || last_name AS name, name AS origin, COUNT(*)
--
-- FROM Athlete NATURAL JOIN Member NATURAL JOIN Individual_Participates
-- INNER JOIN Country ON (code = origin)--all will join on id
-- -- You also need to join to get the bronze medals and stuff let's pretend we already have it
--
-- CREATE VIEW Athlete_Statistics AS
-- SELECT

CREATE TABLE Event (
  name VARCHAR(20) PRIMARY KEY,
  type VARCHAR(20) NOT NULL,
  for VARCHAR(20) REFERENCES Sport(name),
  result_type VARCHAR(20), --TODO: not sure what this is for
  held_at VARCHAR(20) REFERENCES Sport_Venue(name),
  start_time TIME, --can we not just combine the two fields?
  start_date DATE,

  CONSTRAINT valid_type CHECK type IN ('Team', 'Individual')
);
-- I won't make separate tables for this because its such an effort and i've supported
-- it out another way

CREATE TABLE Team (
  id CHAR(10) PRIMARY KEY
	country_code CHAR(2) REFERENCES Country(code),
	name VARCHAR(20),

	UNIQUE NOT NULL (country_code, name)
);

CREATE TABLE Membership (
  team REFERENCES Team(id),
  member REFERENCES Athlete(id),

  PRIMARY KEY (team, member)
);

--NO ONE should be allowed to insert into this
CREATE TABLE Competitor (
  id CHAR(10)
);

CREATE TABLE Participates (
  competitor CHAR(10) REFERENCES Competitor(id), -- not sure about this
  result VARCHAR(20), --TODO: check what this would have in it?
  medal VARCHAR(20),
  event REFERENCES Event(name), --check if competitor id is individual, then event should be individual etc

  CONSTRAINT valid_medal CHECK medal IN ('gold', 'silver', 'bronze'),
  PRIMARY KEY (competitor, event)
);

CREATE OR REPLACE FUNCTION correct_event_type() RETURNS trigger AS
$$ DECLARE
   event_type       VARCHAR(20);
   team_competitor  BOOLEAN;

   BEGIN
    event_type = (SELECT type FROM Event WHERE name = NEW.event);
    --this will be a string: either 'Team' or 'Individual'
    team_competitor = (EXISTS (SELECT * FROM Team WHERE id = NEW.competitor));

    IF ((NOT(team_competitor) AND event_type LIKE 'Team')
        OR (team_competitor AND event_type LIKE 'Individual')) THEN
        RAISE EXCEPTION 'The competitor type and event type do not match';
    END IF;
    RETURN NEW;
   END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER correct_event_type BEFORE INSERT OR UPDATE ON Participates
FOR EACH ROW EXECUTE PROCEDURE correct_event_type();
