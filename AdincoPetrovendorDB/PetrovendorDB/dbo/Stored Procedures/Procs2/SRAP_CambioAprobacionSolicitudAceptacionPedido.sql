USE [Petrovendor]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SRAP_CambioAprobacionSolicitudAceptacionPedido'
)
    DROP PROCEDURE SRAP_CambioAprobacionSolicitudAceptacionPedido;

/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultaPedidoDetallesVenta]    Script Date: 11/06/2021 12:01:56 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 25-05-2021
-- Description:	Aprobar detalle de solicitud de recepción de pedido
-- =============================================
CREATE PROCEDURE [dbo].[SRAP_CambioAprobacionSolicitudAceptacionPedido] 
	-- Add the parameters for the stored procedure here
@IdPedido    INT,
@IdSolicitudAceptacionPedido INT,
@IdProveedor INT,
@UsuarioId   INT,
@AccionAprobacion  NVARCHAR(MAX),
@ComentarioAceptacion NVARCHAR(MAX),
@ComentarioAprobacion NVARCHAR(MAX),
@NombreUsuarioEntrega  NVARCHAR(MAX),
@NombreRecibidoPor NVARCHAR(MAX),
@IdDomicilioEntrega INT,
@IdTarea INT,
@IdOperacion INT

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

		 DECLARE @NuevoEstatusId INT 
		 DECLARE @TareaActualId INT 
		 DECLARE @EstatusAprobadorActualId INT 
		 DECLARE @NombreEstatusAprobadorActual NVARCHAR(MAX) 
		 DECLARE @FechaActual DATETIME  = (SELECT GETDATE())
		 DECLARE @DescripcionH NVARCHAR(MAX)
		 DECLARE @EstatusAprobacionId INT 
		 DECLARE @IdNacionalidadProveedor INT 
		 DECLARE @IdRegimenProveedor INT 
		 DECLARE @IdProveedorVenta INT 
		 DECLARE @IdPaisProveedor INT 
		 DECLARE @IdAceptacionPedido INT = 0
		 DECLARE @IdAceptacionPedidoDetalle INT =0
		 DECLARE @IdPedidoGeneral INT = 0
		 DECLARE @NombreAreaContratual NVARCHAR(MAX)
	     DECLARE @NombreEstatusAprobacionActual NVARCHAR(MAX)
		 DECLARE @NombreEstatusAprobacionActualEN NVARCHAR(MAX)


		DECLARE @CountTarea INT;
        DECLARE @CountEstApr INT;
        DECLARE @CountEstRech INT;
        DECLARE @CountEstPen INT;

		DECLARE @CantidadProductos INT
		DECLARE @ContadorProductos INT 

		DECLARE @Aprobadores AS TABLE 
		(
		IdRow  INT IDENTITY(1,1) PRIMARY KEY,
		Nombre NVARCHAR(MAX),
		Correo  NVARCHAR(MAX),
		IdUsuario INT 
		)

		DECLARE @ProductosAceptacion AS TABLE
		(
			IdRow  INT IDENTITY(1,1) PRIMARY KEY,
			IdPedidoDetalle INT,
			Detalle NVARCHAR(MAX),
			Cantidad FLOAT,
			Excedente FLOAT,
			IdInstalacion INT,
			IdLineaPresupuesto INT,
			IdMaterial INT,
			IdProveedorCompas INT 
		)

		---Glosario Estatus---
        -- 1 Pendiente
        -- 2 Aceptada
        -- 3 Rechazada
        -- 4 Vencida
        -- 7 Reasignada
        --12 Eliminado
		
		/*0. OBTENER INFORMACION IMPORTANTE */
		BEGIN
			 IF @AccionAprobacion = 'APROBAR'
			 BEGIN 
				SET @NuevoEstatusId = 2 
			 END 
		 
			 IF  @AccionAprobacion = 'RECHAZAR'
			 BEGIN 
				SET @NuevoEstatusId = 3
			 END

			SELECT 
			@IdPedidoGeneral = PG.IdPedido,
			@NombreAreaContratual =  CONCAT(ISNULL(C.NumeroContrato,'') ,' - ' , ISNULL(AC.NombreAreaContractual,'')) 
			FROM MM_Pedido AS P  
			JOIN MM_Pedidos AS PG 
			ON P.IdPedido = PG.IdIdentificador 
			AND PG.IdProveedorCliente = P.IdProveedorCompras 
			AND PG.IdTipoPedido in (2,4,6) 
			LEFT JOIN Adinco..CO_Contrato C
				ON P.IdContrato = C.IdContrato
			LEFT JOIN Adinco..CO_AreaContractual AC 
				 ON C.IdAreaContractual = AC.IdAreaContractual  
			WHERE P.IdPedido = @IdPedido

		 END 

		 /*1. VALIDAR QUE EL USUARIO SEA APROBADOR Y QUE LA TAREA ESTE EN APROBACIÓN */
		 BEGIN 
		   
		   SELECT 
		   @TareaActualId				 = T.IdTarea,
		   @EstatusAprobadorActualId	 = T.IdEstatus,
		   @NombreEstatusAprobadorActual = E.Nombre
		   FROM TA_Tarea T
		   LEFT JOIN TA_Estatus E
			ON T.IdEstatus = E.IdEstatus
		   WHERE T.IdTarea		= @IdTarea
		   AND T.IdAprobador	= @UsuarioId
		   AND T.IdOperacion	= @IdOperacion
		   AND T.Activo			= 1

		   IF ISNULL(@TareaActualId,0) = 0
		   BEGIN
				SELECT 'ERROR_VALIDACION' AS response,
				'No eres aprobador de esta solicitud de aceptación de pedido' AS detalle
				RETURN 
		   END

		   IF ISNULL(@EstatusAprobadorActualId,0) <> 1 --> SI ES DIFERENTE AL ESTATUS EN APROBACIÓN
		   BEGIN
				SELECT 'ERROR_VALIDACION' AS response,
				CONCAT('Ya se ha realizado la acción de aprobación anteriormente, estatus actual: ', ISNULL(@NombreEstatusAprobadorActual,'')) AS detalle
				RETURN 
		   END 

		 END 

		 /*2.- ACTUALIZAR ESTATUS DE LA TAREA*/
		 BEGIN 
			UPDATE TA_Tarea 
			SET IdEstatus	= @NuevoEstatusId,
			ModificadoEl	= @FechaActual,
			Comentario		= @ComentarioAprobacion,
			Visto			= 1,
			FechaCambioEstatus= @FechaActual
			WHERE IdTarea	= @IdTarea		

			DECLARE @ESTATUSTA NVARCHAR(MAX)
            =   (SELECT Nombre FROM TA_Estatus WHERE IdEstatus = @NuevoEstatusId)

			IF @ESTATUSTA = 'Aprobada'
			BEGIN
				SET @ESTATUSTA = N'Aprobado'
			END

			IF @ESTATUSTA = 'Rechazada'
			BEGIN
				SET @ESTATUSTA = N'Rechazado'
			END

			 SET @DescripcionH
            = N'El Usuario ' + (SELECT Nombre FROM S_Usuario WHERE IdUsuario = @UsuarioId)
              + N' ha ' + @ESTATUSTA + N' la tarea de aprobación'
			
			INSERT INTO TA_HistorialFlujoTarea (IdOperacion, Fecha, Descripcion, IdEstadoFlujo)
			VALUES
			(@IdOperacion, @FechaActual, @DescripcionH, 2)

		 END 	  			  	  

		/*3- ACTUALIZAR ESTATUS DE LA APROBACION SI TODOS APROBARON O SI SE RECHAZO LA APROBACIÓN*/
		BEGIN 
			---CONTAR NUMERO DE APROBADORES EN LA APROBACION GRAL/APROBADORES
			SET @CountTarea =
			(
				SELECT COUNT(T.IdEstatus) AS TOTAL
				FROM TA_Operacion TAO
					JOIN TA_Tarea AS T
						ON T.IdOperacion = TAO.IdOperacion
				WHERE TAO.IdOperacion = @IdOperacion
					  AND T.IdEstatus <> 7 --> NO SEA REASIGNADO
					  AND T.IdEstatus <> 12 --> NO ESTE ELIMINADO
					  AND T.Activo = 1 --> ESTE ACTIVO
			);

			 --- CONTAR NUMERO DE APROBADORES QUE FALTAN POR APROBAR 
			SET @CountEstPen =
			(
				SELECT COUNT(T.IdEstatus) AS TOTAL
				FROM TA_Operacion TAO
					JOIN TA_Tarea AS T
						ON T.IdOperacion = TAO.IdOperacion
				WHERE TAO.IdOperacion = @IdOperacion
					  AND T.IdEstatus = 1
					  AND T.Activo = 1
			);

			--- CONTAR NUMERO DE APROBADORES QUE YA APROBARON 
			SET @CountEstApr =
			(
				SELECT COUNT(T.IdEstatus) AS TOTAL
				FROM TA_Operacion TAO
					JOIN TA_Tarea AS T
						ON T.IdOperacion = TAO.IdOperacion
				WHERE TAO.IdOperacion = @IdOperacion
					  AND T.IdEstatus = 2 --> APROBARON
					  AND T.Activo = 1
			);

			--- CONTAR NUMERO DE APROBADORES QUE RECHAZARON 
			SET @CountEstRech =
			(
				SELECT COUNT(T.IdEstatus) AS TOTAL
				FROM TA_Operacion TAO
					JOIN TA_Tarea AS T
						ON T.IdOperacion = TAO.IdOperacion
				WHERE TAO.IdOperacion = @IdOperacion
					  AND T.IdEstatus = 3 --> RECHAZARON 
					  AND T.Activo = 1
			);

			IF (@CountEstRech > 0)
			BEGIN
			    /*LA TAREA HA SIFO RECHAZADA*/
				--- ACTUALIZAR EL ESTATUS DE LA OPERACION ---> SE CANCELA LA TAREA 
				UPDATE TA_Operacion 
				SET IdEstatusOperacion = 3, 
				IdEstadoFlujo = 4
				WHERE IdOperacion = @IdOperacion

				---ACTUALIZAR LOS ESTATUS QUE AUN NO A SIDO APROBADOS(PENDIENTES) ---> SE CANCELAN POR CANCELACIÓN LAS TAREAS NO EVALUADAS
				UPDATE TA_TAREA 
				SET IdEstatus= 4 
				WHERE IdTarea IN (SELECT IdTarea 
								  FROM TA_Tarea
								  WHERE IdOperacion = @IdOperacion 
								  AND IdEstatus= 1
								  AND Activo = 1)

				SET @DescripcionH = 'Se ha Finalizado la aprobación de la Tarea '

				INSERT INTO TA_HistorialFlujoTarea(IdOperacion,Fecha,Descripcion,IdEstadoFlujo)
				VALUES(@IdOperacion,GETDATE(),@DescripcionH,7)

			END
			ELSE 
			BEGIN 
				IF (@CountEstApr = @CountTarea)
				BEGIN 
					--ACTUALIZAR EL ESTATUS DE LA OPERACION Y EL ESTADO DEL FLUJO ---> TAREA APROBADA

					UPDATE TA_Operacion
					SET IdEstatusOperacion = 2,
					IdEstadoFlujo = 3
					WHERE IdOperacion = @IdOperacion
				
					SET @DescripcionH = 'Se ha Finalizado la aprobación de la Tarea '

					INSERT INTO TA_HistorialFlujoTarea(IdOperacion,Fecha,Descripcion,IdEstadoFlujo)
					VALUES(@IdOperacion,GETDATE(),@DescripcionH,7)
				END 			
			END   
		END 

		/*3.1 OBTENER EL ESTATUS ACTUAL DE LA APROBACION ACTUAL*/
		BEGIN 
			
			SELECT @EstatusAprobacionId = O.IdEstatusOperacion,
			@NombreEstatusAprobacionActual = E.Nombre,
			@NombreEstatusAprobacionActualEN = E.Name
			FROM TA_Operacion O
			LEFT JOIN TA_Estatus E
				ON O.IdEstatusOperacion = E.IdEstatus
			WHERE O.IdOperacion = @IdOperacion

		END

		/*4 SI LA APROBACION ESTA APROBADA - GENERAR ACEPTACION DE PEDIDO */
		BEGIN 
			IF @EstatusAprobacionId  = 2 --> CTE --> ESTATUS APROBADO
			BEGIN 
			   
			    /*4.1 ESTA APROBADA LA APROBACION GENERAR ACEPTACION DE PEDIDO 
				--> SE TOMA COMO REFERENCIA EL SP SP_MM_AgregarAceptacionPedidoEncabezado
				*/
				BEGIN

				SELECT @IdProveedorVenta			= P.IdSubcontratista,
						@IdNacionalidadProveedor	= S.IdNacionalidad,
						@IdPaisProveedor			= S.IdPais,
						@IdRegimenProveedor			= S.IdTipoRegimen
				FROM MM_Pedido P
				INNER JOIN S_Proveedor S
						ON S.IdProveedor = P.IdSubcontratista
				WHERE P.IdPedido = @IdPedido


				/*AGREGAR ENCABEZADO ACEPTACION PEDIDO*/
				INSERT INTO MM_AceptacionPedido
				(
					IdProveedor,IdPedido,Comentario,NombreUsuarioEntrega,Activo,Creado,CreadorPor,
					IdDomicilioEntrega,	RecibidoPor,NombreRecibidoPor,IdNacionalidadProveedor,IdRegimenProveedor,
					IdPaisProveedor
				)
				VALUES
				(@IdProveedor, @IdPedido, @ComentarioAceptacion, @NombreUsuarioEntrega, 1,@FechaActual, @UsuarioId,
				 @IdDomicilioEntrega, @UsuarioId, @NombreRecibidoPor, @IdNacionalidadProveedor, @IdRegimenProveedor,
				 @IdPaisProveedor)
					
				 SELECT @IdAceptacionPedido = SCOPE_IDENTITY()

				-- EN CASO DE QUE EL BIT PEDIRCARTA = 1 NO PEDIR CARTA
				INSERT INTO dbo.RelacionCartaCNPedido
				(
					IdPedido,IdAceptacionPedido,PedirCarta,
					CreadoPor,FechaCreacion
				)
				SELECT @IdPedido, @IdAceptacionPedido,1,
					   @UsuarioId,@FechaActual

               
			   END 

			   /*4.2 AGREGAR ACEPTACION PEDIDO DETALLE*/
			   BEGIN
					
					/*OBTENER LOS PRODUCTOS QUE SE VAN A RECEPCIONAR*/
					INSERT INTO @ProductosAceptacion(IdPedidoDetalle,Cantidad,Detalle,Excedente, IdInstalacion, IdLineaPresupuesto,IdMaterial,IdProveedorCompas)
					SELECT 					
					PD.IdPedidoDetalle,					 
					SAPD.Cantidad AS CantidadProcesada, 	
					'Aceptación realizada por aprobación' AS Detalle,	
					0  AS Excedente,
					ISNULL(SPDL.IdInstalacion,0)  AS IdInstalacion,
					ISNULL(SPDL.IdLineaPresupuesto,0)  AS IdLineaPresupuesto,
					PD.IdMaterial,
					P.IdProveedorCompras				
					FROM MM_SolicitudAceptacionPedidoDetalle SAPD 		
					JOIN MM_PedidoDetalle AS PD 
						ON SAPD.IdPedidoDetalle	= PD.IdPedidoDetalle
					JOIN MM_Pedido	P
						ON PD.IdPedido	= P.IdPedido					
					JOIN MM_PeticionOferta AS PO 
						ON P.IdPeticionOferta	= PO.IdPeticionOFerta 
					JOIN MM_PeticionOfertaDetalle AS POD 
						ON PO.IdPeticionOferta = POD.IdPeticionOferta 
						AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle 
					LEFT JOIN MM_SolicitudPedidoDetalle AS SPD 
						ON POD.IdSolicitudPedidoDetalle	 = SPD.IdSolicitudPedidoDetalle 
					LEFT JOIN MM_SolicitudPedidoDetalleLineaPresupuesto SPDL
						ON SPD.IdSolicitudPedidoDetalle	= SPDL.IdSolicitudPedidoDetalle
					WHERE P.IdPedido = @IdPedido
					AND SAPD.IdSolicitudAceptacionPedido= @IdSolicitudAceptacionPedido
					ORDER BY PD.IdPedidoDetalle ASC


					SELECT @CantidadProductos =  COUNT(1) 
					FROM @ProductosAceptacion
					
					SET @ContadorProductos=1

					WHILE @CantidadProductos >= @ContadorProductos
					BEGIN 
					 
						/*SE GUARDA LA INFORMACIÓN DEL DETALLE DE LOS PRODUCTOS REFERENCIA EN EL SP --> SP_MM_AgregarAceptacionPedidoDetalle */

						
						INSERT INTO MM_AceptacionPedidoDetalle
						(
							IdAceptacionPedido,IdPedidoDetalle,Cantidad,Detalle,
							CreadoPor,Creado,Excedente
						)
						SELECT @IdAceptacionPedido,IdPedidoDetalle, Cantidad, Detalle,
						@UsuarioId, @FechaActual, Excedente
						FROM @ProductosAceptacion
						WHERE IdRow = @ContadorProductos

						SELECT @IdAceptacionPedidoDetalle = SCOPE_IDENTITY();

						INSERT INTO dbo.MM_AceptacionPedidoDetalleInstalacion
						(IdAceptacionPedido,IdAceptacionPedidoDetalle,IdPedidoDetalle,
							IdProveedor,IdMaterial,Cantidad,IdInstalacion,IdLineaPresupuesto
						)

						SELECT 
						@IdAceptacionPedido,@IdAceptacionPedidoDetalle,IdPedidoDetalle,
						IdProveedorCompas,IdMaterial,Cantidad,IdInstalacion,IdLineaPresupuesto
						FROM @ProductosAceptacion
						WHERE IdRow = @ContadorProductos

						IF NOT EXISTS
						(
							SELECT 1
							FROM dbo.MM_AceptacionPedidoDetalleInstalacion
							WHERE IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle
						)
						BEGIN
							RAISERROR(
										 'Valor no insertado en MM_AceptacionPedidoDetalleInstalacion por eso es el error para que coincida el valor en MM_AceptacionPedidoDetalle',
										 16,
										 1
									 )
						END

						SET @ContadorProductos = @ContadorProductos + 1;

					END
			   END 

			   /*4.3 RELACIONAR LOS DOCUMENTOS CARGADOS POR EL PROVEEDOR*/
			   /*LOS DOCUMENTOS QUE SE AGREGAN EN S_DOCUMENTOS SON LOS 
			   QUE CARGA EL PROVEEDOR EN LA APROBACION DE ACEPTACION DE PEDIDO
			   SP DE REFERENCIA --> SP_MM_AgregarAceptacionDocumentos_S3*/
			  INSERT INTO  MM_AceptacionDocumento
			  (IdAceptacionDocumento, IdDocumento, Comentario, NombreDocumento, Activo )
			  SELECT  @IdAceptacionPedido,D.IdDocumento, D.Descripcion, D.NombreDocumento,D.Activo
			  FROM S_Documento_S3 D
			  WHERE D.Activo= 1 --> CTE QU ESTE ACTIVO
			  AND D.IdDocumentoTabla = @IdSolicitudAceptacionPedido
			  AND D.IdTipoDocumento =  12 --> CTE SELECT * FROM S_TipoDocumento WHERE IdTipoDocumento = 12

			  /*4.4 RELACIONAR LA SOLICITUD DE ACEPTACION DE PEDIDO CON LA ACEPTACION DE PEDIDO*/
			  UPDATE MM_SolicitudAceptacionPedido
			  SET IdAceptacionPedido=@IdAceptacionPedido,
			  ModificadoEl = @FechaActual,
			  ModificadoPor = @UsuarioId
			  WHERE IdSolicitudAceptacionPedido = @IdSolicitudAceptacionPedido

			END 
		END 

		/*5.-ENVIAR CORREOS SI LA APROBACIÓN FUE APROBADA O RECHAZADA A LOS APROBADORES*/
		--BEGIN
		--		/*POR EL MOMENTO ESTA FUNCIONALIDAD VA ESTAR DESACTIVIDA, SOLO SE ESPERA UN APROBADOR */
		--		INSERT INTO @Aprobadores(Nombre, Correo, IdUsuario)
		--		SELECT U.Nombre, U.Correo,U.IdUsuario
		--		FROM TA_Tarea T
		--		JOIN TA_Operacion O 
		--		ON T.IdOperacion = O.IdOperacion
		--		JOIN S_Usuario U
		--			ON T.IdAprobador	= U.IdUsuario
		--		WHERE 
		--		T.IdOperacion = @IdOperacion
		--		AND T.Activo=1
		--		AND T.IdEstatus <> 7 --> NO SEA REASIGNADO
		--		AND T.IdEstatus <> 12 --> NO ESTE ELIMINADO 								

		--END 

		

		/*6. REGRESAR RESPUESTA TABLA 1*/


		SELECT 'SUCCESS' AS response,
		ISNULL(@EstatusAprobacionId,0) AS estatusAprobacion,
		ISNULL(@IdNacionalidadProveedor,0) as idNacionalidadProveedor,
		ISNULL(@IdAceptacionPedido,0) AS idAceptacionPedido,
		ISNULL(@IdPedido,0) AS idPedido,
		ISNULL(@IdPedidoGeneral,0) as idPedidoGeneral,
		ISNULL(@NombreAreaContratual,'') AS nombreAreaContratual,
		ISNULL(@IdOperacion,0) AS idOperacion,
		ISNULL(@NombreEstatusAprobacionActual,'') AS nombreEstatusAprobacion,
	    ISNULL(@NombreEstatusAprobacionActualEN,'') AS nombreEstatusAprobacionEn,
		'Solicitud de aprobación de aceptación de bienes y servicios' AS nombreTipoOperacion

		/*7. REGRESAR RESPUESTA TABLA 2 INFORMACION DEL USUARIO ASIGNADOR DE LA APROBACION*/

		SELECT 
		U.Nombre,
		U.Correo,
		U.IdUsuario,
		U.Activo
		FROM TA_Operacion O
		JOIN S_Usuario U
			ON O.IdAsignador = U.IdUsuario
		WHERE O.IdOperacion =@IdOperacion

END


 