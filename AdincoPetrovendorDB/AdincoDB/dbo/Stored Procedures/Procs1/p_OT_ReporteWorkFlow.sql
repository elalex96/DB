IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_ReporteWorkFlow'
    )
    DROP PROCEDURE p_OT_ReporteWorkFlow;
GO
CREATE PROCEDURE [dbo].[p_OT_ReporteWorkFlow]
    @pIdContrato INT,
    @pUsuarioID  INT
AS
    BEGIN
        CREATE TABLE #tmpOTEstimacion
            (
                IdOTSolicitud INT,
                Total         FLOAT
            )
		CREATE TABLE #tmpCentroCostos
            (
                IdUsuario INT,
                IdCentroCostos         INT
            )

        INSERT INTO #tmpOTEstimacion
            (
                IdOTSolicitud,
                Total
            )
                    SELECT
                        OT_Solicitud.IdOTSolicitud,
                        Total = SUM(OT_Estimacion.Total)
                    FROM
                        OT_Estimacion (NOLOCK)
                        INNER JOIN
                            OT_Solicitud (NOLOCK)
                                ON OT_Estimacion.IdOTSolicitud	=	OT_Solicitud.IdOTSolicitud 
								AND   ISNULL(OT_Estimacion.Cancelada, 0) = 0
                        INNER JOIN
                            SC_Subcontrato (NOLOCK)
                                ON  OT_Solicitud.IdSubcontrato	=	SC_Subcontrato.IdSubcontrato
                    WHERE
                        ISNULL(OT_Estimacion.Cancelada, 0) = 0
                    GROUP BY
                        OT_Solicitud.IdOTSolicitud;

		INSERT INTO	#tmpCentroCostos(IdUsuario ,IdCentroCostos)
		SELECT IdUsuario ,IdCentroCosto FROM [AP_UsuarioCentroCosto] WHERE IdUsuario = @pUsuarioID;

		IF((SELECT COUNT(1) FROM #tmpCentroCostos WHERE IdCentroCostos = 0) = 0)
		BEGIN
			INSERT INTO	#tmpCentroCostos(IdUsuario ,IdCentroCostos)
			SELECT @pUsuarioID,0;
		END

        SELECT
            Folio                            = ot.Folio,
            Subcontrato                      = sc.NumeroSubcontrato,
            Proveedor                        = p.RazonSocial,
            CentroCostos                     = cc.CentroCosto,
            EstatusActual                    = CASE
                                                   WHEN ISNULL(ot.IsEliminado, 0) = 1
                                                       THEN 'Baja'
                                                   ELSE
                                                       e.Descripcion
                                               END,
            FechaInicio                      = ot.FechaInicio,
            FechaFin                         = ot.FechaFin,
            NumeroPartidas_Servicios         = COUNT(DISTINCT sm.IdOTSolicitudMaterial),
            TotalOT                          = SUM(ISNULL(sm.CANTIDAD,0) * ISNULL(SCM.PrecioUnitario,0)),
            Moneda                           = mon.TipoMonedaCorto,
            'Fecha Registro'                 = ot.CreadoEl,
            FechaBaja                        = CASE
                                                   WHEN ISNULL(ot.IsEliminado, 0) = 1
                                                       THEN ot.ModificadoEl
                                                   ELSE
                                                       NULL
                                               END,
            'Cantidad Estimada'              = ISNULL(est.Total, 0),
            'Cantidad Pendiente Por Estimar' = SUM(ISNULL(sm.CANTIDAD,0) * ISNULL(SCM.PrecioUnitario,0)) - ISNULL(est.Total, 0),
            'Porc. Avance Financiero'        = ISNULL((CAST(CASE
                                                         WHEN SUM(ISNULL(sm.CANTIDAD,0) * ISNULL(SCM.PrecioUnitario,0)) > 0
                                                             THEN (ISNULL(est.Total, 0) * 100)
                                                                  / SUM(ISNULL(sm.CANTIDAD,0) * ISNULL(SCM.PrecioUnitario,0))
                                                         ELSE
                                                             0
															  
                                                     END AS DECIMAL(15, 2))
                                              ) ,0)/ 100,
            SAPPR                            = ot.SAPPR
        FROM
			SC_Subcontrato                sc (NOLOCK)
        INNER JOIN
            OT_Solicitud                      ot (NOLOCK)
			ON  sc.IdContrato =	@pIdContrato
			AND sc.IdSubcontrato	=	ot.IdSubcontrato
		INNER JOIN
                #tmpCentroCostos	TCC
				ON ot.IdCentroCosto	=	TCC.IdCentroCostos
            INNER JOIN
                OT_SolicitudMaterial          sm (NOLOCK)
                    ON ot.IdOTSolicitud	=	sm.IdOTSolicitud               
            INNER JOIN
                PV_TipoMoneda                 mon (NOLOCK)
                    ON ot.IdMoneda	=	mon.IdMoneda
            INNER JOIN
                SC_Materiales                 scm (NOLOCK)
                    ON  sm.IdSCMaterial	=	scm.IdSCMaterial
            INNER JOIN
                OT_Estatus                    e (NOLOCK)
                    ON ot.IdOTEstatus	=	 e.IdOtEstatus
            INNER JOIN
                PV_Subcontratista             p (NOLOCK)
                    ON  sc.IdSubcontratista	=	p.IdSubcontratista
            INNER JOIN
                petrovendor..CC_CentroCosto   cc (NOLOCK)
                    ON  ot.IdCentroCosto	=	cc.IdCentroCosto
           
            LEFT JOIN
                #tmpOTEstimacion              est  (NOLOCK)
                    ON ot.IdOTSolicitud	=	est.IdOTSolicitud 
        WHERE
            sc.IdContrato =	@pIdContrato
        GROUP BY
            ot.Folio,
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

    END
