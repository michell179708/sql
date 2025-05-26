CREATE OR REPLACE
FUNCTION npv
( future_value  NUMBER 
, periods       INTEGER
, interest      NUMBER ) -- parameters from the function.
RETURN NUMBER DETERMINISTIC IS
  calculated_npv NUMBER := NULL;
  result NUMBER := NULL;
BEGIN
  calculated_npv := future_value * POWER((1 + interest), periods);
  result := ROUND(calculated_npv, 2);
  RETURN result;
END npv;
/

SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
  future_value NUMBER := 10.000;
  periods INTEGER := 2;
  interest NUMBER := 0.03;
BEGIN
  dbms_output.put_line('The result [' || TO_CHAR(npv(future_value, periods, interest)) || '].');
END;
/

