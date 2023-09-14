USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'AP_InsertImagenBannerOperadoras'
)
    DROP PROCEDURE AP_InsertImagenBannerOperadoras;
/****** Object:  StoredProcedure [dbo].[AP_InsertImagenBannerOperadoras]    Script Date: 23/08/2023 11:23:32 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--╔══════════════════════════════════════════════════════╗
--║Create Author: Daniel AC			     				 ║
--║Create date:   2023-08-23							 ║
--║Description:	  Insertar Imagen en AP_BannerOperadoras ║
--╚══════════════════════════════════════════════════════╝
CREATE PROCEDURE [dbo].[AP_InsertImagenBannerOperadoras] 
-- Add the parameters for the stored procedure here
@IdUsuario    INT           = 0, 
@IdContrato   INT           = 0, 
@IdProveedor  INT			= 0,
@Activo       BIT, 
@Comentario   NVARCHAR(MAX), 
@NombreImagen   NVARCHAR(MAX),
@ImagenOperadora IMAGE,
@Orden INT
AS
     BEGIN
         SET NOCOUNT ON;		 
         INSERT INTO AP_BannerOperadoras
         (ImagenOperadora, 
          Activo, 
          Comentario, 
		  Orden,
		  NombreImagen,
          CreadoPor, 
          CreadoEn
         )
         VALUES
         (@ImagenOperadora, 
          @Activo, 
		  @Comentario, 
		  @Orden,
		  @NombreImagen,
          @IdUsuario, 
          GETDATE()
         );

         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;

     END;