USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_ActualizarSolicitanteSolped]    Script Date: 30/09/2021 03:00:12 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ActualizarSolicitanteSolped]
    @IdSolicitudPedido INT,
    @IdSolicitnate INT,
    @IdUsuario INT
AS
BEGIN
	DECLARE @IdSolicitudAceptacionPedido INT, @CONT INT, @CONTTOTAL INT, @IdTareaOBS INT;
	DECLARE @TipoOperacionId INT = (SELECT IdTipoOperacion FROM TA_TipoOperacion WHERE NombreOperacion='Aprobación de solicitud de aceptación de pedido');
	DECLARE @IdProveedor INT = (SELECT IdProveedor FROM MM_SolicitudPedido WHERE IdSolicitudPedido = @IdSolicitudPedido);
	DECLARE @IdOperacion INT;
    DECLARE @SolicitanteAnterior NVARCHAR(MAX) = (SELECT TOP 1
														US.Nombre
													FROM S_Usuario AS US
													JOIN MM_SolicitudPedido AS SP 
														ON SP.Solicitante = US.IdUsuario 
														AND SP.IdSolicitudPedido = @IdSolicitudPedido);

	DECLARE @SolicitanteNuevo NVARCHAR(MAX) = (SELECT TOP 1
														US.Nombre
													FROM S_Usuario AS US
													WHERE IdUsuario = @IdSolicitnate);

	IF ISNULL(@SolicitanteAnterior,'') != ISNULL(@SolicitanteNuevo,'')
	BEGIN

		IF (ISNULL(@IdSolicitudPedido, 0) <> 0)
		BEGIN
			UPDATE dbo.MM_SolicitudPedido
			SET Solicitante = @IdSolicitnate
			WHERE IdSolicitudPedido = @IdSolicitudPedido
		END

		INSERT INTO dbo.HistorialObjetoDelPedido
		(
			IdSolicitudPedido,
			IdUsuarioModifico,
			MotivoAnterior,
			FechaModificado
		)
		SELECT @IdSolicitudPedido,
			   @IdUsuario,
			   'Se cambia el solicitante ' + isnull(@SolicitanteAnterior,'') + ' a ' + isnull(@SolicitanteNuevo,''),
			   GETDATE();

	END
	
	SET @SolicitanteNuevo = (SELECT top 1 S.Nombre
	FROM MM_SolicitudPedido SP
	join s_usuario S 
	on SP.Solicitante = S.IdUsuario
	WHERE IdSolicitudPedido = @IdSolicitudPedido)

	--MODIFICACION DE TAREAS DEL SOLICITANTE
	--SE OBTIENEN TODAS LAS ACEPTACIONES REFERENTES A LA SOLICITUD DE PEDIDO
	SELECT
		ROW_NUMBER() over( order by SAP.IdSolicitudAceptacionPedido desc) as RN,
		SAP.IdSolicitudAceptacionPedido,
		T.IdOperacion,
		P.IdPedido,
		SP.IdSolicitudPedido
	INTO #ACEPTACIONES
	FROM dbo.MM_SolicitudAceptacionPedido AS SAP
	JOIN MM_Pedido AS P ON SAP.IdPedido = P.IdPedido
	JOIN MM_SolicitudPedido AS SP ON P.IdSolicitudPedido = SP.IdSolicitudPedido
	JOIN TA_Operacion AS T 
		ON SAP.IdSolicitudAceptacionPedido = T.IdDocumento 
		AND T.IdTipoOperacion = @TipoOperacionId
		AND SP.IdSolicitudPedido = @IdSolicitudPedido
	WHERE SAP.Activo = 1
	GROUP BY SAP.IdSolicitudAceptacionPedido,
		T.IdOperacion,
		P.IdPedido,
		SP.IdSolicitudPedido;

	SET @CONT = 1;
	SET @CONTTOTAL = (SELECT COUNT(1) FROM #ACEPTACIONES);

	--RECORRIDO DE TODAS LAS ACEPTACIONES
	WHILE @CONT <= @CONTTOTAL
	BEGIN
		
		--RECUPERACION DE LA OPERACION
		SET @IdOperacion = (SELECT IdOperacion FROM #ACEPTACIONES WHERE RN = @CONT);
		--RECUPEREACION DE LA SOLICITUD DE ACEPTACION DE PEDIDO
		SET @IdSolicitudAceptacionPedido = (SELECT IdSolicitudAceptacionPedido FROM #ACEPTACIONES WHERE RN = @CONT);
		
		--DESACTIVACION DE LAS TAREAS ASOCIADAS A LA OPERACION
		UPDATE TA_Tarea
		SET Activo = 0,
			Comentario = 'TAREA DESACTIVADA POR REASIGNACION DE SOLICITANTE'
		WHERE IdOperacion = @IdOperacion
			AND NombreTarea != 'Solicitud Aceptación pedido OBS';

		--SE INCERTA UNA NUEVA TAREA CON EL SOLICITANTE
		INSERT INTO TA_Tarea
		(
			NombreTarea,
			FechaRegistro,
			IdEstatus,
			Activo, 
			IdAprobador,
			NoSecuencia,
			IdOperacion
		)
		values
		(
			'Solicitud Aceptación pedido',
			GETDATE(),
			1,--APROBADA
			1,
			@IdSolicitnate,
			1,
			@IdOperacion
		);

		SET @CONT = @CONT + 1;

		--ACTUALIZACION DE LA SECUENCIA DE LA TAREA OBS
		SET @IdTareaOBS = (SELECT TOP 1 IdTarea FROM dbo.TA_Tarea WHERE NombreTarea = 'Solicitud Aceptación pedido OBS' AND IdOperacion = @IdOperacion AND Activo = 1);

		UPDATE TA_Tarea
		SET NoSecuencia = @CONT
		WHERE IdTarea = @IdTareaOBS;

	END

	SELECT 'TRUE',@SolicitanteNuevo

END
