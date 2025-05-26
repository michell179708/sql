--lyrics record
CREATE TYPE lyric AS
( days  VARCHAR(8)
, gift  VARCHAR(24));

--Function twelve days 
CREATE FUNCTION twelve_days
  ( IN pv_days   VARCHAR(8)[]
  , IN pv_gifts  LYRIC[] ) RETURNS VARCHAR[] AS
$$  
DECLARE 
  /* Initialize the collection of lyrics:
   *   - An array of 114 elements of 36 character variable length strings.
   */
  lv_retval VARCHAR(36)[114];
  
BEGIN
  /*
   *  Read forward through the pv_days array (HINT: Use ARRAY_LENGTH() function.)
   */
  FOR i IN 1..ARRAY_LENGTH(pv_days,1) LOOP
    /*  Add the 'On the nth day of Christmas, my true love sent to me' to
     *  the lv_retval array as two separate lines. (HINT: Use ARRAY_APPEND() function
     *  and cast the result as the TEXT type).
    */
    lv_retval := ARRAY_APPEND(lv_retval, ('On the ' || pv_days[i]|| ' day of Christmas')::TEXT);
    lv_retval := ARRAY_APPEND(lv_retval, ('- my true love sent to me')::TEXT);
 
    /*
     *  Read backward through the the pv_gifts array (or lyrics) based on
     *  the ascending value of the pv_days array index. (HINT: Use the REVERSE
     *  keyword and couple the maximum index value of the pv_days array to the 
     *  current index value being read by the outer loop.)
     */
    FOR j IN REVERSE i..i LOOP
       /*
       *  Develop an if-statement that replaces the 'and a' value from the
       *  pv_gifts array's days member with a literal 'A' value for the first
       *  day of Christmas. (HINT: Use ARRAY_APPEND() function and cast the
       *  result as the TEXT type.)
       */
      IF i = 1 THEN
        lv_retval := ARRAY_APPEND(lv_retval, ('A'||' '|| pv_gifts[j].gift)::TEXT);
      ELSIF J <= i THEN
        lv_retval := ARRAY_APPEND(lv_retval,(pv_gifts[j].days ||' '|| pv_gifts[j].gift)::TEXT); 
      END IF;
    END LOOP;
 
    /* 
     *  Add a line break for each verse. (HINT: Use ARRAY_APPEND() function and cast the
     *  result as the TEXT type).
     */
    lv_retval :=ARRAY_APPEND(lv_retval,''::TEXT) ;
  END LOOP;
 
  /* Return the song's lyrics. */
  RETURN lv_retval;
END;
$$ LANGUAGE plpgsql;

SELECT UNNEST(twelve_days(ARRAY['first','second','third','fourth'
                          ,'fifth','sixth','seventh','eighth'
                          ,'nineth','tenth','eleventh','twelfth']
                         ,ARRAY[('and a','Partridge in a pear tree')::lyric
                          ,('Two','Turtle doves')::lyric
                          ,('Three','French hens')::lyric
                          ,('Four','Calling birds')::lyric
                          ,('Five','Golden rings')::lyric
                          ,('Six','Geese a laying')::lyric
                          ,('Seven','Swans a swimming')::lyric
                          ,('Eight','Maids a milking')::lyric
                          ,('Nine','Ladies dancing')::lyric
                          ,('Ten','Lords a leaping')::lyric
                          ,('Eleven','Pipers piping')::lyric
                          ,('Twelve','Drummers drumming')::lyric])) 
                          
                          AS "12-Days of Christmas";

DO
$$
DECLARE
  /* Declare an lv_days array and initialize it with values. */
 lv_days VARCHAR(8)[] := ARRAY['first', 'second','third','fourth','fith','sixth'
                                ,'seventh','eighth','ninth','tenth','eleventh','twelfth'];
							
  /* Declare an lv_gifts array and initialize it with values. */
  lv_gifts lyric[] := ARRAY[('and a','Partridge in a pear tree')::lyric
                            ,('Two','Turtle doves')::lyric
                            ,('Three','French hens')::lyric
                            ,('Four','Calling birds')::lyric
                            ,('Five','Golden rings')::lyric
                            ,('Six','Geese a laying')::lyric
                            ,('Seven','Swans a swimming')::lyric
                            ,('Eight','Maids a milking')::lyric
                            ,('Nine','Ladies dancing')::lyric
                            ,('Ten','Lords a leaping')::lyric
                            ,('Eleven','Pipers piping')::lyric
                            ,('Twelve','Drummers drumming')::lyric];

  /* Declare an lv_song array without initializing values. */
  lv_song VARCHAR(36)[];

BEGIN
  /* Call the twelve_days function and assign the results to a local song variable. */
  lv_song := twelve_days(lv_days, lv_gifts);
  
  /* Read the lines from the local song variable. */
  FOR i IN 1..ARRAY_LENGTH(lv_song,1) LOOP
    RAISE NOTICE '[%] %', i,lv_song[i];
  END LOOP;
END;
$$