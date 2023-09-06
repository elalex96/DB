USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'AP_ConsultaBannerOperadoras'
)
    DROP PROCEDURE AP_ConsultaBannerOperadoras;
/****** Object:  StoredProcedure [dbo].[AP_ConsultaBannerOperadoras]    Script Date: 23/08/2023 11:46:00 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--╔═════════════════════════════════════════╗
--║Create Author:	Daniel AC	            ║
--║Create date:   2022-08-23	            ║
--║Description:	  Select AP_BannerOperadoras║
--╚═════════════════════════════════════════╝
CREATE PROCEDURE [dbo].[AP_ConsultaBannerOperadoras] 
-- Add the parameters for the stored procedure here
@IdUsuario  INT = 0, 
@IdContrato INT = 0,
@IdProveedor INT = 0,
@Consulta NVARCHAR(MAX)
AS
     BEGIN
         SET NOCOUNT ON;

		 IF @Consulta ='ADMINISTRACION'
		 BEGIN 
         SELECT B.IdBanner,
				B.ImagenOperadora,
				B.Activo, 
				B.Orden,                
				ISNULL(B.Comentario,'') AS Comentario,          
				B.NombreImagen,
                UC.Nombre AS CreadoPor, 
                B.CreadoEn, 
                UM.Nombre AS ModificadoPor, 
                B.ModificadoEn
         FROM AP_BannerOperadoras B(NOLOCK)
              LEFT JOIN dbo.S_Usuario UC(NOLOCK) ON B.CreadoPor = UC.IdUsuario
              LEFT JOIN dbo.S_Usuario UM(NOLOCK) ON B.ModificadoPor = UM.IdUsuario
			  ORDER BY B.Orden ASC
		END

		IF @Consulta ='BANNER-LOGIN'
		BEGIN

			SELECT B.ImagenOperadora		
			,NombreImagen 
			FROM AP_BannerOperadoras B(NOLOCK)
			WHERE B.Activo =1 
			ORDER BY Orden ASC

		END 


     END;