CREATE VIEW [dbo].[VistaReporteTableroA5BG]
AS
     SELECT TOP (100) PERCENT C.NumeroContrato AS Contrato, 
                              S4.Nombre AS Solicitante, 
                              SP.IdSolicitudPedido AS IdRequisicion, 
                              SP.MotivoUrgencia AS Descripcion, 
                              SP.FechaAlta AS FechaRegistro,
                              CASE
                                  WHEN TAO.IdEstatusOperacion = 3
                                  THEN TH.Fecha
                              END AS FechaRechazado,
                              CASE
                                  WHEN TAO.IdEstatusOperacion = 2
                                  THEN THA.Fecha
                              END AS FechaAprobado, 
                              PO.IdPeticionOferta, 
                              PO.CreadoEl AS FechaPeticionOferta, 
                              P.RazonSocial, 
                              P.IdProveedor, 
                              dbo.Fn_CalcularTotalCotizado(PO.IdPeticionOferta) AS TotalCotizado, 
                              AP.Creado AS FechaEntregaFinal, 
                              PO.FechaFinalizado AS FechaCotizacionOC, 
                              ped.CreadoEl AS FechaPedido, 
                              pedidos.IdPedido AS NumPedido, 
                              ped.Version, 
                              T.FechaCambioEstatus AS Aprobador1, 
                              TA.FechaCambioEstatus AS Aprobador2, 
                              TB.FechaCambioEstatus AS Aprobador3, 
                              TC.FechaCambioEstatus AS Aprobador4, 
                              TD.FechaCambioEstatus AS Aprobador5, 
                              T6.FechaCambioEstatus AS Aprobador6,
                              CASE
                                  WHEN TAP.IdEstadoFlujo = 3
                                  THEN THP.Fecha
                                  ELSE NULL
                              END AS AprobacionPedido,
                              CASE
                                  WHEN ISNULL(ped.Cerrado, 0) = 1
                                  THEN 'Cerrado'
                                  ELSE TEP.Nombre
                              END AS EstatusPedido, 
                              s5.Nombre AS Comprador, 
                              dbo.Fn_CalcularTotalPedido(ped.IdPedido) AS Costo, 
                              TM.TipoMonedaCorto AS Moneda, 
                              ped.FechaRecepcionServicio AS OrdenCompra, 
                              AP.IdAceptacionPedido, 
                              AP.Creado AS EntregaRecepcion, 
                              ACPCN.CreadoEl AS RegistroPCN,
                              CASE
                                  WHEN ACPCN.IdEstatus = 2
                                  THEN ACPCN.FechaEvaluacion
                                  ELSE NULL
                              END AS AprobacionPCN,
                              CASE
                                  WHEN ACPCN.IdEstatus = 3
                                  THEN ACPCN.FechaEvaluacion
                                  ELSE NULL
                              END AS RechazoPCN, 
                              AF.CreadoEl AS RecepcionFactura,
                              CASE
                                  WHEN AF.IdEstatusXML = 2
                                  THEN HFF.Fecha
                                  ELSE NULL
                              END AS AprobacionFactura,
                              CASE
                                  WHEN AF.IdEstatusXML = 3
                                  THEN HFF.Fecha
                                  ELSE NULL
                              END AS RechazoFactura, 
                              AC.NombreAreaContractual, 
                              SPDDLP.IdInstalacion, 
                              inst.NombreInstalacion, 
                              TE.Nombre AS EstatusRequisicion, 
                              PG.NombrePrograma AS Programa
     FROM MM_SolicitudPedido AS SP
          LEFT JOIN dbo.MM_SolicitudPedidoDetalle SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
          LEFT JOIN MM_SolicitudPedidoDetalleLineaPresupuesto SPDDLP ON SPDDLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
          LEFT JOIN Adinco.dbo.CO_Instalacion inst ON inst.IdInstalacion = SPDDLP.IdInstalacion
          LEFT JOIN TA_Operacion AS TAO ON TAO.IdDocumento = SP.IdSolicitudPedido
                                           AND TAO.IdTipoOperacion = 2
          LEFT JOIN dbo.TA_HistorialFlujoTarea AS TH ON TH.IdOperacion = TAO.IdOperacion
                                                        AND TH.IdEstadoFlujo = 7
          LEFT JOIN dbo.TA_HistorialFlujoTarea AS THA ON THA.IdOperacion = TAO.IdOperacion
                                                         AND THA.IdEstadoFlujo = 7
          LEFT JOIN TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion
          LEFT JOIN Adinco.dbo.CO_Contrato AS C ON SP.IdContrato = C.IdContrato
          LEFT JOIN dbo.MM_PeticionOferta PO ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
          LEFT JOIN dbo.S_Proveedor P ON P.IdProveedor = PO.IdSubcontratista
          LEFT JOIN dbo.S_Usuario S4 ON SP.IdUsuarioSolicitante = S4.IdUsuario
          LEFT JOIN dbo.MM_Pedido ped ON ped.IdSolicitudPedido = SP.IdSolicitudPedido
                                         AND ped.IdPeticionOferta = PO.IdPeticionOferta
                                         AND ped.IdSubcontratista = PO.IdSubcontratista
          LEFT JOIN dbo.TA_Operacion TAP ON TAP.IdDocumento = SP.IdSolicitudPedido
                                            AND TAP.NoVersion = ped.Version
                                            AND TAP.IdTipoOperacion = 9
          LEFT JOIN dbo.TA_Tarea AS T ON T.IdOperacion = TAP.IdOperacion
                                         AND T.NoSecuencia = 1
          LEFT JOIN dbo.TA_Tarea AS TA ON TA.IdOperacion = TAP.IdOperacion
                                          AND TA.NoSecuencia = 2
          LEFT JOIN dbo.TA_Tarea AS TB ON TB.IdOperacion = TAP.IdOperacion
                                          AND TB.NoSecuencia = 3
          LEFT JOIN dbo.TA_Tarea AS TC ON TC.IdOperacion = TAP.IdOperacion
                                          AND TC.NoSecuencia = 4
          LEFT JOIN dbo.TA_Tarea AS TD ON TD.IdOperacion = TAP.IdOperacion
                                          AND TD.NoSecuencia = 5
          LEFT JOIN dbo.TA_Tarea AS T6 ON T6.IdOperacion = TAP.IdOperacion
                                          AND T6.NoSecuencia = 6
          LEFT JOIN dbo.TA_HistorialFlujoTarea AS THP ON THP.IdOperacion = TAP.IdOperacion
                                                         AND THP.IdEstadoFlujo = 7
          LEFT JOIN dbo.S_Usuario S5 ON ped.CreadoPor = s5.IdUsuario
          LEFT JOIN TA_Estatus AS TEP ON TEP.IdEstatus = TAP.IdEstatusOperacion
          LEFT JOIN dbo.MM_Pedidos pedidos ON pedidos.IdIdentificador = ped.IdPedido
                                              AND pedidos.IdProveedorCliente = ped.IdProveedorCompras
          LEFT JOIN MM_AceptacionPedido AP ON AP.IdPedido = pedidos.IdIdentificador
          LEFT JOIN Adinco.dbo.CO_AreaContractual AC ON AC.IdAreaContractual = C.IdAreaContractual
          LEFT JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda = ped.IdMoneda
          LEFT JOIN dbo.MM_AceptacionCartaPCN AS ACPCN ON ACPCN.IdAceptacionPedido = AP.IdAceptacionPedido --AND ACPCN.IdEstatus = 2
          LEFT JOIN dbo.MM_AceptacionFactura AS AF ON AF.IdAceptacionPedido = AP.IdAceptacionPedido --AND AF.IdEstatus = 2
          LEFT JOIN dbo.TA_Operacion AS TAF ON TAF.IdDocumento = AF.IdAceptacionFactura
                                               AND TAF.IdTipoOperacion = 10
          LEFT JOIN dbo.TA_HistorialFlujoTarea AS HFF ON HFF.IdOperacion = TAF.IdOperacion
                                                         AND HFF.IdEstadoFlujo = 7
          LEFT JOIN Adinco.dbo.CO_Presupuesto AS PRES ON PRES.IdPresupuesto = SP.IdPresupuesto
          LEFT JOIN Adinco.dbo.CO_ProgramaActividad AS PG ON PG.IdProgramaActividad = PRES.IdProgramaActividad
     WHERE SP.IdProveedor = 690
           AND TAO.IdTipoOperacion = 2
           AND ISNULL(SP.Visible, 1) = 1
           AND ISNULL(SP.IdEstatusEliminado, 0) <> 1
           AND ISNULL(ped.IdEstatusEliminado, 0) <> 1
           AND C.IdContrato = 10019
     GROUP BY C.NumeroContrato, 
              S4.Nombre, 
              SP.IdSolicitudPedido, 
              SP.MotivoUrgencia, 
              PO.IdPeticionOferta, 
              PO.CreadoEl, 
              P.RazonSocial, 
              P.IdProveedor, 
              PO.FechaFinalizado, 
              ped.CreadoEl, 
              ped.IdPedido, 
              pedidos.IdPedido, 
              ped.Version, 
              SP.FechaAlta,
              CASE
                  WHEN TAO.IdEstatusOperacion = 3
                  THEN TH.Fecha
              END,
              CASE
                  WHEN TAO.IdEstatusOperacion = 2
                  THEN THA.Fecha
              END, 
              T.FechaCambioEstatus, 
              TA.FechaCambioEstatus, 
              TB.FechaCambioEstatus, 
              TC.FechaCambioEstatus, 
              TD.FechaCambioEstatus, 
              T6.FechaCambioEstatus, 
              s5.Nombre, 
              TAP.IdEstadoFlujo, 
              THP.Fecha, 
              ped.Cerrado, 
              TEP.Nombre, 
              TM.TipoMonedaCorto, 
              ped.FechaRecepcionServicio, 
              AC.NombreAreaContractual, 
              SPDDLP.IdInstalacion, 
              inst.NombreInstalacion, 
              TE.Nombre, 
              PED.TotalPedido, 
              AP.Creado, 
              AP.IdAceptacionPedido, 
              ACPCN.CreadoEl, 
              ACPCN.IdEstatus, 
              ACPCN.IdEstatus, 
              ACPCN.FechaEvaluacion, 
              AF.CreadoEl, 
              AF.IdEstatusXML, 
              HFF.Fecha, 
              PG.NombrePrograma
     ORDER BY SP.IdSolicitudPedido, 
              pedidos.IdPedido, 
              P.IdProveedor;
