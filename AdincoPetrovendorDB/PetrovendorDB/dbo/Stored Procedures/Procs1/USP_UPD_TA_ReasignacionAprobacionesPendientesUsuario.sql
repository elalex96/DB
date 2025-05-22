USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_UPD_TA_ReasignacionAprobacionesPendientesUsuario'
)
 DROP PROCEDURE USP_UPD_TA_ReasignacionAprobacionesPendientesUsuario;
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author: Daniel AC  
-- Create date: 05-04-2021  
-- Description: Realizar reasignación de tareas de aprobaciones masivamente  
-- =============================================  
CREATE PROCEDURE [dbo].[USP_UPD_TA_ReasignacionAprobacionesPendientesUsuario] 
 @TareasIds NVARCHAR(MAX),
 @ContratoId INT,
 @AprobadorActualId INT,
 @NuevoAprobadorId INT,
 @ProveedorId INT,
 @Justificacion NVARCHAR(MAX)
AS
BEGIN
BEGIN TRY
BEGIN TRAN

		
DECLARE @Contador INT = 1
DECLARE @CantidadAprobaciones  INT = 0

DECLARE @EstatusSiguienteTareaId INT
DECLARE @OperacionId INT
DECLARE @TareaId INT
DECLARE @SolicitudPedidoId INT
DECLARE @NombreTipoFlujo NVARCHAR(MAX) = ''
DECLARE @EstatusTareaId INT
DECLARE @EstaEnAprobacionOperacion INT
DECLARE @EstatusExistenteTareaId INT

DECLARE @Historial NVARCHAR(MAX) = ''
DECLARE @HistorialReinicio NVARCHAR(MAX) = ''
DECLARE @NombreAprobadorActual NVARCHAR(MAX) = ''
DECLARE @NombreNuevoAprobador NVARCHAR(MAX) = ''
DECLARE @NombreOperadora NVARCHAR(MAX) = ''
DECLARE @CorreoAprobador NVARCHAR(MAX) = ''
DECLARE @DescripcionOperacion NVARCHAR(MAX) = ''
DECLARE @Descripcion NVARCHAR(MAX) = ''
DECLARE @DescripcionTarea NVARCHAR(MAX) = ''
DECLARE @DescripcionValidaciones NVARCHAR(MAX) = ''
DECLARE @Contrato NVARCHAR(MAX) = ''
DECLARE @NoSecuencia INT
DECLARE @IdTareaNueva INT 
DECLARE @AplicaNotificacion  BIT 

CREATE TABLE #AprobacionesTareas(
Id INT Identity(1,1),
TareaId INT 
)

CREATE TABLE #CorreosTareas(
Id INT Identity(1,1),
IdSolicitudPedido INT,
IdAprobador INT,
NoSecuencia INT,
IdOperacion INT,
IdTarea INT,
NombreAprobador  NVARCHAR(MAX),
CorreoAprobador  NVARCHAR(MAX),
DescripcionAprobacion  NVARCHAR(MAX),
Contrato NVARCHAR(MAX)
)

CREATE TABLE #SecuenciaTareas(
NoSecuencia INT,
TareaId INT 
)

CREATE TABLE #CambioTareas(
Id INT Identity(1,1),
IdSolicitudPedido INT,
IdTarea INT,
Detalle NVARCHAR(MAX)
)

-- OBTENER TAREAS 
INSERT INTO #AprobacionesTareas(TareaId)
SELECT splitdata
FROM dbo.fnSplitString(@TareasIds, ',');


 SET @CantidadAprobaciones = (SELECT COUNT(1) 
							 FROM #AprobacionesTareas)
 

 SELECT 
 @NombreNuevoAprobador = Nombre,
 @CorreoAprobador = Correo
 FROM S_Usuario
 WHERE IdUsuario = @NuevoAprobadorId 
 
 SELECT @NombreOperadora = RazonSocial
 FROM S_Proveedor
 WHERE IdProveedor = @ProveedorId


WHILE @CantidadAprobaciones >= @Contador
BEGIN
        SET @DescripcionTarea = ''
		SET @DescripcionOperacion = ''
		SET @Contrato = ''
		SET @DescripcionValidaciones = ''
		SET @NombreAprobadorActual = ''
		SET @NombreTipoFlujo = ''
		SET @Contrato  = ''
		SET @HistorialReinicio = ''
		SET @SolicitudPedidoId = 0
		SET @OperacionId = 0
		SET @ContratoId = 0
		SET @EstatusExistenteTareaId = 0
		SET @AplicaNotificacion = 0
		SET @TareaId = 0
		SET @IdTareaNueva = 0
		SET @EstatusSiguienteTareaId = 0

		SELECT @TareaId = TareaId
		FROM #AprobacionesTareas
		WHERE Id = @Contador;
		
		SELECT 
		@OperacionId =  O.IdOperacion,
		@NombreAprobadorActual = U.Nombre,
        @SolicitudPedidoId = O.IdDocumento,
        @DescripcionOperacion = O.Descripcion,   
		@NombreTipoFlujo = TFT.Nombre,
		@Contrato = CONCAT(C.NumeroContrato,' - ',AC.NombreAreaContractual),
		@ContratoId = SP.IdContrato,
		@NoSecuencia = T.NoSecuencia,
		@EstatusTareaId = T.IdEstatus
		FROM TA_Tarea T
		JOIN TA_TareaOperacion AS TTO
			ON T.IdTarea = TTO.IdTarea
			AND T.IdTarea = @TareaId 
		JOIN TA_Operacion AS O
		    ON TTO.IdOperacion = O.IdOperacion
		JOIN MM_SolicitudPedido SP
			ON O.IdDocumento = SP.IdSolicitudPedido
			AND O.IdTipoOperacion = 2 --> CTE APROBACIÓN SOLPED
		JOIN TA_Estatus AS E 
			ON O.IdEstatusOperacion = E.IdEstatus
		JOIN TA_FlujoTarea FT 
			ON O.IdFlujoTarea = FT.IdFlujoTarea
		JOIN TA_TipoFlujoTarea TFT 
			ON FT.IdTipoFlujo = TFT.IdTipoFlujoTarea
		LEFT JOIN Adinco..CO_Contrato C 
			ON SP.IdContrato = C.IdContrato
		LEFT JOIN Adinco..CO_AreaContractual AC 
			ON C.IdAreaContractual = AC.IdAreaContractual
		LEFT JOIN S_Usuario U 
			ON T.IdAprobador = U.IdUsuario
		WHERE T.IdAprobador = @AprobadorActualId			    
				AND O.IdTipoOperacion = 2
				AND O.IdProveedor = @ProveedorId
				AND ISNULL(O.IdEstatusEliminado, 0) <> 1  --> MOSTRAR NO ELIMINADAS 
	    GROUP BY O.IdOperacion,
				O.IdDocumento,
				O.FechaRegistro,
				O.Descripcion,
				E.Nombre,
				O.IdEstatusEliminado,
				T.IdTarea,
				TFT.Nombre,
				AC.NombreAreaContractual,
				T.NoSecuencia,
				U.Nombre,
				C.NumeroContrato,
				SP.IdContrato,
				T.IdEstatus
		ORDER BY O.FechaRegistro DESC;

		SET @DescripcionTarea = CONCAT(@DescripcionTarea,'Solicitud de pedido No. ',ISNULL(@SolicitudPedidoId,0),'. Operadora: ',ISNULL(@NombreOperadora,''),'[',@ProveedorId,']. ' )
		
		-- RELIZAR VALIDACIÓN DE INFORMACIÓN GRAL
		IF ISNULL(@SolicitudPedidoId,0) = 0
		BEGIN
			SET @DescripcionValidaciones = CONCAT(@DescripcionValidaciones,'Información de la Tarea de aprobación [',@TareaId,'] de la Solicitud de pedido no encontrada. ')
		END 

		IF ISNULL(@SolicitudPedidoId,0) > 0 AND ISNULL(@EstatusTareaId,0) <> 1
		BEGIN
			SET @DescripcionValidaciones = CONCAT(@DescripcionValidaciones,'La tarea ya no se encuentrá en estatus En Aprobación')
		END 

		IF @NuevoAprobadorId = @AprobadorActualId
		BEGIN
			SET @DescripcionValidaciones = CONCAT(@DescripcionValidaciones,'El nuevo aprobador [',@NombreNuevoAprobador,'], no puede ser el mismo usuario aprobador actual [',@NombreAprobadorActual,'].')
		END 

		
		IF @DescripcionValidaciones = ''
		BEGIN

			IF @EstatusTareaId = 1 --> CTE SI ESTA EN APROBACIÓN
			BEGIN

				 -- VALIDAR SI EL NUEVO APROBADOR SE ENCUENTRA EN EL FLUJO DE APROBACIÓN EN ESTATUS EN APROBACIÓN O EN ALGUN OTRO ESTATUS 
				SELECT @IdTareaNueva =  T.IdTarea,
				@EstatusExistenteTareaId  = T.IdEstatus
				FROM TA_Tarea AS T  
				JOIN TA_TareaOperacion AS TTO 
					ON  T.IdTarea = TTO.IdTarea
				JOIN TA_Operacion AS TOO 
					ON TTO.IdOperacion = TOO.IdOperacion 
				WHERE TTO.IdOperacion = @OperacionId
				AND T.IdAprobador = @NuevoAprobadorId
			
				IF ISNULL(@IdTareaNueva,0)  = 0 --> NO EXISTE TAREA CON EL NUEVO APROBADOR
				BEGIN 

					 --- AGREGAR TAREA NUEVO APROBADOR--- 
					 INSERT INTO TA_Tarea(NombreTarea,FechaRegistro,IdEstatus,Activo, Visto,IdAprobador,NoSecuencia,IdOperacion)
					 SELECT NombreTarea,GETDATE() AS FechaRegistro,IdEstatus,Activo, Visto,@NuevoAprobadorId AS IdAprobador,NoSecuencia,IdOperacion
					 FROM TA_Tarea AS T
					 WHERE T.IdTarea =  @TareaId

					SET @IdTareaNueva = (SELECT  SCOPE_IDENTITY())

					--- AGREGAR RELACIÓN TAREA OPERACION ---

					INSERT INTO TA_TareaOperacion(IdOperacion, IdTarea)
					VALUES(@OperacionId,@IdTareaNueva)

					--- ELIMINAR TAREA APROBADOR ACTUAL COMO ESTA EN APROBACIÓN NO IMPACTO EN EL FLUJO---
					DELETE TA_TareaOperacion
					WHERE IdTarea = @TareaId

					DELETE TA_Tarea
					WHERE IdTarea = @TareaId

					--- AGREGAR EVENTO HISTORIAL --- 

					SET @Descripcion = 'Se realizo cambio de Aprobador del usuario: '+
								(ISNULL(@NombreAprobadorActual,'-')+ 
								' al usuario: ' +
								(ISNULL(@NombreNuevoAprobador,'-')+' *Actualización realizada por soporte del sistema, detalle: '+@Justificacion+'. ')) 
						
				 INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
				 VALUES(@Descripcion,@OperacionId,GETDATE(),8)

				 SET @DescripcionTarea = CONCAT(@DescripcionTarea,'Cambio realizado. ',@Descripcion)
				 SET @DescripcionTarea = CONCAT(@Descripcion,'OperacionId: ', @OperacionId, ', TareaId: ', @TareaId, ', Nueva TareaId: ', @IdTareaNueva,'. ')

			 END 
				ELSE
				BEGIN
						SET @DescripcionTarea = CONCAT(@DescripcionTarea,'Cambio realizado, el usuario ',@NombreNuevoAprobador,' ya tenia una tarea en: En aprobación. ')

						
						IF ISNULL(@IdTareaNueva,0) > 1 --> LA TAREA QUE YA EXISTE ENTONCES REINICIAR
						BEGIN 
							-- OBTENER DETALLE ANTES DE REINICIO
						
							SELECT @HistorialReinicio = CONCAT(
							'*Se reinicio la TareaId: ',ISNULL(T.IdTarea,'-'),
							', para el aprobador, ya que el usuario ya tenía asignada una tarea en el flujo de aprobación. Estatus anterior: ', ISNULL(E.Nombre,'-'),
							', No secuencia: ',T.NoSecuencia, 
							', Comentario: ',ISNULL(T.Comentario,'-'),
							', Fecha de cambio estatus: ',ISNULL(FORMAT(T.FechaCambioEstatus,'dd/MM/yyyy HH:MM:ss'),'-'), 
							', Visto: ', ISNULL(T.Visto,'-'),
							', Firma: ', ISNULL(T.IdFirma,'-'),
							', Activo: ', ISNULL(T.Activo,'-'),
							', IdOperacion: ', ISNULL(T.IdOperacion,'-'),
							'.  '
							)
							FROM TA_Tarea T
							LEFT JOIN TA_Estatus E
							ON T.IdEstatus = E.IdEstatus
							WHERE T.IdTarea = @IdTareaNueva


							--> REINICIAR EL ESTATUS DE LA APROBACIÓN
							UPDATE TA_Tarea  
							SET Activo  = 1, 
							IdEstatus = 1,
							NoSecuencia = @NoSecuencia,
							Comentario = '',
							FechaCambioEstatus = NULL
							WHERE IdTarea = @IdTareaNueva

						END

						--- ELIMINAR TAREA DEL APROBADOR ACTUAL
						DELETE TA_TareaOperacion
						WHERE IdTarea = @TareaId
					
						DELETE TA_Tarea
						WHERE IdTarea = @TareaId

						--> OBTENER NUEVO NUMERO DE SECUENCIA Y ACTUALIZAR LOS NUMEROS DE SECUENCIA DE LA APROBACIÓN
						TRUNCATE TABLE #SecuenciaTareas
						INSERT INTO #SecuenciaTareas(NoSecuencia,TareaId)
						SELECT 
						ROW_NUMBER() OVER (ORDER BY T.IdTarea) AS Fila,
						T.IdTarea
						FROM TA_Tarea T
						JOIN TA_TareaOperacion OT
							ON T.IdTarea = OT.IdTarea
						WHERE T.IdOperacion = @OperacionId
						AND T.Activo = 1 --> CTE TAREAS ACTIVAS
						ORDER BY T.NoSecuencia ASC

						UPDATE T
						SET T.NoSecuencia = ST.NoSecuencia
						FROM TA_Tarea T
						JOIN #SecuenciaTareas ST
							ON T.IdTarea = ST.TareaId 

						-- OBTENER EL NUEVO NUMERO DE SECUENCIA 
						SELECT @NoSecuencia = NoSecuencia
						FROM TA_Tarea 
						WHERE IdTarea = @IdTareaNueva

						--- AGREGAR EVENTO HISTORIAL --- 

						SET @Descripcion = 'Se realizo cambio de Aprobador del usuario: '+
									(ISNULL(@NombreAprobadorActual,'-')+ 
									' al usuario: ' +
									(ISNULL(@NombreNuevoAprobador,'-')+' *Actualización realizada por soporte del sistema, detalle: '+@Justificacion+'. ')) 
						
					 INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
					 VALUES(@Descripcion,@OperacionId,GETDATE(),8)

					 SET @DescripcionTarea = CONCAT(@Descripcion,'OperacionId: ', @OperacionId, ', TareaId: ', @TareaId, ', Nueva TareaId: ', @IdTareaNueva,'. ',@HistorialReinicio)

				 END 

			 -- VALIDAR SI SE DEBE GENERAR CORREO DE NOTIFICACIÓN, SEGUN EL FLUJO SERIAL O PARALELO
			 SET @AplicaNotificacion = 0

			 IF (ISNULL(@NoSecuencia,0) = 1 AND UPPER(@NombreTipoFlujo) = 'SERIAL') OR  UPPER(@NombreTipoFlujo) = 'PARALELO'
			 BEGIN
				SET @AplicaNotificacion = 1
			 END
			 ELSE 
			 BEGIN 
				-- VALIDAR SI EL APROBADOR ANTERIOR YA REALIZO LA APROBACIÓN
				SELECT @EstatusSiguienteTareaId = T.IdEstatus
				FROM TA_Tarea T 
				WHERE T.IdOperacion = @OperacionId
				AND T.NoSecuencia = (ISNULL(@NoSecuencia,0)-1)
				AND T.Activo = 1

				IF ISNULL(@EstatusSiguienteTareaId,0) <> 1 --> ES DIFERENTE A ESTADO EN APROBACIÓN
				BEGIN
					SET @AplicaNotificacion = 1
				END
				ELSE
				BEGIN
					SET @DescripcionTarea = CONCAT(@DescripcionTarea,'* No se genero correo de notificación por que el aprobador anterior no ha realizado la aprobación en flujo: ',UPPER(@NombreTipoFlujo), ', núm. secuencia',ISNULL(@NoSecuencia,0))
				END 
			 END 

			 IF @AplicaNotificacion = 1
			 BEGIN 
			  --> AGREGAR LA INFORMACIÓN NECESARIA PARA GENERAR CORREOS EN C#
				 INSERT INTO #CorreosTareas(				
					IdSolicitudPedido,
					IdAprobador,
					NoSecuencia,
					IdOperacion,
					IdTarea,
					NombreAprobador,
					CorreoAprobador,
					DescripcionAprobacion,
					Contrato
				 )
				 VALUES(
				 @SolicitudPedidoId,
				 @NuevoAprobadorId,
				 @NoSecuencia,
				 @OperacionId,
				 @IdTareaNueva,
				 ISNULL(@NombreNuevoAprobador,''),
				 ISNULL(@CorreoAprobador,''),
				 ISNULL(@DescripcionOperacion,''),
				 ISNULL(@Contrato,'')
				 )
			 END
			END 
			ELSE
			BEGIN
				SET @DescripcionTarea = CONCAT(@DescripcionTarea, 'Cambio no realizado. La tarea no se encuentrá en estatus En Aprobación')
			END 
		END
		ELSE
		BEGIN 
			SET @DescripcionTarea = CONCAT(@DescripcionTarea, 'Cambio no realizado. ',@DescripcionValidaciones, '. Justificación del cambio solicitado: ', @Justificacion)
		END 
		

	INSERT INTO AP_Bitacora(Fecha, Tipo, Mensaje, Detalle, UsuarioId, ContratoId)
	VALUES(GETDATE(),'CONSOLA-SOPORTE',CONCAT('Cambio aprobador-solped #',ISNULL(@SolicitudPedidoId,'-')),@DescripcionTarea,0,@ContratoId)

	INSERT INTO #CambioTareas(IdSolicitudPedido, IdTarea, Detalle)
	VALUES(@SolicitudPedidoId, @TareaId,@DescripcionTarea)

	SET @Contador = ISNULL(@Contador,0) + 1

END
	
	-- RESUMEN
	SELECT Id,IdSolicitudPedido, IdTarea, Detalle
	FROM #CambioTareas

	-- CORREOS 
	SELECT	
	IdSolicitudPedido,
	IdAprobador,
	NoSecuencia,
	IdOperacion,
	IdTarea,
	NombreAprobador,
	CorreoAprobador,
	DescripcionAprobacion,
	Contrato
	FROM #CorreosTareas

    /*===========*/	
	COMMIT TRAN	
	END TRY
	BEGIN CATCH
		/*===========*/
		ROLLBACK TRAN		
	    DECLARE @ERROR NVARCHAR(MAX) = 'ERROR USP_UPD_TA_ReasignacionAprobacionesPendientesUsuario ['+ ERROR_MESSAGE() + '] LINEA ['+ CAST(ERROR_LINE() AS VARCHAR)+']';
	    RAISERROR (15600,-1,-1, @ERROR); 
		/*===========*/
	END CATCH	

END