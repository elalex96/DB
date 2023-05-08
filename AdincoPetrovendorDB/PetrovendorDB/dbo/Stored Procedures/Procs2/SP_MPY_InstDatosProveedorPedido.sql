-- =============================================
-- Author:		Alexander Gomez
-- Create date: 12-09-2018
-- Description:	Guardado de los datos del proveedor del pedido
-- =============================================
CREATE procedure [dbo].[SP_MPY_InstDatosProveedorPedido] 
	-- Add the parameters for the stored procedure here
	@RazonSocial NVARCHAR(MAX), 
	@RFC NVARCHAR(MAX), 
	@Pais NVARCHAR(MAX), 
	@Direccion NVARCHAR(MAX), 
	@Contacto NVARCHAR(MAX), 
	@EmailContacto NVARCHAR(MAX), 
	@ID NVARCHAR(MAX),
	@IdAceptacionPedido NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.MPY_MM_AceptacionPedido
	SET VendorsName = @RazonSocial,
		VendorAddress = @Direccion,
		Contacto = @Contacto,
		CorreoContacto = @EmailContacto,
		PaisSAP = @Pais
	WHERE IdAceptacionPedido = @IdAceptacionPedido
		AND IdProveedor = @ID

	SELECT 'SUCCESS'

END
