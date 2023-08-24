USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_TA_ActualizarEstatusTarea_CD'
)
    DROP PROCEDURE SP_TA_ActualizarEstatusTarea_CD;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 12-02-18
-- Description: Actualizar Estutus aprobador de compra directa temporal
--Temporal por que solo actualiza el estatus del aprobador y no el del estutus general esperando una respuesta si se envia la factura de adinco procede a ejecutar el 
-- SP SP_TA_ActualizarEstatusTarea
-- =============================================
-- Modified:		Alexander Gomez
-- Create date: 16-08-2023
-- Description:	se agrega la actualizacion del campo updateByApp para localizacion de actualizaciones desde la app
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ActualizarEstatusTarea_CD]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @IdUsuario INT,
    @Comentario NVARCHAR(MAX),
    @IdEstatus INT,
    @IdOperacion INT,
    @ACCION NVARCHAR(200),
    @IdFirma NVARCHAR(200),
    @IdContrato INT = 0,
    @FechaRegistro DATETIME = '12-02-2018',
	@updateByApp BIT = NULL

AS
BEGIN

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SET NOCOUNT ON;
    DECLARE @IdTarea INT;
    DECLARE @IdFlujoTarea INT;
    DECLARE @IdOperacionR INT;
    DECLARE @DescripcionH NVARCHAR(MAX);
    DECLARE @IdFactura INT;
    DECLARE @IdAsignador INT;
    DECLARE @ESTATUS_TEMPORAL NVARCHAR(200) = '';
    DECLARE @FECHA_CAMBIO_ESTATUS DATETIME;

    -- SE OBTIENE EL NUMERO DE TAREA DEL APROBADOR ACTUAL 
    SET @IdTarea =
    (
        SELECT T.IdTarea
        FROM TA_Tarea AS T (NOLOCK)
        WHERE IdAprobador = @IdUsuario
              AND T.IdOperacion = @IdOperacion
    );

    SET @FECHA_CAMBIO_ESTATUS = GETDATE();

    --- SE CAMBIA EL ESTATUS DEL APROBADOR ACTUAL Y SE VALIDA EL ESTATUS GENERAL DE LA APROBACIÓN(TA_OPERACION) QUE RESULTA AL CAMBIAR ESTATUS DEL APROBADOR ACTUAL
    -- SI ES RECHAZADA SE CONTINUA EL PROCESO NORMAL 
    -- SI ES PENDIENTE SE CONTINUA EL PROCESO NORMAL
    -- SI ES APROBADA SE DETIENE EL PROCESO PARA ENVIAR LA FACTURA A LA BD DE ADINCO
    IF @ACCION = 'CAMBIAR_ESTATUS_APROBADOR'
    BEGIN

        UPDATE TA_Tarea
        SET IdEstatus = @IdEstatus,
            FechaCambioEstatus = @FECHA_CAMBIO_ESTATUS,
            TA_Tarea.Comentario = @Comentario,
			updateByApp = @updateByApp
        WHERE IdTarea = @IdTarea;


        --- OBTENER ESTATUS APROBACIÓN GENERAL CON APROBACIÓN DE APROBADOR ACTUAL

        DECLARE @CountTarea INT;
        DECLARE @CountEstPen INT;
        DECLARE @CountEstApr INT;
        DECLARE @CountEstRech INT;
        DECLARE @CountEstCanc INT;
        DECLARE @Resultado INT = 1;

        ---Glosario ---
        -- 1 Pendiente
        -- 2 Aceptada
        -- 3 Rechazada
        -- 4 Vencida
        -- 7 Reasignada

        ---CONTAR NUMERO DE APROBADORES EN LA APROBACION GRAL
        SET @CountTarea =
        (
            SELECT COUNT(IdEstatus) AS TOTAL
            FROM TA_Operacion TAO (NOLOCK)
                INNER JOIN TA_Tarea AS T (NOLOCK)
                    ON TAO.IdOperacion = T.IdOperacion
            WHERE TAO.IdOperacion = @IdOperacion
                  AND T.IdEstatus <> 7
        );

        --- T.IdEstatus <> 7 ---> Es Cancelado por Reasignación ---
        --- CONTAR NUMERO DE APROBADORES QUE FALTAN POR APROBAR 
        SET @CountEstPen =
        (
            SELECT COUNT(IdEstatus) AS TOTAL
            FROM TA_Operacion TAO (NOLOCK)
                INNER JOIN TA_Tarea AS T (NOLOCK)
                    ON TAO.IdOperacion = T.IdOperacion
            WHERE TAO.IdOperacion = @IdOperacion
                  AND T.IdEstatus = 1
        );
        --- CONTAR NUMERO DE APROBADORES QUE YA APROBARON 
        SET @CountEstApr =
        (
            SELECT COUNT(IdEstatus) AS TOTAL
            FROM TA_Operacion TAO (NOLOCK)
                INNER JOIN TA_Tarea AS T (NOLOCK)
                    ON TAO.IdOperacion = T.IdOperacion 
            WHERE TAO.IdOperacion = @IdOperacion
                  AND T.IdEstatus = 2
        );

        --- CONTAR NUMERO DE APROBADORES QUE RECHAZARON 
        SET @CountEstRech =
        (
            SELECT COUNT(IdEstatus) AS TOTAL
            FROM TA_Operacion TAO (NOLOCK)
                INNER JOIN TA_Tarea AS T (NOLOCK)
                    ON TAO.IdOperacion = T.IdOperacion
            WHERE TAO.IdOperacion = @IdOperacion
                  AND T.IdEstatus = 3
        );

        SELECT @IdFactura = IdDocumento
        FROM TA_Operacion (NOLOCK)
        WHERE IdOperacion = @IdOperacion;

        SELECT @IdAsignador = IdAsignador
        FROM TA_Operacion (NOLOCK)
        WHERE IdOperacion = @IdOperacion;


        BEGIN
            IF (@CountEstRech > 0)
            BEGIN
                -- LA APROBACION GRAL FUE RECHAZADA
                -- REGRESAR EL ESTATUS A 1 PARA CAMBIAR ESTATUS EN EN EL SP SP_TA_ActualizarEstatusTarea
                UPDATE TA_Tarea
                SET IdEstatus = 1,
                    FechaCambioEstatus = NULL,
                    TA_Tarea.Comentario = '',
					updateByApp = @updateByApp
                WHERE IdTarea = @IdTarea;
                SELECT  'CONTINUAR_APROBACION_GENERAL',
                        ISNULL(@IdFactura, 0),
                        ISNULL(@IdAsignador, 0);
            END;
            ELSE IF (@CountEstApr = @CountTarea)
            BEGIN
                -- LA APROBACION GRAL FUE ACEPTADA               
                -- SET @ESTATUS_TEMPORAL = 'DETENER_APROBACION_GENERAL'   
                -- SE CANCELA POR QUE SE TIENE QUE ENVIAR PRIMERO LA FACTURA A LA BD DE ADINCO 

                -- REGRESAR EL ESTATUS A 1 PARA CAMBIAR ESTATUS EN EN EL SP SP_TA_ActualizarEstatusTarea
                UPDATE TA_Tarea
                SET IdEstatus = 1,
                    FechaCambioEstatus = NULL,
                    TA_Tarea.Comentario = '',
					updateByApp = @updateByApp
                WHERE IdTarea = @IdTarea;

                SELECT 'ENVIAR_FACTURA',
                       ISNULL(@IdFactura, 0),
                       ISNULL(@IdAsignador, 0);

            END;
            ELSE
            BEGIN
                -- LA APROBACIÓN SIGUE EN PENDIENTE
                -- REGRESAR EL ESTATUS A 1 PARA CAMBIAR ESTATUS EN EN EL SP SP_TA_ActualizarEstatusTarea
                UPDATE TA_Tarea
                SET IdEstatus = 1,
                    FechaCambioEstatus = NULL,
                    TA_Tarea.Comentario = '',
					updateByApp = @updateByApp
                WHERE IdTarea = @IdTarea;

               SELECT  'CONTINUAR_APROBACION_GENERAL',
                        ISNULL(@IdFactura, 0),
                        ISNULL(@IdAsignador, 0);
            END;
        END;
    END;

    --- LA FACTURA DE ADINCO POR ALGUNA RAZON NO SE ENVIO A LA BD DE ADINCO, REVERTIR APROBACIÓN DEL USUARIO ACTUAL NO SE ACTUALIZA ESTATUS DE APROBACIÓN GRAL
    IF @ACCION = 'REGRESAR_ESTATUS_APROBADOR_PENDIENTE'
    BEGIN
        SET @ESTATUS_TEMPORAL = '';
        UPDATE TA_Tarea
        SET IdEstatus = 1,
            FechaCambioEstatus = NULL,
            TA_Tarea.Comentario = '',
			updateByApp = @updateByApp
        WHERE IdTarea = @IdTarea;
        SELECT 'SUCCESS',
                ISNULL(@IdFactura, 0),
                ISNULL(@IdAsignador, 0);
    END;
END;


