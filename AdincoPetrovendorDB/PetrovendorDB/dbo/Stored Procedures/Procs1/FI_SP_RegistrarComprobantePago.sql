-- =============================================
-- Author:		<Jose Roman>
-- Create date: <12-06-2018>
-- Description:	<SP para registrar un comprobante de pago>
-- Create date: <07-02-2018>
-- Description:	<Se agrega el envio del comprobante a Adinco>
-- =============================================
-- =============================================
-- Author:   Daniel AC
-- Create date: 01/10/2019
-- Description:   Se removio insertado de registros de Adinco 
-- =============================================

CREATE procedure [dbo].[FI_SP_RegistrarComprobantePago]
	@Serie NVARCHAR(max),
	@Folio NVARCHAR(max),
	@Fecha DATETIME, 
	@FormaPago NVARCHAR(max),
	@NoCertificado NVARCHAR(max),
	@CondicionesDePago NVARCHAR(max),
	@SubTotal MONEY,
	@Descuento MONEY,
	@TipoCambio MONEY,
	@Moneda NVARCHAR(max),
	@TipoComprobante NVARCHAR(MAX),
	@MetodoPago NVARCHAR(max),
	@LugarExpedicion NVARCHAR(max),
	@NumCtaPago NVARCHAR(max),
	@Emisor NVARCHAR(max),
	@Receptor NVARCHAR(max),
	@UUID NVARCHAR(max),
	@IdSubcontratista INT,
	@XML NVARCHAR(max),
	@RFCReceptor varchar(30),
	@NombreXML NVARCHAR(max),
	@FechaTimbrado DATETIME,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	DECLARE @IdContratista INT = (SELECT TOP 1 IdProveedor FROM dbo.S_Proveedor WHERE RFC = @RFCReceptor AND Activo = 1 AND ISNULL(IsEliminado, 0) = 0)
	DECLARE @IdFacturaPetrovendor INT,
			@IdFacturaAdinco INT

	--SET @IdContrato = (SELECT TOP 1 IdContrato FROM dbo.FI_Factura WHERE UUID = @UUID);

	--Registro de comprobante en Petrovendor
	INSERT INTO dbo.FI_Factura
	(
	    Serie,
	    Folio,
	    Fecha,
	    FormaPago,
	    NoCertificado,
	    CondicionesDePago,
	    SubTotal,
	    Descuento,
	    TipoCambio,
	    Moneda,
	    TipoComprobante,
	    MetodoPago,
	    LugarExpedicion,
	    NumCtaPago,
	    Emisor,
	    Receptor,
	    UUID,
	    FechaRecepcion,
	    IdSubcontratista,
	    --IdContrato,
	    XML,
	    Activa,
	    CreadoPor,
	    CreadoEn,
	    IdReceptor,
	    NombreXML,
	    IsEliminado,
		FechaTimbrado
	)
	VALUES
	(  
		@Serie,
		@Folio,
		@Fecha,
		@FormaPago,
		@NoCertificado,
		@CondicionesDePago,
		@SubTotal,
		@Descuento,
		@TipoCambio,
		@Moneda,
		@TipoComprobante,
		@MetodoPago,
		@LugarExpedicion,
		@NumCtaPago,
		@Emisor,
		@Receptor,
		@UUID,
		GETDATE(),
		@IdSubcontratista,
		--@IdContrato,
		@XML,
		1,
		@IdUsuario,
		GETDATE(),
		@IdContratista,
		@NombreXML,
		0,
		@FechaTimbrado
	)
	
	SET	@IdFacturaPetrovendor = SCOPE_IDENTITY()
	SELECT @IdFacturaPetrovendor

END



