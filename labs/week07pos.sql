/* Drop table unconditionally. */
DROP TABLE IF EXISTS avenger;

/* Create avenger table. */
CREATE TABLE avenger
( avenger_id      SERIAL
, first_name      VARCHAR(30)
, last_name       VARCHAR(30)
, character_name  VARCHAR(30)
, species         VARCHAR(30));

/* Insert 6-rows of data. */
INSERT INTO avenger
( first_name, last_name, character_name, species )
VALUES
 ('Anthony','Stark','Iron Man','Terran')
,('Thor','Odinson','God of Thunder','Asgardian')
,('Steven','Rogers','Captain America','Terran')
,('Bruce','Banner','Hulk','Terran')
,('Clinton','Barton','Hackeye','Terran')
,('Natasha','Romanoff','Black Widow','Terran');

/* Drop the funciton conditionally. */
DROP FUNCTION IF EXISTS getAvenger;

/* Create the function. */
CREATE FUNCTION getAvenger (IN species_in VARCHAR(2))
  RETURNS TABLE
    ( first_name      VARCHAR(30)
    , last_name       VARCHAR(30)
    , character_name  VARCHAR(30)) AS
$$
BEGIN
  RETURN QUERY
  SELECT a.first_name
  ,      a.last_name
  ,      a.character_name
  FROM   avenger a
  WHERE  a.species = species_in;
END;
$$ LANGUAGE plpgsql;

/* Select from the result of the function. */
SELECT * FROM getAvenger('Asgardian');

CREATE OR REPLACE
  VIEW avenger_asgardian AS
  SELECT * FROM getAvenger('Asgardian'); 
  
  SELECT * FROM avenger_asgardian;

/* Drop table unconditionally. */
DROP TABLE conquistador;

/* Create avenger table. */
CREATE TABLE conquistador
( conquistador_id   SERIAL
, conquistador      VARCHAR(30)
, actual_name       VARCHAR(30)
, nationality       VARCHAR(30)
, lang              VARCHAR(2));

/* Insert 9-rows of data. */
INSERT INTO conquistador
( conquistador
, actual_name
, nationality
, lang )
VALUES
 ('Juan de Fuca','Ioánnis Fokás','Greek','el')
,('Nicolás de Federmán','Nikolaus Federmann','German','de')
,('Sebastián Caboto','Sebastiano Caboto','Venetian','it')
,('Jorge de la Espira','Georg von Speyer','German','de')
,('Eusebio Francisco Kino','Eusebius Franz Kühn','Italian','it')
,('Wenceslao Linck','Wenceslaus Linck','Bohemian','cs')
,('Fernando Consag','Ferdinand Konšcak','Croatian','sr')
,('Américo Vespucio','Amerigo Vespucci','Italian','it')
,('Alejo García','Aleixo Garcia','Portuguese','pt');

/* Conditionally drop the type.*/
DROP TYPE IF EXISTS conquistador_struct;

-- Create a type to use as a row structure.
CREATE TYPE conquistador_struct AS (
    conquistador VARCHAR(30),
    actual_name VARCHAR(30),
    nationality VARCHAR(30)
);

-- Drop the function conditionally.
DROP FUNCTION IF EXISTS getConquistador(IN VARCHAR);

-- Create a table function that returns a set of a structure.
CREATE FUNCTION getConquistador (IN lang_in VARCHAR(2))
  RETURNS SETOF conquistador_struct AS
$$
BEGIN
  RETURN QUERY
  SELECT conquistador, actual_name, nationality
  FROM conquistador
  WHERE lang = lang_in;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM getConquistador('de');

CREATE OR REPLACE
  VIEW conquistador_de AS
  SELECT * FROM getConquistador('de'); 
  
SELECT * FROM conquistador_de;