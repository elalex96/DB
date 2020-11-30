-- =============================================
-- Author:		Manuel CD
-- Create date: 20-10-2017
-- Description:	Consulta lista de meses por contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaMesesPorContratoPemex] --10010
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @FechaEfectiva AS DATE;
         SET LANGUAGE spanish;

         /**/

         SELECT @FechaEfectiva = InicioVigencia
         FROM CO_Contrato
         WHERE IdContrato = @IdContrato;

         /**/

         SELECT CONCAT(RIGHT('00'+CAST(MONTH(IdFecha) AS VARCHAR(2)), 2), '/', YEAR(IdFecha)) AS MesAño, 
                CONCAT(RIGHT('00'+CAST(MONTH(IdFecha) AS VARCHAR(2)), 2), ' ', datename(month, IdFecha), ' ', YEAR(IdFecha)) AS Fecha, 
                CAST(C.IdFecha AS DATE) AS IdFecha
         FROM AP_Calendario C
         WHERE C.Dia = 1
               AND C.IdFecha BETWEEN DATEADD(month, -1, @FechaEfectiva) AND CURRENT_TIMESTAMP
         ORDER BY c.IdFecha DESC;
     END;