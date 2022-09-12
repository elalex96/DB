USE [Adinco]
GO
-- =============================================      
-- Author:   Miguel      
-- Create date: Domingo 1 Diciembre 2016 19:49 p.m.      
-- Description: Reporte de Integración de Gastos a Nivel Actividad      
-- =============================================
-- Author:   Reyna 20211208 Issue 1663 
-- Se borra la linea de AND RRF.MesPresentacion = R.MesPresentacion  del JOIN FI_RelacionRefacturas Ya que no se mostraban las LUMS y se agrego nuevamente los JOINS 
-- para los comprobantes en el extranjero se muestran como LUMS
-- =============================================  
-- Author: Neri 20220727 Issue 2146 
-- Se ajusta columna R.Comentarios a R.Comentarios AS DescripcionPartidaServicio para que se pinte correctamente en el reporte.
-- =============================================  
-- Author:  Reyna Olvera    
-- Create date: 1 Septiembre 2022    
-- Description: Se agrega ajuste, cuando el gasto se encuentre relacionado a una nota de credito, se colocará como negativo
-- ============================================= 
-- Author:  Reyna Olvera    
-- Create date: 8 Septiembre 2022    
-- Description: Issue 2218 - Se agrega ajuste de mostrar las columnas solicitadas que realizan extracción de petrovendor con adinco [Ajuste
-- ,Descripción de la Partida ó servicio, Orden de Servicio/Orden Compra,Partida,Unidad,P.U. USD, P.U. MXN, Cantidad Real]
-- ============================================= 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CO_ReporteIntegracionGastosPorSubcontratistaAmatitlan]
    @Anio          INT = 0,
    @Mes           INT = 0,
    @IdPresupuesto INT = 0
AS
    BEGIN

        SET LANGUAGE spanish;

        SELECT
            UPPER(CONCAT(DATENAME(MONTH, R.MesPresentacion), ' ', YEAR(R.MesPresentacion))) AS FechaReporte,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN ISNULL(F.Serie, '') + ' ' + ISNULL(F.Folio, '')
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN PC.FolioComprobante
                ELSE
                    ''
            END                                                                             AS NumeroFactura,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN (CASE
                              WHEN (F.TipoComprobante) LIKE '%egreso%'
                                   OR F.TipoComprobante LIKE 'E%'
                                  THEN CASE
                                           WHEN ISNULL(R.Ajuste, '') = ''
                                               THEN R.Comentarios
                                           ELSE
                                               R.Ajuste
                                       END
                              ELSE
                                  ''
                          END
                         )
                ELSE
                    ''
            END                                                                             AS Comentarios,
            CASE
                WHEN ISNULL(MM.DescripcionLarga, '') = ''
                    THEN CASE
                             WHEN ISNULL(R.DescripcionPartidaServicio, '') = ''
                                 THEN ISNULL(R.Comentarios, '') COLLATE Modern_Spanish_CI_AS
                             ELSE
                                 ISNULL(R.DescripcionPartidaServicio, '') COLLATE Modern_Spanish_CI_AS
                         END
                ELSE
                    ISNULL(MM.DescripcionLarga, '') COLLATE Modern_Spanish_CI_AS
            END                                                                             AS DescripcionPartidaServicio,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN F.Fecha
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN PC.FechaPago
                ELSE
                    ''
            END                                                                             AS FechaFactura,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN RTRIM(P.RazonSocial)
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN RTRIM(PPC.RazonSocial)
                ELSE
                    ''
            END                                                                             AS Proveedor,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN TCM.TipoCambio
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN TCMPC.TipoCambio
                ELSE
                    0
            END                                                                             AS TipoCambio,
            TS.NombreTipoServicio,
            S.NombreServicio                                                                AS NombreServicioConcepto,
            RTRIM(A.NombreActividad)                                                        AS Actividad,
            R.MesPresentacion                                                               AS Periodo,
            CASE P.Relacionada
                WHEN 1
                    THEN 'Relacionadas'
                ELSE
                    'Prestadora de Servicios'
            END                                                                             AS Segmento,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN F.IdFactura
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN PC.IdPedimentoComprobante
                ELSE
                    0
            END                                                                             AS IdFactura,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN ISNULL(FRRF.Serie, '') + ' ' + ISNULL(FRRF.Folio, '')
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN ISNULL(RPRF.Serie, '') + ' ' + ISNULL(RPRF.Folio, '')
                ELSE
                    ''
            END                                                                             AS FacturaLum,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN ISNULL(PRF.RazonSocial, '')
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN ISNULL(RPRSub.RazonSocial, '')
                ELSE
                    ''
            END                                                                             AS RSRefac,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN ISNULL(CONVERT(varchar, FRRF.Fecha, 103), '')
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN ISNULL(CONVERT(varchar, RPRF.Fecha, 103), '')
                ELSE
                    ''
            END                                                                             AS FechaFacLum,
            I.NombreInstalacion                                                             AS Instalacion,
                                                                                                                --instalacion del gasto      
            R.InicioEjecucion                                                               AS FechaI,
            R.FinEjecucion                                                                  AS FechaF,
            CASE
                WHEN ISNULL(RTRIM(PPS.IdPedido), '') = ''
                    THEN CASE
                             WHEN ISNULL(RTRIM(PG.IdPedido), '') = ''
                                 THEN ISNULL(R.OrdenServicioOrdenCompra, '')
                             ELSE
                                 CONCAT('CD #', RTRIM(PG.IdPedido))
                         END
                ELSE
                    RTRIM(PPS.IdPedido)
            END                                                                             AS OrdenSC,
            ISNULL(R.Partida, '')                                                           AS Partida,
            CASE
                WHEN FP.IdMoneda = 2
                    THEN PPD.PrecioUnitario
                ELSE
                    CASE
                        WHEN F.IdMoneda = 2
                            THEN R.PrecioUnitario
                        ELSE
                            NULL
                    END
            END                                                                             AS PUUSD,
            CASE
                WHEN FP.IdMoneda = 1
                    THEN PPD.PrecioUnitario
                ELSE
                    CASE
                        WHEN F.IdMoneda = 1
                            THEN R.PrecioUnitario
                        ELSE
                            NULL
                    END
            END                                                                             AS PUMXN,
            CAST(SUM(   CASE
                            WHEN R.CvTipoDocFacturacion = 1
                                THEN F.SubTotal
                            ELSE
                                PCD.PrecioUnitario
                        END
                    ) AS DECIMAL(15, 2))                                                    AS ImporteFA,
            CAST(CASE
                     WHEN R.CvTipoDocFacturacion = 1
                         THEN (CASE
                                   WHEN (F.TipoComprobante) LIKE '%egreso%'
                                        OR F.TipoComprobante LIKE 'E%'
                                       THEN ISNULL(
                                                      (ABS(ISNULL(
                                                                     ABS(ISNULL(RM.MontoGasto, R.MontoRegistro))
                                                                     + ABS(ISNULL(rm.MontoEquivalente, 0)), 0
                                                                 )
                                                          ) * -1
                                                      ), 0
                                                  )
                                   ELSE
                                       ISNULL(
                                                 ISNULL(RM.MontoGasto, R.MontoRegistro)
                                                 + ISNULL(rm.MontoEquivalente, 0), 0
                                             )
                               END
                              )
                     ELSE
                         ISNULL(ISNULL(RM.MontoGasto, R.MontoRegistro) + ISNULL(rm.MontoEquivalente, 0), 0)
                 END AS DECIMAL(15, 2))                                                     AS ImporteFaCMarckup,
            CASE
                WHEN F.IdMoneda = 1
                    THEN 'MXN'
                ELSE
                    'USD'
            END                                                                             AS Moneda,
            CAST(SUM(   CASE
                            WHEN R.CvTipoDocFacturacion = 1
                                 AND ISNULL(R.MontoRegistro, 0) <> 0
                                THEN (CASE
                                          WHEN (F.TipoComprobante) LIKE '%egreso%'
                                               OR F.TipoComprobante LIKE 'E%'
                                              THEN ISNULL((ABS(ISNULL(R.MontoRegistro, 0)) * -1), 0)
                                                   / ISNULL(RM.TipoCambio, TCM.TipoCambio)
                                          ELSE
                                              ISNULL(R.MontoRegistro, 0) / ISNULL(RM.TipoCambio, TCM.TipoCambio)
                                      END
                                     )
                            WHEN R.CvTipoDocFacturacion IN (
                                                               2, 3
                                                           )
                                 AND ISNULL(R.MontoRegistro, 0) <> 0
                                THEN ISNULL(R.MontoRegistro, 0) / ISNULL(RM.TipoCambio, TCMPC.TipoCambio)
                            ELSE
                                0
                        END
                    ) AS DECIMAL(15, 2))                                                    AS ImprteUSDMxnUsd,
            CAST(CASE
                     WHEN R.CvTipoDocFacturacion = 1
                         THEN (CASE
                                   WHEN (F.TipoComprobante) LIKE '%egreso%'
                                        OR F.TipoComprobante LIKE 'E%'
                                       THEN ISNULL((ABS(ISNULL(rm.MontoEquivalente, 0)) * -1), 0)
                                   ELSE
                                       ISNULL(rm.MontoEquivalente, 0)
                               END
                              )
                     ELSE
                         ISNULL(rm.MontoEquivalente, 0)
                 END AS DECIMAL(15, 2))                                                     AS MarkUp,
            CAST((CASE
                      WHEN R.CvTipoDocFacturacion = 1
                          THEN (CASE
                                    WHEN (F.TipoComprobante) LIKE '%egreso%'
                                         OR F.TipoComprobante LIKE 'E%'
                                        THEN ISNULL(
                                                       (ABS(ISNULL(
                                                                      ABS(ISNULL(RM.MontoGasto, R.MontoRegistro))
                                                                      + ABS(ISNULL(rm.MontoEquivalente, 0)), 0
                                                                  )
                                                           ) * -1
                                                       ), 0
                                                   )
                                    ELSE
                                        ISNULL(
                                                  ISNULL(RM.MontoGasto, R.MontoRegistro)
                                                  + ISNULL(rm.MontoEquivalente, 0), 0
                                              )
                                END
                               )
                      ELSE
                          ISNULL(ISNULL(RM.MontoGasto, R.MontoRegistro) + ISNULL(rm.MontoEquivalente, 0), 0)
                  END
                 ) / (CASE
                          WHEN R.CvTipoDocFacturacion = 1
                              THEN TCM.TipoCambio
                          WHEN R.CvTipoDocFacturacion IN (
                                                             2, 3
                                                         )
                              THEN TCMPC.TipoCambio
                          ELSE
                              0
                      END
                     ) AS DECIMAL(15, 2))                                                   AS ImporteEstimadoUSD,
            R.MesCertificadoCIEP,
            Rub.NombreRubro                                                                 AS SubActividad,
            ''                                                                              AS AplicacionEspecifica,
            PRE.Nombre                                                                      AS Presupuesto,
            CASE
                WHEN TS.NombreTipoServicio LIKE '%desarrollo%'
                     OR TS.NombreTipoServicio LIKE '%explora%'
                    THEN 'CAPEX'
                WHEN TS.NombreTipoServicio LIKE '%produc%'
                    THEN 'OPEX'
                ELSE
                    'OVERHEAD'
            END                                                                             AS CAPEXOPEX,
            'Facturado relacionada'                                                         AS Estatus,
            R.IdRegistro,
            CASE
                WHEN ISNULL(U.Unidad, '') = ''
                    THEN ISNULL(UM.Unidad, '') COLLATE Modern_Spanish_CI_AS
                ELSE
                    ISNULL(U.Unidad, '') COLLATE Modern_Spanish_CI_AS
            END                                                                             AS Unidad,
            CASE
                WHEN ISNULL(APD.Cantidad, 0) = 0
                    THEN ISNULL(RTRIM(R.CantidadReal), '')
                ELSE
                    ISNULL(RTRIM(APD.Cantidad), '')
            END                                                                             AS Cantidad
        FROM
            dbo.CO_Registro                             AS R
            JOIN
                dbo.CO_LineaPresupuestoMes              AS C
                    ON R.IdPrograma = C.IdLineaPresupuestoMes
            JOIN
                dbo.CO_Presupuesto                      PRE
                    ON C.IdPresupuesto = PRE.IdPresupuesto
            JOIN
                dbo.CO_Servicio                         AS S
                    ON C.IdServicio = S.IdServicio
            JOIN
                dbo.CO_TipoServicio                     AS TS
                    ON C.IdTipoServicio = TS.IdTipoServicio
            JOIN
                dbo.CO_Rubro                            Rub
                    ON C.IdRubro = Rub.IdRubro
            JOIN
                dbo.CO_Instalacion                      AS I
                    ON R.IdInstalacion = I.IdInstalacion
            JOIN
                dbo.CO_ActividadCIEP                    AS A
                    ON C.IdActividad = A.IdActividad
            LEFT JOIN
                dbo.FI_Factura                          F
                    ON R.IdFactura = F.IdFactura
            LEFT JOIN
                dbo.FI_RelacionRefacturas               AS RRF
                    ON R.IdFactura = RRF.idFacturaHijo
            LEFT JOIN
                dbo.PV_Subcontratista                   AS P
                    ON F.IdSubcontratista = P.IdSubcontratista
            LEFT JOIN
                dbo.FI_Factura                          FRRF
                    ON RRF.idFacturaPadre = FRRF.IdFactura
            LEFT JOIN
                dbo.PV_Subcontratista                   AS PRF
                    ON FRRF.IdSubcontratista = PRF.IdSubcontratista
            LEFT JOIN
                dbo.CO_TipoCambioMensual                AS TCM
                    ON TCM.IdMoneda = F.IdMoneda
                       AND TCM.IdMes = MONTH(F.Fecha)
                       AND TCM.Anio = YEAR(F.Fecha)
            LEFT JOIN
                dbo.FI_PedimentoComprobante             AS PC
                    ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante
            LEFT JOIN
                dbo.FI_PedimentoComprobanteDetalle      AS PCD
                    ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
            LEFT JOIN
                dbo.CO_TipoCambioMensual                AS TCMPC
                    ON TCMPC.IdMoneda = PC.IdMoneda
                       AND TCMPC.IdMes = MONTH(PC.FechaPago)
                       AND TCMPC.Anio = YEAR(PC.FechaPago)
            LEFT JOIN
                dbo.PV_Subcontratista                   AS PPC
                    ON PC.IdSubcontratistaExportador = PPC.IdSubcontratista
            LEFT JOIN
                CO_RegistroMarkup                       RM
                    ON RM.GastoId = R.IdRegistro
            LEFT JOIN
                FI_RelacionPedimento                    AS RRP
                    ON R.IdPedimentoComprobante = RRP.IdPedimentoHijo
            LEFT JOIN
                dbo.FI_Factura                          RPRF
                    ON RRP.idFacturaPadre = RPRF.IdFactura
            LEFT JOIN
                dbo.PV_Subcontratista                   AS RPRSub
                    ON RPRF.IdSubcontratista = RPRSub.IdSubcontratista
            LEFT JOIN
                PV_MM_MaterialUnidad                    UM
                    ON R.UnidadMedidaId = UM.IdUnidad
            /*cambios petro*/
            LEFT JOIN
                Petrovendor..MM_AceptacionPedidoDetalle as APD
                    on R.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
            LEFT JOIN
                Petrovendor..MM_AceptacionPedido        AS AP
                    ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
            LEFT JOIN
                PETROVENDOR..MM_AceptacionFactura       AS AFF
                    ON AP.IdAceptacionPedido = AFF.IdAceptacionPedido
            LEFT JOIN
                petrovendor..mm_pedido                  as PP
                    on AP.IdPedido = PP.IdPedido
            LEFT JOIN
                petrovendor..mm_pedidos                 as PPS
                    on PP.IdPedido = PPS.IdIdentificador
                       AND PPS.IdTipoPedido IN (
                                                   2, 4, 6
                                               ) -- MERCADEO, ADJ DIRECTA Y COMPRA DIRECTA 
                       AND PPS.IdProveedorCliente = PP.IdProveedorCompras
            LEFT JOIN
                Petrovendor..MM_PedidoDetalle           PPD
                    ON PP.IdPedido = PPD.IdPedido
                       AND APD.IdPedidoDetalle = ppd.IdPedidoDetalle
            LEFT JOIN
                Petrovendor..MM_PeticionOferta          PPO
                    ON PP.IdPeticionOferta = PPO.IdPeticionOferta
            LEFT JOIN
                Petrovendor..MM_PeticionOfertaDetalle   PPOD
                    ON PPO.IdPeticionOferta = PPOD.IdPeticionOferta
                       AND PPD.IdPeticionOfertaDetalle = PPOD.IdPeticionOfertaDetalle
            LEFT JOIN
                petrovendor..MM_SolicitudPedidoDetalle  as SPD
                    on PP.IdSolicitudPedido = SPD.IdSolicitudPedido
                       AND PPOD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle --Producto cotizados en el pedidoy que estan solo en la aceptación
            LEFT JOIN
                petrovendor..MM_Material                as MM
                    on SPD.IdMaterial = MM.IdMaterial
            LEFT JOIN
                petrovendor..PV_MM_MaterialUnidad       as U
                    on SPD.IdUnidad = U.IdUnidad
            LEFT JOIN
                Petrovendor..CO_Registro                as PR
                    on APD.IdAceptacionPedidoDetalle = PR.IdAceptacionPedidoDetalle
            LEFT JOIN
                petrovendor..FI_Factura                 as FP
                    on PR.IdFactura = FP.IdFactura
                       AND AFF.IdFactura IS NOT NULL
                       AND FP.Activa = 1

            /*cambios petro compra directa*/
            LEFT JOIN
                petrovendor..FI_Factura                 AS FPCO
                    ON F.UUID = FPCO.UUID COLLATE Modern_Spanish_CI_AS
                       AND FPCO.Activa = 1
            LEFT JOIN
                Petrovendor..CO_Registro                AS RPCD
                    ON FPCO.IdFactura = RPCD.IdFactura
                       AND RPCD.IdAceptacionPedidoDetalle IS NULL
            LEFT JOIN
                Petrovendor..TA_Operacion               AS TAO
                    ON TAO.IdDocumento = RPCD.IdFactura
                       and TAO.IdTipoOperacion = 14 --> aprobación de compra directa
            LEFT JOIN
                Petrovendor..MM_Pedidos                 PG
                    ON PG.IdIdentificador = FPCO.IdFactura
                       AND PG.IdTipoPedido = 1 --> cte compra directa
                       AND TAO.IdProveedor = PG.IdProveedorCliente
        WHERE
            (
                YEAR(R.MesPresentacion) = @Anio
                AND MONTH(R.MesPresentacion) = @Mes
            )
            AND C.IdPresupuesto = @IdPresupuesto
        GROUP BY
            UPPER(CONCAT(DATENAME(MONTH, R.MesPresentacion), ' ', YEAR(R.MesPresentacion))),
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN ISNULL(F.Serie, '') + ' ' + ISNULL(F.Folio, '')
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN PC.FolioComprobante
                ELSE
                    ''
            END,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN (CASE
                              WHEN (F.TipoComprobante) LIKE '%egreso%'
                                   OR F.TipoComprobante LIKE 'E%'
                                  THEN CASE
                                           WHEN ISNULL(R.Ajuste, '') = ''
                                               THEN R.Comentarios
                                           ELSE
                                               R.Ajuste
                                       END
                              ELSE
                                  ''
                          END
                         )
                ELSE
                    ''
            END,
            CASE
                WHEN ISNULL(MM.DescripcionLarga, '') = ''
                    THEN CASE
                             WHEN ISNULL(R.DescripcionPartidaServicio, '') = ''
                                 THEN ISNULL(R.Comentarios, '') COLLATE Modern_Spanish_CI_AS
                             ELSE
                                 ISNULL(R.DescripcionPartidaServicio, '') COLLATE Modern_Spanish_CI_AS
                         END
                ELSE
                    ISNULL(MM.DescripcionLarga, '') COLLATE Modern_Spanish_CI_AS
            END,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN F.Fecha
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN PC.FechaPago
                ELSE
                    ''
            END,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN RTRIM(P.RazonSocial)
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN RTRIM(PPC.RazonSocial)
                ELSE
                    ''
            END,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN (CASE
                              WHEN (F.TipoComprobante) LIKE '%egreso%'
                                   OR F.TipoComprobante LIKE 'E%'
                                  THEN ISNULL(
                                                 (ABS(ISNULL(
                                                                ABS(ISNULL(RM.MontoGasto, R.MontoRegistro))
                                                                + ABS(ISNULL(rm.MontoEquivalente, 0)), 0
                                                            )
                                                     ) * -1
                                                 ), 0
                                             )
                              ELSE
                                  ISNULL(ISNULL(RM.MontoGasto, R.MontoRegistro) + ISNULL(rm.MontoEquivalente, 0), 0)
                          END
                         )
                ELSE
                    ISNULL(ISNULL(RM.MontoGasto, R.MontoRegistro) + ISNULL(rm.MontoEquivalente, 0), 0)
            END,
            CAST(CASE
                     WHEN R.CvTipoDocFacturacion = 1
                         THEN (CASE
                                   WHEN (F.TipoComprobante) LIKE '%egreso%'
                                        OR F.TipoComprobante LIKE 'E%'
                                       THEN ISNULL((ABS(ISNULL(rm.MontoEquivalente, 0)) * -1), 0)
                                   ELSE
                                       ISNULL(rm.MontoEquivalente, 0)
                               END
                              )
                     ELSE
                         ISNULL(rm.MontoEquivalente, 0)
                 END AS DECIMAL(15, 2)),
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN TCM.TipoCambio
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN TCMPC.TipoCambio
                ELSE
                    0
            END,
            TS.NombreTipoServicio,
            S.NombreServicio,
            RTRIM(A.NombreActividad),
            R.MesPresentacion,
            CASE P.Relacionada
                WHEN 1
                    THEN 'Relacionadas'
                ELSE
                    'Prestadora de Servicios'
            END,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN F.IdFactura
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN PC.IdPedimentoComprobante
                ELSE
                    0
            END,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN ISNULL(FRRF.Serie, '') + ' ' + ISNULL(FRRF.Folio, '')
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN ISNULL(RPRF.Serie, '') + ' ' + ISNULL(RPRF.Folio, '')
                ELSE
                    ''
            END,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN ISNULL(PRF.RazonSocial, '')
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN ISNULL(RPRSub.RazonSocial, '')
                ELSE
                    ''
            END,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN ISNULL(CONVERT(varchar, FRRF.Fecha, 103), '')
                WHEN R.CvTipoDocFacturacion IN (
                                                   2, 3
                                               )
                    THEN ISNULL(CONVERT(varchar, RPRF.Fecha, 103), '')
                ELSE
                    ''
            END,
            I.NombreInstalacion,
            R.InicioEjecucion,
            R.FinEjecucion,
            CASE
                WHEN ISNULL(RTRIM(PPS.IdPedido), '') = ''
                    THEN CASE
                             WHEN ISNULL(RTRIM(PG.IdPedido), '') = ''
                                 THEN ISNULL(R.OrdenServicioOrdenCompra, '')
                             ELSE
                                 CONCAT('CD #', RTRIM(PG.IdPedido))
                         END
                ELSE
                    RTRIM(PPS.IdPedido)
            END,
            ISNULL(R.Partida, ''),
            CASE
                WHEN FP.IdMoneda = 2
                    THEN PPD.PrecioUnitario
                ELSE
                    CASE
                        WHEN F.IdMoneda = 2
                            THEN R.PrecioUnitario
                        ELSE
                            NULL
                    END
            END,
            CASE
                WHEN FP.IdMoneda = 1
                    THEN PPD.PrecioUnitario
                ELSE
                    CASE
                        WHEN F.IdMoneda = 1
                            THEN R.PrecioUnitario
                        ELSE
                            NULL
                    END
            END,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                    THEN F.SubTotal
                ELSE
                    PCD.PrecioUnitario
            END,
            R.MontoRegistro,
            CASE
                WHEN F.IdMoneda = 1
                    THEN 'MXN'
                ELSE
                    'USD'
            END,
            R.MesCertificadoCIEP,
            Rub.NombreRubro,
            PRE.Nombre,
            CASE
                WHEN TS.NombreTipoServicio LIKE '%desarrollo%'
                     OR TS.NombreTipoServicio LIKE '%explora%'
                    THEN 'CAPEX'
                WHEN TS.NombreTipoServicio LIKE '%produc%'
                    THEN 'OPEX'
                ELSE
                    'OVERHEAD'
            END,
            R.IdRegistro,
            RRF.MesPresentacion,
            CASE
                WHEN ISNULL(U.Unidad, '') = ''
                    THEN ISNULL(UM.Unidad, '') COLLATE Modern_Spanish_CI_AS
                ELSE
                    ISNULL(U.Unidad, '') COLLATE Modern_Spanish_CI_AS
            END,
            CASE
                WHEN ISNULL(APD.Cantidad, 0) = 0
                    THEN ISNULL(RTRIM(R.CantidadReal), '')
                ELSE
                    ISNULL(RTRIM(APD.Cantidad), '')
            END
        ORDER BY
            R.IdRegistro,
            IdFactura,
            TS.NombreTipoServicio,
            Actividad,
            Proveedor;

    END;
GO


