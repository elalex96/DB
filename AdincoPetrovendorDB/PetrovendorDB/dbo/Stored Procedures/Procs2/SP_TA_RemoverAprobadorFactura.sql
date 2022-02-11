USE petrovendor
GO
DROP PROCEDURE IF EXISTS SP_TA_RemoverAprobadorFactura
GO
-- =============================================
-- Author:		<Daniel AC>
-- Create date: <02-08-19>
-- Description:	Agregue, reinicio de aprobación de los aprobadores que ya tenian un estatus de aprobado y consulta para reenviarles notificación de reinicio
-- =============================================
-- Author:		Luis David
-- Create date: 10-03-2022
-- Description:	Se agrega el filtro de aprobadores activos
CREATE PROCEDURE [dbo].[SP_TA_RemoverAprobadorFactura] --420, 2
@IdProveedor INT,
@IdUsuario INT,
@IdAceptacionFactura  INT, 
@IdTarea INT,
@IdOperacion INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @FechaMod DATETIME = GETDATE()
	 
	 --VALIDAR QUE LA APROBACIÓN ESTE EN ESTATUS DE EN_APROBACIÓN 

	 DECLARE @IdESTATUSACTUAL INT 

	 SELECT @IdESTATUSACTUAL= IdEstatusOperacion FROM dbo.TA_Operacion WHERE IdOperacion=@IdOperacion
	 
	 IF ISNULL(@IdESTATUSACTUAL,0) = 1 --APROBACIÓN TIENE QUE ESTAR EN APROBACIÓN
	 BEGIN 
		
		DECLARE @AprobadoresActivos INT 

		SELECT @AprobadoresActivos= COUNT(IdTarea) 
		FROM dbo.TA_Tarea WHERE IdOperacion=@IdOperacion AND Activo=1
		
		--> LA APROBACIÓN SIEMPRE DEBE TENER AL MENOS UN APROBADOR DE FACTURA, SI NO, NO SE ELIMINA EL APROBADOR ACTUAL 
		IF @AprobadoresActivos > 1 
		BEGIN 

			---ACTUALIZAR 
			 UPDATE dbo.TA_Tarea  
			 SET Activo  = 0, --> DESACTIVAMOS LA APROBACIÓN 
			 IdEstatus = 12, --> ELIMINADO
			 EliminadoPor=@IdUsuario,
			 EliminadoEl=@FechaMod
			 WHERE IdTarea = @IdTarea
			 AND IdOperacion=@IdOperacion 

			 DECLARE @IdUsuarioEliminado INT , @Descripcion NVARCHAR(MAX)
			 SELECT @IdUsuarioEliminado=IdAprobador FROM dbo.TA_Tarea WHERE IdTarea=@IdTarea

			 --AGREGAR DETALLE AL HISTORIAL DE OPERACION 
			  SET @Descripcion = 'El usuario '+
							(SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdUsuario)+ 
							' ha eliminado al usuario ' +
							(SELECT Nombre FROM S_Usuario U WHERE IdUsuario = @IdUsuarioEliminado) + ' de la aprobación de la factura'
							
			INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
			VALUES(@Descripcion,@IdOperacion,@FechaMod,10)		  
			  

			 --- VALIDAR EL TIPO DE FLUJO SI ES SERIAL SE TIENE QUE ACTUALIZAR NO SECUENCIA
			 DECLARE @IdFlujoAprobacion INT 
			 DECLARE @TipoFlujo INT 
			 DECLARE @NoSecuencia INT 

			SELECT @IdFlujoAprobacion= IdFlujoTarea FROM  dbo.TA_Operacion WHERE IdOperacion =@IdOperacion
			SELECT @TipoFlujo=IdTipoFlujo FROM  dbo.TA_FlujoTarea WHERE IdFlujoTarea=@IdFlujoAprobacion

			IF @TipoFlujo = 1 -->	APROBACIÓN SERIAL 
			BEGIN 
				--SE TIENE QUE ACTUALIZAR EL NO DE SECUENCIA DE LOS APROBADORES ACTIVOS 
				CREATE TABLE #Aprobadores(IdTarea INT,  NewNoSecuencia INT )
			
				 INSERT INTO #Aprobadores
				(IdTarea,NewNoSecuencia)
			 			
				SELECT IdTarea, ROW_NUMBER() OVER(ORDER BY NoSecuencia ASC) AS  NewNoSecuencia
				FROM dbo.TA_Tarea 
				WHERE IdOperacion =@IdOperacion ---> 
				AND Activo=1  --> ESTEN ACTIVOS 
				ORDER BY NoSecuencia ASC

				UPDATE T
				SET T.NoSecuencia=A.NewNoSecuencia
				FROM dbo.TA_Tarea T
				INNER JOIN #Aprobadores A 
				ON T.IdTarea = A.IdTarea
					
			 END 

			 --ACTUALIZAR APROBADORES QUE YA HABIAN APROBADO LA FACTURA (REINICIO)
			CREATE TABLE #TAREAS_APROBADAS(IdTarea INT, FechaCambioEstatus DATETIME, Comentantario NVARCHAR(MAX),IdEstatus INT)

			INSERT INTO #TAREAS_APROBADAS(IdTarea, FechaCambioEstatus, Comentantario, IdEstatus)
			SELECT IdTarea, FechaCambioEstatus, Comentario, IdEstatus
			FROM dbo.TA_Tarea 
			WHERE IdOperacion=@IdOperacion 
			AND Activo=1 AND IdEstatus=2 --> ESTATUS APROBADO 

			UPDATE T
			SET T.IdEstatus=1, --- REINICIO DE ESTATUS
			T.FechaCambioEstatus=NULL 
			FROM dbo.TA_Tarea  T 
			INNER JOIN #TAREAS_APROBADAS TA 
			ON T.IdTarea = TA.IdTarea
			AND T.IdOperacion=@IdOperacion
		
			INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
			SELECT CONCAT('Reinicio de aprobación del usuario ', ISNULL(U.Nombre,''), ', Última modificación: ',FORMAT(TA.FechaCambioEstatus,'dd/MM/yyyy hh:mm tt'),' del Estatus Aprobado al Estatus Pendiente.', 'Modificación (Eliminación de un aprobador del flujo 
de aprobación) realizada por ', ISNULL(UR.Nombre,'')), T.IdOperacion,@FechaMod, 6 --> Tarea Reiniciada
			FROM #TAREAS_APROBADAS TA
			INNER JOIN dbo.TA_Tarea T ON T.IdTarea = TA.IdTarea
			LEFT JOIN dbo.S_Usuario U ON U.IdUsuario=T.IdAprobador
			LEFT JOIN dbo.S_Usuario UR ON UR.IdUsuario=@IdUsuario
			AND T.IdOperacion=@IdOperacion

			SELECT 'SUCCESS' AS RESPONSE

			 --INFORMACIÓN DEL APROBADOR ACTUAL PARA ENVIARLE NOTIFICACIÓN DE QUE HA SIDO REMOVIDO DE LA APROBACIÓN
			SELECT 
			    U.IdUsuario,--0
				T.NoSecuencia,--1
				U.Nombre,--2
				U.Correo,--3
				T.IdEstatus,--4
				TOO.IdDocumento,--5
				TTO.NombreOperacion,--6
				AF.IdAceptacionPedido,--7
				PG.IdPedido AS PedidoGral,--8
				ISNULL(U.Telefono,'') AS Telefono,--9
				P.IdPedido,--10
				P.IdSolicitudPedido,--11
				FT.IdFlujoTarea,--12
				FT.IdTipoFlujo,--13
				TOO.IdEstatusOperacion,--14
				TAE.Nombre,--15
				TOO.IdEstadoFlujo,--16
				TOO.IdTipoOperacion,	--17							
				TOO.IdOperacion,--18
				TOO.IdAsignador,--19				
				'' AS Comentario,		--20	
				T.MensajeAsignacion, --21,2
				ISNULL(UE.Nombre, 'No identificado') AS UsuarioElimino --
			FROM TA_Tarea AS T
				INNER JOIN TA_Operacion AS TOO
					ON T.IdOperacion = TOO.IdOperacion
				INNER JOIN TA_FlujoTarea AS FT
					ON TOO.IdFlujoTarea = FT.IdFlujoTarea
				INNER JOIN S_Usuario AS U
					ON T.IdAprobador = U.IdUsuario
				INNER JOIN TA_TipoOperacion AS TTO
					ON TOO.IdTipoOperacion = TTO.IdTipoOperacion
				INNER JOIN TA_Estatus AS TAE
					ON TOO.IdEstatusOperacion = TAE.IdEstatus
				LEFT JOIN dbo.MM_AceptacionFactura AF 
					ON TOO.IdDocumento = AF.IdAceptacionFactura
				LEFT JOIN dbo.MM_AceptacionPedido AP 
					ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN dbo.MM_Pedido P 
					ON AP.IdPedido = P.IdPedido
				LEFT JOIN dbo.MM_Pedidos PG 
					ON P.IdPedido = PG.IdIdentificador
				AND PG.IdProveedorCliente=P.IdProveedorCompras
				LEFT JOIN dbo.S_Usuario UE ON UE.IdUsuario=@IdUsuario ---> usuario elimino al aprobador 
			WHERE T.IdOperacion = @IdOperacion
			AND T.IdTarea=@IdTarea
			AND ISNULL(U.Activo,0) = 1
			GROUP BY
			 U.IdUsuario,--0
				T.NoSecuencia,--1
				U.Nombre,--2
				U.Correo,--3
				T.IdEstatus,--4
				TOO.IdDocumento,--5
				TTO.NombreOperacion,--6
				AF.IdAceptacionPedido,--7
				PG.IdPedido,--8
				U.Telefono,
				P.IdPedido,
				FT.IdFlujoTarea,
				FT.IdTipoFlujo,
				TOO.IdEstatusOperacion,
				TAE.Nombre,
				TOO.IdEstadoFlujo,
				TOO.IdTipoOperacion,							
				TOO.IdOperacion,
				TOO.IdAsignador,								
				T.MensajeAsignacion,
				P.IdSolicitudPedido	,
				UE.Nombre	 
			 

			 ---APROBADORES A LOS QUE SE LES REINICIO SU APROBACIÓN POR UNA ELIMINACIÓN

				 SELECT 
					U.IdUsuario,--0
					T.NoSecuencia,--1
					U.Nombre,--2
					U.Correo,--3
					T.IdEstatus,--4
					TOO.IdDocumento,--5
					TTO.NombreOperacion,--6
					AF.IdAceptacionPedido,--7
					PG.IdPedido AS PedidoGral,--8
					ISNULL(U.Telefono,'') AS Telefono,--9
					P.IdPedido,--10
					P.IdSolicitudPedido,--11
					FT.IdFlujoTarea,--12
					FT.IdTipoFlujo,--13
					TOO.IdEstatusOperacion,--14
					TAE.Nombre,--15
					TOO.IdEstadoFlujo,--16
					TOO.IdTipoOperacion,	--17							
					TOO.IdOperacion,--18
					TOO.IdAsignador,--19				
					'' AS Comentario,		--20	
					T.MensajeAsignacion, --21,2
					ISNULL(UE.Nombre, 'No identificado') AS UsuarioElimino --
				FROM TA_Tarea AS T
				    INNER JOIN #TAREAS_APROBADAS TA 
						ON T.IdTarea = TA.IdTarea
					INNER JOIN TA_Operacion AS TOO
						ON T.IdOperacion = TOO.IdOperacion
					INNER JOIN TA_FlujoTarea AS FT
						ON TOO.IdFlujoTarea = FT.IdFlujoTarea
					INNER JOIN S_Usuario AS U
						ON T.IdAprobador = U.IdUsuario
					INNER JOIN TA_TipoOperacion AS TTO
						ON TOO.IdTipoOperacion = TTO.IdTipoOperacion
					INNER JOIN TA_Estatus AS TAE
						ON TOO.IdEstatusOperacion = TAE.IdEstatus					
					LEFT JOIN dbo.MM_AceptacionFactura AF 
						ON TOO.IdDocumento = AF.IdAceptacionFactura
					LEFT JOIN dbo.MM_AceptacionPedido AP 
						ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
					LEFT JOIN dbo.MM_Pedido P 
						ON AP.IdPedido = P.IdPedido
					LEFT JOIN dbo.MM_Pedidos PG 
						ON P.IdPedido = PG.IdIdentificador
					AND PG.IdProveedorCliente=P.IdProveedorCompras
					LEFT JOIN dbo.S_Usuario UE 
						ON @IdUsuario = UE.IdUsuario---> usuario elimino al aprobador 
				WHERE T.IdOperacion = @IdOperacion	
				AND ISNULL(U.Activo,0) = 1
				GROUP BY
				 U.IdUsuario,--0
					T.NoSecuencia,--1
					U.Nombre,--2
					U.Correo,--3
					T.IdEstatus,--4
					TOO.IdDocumento,--5
					TTO.NombreOperacion,--6
					AF.IdAceptacionPedido,--7
					PG.IdPedido,--8
					U.Telefono,
					P.IdPedido,
					FT.IdFlujoTarea,
					FT.IdTipoFlujo,
					TOO.IdEstatusOperacion,
					TAE.Nombre,
					TOO.IdEstadoFlujo,
					TOO.IdTipoOperacion,							
					TOO.IdOperacion,
					TOO.IdAsignador,								
					T.MensajeAsignacion,
					P.IdSolicitudPedido	,
					UE.Nombre
		END 
		ELSE 
		BEGIN 
			SELECT 'AGREGARNUEVOAPROBADOR' AS RESPONSE
		END 		  

	 END 
	 ELSE 
	 BEGIN
		DECLARE @EstatusActual NVARCHAR(MAX)
		SELECT @EstatusActual=ISNULL(@EstatusActual,'') FROM  dbo.TA_Estatus WHERE IdEstatus=@IdESTATUSACTUAL
		SELECT 'ELIMINACION_NOREALIZADA' AS RESPONSE,@EstatusActual AS EstatusActual
	 END 



END
