-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2019-07-11
-- Description:	Actualiza el pdf del EPT
-- =============================================
CREATE PROCEDURE [SP_FI_ActualizaEPT] 
-- Add the parameters for the stored procedure here
@IdEpt      INT, 
@EptPdf     IMAGE, 
@IdUsuario  INT, 
@IdContrato INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         UPDATE dbo.FI_EstudioPreciosTransfer
           SET 
               Archivo = @EptPdf
         WHERE IdEstudioPrecioTransfer = @IdEpt;
         --
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;
