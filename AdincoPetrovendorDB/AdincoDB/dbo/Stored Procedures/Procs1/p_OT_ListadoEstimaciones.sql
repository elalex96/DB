IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_ListadoEstimaciones'
    )
    DROP PROCEDURE p_OT_ListadoEstimaciones;
GO
CREATE PROCEDURE p_OT_ListadoEstimaciones -- 10,10038,1
    @pIdUsuario      int,
    @pIdContrato     int = 0,
    @pIdCentroCostos int = 0
as
    begin
        select
            ots.Folio,
            ote.FechaCorteInicio,
            ote.FechaCorteFin,
            ote.CreadoEl,
            ote.Total,
            tm.TipoMonedaCorto,
            ote.IdPedidoGeneral as IdPedido,
            pv.RazonSocial,
            ote.IdOTEstimacion
        from
            AP_UsuarioCentroCosto           ucc (NOLOCK)
            inner join
                Petrovendor..CC_CentroCosto cc (NOLOCK)
                    on ucc.IdCentroCosto = cc.IdCentroCosto
                       and ucc.IdUsuario = @pIdUsuario
            INNER JOIN
                OT_Solicitud                ots (NOLOCK)
                    on cc.IdCentroCosto = ots.IdCentroCosto
            INNER JOIN
                Adinco..OT_Estimacion       ote (NOLOCK)
                    ON ots.IdOTSolicitud = ote.IdOTSolicitud
            INNER JOIN
                PV_TipoMoneda               tm (NOLOCK)
                    on ots.IdMoneda = tm.IdMoneda
            INNER JOIN
                SC_Subcontrato              sc (NOLOCK)
                    on sc.IdSubContrato = ots.IdSubcontrato
            INNER JOIN
                PV_Subcontratista           pv (NOLOCK)
                    on pv.IdSubcontratista = sc.IdSubcontratista
        where
            ote.Cancelada = 0
            or ote.Cancelada is null
    end
