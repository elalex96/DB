-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-09-24
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_SE_PeriodosICN]
-- [SP_SE_PeriodosICN] 3,3
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT CASE
                    WHEN MONTH(IdFecha) >= 1
                         AND MONTH(IdFecha) <= 6
                    THEN CAST(CONCAT(1, '-', Anio) AS NVARCHAR(10))
                    WHEN MONTH(IdFecha) >= 7
                         AND MONTH(IdFecha) <= 12
                    THEN CAST(CONCAT(2, '-', Anio) AS NVARCHAR(10))
                    ELSE ''
                END AS Periodo, 
                Anio,
                CASE
                    WHEN MONTH(IdFecha) >= 1
                         AND MONTH(IdFecha) <= 6
                    THEN 'Enero - Junio '+CAST(Anio AS NVARCHAR(10))
                    WHEN MONTH(IdFecha) >= 7
                         AND MONTH(IdFecha) <= 12
                    THEN 'Julio - Diciembre '+CAST(Anio AS NVARCHAR(10))
                    ELSE ''
                END AS Semestre
         --SELECT GETDATE(),IdFecha
         FROM dbo.AP_Calendario
         WHERE Anio <= YEAR(GETDATE())
               AND Anio >= 2017
         GROUP BY CASE
                      WHEN MONTH(IdFecha) >= 1
                           AND MONTH(IdFecha) <= 6
                      THEN CAST(CONCAT(1, '-', Anio) AS NVARCHAR(10))
                      WHEN MONTH(IdFecha) >= 7
                           AND MONTH(IdFecha) <= 12
                      THEN CAST(CONCAT(2, '-', Anio) AS NVARCHAR(10))
                      ELSE ''
                  END, 
                  Anio,
                  CASE
                      WHEN MONTH(IdFecha) >= 1
                           AND MONTH(IdFecha) <= 6
                      THEN 'Enero - Junio '+CAST(Anio AS NVARCHAR(10))
                      WHEN MONTH(IdFecha) >= 7
                           AND MONTH(IdFecha) <= 12
                      THEN 'Julio - Diciembre '+CAST(Anio AS NVARCHAR(10))
                      ELSE ''
                  END
         ORDER BY Anio DESC;
     END;