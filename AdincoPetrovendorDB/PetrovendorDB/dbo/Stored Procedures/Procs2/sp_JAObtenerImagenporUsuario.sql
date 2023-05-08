-- ============================================= 
-- Modified: DANIEL AC 
-- Updated date: 03/01/2018
-- Description: ACTUALICE RETORNO DE IMAGE NVARCHAR A IMAGE 
-- =============================================
CREATE PROCEDURE [dbo].[sp_JAObtenerImagenporUsuario] 
(@IdUsuario INT,
@IdProveedor INT)
AS
BEGIN
     

    SELECT IdImagen,
           Imagen
    FROM dbo.S_ImagenPerfil
    WHERE IdProveedor = @IdProveedor

END