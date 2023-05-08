
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2017
-- Description:	Consulta lista de meses por contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaMesesPorContrato] 
-- Add the parameters for the stored procedure here
-- [sp_CO_ConsultaMesesPorContrato] 10007
@IdContrato INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         /**/

         SET LANGUAGE spanish;
         DECLARE @FechaEfectiva AS DATE;

         /**/

         SELECT @FechaEfectiva = InicioVigencia
         FROM CO_Contrato
         WHERE IdContrato = @IdContrato;

         /**/

         IF @IdContrato = 10007
             BEGIN
                 SELECT CAST(C.IdFecha AS DATE) AS IdFecha, 
                        CONCAT( datename(month, IdFecha), ' ', YEAR(IdFecha)) AS Fecha
                 FROM AP_Calendario C
                 WHERE C.Dia = 1
                       AND C.IdFecha BETWEEN DATEADD(month, -1, @FechaEfectiva) AND CURRENT_TIMESTAMP--DATEFROMPARTS(2019, 12, 31)
                 ORDER BY c.IdFecha DESC;
             END;

                 /**/

             ELSE
             BEGIN
                 SELECT CAST(C.IdFecha AS DATE) AS IdFecha, 
                        CONCAT( datename(month, IdFecha), ' ', YEAR(IdFecha)) AS Fecha
                 FROM AP_Calendario C
                 WHERE C.Dia = 1
                       AND C.IdFecha BETWEEN DATEADD(month, -1, @FechaEfectiva) AND CURRENT_TIMESTAMP
                 ORDER BY c.IdFecha DESC;
             END;
                 -- Insert statements for procedure here

     END;

