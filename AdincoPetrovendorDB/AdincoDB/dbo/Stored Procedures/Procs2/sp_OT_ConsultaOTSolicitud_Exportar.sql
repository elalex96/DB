IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'sp_OT_ConsultaOTSolicitud_Exportar'
    )
    DROP PROCEDURE sp_OT_ConsultaOTSolicitud_Exportar;
GO
-- sp_OT_ConsultaOTSolicitud_Exportar 10038,10
CREATE PROCEDURE [dbo].[sp_OT_ConsultaOTSolicitud_Exportar]
    @pIdContrato int,
    @pIdUsuario  int
As
    begin
        IF OBJECT_ID(N'tempdb..#tmpCantidad') IS NOT NULL
            BEGIN
                DROP TABLE #tmpCantidad
            END

        CREATE TABLE #tmpCantidad
            (
                IdSubContrato INT,
                IdSCMaterial  INT,
                Cantidad      DECIMAL(14, 5)
            )

        INSERT INTO #tmpCantidad
                    select
                        IdSubContrato,
                        IdSCMaterial,
                        Cantidad = ISNULL(SUM(asignado.cantidad), 0)
                    from
                        OT_SolicitudMaterial asignado (NOLOCK)
                        inner join
                            OT_Solicitud     otasignada (NOLOCK)
                                on otasignada.IdOTSolicitud = asignado.IdOTSolicitud
								AND   otasignada.IsActivo = 1
								and otasignada.IsEliminado = 0
								and otasignada.IdOTEstatus not in (
																		7, 8
																	) --rechazada
                    where
                        otasignada.IsActivo = 1
                        and otasignada.IsEliminado = 0
                        and otasignada.IdOTEstatus not in (
                                                              7, 8
                                                          ) --rechazada
                    group by
                        IdSubContrato,
                        IdSCMaterial;

        select
            sol.IdOTSolicitud,
            sol.Folio,
            sol.FechaInicio,
            sol.FechaFin,
            sc2.Objeto,
            Estatus            = ote.Descripcion,
            cc.CentroCosto,
            sc2.NumeroSubContrato,
            sc.Concepto,
            sm.IdOTSolicitud,
            Material           = sc.Descripcion,
            Unidad,
            Cantidad           = ISNULL(sm.Cantidad, 0),
            CantidadDisponible = case
                                     when ISNULL(sc.Cantidad, 0) - (t1.cantidad) < 0
                                         then 0
                                     else
                                         ISNULL(sc.Cantidad, 0) - (t1.cantidad)
                                 End,
            PrecioUnitario     = sc.PrecioUnitario,
            Importe            = cast(isnull(sm.Cantidad, 0) * isnull(sc.PrecioUnitario, 0) as money),
            sm.FechaProgramaInicio,
            sm.FechaProgramaFin,
            Moneda             = isnull(TipoMonedaCorto, 'NO DEFINIDO'),
            SAPPR
        from
            #tmpCantidad                             t1
            JOIN
                OT_Solicitud                         sol (NOLOCK)
                    ON t1.IdSubContrato = sol.IdSubContrato
					  and isnull(sol.IsActivo, 0) = 1
            JOIN
                dbo.SC_Materiales                    sc (NOLOCK)
                    ON t1.IdSCMaterial = sc.IdSCMaterial
                       AND sol.IdSubContrato = sc.IdSubContrato
            JOIN
                petrovendor..MM_Material             mmm (NOLOCK)
                    ON sc.IdMaestro = mmm.IdMaterial
            JOIN
                sc_subcontrato                       sc2 (NOLOCK)
                    on sol.idsubcontrato = sc2.idsubcontrato
					  and sc2.IsActivo = 1
            
            and sc2.IdContrato = @pIdContrato
            JOIN
                OT_SolicitudMaterial                 sm (NOLOCK)
                    on sol.IdOTSolicitud = sm.IdOTSolicitud
                       and sm.IdSCMaterial = sc.IdSCMaterial
            JOIN
                Petrovendor..CC_CentroCosto          cc (NOLOCK)
                    on sol.IdCentroCosto = cc.IdCentroCosto
            JOIN
                AP_UsuarioCentroCosto                ucc (NOLOCK)
                    on cc.IdCentroCosto = ucc.IdCentroCosto
					and ucc.IdUsuario = @pIdUsuario
            JOIN
                OT_Estatus                           ote (NOLOCK)
                    on sol.IdOTEstatus = ote.IdOtEstatus
					AND  ote.IdOTEstatus not in (
                                       7, 8
                                   )
            LEFT JOIN
                Petrovendor.dbo.PV_TipoMoneda        moneda (NOLOCK)
                    on sol.IdMoneda = moneda.idMoneda
            LEFT JOIN
                Petrovendor.dbo.PV_MM_MaterialUnidad uni (NOLOCK)
                    on SC.IdUnidad = uni.IdUnidad
            LEFT JOIN
                dbo.OT_SolicitudMaterialBitacora     bita (NOLOCK)
                    on sm.IdOTSolicitudMaterial = bita.IdOTSolicitudMaterial
                       and bita.IdTipoUsuario = 1
        where
            ote.IdOTEstatus not in (
                                       7, 8
                                   )
            and sc2.IsActivo = 1
            and ucc.IdUsuario = @pIdUsuario
            and sc2.IdContrato = @pIdContrato
            and (
                    (
                        sm.Cantidad > 0
                        and sol.IdOTEstatus in (
                                                   2, 3, 4, 5, 6, 9, 10, 11, 12
                                               )
                    )
                    OR sol.IdOTEstatus in (
                                              1
                                          )
                )
            and isnull(sol.IsActivo, 0) = 1
        group by
            sol.IdOTSolicitud,
            Folio,
            sm.IdOTSolicitud,
            sc.Concepto,
            sc.Descripcion,
            sm.IdServicio,
            sc.IdUnidad,
            sm.Cantidad,
            sc.Cantidad,
            t1.Cantidad,
            sc.PrecioUnitario,
            sm.Cantidad,
            sc.PrecioUnitario,
            sm.FechaProgramaInicio,
            sm.FechaProgramaFin,
            sm.CreadoPor,
            sm.CreadoEl,
            sm.ModificadoPor,
            sm.ModificadoEl,
            sol.IdSubContrato,
            Unidad,
            bita.IdOTSolicitudMaterial,
            TipoMonedaCorto,
            sol.Folio,
            sol.FechaInicio,
            sol.FechaFin,
            sc2.Objeto,
            ote.Descripcion, --join con OT_Estatus
            sc.Concepto,
            cc.CentroCosto,  -- Petrovendor..CC_CentroCosto
            sc2.NumeroSubContrato,
            SAPPR
        order by
            Folio,
            sc2.NumeroSubContrato
    end
