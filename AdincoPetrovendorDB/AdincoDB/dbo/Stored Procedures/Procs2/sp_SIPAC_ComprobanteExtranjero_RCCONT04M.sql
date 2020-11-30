CREATE PROCEDURE [dbo].[sp_SIPAC_ComprobanteExtranjero_RCCONT04M]
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT
AS
     BEGIN

         -- =============================================
         -- Author: Manuel Cruz
         -- Create date:  2017-03-29
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

         /**/

         EXEC sp_SIPAC_Procesar_IdPreciosTransfer_V2 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;
         EXEC sp_SIPAC_Procesar_IdComprobanteExtranjero_V2 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;

         /**/

         SELECT con.IdSipac, 
                c.IdRegFiducidiario, 
                CONVERT(VARCHAR(10), (DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1)), 103) AS PeriodoReporte, 
                PC.IdDocFacturacionSIPAC AS IdentificadorDocumentoFacturacion, 
                REPLACE(PC.IdDocFacturacionSIPAC, '-', '_')+'.pdf' AS NombreExtensionArchivo,
                CASE
                    WHEN ISNULL(RE.IDRelacionada, 2) <> 2
                    THEN 1
                    ELSE 2
                END AS TipoOperacion, 
                PC.FolioComprobante, 
                CONVERT(CHAR(10), PC.FechaPago, 103) AS FechaFacturacion, 
                subi.RFC, 
                subi.RazonSocial, 
                subi.NombreVialidad AS Calle, 
                subi.NumExterior, 
                subi.NumInterior, 
                subi.Municipio, 
                subi.Entidad, 
                ISNULL(subi.Pais, '-') AS Pais, 
                pcd.Cantidad, 
                u.Unidad, 
                pcd.NumeroSerieMercancia, 
                pcd.ClaseBienServicio, 
                CAST(ROUND(pcd.PrecioUnitario, 2) AS DECIMAL(15, 2)) AS PrecioUnitarioAntesImpuesto, 
                CAST(ROUND((pcd.PrecioUnitario * pcd.Cantidad), 2) AS DECIMAL(15, 2)) AS ImporteTotalAntesImpuesto, 
                li.IdClave AS FormaPago, 
                tm.TipoMonedaCorto AS MonedaFuncional,
                CASE
                    WHEN ISNULL(tr.MontoPagado, 0) <> 0
                    THEN CAST(ROUND((ISNULL(tr.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                    ELSE 0
                END AS MontoEquivalenteUSD, 
                CAST(ROUND(TCD.tipocambio, 4) AS DECIMAL(7, 4)) AS TipoCambioUSD,
                CASE
                    WHEN ISNULL(r.MontoRegistro, 0) <> 0
                    THEN CAST(ROUND((ISNULL(r.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                    ELSE 0
                END AS 'MontoUSD Recuperacion Costo',
                CASE tr.IdMetodoPago
                    WHEN 6
                    THEN 1
                    ELSE 0
                END AS Efectivo,
                CASE tr.IdMetodoPago
                    WHEN 4
                    THEN 1
                    ELSE 0
                END AS TransferenciaElectronica,
                CASE tr.IdMetodoPago
                    WHEN 1
                    THEN 1
                    ELSE 0
                END AS Cheque,
                CASE tr.IdMetodoPago
                    WHEN 2
                    THEN 1
                    ELSE 0
                END AS TarjetaCredito,
                CASE tr.IdMetodoPago
                    WHEN 3
                    THEN 1
                    ELSE 0
                END AS TarjetaDevito,
                CASE tr.IdMetodoPago
                    WHEN 5
                    THEN 1
                    ELSE 0
                END AS TarjetaServicio, 
                ISNULL(ept.IdDocFacturacionSIPAC, 'NA') AS EstudioPrecioTransferencia, 
                2 AS IdClasificacionDocumento
         --INTO #Comprobantes
         FROM FI_Transfer tr WITH(NOLOCK)
              LEFT JOIN FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = tr.IdTransferencia
              LEFT JOIN FI_PedimentoComprobante PC WITH(NOLOCK) ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
              LEFT JOIN CO_Registro r WITH(NOLOCK) ON r.IdPedimentoComprobante = PC.IdPedimentoComprobante
              LEFT JOIN CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes
              LEFT JOIN CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto
              LEFT JOIN Co_anioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = p.IdAnioContractual
              LEFT JOIN co_contrato c WITH(NOLOCK) ON AC.IdContrato = c.IdContrato
              LEFT JOIN co_contratista con WITH(NOLOCK) ON c.idcontratista = con.idcontratista
              LEFT JOIN FI_Documento doc WITH(NOLOCK) ON PC.IdPedimentoComprobante = doc.IdPedimentoComprobante
              LEFT JOIN PV_Subcontratista subi WITH(NOLOCK) ON PC.IdSubcontratistaExportador = subi.IdSubcontratista
              LEFT JOIN PV_TipoMoneda tm WITH(NOLOCK) ON PC.IdMoneda = tm.IdMoneda
              LEFT JOIN CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = tm.IdMoneda
                                                                AND DAY(TCD.Fecha) = DAY(PC.FechaPago)
                                                                AND MONTH(TCD.Fecha) = MONTH(PC.FechaPago)
                                                                AND YEAR(TCD.Fecha) = YEAR(PC.FechaPago)
              LEFT JOIN FI_PedimentoComprobanteDetalle pcd WITH(NOLOCK) ON PC.IdPedimentoComprobante = pcd.IdPedimentoComprobante
              LEFT JOIN dbo.PV_MM_MaterialUnidad u WITH(NOLOCK) ON pcd.IdUnidadMedida = u.IdUnidad
              LEFT JOIN ap_lista li WITH(NOLOCK) ON PC.IdFormaPago = li.idclave
              LEFT JOIN fi_estudiopreciostransfer ept WITH(NOLOCK) ON PC.IdEstudioPrecioTransfer = ept.IdEstudioPrecioTransfer
              LEFT JOIN CO_RelacionEmpresas RE WITH(NOLOCK) ON RE.idcontratista = con.Idcontratista
                                                               AND PC.IdSubcontratistaExportador = RE.IdRelacionada
         WHERE PC.CvTipoDocFacturacion = 3
               AND c.IdContrato = @Contrato --10005
               AND DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1) = @Mes --'20180401'
               AND r.IdEstado = 10004
               AND ISNULL(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0
               AND p.IdPresupuesto = CASE
                                         WHEN @IdPresupuesto = 0
                                         THEN lpm.IdPresupuesto
                                         ELSE @IdPresupuesto
                                     END
               --AND p.idpresupuesto = @IdPresupuesto

               AND li.IdGrupo = 10001
         GROUP BY con.IdSipac, 
                  c.IdRegFiducidiario, 
                  CONVERT(VARCHAR(10), (DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1)), 103), 
                  PC.IdDocFacturacionSIPAC, 
                  doc.NombreExtensionArchivo, 
                  PC.FechaPago, 
                  subi.RFC, 
                  subi.RazonSocial, 
                  subi.NombreVialidad, 
                  subi.NumExterior, 
                  subi.NumInterior, 
                  subi.Municipio, 
                  subi.Entidad, 
                  subi.Pais, 
                  pcd.Cantidad, 
                  pcd.PrecioUnitario, 
                  u.Unidad, 
                  pcd.NumeroSerieMercancia, 
                  pcd.ClaseBienServicio, 
                  li.idclave, 
                  tm.TipoMonedaCorto,
                  CASE
                      WHEN ISNULL(tr.MontoPagado, 0) <> 0
                      THEN CAST(ROUND((ISNULL(tr.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                      ELSE 0
                  END, 
                  CAST(ROUND(TCD.tipocambio, 4) AS DECIMAL(7, 4)),
                  CASE
                      WHEN ISNULL(r.MontoRegistro, 0) <> 0
                      THEN CAST(ROUND((ISNULL(r.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                      ELSE 0
                  END, 
                  PC.FolioComprobante, 
                  ept.IdDocFacturacionSIPAC, 
                  ept.IdClasificacionDocumento, 
                  RE.IDRelacionada, 
                  tr.IdMetodoPago;

         /*Temporal para agrupar por linea de presupuesto mes por montos diferentes de gasto*/
/*SELECT IdSipac,
                    IdRegFiducidiario,
                    PeriodoReporte,
                    IdentificadorDocumentoFacturacion,
                    NombreExtensionArchivo,
                    TipoOperacion,
                    FolioComprobante,
                    FechaFacturacion,
                    RFC,
                    RazonSocial,
                    Calle,
                    NumExterior,
                    NumInterior,
                    Municipio,
                    Entidad,
                    Pais,
                    Cantidad,
                    Unidad,
                    NumeroSerieMercancia,
                    ClaseBienServicio,
                    PrecioUnitarioAntesImpuesto,
                    ImporteTotalAntesImpuesto,
                    FormaPago,
                    MonedaFuncional,
                    MontoEquivalenteUSD,
                    TipoCambioUSD,
                    SUM([MontoUSD Recuperacion Costo]),
                    Efectivo,
                    TransferenciaElectronica,
                    Cheque,
                    TarjetaCredito,
                    TarjetaDevito,
                    TarjetaServicio,
                    EstudioPrecioTransferencia,
                    IdClasificacionDocumento
             FROM #Comprobantes
             GROUP BY IdSipac,
                      IdRegFiducidiario,
                      PeriodoReporte,
                      IdentificadorDocumentoFacturacion,
                      NombreExtensionArchivo,
                      TipoOperacion,
                      FolioComprobante,
                      FechaFacturacion,
                      RFC,
                      RazonSocial,
                      Calle,
                      NumExterior,
                      NumInterior,
                      Municipio,
                      Entidad,
                      Pais,
                      Cantidad,
                      Unidad,
                      NumeroSerieMercancia,
                      ClaseBienServicio,
                      PrecioUnitarioAntesImpuesto,
                      ImporteTotalAntesImpuesto,
                      FormaPago,
                      MonedaFuncional,
                      MontoEquivalenteUSD,
                      TipoCambioUSD,
                      --[MontoUSD Recuperacion Costo],
                      Efectivo,
                      TransferenciaElectronica,
                      Cheque,
                      TarjetaCredito,
                      TarjetaDevito,
                      TarjetaServicio,
                      EstudioPrecioTransferencia,
                      IdClasificacionDocumento;*/

         --EXEC sp_SIPAC_ComprobanteExtranjero_RCCONT04M 10005,'2018-04-01',10036

     END;
