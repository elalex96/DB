
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 22/03/2018
-- Description: Validacion para eliminar la factura en mercadeo
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 05/07/2019
-- Description: se agrego y cambio la funcionalidad de la eliminacion de la compra directa
-- =============================================
-- =============================================
-- Author:  Daniel AC
-- Create date: 27-09-2019
-- Description: Agregue un respaldo de los anexos eliminados para no modificar la lógica del código
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ValidarEliminadoFacturaCompraDirecta] --10517,420,2199,3,'Prueba'
	-- Add the parameters for the stored procedure here
	@IdPedido INT,
	@IdProveedor INT,
	@IdUsuario INT,
	@IdContrato INT,
	@Comentario NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--DATOS DE LA FACTURA
	DECLARE @IDREGISTRO INT = (SELECT IdRegistro FROM dbo.MM_Pedidos WHERE IdPedido = @IdPedido AND IdTipoPedido = 1 AND IdProveedorCliente = @IdProveedor);
	DECLARE @IFACTURAP INT = (SELECT TOP 1 IdIdentificador FROM dbo.MM_Pedidos WHERE IdPedido = @IdPedido AND IdTipoPedido = 1 AND IdProveedorCliente = @IdProveedor);
	DECLARE @UUID NVARCHAR(50) = (SELECT TOP 1 UUID FROM dbo.FI_Factura WHERE IdFactura = @IFACTURAP);
	DECLARE @IDFACTURAA INT = (SELECT TOP 1 IdFactura FROM Adinco.dbo.FI_Factura WHERE UUID = @UUID);

	--DATOS DE LA ELIMINACION DE LA FACTURA
	DECLARE @COMENTARIOINTERNO NVARCHAR(MAX) = ('ELIMINACION OCD');
	DECLARE @TIPOELIMINACION NVARCHAR(10) = ('OCD-F');

	/*RESPLADO DE LA FACTURA*/
	INSERT INTO dbo.AD_RegistroEliminacion
    (
		IdUsuario,
        FechaRegistro,
        ComentarioExterno,
        ComentarioInterno,
        TipoEliminacion,
        Activo,
        IdProveedor,
        IdContrato,
        IdProceso,
        Confirmacion
     )
     VALUES
     (   
		@IDUSUARIO,          -- IdUsuario - int
        GETDATE(),   -- FechaRegistro - dateti
        @Comentario, -- ComentarioExterno - nvarchar(max)
        @COMENTARIOINTERNO, -- ComentarioInterno - nvarchar(max)
        @TIPOELIMINACION,               -- TipoEliminacion - nvarchar(100)
        1, -- Activo - bit
        @IdProveedor, -- IdProveedor -- int
        @IdContrato, -- IdContrato -- int 
        @IdPedido, -- IdProceso --int
        1  --Confirmacion bit
      );

	  DECLARE @IDELIMINACION INT = (SELECT SCOPE_IDENTITY());

	  INSERT INTO dbo.PR_FI_CFDIConceptoImpuesto
				(
				    IdFacturaConcepto,
				    IdTipoImpuesto,
				    NombreImpuesto,
				    Base,
				    Impuesto,
				    TipoFactor,
				    Tasa,
				    Importe,
					IdEliminacion
				)
				SELECT IdFacturaConcepto,
                       IdTipoImpuesto,
                       NombreImpuesto,
                       Base,
                       Impuesto,
                       TipoFactor,
                       Tasa,
                       Importe,
                       @IDELIMINACION
                FROM Adinco.dbo.FI_CFDIConceptoImpuesto
                WHERE IdFacturaConcepto IN (
                                       SELECT CF.IdFacturaConcepto
										FROM Adinco.dbo.FI_CFDIConcepto AS CF
										WHERE CF.IdFactura = @IDFACTURAA
                                   );

                DELETE Adinco.dbo.FI_CFDIConceptoImpuesto
                WHERE IdFacturaConcepto IN (
                                       SELECT CF.IdFacturaConcepto
										FROM Adinco.dbo.FI_CFDIConcepto AS CF
										WHERE CF.IdFactura = @IDFACTURAA
                                   );

                INSERT INTO dbo.PR_FI_CFDIConcepto
                (
                    IdFacturaConcepto,
                    IdFactura,
                    ClaveProdServ,
                    Cantidad,
                    ClaveUnidad,
                    Unidad,
                    Descripcion,
                    ValorUnitario,
                    Importe,
                    NoIdentificacion,
                    IdEliminacion
                )
                SELECT IdFacturaConcepto,
                       IdFactura,
                       ClaveProdServ,
                       Cantidad,
                       ClaveUnidad,
                       Unidad,
                       Descripcion,
                       ValorUnitario,
                       Importe,
                       NoIdentificacion,
                       @IDELIMINACION
                FROM Adinco.dbo.FI_CFDIConcepto
                WHERE IdFactura IN (@IDFACTURAA);

                DELETE Adinco.dbo.FI_CFDIConcepto
                WHERE IdFactura IN (@IDFACTURAA);

                INSERT INTO dbo.PR_FI_CFDIImpuesto
                (
                    IdCFDIImpuesto,
                    IdFactura,
                    IdTipoImpuesto,
                    Impuesto,
                    TipoFactor,
                    Tasa,
                    Importe,
                    IdEliminacion
                )
                SELECT IdCFDIImpuesto,
                       IdFactura,
                       IdTipoImpuesto,
                       Impuesto,
                       TipoFactor,
                       Tasa,
                       Importe,
                       @IDELIMINACION
                FROM Adinco.dbo.FI_CFDIImpuesto
                WHERE IdFactura IN (@IDFACTURAA);

                DELETE Adinco.dbo.FI_CFDIImpuesto
                WHERE IdFactura IN (@IDFACTURAA);

                INSERT INTO dbo.PR_FI_Documento
                (
                    IdDocumento,
                    Documento,
                    IdTipoDocumento,
                    IdFactura,
                    IdPedimentoComprobante,
                    IdDocFacturacionSIPAC,
                    NombreExtensionArchivo,
                    IdUsuario,
                    FechaCarga,
                    IsEliminado,
                    DocumentoByte,
                    IdEliminacion
                )
                SELECT IdDocumento,
                       Documento,
                       IdTipoDocumento,
                       IdFactura,
                       IdPedimentoComprobante,
                       IdDocFacturacionSIPAC,
                       NombreExtensionArchivo,
                       IdUsuario,
                       FechaCarga,
                       IsEliminado,
                       DocumentoByte,
                       @IDELIMINACION
                FROM Adinco.dbo.FI_Documento
                WHERE IdFactura IN (
                                       @IDFACTURAA
                                   )
                      AND IdTipoDocumento = 1; --> ES TIPO FACTURA --> FI_TipoDocumento 
                DELETE Adinco.dbo.FI_Documento
                WHERE IdFactura IN (
                                       @IDFACTURAA
                                   )
                      AND IdTipoDocumento = 1; --> ES TIPO FACTURA --> FI_TipoDocumento

                /*PROCESO DE ELIMINACIÓN EN ADINCO RESPALDO DE LOS ELIMINADO EN TABLAS PR(PAPELERA RECICLAJE) DE PETROVENDOR Y LUEGO ELIMINACION FISICA*/
				INSERT INTO dbo.PR_FI_ArchivoXml
				(
				    ArchivoXml,
				    HashSHA256,
				    IdFactura,
				    IdContrato,
				    CreadoPor,
				    CreadoEl,
				    ModificadoPor,
				    ModificadoEl,
				    Activo,
				    IdEliminacion
				)
				SELECT
					ArchivoXml,
					HashSHA256,
					IdFactura,
					IdContrato,
					CreadoPor,
					CreadoEl,
					ModificadoPor,
					ModificadoEl,
					Activo,
					@IDELIMINACION
				FROM Adinco.dbo.FI_ArchivoXml
				WHERE IdFactura IN (
                                       @IDFACTURAA
                                   );
                DELETE Adinco.dbo.FI_ArchivoXml
                WHERE IdFactura IN (
                                       @IDFACTURAA
                                   );

				--ELIMINACION DE GASTOS DE ADINCO

				DELETE Adinco.dbo.CO_Registro
				WHERE IdFactura IN (
                                       @IDFACTURAA
                                   );

				DELETE Adinco.dbo.FI_Transfer
				WHERE IdFacturaPago IN (
                                       @IDFACTURAA
                                   );

				DELETE Adinco.dbo.FI_TransferFactura
				WHERE IdFactura IN (
                                       @IDFACTURAA
                                   ); 

                INSERT INTO dbo.PR_FI_Factura
                (
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
                    --PDF,
                    --IdReceptor,
                    --IdentificadorSIPAC,
                    NombreXML,
                    IdEstudioPrecioTransfer,
                    IdDocFacturacionSIPAC,
                    ProcesadoSIPAC,
                    --ClaveFormaPago,
                    RegimenFiscal,
                    UsoCFDI,
                    VersionCFDI,
                    --HashSHA256,
                    --UUIDRelacionado,
                    --TipoRelacion,
                    --NoParcialidad,
                    IdEliminacion
                )
                SELECT IdFactura,
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
                       --PDF,
                       --IdReceptor,
                       --IdentificadorSIPAC,
                       NombreXML,
                       IdEstudioPrecioTransfer,
                       IdDocFacturacionSIPAC,
                       ProcesadoSIPAC,
                       --ClaveFormaPago,
                       RegimenFiscal,
                       UsoCFDI,
                       VersionCFDI,
                       --HashSHA256,
                       --UUIDRelacionado,
                       --TipoRelacion,
                       --NoParcialidad,
                       @IDELIMINACION
                FROM Adinco.dbo.FI_Factura
                WHERE IdFactura IN (
                                       @IDFACTURAA
                                   );
                DELETE Adinco.dbo.FI_Factura
                WHERE IdFactura IN (
                                       @IDFACTURAA
                                   );

				DELETE dbo.CO_RelacionRegistroAdinco
				WHERE IdRegistroPetrovendor = (SELECT IdRegistro FROM dbo.CO_Registro WHERE IdFactura = @IFACTURAP);

				DELETE Adinco.dbo.CO_Registro
				WHERE IdFactura = @IDFACTURAA;

				DELETE dbo.CO_Registro
				WHERE IdFactura = @IFACTURAP;

DELETE Adinco.dbo.FI_FacturaAdincoPetrovendor WHERE IdFacturaPetrovendor = @IFACTURAP

INSERT INTO dbo.Pv_DocSoporte_CompraDirecta_Eliminados
(id,idFactura,documento,nombreArchivo,Carpeta,Identificador,Extension,Mime, AMS3,EliminadoS3,isEliminado)

SELECT id,idFactura,'',nombreArchivo,Carpeta,Identificador,Extension,Mime, AMS3,EliminadoS3,isEliminado 
FROM  Pv_DocSoporte_CompraDirecta  
WHERE idFactura = @IFACTURAP

DELETE  dbo.Pv_DocSoporte_CompraDirecta WHERE idFactura = @IFACTURAP

DELETE dbo.FI_CFDIConcepto WHERE IdFactura = @IFACTURAP;

DELETE dbo.FI_CFDIImpuesto WHERE IdFactura = @IFACTURAP;

DELETE dbo.FI_Documento WHERE IdFactura = @IFACTURAP AND IdTipoDocumento = 1; --> ES TIPO FACTURA --> FI_TipoDocumento

DELETE dbo.FI_RelacionArchivoXMLAdinco WHERE IdArchivoXML IN (SELECT IdArchivoXml FROM dbo.FI_ArchivoXml WHERE IdFactura = @IFACTURAP)

DELETE dbo.FI_ArchivoXml WHERE IdFactura = @IFACTURAP;

DELETE dbo.FI_Factura WHERE IdFactura = @IFACTURAP;

DELETE dbo.TA_ComentariosTareaCancelada WHERE IdOperacion IN (SELECT IdOperacion FROM dbo.TA_Operacion WHERE IdDocumento = @IFACTURAP AND IdTipoOperacion = 14);

DELETE dbo.TA_TareaOperacion WHERE IdOperacion IN (SELECT IdOperacion FROM dbo.TA_Operacion WHERE IdDocumento = @IFACTURAP AND IdTipoOperacion = 14);

DELETE dbo.TA_Operacion WHERE IdDocumento = @IFACTURAP AND IdTipoOperacion = 14;

DELETE dbo.MM_Pedidos WHERE IdRegistro = @IDREGISTRO;

SELECT 
	IdEliminacion,
	IdUsuario,
	IdProveedor,
	IdContrato,
	IdProceso
FROM dbo.AD_RegistroEliminacion 
WHERE IdEliminacion = @IDELIMINACION

END

