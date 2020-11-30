
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 16-08-17
-- Description:	Actualiza el estatus de aprobador y de la aprobacion general  
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ActualizarEstatusAceptacionPedimentoComprobante]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @IdUsuario INT,
    @IdAceptacionPedido INT,
    @Comentario NVARCHAR(MAX),
    @IdEstatus INT,
    @IdOperacion INT,
    @ACCION NVARCHAR(200)


--- SP_FI_ActualizarEstatusAceptacionFactura_RF 420,2205,48,'ejemplo', 1,2400


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
	DECLARE @IdDocumento INT;
	DECLARE @ESTATUS_TEMPORAL NVARCHAR(200) = ''
	DECLARE @FECHA_CAMBIO_ESTATUS DATETIME

	-- SE OBTIENE EL NUMERO DE TAREA DEL APROBADOR ACTUAL 
    SET @IdTarea =
    (
        SELECT T.IdTarea
        FROM TA_Tarea AS T
        WHERE IdAprobador = @IdUsuario
              AND T.IdOperacion = @IdOperacion
    );

	SET @FECHA_CAMBIO_ESTATUS = GETDATE()

	--- SE CAMBIA EL ESTATUS DEL APROBADOR ACTUAL Y SE VALIDA EL ESTATUS GENERAL DE LA APROBACIÓN(TA_OPERACION) QUE RESULTA AL CAMBIAR ESTATUS DEL APROBADOR ACTUAL
		-- SI ES RECHAZADA SE CONTINUA EL PROCESO NORMAL 
		-- SI ES PENDIENTE SE CONTINUA EL PROCESO NORMAL
		-- SI ES APROBADA SE DETIENE EL PROCESO PARA ENVIAR LA FACTURA A LA BD DE ADINCO
    IF @ACCION = 'CAMBIAR_ESTATUS_APROBADOR'
    BEGIN

        UPDATE TA_Tarea
        SET IdEstatus = @IdEstatus,
            FechaCambioEstatus = @FECHA_CAMBIO_ESTATUS,
            TA_Tarea.Comentario = @Comentario
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
            FROM TA_Operacion TAO
                INNER JOIN TA_Tarea AS T
                    ON T.IdOperacion = TAO.IdOperacion
            WHERE TAO.IdOperacion = @IdOperacion
                  AND T.IdEstatus <> 7
        );

        --- T.IdEstatus <> 7 ---> Es Cancelado por Reasignación ---
		--- CONTAR NUMERO DE APROBADORES QUE FALTAN POR APROBAR 
        SET @CountEstPen =
        (
            SELECT COUNT(IdEstatus) AS TOTAL
            FROM TA_Operacion TAO
                INNER JOIN TA_Tarea AS T
                    ON T.IdOperacion = TAO.IdOperacion
            WHERE TAO.IdOperacion = @IdOperacion
                  AND T.IdEstatus = 1
        );
		--- CONTAR NUMERO DE APROBADORES QUE YA APROBARON 
        SET @CountEstApr =
        (
            SELECT COUNT(IdEstatus) AS TOTAL
            FROM TA_Operacion TAO
                INNER JOIN TA_Tarea AS T
                    ON T.IdOperacion = TAO.IdOperacion
            WHERE TAO.IdOperacion = @IdOperacion
                  AND T.IdEstatus = 2
        );

		--- CONTAR NUMERO DE APROBADORES QUE RECHAZARON 
        SET @CountEstRech =
        (
            SELECT COUNT(IdEstatus) AS TOTAL
            FROM TA_Operacion TAO
                INNER JOIN TA_Tarea AS T
                    ON T.IdOperacion = TAO.IdOperacion
            WHERE TAO.IdOperacion = @IdOperacion
                  AND T.IdEstatus = 3
        );


        BEGIN
            IF (@CountEstRech > 0)
            BEGIN
				-- LA APROBACION GRAL FUE RECHAZADA
                SET @ESTATUS_TEMPORAL = 'CONTINUAR_APROBACION_GENERAL'  
            END;
            ELSE IF (@CountEstApr = @CountTarea)
            BEGIN  
				-- LA APROBACION GRAL FUE ACEPTADA               
				SET @ESTATUS_TEMPORAL = 'DETENER_APROBACION_GENERAL'   
				-- SE CANCELA POR QUE SE TIENE QUE ENVIAR PRIMERO LA FACTURA A LA BD DE ADINCO 
            END;
            ELSE
			BEGIN
				-- LA APROBACIÓN SIGUE EN PENDIENTE
                SET @ESTATUS_TEMPORAL = 'CONTINUAR_APROBACION_GENERAL'   
			END 
        END;
    END;

	--- EL PEDIMENTO/COMPROBANTE YA FUE ENVIADA A BD DE ADINCO SE TIENE QUE CONTINUAR LA ACTUALIZACIÓN DEL ESTATUS GRAL DE LA APROBACIÓN
	IF @ACCION = 'ENVIADA_CAMBIAR_ESTATUS_APROBADOR_APROBADO'
	BEGIN 
		SET @ESTATUS_TEMPORAL = 'CONTINUAR_APROBACION_GENERAL'
	END 

	--- LA FACTURA DE ADINCO POR ALGUNA RAZON NO SE ENVIO A LA BD DE ADINC, REVERTIR APROBACIÓN DEL USUARIO ACTUAL NO SE ACTUALIZA ESTATUS DE APROBACIÓN GRAL
	IF @ACCION = 'REGRESAR_ESTATUS_APROBADOR_PENDIENTE'
	BEGIN 
		SET @ESTATUS_TEMPORAL = ''
		UPDATE TA_Tarea
		SET IdEstatus = 1,
			FechaCambioEstatus = NULL,
			TA_Tarea.Comentario = ''
		WHERE IdTarea = @IdTarea
		SELECT 'SUCCESS'
	END 


	--- # PROCESO DE ACUERDO AL ESTATUS GRAL DE LA APROBACIÓN 

	--- SE RETORNA MENSAJE PARA ENVIAR EL PEDIMENTO/COMPROBANTE A LA BD DE ADINCO 
	IF @ESTATUS_TEMPORAL = 'DETENER_APROBACION_GENERAL'
	BEGIN 
	
		SELECT 'ENVIAR_PEDIMENTO_COMPROBANTE'

	END 

	--- ENTRA A ESTA CONDICION SIEMPRE Y CUANDO LA APROBACIÓN GRAL SER RECHAZADA,PENDIENTE O YA SE ENVIO LA FACTURA 
	IF @ESTATUS_TEMPORAL = 'CONTINUAR_APROBACION_GENERAL'
	BEGIN 
			
			-- Actualizar Estatus de Tarea ---

			UPDATE TA_Tarea
			SET IdEstatus = @IdEstatus,
				FechaCambioEstatus = GETDATE(),
				TA_Tarea.Comentario = @Comentario
			WHERE IdTarea = @IdTarea;

			----Agregar Evento al Historial  ---

			DECLARE @ESTATUSTA NVARCHAR(MAX) = (SELECT Nombre FROM TA_Estatus WHERE IdEstatus = @IdEstatus)
			IF @ESTATUSTA = 'Aprobada'
			BEGIN
				SET @ESTATUSTA = 'Aprobado'
			END

			IF @ESTATUSTA = 'Rechazada'
			BEGIN
				SET @ESTATUSTA = 'Rechazado'
			END
			IF @ESTATUSTA = 'Vencida'
			BEGIN
				SET @ESTATUSTA = 'Vencido'
			END
			SET @DescripcionH = 'El Usuario ' +
								(
									SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdUsuario
								) + ' ha ' +
								@ESTATUSTA + ' la Tarea.';
			IF @Comentario <> ''
			BEGIN
				SET @DescripcionH = @DescripcionH + ' Detalle: ' + @Comentario;
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


			--- Ejecutar el Cambio de Estatus General de la Operacion  -----

			EXEC SP_PC_CambiarEstatusFlujoPeticionComprobante @IdOperacion, @IdAceptacionPedido;


			--- Obtener la información del flujo --- 

		
			SELECT DISTINCT
				TOO.IdDocumento,--0
				FT.IdFlujoTarea,--1
				FT.IdTipoFlujo,--2
				TOO.IdEstatusOperacion,--3
				TAE.Nombre,--4
				TOO.IdEstadoFlujo,--5
				TOO.IdTipoOperacion,--6
				TTO.NombreOperacion,--7
				U.IdUsuario,--8
				T.NoSecuencia,--9
				U.Nombre,--10
				U.Correo,--11
				T.IdEstatus,--12
				TOO.IdOperacion,--13
				TOO.IdAsignador,--14
				TOO.IdProveedor,		--15	
				TAE.Nombre,--16
				TAE.Nombre--17	
			FROM TA_Tarea AS T
				INNER JOIN TA_Operacion AS TOO
					ON TOO.IdOperacion = T.IdOperacion
				INNER JOIN TA_FlujoTarea AS FT
					ON FT.IdFlujoTarea = TOO.IdFlujoTarea
				---INNER JOIN TA_Aprobador  AS TAA on TAA.IdUsuario= T.IdAprobador  AND TAA.IdFlujoTarea = FT.IdFlujoTarea
				INNER JOIN S_Usuario AS U
					ON U.IdUsuario = T.IdAprobador
				INNER JOIN TA_TipoOperacion AS TTO
					ON TTO.IdTipoOperacion = TOO.IdTipoOperacion
				INNER JOIN TA_Estatus AS TAE
					ON TAE.IdEstatus = TOO.IdEstatusOperacion
			WHERE T.IdOperacion = @IdOperacion
				  AND T.Activo = 1
			ORDER BY NoSecuencia ASC;

	END
	
END;


