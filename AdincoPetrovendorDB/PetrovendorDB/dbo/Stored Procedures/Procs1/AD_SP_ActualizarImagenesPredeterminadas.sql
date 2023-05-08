-- ============================================= 
-- Create: DANIEL AC 
-- Updated date: 08/01/2017 
-- Description: ACTUALIZAR DE IMAGENES PREDETERMINADAS 
-- =============================================
CREATE PROCEDURE [dbo].[AD_SP_ActualizarImagenesPredeterminadas]  
(
   
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME,
	@Imagen IMAGE,
	@ImagenThumb IMAGE,
	@Detalle NVARCHAR(500),	
	@IdImagenPredeterminada INT 
)
AS
BEGIN

	UPDATE dbo.PV_ImagenPredeterminada
	SET Detalle=@Detalle,
	EditadaPor=@IdUsuario,
	EditadaEl= GETDATE(),
	Imagen=@Imagen,
	ImagenThumb = @ImagenThumb
	WHERE IdImagenPredeterminada=@IdImagenPredeterminada
END
