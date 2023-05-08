--╔════════════════════════════════════════╗
--║Create Author: Marcos Garcia			   ║
--║Create date:   2020-04-01			   ║
--║Description:	  Update Datos en AP_Banner║
--╚════════════════════════════════════════╝
CREATE PROCEDURE [dbo].[SP_AP_UpdateImagenBanner] 
-- Add the parameters for the stored procedure here
@IdUsuario  INT = 0, 
@IdContrato INT = 0, 
@IdBanner   INT, 
@Activo     INT,
@Comentario NVARCHAR(MAX)
AS
     BEGIN
         SET NOCOUNT ON;
         UPDATE dbo.AP_Banner
           SET 
               Activo = @Activo, 
			   Comentario = @Comentario,
               ModificadoPor = @IdUsuario, 
               ModificadoEn = GETDATE()
         WHERE IdBanner = @IdBanner;
		 IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;

     END;