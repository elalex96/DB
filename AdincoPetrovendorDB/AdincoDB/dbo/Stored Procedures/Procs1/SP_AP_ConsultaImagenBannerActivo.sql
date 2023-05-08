--╔════════════════════════════════════════════╗
--║Create Author: Marcos Garcia				   ║
--║Create date:   2020-04-01				   ║
--║Description:	  Consulta ImagenBanner Activos║
--╚════════════════════════════════════════════╝
CREATE PROCEDURE [dbo].[SP_AP_ConsultaImagenBannerActivo] 
-- Add the parameters for the stored procedure here
@IdUsuario  INT = 0, 
@IdContrato INT = 0
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT 
                B.BannerImagen,
				 ROW_NUMBER() OVER(ORDER BY B.IdBanner ASC) AS FileName
         FROM dbo.AP_Banner B(NOLOCK)             
         WHERE B.Activo = 1;
     END;