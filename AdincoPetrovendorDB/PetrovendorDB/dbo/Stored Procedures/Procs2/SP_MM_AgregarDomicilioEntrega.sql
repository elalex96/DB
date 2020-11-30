-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017
-- Description:	Permite agregar Domicilio de entrega de Pedido
-- =============================================
CREATE   PROCEDURE  [dbo].[SP_MM_AgregarDomicilioEntrega] 
	-- Add the parameters for the stored procedure here
		
	@Calle nvarchar(MAX),
	@NoExterior nvarchar(300),
	@NoInterior nvarchar(300),
	@Colonia nvarchar(350),
	@Municipio nvarchar(300),
	@Estado nvarchar(300),
	@CodigoPostal nvarchar(100),
	@Referencia nvarchar(MAX),
	@IdProveedor int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[MM_DomicilioEntregaPedido](Calle,NoExterior,NoInterior,Colonia,Municipio,Estado,CP,Referencia,IdProveedor)
	VALUES(@Calle,@NoExterior,@NoInterior,@Colonia,@Municipio,@Estado,@CodigoPostal,@Referencia, @IdProveedor)

	SELECT @@IDENTITY AS IdDomicilioEntrega
END

