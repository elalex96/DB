-- =============================================
-- Author:		Alexander Gomez
-- Create date: 02/05/2022
-- Description:	Envio de notificacion de usuarios OBS
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 03/06/2022
-- Description:	Se obtiene correo de notificaciones directamente desde la tabla 
-- =============================================
-- =============================================
-- Author:		Luis David
-- Create date: 05/10/2022
-- Description:	Optimización
-- =============================================
CREATE PROCEDURE [dbo].[SRAP_EnviarNotificacionOBSAprobacionSolicitudAceptacion] --10038,12185,27250,1081,'4500000002',2653
	-- Add the parameters for the stored procedure hePut your HTML text herere
	@ContratoId INT,
	@NumeroPedidoGral INT,
	@IdPedido INT,
	@NoSolicitudRecepcionPedido INT,
	@PO NVARCHAR(1000),
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CorreoNotificaciones NVARCHAR(MAX),
	@HTML NVARCHAR(MAX),
	@ASUNTO NVARCHAR(1000),
	@DESTINATARIO NVARCHAR(500),
	@DESTINATARIO_NOMBRE NVARCHAR(500),
	@ID_NOTIFICACION INT,
	@CONT_TOTAL INT,
	@ROW INT = 1,
	@NUMERO_CONTRATO NVARCHAR(500)= (SELECT TOP 1
													C.NumeroContrato + ' - ' + AC.NombreAreaContractual
												FROM Adinco.dbo.CO_Contrato AS C (NOLOCK)
												JOIN Adinco.dbo.CO_AreaContractual AS AC (NOLOCK)
													ON C.IdAreaContractual = AC.IdAreaContractual
												WHERE C.IdContrato = @ContratoId),
	--SE OBTIENE EL NOMBRE DEL SUBCONTRATISTA
	@PROVEEDOR NVARCHAR(500) = (SELECT TOP 1
											PR.RazonSocial 
										FROM MM_Pedido AS P (NOLOCK)
										JOIN S_Proveedor AS PR (NOLOCK) ON
											P.IdSubcontratista = PR.IdProveedor
										WHERE P.IdPedido = @IdPedido);
	DECLARE @USUARIOS_OBS TABLE (R INT IDENTITY(1,1) PRIMARY KEY,
								ID_USUARIO INT, 
								NOMBRE NVARCHAR(500), 
								CORREO NVARCHAR(500));

	--CONSULTA DE TODOS LOS USUARIOS OBS DEL CONTRATO
	INSERT @USUARIOS_OBS(
		ID_USUARIO,
		NOMBRE,
		CORREO
	)
	SELECT 			
		U.IdUsuario,
		U.Nombre,
		U.Correo
	FROM DEA_UsuarioOBS UOBS (NOLOCK)
		JOIN S_Usuario U (NOLOCK)
	ON UOBS.IdUsuario = U.IdUsuario				
	WHERE 1 = UOBS.Activo
		AND @ContratoId = UOBS.IdContrato		
	GROUP BY U.IdUsuario,
		U.Nombre,
		U.Correo;

	--SE OBTIENE EL TOTAL DE APROBADORES
	SET @CONT_TOTAL = (SELECT COUNT(1) FROM @USUARIOS_OBS);
	SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C (NOLOCK)
									INNER JOIN TA_CorreoServidor AS S (NOLOCK)
										ON  C.IdServidor = S.IdServidor
								WHERE IdCorreo = 109) --> CTE NUMERO CORREO (TA_Correo)

	--SE RECORREN Y ENVIAN LOS CORREOS DE NOTIFICACIONES A LOS USUARIOS
	WHILE @CONT_TOTAL >= @ROW
	BEGIN

		SET @HTML = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 109);
		SET @ASUNTO = (SELECT Asunto FROM dbo.TA_Correo WHERE IdCorreo = 109);
		SET @DESTINATARIO = (SELECT CORREO FROM @USUARIOS_OBS WHERE R = @ROW);
		SET @DESTINATARIO_NOMBRE = (SELECT NOMBRE FROM @USUARIOS_OBS WHERE R = @ROW);

		SET @HTML = (REPLACE(@HTML,'##NOMBRE_USUARIO##',@DESTINATARIO_NOMBRE));
		SET @HTML = (REPLACE(@HTML,'##RazonSocialProveedor##',@PROVEEDOR));
		SET @HTML = (REPLACE(@HTML,'##NombreProveedor##',@PROVEEDOR));
		SET @HTML = (REPLACE(@HTML,'##SAPPONO##',@PO));
		SET @HTML = (REPLACE(@HTML,'##NO_SOLICITUDACEPTACION_PEDIDO##',@NoSolicitudRecepcionPedido));
		SET @HTML = (REPLACE(@HTML,'##NUMERO_PEDIDO##',CAST(@NumeroPedidoGral AS NVARCHAR)));
		SET @HTML = (REPLACE(@HTML,'#CONTRATO#',@NUMERO_CONTRATO));
		SET @HTML = (REPLACE(@HTML,'##URL_TAREA##','http://procura.adinco.mx/02Proveedores/SolicitudAceptacionPedido.aspx?pedido=' + CAST(@IdPedido AS NVARCHAR) + '&solicitud=' + CAST(@NoSolicitudRecepcionPedido AS NVARCHAR)));
		SET @HTML = (REPLACE(@HTML,'##ANIO_ACTUAL##',YEAR(GETDATE())));

		SET @ASUNTO = (REPLACE(@ASUNTO,'##NúmeroSolicitud##',CAST(@NoSolicitudRecepcionPedido AS NVARCHAR)));
		SET @ASUNTO = (REPLACE(@ASUNTO,'##NumeroPOSAP##',@PO));

		SET @ID_NOTIFICACION = ((SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion) + 1);

		--SELECT @HTML,@DESTINATARIO_NOMBRE,@PROVEEDOR,@NoSolicitudRecepcionPedido,@PO,@NUMERO_CONTRATO,@ID_NOTIFICACION,@ASUNTO

		--INCERTADO EN LA TABLA DE NOTIFICACIONES
		INSERT INTO Adinco.dbo.S_Notificacion
		(
			IdNotificacion,
			Para,
			Asunto,
			Mensaje,
			FechaProgramadaEnvio,
			Enviada,
			FechaEnvio,
			CreadoPor,
			CreadoEl,
			ModificadoPor,
			ModificadoEl,
			De,
			EN_MsjEnviado
		)
		VALUES
		(	@ID_NOTIFICACION,         -- IdNotificacion - bigint
			@DESTINATARIO,        -- Para - varchar(1000)
			@ASUNTO,        -- Asunto - varchar(500)
			@HTML,        -- Mensaje - text
			DATEADD(MINUTE,1,GETDATE()), -- FechaProgramadaEnvio - datetime
			0,      -- Enviada - bit
			NULL, -- FechaEnvio - datetime
			3,         -- CreadoPor - int
			GETDATE(), -- CreadoEl - datetime
			NULL,         -- ModificadoPor - int
			NULL, -- ModificadoEl - datetime
			ISNULL(@CorreoNotificaciones,''),        -- De - varchar(100)
			NULL       -- EN_MsjEnviado - bit
		);

		INSERT INTO dbo.TA_EnvioCorreo
		(
			IdEnvioAdinco,
			IdCorreo,
			IdIdentificacion,
			EnviadoPor,
			EnviadoEl
		)
		VALUES
		(   @ID_NOTIFICACION, -- IdEnvioAdinco - int
			109, 
			CONCAT('Aprobación de Solicitud de recepción de bienes y servicios #' , @NoSolicitudRecepcionPedido),  -- IdIdentificacion - int
			@IdUsuario,
			GETDATE()
		);

		--INCERTADO EN LA BITACORA DE NOTIFICACIONES
		INSERT INTO dbo.TA_BitacoraCorreo
		(
			IdDocumento,
			Detalle,
			Correo,
			Enviado,
			FechaEnvio,
			IdUsuarioEnvio,
			IdProveedorEnvio,
			IdUsuarioReceptor
		)
		VALUES
		(   @NoSolicitudRecepcionPedido,         -- IdDocumento - int
			N'Aprobación de Solicitud de recepción de bienes y servicios',       -- Detalle - nvarchar(max)
			@DESTINATARIO,       -- Correo - nvarchar(350)
			1,      -- Enviado - bit
			GETDATE(), -- FechaEnvio - datetime
			0,         -- IdUsuarioEnvio - int
			0,         -- IdProveedorEnvio - int
			0          -- IdUsuarioReceptor - int
		);

		SET @ROW = @ROW + 1;
	END

END
