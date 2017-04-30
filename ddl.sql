CREATE TABLE Location (
name  VARCHAR(20) PRIMARY KEY,
type VARCHAR (20)
);

CREATE TABLE Located_in (
	child VARCHAR (20) REFERENCES Location(name) PRIMARY KEY,
	Parent VARCHAR (20), REFERENCES Location(name) PRIMARY KEY,
);

CREATE TABLE Place (
	name VARCHAR (20) PRIMARY KEY,
	longitude VARCHAR(10),
latitude VARCHAR(10)
address VARCHAR(20),
l_name REFERENCES Location(name)
);

CREATE TABLE Journey (
	start_date DATE,
	start_time TIME,
	nBooked INT DEFAULT 0,
	to VARCHAR(20) REFERENCES Place(name),
	from VARCHAR(20) REFERENCES Place(name),
	assigned VARCHAR(8) REFERENCES Vehicle(code) NOT NULL
	PRIMARY KEY (start_date, start_time, assigned)
);

CREATE TABLE Vehicle (
	code VARCHAR(8) PRIMARY KEY,
  capacity INT
);

CREATE TABLE JourneyBooking(

person_id VARCHAR(10) REFERENCES Member(id),
organizer_id VARCHAR(10) REFERENCES Staff(id),
start_time TIME REFERENCES Journey(start_time),
start_date TIME REFERENCES Journey(start_date),
vehicle_code VARCHAR(8) REFERENCES Vehicle
when DATE
PRIMARY KEY (person_id, organizer_id, start_time, start_date, vehicle_code, when)
);


CREATE TABLE Member(
	lives_in VARCHAR(20) REFERENCES Accommodation(name),
	id CHAR(10) PRIMARY KEY, -- "All Member IDs are created as 10-digit numeric codes"
	given_name VARCHAR(20),
	family_name VARCHAR(20),
	title VARCHAR (20),
	from_place VARCHAR(3) FOREIGN KEY REFERENCES Country(code),
  -- CONSTRAINT is_numeric CHECK id SIMILAR TO '^[0-9]*$'
);

CREATE TABLE Country (
	code VARCHAR(3) PRIMARY KEY,
	name VARCHAR(20)
);

CREATE TABLE Athlete(
id VARCHAR(10) REFERENCES Member(id) PRIMARY KEY
);

CREATE TABLE Official(
id VARCHAR(10) REFERENCES Member(id) PRIMARY KEY
);

CREATE TABLE Staff(
id VARCHAR(10) REFERENCES Member(id) PRIMARY KEY
);

CREATE TABLE Accomodation(
name VARCHAR(20) REFERENCES Place(name) PRIMARY KEY
);

CREATE TABLE Runs(
	Official_id VARCHAR(10) REFERENCES Official(id),
	role VARCHAR(20),
	event_name VARCHAR(20) REFERENCES Event(name),
	PRIMARY KEY (official_id, event_name)
);

CREATE TABLE Sport_Venue(
name VARCHAR(20) REFERENCES Place(name) PRIMARY KEY
);

CREATE TABLE Sport(
name VARCHAR(20) PRIMARY KEY
);


CREATE TABLE Event(
	name VARCHAR(20) PRIMARY KEY,
	result_type VARCHAR(20),
	for, VARCHAR(20) REFERENCES Sport(name),
	held_at VARCHAR(20) REFERENCES Sport_Venue(name)
	date DATE
	time TIME
);

CREATE TABLE Team (
	country_id VARCHAR(3) REFERENCES Country(code),
	name VARCHAR(20)
	PRIMARY KEY (country_id,name)
);

CREATE TABLE Membership (
	a_id VARCHAR(10) REFERENCES Athlete(id), --has to be
	team VARCHAR(20) REFERENCES Team(name)
);

CREATE TABLE Participates (
  medal VARCHAR(20),
  CONSTRAINT valid_medal CHECK medal IN ('gold', 'silver', 'bronze')
);
