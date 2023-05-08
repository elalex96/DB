-- =============================================
-- Author:		Daniel AC
-- Create date: 07-12-17
-- Description:	
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 17/01/2018
-- Description:	se modifica el store para que los combos @idCuentaContable, @idCuentaSectorHidrocarburos,@idCentroCosto sean nuleables
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_GuardarFacturaCompraDirecta]
    -- Add the parameters for the stored procedure here
    @Serie NVARCHAR(MAX),
    @Folio NVARCHAR(MAX),
    @Fecha DATETIME,
    @Sello NVARCHAR(MAX),
    @FormaPago NVARCHAR(MAX),
    @NoCertificado NVARCHAR(MAX),
    @Certificado NVARCHAR(MAX),
    @CondicionesDePago NVARCHAR(MAX),
    @SubTotal MONEY,
    @Descuento MONEY,
    @TipoCambio MONEY,
    @Moneda NVARCHAR(MAX),
    @MontoConIva DECIMAL(18, 4),
    @TipoComprobante NVARCHAR(MAX),
    @MetodoPago NVARCHAR(MAX),
    @LugarExpedicion NVARCHAR(MAX),
    @NumCtaPago NVARCHAR(MAX),
    @Emisor NVARCHAR(MAX),
    @Receptor NVARCHAR(MAX),
    @UUID NVARCHAR(MAX),
    @FechaTimbrado DATETIME,
    @SelloCFD NVARCHAR(MAX),
    @NoCertificadoSAT NVARCHAR(MAX),
    @SelloSAT NVARCHAR(MAX),
    @Tipo NVARCHAR(MAX),
    @FechaRecepcion DATETIME,
    @IdSubcontratista INT,
    @IdMoneda INT,
    @IdContrato INT,
    @XML NVARCHAR(MAX),
    @Activa BIT,
    --- @ArchivoPDF NVARCHAR(MAX),
    @ArchivoXML NVARCHAR(MAX),
    @CreadoPor INT,
    --- @PDF NVARCHAR(MAX),
    @NombreXML NVARCHAR(MAX),
    @lineaPresupuesto INT,
    @idPeriodo INT,
    @idPresupuesto INT,
    @Comentarios NVARCHAR(200),
    @idCuentaContable INT,
    @idCuentaSectorHidrocarburos INT,
    @idCentroCosto INT,
    @montoEjercido DECIMAL(18, 4),
    @inicioEjecucion DATE,
    @finEjecucion DATE,
    @idInstalacion INT,
    @ComprobantePDFByte IMAGE,
    @ComprobanteXMLByte IMAGE,
    @IdTipoPedido INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @idFactura INT,
            @mesPresentacion DATE

    IF (@idCuentaContable = -1)
        SET @idCuentaContable = NULL

    IF (@idCuentaSectorHidrocarburos = -1)
        SET @idCuentaSectorHidrocarburos = NULL

    IF (@idCentroCosto = -1)
        SET @idCentroCosto = NULL


    INSERT INTO dbo.FI_Factura
    (
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
        PDF,
        NombreXML,
        ComprobantePDFByte,
        ComprobanteXMLByte,
        IdTipoPedido
    )
    VALUES
    (   @Serie,             -- Serie - nvarchar(max)
        @Folio,             -- Folio - nvarchar(max)
        @Fecha,             -- Fecha - datetime
        @Sello,             -- Sello - nvarchar(max)
        @FormaPago,         -- FormaPago - nvarchar(max)
        @NoCertificado,     -- NoCertificado - nvarchar(max)
        @Certificado,       -- Certificado - nvarchar(max)
        @CondicionesDePago, -- CondicionesDePago - nvarchar(max)
        @SubTotal,          -- SubTotal - money
        @Descuento,         -- Descuento - money
        @TipoCambio,        -- TipoCambio - money
        @Moneda,            -- Moneda - nvarchar(max)
        @MontoConIva,       -- MontoConIva - decimal(18, 4)
        @TipoComprobante,   -- TipoComprobante - nvarchar(max)
        @MetodoPago,        -- MetodoPago - nvarchar(max)
        @LugarExpedicion,   -- LugarExpedicion - nvarchar(max)
        @NumCtaPago,        -- NumCtaPago - nvarchar(max)
        @Emisor,            -- Emisor - nvarchar(max)
        @Receptor,          -- Receptor - nvarchar(max)
        @UUID,              -- UUID - nvarchar(max)
        @FechaTimbrado,     -- FechaTimbrado - datetime
        @SelloCFD,          -- SelloCFD - nvarchar(max)
        @NoCertificadoSAT,  -- NoCertificadoSAT - nvarchar(max)
        @SelloSAT,          -- SelloSAT - nvarchar(max)
        @Tipo,              -- Tipo - nvarchar(max)
        @FechaRecepcion,    -- FechaRecepcion - datetime
        @IdSubcontratista,  -- IdSubcontratista - int
        @IdMoneda,          -- IdMoneda - int
        @IdContrato,        -- IdContrato - int
        @XML,               -- XML - nvarchar(max)
        @Activa,            -- Activa - bit
        NULL,               -- ArchivoPDF - nvarchar(max)
        @ArchivoXML,        -- ArchivoXML - nvarchar(max)
        @CreadoPor,         -- CreadoPor - int
        GETDATE(),          -- CreadoEn - datetime
        NULL,               -- PDF - varbinary(max)
        @NombreXML,         -- NombreXML - nvarchar(max)
        @ComprobantePDFByte,
        @ComprobanteXMLByte,
        @IdTipoPedido
    )

    SELECT @idFactura = SCOPE_IDENTITY()
    SELECT @mesPresentacion = DATEADD(MONTH, DATEDIFF(MONTH, 0, @inicioEjecucion), 0)

    INSERT INTO dbo.CO_Registro
    (
        IdFactura,
        MontoRegistro,
        InicioEjecucion,
        FinEjecucion,
        Comentarios,
        MesPresentacion,
        IdUsuarioCreadoPor,
        FecMovto,
        IdInstalacion,
        CreadoPor,
        IdCatalogoCuentasSH,
        CentroCostos,
        CuentaContable,
        IdLineaPresupuestoMes,
		CvTipoDocFacturacion,
		CostosAtribuiblesAdministracion
    )
    VALUES
    (   @idFactura,                   -- IdFactura - int
        @montoEjercido,               -- MontoRegistro - decimal(18, 4)  
        @inicioEjecucion,
        @finEjecucion,
        @Comentarios,
        @mesPresentacion,             -- MesPresentacion - date
        @CreadoPor,                   -- IdUsuarioCreadoPor - int
        GETDATE(),                    -- FecMovto - datetime
        @idInstalacion,
        @CreadoPor,                   -- CreadoPor - int
        @idCuentaSectorHidrocarburos, -- IdCatalogoCuentasSH - int
        @idCentroCosto,               -- CentroCostos - int
        @idCuentaContable,            -- CuentaContable - int
        @lineaPresupuesto,             -- IdLineaPresupuestoMes - int
		1,
		1
    )

    --Retorno para saber el valor del id de la factura que se inserto
    SELECT @idFactura


END;


