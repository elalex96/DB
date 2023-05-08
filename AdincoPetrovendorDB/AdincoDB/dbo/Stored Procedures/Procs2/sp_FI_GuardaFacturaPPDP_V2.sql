-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Guarda las facturas PPD o P para realizar la busqueda de los ppd y complementos de pago para el reporte de CGI
-- Author:		Manuel Cruz
-- Create date: 27-09-2019
-- Description:	Actualiza las transferencias relacionandola con el Complemento de Pago que se identifica al momento de la carga.
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_GuardaFacturaPPDP_V2] --3,10061,66739
@idContrato INT, 
@idUsuario  INT, 
@idFactura  INT
AS
     BEGIN
         DECLARE @TipoComprobante NVARCHAR(150), @MetodoPago NVARCHAR(150), @MesPresentacionCGI DATE, @error NVARCHAR(MAX)= '';
         SELECT --f.IdFactura,
         @TipoComprobante = CASE
                                WHEN f.TipoComprobante LIKE '%ingreso%'
                                     OR f.TipoComprobante LIKE 'I%'
                                THEN 'I'
                                WHEN(f.TipoComprobante) LIKE '%egreso%'
                                    OR f.TipoComprobante LIKE 'E%'
                                THEN 'E'
                                WHEN(f.TipoComprobante) LIKE '%traslado%'
                                    OR f.TipoComprobante LIKE 'T%'
                                THEN 'T'
                                WHEN(f.TipoComprobante) LIKE '%nómina%'
                                    OR f.TipoComprobante LIKE 'N%'
                                THEN 'N'
                                WHEN(f.TipoComprobante) LIKE '%pago%'
                                    OR f.TipoComprobante LIKE 'P%'
                                THEN 'P'
                                ELSE 'NA'
                            END, 
         @MetodoPago = CASE
                           WHEN f.MetodoPago LIKE '%exhibi%'
                                OR f.MetodoPago LIKE '%PUE%'
                                OR f.FormaPago LIKE '%exhibi%'
                                OR f.FormaPago LIKE '%PUE%'
                           THEN 'PUE'
                           WHEN f.MetodoPago LIKE '%parcia%'
                                OR f.MetodoPago LIKE '%dife%'
                                OR f.MetodoPago LIKE '%PPD%'
                                OR f.FormaPago LIKE '%parcia%'
                                OR f.FormaPago LIKE '%dife%'
                                OR f.FormaPago LIKE '%PPD%'
                           THEN 'PPD'
                       END, 
         @MesPresentacionCGI = c.MesPresentacionCGI
         FROM dbo.FI_Factura f
              JOIN dbo.CO_Contrato c ON f.IdContrato = c.IdContrato
         WHERE f.IdFactura = @idFactura
               AND f.IdContrato = @idContrato;
         IF(@TipoComprobante = 'P')
             BEGIN
                 -- Identificar las facturas principales PPD relacionadas a los complementos con la tabla anterior
                 -- DROP TABLE #FacturasPrincipales; DROP TABLE #TransferenciaCP;
                 CREATE TABLE #FacturasPrincipales
                 (IdFacturaPPD INT, 
                  UUID         NVARCHAR(300), 
                  IdFacturaCP  INT
                 );
                 --
                 INSERT INTO #FacturasPrincipales
                 (IdFacturaPPD, 
                  UUID, 
                  IdFacturaCP
                 )
                        SELECT F.IdFactura, 
                               F.UUID, 
                               CP.IdFactura
                        FROM dbo.FI_ComplementoDePago CP
                             JOIN dbo.FI_CPDocRelacionado CPDR ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
                             JOIN dbo.FI_Factura F ON CPDR.IdDocumento = F.UUID
                        WHERE CP.IdFactura = @idFactura;
                 -- Identificar las transferencias relacionadas directamente con las facturas PPD de la tabla anterior, para posteriormente eliminarla, se creo una tabla para guardar respaldo de las relaciones
                 INSERT INTO dbo.FI_TransferFacturaPPD
                 (IdTransfer, 
                  IdFactura, 
                  MontoPagado, 
                  CvTipoDocFacturacion, 
                  CreadoPor, 
                  CreadoEn, 
                  ModificadoPor, 
                  ModificadoEn
                 )
                        SELECT IdTransfer, 
                               IdFactura, 
                               MontoPagado, 
                               CvTipoDocFacturacion, 
                               CreadoPor, 
                               CreadoEn, 
                               @idUsuario, 
                               GETDATE()
                        FROM dbo.FI_TransferFactura TF
                             JOIN #FacturasPrincipales FP ON TF.IdFactura = FP.IdFacturaPPD;
                 -- Eliomiar relacion existente entre la factura principal PPD y la transferencia
                 CREATE TABLE #TransferenciaCP
                 (IdTransfer INT
                 );
                 --
                 INSERT INTO #TransferenciaCP(IdTransfer)
                        SELECT DISTINCT 
                               TFPPD.IdTransfer
                        FROM dbo.FI_TransferFacturaPPD TFPPD
                             JOIN #FacturasPrincipales FP ON TFPPD.IdFactura = FP.IdFacturaPPD
                        WHERE FP.IdFacturaCP = @idFactura;
                 -- Eliminar
                 DELETE dbo.FI_TransferFactura
                 WHERE IdTransfer IN
                 (
                     SELECT IdTransfer
                     FROM #TransferenciaCP
                 );
                 -- Actualizar en FI_Transfer IdFormaPago = 2 ya que indica que el metodo de pago es PPD
                 UPDATE dbo.FI_Transfer
                   SET 
                       IdFormaPago = 2
                 WHERE IdTransferencia IN
                 (
                     SELECT IdTransfer
                     FROM #TransferenciaCP
                 );
                 -- Insertar la nueva relacion del complemento de pago con la transferencia.
                 INSERT INTO dbo.FI_TransferFactura
                 (IdTransfer, 
                  IdFactura, 
                  MontoPagado, 
                  CvTipoDocFacturacion, 
                  CreadoPor, 
                  CreadoEn
                 )
                        SELECT DISTINCT 
                               TFPPD.IdTransfer, 
                               FP.IdFacturaCP, 
                               0, 
                               6, 
                               @idUsuario, 
                               GETDATE()
                        FROM #FacturasPrincipales FP
                             JOIN dbo.FI_TransferFacturaPPD TFPPD ON FP.IdFacturaPPD = TFPPD.IdFactura
                        WHERE FP.IdFacturaCP = @idFactura;
             END;
         IF @@ERROR <> 0
             BEGIN
                 SET @error = 'Inconveniente encontrado en el sp: sp_FI_GuardaFacturaPPDP, CodigoError: '+CAST(@@ERROR AS NVARCHAR(8));
             END;
         SELECT @error AS error;
     END;