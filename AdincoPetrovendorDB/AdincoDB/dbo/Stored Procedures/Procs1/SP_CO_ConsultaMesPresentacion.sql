CREATE PROCEDURE [dbo].[SP_CO_ConsultaMesPresentacion] 
AS
BEGIN
	SET LANGUAGE SPANISH
    SELECT CONVERT(VARCHAR(10), MesPresentacion, 105) AS MesPresentacion,
                    DATENAME(mm, MONTH (MesPresentacion)) AS 'Mes',
					YEAR (MesPresentacion) AS 'Year'
      FROM CO_Registro
	  WHERE MesPresentacion IS NOT NULL
	  GROUP BY CONVERT(VARCHAR(10), MesPresentacion, 105) ,
                    DATENAME(mm, MONTH (MesPresentacion)),
					YEAR (MesPresentacion)
     ORDER BY 
                    DATENAME(mm, MONTH (MesPresentacion)) DESC,
					YEAR (MesPresentacion) DESC,
					CONVERT(VARCHAR(10), MesPresentacion, 105) DESC 
END;

