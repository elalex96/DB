-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <20/04/2020>
-- Description:	<guardado de los archivos de s3 de carta cn de compra directa>
-- =============================================
CREATE PROCEDURE [dbo].[SP_OCD_GuardarArchivoCN]
	-- Add the parameters for the stored procedure here
	@IdFactura INT,
	@nombreArchivo NVARCHAR(MAX),
	@Carpeta NVARCHAR(MAX),
	@Mime NVARCHAR(MAX),
	@Identificador NVARCHAR(MAX),
	@Extension NVARCHAR(MAX),
	@IdUsuario INT,
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IDPEDIDO INT = (SELECT IdPedido FROM dbo.MM_Pedidos WHERE IdIdentificador = @IdFactura AND IdTipoPedido = 1 AND IdProveedorCliente = @IdProveedor);

	IF EXISTS (SELECT * FROM dbo.CN_ArchivoCartaCompraDirecta WHERE IdFactura = @IdFactura)
	BEGIN
	    
		UPDATE dbo.CN_ArchivoCartaCompraDirecta
		SET nombreArchivo = @nombreArchivo,
			Carpeta = @Carpeta,
			Mime = @Mime,
			Extension = Extension,
			Identificador = @Identificador,
			ModificadoPor = @IdUsuario,
			ModificadoEl = GETDATE()
		WHERE IdFactura = @IdFactura;

		SELECT @IdFactura

	END
	ELSE
	BEGIN
	    INSERT INTO dbo.CN_ArchivoCartaCompraDirecta
	(
	    IdFactura,
	    nombreArchivo,
	    Carpeta,
	    Mime,
	    Extension,
	    Identificador,
	    CreadoPor,
	    CreadoEl,
	    IdProveedor,
		IdPedido,
		Activo
	)
	VALUES
	(   @IdFactura,         -- IdFactura - int
	    @nombreArchivo,         -- nombreArchivo - int
	    @Carpeta,       -- Carpeta - nvarchar(max)
	    @Mime,       -- Mime - nvarchar(max)
	    @Extension,       -- Extension - nvarchar(max)
	    @Identificador,       -- Identificador - nvarchar(max)
	    @IdUsuario,         -- CreadoPor - int
	    GETDATE(), -- CreadoEl - datetime
	    @IdProveedor,          -- IdProveedor - int
		@IDPEDIDO,
		1
	  );

	  SELECT SCOPE_IDENTITY() AS id
	END
	

END
