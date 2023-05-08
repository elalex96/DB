CREATE VIEW [dbo].[VistaGastosPorPozoJaguar]
AS
     SELECT TOP (100) PERCENT ISNULL(CI.NombreInstalacion, '') AS Pozo, --> INSTALACIÓN
                              PG.IdPedido AS NoPedido, ---> NUMERO DE PEDIDO VISIBLE 
                              CONCAT(ISNULL(PV.RazonSocial, ''), ' ', ISNULL(PV.RegimenCapital, '')) AS Proveedor, --> PROVEEDOR VENTAS
                              POD.MaterialCotizadoTextoC AS Descripcion, --> NOMBRE DEL MATERIAL COMPRADO O CON DESCRIPCIÓN DEL PROVEEDOR 
                              PD.Cantidad AS UnidadesSolicitadasEnPedido, --> UNIDADES REGISTRADAS EN EL PEDIDO DETALLE
                              (ISNULL(
     (
         SELECT SUM(ISNULL(Cantidad, 0))
         FROM MM_AceptacionPedidoDetalle APD
              LEFT JOIN MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
         WHERE APD.IdPedidoDetalle = PD.IdPedidoDetalle
               AND AP.IdPedido = PD.IdPedido
               AND ISNULL(AP.IdEstatusEliminado, 0) <> 1
     ), 0)) AS UnidadesAceptadas, --> UNIDADEDES ACEPTADAS EN TODAS LAS ACEPTACIONES NO ELIMINADAS
                              (PD.Cantidad - (ISNULL(
     (
         SELECT SUM(ISNULL(Cantidad, 0))
         FROM MM_AceptacionPedidoDetalle APD
              LEFT JOIN MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
         WHERE APD.IdPedidoDetalle = PD.IdPedidoDetalle
               AND AP.IdPedido = PD.IdPedido
               AND ISNULL(AP.IdEstatusEliminado, 0) <> 1
     ), 0))) AS UnidadesPendientesPorAceptar, --> UNIDADES PENDIENTES DE RECIBIR = UNIDADES PEDIDO DETALLE ACTUAL - UNIDADES ACEPTADAS EN TODAS LAS ACEPTACIONES DETALLE DEL PEDIDO DETALLE ACTUAL NO ELIMINADAS
                              PD.PrecioUnitario AS PrecioUnitario, --> PRECIO UNITARIO EN PEDIDO DETALLE
                              PD.Subtotal AS MontoPedido, ---> MONTO TOTAL DEL PEDIDO DETALLE
                              (PD.PrecioUnitario * (ISNULL(
     (
         SELECT SUM(ISNULL(Cantidad, 0))
         FROM MM_AceptacionPedidoDetalle APD
              LEFT JOIN MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
         WHERE APD.IdPedidoDetalle = PD.IdPedidoDetalle
               AND AP.IdPedido = PD.IdPedido
               AND ISNULL(AP.IdEstatusEliminado, 0) <> 1
     ), 0))) AS MontoAceptado, --> MONTO ACEPTADO= UNIDADES ACEPTADAS EN TODAS LAS ACEPTACIONES NO ELIMINADAS * PRECIO UNITARIO DE PEDIDO DETALLE 
                              ((PD.Subtotal) - (PD.PrecioUnitario * (ISNULL(
     (
         SELECT SUM(ISNULL(Cantidad, 0))
         FROM MM_AceptacionPedidoDetalle APD
              LEFT JOIN MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
         WHERE APD.IdPedidoDetalle = PD.IdPedidoDetalle
               AND AP.IdPedido = PD.IdPedido
               AND ISNULL(AP.IdEstatusEliminado, 0) <> 1
     ), 0)))) AS MontoPorAceptar, --> MONTO POR ACEPTAR = MONTO TOTAL - (CANTIDAD ACEPTADA EN TODAS LAS ACEPTACIONES NO ELIMINADAS * PRECIO UNITARIO DE PEDIDO DETALLE) 
                              TM.TipoMoneda AS Moneda, --> MONEDA DEL PEDIDO DETALLE 
                              (CO.NumeroContrato+' - '+AC.NombreAreaContractual) AS Contrato, --> CONTRATO DE LA REQUISICIÓN
                              CONCAT(ISNULL(PC.RazonSocial, ''), ' ', ISNULL(PC.RegimenCapital, '')) AS Empresa, --> PROVEEDOR COMPRAS
                              CASE
                                  WHEN ISNULL(PD.RecepcionPedido, 0) = 1
                                  THEN 'Confirmado'
                                  ELSE 'Rechazada'
                              END AS ConfirmacionPorPartida
     FROM dbo.MM_PedidoDetalle PD
          LEFT JOIN dbo.MM_Pedido P ON PD.IdPedido = P.IdPedido
          LEFT JOIN dbo.MM_Pedidos PG ON PG.IdIdentificador = P.IdPedido
                                         AND P.IdProveedorCompras = PG.IdProveedorCliente
          LEFT JOIN dbo.MM_PeticionOferta PO ON PO.IdPeticionOferta = P.IdPeticionOferta
          LEFT JOIN dbo.MM_PeticionOfertaDetalle POD ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
                                                        AND PO.IdPeticionOferta = POD.IdPeticionOferta
          LEFT JOIN dbo.S_Proveedor PV ON PV.IdProveedor = P.IdSubcontratista
          LEFT JOIN dbo.S_Proveedor PC ON PC.IdProveedor = P.IdProveedorCompras
          LEFT JOIN dbo.MM_SolicitudPedido SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
                                                 AND PO.IdSolicitudPedido = SP.IdSolicitudPedido
          LEFT JOIN dbo.MM_SolicitudPedidoDetalle SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
                                                         AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
          LEFT JOIN Adinco.dbo.CO_Contrato CO ON CO.IdContrato = SP.IdContrato
          LEFT JOIN Adinco.dbo.CO_AreaContractual AC ON AC.IdAreaContractual = CO.IdAreaContractual
          LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL ON SPDL.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
          LEFT JOIN Petrovendor.dbo.CC_CentroCosto CC ON CC.IdCentroCosto = SPDL.IdCentroCosto
          LEFT JOIN Adinco.dbo.CO_Instalacion CI ON CI.IdInstalacion = SPDL.IdInstalacion
          LEFT JOIN dbo.PV_TipoMoneda TM ON TM.IdMoneda = PD.IdMoneda
          LEFT JOIN dbo.TA_Operacion O ON O.IdDocumento = P.IdSolicitudPedido
                                          AND O.IdTipoOperacion = 9
                                          AND P.Version = O.NoVersion
     WHERE P.IdProveedorCompras IN(606, 690) --> PROVEEDOR COMPRAS
          AND O.IdEstatusOperacion = 2 --> APROBACIÓN APROBADA
          AND P.RecepcionServicio = 1 --> PEDIDO CONFIRMADO
          AND ISNULL(P.IdEstatusEliminado, 0) <> 1 --> PEDIDO NO ELIMINADO
     ORDER BY PG.IdIdentificador ASC;
