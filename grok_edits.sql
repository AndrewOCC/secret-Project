CREATE TABLE Country (
	code CHAR(2) PRIMARY KEY, -- guessing this is like the shortcode on grok
	name VARCHAR(20)
);

CREATE TABLE Locat (
  name VARCHAR(20) PRIMARY KEY, --like "Glebe"
  type VARCHAR(20), -- like Suburb, Area, ..
  CONSTRAINT valid_type CHECK (type IN ('Suburb', 'Area', 'District'))
);

CREATE TABLE Place (
  name VARCHAR(20) PRIMARY KEY,
  longitude DECIMAL(9,6),
  latitude DECIMAL(9,6),
  address VARCHAR(20),
  type VARCHAR(20),
  locat VARCHAR(20) NOT NULL REFERENCES Locat(name),

  CONSTRAINT valid_type CHECK (type IN ('Sport Venue', 'Accommodation')),
  UNIQUE(longitude, latitude) --check: what happens for unique(null)?
);

CREATE TABLE Accommodation (
  name VARCHAR(20) PRIMARY KEY REFERENCES Place(name)
);

CREATE TABLE Member (
  id CHAR(10) PRIMARY KEY,
  first_name VARCHAR(20),
  last_name VARCHAR(20),
  title VARCHAR(5),
  origin CHAR(2) REFERENCES Country(code) NOT NULL,
  type VARCHAR(20) NOT NULL,
  lives_in VARCHAR(20) REFERENCES Accommodation(name),

  CONSTRAINT valid_title CHECK (title IN ('Ms', 'Mr', 'Mrs', 'Dr', 'Miss')),
  CONSTRAINT valid_id CHECK (id SIMILAR TO '^[0-9]*$'), --checks that is numeric
  CONSTRAINT valid_type CHECK (type IN ('Staff', 'Athlete', 'Official'))
);

--start: tables for athlete, official, staff
CREATE TABLE Athlete (
  id CHAR(10) PRIMARY KEY REFERENCES Member(id) ON DELETE CASCADE
);

CREATE TABLE Official (
id CHAR(10) PRIMARY KEY REFERENCES Member(id) ON DELETE CASCADE
);

CREATE TABLE Staff (
id CHAR(10) PRIMARY KEY REFERENCES Member(id) ON DELETE CASCADE
);
--end: tables for athlete, official, staff

CREATE TABLE Located_in (
  locat VARCHAR(20) REFERENCES Locat(name),
  is_in VARCHAR(20) REFERENCES Locat(name),

  PRIMARY KEY (locat, is_in)
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

CREATE TABLE Sport_Event(
  name VARCHAR(40) PRIMARY KEY,
  type VARCHAR(20) NOT NULL,
  for_sport VARCHAR(20) REFERENCES Sport(name),
  result_type VARCHAR(20), --TODO: not sure what this is for
  held_at VARCHAR(20) REFERENCES Sport_Venue(name),
  start_time TIME, --can we not just combine the two fields?
  start_date DATE,

  CONSTRAINT valid_type CHECK (type IN ('Team', 'Individual'))
);
-- I won't make separate tables for this because its such an effort and i've supported
-- it out another way

CREATE TABLE Team (
    id CHAR(10) PRIMARY KEY,
	country_code CHAR(2) REFERENCES Country(code) NOT NULL,
	name VARCHAR(20) NOT NULL,

	UNIQUE (country_code, name)
);

CREATE TABLE Membership (
  team CHAR(10) REFERENCES Team(id) ON DELETE CASCADE,
  member CHAR(10) REFERENCES Athlete(id),

  PRIMARY KEY (team, member)
);

--NO ONE should be allowed to insert into this
CREATE TABLE Competitor (
  id CHAR(10) PRIMARY KEY
);

CREATE TABLE Participates (
  competitor_id CHAR(10) REFERENCES Competitor(id), -- not sure about this
  result VARCHAR(20), --TODO: check what this would have in it?
  medal VARCHAR(20),
  sport_event VARCHAR(40) REFERENCES Sport_Event(name), --check if competitor id is individual, then event should be individual etc

  CONSTRAINT valid_medal CHECK (medal IN ('gold', 'silver', 'bronze')),
  PRIMARY KEY (competitor_id, sport_event)
);
