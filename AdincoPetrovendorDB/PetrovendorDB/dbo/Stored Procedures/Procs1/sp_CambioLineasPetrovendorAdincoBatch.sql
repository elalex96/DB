-- =============================================
-- Author:		Pedro Acuña
-- Create date: 21-01-2020
-- Description:	Cambio de lineas de presupuesto de adinco y petrovendor del grid batch
-- =============================================

CREATE PROCEDURE sp_CambioLineasPetrovendorAdincoBatch
@IdSolicitudPedidoDetalle INT,
@IdPeriodo INT,
@IdPresupuesto INT,
@IdLineaPresupuesto INT
AS
BEGIN
    DECLARE @IdPeriodoSolped INT,
            @IdPresupuestoSolped INT,
            @IdSolicitudPedido INT

    SELECT TOP 1
           @IdSolicitudPedido = IdSolicitudPedido
    FROM dbo.MM_SolicitudPedidoDetalle
    WHERE IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle

    SELECT @IdSolicitudPedido
    DECLARE @TablaRegistrosAfectados TABLE
    (
        IdSolicitudPedido INT,
        IdSolicitudPedidoDetalle INT,
        IdLineaPresupuesto INT,
        IdPedidoGral INT,
        IdAceptacion INT,
        FechaRegistro DATETIME,
        Proveedor NVARCHAR(MAX),
        Estatus NVARCHAR(MAX),
        TipoPedido NVARCHAR(MAX),
        TipoMoneda NVARCHAR(MAX),
        UUID NVARCHAR(MAX),
        IdFactura INT,
        IdRegistroPetrov INT,
        IdLineaPetrov INT,
        IdFacturaAdinco INT,
        IdRegistroAdinco INT,
        IdPrograma INT,
        Linea INT
    )

    INSERT INTO @TablaRegistrosAfectados
    EXEC dbo.sp_RegistrosAfectadosCambioLineas @IdSolicitudPedido = @IdSolicitudPedido

    SELECT @IdPeriodoSolped = IdPeriodo,
           @IdPresupuestoSolped = IdPresupuesto
    FROM dbo.MM_SolicitudPedido
    WHERE IdSolicitudPedido = @IdSolicitudPedido

    SELECT @IdPeriodoSolped,
           @IdPeriodo,
           @IdPresupuestoSolped,
           @IdPresupuesto
    IF (   @IdPeriodo <> ISNULL(@IdPeriodoSolped, 0)
           OR @IdPresupuesto <> ISNULL(@IdPresupuestoSolped, 0))
    BEGIN
        INSERT INTO dbo.HistoricoCambioLineaPeriodoPresupuesto (IdSolicitudPedido, IdPeriodoOld, IdPresupuestoOld, FechaModificado)
        SELECT @IdSolicitudPedido,
               @IdPeriodoSolped,
               @IdPresupuestoSolped,
               GETDATE()

        IF (@IdPeriodo <> ISNULL(@IdPeriodoSolped, 0))
        BEGIN
            UPDATE dbo.MM_SolicitudPedido
            SET IdPeriodo = @IdPeriodo
            WHERE IdSolicitudPedido = @IdSolicitudPedido
        END

        IF (@IdPresupuesto <> ISNULL(@IdPresupuestoSolped, 0))
        BEGIN
            UPDATE dbo.MM_SolicitudPedido
            SET IdPresupuesto = @IdPresupuesto
            WHERE IdSolicitudPedido = @IdSolicitudPedido
        END
    END

    INSERT INTO dbo.HistoricoCambioLineaSolpedDetalle
    (
        IdSolicitudPedido,
        IdSolicitudPedidoDetalle,
        IdLineaPresupuestoOld,
        FechaModificado
    )
    SELECT @IdSolicitudPedido,
           @IdSolicitudPedidoDetalle,
           IdLineaPresupuesto,
           GETDATE()
    FROM dbo.MM_SolicitudPedidoDetalleLineaPresupuesto
    WHERE IdSolicitudPedidoDetalle IN
          (   SELECT IdSolicitudPedidoDetalle
              FROM @TablaRegistrosAfectados
              WHERE IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle )

    UPDATE spdl
    SET spdl.IdLineaPresupuesto = @IdLineaPresupuesto
    FROM dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl
    WHERE spdl.IdSolicitudPedidoDetalle IN
          (   SELECT IdSolicitudPedidoDetalle
              FROM @TablaRegistrosAfectados
              WHERE IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle )
END



