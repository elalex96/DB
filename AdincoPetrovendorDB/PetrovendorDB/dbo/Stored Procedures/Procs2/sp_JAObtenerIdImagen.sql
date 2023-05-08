-- ============================================= 
-- Modified: DANIEL AC 
-- Updated date: 03/01/2018
-- Description: ACTUALICE RETORNO DE IMAGE NVARCHAR A IMAGE 
-- =============================================
CREATE PROCEDURE [dbo].[sp_JAObtenerIdImagen] (@IdProveedor INT)
AS
BEGIN
    SELECT IdImagen,ImagenProveedor
    FROM dbo.S_ImagenPerfil
    WHERE IdProveedor = @IdProveedor
          AND IsVisible = 1
END