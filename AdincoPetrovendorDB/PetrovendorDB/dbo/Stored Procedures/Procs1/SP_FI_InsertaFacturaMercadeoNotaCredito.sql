-- =============================================  
-- Author:   Daniel AC  
-- Create date: 14/10/2020  
-- Description:   Se agrego columnas de error SAT  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_FI_InsertaFacturaMercadeoNotaCredito]
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
    @MontoConIva DECIMAL,
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
    @IdUsuario INT,
    @IdAceptacionPedido INT,
    @ComprobanteXMLByte IMAGE,
    @ComprobantePDFByte IMAGE,
    @IdTipoPedido INT,
    @IdLectorXMLSAT INT,
    @ErrorSAT NVARCHAR(MAX)
AS
BEGIN
    -- =============================================  
    -- Author:  DANIEL AC  
    -- Create date: 14/10/2020  
    -- Description: Inserta una factura de tipo nota de crédito  
    -- =============================================  
    SET NOCOUNT ON;
    -- =============================================  
    DECLARE @ENCONTRADO AS INTEGER;
    DECLARE @IdContratoF INT;

    IF @IdContrato = 0
    BEGIN
        SET @IdContratoF =
        (
            SELECT SP.IdContrato
            FROM MM_SolicitudPedido AS SP
                INNER JOIN MM_Pedido AS P
                    ON P.IdSolicitudPedido=SP.IdSolicitudPedido
                INNER JOIN MM_AceptacionPedido AS AP
                    ON P.IdPedido=AP.IdPedido
            WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
        );
    END;
    ELSE
    BEGIN
        SET @IdContratoF = @IdContrato;
    END;


    INSERT INTO [dbo].[FI_Factura]
    (
        [Serie],
        [Folio],
        [Fecha],
        [Sello],
        [FormaPago],
        [NoCertificado],
        [Certificado],
        [CondicionesDePago],
        [SubTotal],
        [Descuento],
        [TipoCambio],
        [Moneda],
        [MontoConIva],
        [TipoComprobante],
        [MetodoPago],
        [LugarExpedicion],
        [NumCtaPago],
        [Emisor],
        [Receptor],
        [UUID],
        [FechaTimbrado],
        [SelloCFD],
        [NoCertificadoSAT],
        [SelloSAT],
        [Tipo],
        [FechaRecepcion],
        [IdSubcontratista],
        [IdMoneda],
        [IdContrato],
        [XML],
        [Activa],
        [ArchivoXML],
        [CreadoPor],
        [CreadoEn],
        [ModificadoPor],
        [ModificadoEn],
        [ProcesadoSIPAC],
        [ComprobanteXMLByte],
        [ComprobantePDFByte],
        [IdTipoPedido],
        [IdLectorXMLSAT],
        [ErroSAT]
    )
    VALUES
    (@Serie, @Folio, @Fecha, @Sello, @FormaPago, @NoCertificado, @Certificado, @CondicionesDePago, @SubTotal,
     @Descuento, @TipoCambio, @Moneda, @MontoConIva, @TipoComprobante, @MetodoPago, @LugarExpedicion, @NumCtaPago,
     @Emisor, @Receptor, @UUID, @FechaTimbrado, @SelloCFD, @NoCertificadoSAT, @SelloSAT, @Tipo, @FechaRecepcion,
     @IdSubcontratista, @IdMoneda, @IdContratoF, @XML, @Activa, @ArchivoXML, @IdUsuario, CURRENT_TIMESTAMP, @IdUsuario,
     CURRENT_TIMESTAMP, 0, @ComprobanteXMLByte, @ComprobantePDFByte, NULL, @IdLectorXMLSAT, @ErrorSAT);



    SELECT SCOPE_IDENTITY() AS IdFactura;
END;


