-- =============================================
-- Author:		Manuel Cruz
-- Create date: 07-06-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_SIPAC_ListaArchivosReporteGastosExtranjero]
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         CREATE TABLE #Documentos
         (Nombre NVARCHAR(MAX), 
          Doc    IMAGE
         );
         -- Insert statements for procedure here

         INSERT INTO #Documentos
         (Nombre, 
          Doc
         )
                SELECT REPLACE(PC.IdDocFacturacionSIPAC, '-', '_')+'.pdf', 
                       doc.DocumentoByte
                FROM fi_transfer tr
                     LEFT JOIN FI_transferfactura TF ON TF.IdTransfer = TR.IdTransferencia
                     LEFT JOIN FI_PedimentoComprobante PC ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
                     LEFT JOIN co_registro r ON r.IdPedimentoComprobante = PC.IdPedimentoComprobante
                     LEFT JOIN co_lineapresupuestomes lpm ON r.idprograma = lpm.idlineapresupuestomes
                     LEFT JOIN co_presupuesto p ON p.idpresupuesto = lpm.idpresupuesto
                     LEFT JOIN Co_anioContractual AC ON AC.idaniocontractual = p.idaniocontractual
                     LEFT JOIN co_contrato c ON tr.idcontrato = c.idcontrato
                     LEFT JOIN co_contratista con ON c.idcontratista = con.idcontratista
                     LEFT JOIN fi_documento doc ON pc.idpedimentocomprobante = doc.idpedimentocomprobante
                     LEFT JOIN pv_subcontratista subi ON pc.idsubcontratistaimportador = subi.idsubcontratista
                     LEFT JOIN pv_tipomoneda tm ON pc.idmoneda = tm.idmoneda
                     LEFT JOIN CO_TipoCambioDiario TCD ON TCD.IdMoneda = TM.IdMoneda
                                                          AND DAY(TCD.Fecha) = DAY(PC.FechaPago)
                                                          AND MONTH(TCD.Fecha) = MONTH(PC.FechaPago)
                                                          AND YEAR(TCD.Fecha) = YEAR(PC.FechaPago)
                     LEFT JOIN fi_pedimentocomprobantedetalle pcd ON pc.idpedimentocomprobante = pcd.idpedimentocomprobante
                     LEFT JOIN pv_unidad u ON pcd.idunidadmedida = u.idunidad
                     LEFT JOIN fi_estudiopreciostransfer ept ON pc.IdEstudioPrecioTransfer = ept.IdEstudioPrecioTransfer
                     LEFT JOIN CO_RelacionEmpresas RE ON RE.idcontratista = Con.idproveedor
                                                         AND PC.IdSubcontratistaImportador = RE.IdRelacionada
                WHERE PC.CvTipoDocFacturacion = 3
                      AND C.IdContrato = @Contrato
                      AND DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1) = @Mes
                      AND r.idestado = 10004
                      AND ISNULL(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0;
         --AND p.idpresupuesto = @IdPresupuesto;
         INSERT INTO #Documentos
         (Nombre, 
          Doc
         )
                SELECT REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_')+'.pdf', 
                       EPT.Archivo
                FROM fi_transfer tr(NOLOCK)
                     JOIN fi_transferfactura tf ON tr.idtransferencia = tf.idtransfer
                     JOIN FI_Factura F ON tf.IdFactura = F.IdFactura
                     JOIN co_registro r ON r.IdFactura = F.IdFactura
                     JOIN co_lineapresupuestomes lpm ON r.idprograma = lpm.idlineapresupuestomes
                     JOIN co_presupuesto p ON p.idpresupuesto = lpm.idpresupuesto
                     JOIN Co_anioContractual AC ON AC.idaniocontractual = p.idaniocontractual
                     JOIN co_contrato c ON AC.idcontrato = c.idcontrato
                     JOIN co_contratista con ON c.idcontratista = con.idcontratista
                     JOIN FI_EstudioPreciosTransfer EPT ON F.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
                WHERE C.IdContrato = @Contrato
                      AND R.IdEstado = 10004
                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
                      AND r.CvTipoDocFacturacion = 1
                      AND isnull(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                      --AND p.idpresupuesto = @IdPresupuesto
                      AND F.IdEstudioPrecioTransfer IS NOT NULL;
         INSERT INTO #Documentos
         (Nombre, 
          Doc
         )
                SELECT REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_')+'.pdf', 
                       EPT.Archivo
                FROM fi_transfer tr(NOLOCK)
                     JOIN fi_transferfactura tf ON tr.idtransferencia = tf.idtransfer
                     JOIN FI_PedimentoComprobante PC ON tf.IdPedimentoComprobante = PC.IdPedimentoComprobante
                     JOIN co_registro r ON r.IdPedimentoComprobante = pc.IdPedimentoComprobante
                     JOIN co_lineapresupuestomes lpm ON r.idprograma = lpm.idlineapresupuestomes
                     JOIN co_presupuesto p ON p.idpresupuesto = lpm.idpresupuesto
                     JOIN Co_anioContractual AC ON AC.idaniocontractual = p.idaniocontractual
                     JOIN co_contrato c ON AC.idcontrato = c.idcontrato
                     JOIN co_contratista con ON c.idcontratista = con.idcontratista
                     JOIN FI_EstudioPreciosTransfer EPT ON PC.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
                WHERE C.IdContrato = @Contrato
                      AND R.IdEstado = 10004
                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
                      AND r.CvTipoDocFacturacion IN(2, 3)
                     AND isnull(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0
                     --AND p.idpresupuesto = @IdPresupuesto
                     AND PC.IdEstudioPrecioTransfer IS NOT NULL;
         SELECT Nombre, 
                Doc
         FROM #Documentos
         WHERE Nombre IS NOT NULL;
     END;