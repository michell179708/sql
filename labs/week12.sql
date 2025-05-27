/* Conditionally drop grandma table and grandma_s sequence. */
BEGIN
  FOR i IN (SELECT object_name
            ,      object_type
            FROM   user_objects
            WHERE  object_name IN ('GRANDMA','GRANDMA_SEQ')) LOOP
    IF i.object_type = 'TABLE' THEN
      /* Use the cascade constraints to drop the dependent constraint. */
      EXECUTE IMMEDIATE 'DROP TABLE '||i.object_name||' CASCADE CONSTRAINTS';
    ELSE
      EXECUTE IMMEDIATE 'DROP SEQUENCE '||i.object_name;
    END IF;
  END LOOP;
END;
/
 
/* Create the table. */
CREATE TABLE GRANDMA
( grandma_id     NUMBER       CONSTRAINT grandma_nn1 NOT NULL
, grandma_house  VARCHAR2(30) CONSTRAINT grandma_nn2 NOT NULL
, CONSTRAINT grandma_pk       PRIMARY KEY (grandma_id)
);
 
/* Create the sequence. */
CREATE SEQUENCE grandma_seq;
 
/* Conditionally drop a table and sequence. */
BEGIN
  FOR i IN (SELECT object_name
            ,      object_type
            FROM   user_objects
            WHERE  object_name IN ('TWEETIE_BIRD','TWEETIE_BIRD_SEQ')) LOOP
    IF i.object_type = 'TABLE' THEN
      EXECUTE IMMEDIATE 'DROP TABLE '||i.object_name||' CASCADE CONSTRAINTS';
    ELSE
      EXECUTE IMMEDIATE 'DROP SEQUENCE '||i.object_name;
    END IF;
  END LOOP;
END;
/
 
/* Create the table with primary and foreign key out-of-line constraints. */
CREATE TABLE TWEETIE_BIRD
( tweetie_bird_id     NUMBER        CONSTRAINT tweetie_bird_nn1 NOT NULL
, tweetie_bird_house  VARCHAR2(30)  CONSTRAINT tweetie_bird_nn2 NOT NULL
, grandma_id          NUMBER        CONSTRAINT tweetie_bird_nn3 NOT NULL
, CONSTRAINT tweetie_bird_pk        PRIMARY KEY (tweetie_bird_id)
, CONSTRAINT tweetie_bird_fk        FOREIGN KEY (grandma_id)
  REFERENCES GRANDMA (GRANDMA_ID)
);
 
/* Create sequence. */
CREATE SEQUENCE tweetie_bird_seq;

/* Conditionally drop a table and sequence. */
BEGIN
 FOR i IN (SELECT object_name
           ,      object_type
           FROM   user_objects
           WHERE  object_name IN ('GRANDMA_LOG','GRANDMA_LOG_SEQ')) LOOP
   IF i.object_type = 'TABLE' THEN
     EXECUTE IMMEDIATE 'DROP TABLE '||i.object_name||' CASCADE CONSTRAINTS';
   ELSE
     EXECUTE IMMEDIATE 'DROP SEQUENCE '||i.object_name;
   END IF;
 END LOOP;
END;
/

/* Create a log table. */
CREATE TABLE grandma_log
( grandma_log_id     NUMBER
, trigger_name       VARCHAR2(30)
, trigger_timing     VARCHAR2(6)
, trigger_event      VARCHAR2(6)
, trigger_type       VARCHAR2(12)
, old_grandma_house  VARCHAR2(30)
, new_grandma_house  VARCHAR2(30));

/* Create log sequence. */
CREATE SEQUENCE grandma_log_seq;

CREATE OR REPLACE TRIGGER grandma_dml_t
 BEFORE INSERT OR UPDATE OR DELETE ON grandma
 FOR EACH ROW
DECLARE
 /* Declare local trigger-scope variables. */
 lv_sequence_id    NUMBER := grandma_log_seq.NEXTVAL;
 lv_trigger_name   VARCHAR2(30) := 'GRANDMA_INSERT_T';
 lv_trigger_event  VARCHAR2(6);
 lv_trigger_type   VARCHAR2(12) := 'FOR EACH ROW';
 lv_trigger_timing VARCHAR2(6) := 'BEFORE';
BEGIN
 /* Check the event type. */
 IF INSERTING THEN
   lv_trigger_event := 'INSERT';
 ELSIF UPDATING THEN
   lv_trigger_event := 'UPDATE';
 ELSIF DELETING THEN
   lv_trigger_event := 'DELETE';
 END IF;

 /* Log event into the grandma_log table. */
 INSERT INTO grandma_log
 ( grandma_log_id
 , trigger_name
 , trigger_event
 , trigger_type
 , trigger_timing
 , old_grandma_house
 , new_grandma_house )
 VALUES
 ( lv_sequence_id
 , lv_trigger_name
 , lv_trigger_event
 , lv_trigger_type
 , lv_trigger_timing
 , :old.grandma_house
 , :new.grandma_house );
END grandma_insert_t;
/

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

/* Test case for delete statement. */
DELETE 
FROM   grandma
WHERE  grandma_house = 'Yellow';

COL trigger_name      FORMAT A16
COL old_grandma_house FORMAT A12
COL new_grandma_house FORMAT A12
SELECT   trigger_name
,        trigger_timing
,        trigger_event
,        trigger_type
,        old_grandma_house
,        new_grandma_house
FROM grandma_log;

CREATE OR REPLACE 
  PROCEDURE write_grandma_log
  ( pv_trigger_name       VARCHAR2
  , pv_trigger_event      VARCHAR2
  , pv_trigger_type       VARCHAR2
  , pv_trigger_timing     VARCHAR2
  , pv_old_grandma_house  VARCHAR2
  , pv_new_grandma_house  VARCHAR2 ) IS
  
  /* the precompiler directive to autonomous. */
  PRAGMA autonomous_transaction;

BEGIN
  
    /* Log event into the grandma_log table. */
    INSERT INTO grandma_log
    ( grandma_log_id
    , trigger_name
    , trigger_event
    , trigger_type
    , trigger_timing
    , old_grandma_house
    , new_grandma_house )
    VALUES
    ( grandma_log_seq.nextval
    , pv_trigger_name
    , pv_trigger_event
    , pv_trigger_type
    , pv_trigger_timing
    , pv_old_grandma_house
    , pv_new_grandma_house );
	
	/* Commit the transaction. */
	COMMIT;
	
EXCEPTION
  WHEN others THEN
    ROLLBACK;

END write_grandma_log;

CREATE OR REPLACE TRIGGER grandma_dml_t
  BEFORE INSERT OR UPDATE OR DELETE ON grandma
  FOR EACH ROW
DECLARE
  /* Declare local trigger-scope variables. */
  lv_trigger_name   VARCHAR2(30) := 'GRANDMA_INSERT_T';
  lv_trigger_event  VARCHAR2(6);
  lv_trigger_type   VARCHAR2(12) := 'FOR EACH ROW';
  lv_trigger_timing VARCHAR2(6) := 'BEFORE';
BEGIN
  /* Check the event type. */
  IF INSERTING THEN
    lv_trigger_event := 'INSERT';
  ELSIF UPDATING THEN
    lv_trigger_event := 'UPDATE';
  ELSIF DELETING THEN
    lv_trigger_event := 'DELETE';
  END IF;
  
  /* Log event into the grandma_log table. */
  write_grandma_log(
      pv_trigger_name      => lv_trigger_name
    , pv_trigger_event     => lv_trigger_event
    , pv_trigger_type      => lv_trigger_type
    , pv_trigger_timing    => lv_trigger_timing
    , pv_old_grandma_house => :old.grandma_house
    , pv_new_grandma_house => :new.grandma_house );

END grandma_dml_t;
/

/* Test case for insert statement. */
INSERT INTO grandma
( grandma_id
, grandma_house )
VALUES
( grandma_seq.nextval
,'Blue' );

/* Test case for update statement. */
UPDATE grandma
SET    grandma_house = 'Green'
WHERE  grandma_house = 'Blue';

/* Test case for delete statement. */
DELETE 
FROM   grandma
WHERE  grandma_house = 'Green';

COL trigger_name      FORMAT A16
COL old_grandma_house FORMAT A12
COL new_grandma_house FORMAT A12
SELECT   trigger_name
,        trigger_timing
,        trigger_event
,        trigger_type
,        old_grandma_house
,        new_grandma_house
FROM grandma_log;

/* Delete a row from contact table. */
DELETE
FROM   contact
WHERE  last_name LIKE 'Smith_Wyse';

/* Delete a row from member table. */
DELETE
FROM   member
WHERE  account_number = 'SLC-000040';

/* Conditionally drop a trigger. */
DECLARE
  success  BOOLEAN := FALSE;
BEGIN
  FOR i IN (SELECT trigger_name
            FROM   user_triggers
            WHERE  trigger_name = 'CONTACT_T') LOOP
    EXECUTE IMMEDIATE 'DROP TRIGGER '||i.trigger_name;
	
    /* Set success to true. */
    success := TRUE;
	
    /* Print successful message. */
    dbms_output.put_line('Dropped trigger.');
  END LOOP;
  
  IF NOT success THEN
    /* Print successful message. */
    dbms_output.put_line('Failed to drop trigger ');
  END IF; 
END;
/

/* Conditionally drop a trigger. */
DECLARE
  success  BOOLEAN := FALSE;
BEGIN
  FOR i IN (SELECT trigger_name
            FROM   user_triggers
            WHERE  trigger_name = 'CONTACT_T') LOOP
    EXECUTE IMMEDIATE 'DROP TRIGGER '||i.trigger_name;
	
    /* Set success to true. */
    success := TRUE;
	
    /* Print successful message. */
    dbms_output.put_line('Dropped trigger.');
  END LOOP;
  
  IF NOT success THEN
    /* Print successful message. */
    dbms_output.put_line('Failed to drop trigger ');
  END IF; 
END;
/

/* Conditionally drop a table and sequence. */
BEGIN
  FOR i IN (SELECT object_name
            ,      object_type
            FROM   user_objects
            WHERE  object_name IN ('CONTACT_LOG','CONTACT_LOG_SEQ')) LOOP
    IF i.object_type = 'TABLE' THEN
      EXECUTE IMMEDIATE 'DROP TABLE '||i.object_name||' CASCADE CONSTRAINTS';
    ELSE
      EXECUTE IMMEDIATE 'DROP SEQUENCE '||i.object_name;
    END IF;
  END LOOP;
END;
/

/* Create table contact_log table. */
CREATE TABLE contact_log
( contact_log_id  NUMBER
, trigger_name    VARCHAR(128)
, trigger_timing  VARCHAR(6)
, trigger_event   VARCHAR(12)
, trigger_type    VARCHAR(16)
, old_last_name   VARCHAR(30)
, new_last_name   VARCHAR(30));

/* Drop a sequence. */
DROP SEQUENCE contact_log_seq;

/* Create a sequence. */
CREATE SEQUENCE contact_log_seq START WITH 1001;

/* Create or replace procedure. */
CREATE OR REPLACE
  PROCEDURE contact_log_p 
  ( pv_trigger_name    IN  VARCHAR2
  , pv_trigger_timing  IN  VARCHAR2
  , pv_trigger_event   IN  VARCHAR2
  , pv_trigger_type    IN  VARCHAR2
  , pv_old_last_name   IN  VARCHAR2
  , pv_new_last_name   IN  VARCHAR2 ) IS

    /* Set precompiler directive. */
    PRAGMA autonomous_transaction;

  BEGIN
    /* Insert into contact_log table. */ 
    INSERT INTO contact_log
    (contact_log_id,
    trigger_name,
    trigger_timing,
    trigger_event,
    trigger_type,
    old_last_name,
    new_last_name
    )
    VALUES
    (contact_log_seq.nextval,
    pv_trigger_name,
    pv,trigger_timing,
    pv_trigger_event,
    pv_trigger_type,
    pv_old_last_name,
    pv_new_last_name);

    /* Commit the transaction. */
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
	  ROLLBACK;
  END contact_log_p;
/

/* Create or replace trigger. */
CREATE OR REPLACE
  TRIGGER contact_t
  BEFORE INSERT OR UPDATE ON contact
  FOR EACH ROW
  WHEN (REGEXP_LIKE(new.last_name,' '))
    DECLARE
    lv_trigger_name VARCHAR2(30) := 'CONTACT_INSERT_T';
    lv_trigger_event VARCHAR2(10);
    lv_trigger_type VARCHAR2(12) := 'FOR EACH ROW';
    lv_trigger_timing VARCHAR2(6) := 'BEFORE';
BEGIN
  IF INSERTING THEN
    /* Add the hyphen between the two part name. */
    :new.last_name := REPLACE(:new.last_name, ' ', '-');
     lv_trigger_event := 'INSERT'

        contact_log(
      pv_trigger_name      => lv_trigger_name
    , pv_trigger_event     => lv_trigger_event
    , pv_trigger_type      => lv_trigger_type
    , pv_trigger_timing    => lv_trigger_timing
    , pv_old_last_name => :old.last_name
    , pv_new_last_name => :new.last_name );

  ELSIF UPDATING THEN
      lv_trigger_event := 'UPDATE'
  	/* Call procedure to insert the log values. */
	
      contact_log(
      pv_trigger_name      => lv_trigger_name
    , pv_trigger_event     => lv_trigger_event
    , pv_trigger_type      => lv_trigger_type
    , pv_trigger_timing    => lv_trigger_timing
    , pv_old_last_name => :old.last_name
    , pv_new_last_name => :new.last_name );

    
	  
    /* Raise error to state policy allows no changes. */
    RAISE_APPLICATION_ERROR(-20001,'Whitespace replaced with hyphen.');
  END IF;	
END contact_t;
/

/* Insert into the contact table. */
INSERT
INTO   contact
( contact_id
, member_id
, contact_type
, last_name
, first_name
, middle_name
, created_by
, creation_date
, last_updated_by
, last_update_date )
VALUES
( contact_s1.nextval
,(SELECT   member_id
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
, 2
, TRUNC(SYSDATE)
, 2
, TRUNC(SYSDATE));

/* Verify that the multiword last name is hyphenated. */
SELECT last_name
FROM   contact
WHERE  last_name like 'Smith_Wyse';

/* Update contact table. */
UPDATE contact
SET    last_name = 'Smith Wyse'
WHERE  last_name = 'Smith-Wyse';

UPDATE contact
       *
ERROR at line 1:
ORA-20001: Whitespace replaced with hyphen.
ORA-06512: at "C##STUDENT.CONTACT_T", line 25
ORA-04088: error during execution of trigger 'C##STUDENT.CONTACT_T'

/* Verify two rows written to contact_log table. */
COL old_last_name FORMAT A12
COL new_last_name FORMAT A12
SELECT trigger_name
,      trigger_timing
,      old_last_name
,      new_last_name
FROM   contact_log

/* Query the last name entry of Smith-Wyse after trigger. */
SELECT c.last_name || ', ' || c.first_name AS full_name
FROM   contact c
WHERE  c.last_name LIKE 'Smith_Wyse';