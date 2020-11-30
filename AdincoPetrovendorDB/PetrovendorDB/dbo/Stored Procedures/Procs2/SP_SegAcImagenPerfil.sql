-- =============================================
-- Author:		Manuel Cruz
-- Create date: 31-01-17
-- Description:	
-- =============================================
-- ============================================= 
-- Modified: Daniel AC
-- Updated date: 03/01/2018
-- Description: Actualice insert, update para imagen con formato image 
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegAcImagenPerfil]
	-- Add the parameters for the stored procedure here
	@IdProveedor int,
	@IdUsuario int, 
	@Imagen IMAGE,
	@ImagenThumb IMAGE

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE	@COUNT INT;
		
	SET @COUNT = (SELECT COUNT(I.IdImagen) FROM S_ImagenPerfil AS I WHERE I.IdProveedor=@IdProveedor)


	IF( @COUNT > 0 ) 
	BEGIN 
		UPDATE S_ImagenPerfil
		SET 
		ImagenProveedor = @Imagen,
		ImagenProveedorThumb =@ImagenThumb,		
		ModificadoPor = @IdUsuario,
		Fecha_Modificacion= GETDATE()
		WHERE 
		idProveedor = @IdProveedor
	END 
	ELSE
	BEGIN 
		INSERT INTO S_ImagenPerfil(ImagenProveedor, ImagenProveedorThumb, idProveedor,IdUsuario,Fecha_Carga,IsVisible)
		VALUES(@Imagen,@ImagenThumb,@IdProveedor,@IdUsuario,GETDATE(),1)
	END 
	

	select ( 'La imagen ha sido actualizada') as Mensaje
END
