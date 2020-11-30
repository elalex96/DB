-- =============================================
-- Author:		Manuel CD
-- Create date: 20-10-2017
-- Description:	Consulta lista de meses por contrato
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ConsultaMesesPorContrato] --10010,1
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdUsuario  INT
AS
     BEGIN
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @FechaEfectiva AS DATE;
         SET LANGUAGE spanish;
         SELECT @FechaEfectiva = InicioVigencia
         FROM CO_Contrato
         WHERE IdContrato = @IdContrato;
         SELECT CONVERT(VARCHAR(11),C.IdFecha,103) AS IdFecha,
                CONCAT(RIGHT('00'+CAST(MONTH(IdFecha) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, IdFecha), ' ', YEAR(IdFecha)) AS Fecha
         FROM AP_Calendario C
         WHERE C.Dia = 1
               AND C.IdFecha BETWEEN DATEADD(MONTH, -1, @FechaEfectiva) AND CURRENT_TIMESTAMP
         ORDER BY c.IdFecha DESC;

	    /*
DECLARE @Fecha15 NVARCHAR(15)
SELECT @Fecha15 = CONCAT(YEAR (GETDATE()),'-', MONTH(GETDATE()),'-15')
IF(CONVERT(VARCHAR(10),GETDATE(),120) < @Fecha15)
SELECT 'SI' AS MSJ, CONVERT(VARCHAR(10),GETDATE(),120) AS FechaActual, @Fecha15 AS Quincena
ELSE SELECT 'NO' AS MSJ
	    */
     END;