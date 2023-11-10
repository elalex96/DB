
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_CO_ConsultaMesesPorContrato'
)
    DROP PROCEDURE sp_CO_ConsultaMesesPorContrato
GO
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2017
-- Description:	Consulta lista de meses por contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaMesesPorContrato] 
@IdContrato INT = 0
AS
     BEGIN

         SET NOCOUNT ON;


         SET LANGUAGE spanish;
         DECLARE @FechaEfectiva AS DATE;


         SELECT @FechaEfectiva = InicioVigencia
         FROM CO_Contrato (NOLOCK)
         WHERE IdContrato = @IdContrato;


         IF @IdContrato = 10007
             BEGIN
                 SELECT CAST(AP_Calendario.IdFecha AS DATE) AS IdFecha, 
                        CONCAT( datename(month, IdFecha), ' ', YEAR(IdFecha)) AS Fecha
                 FROM AP_Calendario (NOLOCK)
                 WHERE AP_Calendario.Dia = 1
                       AND AP_Calendario.IdFecha BETWEEN DATEADD(month, -1, @FechaEfectiva) AND CURRENT_TIMESTAMP--DATEFROMPARTS(2019, 12, 31)
                 ORDER BY AP_Calendario.IdFecha DESC;
             END;

                 /**/

             ELSE
             BEGIN
                 SELECT CAST(AP_Calendario.IdFecha AS DATE) AS IdFecha, 
                        CONCAT( datename(month, IdFecha), ' ', YEAR(IdFecha)) AS Fecha
                 FROM AP_Calendario (NOLOCK)
                 WHERE AP_Calendario.Dia = 1
                       AND AP_Calendario.IdFecha BETWEEN DATEADD(month, -1, @FechaEfectiva) AND CURRENT_TIMESTAMP
                 ORDER BY AP_Calendario.IdFecha DESC;
             END;
                 -- Insert statements for procedure here

     END;

