-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_OT_ReporteWorkFlow 10038
CREATE PROC p_OT_ReporteWorkFlow @pIdContrato INT, 
                                @pUsuarioID  INT
AS
     SELECT ot.IdOTSolicitud, 
            Total = SUM(ote.Total)
     INTO #tmpOTEstimacion
     FROM OT_Estimacion ote
          INNER JOIN OT_Solicitud ot ON ot.IdOTSolicitud = ote.IdOTSolicitud
          INNER JOIN SC_Subcontrato sc ON sc.IdSubcontrato = ot.IdSubcontrato
     WHERE ISNULL(ote.Cancelada, 0) = 0
     GROUP BY ot.IdOTSolicitud;
     SELECT Folio = ot.Folio, 
            Subcontrato = sc.NumeroSubcontrato, 
            Proveedor = p.RazonSocial, 
            CentroCostos = cc.CentroCosto, 
            EstatusActual = CASE
                                WHEN ISNULL(ot.IsEliminado, 0) = 1
                                THEN 'Baja'
                                ELSE e.Descripcion
                            END, 
            FechaInicio = ot.FechaInicio, 
            FechaFin = ot.FechaFin, 
            NumeroPartidas_Servicios = COUNT(DISTINCT sm.IdOTSolicitudMaterial), 
            TotalOT = SUM(sm.CANTIDAD * SCM.PrecioUnitario), 
            Moneda = mon.TipoMonedaCorto, 
            'Fecha Registro' = ot.CreadoEl, 
            FechaBaja = CASE
                            WHEN ISNULL(ot.IsEliminado, 0) = 1
                            THEN ot.ModificadoEl
                            ELSE NULL
                        END, 
            'Cantidad Estimada' = ISNULL(est.Total, 0), 
            'Cantidad Pendiente Por Estimar' = SUM(sm.CANTIDAD * SCM.PrecioUnitario) - ISNULL(est.Total, 0), 
            'Porc. Avance Financiero' = (CAST(CASE
                                                  WHEN SUM(sm.CANTIDAD * SCM.PrecioUnitario) > 0
                                                  THEN(ISNULL(est.Total, 0) * 100) / SUM(sm.CANTIDAD * SCM.PrecioUnitario)
                                                  ELSE 0
                                              END AS DECIMAL(5, 2))) / 100, 
            SAPPR = ot.SAPPR
     FROM OT_Solicitud ot
          INNER JOIN OT_SolicitudMaterial sm ON sm.IdOTSolicitud = ot.IdOTSolicitud
          INNER JOIN SC_Subcontrato sc ON sc.IdSubcontrato = ot.IdSubcontrato
          INNER JOIN PV_TipoMoneda mon ON mon.IdMoneda = ot.IdMoneda
          INNER JOIN SC_Materiales scm ON scm.IdSCMaterial = sm.IdSCMaterial
          INNER JOIN OT_Estatus e ON e.IdOtEstatus = ot.IdOTEstatus
          INNER JOIN PV_Subcontratista p ON p.IdSubcontratista = sc.IdSubcontratista
          INNER JOIN petrovendor..CC_CentroCosto cc ON cc.IdCentroCosto = ot.IdCentroCosto
          INNER JOIN AP_Usuario u ON u.UsuarioId = @pUsuarioID
          INNER JOIN [dbo].[AP_UsuarioCentroCosto] ucc ON ucc.IdUsuario = u.UsuarioId
                                                          AND ucc.IdCentroCosto IN(0, ot.IdCentroCosto)
          LEFT JOIN #tmpOTEstimacion est ON est.IdOTSolicitud = ot.IdOTSolicitud
     WHERE sc.IdContrato = @pIdContrato
     GROUP BY ot.Folio, 
              sc.NumeroSubcontrato, 
              p.RazonSocial, 
              ot.IsEliminado, 
              e.Descripcion, 
              ot.FechaInicio, 
              ot.FechaFin, 
              ot.CreadoEl, 
              ot.ModificadoEl, 
              mon.TipoMonedaCorto, 
              est.Total, 
              cc.CentroCosto, 
              ot.SAPPR;