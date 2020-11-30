-- =============================================
-- Author:		Pedro Acu�a
-- Create date: 14-08-2019
-- Description:	Carga los registros que van a ser afectados
-- =============================================

CREATE PROCEDURE sp_RegistrosAfectadosCambioLineas @IdSolicitudPedido INT
AS
    BEGIN
        DECLARE @TablaSolped TABLE
        (IdSolicitudPedido                        INT, 
         IdSolicitudPedidoDetalle                 INT, 
         IdSolicitudPedidoDetalleLineaPresupuesto INT, 
         IdLineaPresupuesto                       INT
        );
        INSERT INTO @TablaSolped
        (IdSolicitudPedido, 
         IdSolicitudPedidoDetalle, 
         IdSolicitudPedidoDetalleLineaPresupuesto, 
         IdLineaPresupuesto
        )
               SELECT sp.IdSolicitudPedido, 
                      spd.IdSolicitudPedidoDetalle, 
                      spdl.IdSolicitudPedidoDetalleLineaPresupuesto, 
                      spdl.IdLineaPresupuesto
               FROM dbo.MM_SolicitudPedido sp
                    INNER JOIN dbo.MM_SolicitudPedidoDetalle spd ON spd.IdSolicitudPedido = sp.IdSolicitudPedido
                    INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl ON spdl.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
               WHERE sp.IdSolicitudPedido = @IdSolicitudPedido;
        DECLARE @TablaRegistroPetrov TABLE
        (IdAceptacion             INT, 
         IdPedido                 INT, 
         FechaRegistro            DATETIME, 
         Proveedor                NVARCHAR(MAX), 
         Estatus                  NVARCHAR(300), 
         IdPedidoGral             INT, 
         TipoPedido               NVARCHAR(400), 
         TipoMoneda               NVARCHAR(120), 
         UUID                     NVARCHAR(MAX), 
         IdSolicitudPedido        INT, 
         IdFactura                INT, 
         IdRegistroPetrov         INT, 
         IdLineaPetrov            INT, 
         IdSolicitudPedidoDetalle INT
        );
        INSERT INTO @TablaRegistroPetrov
        (IdAceptacion, 
         IdPedido, 
         FechaRegistro, 
         Proveedor, 
         Estatus, 
         IdPedidoGral, 
         TipoPedido, 
         TipoMoneda, 
         UUID, 
         IdSolicitudPedido, 
         IdFactura, 
         IdRegistroPetrov, 
         IdLineaPetrov, 
         IdSolicitudPedidoDetalle
        )
               SELECT AF.IdAceptacionPedido, 
                      PE.IdPedido, 
                      O.FechaRegistro, 
                      PR.RazonSocial + ' ' + ISNULL(PR.RegimenCapital, '') AS Proveedor, 
                      E.Nombre, 
                      PG.IdPedido AS IdPedidoGeneral, 
                      TP.TipoPedido, 
                      TM.TipoMonedaCorto AS Moneda, 
                      fi.UUID, 
                      PE.IdSolicitudPedido, 
                      fi.IdFactura, 
                      r.IdRegistro, 
                      r.IdLineaPresupuestoMes, 
                      spd.IdSolicitudPedidoDetalle
               FROM MM_AceptacionFactura AS AF
                    INNER JOIN TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura
                    INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
                    INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                    INNER JOIN dbo.MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
                    INNER JOIN MM_Pedido AS PE ON PE.IdPedido = AP.IdPedido
                                                  AND PE.IdSubcontratista = O.IdProveedor
                    INNER JOIN MM_PedidoDetalle AS PED ON PED.IdPedido = PE.IdPedido
                                                          AND APD.IdPedidoDetalle = PED.IdPedidoDetalle
                    INNER JOIN MM_Pedidos AS PG ON PE.IdPedido = PG.IdIdentificador
                                                   AND PG.IdProveedorCliente = AP.IdProveedor
                    INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = PE.IdSubcontratista
                    INNER JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda = PE.IdMoneda
                    LEFT JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
                    LEFT JOIN dbo.FI_Factura AS fi ON fi.IdFactura = AF.IdFactura
                    INNER JOIN dbo.CO_Registro r ON r.IdFactura = fi.IdFactura
                    INNER JOIN dbo.MM_PeticionOfertaDetalle pod ON pod.IdPeticionOfertaDetalle = PED.IdPeticionOfertaDetalle
                    INNER JOIN dbo.MM_SolicitudPedidoDetalle spd ON spd.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle
               WHERE O.IdTipoOperacion = 10
                     AND ISNULL(AF.IdEstatusEliminado, 0) <> 1
                     AND PE.IdSolicitudPedido = @IdSolicitudPedido
               GROUP BY AF.IdAceptacionPedido, 
                        PE.IdPedido, 
                        O.FechaRegistro, 
                        PR.RazonSocial, 
                        PR.RegimenCapital, 
                        E.Nombre, 
                        PG.IdPedido, 
                        TP.TipoPedido, 
                        TM.TipoMonedaCorto, 
                        PR.RFC, 
                        AF.IdEstatusEliminado, 
                        PE.IdSolicitudPedido, 
                        E.IdEstatus, 
                        fi.UUID, 
                        fi.IdFactura, 
                        spd.IdSolicitudPedidoDetalle, 
                        r.IdRegistro, 
                        r.IdLineaPresupuestoMes
               ORDER BY AF.IdAceptacionPedido DESC;
        DECLARE @TablaRelacionFactura TABLE
        (IdFacturaPetrov INT, 
         IdFacturaAdinco INT
        );
        INSERT INTO @TablaRelacionFactura
        (IdFacturaPetrov, 
         IdFacturaAdinco
        )
               SELECT IdFacturaPetrovendor, 
                      IdFacturaAdinco
               FROM Adinco.dbo.FI_FacturaAdincoPetrovendor
               WHERE IdFacturaPetrovendor IN
               (
                   SELECT IdFactura
                   FROM @TablaRegistroPetrov
               );
        DECLARE @TablaRegistrosAdinco TABLE
        (IdRegistroAdinco INT, 
         IdPrograma       INT, 
         IdRegistroPetrov INT, 
         IdFacturaAdinco  INT
        );
        INSERT INTO @TablaRegistrosAdinco
        (IdRegistroAdinco, 
         IdPrograma, 
         IdFacturaAdinco
        )
               SELECT r.IdRegistro, 
                      r.IdPrograma, 
                      r.IdFactura
               FROM @TablaRelacionFactura rel
                    LEFT JOIN Adinco.dbo.FI_Factura f ON f.IdFactura = rel.IdFacturaAdinco
                    LEFT JOIN Adinco.dbo.CO_Registro r ON r.IdFactura = f.IdFactura;
        UPDATE t
          SET 
              t.IdRegistroPetrov = rel.IdRegistroPetrovendor
        FROM @TablaRegistrosAdinco t
             INNER JOIN dbo.CO_RelacionRegistroAdinco rel ON rel.IdRegistroAdinco = t.IdRegistroAdinco;
        SELECT ts.IdSolicitudPedido, 
               ts.IdSolicitudPedidoDetalle, 
               ts.IdLineaPresupuesto, 
               tp.IdPedidoGral, 
               tp.IdAceptacion, 
               tp.FechaRegistro, 
               tp.Proveedor, 
               tp.Estatus, 
               tp.TipoPedido, 
               tp.TipoMoneda, 
               tp.UUID, 
               tp.IdFactura, 
               tp.IdRegistroPetrov, 
               tp.IdLineaPetrov, 
               adinco.IdFacturaAdinco, 
               adinco.IdRegistroAdinco, 
               adinco.IdPrograma, 
               '' AS LineaCambiar
        FROM @TablaSolped ts
             LEFT JOIN @TablaRegistroPetrov tp ON tp.IdSolicitudPedidoDetalle = ts.IdSolicitudPedidoDetalle
             LEFT JOIN @TablaRegistrosAdinco adinco ON adinco.IdRegistroPetrov = tp.IdRegistroPetrov;
    END;
