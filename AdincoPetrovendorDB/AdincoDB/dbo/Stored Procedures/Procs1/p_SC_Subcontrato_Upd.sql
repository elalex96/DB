IF OBJECT_ID('[dbo].[p_SC_Subcontrato_Upd]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[p_SC_Subcontrato_Upd]
GO

CREATE PROCEDURE [dbo].[p_SC_Subcontrato_Upd]
(
    @pIdSubContrato     INT,
    @pIdSubContratista  INT,
    @pNumeroSubContrato VARCHAR(20),
    @pObjeto            VARCHAR(300),
    @pIdCentroCosto     INT,
    @pIdContratista     INT,
    @pIdMoneda          INT,
    @pPrefijoOT         VARCHAR(13),
    @pFechaInicio       DATETIME = NULL,
    @pFechaFin          DATETIME = NULL,
    @pError             VARCHAR(250) = '' OUT
)
AS
BEGIN
    CREATE TABLE #OTSolicitudesSubcontrato
    (
        Id INT IDENTITY(1,1),
        IdOTSolicitud INT,
        IdSubContrato INT,
        IdOTEstimacion INT,
        IdSolicitudPedido INT,
        IdPedido INT
    );

    CREATE TABLE #OTEstNoPuedeModificar
    (
        Id INT IDENTITY(1,1),
        IdOTEstimacion INT
    );

    DECLARE @MonedaIdAntes INT = 0;

    IF (SUBSTRING(@pPrefijoOT, 1, 3) <> 'OT-')
    BEGIN
        SET @pPrefijoOT = 'OT-' + @pPrefijoOT;
    END

    IF EXISTS (
        SELECT 1
        FROM SC_SubContrato (NOLOCK)
        WHERE NumeroSubContrato = @pNumeroSubContrato
          AND IdSubContrato <> @pIdSubContrato
          AND IdContratista = @pIdContratista
          AND IsActivo = 1
    )
    BEGIN
        SET @pError = '[ALERTA] Este número de Sub Contrato está siendo utilizado en otro contrato activo, es necesario modificar.';
        RETURN;
    END

    SELECT @MonedaIdAntes = IdMoneda
    FROM SC_SubContrato (NOLOCK)
    WHERE IdSubContrato = @pIdSubContrato;

    UPDATE SC_SubContrato
    SET IdSubContratista = @pIdSubContratista,
        NumeroSubContrato = @pNumeroSubContrato,
        Objeto = @pObjeto,
        IdCentroCosto = @pIdCentroCosto,
        IdMoneda = @pIdMoneda,
        PrefijoOT = @pPrefijoOT,
        FechaInicio = @pFechaInicio,
        FechaFin = @pFechaFin
    WHERE IdSubContrato = @pIdSubContrato;

    IF (@MonedaIdAntes <> @pIdMoneda)
    BEGIN
        INSERT INTO #OTSolicitudesSubcontrato (IdOTSolicitud, IdSubContrato, IdOTEstimacion, IdSolicitudPedido, IdPedido)
        SELECT s.IdOTSolicitud, s.IdSubContrato, e.IdOTEstimacion, e.IdSolicitudPedido, e.IdPedido
        FROM OT_Solicitud s (NOLOCK)
        JOIN OT_Estimacion e (NOLOCK) ON s.IdOTSolicitud = e.IdOTSolicitud
        WHERE s.IdSubContrato = @pIdSubContrato
          AND s.IsActivo = 1
          AND s.IdOTEstatus <> 12;

        UPDATE OT_Solicitud
        SET IdMoneda = @pIdMoneda
        WHERE IdSubContrato = @pIdSubContrato
          AND IsActivo = 1
          AND IdOTEstatus <> 12;

        INSERT INTO #OTEstNoPuedeModificar (IdOTEstimacion)
        SELECT ots.IdOTEstimacion
        FROM #OTSolicitudesSubcontrato ots
        JOIN petrovendor..MM_Pedido p (NOLOCK) ON ots.IdPedido = p.IdPedido
        JOIN petrovendor..MM_AceptacionPedido ap (NOLOCK) ON p.IdPedido = ap.IdPedido
        JOIN petrovendor..MM_AceptacionCartaPCN cn (NOLOCK) ON ap.IdAceptacionPedido = cn.IdAceptacionPedido
        WHERE ap.Activo = 1
          AND ISNULL(cn.IdEliminado, 0) = 0
          AND cn.IdEstatus = 2
        GROUP BY ots.IdOTEstimacion;

        DELETE FROM #OTSolicitudesSubcontrato
        WHERE IdOTEstimacion IN (SELECT IdOTEstimacion FROM #OTEstNoPuedeModificar);

        IF (EXISTS (SELECT 1 FROM #OTSolicitudesSubcontrato))
        BEGIN
            UPDATE pod
            SET pod.IdMoneda = @pIdMoneda
            FROM #OTSolicitudesSubcontrato ots
            JOIN petrovendor..MM_PeticionOferta po (NOLOCK) ON ots.IdSolicitudPedido = po.IdSolicitudPedido
            JOIN petrovendor..MM_PeticionOfertaDetalle pod (NOLOCK) ON po.IdPeticionOferta = pod.IdPeticionOferta;

            UPDATE p
            SET p.IdMoneda = @pIdMoneda
            FROM #OTSolicitudesSubcontrato ots
            JOIN petrovendor..MM_Pedido p (NOLOCK) ON ots.IdPedido = p.IdPedido;

            UPDATE pdp
            SET pdp.IdMoneda = @pIdMoneda
            FROM #OTSolicitudesSubcontrato ots
            JOIN petrovendor..MM_PedidoDetalle pdp (NOLOCK) ON ots.IdPedido = pdp.IdPedido;

            SET @pError = '[ACTUALIZACIÓN] SE ACTUALIZÓ LA MONEDA DE PEDIDOS DE PROCURA SIN CARTA APROBADA';
            RETURN;
        END
    END
END
