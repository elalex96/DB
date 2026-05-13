-- =============================================
-- Author:		Miguel
-- Create date:	10-03-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_Presupuestos] 
-- Add the parameters for the stored procedure here
@IdContrato INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         SELECT P.IdPresupuesto,
                P.Version,
                P.Nombre
         FROM CO_Presupuesto AS P
              INNER JOIN CO_AnioContractual AS AC ON P.IdAnioContractual = AC.IdAnioContractual
              INNER JOIN CO_Contrato ON AC.IdContrato = CO_Contrato.IdContrato
         WHERE(P.Activo = 1)
              AND (CO_Contrato.IdContrato = @IdContrato)
	    ORDER BY AC.Anio DESC

         -- Insert statements for procedure here

     END;

