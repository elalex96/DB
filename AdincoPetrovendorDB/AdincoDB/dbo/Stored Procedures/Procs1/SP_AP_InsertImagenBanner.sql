--╔═══════════════════════════════════════════╗
--║Create Author: Marcos Garcia				  ║
--║Create date:   2020-03-30				  ║
--║Description:	  Insertar Imagen en AP_Banner║
--╚═══════════════════════════════════════════╝
CREATE PROCEDURE [dbo].[SP_AP_InsertImagenBanner] 
-- Add the parameters for the stored procedure here
@IdUsuario    INT           = 0, 
@IdContrato   INT           = 0, 
@Activo       INT, 
@Comentario   NVARCHAR(MAX), 
@ImagenBanner IMAGE
AS
     BEGIN
         SET NOCOUNT ON;		 
         INSERT INTO dbo.AP_Banner
         (BannerImagen, 
          Activo, 
          Comentario, 
          CreadoPor, 
          CreadoEn
         )
         VALUES
         (@ImagenBanner, 
          @Activo, 
          @Comentario, 
          @IdUsuario, 
          GETDATE()
         );
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;