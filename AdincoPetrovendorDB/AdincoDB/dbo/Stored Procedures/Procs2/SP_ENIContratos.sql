-- =============================================
-- Author:		Manuel Cruz
-- Create date: 26-06-2020
-- Description:	
-- =============================================
CREATE PROCEDURE SP_ENIContratos 
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
                NumeroContrato
         FROM CO_Contrato
         WHERE IdContratista = @IdContratista;
     END;
