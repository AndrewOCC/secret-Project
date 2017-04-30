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
id CHAR(10) PRIMARY KEY FOREIGN KEY REFERENCES Member(id)
);

CREATE TABLE Staff (
id CHAR(10) PRIMARY KEY FOREIGN KEY REFERENCES Member(id)
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
  name VARCHAR(20) PRIMARY KEY FOREIGN KEY REFERENCES Place(name)
);

CREATE TABLE Accomodation (
  name VARCHAR(20) PRIMARY KEY FOREIGN KEY REFERENCES Place(name)
);
