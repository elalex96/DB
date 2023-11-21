
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_ActualizaEPT'
)
    DROP PROCEDURE SP_FI_ActualizaEPT
GO
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2019-07-11
-- Description:	Actualiza el pdf del EPT
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ActualizaEPT] 
@IdEpt      INT, 
@EptPdf     IMAGE, 
@IdUsuario  INT, 
@IdContrato INT
AS
     BEGIN

         SET NOCOUNT ON;

         UPDATE dbo.FI_EstudioPreciosTransfer
           SET 
               Archivo = @EptPdf
         WHERE IdEstudioPrecioTransfer = @IdEpt;
         
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;
