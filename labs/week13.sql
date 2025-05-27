/* Conditionally drop grandma table and grandma_s sequence. */
DROP TABLE IF EXISTS grandma CASCADE;
 
/* Create the table. */
SELECT 'CREATE TABLE grandma' AS statement;
CREATE TABLE GRANDMA
( grandma_id     SERIAL
, grandma_house  VARCHAR(30)  NOT NULL
, PRIMARY KEY (grandma_id)
);
 
/* Conditionally drop a table and sequence. */
DROP TABLE IF EXISTS tweetie_bird CASCADE;
 
/* Create the table with primary and foreign key out-of-line constraints. */
SELECT 'CREATE TABLE tweetie_bird' AS statement;
CREATE TABLE TWEETIE_BIRD
( tweetie_bird_id     SERIAL
, tweetie_bird_house  VARCHAR(30)   NOT NULL
, grandma_id          INTEGER       NOT NULL
, PRIMARY KEY (tweetie_bird_id)
, CONSTRAINT tweetie_bird_fk        FOREIGN KEY (grandma_id)
  REFERENCES grandma (grandma_id)
);

/* Conditionally drop a table and sequence. */
DROP TABLE IF EXISTS grandma_log CASCADE;

/* Create grandma logging table. */
SELECT 'CREATE TABLE grandma_log' AS statement;
CREATE TABLE grandma_log
( grandma_log_id     SERIAL
, trigger_name       VARCHAR(30)
, trigger_timing     VARCHAR(6)
, trigger_event      VARCHAR(6)
, trigger_type       VARCHAR(12)
, old_grandma_house  VARCHAR(30)
, new_grandma_house  VARCHAR(30));

/* Conditionally drop the function. */
DROP FUNCTION IF EXISTS grandma_dml_f;

/* Create the function for a trigger. */
CREATE FUNCTION grandma_dml_f()
  RETURNS trigger AS
$$
DECLARE
  /* Declare local trigger-scope variables. */
  lv_trigger_name   VARCHAR(30) := 'GRANDMA_DML_T';
  lv_trigger_event  VARCHAR(6);
  lv_trigger_type   VARCHAR(12) := 'FOR EACH ROW';
  lv_trigger_timing VARCHAR(6) := 'BEFORE';
BEGIN
  IF old.grandma_id IS NULL THEN
    lv_trigger_event := 'INSERT';
  ELSE
    lv_trigger_event := 'UPDATE';
  END IF;
  
  /* Log event into the grandma_log table. */
  INSERT INTO grandma_log
  ( trigger_name
  , trigger_event
  , trigger_type
  , trigger_timing
  , old_grandma_house
  , new_grandma_house )
  VALUES
  ( lv_trigger_name
  , lv_trigger_event
  , lv_trigger_type
  , lv_trigger_timing
  , old.grandma_house
  , new.grandma_house );
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER grandma_log_t
  BEFORE INSERT OR UPDATE ON grandma
  FOR EACH ROW EXECUTE FUNCTION grandma_dml_f();

/* Test case for insert statement. */
INSERT INTO grandma
( grandma_id
, grandma_house )
VALUES
( grandma_seq.nextval
,'Red' );

/* Test case for update statement. */
UPDATE grandma
SET    grandma_house = 'Yellow'
WHERE  grandma_house = 'Red';

SELECT   trigger_name
,        trigger_timing
,        trigger_event
,        trigger_type
,        old_grandma_house
,        new_grandma_house
FROM     grandma_log;

/* Delete a row from contact table. */
DELETE
FROM   contact
WHERE  last_name LIKE 'Smith_Wyse';

/* Delete a row from member table. */
DELETE
FROM   member
WHERE  account_number = 'SLC-000040';

/* Conditionally drop a trigger. */
DROP TRIGGER IF EXISTS contact_t;

/* Conditionally drop helper function get_member_id. */
DROP FUNCTION IF EXISTS get_member_id;

/* Create or replace get_member_id function. */
CREATE OR REPLACE
  FUNCTION get_member_id
  ( IN pv_account_number  VARCHAR ) RETURNS INTEGER AS
$$
  /* Required for PL/pgSQL programs. */
  DECLARE
  
    /* Local return variable. */
    lv_retval  INTEGER := 0;  -- Default value is 0.
 
    /* Use a cursor, which will not raise an exception at runtime. */
    find_member_id CURSOR 
    ( cv_account_number  VARCHAR ) FOR
      SELECT m.member_id
	  FROM   member m
	  WHERE  m.account_number = cv_account_number;
 
  BEGIN  
 
    /* Assign a value when a row exists. */
    FOR i IN find_member_id(pv_account_number) LOOP
      lv_retval := i.member_id;
    END LOOP;
 
    /* Return 0 when no row found and the ID # when row found. */
    RETURN lv_retval;
  END;
$$ LANGUAGE plpgsql;

/* Conditionally insert row into the member table. */
DO
$$
DECLARE
  /* Declare a control variable to avoid duplicate inserts. */
  lv_member_id  integer := 0;
  
BEGIN
  /* Check for and assign an existing surrogate key value. */
  lv_member_id := get_member_id('SLC-000040');

  /* Insert row when there is no prior row. */
  IF lv_member_id = 0 THEN
    /* Insert row into the member table. */
    INSERT
    INTO   member
    ( member_type
    , account_number
    , credit_card_number
    , credit_card_type
    , created_by
    , last_updated_by )
    VALUES
    ((SELECT   common_lookup_id
      FROM     common_lookup
      WHERE    common_lookup_table = 'MEMBER'
      AND      common_lookup_column = 'MEMBER_TYPE'
      AND      common_lookup_type = 'INDIVIDUAL')
    ,'SLC-000040'
    ,'6022-2222-3333-4444'
    ,(SELECT   common_lookup_id
      FROM     common_lookup
      WHERE    common_lookup_table = 'MEMBER'
      AND      common_lookup_column = 'CREDIT_CARD_TYPE'
      AND      common_lookup_type = 'DISCOVER_CARD')
    , 1002
    , 1002 );
  END IF;
END;
$$
LANGUAGE plpgsql;

/* Conditionally drop a table and sequence. */
DROP TABLE IF EXISTS contact_log;

/* Create table contact_log table. */
CREATE TABLE contact_log
( contact_log_id  SERIAL
, trigger_name    VARCHAR(128)
, trigger_timing  VARCHAR(6)
, trigger_event   VARCHAR(12)
, trigger_type    VARCHAR(16)
, old_last_name   VARCHAR(30)
, new_last_name   VARCHAR(30));

/* Drop function conditionally. */
DROP FUNCTION IF EXISTS contact_log_f CASCADE;

/* Create function. */
CREATE FUNCTION contact_log_f()
  RETURNS trigger AS
$$
DECLARE
  /* Declare local trigger-scope variables. */
  lv_trigger_name   VARCHAR(30) := 'CONTACT_T';
  lv_trigger_event  VARCHAR(12);
  lv_trigger_type   VARCHAR(16) := 'FOR EACH ROW';
  lv_trigger_timing VARCHAR(6) := 'BEFORE';
BEGIN

  IF old.last_name IS NULL THEN
    /* Replace whitespace with hyphen. */
	new.last_name = REPLACE(new.last_name,' '. '-');

	/* Assign the trigger type. */
    lv_trigger_event := 'INSERT';
  ELSE
    /* Assign the trigger type. */
    lv_trigger_event := 'UPDATE';
  END IF;
  
  /* Log event into the grandma_log table. */
  INSERT INTO grandma_log(event_type, event_message)
    VALUES (TG_OP, 'Last name modified');
  
  /* Raise an exception. */
  IF lv_trigger_event = 'UPDATE'  THEN
    RAISE EXCEPTION 'Attempted to change from hyphenated last_name to two word field.';
  END IF;
  
  /* Return from function to complete SQL action. */
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

/* Create trigger. */
CREATE TRIGGER contact_t
  BEFORE INSERT OR UPDATE ON contact
  FOR EACH ROW EXECUTE FUNCTION contact_log_f();

  /* Insert into the contact table. */
INSERT
INTO   contact
( member_id
, contact_type
, last_name
, first_name
, middle_name
, created_by
, last_updated_by )
VALUES
((SELECT   member_id
  FROM     member
  WHERE    account_number = 'SLC-000040')
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_table = 'MEMBER'
  AND      common_lookup_column = 'MEMBER_TYPE'
  AND      common_lookup_type = 'INDIVIDUAL')
,'Smith Wyse'
,'Samuel'
, NULL
, 1002
, 1002);

/* Verify that the multiword last name is hyphenated. */
SELECT last_name
FROM   contact
WHERE  last_name like 'Smith_Wyse';

/* Update contact table. */
UPDATE contact
SET    last_name = 'Smith Wyse'
WHERE  last_name = 'Smith-Wyse';

/* Verify two rows written to contact_log table. */
SELECT trigger_name
,      trigger_timing
,      old_last_name
,      new_last_name
FROM   contact_log;

/* Query the last name entry of Smith-Wyse after trigger. */
SELECT c.last_name || ', ' || c.first_name AS full_name
FROM   contact c
WHERE  c.last_name LIKE 'Smith_Wyse';