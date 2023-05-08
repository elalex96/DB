-- =============================================
-- Author:		Manuel CD
-- Create date: 2018-08-28
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ActualzaVolumenProduccionMensualCIEP] 
-- Add the parameters for the stored procedure here
@IdContrato               INT   = 0, 
@IdUsuario                INT   = 0, 
@Barriles                 FLOAT, 
@API                      FLOAT, 
@IdProduccionCrudoMensual INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         UPDATE [dbo].[CO_ProduccionCrudoMensualCIEP]
           SET 
               [QCE] = @Barriles, 
               [API] = @API, 
               [ModificadoPor] = @IdUsuario, 
               [ModificadoEl] = GETDATE()
         WHERE IdProduccionCrudoMensual = @IdProduccionCrudoMensual;
     END;
