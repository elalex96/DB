-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <28/10/2019>
-- Description:	<Guardar registro de pase adinco>
-- =============================================
CREATE PROCEDURE [dbo].[SP_WA_InserRegistroPaseAdinco]
	-- Add the parameters for the stored procedure here
	@IdDocumento INT,
	@IdTipoEnvio INT,
	@IdDocumentoAdinco INT,
	@IdUsuario INT,
	@IdProveedor INT,
	@IdContrato INT,
	@WSMensaje NVARCHAR(MAX),
	@UUID NVARCHAR(50),
	@Error BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IDFACTURAADINCO INT;
	DECLARE @IDFACTURAPETRO INT;
	DECLARE @IDUSUARIOPETRO INT;

	--SI SE ENVIA UNA FACTURA.....
	IF @IdTipoEnvio = 1
	BEGIN

		--SE OBTIENE LA FACTURA DE ADINCO DEACUERDO CON EL UUID RECIBIDO
	    SET @IDFACTURAADINCO = (SELECT IdFactura FROM Adinco.dbo.FI_Factura WHERE UUID = @UUID);
		--SE OBTIENE LA FACTURA DE PETROVENDOR DEACUERDO AL UUID RECIBIDO
		SET @IDFACTURAPETRO = (SELECT IdFactura FROM dbo.FI_Factura WHERE UUID = @UUID);
		--SE OBTIENE EL USUARIO EN PETRO/PROCURA DEACUERDO AL RECIBIDO
		SET @IDUSUARIOPETRO = (SELECT TOP 1 IdUsuario FROM dbo.S_Usuario WHERE IdUsuarioADINCO = @IdUsuario);
		
	END;

	IF @IdTipoEnvio = 2
	BEGIN
	    
		SET @IDFACTURAADINCO = @IdDocumentoAdinco;
		SET @IDFACTURAPETRO = @IdDocumento;
		SET @IDUSUARIOPETRO = (SELECT TOP 1 IdUsuario FROM dbo.S_Usuario WHERE IdUsuarioADINCO = @IdUsuario);

	END

	IF @IdTipoEnvio IN (3,4)
	BEGIN
	    
		SET @IDFACTURAADINCO = @IdDocumentoAdinco;
		SET @IDFACTURAPETRO = @IdDocumento;
		SET @IDUSUARIOPETRO = @IdUsuario;

	END

	--SE OBTIENE EL PROVEEDOR DE PETROVENDOR DEACUERDO AL USUARIO RECIBIDO 
	DECLARE @IDPROVEDORR INT = (SELECT TOP 1 IdProveedor FROM dbo.S_UsuarioProveedor WHERE IdUsuario = @IDUSUARIOPETRO);

	
	--SE GUARDA EL ENVIO EN LA BITACORA DE ENVIO ADINCO
	INSERT INTO dbo.WA_BitacoraEnvioAdinco
	(
	    IdDocumento,
	    IdTipoEnvio,
	    FechaEnvio,
	    IdDocumentoAdinco,
	    IdUsuario,
	    IdProveedor,
	    IdContrato,
	    WSMensaje,
		IsError
	)
	VALUES
	(   @IDFACTURAPETRO,         -- IdDocumento - int
	    @IdTipoEnvio,         -- IdTipoEnvio - int
	    GETDATE(), -- FechaEnvio - datetime
	    @IDFACTURAADINCO,         -- IdDocumentoAdinco - int
	    @IDUSUARIOPETRO,         -- IdUsuario - int
	    @IDPROVEDORR,         -- IdProveedor - int
	    @IdContrato,         -- IdContrato - int
	    @WSMensaje,        -- WSMensaje - nvarchar(max)}
		@Error
	    )

	--RESPALDO DE LA FACTURA QUE SE ENVIO
	IF @IdTipoEnvio = 1 AND ISNULL(@Error,0) = 0 --Factura
	BEGIN

	    INSERT INTO dbo.WA_Factura_Bitacora
	    SELECT
	        IdFactura,
	        Serie,
	        Folio,
	        Fecha,
	        Sello,
	        FormaPago,
	        NoCertificado,
	        Certificado,
	        CondicionesDePago,
	        SubTotal,
	        Descuento,
	        TipoCambio,
	        Moneda,
	        MontoConIva,
	        TipoComprobante,
	        MetodoPago,
	        LugarExpedicion,
	        NumCtaPago,
	        Emisor,
	        Receptor,
	        UUID,
	        FechaTimbrado,
	        SelloCFD,
	        NoCertificadoSAT,
	        SelloSAT,
	        Tipo,
	        FechaRecepcion,
	        IdSubcontratista,
	        IdMoneda,
	        IdContrato,
	        XML,
	        Activa,
	        ArchivoPDF,
	        ArchivoXML,
	        CreadoPor,
	        CreadoEn,
	        ModificadoPor,
	        ModificadoEn,
	        PDF,
	        IdReceptor,
	        IdentificadorSIPAC,
	        NombreXML,
	        IdEstudioPrecioTransfer,
	        IdDocFacturacionSIPAC,
	        ProcesadoSIPAC,
	        ClaveFormaPago,
	        IdEstatusEnviado,
	        FechaEnvio,
	        ComprobantePDFByte,
	        ComprobanteXMLByte,
	        IdTipoPedido,
	        ResponseAdinco,
	        IsEliminado,
	        EliminadoPor,
	        EliminadoEL,
	        ComentarioEliminado,
	        IdEliminado,
	        IdLectorXMLSAT,
	        ErroSAT
	    FROM dbo.FI_Factura
		WHERE IdFactura = @IDFACTURAPETRO;

		INSERT INTO dbo.WA_CFDIConcepto
		SELECT
		    IdFacturaConcepto,
		    IdFactura,
		    Descripcion,
		    Cantidad,
		    Unidad,
		    ValorUnitario,
		    Importe,
		    NoIdentificacion,
		    CreadoPor,
		    Descuento,
		    ClaveUnidad,
		    ClaveProdServ
		FROM dbo.FI_CFDIConcepto
		WHERE IdFactura = @IDFACTURAPETRO;

		INSERT INTO dbo.WA_CFDIImpuesto
		SELECT
		    IdFactura,
		    IdTipoImpuesto,
		    Impuesto,
		    Tasa,
		    Importe,
		    CreadoPor
		FROM dbo.FI_CFDIImpuesto 
		WHERE IdFactura = @IDFACTURAPETRO;

	END

	--RESPALDO DEL GASTO QUE SE ENVIO
	IF @IdTipoEnvio = 2 AND ISNULL(@Error,0) = 0 --Gasto
	BEGIN
	    
		INSERT INTO dbo.WA_Registro_Bitacora
		SELECT * FROM dbo.CO_Registro
		WHERE IdRegistro = @IDFACTURAPETRO;

	END




	IF @IdTipoEnvio IN (3,4)
	BEGIN
	    
		INSERT INTO dbo.WA_PedimentoComprobante
		SELECT
		    IdPedimentoComprobante,
		    IdContrato,
		    NumeroPedimento,
		    ClavePedimento,
		    FolioComprobante,
		    FechaPago,
		    Regimen,
		    IdSubcontratistaImportador,
		    AduanaES,
		    IdSubcontratistaExportador,
		    IdFormaPago,
		    IdMoneda,
		    AcuseElectronico,
		    IdEstudioPrecioTransfer,
		    IdDocFacturacionSIPAC,
		    CvTipoDocFacturacion,
		    ProcesadoSIPAC,
		    CreadoPor,
		    CreadoEn,
		    ModificadoPor,
		    ModificadoEn,
		    HashSHA256,
		    IsEliminado,
		    IsActivo,
		    IsBorrador,
		    IdOrigen,
		    TipoOrigen,
		    IdPedidoGeneral,
		    IdEstatusEliminado,
		    IdEliminado,
		    Reportado
		FROM dbo.FI_PedimentoComprobante
		WHERE IdPedimentoComprobante = @IdDocumento;

		INSERT INTO dbo.WA_PedimentoComprobanteDetalle
		SELECT
		    IdPedimentoComprobanteDetalle,
		    IdPedimentoComprobante,
		    IdUnidadMedida,
		    NumeroSerieMercancia,
		    DescripcionMercancia,
		    ClaseBienServicio,
		    PrecioUnitario,
		    Cantidad,
		    ImporteTotal,
		    CreadoPor,
		    CreadoEn,
		    ModificadoPor,
		    ModificadoEn,
		    IsEliminado,
		    IsActivo,
		    IsBorrador,
		    IdAceptacionPedido,
		    IdMaterialImportado,
		    IdAceptacionPedidoDetalle
		FROM dbo.FI_PedimentoComprobanteDetalle 
		WHERE IdPedimentoComprobante = @IdDocumento;

	END

END
