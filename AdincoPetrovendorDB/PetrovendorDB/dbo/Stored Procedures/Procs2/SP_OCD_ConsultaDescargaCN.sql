-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <20/04/2020>
-- Description:	<consultar datos de descarga de la carta cn para compra directa>
-- =============================================
CREATE PROCEDURE [dbo].[SP_OCD_ConsultaDescargaCN]
	-- Add the parameters for the stored procedure here
	@IdFactura INT,
	@IdPedido INT,
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	IF EXISTS (SELECT
					IdAchivoCNCD,
					nombreArchivo,
					Carpeta,
					Mime,
					Extension,
					Identificador
				FROM dbo.CN_ArchivoCartaCompraDirecta
				WHERE IdFactura = @IdFactura
					AND IdProveedor = @IdProveedor
					AND IdPedido = @IdPedido)
	BEGIN
	    
		SELECT
			IdAchivoCNCD,
			nombreArchivo,
			Carpeta,
			Mime,
			Extension,
			Identificador
		FROM dbo.CN_ArchivoCartaCompraDirecta
		WHERE IdFactura = @IdFactura
			AND IdProveedor = @IdProveedor
			AND IdPedido = @IdPedido;

	END
	ELSE
	BEGIN
	    
		SELECT 'CARTA_CN_NO_CARGADA' AS RESPONSE

	END

	

END
