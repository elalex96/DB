-- =============================================
-- Author:		Miguel
-- Create date: 5-12-16
-- Description:	Inserta una factura
-- Update Author:		Alexander Gomez
-- Update date: 26-06-2018
-- Description: Modificacion para el parametro de IdContrato Nulo para Murphy
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_InsertaFactura]
-- Add the parameters for the stored procedure here
@Serie                     NVARCHAR(MAX), 
@Folio                     NVARCHAR(MAX), 
@Fecha                     DATETIME, 
@Sello                     NVARCHAR(MAX), 
@FormaPago                 NVARCHAR(MAX), 
@NoCertificado             NVARCHAR(MAX), 
@Certificado               NVARCHAR(MAX), 
@CondicionesDePago         NVARCHAR(MAX), 
@SubTotal                  MONEY, 
@Descuento                 MONEY, 
@TipoCambio                MONEY, 
@Moneda                    NVARCHAR(MAX), 
@MontoConIva               MONEY, 
@TipoComprobante           NVARCHAR(MAX), 
@MetodoPago                NVARCHAR(MAX), 
@LugarExpedicion           NVARCHAR(MAX), 
@NumCtaPago                NVARCHAR(MAX), 
@Emisor                    NVARCHAR(MAX), 
@Receptor                  NVARCHAR(MAX), 
@UUID                      NVARCHAR(MAX), 
@FechaTimbrado             DATETIME, 
@SelloCFD                  NVARCHAR(MAX), 
@NoCertificadoSAT          NVARCHAR(MAX), 
@SelloSAT                  NVARCHAR(MAX), 
@Tipo                      NVARCHAR(MAX), 
@FechaRecepcion            DATETIME, 
@IdSubcontratista          INT, 
@IdMoneda                  INT, 
@IdContrato                INT, 
@XML                       NVARCHAR(MAX), 
@Activa                    BIT, 
@ArchivoPDF                NVARCHAR(MAX), 
@ArchivoXML                NVARCHAR(MAX), 
@IdUsuario                 INT, 
@RegimenFiscal             NVARCHAR(MAX), 
@UsoCFDI                   NVARCHAR(MAX), 
@VersionCFDI               NVARCHAR(MAX), 
@TotalImpuestosTrasladados MONEY         = 0, 
@TotalImpuestosRetenidos   MONEY         = 0
AS
     BEGIN
         SET NOCOUNT ON;
         DECLARE @ENCONTRADO AS INTEGER;
         IF LEN(RTRIM(@UUID)) > 0
             BEGIN
                 SELECT @ENCONTRADO = COUNT(1)
                 FROM FI_Factura F
                 WHERE F.UUID = @UUID;
                 IF(@ENCONTRADO > 0)
                     BEGIN
                         SELECT IDFACTURA AS INSERTADO, 
                                'La factura '+SERIE+'-'+FOLIO+' se ha registrado correctamente con el id '+IDFACTURA AS MSG
                         FROM FI_Factura
                         WHERE UUID = @UUID;
                     END;
                     ELSE
                     BEGIN
                         IF(@IdContrato = 0)
                             BEGIN
                                 SET @IdContrato = NULL
                             END
                         INSERT INTO [dbo].[FI_Factura]
                         ([Serie], 
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
                          [ArchivoPDF], 
                          [ArchivoXML], 
                          [CreadoPor], 
                          [CreadoEn], 
                          [ModificadoPor], 
                          [ModificadoEn], 
                          [ProcesadoSIPAC], 
                          [RegimenFiscal], 
                          [UsoCFDI], 
                          [VersionCFDI], 
                          [TotalImpuestosTrasladados], 
                          [TotalImpuestosRetenidos]
                         )
                         VALUES
                         (@Serie, 
                          @Folio, 
                          @Fecha, 
                          @Sello, 
                          @FormaPago, 
                          @NoCertificado, 
                          @Certificado, 
                          @CondicionesDePago, 
                          @SubTotal, 
                          @Descuento, 
                          @TipoCambio, 
                          @Moneda, 
                          @MontoConIva, 
                          @TipoComprobante, 
                          @MetodoPago, 
                          @LugarExpedicion, 
                          @NumCtaPago, 
                          @Emisor, 
                          @Receptor, 
                          @UUID, 
                          @FechaTimbrado, 
                          @SelloCFD, 
                          @NoCertificadoSAT, 
                          @SelloSAT, 
                          @Tipo, 
                          @FechaRecepcion, 
                          @IdSubcontratista, 
                          @IdMoneda, 
                          @IdContrato, 
                          @XML, 
                          @Activa, 
                          @ArchivoPDF, 
                          @ArchivoXML, 
                          @IdUsuario, 
                          CURRENT_TIMESTAMP, 
                          @IdUsuario, 
                          CURRENT_TIMESTAMP, 
                          0, 
                          @RegimenFiscal, 
                          @UsoCFDI, 
                          @VersionCFDI, 
                          @TotalImpuestosTrasladados, 
                          @TotalImpuestosRetenidos
                         );
                         SELECT CAST(@@IDENTITY AS NVARCHAR) AS INSERTADO, 
                                'La factura '+@Serie+'-'+@Folio+' se ha registrado correctamente con el id '+CAST(@@IDENTITY AS NVARCHAR) AS MSG;
                     END;
             END;
             ELSE
             BEGIN
                 IF(@IdContrato = 0)
                     BEGIN
                         SET @IdContrato = NULL
                     END
                 INSERT INTO [dbo].[FI_Factura]
                 ([Serie], 
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
                  [ArchivoPDF], 
                  [ArchivoXML], 
                  [CreadoPor], 
                  [CreadoEn], 
                  [ModificadoPor], 
                  [ModificadoEn], 
                  [ProcesadoSIPAC], 
                  [RegimenFiscal], 
                  [UsoCFDI], 
                  [VersionCFDI], 
                  [TotalImpuestosTrasladados], 
                  [TotalImpuestosRetenidos]
                 )
                 VALUES
                 (@Serie, 
                  @Folio, 
                  @Fecha, 
                  @Sello, 
                  @FormaPago, 
                  @NoCertificado, 
                  @Certificado, 
                  @CondicionesDePago, 
                  @SubTotal, 
                  @Descuento, 
                  @TipoCambio, 
                  @Moneda, 
                  @MontoConIva, 
                  @TipoComprobante, 
                  @MetodoPago, 
                  @LugarExpedicion, 
                  @NumCtaPago, 
                  @Emisor, 
                  @Receptor, 
                  @UUID, 
                  @FechaTimbrado, 
                  @SelloCFD, 
                  @NoCertificadoSAT, 
                  @SelloSAT, 
                  @Tipo, 
                  @FechaRecepcion, 
                  @IdSubcontratista, 
                  @IdMoneda, 
                  @IdContrato, 
                  @XML, 
                  @Activa, 
                  @ArchivoPDF, 
                  @ArchivoXML, 
                  @IdUsuario, 
                  CURRENT_TIMESTAMP, 
                  @IdUsuario, 
                  CURRENT_TIMESTAMP, 
                  0, 
                  @RegimenFiscal, 
                  @UsoCFDI, 
                  @VersionCFDI, 
                  @TotalImpuestosTrasladados, 
                  @TotalImpuestosRetenidos
                 );
                 SELECT CAST(@@IDENTITY AS NVARCHAR) AS INSERTADO, 
                        'La factura Serie- '+@Serie+' Folio- '+@Folio+' UUID- '+@UUID+' se ha registrado correctamente con el id '+CAST(@@IDENTITY AS NVARCHAR) AS MSG;
             END;
     END;