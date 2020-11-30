-- =============================================
-- Author:		<Daniel AC>
-- Create date: <02-08-19>
-- Description:	<Consulta usuarios con rol de aprobación de factura>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_AgregarNuevoFlujoAprobacionFactura]  
@IdProveedor INT,
@IdUsuario INT,
@IdAceptacionFactura INT, 
@IdNuevoFlujoAprobacion INT,
@IdOperacion INT,
@MensajeAsignacion NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @FECHAMODIFICACION DATETIME  = GETDATE()
	 --VALIDAR QUE LA APROBACIÓN ESTE EN ESTATUS DE EN_APROBACIÓN 

	  DECLARE @IdESTATUSACTUAL INT 

	 SELECT @IdESTATUSACTUAL= IdEstatusOperacion FROM dbo.TA_Operacion WHERE IdOperacion=@IdOperacion
	 IF ISNULL(@IdESTATUSACTUAL,0) = 1 --APROBACIÓN TIENE QUE ESTAR EN APROBACIÓN
	 BEGIN 
		CREATE TABLE #OLD_APROBADORES(IdTarea INT, IdAprobador INT, IdOperacion INT, NoSecuencia INT)

		INSERT INTO #OLD_APROBADORES
		SELECT IdTarea,IdAprobador, IdOperacion, NoSecuencia FROM TA_Tarea WHERE IdOperacion= @IdOperacion AND Activo=1

		
		-- AGREGAR AL HISTORIAL LOS APROBADORES ELIMINADOS
	    INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
		SELECT  
		CONCAT('El usuario ',ISNULL(UE.Nombre,' usuario no identificado '),' ha eliminado al usuario ' , ISNULL(UA.Nombre,' usuario no identificado '),  ' de la aprobación de la factura'),
		@IdOperacion,
		@FECHAMODIFICACION,
		10--> ESTATUS DE ELIMINACIÓN DE  SELECT * FROM dbo.TA_EstadoFlujoTarea WHERE Idestado=10
		FROM dbo.TA_Tarea  T
		LEFT JOIN dbo.S_Usuario UA ON UA.IdUsuario=T.IdAprobador
		LEFT JOIN dbo.S_Usuario UE ON UE.IdUsuario=@IdUsuario --> USUARIO ACTUAL
		WHERE T.Activo=1
		AND T.IdOperacion=@IdOperacion 

		--APROBADORES ACTUALES PASARLOS A ELIMINADOS 
		UPDATE TA_Tarea 
		SET Activo=0,
		IdEstatus=12, ---> ELIMINADO
		EliminadoPor=@IdUsuario,
		EliminadoEl=@FECHAMODIFICACION
		WHERE Activo=1
		AND IdOperacion=@IdOperacion

		---ACTUALIZAR EL NUEVO FLUJO DE APROBACION EN LA OPERACION
		UPDATE dbo.TA_Operacion 
		SET IdEstadoFlujo=1,
		IdFlujoTarea=@IdNuevoFlujoAprobacion
		WHERE IdOperacion=@IdOperacion		

		--AGREGAR NUEVOS APROBADORES 
		INSERT INTO dbo.TA_Tarea(NombreTarea,FechaRegistro,IdEstatus,Activo, Visto,IdAprobador,NoSecuencia,IdOperacion, AsignadoPor,MensajeAsignacion)	
		SELECT 'Aprobación de Factura',@FECHAMODIFICACION, 1, 1,0, IdUsuario, NoSecuencia,@IdOperacion, @IdUsuario, @MensajeAsignacion
		FROM dbo.TA_Aprobador 
		WHERE IdFlujoTarea=@IdNuevoFlujoAprobacion

		---AGREGAR AL HISTORIAL LOS NUEVOS APROBADORES 
		 INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
		SELECT  
		CONCAT('El usuario ',ISNULL(UE.Nombre,' usuario no identificado '),'  ha asignado como aprobador de la factura al usuario  ' , ISNULL(UA.Nombre,' usuario no identificado ')),
		@IdOperacion,
		@FECHAMODIFICACION,
		8--> REASIGNACIÓN DE TAREA 
		FROM dbo.TA_Aprobador A
		LEFT JOIN dbo.S_Usuario UA ON UA.IdUsuario=A.IdUsuario
		LEFT JOIN dbo.S_Usuario UE ON UE.IdUsuario=@IdUsuario --> USUARIO ACTUAL
		WHERE A.IdFlujoTarea=@IdNuevoFlujoAprobacion
				
		SELECT 'SUCCESS'

		---MANDAR NOTIFICACION A LOS USUARIOS QUE ESTABAN ANTES DE QUE YA NO ESTA PARTE DE LA APROBACIÓN DE FACTURA 
		   SELECT 
			    U.IdUsuario,--0
				OA.NoSecuencia,--1
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
				T.MensajeAsignacion, --21
				ISNULL(UE.Nombre,' Usuario no identificado')
			FROM dbo.TA_Tarea AS T
				INNER JOIN #OLD_APROBADORES OA 
					ON OA.IdTarea = T.IdTarea
				INNER JOIN TA_Operacion AS TOO
					ON TOO.IdOperacion = T.IdOperacion
				INNER JOIN TA_FlujoTarea AS FT
					ON FT.IdFlujoTarea = TOO.IdFlujoTarea
				INNER JOIN S_Usuario AS U
					ON U.IdUsuario = T.IdAprobador
				INNER JOIN TA_TipoOperacion AS TTO
					ON TTO.IdTipoOperacion = TOO.IdTipoOperacion
				INNER JOIN TA_Estatus AS TAE
					ON TAE.IdEstatus = TOO.IdEstatusOperacion
				LEFT JOIN dbo.MM_AceptacionFactura AF 
					ON AF.IdAceptacionFactura=TOO.IdDocumento
				LEFT JOIN dbo.MM_AceptacionPedido AP 
					ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
				LEFT JOIN dbo.MM_Pedido P ON P.IdPedido = AP.IdPedido
				LEFT JOIN dbo.MM_Pedidos PG ON PG.IdIdentificador=P.IdPedido
				AND PG.IdProveedorCliente=P.IdProveedorCompras
				LEFT JOIN dbo.S_Usuario UE ON UE.IdUsuario=@IdUsuario --> USUARIO ACTUAL
			WHERE T.IdOperacion = @IdOperacion			
			GROUP BY
			 U.IdUsuario,--0
				OA.NoSecuencia,--1
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
				P.IdSolicitudPedido,
				UE.Nombre

		-- MANDAR NOTIFICACIÓN A LOS NUEVOS APROBADORES
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
				T.MensajeAsignacion, --21
				ISNULL(UE.Nombre,' Usuario no identificado')
			FROM dbo.TA_Tarea AS T				
				INNER JOIN TA_Operacion AS TOO
					ON TOO.IdOperacion = T.IdOperacion
				INNER JOIN TA_FlujoTarea AS FT
					ON FT.IdFlujoTarea = TOO.IdFlujoTarea
				INNER JOIN S_Usuario AS U
					ON U.IdUsuario = T.IdAprobador
				INNER JOIN TA_TipoOperacion AS TTO
					ON TTO.IdTipoOperacion = TOO.IdTipoOperacion
				INNER JOIN TA_Estatus AS TAE
					ON TAE.IdEstatus = TOO.IdEstatusOperacion
				LEFT JOIN dbo.MM_AceptacionFactura AF 
					ON AF.IdAceptacionFactura=TOO.IdDocumento
				LEFT JOIN dbo.MM_AceptacionPedido AP 
					ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
				LEFT JOIN dbo.MM_Pedido P ON P.IdPedido = AP.IdPedido
				LEFT JOIN dbo.MM_Pedidos PG ON PG.IdIdentificador=P.IdPedido
				AND PG.IdProveedorCliente=P.IdProveedorCompras
				LEFT JOIN dbo.S_Usuario UE ON UE.IdUsuario=@IdUsuario --> USUARIO ACTUAL
			WHERE T.IdOperacion = @IdOperacion	
			AND T.Activo=1--> SOLO APROBADORES ACTIVOS		
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
				P.IdSolicitudPedido,
				UE.Nombre

	 END 
	 ELSE 
	 BEGIN
		DECLARE @EstatusActual NVARCHAR(MAX)
		SELECT @EstatusActual=ISNULL(@EstatusActual,'') FROM  dbo.TA_Estatus WHERE IdEstatus=@IdESTATUSACTUAL
		SELECT 'ESTATUS_NOENAPROBACION' AS Response,@EstatusActual AS EstatusActual
	 END 
 

END

 
