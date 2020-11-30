CREATE PROCEDURE [dbo].[SP_CO_GuardarCompraDirectaFactura]
(
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
    @ArchivoPDF NVARCHAR(MAX),
    @ArchivoXML NVARCHAR(MAX),
    @CreadoPor INT,
    @PDF NVARCHAR(MAX),
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
	@idInstalacion INT
)
AS
BEGIN
    DECLARE @idFactura INT,
            @pdfVarBinary VARBINARY(MAX),
            @mesPresentacion DATE
    SELECT @pdfVarBinary = CAST(@PDF AS VARBINARY(MAX))

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
        NombreXML
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
        @ArchivoPDF,        -- ArchivoPDF - nvarchar(max)
        @ArchivoXML,        -- ArchivoXML - nvarchar(max)
        @CreadoPor,         -- CreadoPor - int
        GETDATE(),          -- CreadoEn - datetime
        @pdfVarBinary,      -- PDF - varbinary(max)
        @NombreXML          -- NombreXML - nvarchar(max)
    )

    SELECT @idFactura = @@IDENTITY
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
        IdLineaPresupuestoMes
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
        @lineaPresupuesto             -- IdLineaPresupuestoMes - int
    )

    --Retorno para saber el valor del id de la factura que se inserto
    SELECT @idFactura
END

