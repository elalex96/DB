-- =============================================
-- Author:		Pedro Acuña
-- Create date: 22-08-2019
-- Description:	Cambio de lineas de presupuesto de adinco y petrovendor
-- =============================================

CREATE PROCEDURE sp_CambioLineasPetrovendorAdinco
    @IdSolicitudPedido INT,
    @IdPeriodo INT,
    @IdPresupuesto INT,
    @IdLineaPresupuesto INT
AS
BEGIN
    DECLARE @IdPeriodoSolped INT,
            @IdPresupuestoSolped INT

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
	DECLARE @TablaAceptacionPedidoDetalle TABLE (IdAceptacionPedidoDetalle INT)

    INSERT INTO @TablaRegistrosAfectados
    EXEC dbo.sp_RegistrosAfectadosCambioLineas @IdSolicitudPedido = @IdSolicitudPedido

    SELECT @IdPeriodoSolped = IdPeriodo,
           @IdPresupuestoSolped = IdPresupuesto	   
    FROM dbo.MM_SolicitudPedido
    WHERE IdSolicitudPedido = @IdSolicitudPedido

    IF (
           @IdPeriodo <> ISNULL(@IdPeriodoSolped, 0)
           OR @IdPresupuesto <> ISNULL(@IdPresupuestoSolped, 0)
       )
    BEGIN
        INSERT INTO dbo.HistoricoCambioLineaPeriodoPresupuesto
        (
            IdSolicitudPedido,
            IdPeriodoOld,
            IdPresupuestoOld,
            FechaModificado
        )
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
           IdSolicitudPedidoDetalle,
           IdLineaPresupuesto,
           GETDATE()
    FROM dbo.MM_SolicitudPedidoDetalleLineaPresupuesto
    WHERE IdSolicitudPedidoDetalle IN
          (
              SELECT IdSolicitudPedidoDetalle FROM @TablaRegistrosAfectados
          )

    UPDATE spdl
    SET spdl.IdLineaPresupuesto = @IdLineaPresupuesto
    FROM dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl
    WHERE spdl.IdSolicitudPedidoDetalle IN
          (
              SELECT IdSolicitudPedidoDetalle FROM @TablaRegistrosAfectados
          )

    INSERT INTO dbo.HistoricoCambioLineaRegistroPetrov
    (
        IdSolicitudPedido,
        IdRegistro,
        IdLineaPresupuestoOld,
        FechaModificado
    )
    SELECT @IdSolicitudPedido,
           r.IdRegistro,
           r.IdLineaPresupuestoMes,
           GETDATE()
    FROM dbo.CO_Registro r
    WHERE r.IdRegistro IN
          (
              SELECT IdRegistroPetrov FROM @TablaRegistrosAfectados
          )
	
	INSERT INTO @TablaAceptacionPedidoDetalle (IdAceptacionPedidoDetalle)
	SELECT r.IdAceptacionPedidoDetalle
    FROM dbo.CO_Registro r
    WHERE r.IdRegistro IN
          (
              SELECT IdRegistroPetrov FROM @TablaRegistrosAfectados
          )AND r.IdAceptacionPedidoDetalle IS NOT NULL

	UPDATE dbo.MM_AceptacionPedidoDetalleInstalacion
	SET IdLineaPresupuesto = @IdLineaPresupuesto
	WHERE IdAceptacionPedidoDetalle IN (SELECT IdAceptacionPedidoDetalle FROM @TablaAceptacionPedidoDetalle)

    UPDATE r
    SET r.IdLineaPresupuestoMes = @IdLineaPresupuesto
    FROM dbo.CO_Registro r
    WHERE r.IdRegistro IN
          (
              SELECT IdRegistroPetrov FROM @TablaRegistrosAfectados
          )

    INSERT INTO dbo.HistoricoCambioLineaRegistroAdinco
    (
        IdSolicitudPedido,
        IdRegistro,
        IdProgramaOld,
        FechaModificado
    )
    SELECT @IdSolicitudPedido,
           r.IdRegistro,
           r.IdPrograma,
           GETDATE()
    FROM Adinco.dbo.CO_Registro r
    WHERE r.IdRegistro IN
          (
              SELECT IdRegistroAdinco FROM @TablaRegistrosAfectados
          )

    UPDATE r
    SET r.IdPrograma = @IdLineaPresupuesto
    FROM Adinco.dbo.CO_Registro r
    WHERE r.IdRegistro IN
          (
              SELECT IdRegistroAdinco FROM @TablaRegistrosAfectados
          )

END



