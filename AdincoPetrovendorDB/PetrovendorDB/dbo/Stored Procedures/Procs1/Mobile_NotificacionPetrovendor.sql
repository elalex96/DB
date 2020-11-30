
-- =============================================
-- Author:		<David De La Cruz>
-- Create date: <>
-- Description:	<Se crea funcionalidad aprobacion movil por TA_Tarea>
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <15-10-2018>
-- Description:	<Se agrega funcionalidad para guardar las aprobacion por Operacion, para la aprobacion de pedido>
-- =============================================

CREATE PROCEDURE [dbo].[Mobile_NotificacionPetrovendor]
    @IdtareaIdentity INT, --GetIdentity
    @IdOperacion INT = NULL
AS
BEGIN

    DECLARE @TipoOperacion INT,
            @Aprobador VARCHAR(80),
            @Correo VARCHAR(100),
            @IdTareaInsertada INT,
            @IdTipoAprobacion INT,    --OK
            @IdStatusAprobacionM INT, --OK
            @IdUsuario INT,           --OK
            @IdContrato INT,          --OK
            @IdDocumento INT,         --OK
            @ComentarioDocumento VARCHAR(250),
			@IdTipoFlujoPet int,
			@Secuencia INT,
			@IntegerSecuencia INT,
            @ComentarioAprobacion VARCHAR(250);

    IF (@IdOperacion IS NULL)
    BEGIN
        SELECT @TipoOperacion = TAOP.IdTipoOperacion,
               @IdDocumento = TAOP.IdDocumento,
               @Aprobador = T.IdAprobador,
               @IdStatusAprobacionM = T.IdEstatus,
               @ComentarioAprobacion = TAOP.Descripcion
        FROM Petrovendor.dbo.TA_Tarea AS T
            LEFT JOIN Petrovendor.dbo.TA_Operacion AS TAOP
                ON T.IdOperacion = TAOP.IdOperacion
        WHERE T.IdTarea = @IdtareaIdentity;

        SET @Correo= (
		SELECT TOP 1 
		Correo
        FROM Petrovendor.dbo.S_Usuario
        WHERE IdUsuario = @Aprobador);

		-- seleccionamos el IdUsuario de ADINCO
        SET @IdUsuario = (SELECT 
							DISTINCT
							TOP 1
			    			IdUsuarioADINCO 
							FROM dbo.S_Usuario 
							WHERE Correo = @Correo
							AND Activo = 1
							AND IsEliminado =0); --IDUSUARIO

        IF @TipoOperacion = 2
        BEGIN
            SELECT @IdContrato = IdContrato,
                   @ComentarioDocumento = MotivoUrgencia
            FROM Petrovendor.dbo.MM_SolicitudPedido
            WHERE IdSolicitudPedido = @IdDocumento; --IDCONTRATO --IDDOCUMENTO
            -----------------------------------------------------------------------------

			SET @IdTipoFlujoPet =(SELECT TOP 1
			FTA.IdTipoFlujo
			FROM dbo.TA_Tarea AS TA
			JOIN dbo.TA_Operacion AS TAO ON TAO.IdOperacion = TA.IdOperacion
			JOIN dbo.TA_FlujoTarea AS FTA ON FTA.IdFlujoTarea = TAO.IdFlujoTarea
			WHERE TA.IdTarea = @IdtareaIdentity)

			IF	@IdTipoFlujoPet =2
			BEGIN
			INSERT INTO Adinco.dbo.AM_Aprobacion
            (
                IdTipoAprobacion,
                IdStatusAprobacionM,
                IdUsuario,
                IdTareaOrigen,
                IdContrato,
                FechaCreacion,
                IdDocumento,
                ComentarioDocumento,
                ComentarioAprobacion,
				EsVisible,
				TipoFlujo
            )
            VALUES
            (   @TipoOperacion,       -- IdTipoAprobacion - int
                @IdStatusAprobacionM, -- IdStatusAprobacionM - int
                @IdUsuario,           -- IdUsuario - int
                @IdtareaIdentity,     -- IdTareaOrigen - int
                @IdContrato,          -- IdContrato - int
                GETDATE(),            -- FechaCreacion - datetime
                @IdDocumento,         -- IdDocumento - int
                @ComentarioDocumento, -- ComentarioDocumento - varchar(250)
                @ComentarioAprobacion,
				1,
				@IdTipoFlujoPet
            );
            end
			IF @IdTipoFlujoPet = 1	
			BEGIN

			SET @Secuencia=(SELECT TOP 1 NoSecuencia FROM dbo.TA_Tarea WHERE IdTarea = @IdtareaIdentity)

			IF	@Secuencia = 1
			BEGIN
				SET @IntegerSecuencia = (1)
			END
			ELSE	
			BEGIN
				SET @IntegerSecuencia = (0)
            END
            
            
			INSERT INTO Adinco.dbo.AM_Aprobacion
            (
                IdTipoAprobacion,
                IdStatusAprobacionM,
                IdUsuario,
                IdTareaOrigen,
                IdContrato,
                FechaCreacion,
                IdDocumento,
                ComentarioDocumento,
                ComentarioAprobacion,
				TipoFlujo,
				NoSecuencia,
				EsVisible
            )
            VALUES
            (   @TipoOperacion,       -- IdTipoAprobacion - int
                @IdStatusAprobacionM, -- IdStatusAprobacionM - int
                @IdUsuario,           -- IdUsuario - int
                @IdtareaIdentity,     -- IdTareaOrigen - int
                @IdContrato,          -- IdContrato - int
                GETDATE(),            -- FechaCreacion - datetime
                @IdDocumento,         -- IdDocumento - int
                @ComentarioDocumento, -- ComentarioDocumento - varchar(250)
                @ComentarioAprobacion,
				@IdTipoFlujoPet,
				@Secuencia,
				@IntegerSecuencia
            );
            END
            
        END;
    END;

    IF (@IdOperacion IS NOT NULL)
    BEGIN

	--creacion de tabla temporal
			-------------------------------------
			CREATE TABLE #TempAM_Aprobacion
				(
				[IdTipoAprobacion] [int] NULL,
				[IdStatusAprobacionM] [int] NULL,
				[IdUsuario] [int] NULL,
				[IdTareaOrigen] [int] NULL,
				[IdContrato] [int] NULL,
				[FechaCreacion] [datetime] NULL,
				[FechaModificacion] [datetime] NULL,
				[IdDocumento] [int] NULL,
				[ComentarioDocumento] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
				[ComentarioAprobacion] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
				[ComentarioAprobacionRechazo] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
				[EsVisible] [bit] NULL,
				[NoVersion] [int] NULL,
				[TipoFlujo] [int] NULL,
				[NoSecuencia] [int] NULL,
				[IdPedido] [int] NULL
				) 
			-------------------------------------
		SET @IdTipoFlujoPet =(SELECT 
			TOP 1
			FTA.IdTipoFlujo
			FROM dbo.TA_Tarea AS TA
			JOIN dbo.TA_Operacion AS TAO ON TAO.IdOperacion = TA.IdOperacion
			JOIN dbo.TA_FlujoTarea AS FTA ON FTA.IdFlujoTarea = TAO.IdFlujoTarea
			WHERE TA.IdOperacion = @IdOperacion)
			--flujo paralelo
			IF	@IdTipoFlujoPet =2
			BEGIN
			INSERT INTO #TempAM_Aprobacion
				(
					IdTipoAprobacion,
					IdStatusAprobacionM,
					IdUsuario,
					IdTareaOrigen,
					IdContrato,
					FechaCreacion,
					FechaModificacion,
					IdDocumento,
					ComentarioDocumento,
					ComentarioAprobacion,
					ComentarioAprobacionRechazo,
					EsVisible,
					NoVersion,
					TipoFlujo,
					NoSecuencia,
					IdPedido
				)SELECT 
				9,
				 t.IdEstatus,
				 u.IdUsuarioADINCO,
				 t.IdTarea,
				 p.IdContrato,
				 GETDATE() AS 'FechaCreacion',
				 NULL AS 'FechaModificacion',
				o.IdDocumento,
				'Nuevo pedido' AS 'ComentarioDocumento',
				o.Descripcion AS 'ComentarioAprobacion',
				NULL AS 'ComentarioAprobacionRechazo'
				,
				1
				,o.NoVersion
				,2 AS 'TipoFlujo'
				,t.NoSecuencia
				,ps.IdPedido
				FROM dbo.TA_Tarea t
				INNER JOIN dbo.TA_Operacion o
				ON o.IdOperacion = t.IdOperacion
				AND o.IdTipoOperacion = 9
				INNER JOIN dbo.MM_Pedido p
				ON p.IdSolicitudPedido = o.IdDocumento AND p.Version = o.NoVersion
				JOIN dbo.MM_Pedidos AS ps ON p.IdPedido = ps.IdIdentificador AND p.IdProveedorCompras = ps.IdProveedorCliente
				right JOIN dbo.S_Usuario u ON u.IdUsuario = t.IdAprobador
				WHERE t.IdOperacion=@IdOperacion
		
			INSERT into adinco.dbo.AM_Aprobacion 
			(
				IdTipoAprobacion,
				IdStatusAprobacionM,
				IdUsuario,
				IdTareaOrigen,
				IdContrato,
				FechaCreacion,
				FechaModificacion,
				IdDocumento,
				ComentarioDocumento,
				ComentarioAprobacion,
				ComentarioAprobacionRechazo,
				EsVisible,
				NoVersion,
				TipoFlujo,
				NoSecuencia,
				IdPedido
			)
			SELECT IdTipoAprobacion,
				IdStatusAprobacionM,
				IdUsuario,
				IdTareaOrigen,
				IdContrato,
				FechaCreacion,
				FechaModificacion,
				IdDocumento,
				ComentarioDocumento,
				ComentarioAprobacion,
				ComentarioAprobacionRechazo,
				EsVisible,
				NoVersion,
				TipoFlujo,
				NoSecuencia,
				IdPedido FROM #TempAM_Aprobacion
            END
			--flujo serial
            IF	@IdTipoFlujoPet =1
			BEGIN
			
			INSERT INTO #TempAM_Aprobacion
				(
					IdTipoAprobacion,
					IdStatusAprobacionM,
					IdUsuario,
					IdTareaOrigen,
					IdContrato,
					FechaCreacion,
					FechaModificacion,
					IdDocumento,
					ComentarioDocumento,
					ComentarioAprobacion,
					ComentarioAprobacionRechazo,
					EsVisible,
					NoVersion,
					TipoFlujo,
					NoSecuencia,
					IdPedido
				)
				SELECT 
				9,
				 t.IdEstatus,
				 u.IdUsuarioADINCO,
				 t.IdTarea,
				 p.IdContrato,
				 GETDATE() AS 'FechaCreacion',
				 NULL AS 'FechaModificacion',
				o.IdDocumento,
				'Nuevo pedido' AS 'ComentarioDocumento',
				o.Descripcion AS 'ComentarioAprobacion',
				NULL AS 'ComentarioAprobacionRechazo'
				,
				CASE WHEN t.NoSecuencia = 1
				THEN
				'1'
				ELSE
				'0'
				END AS 'EsVisible'
				,o.NoVersion
				,1 AS 'TipoFlujo'
				,t.NoSecuencia
				,ps.IdPedido
				FROM dbo.TA_Tarea t
				INNER JOIN dbo.TA_Operacion o
				ON o.IdOperacion = t.IdOperacion
				AND o.IdTipoOperacion = 9
				INNER JOIN dbo.MM_Pedido p
				ON p.IdSolicitudPedido = o.IdDocumento AND p.Version = o.NoVersion
				JOIN dbo.MM_Pedidos AS ps ON p.IdPedido = ps.IdIdentificador AND p.IdProveedorCompras = ps.IdProveedorCliente
				right JOIN dbo.S_Usuario u ON u.IdUsuario = t.IdAprobador
				WHERE t.IdOperacion=@IdOperacion
			INSERT into adinco.dbo.AM_Aprobacion
				(
					IdTipoAprobacion,
					IdStatusAprobacionM,
					IdUsuario,
					IdTareaOrigen,
					IdContrato,
					FechaCreacion,
					FechaModificacion,
					IdDocumento,
					ComentarioDocumento,
					ComentarioAprobacion,
					ComentarioAprobacionRechazo,
					EsVisible,
					NoVersion,
					TipoFlujo,
					NoSecuencia,
					IdPedido
				)
				SELECT IdTipoAprobacion,
					IdStatusAprobacionM,
					IdUsuario,
					IdTareaOrigen,
					IdContrato,
					FechaCreacion,
					FechaModificacion,
					IdDocumento,
					ComentarioDocumento,
					ComentarioAprobacion,
					ComentarioAprobacionRechazo,
					EsVisible,
					NoVersion,
					TipoFlujo,
					NoSecuencia,
					IdPedido FROM #TempAM_Aprobacion
            END
    END;
END;

