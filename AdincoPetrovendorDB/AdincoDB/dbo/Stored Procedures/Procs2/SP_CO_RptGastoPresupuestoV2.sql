-- =============================================
-- Author:		Manuel Cruz
-- Create date: 24-10-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_RptGastoPresupuestoV2] 
-- SP_CO_RptGastoPresupuesto 3,1,3
-- SP_CO_RptGastoPresupuesto 3,1,10042
-- SP_CO_RptGastoPresupuesto 3,1,10061
-- Add the parameters for the stored procedure here
@IdContrato    INT, 
@IdUsuario     INT, 
@IdPresupuesto INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here

         CREATE TABLE #Datos
         (IdActividad             VARCHAR(500), 
          ActividadPetrolera      VARCHAR(500), 
          IdSubActividadPetrolera VARCHAR(500), 
          SubactividadPetrolera   VARCHAR(500), 
          IdTareaPetrolera        VARCHAR(500), 
          TareaPetrolera          VARCHAR(500), 
          SubTareaPetrolera       VARCHAR(5000), 
          PresupuestoUSD          MONEY, 
          RegistradoUSD           MONEY, 
          SaldoUSD                MONEY, 
          Pagado                  MONEY, 
          Ejercido                FLOAT, 
          OCAprobadas             INT, 
          TotalEjercido           MONEY
         );
         CREATE TABLE #Registrado
         (IdActividad             VARCHAR(500), 
          ActividadPetrolera      VARCHAR(500), 
          IdSubActividadPetrolera VARCHAR(500), 
          SubactividadPetrolera   VARCHAR(500), 
          IdTareaPetrolera        VARCHAR(500), 
          TareaPetrolera          VARCHAR(500), 
          SubTareaPetrolera       VARCHAR(5000), 
          RegistradoUSD           MONEY
         );
         CREATE TABLE #Facturas
         (IdActividad             VARCHAR(500), 
          ActividadPetrolera      VARCHAR(500), 
          IdSubActividadPetrolera VARCHAR(500), 
          SubactividadPetrolera   VARCHAR(500), 
          IdTareaPetrolera        VARCHAR(500), 
          TareaPetrolera          VARCHAR(500), 
          SubTareaPetrolera       VARCHAR(5000), 
          IdFactura               INT
         );
         CREATE TABLE #Pagado
         (IdActividad             VARCHAR(500), 
          ActividadPetrolera      VARCHAR(500), 
          IdSubActividadPetrolera VARCHAR(500), 
          SubactividadPetrolera   VARCHAR(500), 
          IdTareaPetrolera        VARCHAR(500), 
          TareaPetrolera          VARCHAR(500), 
          SubTareaPetrolera       VARCHAR(5000), 
          Pagado                  MONEY
         );

         /**/

         INSERT INTO #Datos
         (IdActividad, 
          ActividadPetrolera, 
          IdSubActividadPetrolera, 
          SubactividadPetrolera, 
          IdTareaPetrolera, 
          TareaPetrolera, 
          SubTareaPetrolera, 
          PresupuestoUSD
         )
                SELECT dbo.CO_ActividadPetroleraCNH.[id_Actividad] AS IdActividad, 
                       dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera AS ActividadPetrolera, 
                       dbo.CO_SubactividadPetrolera.[id_Sub-actividad] AS IdSubActividadPetrolera, 
                       dbo.CO_SubactividadPetrolera.SubactividadPetrolera AS SubactividadPetrolera, 
                       dbo.CO_TareaPetrolera.[id_Tarea] AS IdTareaPetrolera, 
                       dbo.CO_TareaPetrolera.TareaPetrolera AS TareaPetrolera, 
                       dbo.CO_Servicio.NombreServicio AS SubTareaPetrolera, 
                       SUM(dbo.CO_LineaPresupuestoMes.Monto) AS PresupuestoUSD
                FROM CO_LineaPresupuestoMes
                     LEFT JOIN CO_ActividadPetroleraCNH ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
                     LEFT JOIN CO_SubactividadPetrolera ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
                     LEFT JOIN CO_TareaPetrolera ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
                     LEFT JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                     LEFT JOIN CO_Presupuesto ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
                WHERE(CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto)
                GROUP BY dbo.CO_ActividadPetroleraCNH.[id_Actividad], 
                         dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera, 
                         dbo.CO_SubactividadPetrolera.[id_Sub-actividad], 
                         dbo.CO_SubactividadPetrolera.SubactividadPetrolera, 
                         dbo.CO_TareaPetrolera.[id_Tarea], 
                         dbo.CO_TareaPetrolera.TareaPetrolera, 
                         dbo.CO_Servicio.NombreServicio;

         /**/

         INSERT INTO #Registrado
         (IdActividad, 
          ActividadPetrolera, 
          IdSubActividadPetrolera, 
          SubactividadPetrolera, 
          IdTareaPetrolera, 
          TareaPetrolera, 
          SubTareaPetrolera, 
          RegistradoUSD
         )
                SELECT dbo.CO_ActividadPetroleraCNH.[id_Actividad] AS IdActividad, 
                       dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera AS ActividadPetrolera, 
                       dbo.CO_SubactividadPetrolera.[id_Sub-actividad] AS IdSubActividadPetrolera, 
                       dbo.CO_SubactividadPetrolera.SubactividadPetrolera AS SubactividadPetrolera, 
                       dbo.CO_TareaPetrolera.[id_Tarea] AS IdTareaPetrolera, 
                       dbo.CO_TareaPetrolera.TareaPetrolera AS TareaPetrolera, 
                       dbo.CO_Servicio.NombreServicio AS SubTareaPetrolera, 
                       SUM(CASE
                               WHEN ISNULL(dbo.CO_Registro.MontoRegistro, 0) <> 0
                                    AND dbo.CO_Registro.CvTipoDocFacturacion = 1
                               THEN ISNULL(dbo.CO_Registro.MontoRegistro, 0) / TCDF.TipoCambio
                               WHEN ISNULL(dbo.CO_Registro.MontoRegistro, 0) <> 0
                                    AND dbo.CO_Registro.CvTipoDocFacturacion IN(2, 3)
                               THEN ISNULL(dbo.CO_Registro.MontoRegistro, 0) / TCDPD.TipoCambio
                               ELSE 0
                           END) AS RegistradoUSD
                FROM CO_LineaPresupuestoMes
                     JOIN CO_ActividadPetroleraCNH ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
                     JOIN CO_SubactividadPetrolera ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
                     JOIN CO_TareaPetrolera ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
                     JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                     JOIN CO_Presupuesto ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
                     JOIN CO_Registro ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
                     LEFT JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura
                     LEFT JOIN dbo.CO_TipoCambioDiario TCDF ON TCDF.IdMoneda = FI_Factura.IdMoneda
                                                               AND MONTH(TCDF.Fecha) = MONTH(FI_Factura.Fecha)
                                                               AND YEAR(TCDF.Fecha) = YEAR(FI_Factura.Fecha)
                                                               AND DAY(TCDF.Fecha) = DAY(FI_Factura.Fecha)
                     LEFT JOIN dbo.FI_PedimentoComprobante PC ON PC.IdPedimentoComprobante = dbo.CO_Registro.IdPedimentoComprobante
                     LEFT JOIN dbo.CO_TipoCambioDiario TCDPD ON TCDPD.IdMoneda = PC.IdMoneda
                                                                AND MONTH(TCDPD.Fecha) = MONTH(PC.FechaPago)
                                                                AND YEAR(TCDPD.Fecha) = YEAR(PC.FechaPago)
                                                                AND DAY(TCDPD.Fecha) = DAY(PC.FechaPago)
                WHERE(CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto)
                GROUP BY dbo.CO_ActividadPetroleraCNH.[id_Actividad], 
                         dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera, 
                         dbo.CO_SubactividadPetrolera.[id_Sub-actividad], 
                         dbo.CO_SubactividadPetrolera.SubactividadPetrolera, 
                         dbo.CO_TareaPetrolera.[id_Tarea], 
                         dbo.CO_TareaPetrolera.TareaPetrolera, 
                         dbo.CO_Servicio.NombreServicio;

         /**/

         UPDATE D
           SET 
               D.RegistradoUSD = R.RegistradoUSD
         FROM #Datos D
              JOIN #Registrado R ON D.IdActividad = R.IdActividad
                                    AND D.ActividadPetrolera = R.ActividadPetrolera
                                    AND D.IdSubActividadPetrolera = R.IdSubActividadPetrolera
                                    AND D.SubactividadPetrolera = R.SubactividadPetrolera
                                    AND D.IdTareaPetrolera = R.IdTareaPetrolera
                                    AND D.TareaPetrolera = R.TareaPetrolera
                                    AND D.SubTareaPetrolera = R.SubTareaPetrolera;

         /**/

         UPDATE #Datos
           SET 
               SaldoUSD = PresupuestoUSD - RegistradoUSD;

         /**/

         INSERT INTO #Facturas
         (IdActividad, 
          ActividadPetrolera, 
          IdSubActividadPetrolera, 
          SubactividadPetrolera, 
          IdTareaPetrolera, 
          TareaPetrolera, 
          SubTareaPetrolera, 
          IdFactura
         )
                SELECT dbo.CO_ActividadPetroleraCNH.[id_Actividad] AS IdActividad, 
                       dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera AS ActividadPetrolera, 
                       dbo.CO_SubactividadPetrolera.[id_Sub-actividad] AS IdSubActividadPetrolera, 
                       dbo.CO_SubactividadPetrolera.SubactividadPetrolera AS SubactividadPetrolera, 
                       dbo.CO_TareaPetrolera.[id_Tarea] AS IdTareaPetrolera, 
                       dbo.CO_TareaPetrolera.TareaPetrolera AS TareaPetrolera, 
                       dbo.CO_Servicio.NombreServicio AS SubTareaPetrolera,
                       CASE
                           WHEN dbo.CO_Registro.CvTipoDocFacturacion = 1
                           THEN CO_Registro.IdFactura
                           ELSE dbo.CO_Registro.IdPedimentoComprobante
                       END AS IdFactura
                FROM CO_LineaPresupuestoMes
                     JOIN CO_ActividadPetroleraCNH ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
                     JOIN CO_SubactividadPetrolera ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
                     JOIN CO_TareaPetrolera ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
                     JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                     JOIN CO_Presupuesto ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
                     JOIN CO_Registro ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
                WHERE(CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto)
                GROUP BY dbo.CO_ActividadPetroleraCNH.[id_Actividad], 
                         dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera, 
                         dbo.CO_SubactividadPetrolera.[id_Sub-actividad], 
                         dbo.CO_SubactividadPetrolera.SubactividadPetrolera, 
                         dbo.CO_TareaPetrolera.[id_Tarea], 
                         dbo.CO_TareaPetrolera.TareaPetrolera, 
                         dbo.CO_Servicio.NombreServicio,
                         CASE
                             WHEN dbo.CO_Registro.CvTipoDocFacturacion = 1
                             THEN CO_Registro.IdFactura
                             ELSE dbo.CO_Registro.IdPedimentoComprobante
                         END;

         /**/

         INSERT INTO #Pagado
         (IdActividad, 
          ActividadPetrolera, 
          IdSubActividadPetrolera, 
          SubactividadPetrolera, 
          IdTareaPetrolera, 
          TareaPetrolera, 
          SubTareaPetrolera, 
          Pagado
         )
                SELECT REG.IdActividad, 
                       REG.ActividadPetrolera, 
                       REG.IdSubActividadPetrolera, 
                       REG.SubactividadPetrolera, 
                       REG.IdTareaPetrolera, 
                       REG.TareaPetrolera, 
                       REG.SubTareaPetrolera, 
                       SUM(CASE
                               WHEN TR.CvTipoDocFacturacion = 1
                                    AND ISNULL(TR.MontoPagado, 0) <> 0
                               THEN ISNULL(TR.MontoPagado, 0) / TC.TipoCambio
                               WHEN TRPC.CvTipoDocFacturacion IN(2, 3)
                                    AND ISNULL(TRPC.MontoPagado, 0) <> 0
                               THEN ISNULL(TRPC.MontoPagado, 0) / TCPC.TipoCambio
                               ELSE 0
                           END) AS Pagado
                FROM #Facturas REG
                     LEFT JOIN dbo.FI_Factura F ON REG.IdFactura = F.IdFactura
                     LEFT JOIN dbo.FI_TransferFactura TR ON F.IdFactura = TR.IdFactura
                                                            AND TR.CvTipoDocFacturacion = 1
                     LEFT JOIN dbo.FI_Transfer T ON TR.IdTransfer = T.IdTransferencia
                     LEFT JOIN dbo.CO_TipoCambioDiario TC ON TC.IdMoneda = T.IdMoneda
                                                             AND CONVERT(VARCHAR, T.FechaPago, 112) = CONVERT(VARCHAR, TC.Fecha, 112)
                     LEFT JOIN dbo.FI_PedimentoComprobante PC ON REG.IdFactura = PC.IdPedimentoComprobante
                     LEFT JOIN dbo.FI_TransferFactura TRPC ON PC.IdPedimentoComprobante = TRPC.IdPedimentoComprobante
                                                              AND TRPC.CvTipoDocFacturacion IN(2, 3)
                     LEFT JOIN dbo.FI_Transfer TPC ON TRPC.IdTransfer = TPC.IdTransferencia
                     LEFT JOIN dbo.CO_TipoCambioDiario TCPC ON TPC.IdMoneda = TCPC.IdMoneda
                                                               AND CONVERT(VARCHAR, TPC.FechaPago, 112) = CONVERT(VARCHAR, TCPC.Fecha, 112)
                GROUP BY REG.IdActividad, 
                         REG.ActividadPetrolera, 
                         REG.IdSubActividadPetrolera, 
                         REG.SubactividadPetrolera, 
                         REG.IdTareaPetrolera, 
                         REG.TareaPetrolera, 
                         REG.SubTareaPetrolera;

         /**/

         UPDATE D
           SET 
               D.Pagado = P.Pagado
         FROM #Datos D
              JOIN #Pagado P ON D.IdActividad = P.IdActividad
                                AND D.ActividadPetrolera = P.ActividadPetrolera
                                AND D.IdSubActividadPetrolera = P.IdSubActividadPetrolera
                                AND D.SubactividadPetrolera = P.SubactividadPetrolera
                                AND D.IdTareaPetrolera = P.IdTareaPetrolera
                                AND D.TareaPetrolera = P.TareaPetrolera
                                AND D.SubTareaPetrolera = P.SubTareaPetrolera;

         /*TOTAL DE ORDENES DE COMPRAS*/

         CREATE TABLE #MontosDolares
         (id                 INT, 
          idLineaPresupuesto INT, 
          MontoEjercido      DECIMAL, 
          IdPedido           INT, 
          Proveedor          NVARCHAR(1000)
         );

         /**/

         CREATE TABLE #MontoEjercidoPorLinea
         (Id                 INT, 
          IdLineaPresupuesto INT, 
          MontoEjercido      DECIMAL, 
          IdPedido           INT, 
          Proveedor          NVARCHAR(1000)
         );

         /**/

         CREATE TABLE #RptGastos
         (IdActividad             VARCHAR(500), 
          ActividadPetrolera      VARCHAR(500), 
          IdSubActividadPetrolera VARCHAR(500), 
          SubactividadPetrolera   VARCHAR(500), 
          IdTareaPetrolera        VARCHAR(500), 
          TareaPetrolera          VARCHAR(500), 
          SubTareaPetrolera       VARCHAR(5000), 
          OCAprobadas             MONEY
         );

         /**/

         --Todos los montos registrados en pesos se pasan a dolares
         INSERT INTO #MontosDolares
         (id, 
          idLineaPresupuesto, 
          MontoEjercido, 
          IdPedido, 
          Proveedor
         )
                --Todas las ordenes de compra que no tienen una factura aprobada o rechazada
                SELECT ROW_NUMBER() OVER(ORDER BY lpm.IdLineaPresupuestoMes), 
                       lpm.IdLineaPresupuestoMes,
                       CASE
                           WHEN pd.IdMoneda = 1
                           THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(ISNULL(pd.Subtotal, 0), CAST(p.CreadoEl AS DATE))
                           ELSE ISNULL(pd.Subtotal, 0)
                       END AS MontoDLS, 
                       PS.IdPedido, 
                       S.RazonSocial
                FROM Adinco.dbo.CO_LineaPresupuestoMes lpm
                     JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp ON spdlp.IdLineaPresupuesto = lpm.IdLineaPresupuestoMes
                     JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle spd ON spd.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle
                     JOIN Petrovendor.dbo.MM_SolicitudPedido sp ON sp.IdSolicitudPedido = spd.IdSolicitudPedido
                                                                   AND ISNULL(sp.IdEstatusEliminado, 0) = 0
                     JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle pod ON pod.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle
                     JOIN Petrovendor.dbo.MM_PeticionOferta po ON po.IdPeticionOferta = pod.IdPeticionOferta
                                                                  AND ISNULL(po.IdEstatusEliminado, 0) = 0
                     JOIN Petrovendor.dbo.MM_PedidoDetalle pd ON pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle
                     JOIN Petrovendor.dbo.MM_Pedido p ON p.IdPedido = pd.IdPedido
                                                         AND ISNULL(p.IdEstatusEliminado, 0) = 0
                                                         AND ISNULL(p.Cerrado, 0) = 0
                     JOIN Petrovendor.dbo.S_Proveedor S ON P.IdSubcontratista = S.IdProveedor
                     JOIN Petrovendor.dbo.MM_Pedidos PS ON P.IdPedido = PS.IdIdentificador
                     JOIN Petrovendor.dbo.TA_Operacion o ON o.IdDocumento = p.IdSolicitudPedido
                                                            AND o.IdTipoOperacion = 9
                                                            AND o.NoVersion = p.Version
                                                            AND o.IdEstatusOperacion = 2
                                                            AND ISNULL(o.IdEstatusEliminado, 0) = 0
                     LEFT JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalle apd ON apd.IdPedidoDetalle = pd.IdPedidoDetalle
                     LEFT JOIN Petrovendor.dbo.MM_AceptacionPedido ap ON ap.IdAceptacionPedido = apd.IdAceptacionPedido
                     LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura af ON af.IdAceptacionPedido = apd.IdAceptacionPedido
                     LEFT JOIN Petrovendor.dbo.TA_Operacion op ON op.IdDocumento = af.IdAceptacionFactura
                                                                  AND op.IdTipoOperacion = 10
                WHERE lpm.IdPresupuesto = @IdPresupuesto
                      AND ISNULL(ap.IdEstatusEliminado, 0) = 0
                      AND ISNULL(af.IdEstatusEliminado, 0) = 0
                      AND ISNULL(op.IdEstatusEliminado, 0) = 0
                      AND (op.IdEstatusOperacion NOT IN(2, 3, 4, 5, 6, 7, 8, 10)
                OR op.IdOperacion IS NULL); --Que la factura no este Aprobada, rechazada, cancelada, vencida, enviada, o cancelada, solo se toman las facturas sin aprobar o sin cargar
         --
         --UNION
         ----Todas las ordenes de compra que no han sido aprobadas o rechazadas
         --SELECT r.IdLineaPresupuestoMes,
         --       CASE
         --           WHEN f.IdMoneda = 1
         --           THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(r.MontoRegistro, CAST(f.FechaTimbrado AS DATE))
         --           ELSE r.MontoRegistro
         --       END AS MontoDls
         --FROM Petrovendor.dbo.MM_Pedidos ps
         --     INNER JOIN Petrovendor.dbo.TA_Operacion o ON o.IdDocumento = ps.IdIdentificador
         --                                                  AND o.IdTipoOperacion = 14
         --                                                  AND ISNULL(o.IdEstatusEliminado, 0) = 0
         --     INNER JOIN Petrovendor.dbo.CO_Registro r ON r.IdFactura = ps.IdIdentificador
         --     INNER JOIN Petrovendor.dbo.FI_Factura f ON f.IdFactura = ps.IdIdentificador
         --     INNER JOIN Adinco.dbo.CO_LineaPresupuestoMes lpm ON lpm.IdLineaPresupuestoMes = r.IdLineaPresupuestoMes
         --WHERE ps.IdTipoPedido = 1
         --      AND lpm.IdPresupuesto = @IdPresupuesto
         --      AND o.IdEstatusOperacion NOT IN(2, 3, 4, 5, 6, 7, 8, 10);

         /**/

         INSERT INTO #MontoEjercidoPorLinea
         (Id, 
          IdLineaPresupuesto, 
          MontoEjercido, 
          IdPedido, 
          Proveedor
         )
                SELECT id, 
                       idLineaPresupuesto, 
                       SUM(MontoEjercido), 
                       IdPedido, 
                       Proveedor
                FROM #MontosDolares
                GROUP BY id, 
                         idLineaPresupuesto, 
                         IdPedido, 
                         Proveedor;

         /**/

         INSERT INTO #RptGastos
         (IdActividad, 
          ActividadPetrolera, 
          IdSubActividadPetrolera, 
          SubactividadPetrolera, 
          IdTareaPetrolera, 
          TareaPetrolera, 
          SubTareaPetrolera, 
          OCAprobadas
         )
                SELECT CO_ActividadPetroleraCNH.id_Actividad AS IdActividad, 
                       CO_ActividadPetroleraCNH.DescripcionActividadPetrolera AS ActividadPetrolera, 
                       CO_SubactividadPetrolera.[id_Sub-actividad] AS IdSubActividadPetrolera, 
                       CO_SubactividadPetrolera.SubactividadPetrolera AS SubactividadPetrolera, 
                       CO_TareaPetrolera.id_Tarea AS IdTareaPetrolera, 
                       CO_TareaPetrolera.TareaPetrolera AS TareaPetrolera, 
                       CO_Servicio.NombreServicio AS SubTareaPetrolera, 
                       SUM(ISNULL(me.MontoEjercido, 0)) AS OCAprobadas
                FROM dbo.CO_LineaPresupuestoMes
                     JOIN CO_ActividadPetroleraCNH ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
                     JOIN CO_SubactividadPetrolera ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
                     JOIN CO_TareaPetrolera ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
                     JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                     JOIN CO_Instalacion ON CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
                     JOIN CO_Presupuesto ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
                     LEFT JOIN #MontoEjercidoPorLinea me ON me.IdLineaPresupuesto = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                WHERE(CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto)
                GROUP BY CO_ActividadPetroleraCNH.id_Actividad, 
                         CO_ActividadPetroleraCNH.DescripcionActividadPetrolera, 
                         CO_SubactividadPetrolera.[id_Sub-actividad], 
                         CO_SubactividadPetrolera.SubactividadPetrolera, 
                         CO_TareaPetrolera.id_Tarea, 
                         CO_TareaPetrolera.TareaPetrolera, 
                         CO_Servicio.NombreServicio
                HAVING SUM(ISNULL(me.MontoEjercido, 0)) <> 0;

         /**/

         INSERT INTO #Datos
         (IdActividad, 
          ActividadPetrolera, 
          IdSubActividadPetrolera, 
          SubactividadPetrolera, 
          IdTareaPetrolera, 
          TareaPetrolera, 
          SubTareaPetrolera, 
          PresupuestoUSD, 
          RegistradoUSD, 
          SaldoUSD, 
          Pagado, 
          Ejercido, 
          OCAprobadas, 
          TotalEjercido
         )
                SELECT IdActividad, 
                       ActividadPetrolera, 
                       IdSubActividadPetrolera, 
                       SubactividadPetrolera, 
                       IdTareaPetrolera, 
                       TareaPetrolera, 
                       SubTareaPetrolera, 
                       0, 
                       0, 
                       0, 
                       0, 
                       0, 
                       OCAprobadas, 
                       0
                FROM #RptGastos;

         /**/

         SELECT ISNULL(IdActividad, '') AS IdActividad, 
                ISNULL(ActividadPetrolera, '') AS ActividadPetrolera, 
                ISNULL(IdSubActividadPetrolera, '') AS IdSubActividadPetrolera, 
                ISNULL(SubactividadPetrolera, '') AS SubactividadPetrolera, 
                ISNULL(IdTareaPetrolera, '') AS IdTareaPetrolera, 
                ISNULL(TareaPetrolera, '') AS TareaPetrolera, 
                ISNULL(SubTareaPetrolera, '') AS SubTareaPetrolera, 
                SUM(ISNULL(PresupuestoUSD, 0)) AS PresupuestoUSD, 
                SUM(ISNULL(RegistradoUSD, 0)) AS RegistradoUSD, 
                --SUM(ISNULL(SaldoUSD, 0)-ISNULL(OCAprobadas, 0)) AS SaldoUSD, 
                SUM(ISNULL(PresupuestoUSD, 0) - (ISNULL(OCAprobadas, 0) + ISNULL(RegistradoUSD, 0))) AS SaldoUSD, 
                SUM(ISNULL(Pagado, 0)) AS Pagado,
                CASE
                    WHEN SUM(ISNULL(OCAprobadas, 0) + ISNULL(RegistradoUSD, 0)) = 0
                    THEN 0
                    WHEN SUM(ISNULL(PresupuestoUSD, 0)) = 0
                    THEN 0
                    ELSE SUM(ISNULL(OCAprobadas, 0) + ISNULL(RegistradoUSD, 0)) / SUM(ISNULL(PresupuestoUSD, 0))
                END AS Ejercido, 
                SUM(ISNULL(OCAprobadas, 0)) AS OCAprobadas, 
                SUM(ISNULL(OCAprobadas, 0) + ISNULL(RegistradoUSD, 0)) AS TotalEjercido
         FROM #Datos
         GROUP BY IdActividad, 
                  ActividadPetrolera, 
                  IdSubActividadPetrolera, 
                  SubactividadPetrolera, 
                  IdTareaPetrolera, 
                  TareaPetrolera, 
                  SubTareaPetrolera;
     END;