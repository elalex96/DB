drop procedure if exists SP_OCD_ConsultaDescargaCN
go
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <20/04/2020>
-- Description:	<consultar datos de descarga de la carta cn para compra directa>
-- =============================================
-- Author:		<Luis David De La Cruz>
-- Create date: <18/10/2021>
-- Description:	<se agregró el campo Bucket a las consultas>
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
					Identificador,
					ISNULL(Bucket,'') as Bucket
				FROM dbo.CN_ArchivoCartaCompraDirecta
				WHERE IdFactura = @IdFactura
					AND IdProveedor = @IdProveedor
					AND IdPedido = @IdPedido)
	BEGIN
	    
		SELECT
			IdAchivoCNCD,
			nombreArchivo = case when rtrim(ltrim(nombreArchivo)) = '' then Identificador else nombreArchivo end,
			Carpeta,
			Mime = 'application/pdf',
			Extension='pdf',
			Identificador,
			ISNULL(Bucket,'') as Bucket
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
