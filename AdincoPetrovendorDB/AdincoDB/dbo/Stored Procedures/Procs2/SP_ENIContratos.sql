-- =============================================
-- Author:		Manuel Cruz
-- Create date: 26-06-2020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENIContratos] 
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         DECLARE @IdContratista INT;
         --
         SELECT @IdContratista = IdContratista
         FROM dbo.CO_Contrato
         WHERE IdContrato = @IdContrato;

         /**/

         SELECT IdContrato, 
                NumeroContrato + ' - ' + AC.NombreAreaContractual AS NumeroContrato
         FROM CO_Contrato AS C
		 LEFT JOIN CO_AreaContractual AS AC ON C.IdAreaContractual = AC.IdAreaContractual 
         WHERE IdContratista = @IdContratista;

     END;