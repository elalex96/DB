CREATE PROCEDURE [dbo].[SP_CO_ConsultaMesPresentacion]
AS
BEGIN
    SELECT DISTINCT CONVERT(VARCHAR(10), MesPresentacion, 105) AS MesPresentacion,
                    MONTH (MesPresentacion) AS 'Mes',
					Year (MesPresentacion) AS 'Year'
      FROM CO_Registro
     ORDER BY MesPresentacion ASC;
END;
