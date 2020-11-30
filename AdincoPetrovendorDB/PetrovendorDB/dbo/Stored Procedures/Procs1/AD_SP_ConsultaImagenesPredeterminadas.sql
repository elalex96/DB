-- ============================================= 
-- Create: DANIEL AC 
-- Updated date: 08/01/2017 
-- Description: CONSULTA DE IMAGENES PREDETERMINADAS 
-- =============================================
CREATE PROCEDURE [dbo].[AD_SP_ConsultaImagenesPredeterminadas]  
(
   
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME
)
AS
BEGIN
    SELECT IdImagenPredeterminada,Detalle, Imagen,ImagenThumb
	FROM dbo.PV_ImagenPredeterminada
END


