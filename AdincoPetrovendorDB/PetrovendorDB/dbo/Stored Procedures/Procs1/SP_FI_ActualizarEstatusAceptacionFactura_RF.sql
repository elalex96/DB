USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_FI_ActualizarEstatusAceptacionFactura_RF]    Script Date: 02/02/2022 12:02:54 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel Cruz
-- Update date: 09-10-2020
-- Description: Se agrego condición en validación de aprobaciónes aprobadas sea = al número de aprobadores 
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 30/09/2019
-- Description:	se agrego la validacion en la tarea de estatus 12(eliminado) 
-- =============================================
ALTER PROCEDURE [dbo].[SP_FI_ActualizarEstatusAceptacionFactura_RF]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @IdUsuario INT,
    @IdAceptacionPedido INT,
    @Comentario NVARCHAR(MAX),
    @IdEstatus INT,
    @IdOperacion INT,
    @ACCION NVARCHAR(200)
AS
BEGIN

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SET NOCOUNT ON;
    DECLARE @IdTarea INT;
    DECLARE @DescripcionH NVARCHAR(MAX);
    DECLARE @IdFactura INT;
    DECLARE @IdDocumento INT;
    DECLARE @ESTATUS_TEMPORAL NVARCHAR(200) = N'';
    DECLARE @FECHA_CAMBIO_ESTATUS DATETIME;

    -- SE OBTIENE EL NUMERO DE TAREA DEL APROBADOR ACTUAL  

    SELECT @IdTarea = T.IdTarea
    FROM TA_Tarea AS T
    WHERE T.IdAprobador = @IdUsuario
          AND T.IdOperacion = @IdOperacion
          AND T.Activo = 1;

    SET @FECHA_CAMBIO_ESTATUS = GETDATE();

    --- SE CAMBIA EL ESTATUS DEL APROBADOR ACTUAL Y SE VALIDA EL ESTATUS GENERAL DE LA APROBACIÓN(TA_OPERACION) QUE RESULTA AL CAMBIAR ESTATUS DEL APROBADOR ACTUAL
    -- SI ES RECHAZADA SE CONTINUA EL PROCESO NORMAL 
    -- SI ES PENDIENTE SE CONTINUA EL PROCESO NORMAL
    -- SI ES APROBADA SE DETIENE EL PROCESO PARA ENVIAR LA FACTURA A LA BD DE ADINCO
    IF @ACCION = 'CAMBIAR_ESTATUS_APROBADOR'
    BEGIN

		--ACTUALIZAR EL ESTATUS DEL USUARIO ACTUAL
        UPDATE TA_Tarea
        SET IdEstatus = @IdEstatus,
            FechaCambioEstatus = @FECHA_CAMBIO_ESTATUS,
            TA_Tarea.Comentario = @Comentario
        WHERE IdTarea = @IdTarea;

        --- OBTENER ESTATUS APROBACIÓN GENERAL CON APROBACIÓN DE APROBADOR ACTUAL

        DECLARE @CountTarea INT;
        DECLARE @CountEstApr INT;
        DECLARE @CountEstRech INT;
        DECLARE @CountEstPen INT;

        ---Glosario ---
        -- 1 Pendiente
        -- 2 Aceptada
        -- 3 Rechazada
        -- 4 Vencida
        -- 7 Reasignada
        --12 Eliminado

        ---CONTAR NUMERO DE APROBADORES EN LA APROBACION GRAL/APROBADORES
        SET @CountTarea =
        (
            SELECT COUNT(IdEstatus) AS TOTAL
            FROM TA_Operacion TAO
                JOIN TA_Tarea AS T
                    ON T.IdOperacion = TAO.IdOperacion
				JOIN S_Usuario AS US
					ON T.IdAprobador = US.IdUsuario
						AND US.Activo = 1
            WHERE TAO.IdOperacion = @IdOperacion
                  AND T.IdEstatus <> 7 --> NO SEA REASIGNADO
                  AND T.IdEstatus <> 12 --> NO ESTE ELIMINADO
                  AND T.Activo = 1 --> ESTE ACTIVO
        );
        
        --- CONTAR NUMERO DE APROBADORES QUE FALTAN POR APROBAR 
        SET @CountEstPen =
        (
            SELECT COUNT(IdEstatus) AS TOTAL
            FROM TA_Operacion TAO
                JOIN TA_Tarea AS T
                    ON T.IdOperacion = TAO.IdOperacion
				JOIN S_Usuario AS US
					ON T.IdAprobador = US.IdUsuario
						AND US.Activo = 1
            WHERE TAO.IdOperacion = @IdOperacion
                  AND T.IdEstatus = 1
                  AND T.Activo = 1
        );
        --- CONTAR NUMERO DE APROBADORES QUE YA APROBARON 
        SET @CountEstApr =
        (
            SELECT COUNT(IdEstatus) AS TOTAL
            FROM TA_Operacion TAO
                JOIN TA_Tarea AS T
                    ON T.IdOperacion = TAO.IdOperacion
				JOIN S_Usuario AS US
					ON T.IdAprobador = US.IdUsuario
						AND US.Activo = 1
            WHERE TAO.IdOperacion = @IdOperacion
                  AND T.IdEstatus = 2 --> APROBARON
                  AND T.Activo = 1
        );

        --- CONTAR NUMERO DE APROBADORES QUE RECHAZARON 
        SET @CountEstRech =
        (
            SELECT COUNT(IdEstatus) AS TOTAL
            FROM TA_Operacion TAO
                JOIN TA_Tarea AS T
                    ON T.IdOperacion = TAO.IdOperacion
				JOIN S_Usuario AS US
					ON T.IdAprobador = US.IdUsuario
						AND US.Activo = 1
            WHERE TAO.IdOperacion = @IdOperacion
                  AND T.IdEstatus = 3 --> RECHAZARON 
                  AND T.Activo = 1
        );


        BEGIN
            IF (@CountEstRech > 0)
            BEGIN
                -- LA APROBACION GRAL FUE RECHAZADA
                SET @ESTATUS_TEMPORAL = N'CONTINUAR_APROBACION_GENERAL';
            END;
            ELSE IF (@CountEstApr = @CountTarea AND @CountEstPen = 0)
            BEGIN
                -- LA APROBACION GRAL FUE ACEPTADA YA QUE FALTAN 0 APROBADORES POR APROBAR Y 
                -- LA CANTIDAD DE APROBADORES ES IGUAL A LA CANTIDAD DE USUARIOS QUE APROBARON              
                SET @ESTATUS_TEMPORAL = N'DETENER_APROBACION_GENERAL';
            -- SE CANCELA POR QUE SE TIENE QUE ENVIAR PRIMERO LA FACTURA A LA BD DE ADINCO 
            END;
            ELSE
            BEGIN
                -- LA APROBACIÓN SIGUE EN PENDIENTE
                SET @ESTATUS_TEMPORAL = N'CONTINUAR_APROBACION_GENERAL';
            END;
        END;
    END;

    --- LA FACTURA YA FUE ENVIADA A BD DE ADINCO SE TIENE QUE CONTINUAR LA ACTUALIZACIÓN DEL ESTATUS GRAL DE LA APROBACIÓN
    IF @ACCION = 'ENVIADA_CAMBIAR_ESTATUS_APROBADOR_APROBADO'
    BEGIN
        SET @ESTATUS_TEMPORAL = N'CONTINUAR_APROBACION_GENERAL';
    END;

    --- LA FACTURA DE ADINCO POR ALGUNA RAZON NO SE ENVIO A LA BD DE ADINCO, REVERTIR APROBACIÓN DEL USUARIO ACTUAL NO SE ACTUALIZA ESTATUS DE APROBACIÓN GRAL
    IF @ACCION = 'REGRESAR_ESTATUS_APROBADOR_PENDIENTE'
    BEGIN
        SET @ESTATUS_TEMPORAL = N'';
        UPDATE TA_Tarea
        SET IdEstatus = 1,
            FechaCambioEstatus = NULL,
            Comentario = ''
        WHERE IdTarea = @IdTarea;
        SELECT 'SUCCESS';
    END;


    --- # PROCESO DEACUERDO AL ESTATUS GRAL DE LA APROBACIÓN 

    --- SE RETORNA MENSAJE PARA ENVIAR FACTURA A LA BD DE ADINCO 
    IF @ESTATUS_TEMPORAL = 'DETENER_APROBACION_GENERAL'
    BEGIN


        SELECT @IdFactura = IdFactura
        FROM MM_AceptacionFactura
        WHERE IdAceptacionPedido = @IdAceptacionPedido;

        SELECT @IdDocumento = IdDocumento
        FROM TA_Operacion
        WHERE IdOperacion = @IdOperacion;

        SELECT 'ENVIAR_FACTURA',
               ISNULL(@IdFactura, 0),
               ISNULL(@IdDocumento, 0);

    END;

    --- ENTRA A ESTA CONDICION SIEMPRE Y CUANDO LA APROBACIÓN GRAL SER RECHAZADA,PENDIENTE O YA SE ENVIO LA FACTURA 
    IF @ESTATUS_TEMPORAL = 'CONTINUAR_APROBACION_GENERAL'
    BEGIN

        -- ACTUALIZAR ESTATUS DE TAREA ---

        UPDATE TA_Tarea
        SET IdEstatus = @IdEstatus,
            FechaCambioEstatus = GETDATE(),
            Comentario = @Comentario
        WHERE IdTarea = @IdTarea;

        ----AGREGAR EVENTO AL HISTORIAL DE LA APROBACIÓN---

        DECLARE @ESTATUSTA NVARCHAR(MAX);
        SELECT @ESTATUSTA = Nombre
        FROM TA_Estatus
        WHERE IdEstatus = @IdEstatus;

        IF @ESTATUSTA = 'Aprobada'
        BEGIN
            SET @ESTATUSTA = N'Aprobado';
        END;

        IF @ESTATUSTA = 'Rechazada'
        BEGIN
            SET @ESTATUSTA = N'Rechazado';
        END;
        IF @ESTATUSTA = 'Vencida'
        BEGIN
            SET @ESTATUSTA = N'Vencido';
        END;
        SET @DescripcionH
            = N'El Usuario ' +
              (
                  SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdUsuario
              ) + N' ha ' + @ESTATUSTA + N' la Tarea.';
        IF @Comentario <> ''
        BEGIN
            SET @DescripcionH = @DescripcionH + N' Detalle: ' + @Comentario;
        END;

        INSERT INTO TA_HistorialFlujoTarea
        (
            IdOperacion,
            Fecha,
            Descripcion,
            IdEstadoFlujo
        )
        VALUES
        (@IdOperacion, GETDATE(), @DescripcionH, 2);


        --- EJECUTAR EL CAMBIO DE ESTATUS GENERAL DE LA OPERACION  -----

        EXEC SP_TA_CambiarEstatusFlujoFactura @IdOperacion, @IdAceptacionPedido;


        --- OBTENER LA INFORMACIÓN DEL FLUJO, LISTA DE APROBADORES  --- 


        SELECT @IdFactura = IdFactura
        FROM MM_AceptacionFactura
        WHERE IdAceptacionPedido = @IdAceptacionPedido;


        SELECT DISTINCT
               TOO.IdDocumento,
               FT.IdFlujoTarea,
               FT.IdTipoFlujo,
               TOO.IdEstatusOperacion,
               TAE.Nombre,
               TOO.IdEstadoFlujo,
               TOO.IdTipoOperacion,
               TTO.NombreOperacion,
               U.IdUsuario,
               T.NoSecuencia,
               U.Nombre,
               U.Correo,
               T.IdEstatus,
               TOO.IdOperacion,
               TOO.IdAsignador,
               TOO.IdProveedor,
               @IdFactura AS IdFactura,
               @Comentario,
               TAE.Name
        FROM TA_Tarea AS T
            JOIN TA_Operacion AS TOO
                ON TOO.IdOperacion = T.IdOperacion
            JOIN TA_FlujoTarea AS FT
                ON FT.IdFlujoTarea = TOO.IdFlujoTarea
            JOIN S_Usuario AS U
                ON U.IdUsuario = T.IdAprobador
            JOIN TA_TipoOperacion AS TTO
                ON TTO.IdTipoOperacion = TOO.IdTipoOperacion
            JOIN TA_Estatus AS TAE
                ON TAE.IdEstatus = TOO.IdEstatusOperacion
        WHERE T.IdOperacion = @IdOperacion
              AND T.Activo = 1
        ORDER BY NoSecuencia ASC;

    END;

END;
