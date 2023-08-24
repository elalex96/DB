USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'AP_EliminarImagenBannerOperadoras'
)
    DROP PROCEDURE AP_EliminarImagenBannerOperadoras;
/****** Object:  StoredProcedure [dbo].[AP_InsertImagenBannerOperadoras]    Script Date: 23/08/2023 11:23:32 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--╔═════════════════════════════════════════════════════════════╗
--║Create Author: Daniel AC			     						║
--║Create date:   2023-08-23									║
--║Description:	  Desactivar Imagen en AP_BannerOperadoras		║
--╚═════════════════════════════════════════════════════════════╝
CREATE PROCEDURE [dbo].[AP_EliminarImagenBannerOperadoras] 
-- Add the parameters for the stored procedure here
@IdUsuario    INT           = 0, 
@IdProveedor  INT			= 0,
@IdContrato   INT           = 0, 
@IdBanner     INT
AS
     BEGIN
         SET NOCOUNT ON;	
		 
         UPDATE AP_BannerOperadoras   
		 SET Activo = 0,
		 ModificadoEn = GETDATE(),
		 ModificadoPor = @IdUsuario
         WHERE IdBanner= @IdBanner    
END;