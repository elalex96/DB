CREATE PROCEDURE [dbo].[sp_SIPAC_Procesar_IdPedimentoImportacion_V2]
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT
AS
     BEGIN

         -- =============================================
         -- Author: Manuel Cruz
         -- Create date: 07-04-17
         -- Description:  
         -- =============================================
         -- Modificado:		  Marcos Garcia
         -- Fecha Modificado: 2020-01-23
         -- Description:	  *Agregar Validacion de @IdPresupuesto = 0
         --					  *Agregar WITH (NOLOCK) en las tablas 
         -- =============================================
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.

         SET NOCOUNT ON;

         -- PRIMERO CREAR LA TABLA TEMPORAL

         CREATE TABLE #PedimentoComprobante
         (IdPedimentoComprobante INT, 
          IdContrato             INT, 
          CvTipoDocFacturacion   INT, 
          SIPAC                  INT
         );
         INSERT INTO #PedimentoComprobante
                SELECT PC.IdPedimentoComprobante, 
                       PC.IdContrato, 
                       PC.CvTipoDocFacturacion, 
                       ROW_NUMBER() OVER(ORDER BY PC.FechaPago) AS SIPAC
                FROM FI_Transfer tr WITH(NOLOCK)
                     LEFT JOIN FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = tr.IdTransferencia
                     LEFT JOIN FI_PedimentoComprobante PC WITH(NOLOCK) ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
                     LEFT JOIN CO_Registro r WITH(NOLOCK) ON r.IdPedimentoComprobante = PC.IdPedimentoComprobante
                     LEFT JOIN CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes
                     LEFT JOIN CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto
                     LEFT JOIN Co_anioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = p.IdAnioContractual
                     LEFT JOIN co_contrato c WITH(NOLOCK) ON tr.IdContrato = c.IdContrato
                     LEFT JOIN co_contratista con WITH(NOLOCK) ON c.idcontratista = con.idcontratista
                     LEFT JOIN FI_Documento doc WITH(NOLOCK) ON PC.IdPedimentoComprobante = doc.IdPedimentoComprobante
                     LEFT JOIN PV_Subcontratista subi WITH(NOLOCK) ON PC.IdSubcontratistaImportador = subi.IdSubcontratista
                     LEFT JOIN PV_TipoMoneda tm WITH(NOLOCK) ON PC.IdMoneda = tm.IdMoneda
                     LEFT JOIN CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = tm.IdMoneda
                                                                       AND DAY(TCD.Fecha) = DAY(PC.FechaPago)
                                                                       AND MONTH(TCD.Fecha) = MONTH(PC.FechaPago)
                                                                       AND YEAR(TCD.Fecha) = YEAR(PC.FechaPago)
                     LEFT JOIN PV_Subcontratista sube WITH(NOLOCK) ON PC.IdSubcontratistaExportador = sube.IdSubcontratista
                     LEFT JOIN FI_PedimentoComprobanteDetalle pcd WITH(NOLOCK) ON PC.IdPedimentoComprobante = pcd.IdPedimentoComprobante
                     LEFT JOIN pv_unidad u WITH(NOLOCK) ON pcd.IdUnidadMedida = u.idunidad
                     LEFT JOIN fi_estudiopreciostransfer ept WITH(NOLOCK) ON PC.IdEstudioPrecioTransfer = ept.IdEstudioPrecioTransfer
                     LEFT JOIN CO_RelacionEmpresas RE WITH(NOLOCK) ON RE.idcontratista = con.idproveedor
                                                                      AND PC.IdSubcontratistaImportador = RE.IdRelacionada
                WHERE PC.CvTipoDocFacturacion = 2
                      AND c.IdContrato = @Contrato
                      AND DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1) = @Mes
                      AND r.IdEstado = 10004
                      AND ISNULL(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0
                      AND p.IdPresupuesto = CASE
                                                WHEN @IdPresupuesto = 0
                                                THEN lpm.IdPresupuesto
                                                ELSE @IdPresupuesto
                                            END
                --AND p.idpresupuesto = @IdPresupuesto

                GROUP BY PC.IdPedimentoComprobante, 
                         PC.IdContrato, 
                         PC.CvTipoDocFacturacion, 
                         PC.FechaPago;
         -- ACTUALIZAR IdDocFacturacionSIPAC EN LA TABLA Pedimento Comprobante
         UPDATE dbo.FI_PedimentoComprobante
           SET 
               IdDocFacturacionSIPAC = CONCAT('PI', '-', LEFT('0'+CAST(MONTH(@Mes) AS VARCHAR(2)), 2)+CAST(YEAR(@Mes) AS CHAR(4)), '-', RIGHT('000000'+CAST(PCT.SIPAC AS VARCHAR(6)), 6))
         FROM FI_PedimentoComprobante PC
              JOIN #PedimentoComprobante PCT ON PC.IdPedimentoComprobante = PCT.IdPedimentoComprobante
         WHERE PC.IdPedimentoComprobante = PCT.IdPedimentoComprobante;
         --EXEC sp_SIPAC_Procesar_IdPedimentoImportacion_V2 3,'2017-03-01',3

     END;
