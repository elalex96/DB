CREATE PROCEDURE ActualizarRequisicion
@IdSolicitudPedidoDetalle INT,
@IdProveedor INT,
@IdMaterial INT,
@IdDomicilioEntrega INT,
@observaciones NVARCHAR(MAX),
@Cantidad MONEY,
@IdUnidad INT,
@IdUsuario INT,
@IdIdentificador NVARCHAR(MAX)
AS
BEGIN
    DECLARE @IdSolicitudPedido INT,
            @IdEstatusOperacion INT,
            @IdOperacion INT,
            @PeticionEnviada BIT,
			@NombreUsuarioModifico NVARCHAR(MAX)

    --Ya que fue actualizada la informacion entonces hay que reiniciar el flujo de aprobacion de la solped
    SELECT @IdSolicitudPedido = IdSolicitudPedido
    FROM dbo.MM_SolicitudPedidoDetalle
    WHERE IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle

	SELECT @NombreUsuarioModifico = Nombre FROM dbo.S_Usuario WHERE IdUsuario = @IdUsuario

    SELECT @PeticionEnviada = PeticionEnviada
    FROM dbo.MM_SolicitudPedido
    WHERE IdSolicitudPedido = @IdSolicitudPedido

    -- si no ah sido enviada
    IF (ISNULL(@PeticionEnviada,0) = 0)
    BEGIN
        INSERT INTO dbo.HistoricoSolicitudPedidoDetalle
        (
            IdSolicitudPedidoDetalle,
            IdMaterial,
            IdDomicilio,
            Observaciones,
            Cantidad,
            IdUnidad,
            FechaRegistro,
            IdUsuarioModifico
        )
        SELECT @IdSolicitudPedidoDetalle,
               @IdMaterial,
               @IdDomicilioEntrega,
               @observaciones,
               @Cantidad,
               @IdUnidad,
               GETDATE(),
               @IdUsuario

        UPDATE spd
        SET spd.IdMaterial = @IdMaterial,
            spd.observaciones = @observaciones,
            spd.Cantidad = @Cantidad,
            spd.IdUnidad = @IdUnidad,
            spd.IdDomicilioEntrega = @IdDomicilioEntrega,
            spd.editado = 1,
            spd.FechaModificado = GETDATE()
        FROM dbo.MM_SolicitudPedidoDetalle spd
            INNER JOIN dbo.MM_SolicitudPedido sp
                ON sp.IdSolicitudPedido = spd.IdSolicitudPedido
        WHERE spd.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle
              AND sp.IdProveedor = @IdProveedor

        SELECT @IdEstatusOperacion = tao.IdEstatusOperacion,
               @IdOperacion = tao.IdOperacion
        FROM dbo.TA_Operacion tao
        WHERE IdTipoOperacion = 2
              AND IdDocumento = @IdSolicitudPedido
              AND ISNULL(IdEstatusEliminado, 0) = 0


        -- si algun usuario aprobo o rechazo entonces hay que setearlos a todos en aprobacion
        IF EXISTS
        (   SELECT 1
            FROM dbo.TA_Tarea
            WHERE IdEstatus IN ( 2, 3 )
                  AND IdOperacion = @IdOperacion)
        BEGIN
            UPDATE dbo.TA_Tarea
            SET IdEstatus = 1
            WHERE IdOperacion = @IdOperacion

            -- agregar a la bandera para saber que se debe de enviar los correos
            INSERT INTO dbo.RequisicionBandera (IdSolicitudPedido, IdUsuario, EnviarCorreo, FechaRegistro, Identificador)
            SELECT @IdSolicitudPedido,
                   @IdUsuario,
                   1,
                   GETDATE(),
				   @IdIdentificador
			
			INSERT INTO dbo.TA_HistorialFlujoTarea (Descripcion, IdOperacion, Fecha, IdEstadoFlujo)
			VALUES
			(   N'El usuario ' + @NombreUsuarioModifico + ' ha reiniciado el flujo de aprobación',       -- Descripcion - nvarchar(max)
			    @IdOperacion,         -- IdOperacion - int
			    GETDATE(), -- Fecha - datetime
			    1          -- IdEstadoFlujo - int
			)
        END
	
        UPDATE tao
        SET tao.IdEstatusOperacion = 1
        FROM dbo.TA_Operacion tao
        WHERE IdDocumento = @IdSolicitudPedido
              AND IdTipoOperacion = 2
              AND ISNULL(IdEstatusEliminado, 0) = 0

    -- ya que se cambio el estatus entonces enviar los correos
    -- al requisitor solo si el no fue el que modifico
    -- tmb se debe de notificar a los aprobadores
	-- esto en el evento Grid_RowUpdated
    END
END




