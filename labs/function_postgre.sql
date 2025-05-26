CREATE OR REPLACE
  FUNCTION npv
  ( future_value  decimal
  , periods       integer
  , interest      decimal )
  RETURNS decimal AS
  $$
  DECLARE
    /* Declare a result variable. */
    calculated_npv decimal := null;
    result decimal := null;
  BEGIN
    /* Calculate the result and round it to the nearest penny and assign it to a local variable. */
    calculated_npv := future_value * POWER((1+interest),periods);
    result := ROUND(calculated_npv,2);
	
    /* Return the calculated result. */
    RETURN result;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

/*ANONYMOUS BLOCK THAT WITH HOLD THE RESULT OF THE FUCTION NPV*/

DO
$$
DECLARE
  /* Declare inputs by data type. */
  future_value decimal;
  periods integer;
  interest decimal;

  /* Result variable. */
  npv_result decimal := null;
BEGIN
  /* Call function and assign value. */
  SELECT npv(10.000,2,0.03) INTO npv_result ;
  
  /* Display value. */
   RAISE NOTICE '%',CONCAT('The result [',npv_result,'].');
END;
$$;