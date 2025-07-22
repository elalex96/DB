USE [Adinco]
GO
IF OBJECT_ID('Petrovendor..Mobile_sp_EnvioCorreosOCD') IS NOT NULL
BEGIN
DROP PROCEDURE Mobile_sp_EnvioCorreosOCD;
END
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <09/02/2020>
-- Description:	<Consultar de correos para la aprobacion de compra directa desde la app>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <22/07/2025>
-- Description:	<Retorno del correo de compra directa>
-- =============================================
CREATE PROCEDURE [dbo].[Mobile_sp_EnvioCorreosOCD]
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
	FROM Petrovendor.dbo.TA_Tarea AS T (NOLOCK)
		JOIN Petrovendor.dbo.S_Usuario AS US (NOLOCK) ON T.IdAprobador = US.IdUsuario
		JOIN Petrovendor.dbo.TA_Operacion AS TA (NOLOCK) ON TA.IdOperacion = T.IdOperacion AND TA.IdTipoOperacion = 14--COMPRA DIRECTA
		JOIN Petrovendor.dbo.TA_FlujoTarea AS FT (NOLOCK) ON FT.IdFlujoTarea = TA.IdFlujoTarea
		JOIN Petrovendor.dbo.MM_Pedidos AS PS (NOLOCK) ON PS.IdIdentificador = TA.IdDocumento AND PS.IdTipoPedido = 1--COMPRA DIRECTA
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
			FROM Petrovendor.dbo.TA_Tarea AS T (NOLOCK)
				LEFT JOIN Petrovendor.dbo.S_Usuario AS US (NOLOCK) ON T.IdAprobador = US.IdUsuario
				LEFT JOIN Petrovendor.dbo.TA_Operacion AS TA (NOLOCK) ON TA.IdOperacion = T.IdOperacion AND TA.IdTipoOperacion = 14--COMPRA DIRECTA
				LEFT JOIN Petrovendor.dbo.TA_FlujoTarea AS FT (NOLOCK) ON FT.IdFlujoTarea = TA.IdFlujoTarea
				LEFT JOIN Petrovendor.dbo.MM_Pedidos AS PS (NOLOCK) ON PS.IdIdentificador = TA.IdDocumento AND PS.IdTipoPedido = 1--COMPRA DIRECTA
				LEFT JOIN Petrovendor.dbo.FI_Factura AS FI (NOLOCK) ON FI.IdFactura = TA.IdDocumento
				LEFT JOIN Adinco.dbo.CO_Contrato AS CO (NOLOCK) ON CO.IdContrato = FI.IdContrato
				LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC (NOLOCK) ON AC.IdAreaContractual = CO.IdAreaContractual
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
			SET @HTML = (REPLACE(@HTML,'##NOMBRE_USUARIO##',ISNULL(@NOMBREUSUARIO,'')));
			SET @HTML = (REPLACE(@HTML,'##DESCRIPCION_TAREA##',ISNULL(@DESCRIPCION,'')));
			SET @HTML = (REPLACE(@HTML,'##AREA_CONTRACTUAL##',ISNULL(@AREACONTRACTUAL,'')));

			SET @HTML = (REPLACE(@HTML,'##URL_TAREA_ACEPTAR##',ISNULL(@URLACEPTAR,'')));
			SET @HTML = (REPLACE(@HTML,'##URL_TAREA_RECHAZAR##',ISNULL(@URLRECHAZAR,'')));
			SET @HTML = (REPLACE(@HTML,'##URL_TAREA##',ISNULL(@URLDETALLE,'')));

			SET @HTML = (REPLACE(@HTML,'##ANIO_ACTUAL##',YEAR(GETDATE())));

				--TABLA PARA EL ENVIO DE CORREOS
				SELECT @CORREOUSUARIO AS Para,        -- Para - varchar(1000)
					   'Aprobaci�n Serial de Orden de Compra Directa #' + CAST(@IDPEDIDO as nvarchar) AS Asunto,        -- Asunto - varchar(500)
						@HTML as Mensaje        -- Mensaje - text

				--TABLA PARA EL ENVIO DE LA PUSH NOTIFICATION
				SELECT 
					@IDUSUARIOADINCO,
					'Nueva Aprobaci�n' AS TITULO,
					'Orden de Compra Directa #' + CAST(@IDPEDIDO AS NVARCHAR) AS SUBTITULO,
					'Estimado(a) ' + @NOMBREUSUARIO + 'te informamos que tiene pendiente la aprobaci�n de la compra directa #'+ CAST(@IDPEDIDO AS NVARCHAR) AS MENSAJE,
					GETDATE();
				END

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
