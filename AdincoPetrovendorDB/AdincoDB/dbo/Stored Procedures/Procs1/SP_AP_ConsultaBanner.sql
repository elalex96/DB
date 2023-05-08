--╔═══════════════════════════════╗
--║Create Author: Marcos Garcia	  ║
--║Create date:   2020-03-31	  ║
--║Description:	  Select AP_Banner║
--╚═══════════════════════════════╝
CREATE PROCEDURE [dbo].[SP_AP_ConsultaBanner] 
-- Add the parameters for the stored procedure here
@IdUsuario  INT = 0, 
@IdContrato INT = 0
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT B.IdBanner,
                CASE
                    WHEN B.Activo = 0
                    THEN 'NO'
                    WHEN B.Activo = 1
                    THEN 'SI'
                    ELSE 'NO'
                END AS Activo, 
				B.Comentario,
                B.Activo AS IsActivo, 
                UC.Nombre AS CreadoPor, 
                B.CreadoEn, 
                UM.Nombre AS ModificadoPor, 
                B.ModificadoEn
         FROM dbo.AP_Banner B(NOLOCK)
              LEFT JOIN dbo.AP_Usuario UC(NOLOCK) ON B.CreadoPor = UC.UsuarioID
              LEFT JOIN dbo.AP_Usuario UM(NOLOCK) ON B.ModificadoPor = UM.UsuarioID
			  ORDER BY B.Activo DESC, B.IdBanner ASC
     END;

