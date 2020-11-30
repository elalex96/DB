CREATE PROCEDURE [dbo].[SP_CO_ConsultaMesPresentacion]
AS
BEGIN
    SELECT DISTINCT MesPresentacion,
                    CONVERT(VARCHAR(10), MesPresentacion, 105) AS 'Mes'
      FROM CO_Registro
     ORDER BY MesPresentacion ASC;
END;
