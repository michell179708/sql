/* Conditionally drop cartoon_user table. */
DROP TABLE IF EXISTS cartoon_user CASCADE;

/* Create cartoon_user table. */
CREATE TABLE cartoon_user
( cartoon_user_id    SERIAL
, cartoon_user_name  VARCHAR(30)  NOT NULL
, PRIMARY KEY (cartoon_user_id)
);

/* Seed the cartoon_user table. */
INSERT INTO cartoon_user
( cartoon_user_name )
VALUES
 ('Bugs Bunny')
,('Wylie Coyote')
,('Elmer Fudd');

/* Conditionally drop grandma table. */
DROP TABLE IF EXISTS grandma CASCADE;
 
/* Create the table. */
CREATE TABLE GRANDMA
( grandma_id     SERIAL
, grandma_house  VARCHAR(30)  NOT NULL
, created_by     INTEGER      NOT NULL
, PRIMARY KEY (grandma_id)
, CONSTRAINT grandma_fk       FOREIGN KEY (created_by)
  REFERENCES cartoon_user (cartoon_user_id)
);
 
/* Conditionally drop a table. */
DROP TABLE IF EXISTS tweetie_bird CASCADE;
 
/* Create the table with primary and foreign key out-of-line constraints. */
SELECT 'CREATE TABLE tweetie_bird' AS command;
CREATE TABLE TWEETIE_BIRD
( tweetie_bird_id     SERIAL
, tweetie_bird_house  VARCHAR(30)   NOT NULL
, grandma_id          INTEGER       NOT NULL
, created_by          INTEGER       NOT NULL
, PRIMARY KEY (tweetie_bird_id)
, CONSTRAINT tweetie_bird_fk1        FOREIGN KEY (grandma_id)
  REFERENCES grandma (grandma_id)
, CONSTRAINT tweetie_bird_fk2        FOREIGN KEY (created_by)
  REFERENCES cartoon_user (cartoon_user_id)
);

/* Create function get_cartoon_user_id function. */
CREATE OR REPLACE
  FUNCTION get_cartoon_user_id
  ( IN pv_cartoon_user_name  VARCHAR ) RETURNS INTEGER AS
$$
  /* Required for PL/pgSQL programs. */
  DECLARE
 
 
    /* Local return variable. */
    lv_retval  INTEGER := 0;  -- Default value is 0.
 
    /* Use a cursor, which will not raise an exception at runtime. */
    find_cartoon_user_id CURSOR 
    ( cv_cartoon_user_name  VARCHAR ) FOR
      SELECT cartoon_user_id
      FROM   cartoon_user
      WHERE  cartoon_user_name = cv_cartoon_user_name;
 
  BEGIN  
 
    /* Assign a value when a row exists. */
    FOR i IN find_cartoon_user_id(pv_cartoon_user_name) LOOP
      lv_retval := i.cartoon_user_id;
    END LOOP;
 
    /* Return 0 when no row found and the ID # when row found. */
    RETURN lv_retval;
  END;
$$ LANGUAGE plpgsql;

/* Create function get_grandma_id function. */
CREATE OR REPLACE
  FUNCTION get_grandma_id
  ( IN pv_grandma_house  VARCHAR ) RETURNS INTEGER AS
$$
  /* Required for PL/pgSQL programs. */
  DECLARE
 
    /* Local return variable. */
    lv_retval  INTEGER := 0;  -- Default value is 0.
 
    /* Use a cursor, which will not raise an exception at runtime. */
    find_grandma_id CURSOR 
    ( cv_grandma_house  VARCHAR ) FOR
      SELECT grandma_id
      FROM   grandma
      WHERE  grandma_house = cv_grandma_house;
 
  BEGIN  
 
    /* Assign a value when a row exists. */
    FOR i IN find_grandma_id(pv_grandma_house) LOOP
      lv_retval := i.grandma_id;
    END LOOP;
 
    /* Return 0 when no row found and the ID # when row found. */
    RETURN lv_retval;
  END;
$$ LANGUAGE plpgsql;

/* Create or replace procedure warner_brother. */
CREATE OR REPLACE
  PROCEDURE warner_brother
  ( IN pv_grandma_house       VARCHAR
  , IN pv_tweetie_bird_house  VARCHAR
  , IN pv_cartoon_user_id     INTEGER ) AS
$$ 
  /* Required for PL/pgSQL programs. */
  DECLARE
 
  /* Declare a local variable for an existing grandma_id. */
  lv_grandma_id   INTEGER;
 
BEGIN  
  /* Check for existing grandma row. */
  lv_grandma_id := get_grandma_id(pv_grandma_house);
  IF lv_grandma_id = 0 THEN 
    /* Insert grandma. */
    INSERT INTO grandma
    ( grandma_house
    , created_by )	
    VALUES
    ( pv_grandma_house
    , pv_cartoon_user_id )
    RETURNING grandma_id INTO lv_grandma_id;
  END IF;
 
  /* Insert tweetie bird. */
  INSERT INTO tweetie_bird
  ( tweetie_bird_house 
  , grandma_id
  , created_by )
  VALUES
  ( pv_tweetie_bird_house
  , lv_grandma_id
  , pv_cartoon_user_id );
 
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE NOTICE '[%] [%]', SQLERRM, SQLSTATE;  
END;
$$ LANGUAGE plpgsql;

/* Create or replace procedure warner_brother. */
CREATE OR REPLACE
  PROCEDURE warner_brother
  ( pv_grandma_house       VARCHAR
  , pv_tweetie_bird_house  VARCHAR
  , pv_cartoon_user_name   VARCHAR ) AS
$$ 
  /* Required for PL/pgSQL programs. */
  DECLARE
 
  /* Declare a local variable for an existing grandma_id. */
  lv_grandma_id       INTEGER;
  lv_cartoon_user_id  INTEGER;
 
BEGIN  
  /* Check for existing grandma row. */
  lv_cartoon_user_id := get_cartoon_user_id(pv_cartoon_user_name);

  /*  */
  CALL warner_brother( pv_grandma_house
                     , pv_tweetie_bird_house
					 , lv_cartoon_user_id );
 
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE NOTICE '[%] [%]', SQLERRM, SQLSTATE;  
END;
$$ LANGUAGE plpgsql;

/* Test the warner_brother procedure. */
DO
$$
BEGIN
  /* Insert the yellow house. */
  CALL warner_brother( 'Yellow House', 'Cage', 3);
  CALL warner_brother( 'Yellow House', 'Tree House', 3);
 
  /* Insert the red house. */
  CALL warner_brother( 'Red House', 'Cage', 'Bugs Bunny');
  CALL warner_brother( 'Red House', 'Tree House', 'Bugs Bunny');
END;
$$ LANGUAGE plpgsql;

SELECT g.grandma_id
,      g.grandma_house
,      g.created_by
,      tb.tweetie_bird_id
,      tb.tweetie_bird_house
,      tb.created_by
FROM   grandma g INNER JOIN tweetie_bird tb
ON     g.grandma_id = tb.grandma_id;

DROP PROCEDURE IF EXISTS contact_insert
( IN pv_member_type         VARCHAR(30)
, IN pv_account_number      VARCHAR(10)
, IN pv_credit_card_number  VARCHAR(19)
, IN pv_credit_card_type    VARCHAR(30)
, IN pv_first_name          VARCHAR(20)
, IN pv_middle_name         VARCHAR(20)
, IN pv_last_name           VARCHAR(20)
, IN pv_contact_type        VARCHAR(30)
, IN pv_address_type        VARCHAR(30)
, IN pv_city                VARCHAR(30)
, IN pv_state_province      VARCHAR(30)
, IN pv_postal_code         VARCHAR(20)
, IN pv_street_address      VARCHAR(30)
, IN pv_telephone_type      VARCHAR(30)
, IN pv_country_code        VARCHAR(3)
, IN pv_area_code           VARCHAR(6)
, IN pv_telephone_number    VARCHAR(10)
, IN pv_created_by          INTEGER
, IN pv_last_updated_by     INTEGER);

DROP PROCEDURE IF EXISTS contact_insert
( IN pv_member_type         VARCHAR(30)
, IN pv_account_number      VARCHAR(10)
, IN pv_credit_card_number  VARCHAR(19)
, IN pv_credit_card_type    VARCHAR(30)
, IN pv_first_name          VARCHAR(20)
, IN pv_middle_name         VARCHAR(20)
, IN pv_last_name           VARCHAR(20)
, IN pv_contact_type        VARCHAR(30)
, IN pv_address_type        VARCHAR(30)
, IN pv_city                VARCHAR(30)
, IN pv_state_province      VARCHAR(30)
, IN pv_postal_code         VARCHAR(20)
, IN pv_street_address      VARCHAR(30)
, IN pv_telephone_type      VARCHAR(30)
, IN pv_country_code        VARCHAR(3)
, IN pv_area_code           VARCHAR(6)
, IN pv_telephone_number    VARCHAR(10)
, IN pv_user_name           VARCHAR(20));

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

SELECT  retval AS "Return Member Value"
FROM   (SELECT get_member_id(m.account_number) AS retval
        FROM   member m
        ORDER BY m.account_number LIMIT 1) x
ORDER BY 1;

/* Create or replace get_member_id function. */
CREATE OR REPLACE
  FUNCTION get_lookup_id
  ( IN pv_table_name   VARCHAR
  , IN pv_column_name  VARCHAR
  , IN pv_lookup_type  VARCHAR ) RETURNS INTEGER AS
$$
  /* Required for PL/pgSQL programs. */
  DECLARE
    /* Local return variable. */
    lv_retval  INTEGER := 0;  -- Default value is 0.
 
    /* Use a cursor, which will not raise an exception at runtime. */
    find_lookup_id CURSOR 
    ( cv_table_name   VARCHAR
    , cv_column_name  VARCHAR
    , cv_lookup_type  VARCHAR ) FOR
      SELECT cl.common_lookup_id
	  FROM   common_lookup cl
	  WHERE  cl.common_lookup_table = cv_table_name
	  AND    cl.common_lookup_column = cv_column_name
	  AND    cl.common_lookup_type = cv_lookup_type;
  BEGIN  

  
    /* Assign a value when a row exists. */
    FOR i IN find_lookup_id( pv_table_name
                           , pv_column_name
                           , pv_lookup_type ) LOOP
      lv_retval := i.common_lookup_id;
    END LOOP;
    INSERT INTO debug values (concat('[',lv_retval,']',pv_table_name, ',', pv_column_name, ',', pv_lookup_type));
	
    /* Return 0 when no row found and the ID # when row found. */
    RETURN lv_retval;
  END;
$$ LANGUAGE plpgsql;

 SELECT    DISTINCT
          CASE
            WHEN NOT retval = 0 THEN retval
          END AS "Return Lookup Value"
FROM     (SELECT get_lookup_id('MEMBER', 'MEMBER_TYPE', cl.common_lookup_type) AS retval
          FROM   common_lookup cl) x
WHERE NOT retval = 0
ORDER BY  1;

CREATE OR REPLACE
  FUNCTION get_system_user_id
  ( IN pv_user_name  VARCHAR ) RETURNS INTEGER AS
$$
  /* Required for PL/pgSQL programs. */
  DECLARE
  
    /* Local return variable. */
    lv_retval  INTEGER := 0;  -- Default value is 0.
 
    /* Use a cursor, which will not raise an exception at runtime. */
    find_system_user_id CURSOR 
    ( cv_user_name  VARCHAR ) FOR
      SELECT su.system_user_id
	  FROM   system_user su
	  WHERE  su.system_user_name = cv_user_name;
 
  BEGIN  
 
    /* Assign a value when a row exists. */
    FOR i IN find_system_user_id(pv_user_name) LOOP
      lv_retval := i.system_user_id;
    END LOOP;
 
    /* Return 0 when no row found and the ID # when row found. */
    RETURN lv_retval;
  END;
$$ LANGUAGE plpgsql;

/* Test the get_system_user_id function. */
SELECT  retval AS "Return System Value"
FROM   (SELECT get_system_user_id(su.system_user_name) AS retval
        FROM   system_user su
        WHERE  system_user_name LIKE 'DBA%'	LIMIT 5) x
ORDER BY 1;

-- Transaction Management Solution modified from Lab 9.
SELECT 'Create contact_insert procedure' AS "Statement";
CREATE OR REPLACE PROCEDURE contact_insert
( IN pv_member_type         VARCHAR(30)
, IN pv_account_number      VARCHAR(10)
, IN pv_credit_card_number  VARCHAR(19)
, IN pv_credit_card_type    VARCHAR(30)
, IN pv_first_name          VARCHAR(20)
, IN pv_middle_name         VARCHAR(20)
, IN pv_last_name           VARCHAR(20)
, IN pv_contact_type        VARCHAR(30)
, IN pv_address_type        VARCHAR(30)
, IN pv_city                VARCHAR(30)
, IN pv_state_province      VARCHAR(30)
, IN pv_postal_code         VARCHAR(20)
, IN pv_street_address      VARCHAR(30)
, IN pv_telephone_type      VARCHAR(30)
, IN pv_country_code        VARCHAR(3)
, IN pv_area_code           VARCHAR(6)
, IN pv_telephone_number    VARCHAR(10)
, IN pv_system_user_id      INTEGER) AS
$$
DECLARE
  /* Declare type variables. */
  lv_member_type       INTEGER;
  lv_credit_card_type  INTEGER;
  lv_contact_type      INTEGER;
  lv_address_type      INTEGER;
  lv_telephone_type    INTEGER;
  
  /* Local surrogate key variables. */
  lv_member_id          INTEGER;
  lv_contact_id         INTEGER;
  lv_address_id         INTEGER;
  lv_street_address_id  INTEGER;
  
  
BEGIN

  /* Assing a null value to an empty string. */ 
  IF pv_middle_name IS NULL THEN
    lv_middle_name = '';
  END IF;
  
  /*
   *  Replace the character type values with their appropriate
   *  common_lookup_id values by calling the get_lookup_id
   *  function.
   */
  lv_member_type := get_lookup_id('MEMBER','MEMBER_TYPE',lv_member_type);
  lv_credit_card_type := get_lookup_id('MEMBER','CREDICT_CARD_TYPE',lv_credict_card_type);
  lv_contact_type := get_lookup_id('CONTACT','CONTACT_TYPE',lv_contact_type);
  lv_address_type := get_lookup_id('ADDRESS','ADDRESS_TYPE',lv_address_type);
  lv_telephone_type := get_lookup_id('TELEPHONE','MEMBER_TYPE',lv_telephone_type);

  /*
   *  Check for existing member row. Assign value when one exists,
   *  and assign zero when no member row is found.
   */
  lv_member_id INTEGER := 0;

  SELECT member_id INTO lv_member_id
  FROM member
  WHERE account_number = pv_account_number
  AND credit_card_number = pv_credit_card_number;

  /*
   *  Enclose the insert into member in an if-statement.
   */
   IF lv_member_id = 0 THEN
    /*
     *  Insert into the member table when no row is found.
     *
     *  Replace the two subqueries by calling the get_lookup_id
     *  function for either the pv_member_type or credit_card_type
     *  value and assign it to a local variable.
     */
    INSERT INTO member
    ( member_type
    , account_number
    , credit_card_number
    , credit_card_type
    , created_by
    , last_updated_by )
    VALUES
    ( lv_member_type
    , pv_account_number
    , pv_credit_card_number
    , lv_credit_card_type
    , pv_system_user_id
    , pv_system_user_id )
    RETURNING member_id INTO lv_member_id;
  END IF;

  /*
   *  Insert into the member table when no row is found.
   *
   *  Replace the subquery by calling the get_lookup_id
   *  function for the pv_contact_type value and
   *  assign it to a local variable.
   */
  INSERT INTO contact
  ( member_id
  , contact_type
  , first_name
  , middle_name
  , last_name
  , created_by
  , last_updated_by )
  VALUES
  ( lv_member_id
  , lv_contact_type
  , pv_first_name
  , pv_middle_name
  , pv_last_name
  , pv_system_user_id
  , pv_system_user_id )
  RETURNING contact_id INTO lv_contact_id;

  /*
   *  Insert into the member table when no row is found.
   *
   *  Replace the subquery by calling the get_lookup_id
   *  function for the pv_address_type value and
   *  assign it to a local variable.
   */
  INSERT INTO address
  ( contact_id
  , address_type
  , city
  , state_province
  , postal_code
  , created_by
  , last_updated_by )
  VALUES
  ( lv_contact_id
  , lv_address_type
  , pv_city
  , pv_state_province
  , pv_postal_code
  , pv_system_user_id
  , pv_system_user_id )
  RETURNING address_id INTO lv_address_id;

  /*
   *  Insert into the member table when no row is found.
   */
  INSERT INTO street_address
  ( address_id
  , street_address
  , created_by
  , last_updated_by )
  VALUES
  ( lv_address_id
  , pv_street_address
  , pv_system_user_id
  , pv_system_user_id )
  RETURNING street_address_id INTO lv_street_address_id;

  /*
   *  Insert into the member table when no row is found.  
   *
   *  Replace the subquery by calling the get_lookup_id
   *  function for the pv_telephone_type value and
   *  assign it to a local variable.
   */
  INSERT INTO telephone
  ( contact_id
  , address_id
  , telephone_type
  , country_code
  , area_code
  , telephone_number
  , created_by
  , last_updated_by )
  VALUES
  ( lv_contact_id
  , lv_address_id
  , lv_telephone_type
  , pv_country_code
  , pv_area_code
  , pv_telephone_number
  , pv_system_user_id
  , pv_system_user_id );

EXCEPTION
 WHEN OTHERS THEN
    RAISE NOTICE 'Trapped Error: %', SQLERRM;
    
END
$$ LANGUAGE plpgsql;

-- Transaction Management Example.
CREATE OR REPLACE PROCEDURE contact_insert
( IN pv_member_type         VARCHAR(30)
, IN pv_account_number      VARCHAR(10)
, IN pv_credit_card_number  VARCHAR(19)
, IN pv_credit_card_type    VARCHAR(30)
, IN pv_first_name          VARCHAR(20)
, IN pv_middle_name         VARCHAR(20)
, IN pv_last_name           VARCHAR(20)
, IN pv_contact_type        VARCHAR(30)
, IN pv_address_type        VARCHAR(30)
, IN pv_city                VARCHAR(30)
, IN pv_state_province      VARCHAR(30)
, IN pv_postal_code         VARCHAR(20)
, IN pv_street_address      VARCHAR(30)
, IN pv_telephone_type      VARCHAR(30)
, IN pv_country_code        VARCHAR(3)
, IN pv_area_code           VARCHAR(6)
, IN pv_telephone_number    VARCHAR(10)
, IN pv_system_user_id       VARCHAR(20)) AS
$$
DECLARE
  /* Declare a who-audit variables. */

 
  /* Declare error handling variables. */
  err_num  TEXT;
  err_msg  INTEGER;
BEGIN

   /*
   *  Replace the character type values with their appropriate
   *  common_lookup_id values by calling the get_lookup_id
   *  function.
   */

  /*
   *  Replace the user_name parameter with system_user_id parameter.
   */

  /*
   *  Call contact_insert procedure.
   */
  contact_insert(pv_member_type, pv_account_number, pv_credit_card_number, pv_credit_card_type,
                pv_first_name, pv_middle_name, pv_last_name, pv_contact_type, pv_address_type,
                pv_city, pv_state_province, pv_postal_code, pv_street_address, pv_telephone_type,
                pv_country_code, pv_area_code, pv_telephone_number, pv_system_user_id);


EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLSTATE;
    err_msg := SUBSTR(SQLERRM,1,100);
    RAISE NOTICE 'Trapped Error: %', err_msg;
END
$$ LANGUAGE plpgsql;

UPDATE system_user
SET    system_user_name = system_user_name || ' ' || system_user_id
WHERE  system_user_name = 'DBA';

/* Deleting Lensherr, McCoy, and Xavier data sets. */
SELECT 'Deleting prior data sets.' AS "Statement";
DO
$$
BEGIN
  /* Cleanup telephone table. */
  DELETE
  FROM   telephone t
  WHERE  t.contact_id IN
   (SELECT contact_id
    FROM   contact
    WHERE  last_name IN ('Lensherr','McCoy','Xavier'));
	
  /* Cleanup street_address table. */
  DELETE 
  FROM   street_address sa
  WHERE  sa.address_id IN
          (SELECT a.address_id
		   FROM   address a INNER JOIN contact c
		   ON     a.contact_id = c.contact_id
		   WHERE  c.last_name IN ('Lensherr','McCoy','Xavier'));
		   
  /* Cleanup address table. */
  DELETE
  FROM   address a
  WHERE  a.contact_id IN
   (SELECT contact_id
    FROM   contact
    WHERE  last_name IN ('Lensherr','McCoy','Xavier'));
	
  /* Cleanup contact table. */
  DELETE
  FROM    contact c
  WHERE   c.last_name IN ('Lensherr','McCoy','Xavier');

  /* Cleanup member table. */
  DELETE
  FROM   member m
  WHERE  m.account_number = 'US00010';
END;
$$;

DO
$$
BEGIN
  /* Call procedure. */
  CALL contact_insert(
         'INDIVIDUAL'
        ,'US00010'
        ,'7777-6666-5555-4444'
        ,'DISCOVER_CARD'
        ,'Erik'
        ,''
        ,'Lensherr'
        ,'CUSTOMER'
        ,'HOME'
        ,'Bayville'
        ,'New York'
        ,'10032'
        ,'1407 Graymalkin Lane'
        ,'HOME'
        ,'001'
        ,'207'
        ,'111-1234'
        , 1002 );
END;
$$;

DO
$$
DECLARE
  /* Declare the variables. */
  pv_member_type        VARCHAR(30) := 'INDIVIDUAL';
  pv_account_number     VARCHAR(10) := 'US00010';
  pv_credit_card_number VARCHAR(19) := '7777-6666-5555-4444';
  pv_credit_card_type   VARCHAR(30) := 'DISCOVER_CARD';
  pv_first_name         VARCHAR(20) := 'Charles';
  pv_middle_name        VARCHAR(20) := 'Francis';
  pv_last_name          VARCHAR(20) := 'Xavier';
  pv_contact_type       VARCHAR(30) := 'CUSTOMER';
  pv_address_type       VARCHAR(30) := 'HOME';
  pv_city               VARCHAR(30) := 'Bayville';
  pv_state_province     VARCHAR(30) := 'New York';
  pv_postal_code        VARCHAR(30) := '10032';
  pv_street_address     VARCHAR(30) := '1407 Graymalkin Lane';
  pv_telephone_type     VARCHAR(30) := 'HOME';
  pv_country_code       VARCHAR(3) := '001';
  pv_area_code          VARCHAR(6) := '207';
  pv_telephone_number   VARCHAR(10) := '111-1234';
  pv_user_name          VARCHAR(20) := 'DBA3';   
BEGIN  
  /* Call procedure. */
  CALL contact_insert(
          pv_member_type
        , pv_account_number
        , pv_credit_card_number
        , pv_credit_card_type
        , pv_first_name
        , pv_middle_name
        , pv_last_name
        , pv_contact_type
        , pv_address_type
        , pv_city
        , pv_state_province
        , pv_postal_code
        , pv_street_address
        , pv_telephone_type
        , pv_country_code
        , pv_area_code
        , pv_telephone_number
        , pv_user_name );
END;
$$;

DO
$$
DECLARE
  /* Declare the variables. */
  pv_member_type        VARCHAR(30) := 'INDIVIDUAL';
  pv_account_number     VARCHAR(10) := 'US00010';
  pv_credit_card_number VARCHAR(19) := '7777-6666-5555-4444';
  pv_credit_card_type   VARCHAR(30) := 'DISCOVER_CARD';
  pv_first_name         VARCHAR(20) := 'Henry';
  pv_middle_name        VARCHAR(20) := 'Philip';
  pv_last_name          VARCHAR(20) := 'McCoy';
  pv_contact_type       VARCHAR(30) := 'CUSTOMER';
  pv_address_type       VARCHAR(30) := 'HOME';
  pv_city               VARCHAR(30) := 'Bayville';
  pv_state_province     VARCHAR(30) := 'New York';
  pv_postal_code        VARCHAR(30) := '10032';
  pv_street_address     VARCHAR(30) := '1407 Graymalkin Lane';
  pv_telephone_type     VARCHAR(30) := 'HOME';
  pv_country_code       VARCHAR(3) := '001';
  pv_area_code          VARCHAR(6) := '207';
  pv_telephone_number   VARCHAR(10) := '111-1234';
  pv_user_name          VARCHAR(20) := 'DBA3';   
BEGIN
  /* Call procedure. */
  CALL contact_insert(
          pv_member_type
        , pv_account_number
        , pv_credit_card_number
        , pv_credit_card_type
        , pv_first_name
        , pv_middle_name
        , pv_last_name
        , pv_contact_type
        , pv_address_type
        , pv_city
        , pv_state_province
        , pv_postal_code
        , pv_street_address
        , pv_telephone_type
        , pv_country_code
        , pv_area_code
        , pv_telephone_number
        , pv_user_name );
END;
$$;

SELECT   m.account_number AS acct_no
,        CONCAT(c.last_name, ', ', c.first_name, ' ', c.middle_name) AS full_name
,        CONCAT(sa.street_address, ', ', a.city, ', ', a.state_province, ' ', a.postal_code) AS address
,       'Y' AS telephone
FROM     member m INNER JOIN contact c
ON       m.member_id = c.member_id INNER JOIN address a
ON       c.contact_id = a.contact_id INNER JOIN street_address sa
ON       a.address_id = sa.address_id INNER JOIN telephone t
ON       c.contact_id = t.contact_id
AND      a.address_id = t.address_id
WHERE    c.last_name IN ('Lensherr','Xavier','McCoy');
