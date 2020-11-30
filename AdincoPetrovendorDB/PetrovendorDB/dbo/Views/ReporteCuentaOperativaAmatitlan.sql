
CREATE VIEW [dbo].[ReporteCuentaOperativaAmatitlan]
AS
     SELECT DISTINCT TOP (100) PERCENT SP.IdSolicitudPedido AS NoRequisicion, 
                                       USP.Nombre AS RequisitorSOLPED, 
                                       SP.FechaAlta AS FechaRequisicion, 
                                       HFSP.Fecha AS FechaAprobacionSOLPED, 
                                       PS.IdPedido AS NoOrdenCompra, 
                                       USOC.Nombre AS RequisitorOC, 
                                       P.CreadoEl AS FechaOC,
                                       CASE
                                           WHEN P.IdEliminado IS NOT NULL
                                           THEN 'ELIMINADO'
                                           ELSE 'ACTIVO'
                                       END PROCESOELIMINADO, 
     (
         SELECT TOP 1 HFP.Fecha
         FROM dbo.TA_HistorialFlujoTarea AS HFP
         WHERE HFP.IdOperacion = OPES.IdOperacion
               AND HFP.IdEstadoFlujo = 7
         ORDER BY HFP.Fecha DESC
     ) AS FechaAprobacionOC, 
                                       AP.IdAceptacionPedido AS NoRecepcion, 
                                       AP.Creado AS FechaRecepcion, 
                                       AP.NombreRecibidoPor AS NombreReceptor, 
                                       M.DescripcionCorta AS NombrePartida, 
                                       M.DescripcionLarga AS Descripcion, 
                                       UN.Unidad AS UnidadMedido, 
                                       PD.Cantidad AS CantidadSolicitada, 
                                       APD.Cantidad AS CantidadAceptada, 
                                       PD.PrecioUnitario, 
                                       (APD.Cantidad * PD.PrecioUnitario) AS SubTotal, 
                                       MON.TipoMonedaCorto AS TipoMoneda, 
                                       TPP.TipoPedido AS TipoOrdenCompra, 
                                       APD.Detalle AS Comentario, 
                                       PR.RazonSocial AS Proveedor, 
                                       FI.Folio AS NoFactura, 
                                       FI.CreadoEn AS FechaFactura, 
                                       'Factura #'+FI.Folio+' / Aprobador : '+UST.Nombre+' / Estatus:'+TAE.Nombre+' / Fecha:'+CAST(TA.FechaCambioEstatus AS VARCHAR(100)) AS AprobacionFactura#1, 
                                       'Factura #'+FI.Folio+' / Aprobador : '+USTD.Nombre+' / Estatus:'+TAED.Nombre+' / Fecha:'+CAST(TAD.FechaCambioEstatus AS VARCHAR(100)) AS AprobacionFactura#2, 
                                       CP.Nombre AS Presupuesto, 
                                       P.CreadoEl AS InicioEjecucion, 
                                       P.FechaRecepcionServicio AS FinEjecucion, 
                                       TG.TipoGasto AS TipoGasto, 
                                       LPM.AC_PRESUP_MES AS MesPresentacion, 
                                       CI.NombreInstalacion AS Instalacion, 
                                       TS.NombreTipoServicio AS TipoServicio, 
                                       AC.NombreActividad AS Actividad, 
                                       SAC.NombreSubactividad AS SubActividad,
									   REG.IdRegistro AS IdRegistroGasto
     FROM dbo.MM_SolicitudPedido AS SP
          LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
          LEFT JOIN dbo.MM_PeticionOferta AS PO ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
          JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
                                                      AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
          LEFT JOIN dbo.MM_Pedido AS P ON P.IdSolicitudPedido = SP.IdSolicitudPedido
                                          AND P.IdPeticionOferta = PO.IdPeticionOferta
                                          AND P.IdSubcontratista = PO.IdSubcontratista
          JOIN dbo.MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
                                             AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
          LEFT JOIN dbo.MM_AceptacionPedido AS AP ON AP.IdPedido = P.IdPedido
          LEFT JOIN dbo.MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
                                                             AND APD.IdPedidoDetalle = PD.IdPedidoDetalle
          LEFT JOIN dbo.MM_AceptacionFactura AS AFI ON AFI.IdAceptacionPedido = AP.IdAceptacionPedido
          LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS LPSP ON LPSP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
          LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS LPM ON LPM.IdLineaPresupuestoMes = LPSP.IdLineaPresupuesto
          LEFT JOIN Adinco.dbo.CO_Instalacion AS CI ON CI.IdInstalacion = LPSP.IdInstalacion
          LEFT JOIN Adinco.dbo.CO_TipoServicio AS TS ON TS.IdTipoServicio = LPM.IdTipoServicio
          LEFT JOIN Adinco.dbo.CO_ActividadCIEP AS AC ON AC.IdActividad = LPM.IdActividad
          LEFT JOIN Adinco.dbo.CO_SubactividadCIEP AS SAC ON SAC.IdSubactividad = LPM.IdSubactividad
          LEFT JOIN dbo.S_Usuario AS USP ON USP.IdUsuario = SP.IdUsuarioSolicitante
          LEFT JOIN dbo.TA_Operacion AS OPP ON OPP.IdDocumento = SP.IdSolicitudPedido
                                               AND OPP.IdTipoOperacion = 2 --REQUISICION
          LEFT JOIN dbo.TA_HistorialFlujoTarea AS HFSP ON HFSP.IdOperacion = OPP.IdOperacion
                                                          AND HFSP.IdEstadoFlujo = 7 --TAREA FINALIZADA
          LEFT JOIN dbo.MM_Pedidos AS PS ON PS.IdIdentificador = P.IdPedido
          INNER JOIN dbo.TA_Operacion AS OPES ON OPES.IdDocumento = P.IdSolicitudPedido
                                                 AND OPES.NoVersion = P.Version
                                                 AND OPES.IdTipoOperacion = 9 --APROBACION DE PEDIDO
                                                 AND OPES.IdEstatusOperacion = 2 -- PEDIDO APROBADO
                                                 AND OPES.IdEstadoFlujo = 3 --FLUJO APROBADO PEDIDO
          LEFT JOIN dbo.S_Usuario AS USOC ON USOC.IdUsuario = P.CreadoPor
          LEFT JOIN dbo.MM_Material AS M ON M.IdMaterial = PD.IdMaterial
          LEFT JOIN dbo.PV_MM_MaterialUnidad AS UN ON UN.IdUnidad = M.IdUnidad
          LEFT JOIN dbo.PV_TipoMoneda AS MON ON MON.IdMoneda = PD.IdMoneda
          LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = P.IdSubcontratista
          LEFT JOIN dbo.TA_Operacion AS OPPF ON OPPF.IdDocumento = AFI.IdAceptacionFactura
                                                AND OPPF.IdTipoOperacion = 10 --APROBACION FACTURA
                                                AND OPPF.IdEstatusOperacion = 2 --FACTURA APROBADA
                                                AND OPPF.IdEstadoFlujo = 3 --FLUJO APROBADO
          LEFT JOIN dbo.FI_Factura AS FI ON FI.IdFactura = AFI.IdFactura
          LEFT JOIN Adinco.dbo.CO_Presupuesto AS CP ON CP.IdPresupuesto = SP.IdPresupuesto
          LEFT JOIN dbo.MM_TipoGastos AS TG ON TG.IdTipoGasto = SP.IdTipoGasto
          LEFT JOIN Adinco.dbo.FI_Factura AS FIAD ON FIAD.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = FI.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
          LEFT JOIN dbo.TA_Tarea AS TA ON TA.IdOperacion = OPPF.IdOperacion
                                          AND TA.NoSecuencia = 1
          LEFT JOIN dbo.S_Usuario AS UST ON UST.IdUsuario = TA.IdAprobador
          LEFT JOIN dbo.TA_Estatus AS TAE ON TAE.IdEstatus = TA.IdEstatus
          LEFT JOIN dbo.TA_Tarea AS TAD ON TAD.IdOperacion = OPPF.IdOperacion
                                           AND TAD.NoSecuencia = 2
          LEFT JOIN dbo.S_Usuario AS USTD ON USTD.IdUsuario = TAD.IdAprobador
          LEFT JOIN dbo.TA_Estatus AS TAED ON TAED.IdEstatus = TAD.IdEstatus
          LEFT JOIN dbo.MM_TipoPedido AS TPP ON TPP.IdTipoPedido = PO.IdTipoProceso
		  LEFT JOIN Adinco.dbo.CO_Registro AS REG ON REG.IdFactura = FIAD.IdFactura
     WHERE SP.IdProveedor = 570
           AND P.IdPedido IS NOT NULL;
