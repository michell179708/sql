--days attribute ADT
CREATE OR REPLACE TYPE days AS TABLE OF VARCHAR2(8);
/

--song attribute ADT    
CREATE OR REPLACE TYPE song AS TABLE OF VARCHAR2(36);
/

--lyric  user define type
CREATE OR REPLACE TYPE lyric IS OBJECT
( 
  days VARCHAR2(8),
  gift VARCHAR2(24)
);
/

CREATE OR REPLACE TYPE lyrics IS TABLE OF lyric;
/

--function twelve days begin 
CREATE OR REPLACE
  FUNCTION twelve_days
  ( pv_days   DAYS
  , pv_gifts  LYRICS ) RETURN song IS
 
  /* Initialize the collection of lyrics. */
  lv_retval  SONG := song();
 
  /* Local procedure to add to the song. */
  PROCEDURE ADD
  ( pv_input  VARCHAR2 ) IS
  BEGIN
    lv_retval.EXTEND;
    lv_retval(lv_retval.COUNT) := pv_input;
  END ADD;
 
BEGIN
  /* Read forward through the days. */
  FOR i IN 1..pv_days.COUNT LOOP
    /* Call the ADD procedure to add the two lines that lead each verse. */
    ADD('On the ' || pv_days(i) || ' day of Christmas');
    ADD('my true love sent to me:');
 
    /* Read backward through the lyrics based on the ascending value of the day. */
    FOR j IN REVERSE 1..i LOOP
      /* Add the lyrics for the current day. */
      IF i = 1 THEN
        ADD('-'||'A'||' '|| pv_gifts(j).gift);
      ELSE
        ADD('-'||pv_gifts(j).days ||' '|| pv_gifts(j).gift);
      END IF;
    END LOOP;
 
    /* A line break by verse. */
    ADD(CHR(13));
  END LOOP;
 
  /* Return the song's lyrics. */
  RETURN lv_retval;
END;
/

SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  /* 
   *  Declare an lv_days table of an 8 character variable length string
   *  and initialize it with values.
   */
  lv_days days := days('first', 'second','third','fourth','fith','sixth','seventh','eighth','ninth','tenth','eleventh','twelfth');
							
  /*
   *  Declare an lv_gifts table of the user-defined LYRIC data type and
   *  initialize it with values.
   */
  lv_gifts lyrics := lyrics(lyric(days => 'and a', gift => 'Partridge in a pear tree')
                            ,lyric(days => 'two', gift => 'Turtle doves')
                            ,lyric(days => 'three', gift => 'French hens')
                            ,lyric(days => 'Four',  gift => 'Calling birds')
                            ,lyric(days => 'Five',  gift => 'Golden rings')
                            ,lyric(days => 'Six',   gift => 'Geese a laying')
                            ,lyric(days => 'Seven', gift => 'Swans a swimming')
                            ,lyric(days => 'Eight', gift => 'Maids a milking')
                            ,lyric(days => 'Nine',  gift => 'Ladies dancing'),
                            ,lyric(days => 'Ten',   gift => 'Lords a leaping'),
                            ,lyric(days => 'Eleven',gift => 'Pipers piping'),
                            ,lyric(days => 'Twelve',gift => 'Drummers drumming'));


  /* 
   *  Declare an lv_days table of an 36 character variable length string
   *  and initialize it with values.
   */
  lv_song song := song();

BEGIN
  /*  Call the twelve_days function and assign the results to the local
   *  lv_song variable.
   */
  lv_song := twelve_days(lv_days,lv_gifts);
  
  /*
   *  Read the lines from the local lv_song variable and print them by
   *  using a dbms_output.put_line function.
   */
  FOR i in 1..lv_song.LAST LOOP
    dbms_output.put_line(lv_song(i)); 
  END LOOP;  
END;
/