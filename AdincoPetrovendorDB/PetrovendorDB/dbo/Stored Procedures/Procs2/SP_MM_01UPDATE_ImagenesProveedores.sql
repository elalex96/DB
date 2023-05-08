-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Materiales que se quieren agregar al pedido de manera Temp 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_01UPDATE_ImagenesProveedores]
    -- Add the parameters for the stored procedure here
    @IdImagen INT,
	@IdImagenProveedor IMAGE,
	@IdImagenProveedorThumb IMAGE
    
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.

    SET NOCOUNT ON;
	     
		UPDATE  dbo.S_ImagenPerfil
		SET ImagenProveedor= @IdImagenProveedor,
		ImagenProveedorThumb =@IdImagenProveedorThumb
		WHERE IdImagen=@IdImagen

		SELECT 'UPDATE SUCCESS'
END;


