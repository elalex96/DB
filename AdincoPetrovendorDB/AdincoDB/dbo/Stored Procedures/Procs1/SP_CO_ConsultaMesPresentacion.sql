CREATE PROCEDURE [dbo].[SP_CO_ConsultaMesPresentacion]
AS
BEGIN
    SELECT DISTINCT CONVERT(VARCHAR(10), MesPresentacion, 105) AS MesPresentacion,
                    MONTH (MesPresentacion) AS 'Mes',
					YEAR (MesPresentacion) AS 'Year'
      FROM CO_Registro
	  WHERE MesPresentacion IS NOT NULL
     ORDER BY Year (MesPresentacion) DESC, MONTH (MesPresentacion) DESC;
END;
