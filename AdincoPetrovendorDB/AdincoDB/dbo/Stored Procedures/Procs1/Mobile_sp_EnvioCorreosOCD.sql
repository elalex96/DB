-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <09/02/2020>
-- Description:	<Consultar de correos para la aprobacion de compra directa desde la app>
-- =============================================
CREATE PROCEDURE [dbo].[Mobile_sp_EnvioCorreosOCD]-- 51368,10394,64243
	-- Add the parameters for the stored procedure here
	@IdOperacion int,
	@IdUsuario int,
	@IdTarea int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IDUSUARIOADINCO INT = @IdUsuario;
	SET @IdUsuario = (SELECT top 1 IdUsuario FROM Petrovendor.dbo.S_Usuario WHERE IdUsuarioADINCO = @IdUsuario)

    -- Insert statements for procedure here
	DECLARE @HTML NVARCHAR(MAX);
	DECLARE @ASUNTO NVARCHAR(MAX);
	DECLARE @NOSECUENCIA INT;
	DECLARE @IDAPROBADOR INT;
	DECLARE @IDFLUJOTAREA INT;
	DECLARE @IDTIPOFLUJO INT;
	DECLARE @IDPEDIDO INT;
	DECLARE @IDESTATUS INT;
	DECLARE @IDDOCUMENTO INT;
	DECLARE @IDASIGNADOR INT;
	DECLARE @IDNOTIFICACION INT;
	DECLARE @NOMBREPROVEEDOR NVARCHAR(500);
	DECLARE @NOMBREUSUARIO NVARCHAR(500);
	DECLARE @CORREOUSUARIO NVARCHAR(500);
	DECLARE @AREACONTRACTUAL NVARCHAR(500);
	DECLARE @DESCRIPCION NVARCHAR(MAX);
	DECLARE @URLACEPTAR NVARCHAR(MAX);
	DECLARE @URLRECHAZAR NVARCHAR(MAX);
	DECLARE @URLDETALLE NVARCHAR(MAX);

	--OBTENCION DE DATOS NECESARIOS PARA EL ENVIO DE CORREO
	SELECT
		@IDAPROBADOR = T.IdAprobador,
		@NOSECUENCIA = T.NoSecuencia,
		@NOMBREUSUARIO = US.Nombre,
		@CORREOUSUARIO = US.Correo,
		@IDTIPOFLUJO = FT.IdTipoFlujo,
		@IDPEDIDO = PS.IdPedido,
		@IDESTATUS = TA.IdEstatusOperacion
	FROM Petrovendor.dbo.TA_Tarea AS T
		JOIN Petrovendor.dbo.S_Usuario AS US ON T.IdAprobador = US.IdUsuario
		JOIN Petrovendor.dbo.TA_Operacion AS TA ON TA.IdOperacion = T.IdOperacion AND TA.IdTipoOperacion = 14--COMPRA DIRECTA
		JOIN Petrovendor.dbo.TA_FlujoTarea AS FT ON FT.IdFlujoTarea = TA.IdFlujoTarea
		JOIN Petrovendor.dbo.MM_Pedidos AS PS ON PS.IdIdentificador = TA.IdDocumento AND PS.IdTipoPedido = 1--COMPRA DIRECTA
	WHERE T.IdOperacion = @IdOperacion AND 
			T.IdTarea = @IdTarea;

	--SI LA OPERACION SIGUE ESTANDO EN APROBACION CONTINUA LA NOTIFICACION SEGUN EL FLUJO
	IF @IDESTATUS = 1
	BEGIN
		--SE EVALUA EL TIPO DE FLUJO
		IF @IDTIPOFLUJO = 1 --SERIAL
		BEGIN
			
			SELECT
				@HTML = HTML
			FROM TA_Correo
			WHERE IdCorreo = 1

			SELECT TOP 1
				@IDAPROBADOR = T.IdAprobador,
				@NOSECUENCIA = T.NoSecuencia,
				@NOMBREUSUARIO = US.Nombre,
				@CORREOUSUARIO = US.Correo,
				@IDUSUARIOADINCO = US.IdUsuarioADINCO,
				@DESCRIPCION = TA.Descripcion,
				@AREACONTRACTUAL = CO.NumeroContrato + ' - ' + AC.NombreAreaContractual,
				@IDDOCUMENTO = TA.IdDocumento,
				@IDASIGNADOR = TA.IdAsignador
			FROM Petrovendor.dbo.TA_Tarea AS T
				LEFT JOIN Petrovendor.dbo.S_Usuario AS US ON T.IdAprobador = US.IdUsuario
				LEFT JOIN Petrovendor.dbo.TA_Operacion AS TA ON TA.IdOperacion = T.IdOperacion AND TA.IdTipoOperacion = 14--COMPRA DIRECTA
				LEFT JOIN Petrovendor.dbo.TA_FlujoTarea AS FT ON FT.IdFlujoTarea = TA.IdFlujoTarea
				LEFT JOIN Petrovendor.dbo.MM_Pedidos AS PS ON PS.IdIdentificador = TA.IdDocumento AND PS.IdTipoPedido = 1--COMPRA DIRECTA
				LEFT JOIN Petrovendor.dbo.FI_Factura AS FI ON FI.IdFactura = TA.IdDocumento
				LEFT JOIN Adinco.dbo.CO_Contrato AS CO ON CO.IdContrato = FI.IdContrato
				LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON AC.IdAreaContractual = CO.IdAreaContractual
			WHERE T.IdOperacion = @IdOperacion AND 
					T.NoSecuencia = (@NOSECUENCIA + 1) AND 
					T.Activo = 1 AND 
					T.FechaCambioEstatus IS NULL AND 
					T.IdEstatus = 1
			ORDER BY NoSecuencia ASC;

			IF ISNULL(@IDAPROBADOR,0) > 0
			BEGIN
				
			SET @URLACEPTAR = 'https://procura.adinco.mx/04Tareas/AprobacionCompraDirecta.aspx?num_operacion=' + LEFT(CONVERT(VARCHAR(36),NEWID()),8) + CAST(@IdOperacion AS nvarchar) + RIGHT(CONVERT(VARCHAR(36),NEWID()),8) + '&response=2&num_tarea=&num_user=' + LEFT(CONVERT(VARCHAR(36),NEWID()),8) + CAST(@IDAPROBADOR AS NVARCHAR) + RIGHT(CONVERT(VARCHAR(36),NEWID()),8) + '&compra = ' + LEFT(CONVERT(VARCHAR(36),NEWID()),8) + CAST(@IDDOCUMENTO AS nvarchar) + RIGHT(CONVERT(VARCHAR(36),NEWID()),8) + '&creado=' + LEFT(CONVERT(VARCHAR(36),NEWID()),8) + CAST(@IDASIGNADOR AS nvarchar) + RIGHT(CONVERT(VARCHAR(36),NEWID()),8);
			SET @URLRECHAZAR = 'https://procura.adinco.mx/04Tareas/AprobacionCompraDirecta.aspx?num_operacion=' + LEFT(CONVERT(VARCHAR(36),NEWID()),8) + CAST(@IdOperacion AS nvarchar) + RIGHT(CONVERT(VARCHAR(36),NEWID()),8) + '&response=3&num_tarea=&num_user=' + LEFT(CONVERT(VARCHAR(36),NEWID()),8) + CAST(@IDAPROBADOR AS NVARCHAR) + RIGHT(CONVERT(VARCHAR(36),NEWID()),8) + '&compra = ' + LEFT(CONVERT(VARCHAR(36),NEWID()),8) + CAST(@IDDOCUMENTO AS nvarchar) + RIGHT(CONVERT(VARCHAR(36),NEWID()),8) + '&creado=' + LEFT(CONVERT(VARCHAR(36),NEWID()),8) + CAST(@IDASIGNADOR AS nvarchar) + RIGHT(CONVERT(VARCHAR(36),NEWID()),8);
			SET @URLDETALLE = 'https://procura.adinco.mx/02Proveedores/DetalleCompraDirecta.aspx?num_operacion=' + LEFT(CONVERT(VARCHAR(36),NEWID()),8) + CAST(@IdOperacion AS nvarchar) + RIGHT(CONVERT(VARCHAR(36),NEWID()),8) + '&compra = ' + LEFT(CONVERT(VARCHAR(36),NEWID()),8) + CAST(@IDDOCUMENTO AS nvarchar) + RIGHT(CONVERT(VARCHAR(36),NEWID()),8) + '&creado=' + LEFT(CONVERT(VARCHAR(36),NEWID()),8) + CAST(@IDASIGNADOR AS nvarchar) + RIGHT(CONVERT(VARCHAR(36),NEWID()),8) + '&num_user=' + LEFT(CONVERT(VARCHAR(36),NEWID()),8) + CAST(@IDAPROBADOR AS NVARCHAR) + RIGHT(CONVERT(VARCHAR(36),NEWID()),8) + '&origin=t&tp_user=' + LEFT(CONVERT(VARCHAR(36),NEWID()),8) + CAST(1 AS NVARCHAR) + RIGHT(CONVERT(VARCHAR(36),NEWID()),8);

			SET @HTML = (REPLACE(@HTML,'##NUMERO_OPERACION##',CAST(@IDPEDIDO AS nvarchar)));
			SET @HTML = (REPLACE(@HTML,'##TIPO_OPERACION##','Orden de Compra Directa'));
			SET @HTML = (REPLACE(@HTML,'##NOMBRE_USUARIO##',@NOMBREUSUARIO));
			SET @HTML = (REPLACE(@HTML,'##DESCRIPCION_TAREA##',@DESCRIPCION));
			SET @HTML = (REPLACE(@HTML,'##AREA_CONTRACTUAL##',@AREACONTRACTUAL));

			SET @HTML = (REPLACE(@HTML,'##URL_TAREA_ACEPTAR##',@URLACEPTAR));
			SET @HTML = (REPLACE(@HTML,'##URL_TAREA_RECHAZAR##',@URLRECHAZAR));
			SET @HTML = (REPLACE(@HTML,'##URL_TAREA##',@URLDETALLE));

			SET @HTML = (REPLACE(@HTML,'##ANIO_ACTUAL##',YEAR(GETDATE())));

			SET @IDNOTIFICACION = ((SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion) + 1);

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
			(	@IDNOTIFICACION,         -- IdNotificacion - bigint
				@CORREOUSUARIO,        -- Para - varchar(1000)
				    'Aprobación Serial de Orden de Compra Directa #' + CAST(@IDDOCUMENTO as nvarchar),        -- Asunto - varchar(500)
				    @HTML,        -- Mensaje - text
				    DATEADD(MINUTE,1,GETDATE()), -- FechaProgramadaEnvio - datetime
				    0,      -- Enviada - bit
				    NULL, -- FechaEnvio - datetime
				    3,         -- CreadoPor - int
				    GETDATE(), -- CreadoEl - datetime
				    NULL,         -- ModificadoPor - int
				    NULL, -- ModificadoEl - datetime
				    'procura@adinco.mx',        -- De - varchar(100)
				    NULL       -- EN_MsjEnviado - bit
			);

			INSERT INTO Petrovendor.dbo.TA_EnvioCorreo
			(
					IdEnvioAdinco,
					IdCorreo,
					IdIdentificacion,
					EnviadoPor,
					EnviadoEl
			)
			VALUES
			(   @IdNotificacion, -- IdEnvioAdinco - int
				1, -- CORREO DE PETICION OFERTA
				CONCAT('0 - Notificacion para Aprobacion de Orden de Compra Directa #' , @IDDOCUMENTO),  -- IdIdentificacion - int
				@IdUsuario,
				GETDATE()
			);

			INSERT INTO Petrovendor.dbo.TA_BitacoraCorreo
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
			(   @IDDOCUMENTO,         -- IdDocumento - int
				N'Notificacion de Aprobacion para Pedimento/Comprobante',       -- Detalle - nvarchar(max)
				@CORREOUSUARIO,       -- Correo - nvarchar(350)
				1,      -- Enviado - bit
				GETDATE(), -- FechaEnvio - datetime
				0,         -- IdUsuarioEnvio - int
				0,         -- IdProveedorEnvio - int
				0          -- IdUsuarioReceptor - int
			);
			END


			--TABLA PARA EL ENVIO DE LA PUSH NOTIFICATION
			SELECT 
				@IDUSUARIOADINCO,
				'Nueva Aprobación' AS TITULO,
				'Orden de Compra Directa #' + CAST(@IDPEDIDO AS NVARCHAR) AS SUBTITULO,
				'Estimado(a) ' + @NOMBREUSUARIO + 'te informamos que tiene pendiente la aprobación de la compra directa #'+ CAST(@IDPEDIDO AS NVARCHAR) AS MENSAJE,
				GETDATE()

		END
		ELSE
		BEGIN
			
			SELECT
			'NO_REQUIERE_NOTIFICACION'

		END
		

	END
	ELSE
	BEGIN

		SELECT
			'NO_REQUIERE_NOTIFICACION'

	END


END
