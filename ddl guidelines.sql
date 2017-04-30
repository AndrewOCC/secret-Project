/*
Things to take note of:
  * All Member IDs are created as 10-digit numeric codes;
  * All Vehicle codes are created as 8-digit alphanumeric codes;
  * The medal attribute on the participates relationship can be ‘gold’, ‘silver’ or ‘bronze’, or left
    as NULL if no medal was received.

There should be:
  * an assertion definition (commented out in your DDL) to constrain the nbooked attribute
of Journey to be kept consistent with the number of bookings make for that journey, and
a trigger definition giving equivalent functionality;
  * a view to present all details of an athlete (including those inherited from Member), plus
columns reporting the number of gold, silver and bronze medals received by that athlete.
  * advanced domain constraints, e.g., using regular expressions.

You should map the two participates relationships for team and individual events so
that all results are maintained in a common table. This should be supported by a commented
assertion and equivalent trigger to enforce the constraint that only team-based results should be
recorded for team events, and individual athletes’ results for individual events.

Rachel: From this, I gather that two participates relationships are possible.
There is a separate results table where all results are kept no matter
whether it is an individual or group result. Maybe it can have an attribute 'group' or
'individual'.

Tips:
* It is recommended that you give meaningful names to all your constraints using the
CONSTRAINT clause.
* You may also wish to refine your schema with CHECK constraints to enforce domains constraint
* You should group your statements for ease of reading (e.g., by keeping all table constraints
within the relevant CREATE TABLE statement rather than declaring them externally
*/
