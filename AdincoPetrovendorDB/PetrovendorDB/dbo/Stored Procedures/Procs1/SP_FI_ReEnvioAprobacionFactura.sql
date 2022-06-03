USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_ReEnvioAprobacionFactura'
)
    DROP PROCEDURE SP_FI_ReEnvioAprobacionFactura;
GO
/****** Object:  StoredProcedure [dbo].[SP_FI_ReEnvioAprobacionFactura]    Script Date: 03/06/2022 11:14:26 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[SP_FI_ReEnvioAprobacionFactura]    Script Date: 29/09/2020 13:23:44 ******/
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <28/09/2020>
-- Description:	<Envio de factura, creacion de la operacion y tareas de aprobacion y envio de correos>
-- =============================================
-- Author:		<Luis David>
-- Create date: <06/04/2022>
-- Description:	<Validación de usuario en tabla TA_NoNotificacion para ver si está bloqueado>
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 03/06/2022
-- Description:	Se obtiene correo de notificaciones directamente desde la tabla TA_CorreoServidor
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ReEnvioAprobacionFactura]
	-- Add the parameters for the stored procedure here
	@IdUsuario INT,
	@IdProveedor INT,
	@IdAceptacionPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CorreoNotificaciones NVARCHAR(MAX);
	DECLARE @DESCRIPCION_HISTORIAL NVARCHAR(MAX);
	DECLARE @ID_ESTATUS_FLUJO INT;
	DECLARE @ID_ESTATUS_OPERACION INT;
	DECLARE @ID_OPERACION INT;
	DECLARE @ID_FLUJO_APROBACION INT;
	DECLARE @NOMBRE_APROBADOR NVARCHAR(200);
	DECLARE @CORREO_APROBADOR NVARCHAR(200);
	DECLARE @IDUSUARIOAPROBADOR INT;
	DECLARE @CONT INT;
	DECLARE @IDNOTIFICACION INT;
	DECLARE @CONTTOTAL INT;
	DECLARE @ID_TIPO_FLUJO INT;
	DECLARE @PLANTILLA_CORREO NVARCHAR(MAX);
	DECLARE @PLANTILLA_ASUNTO NVARCHAR(MAX);
	DECLARE @NOMBRE_CONTRATO NVARCHAR(MAX) = (SELECT TOP 1 C.NumeroContrato + ' - ' + AC.NombreAreaContractual AS NombreContrato
													FROM dbo.MM_AceptacionPedido AP
													LEFT JOIN dbo.MM_Pedido P ON P.IdPedido = AP.IdPedido
													LEFT JOIN Adinco.dbo.CO_Contrato C ON C.IdContrato = P.IdContrato
													LEFT JOIN Adinco.dbo.CO_AreaContractual AC ON AC.IdAreaContractual = C.IdAreaContractual
													WHERE AP.IdAceptacionPedido = @IdAceptacionPedido);
	DECLARE @IDPROVEEDOROPERADORA INT = (SELECT TOP 1 AP.IdProveedor
													FROM dbo.MM_AceptacionPedido AP
													LEFT JOIN dbo.MM_Pedido P ON P.IdPedido = AP.IdPedido
													LEFT JOIN Adinco.dbo.CO_Contrato C ON C.IdContrato = P.IdContrato
													LEFT JOIN Adinco.dbo.CO_AreaContractual AC ON AC.IdAreaContractual = C.IdAreaContractual
													WHERE AP.IdAceptacionPedido = @IdAceptacionPedido)
	DECLARE @TABLE_APROBADORES TABLE(ID INT IDENTITY(1,1), IdAprobador INT, IdSecuencia INT, Nombre NVARCHAR(200), Correo NVARCHAR(200));
	DECLARE @ID_OPERADORA INT = ( SELECT IdProveedor FROM dbo.MM_AceptacionPedido WHERE IdAceptacionPedido = @IdAceptacionPedido);
	DECLARE @ID_ACEPTACION_FACTURA int = (SELECT IdAceptacionFactura 
										  FROM MM_AceptacionFactura 
										WHERE IdAceptacionPedido = @IdAceptacionPedido);
	
	--SE VALIDA LA INEXISTENCIA DE LA OPERACION PARA ESTA FACTURA
	SET @ID_OPERACION = (SELECT TOP 1 
								IdOperacion
							FROM dbo.TA_Operacion 
							WHERE IdDocumento = @ID_ACEPTACION_FACTURA 
								AND IdTipoOperacion = 10
								AND IdProveedor = @IdProveedor);

	--SE ACTUALIZA EL ESTATUS DE LA APROBACION DE FACTURA(EN APROBACION)
	UPDATE MM_AceptacionFactura 
	SET [IdEstatusXML] = 1,
	[IdEstatusPDF] = 1,
	[ModificadoPor]  = @IdUsuario,
	[ModificadoEl] = getdate()
	WHERE IdAceptacionFactura = @ID_ACEPTACION_FACTURA;

	SET @DESCRIPCION_HISTORIAL ='Se reinicio Aprobación de Factura';
	 
	INSERT INTO TA_HistorialFlujoTarea
	(
		Descripcion, 
		IdOperacion, 
		Fecha,
		IdEstadoFlujo
	)
	VALUES
	(	
		@DESCRIPCION_HISTORIAL,
		@ID_OPERACION, 
		GETDATE(),
		6
	);

	UPDATE TA_Operacion 
	SET IdEstatusOperacion = 1,
		IdEstadoFlujo = 1,
	FechaModificacion = NULL,
	Descripcion= NULL
	WHERE IdOperacion = @ID_OPERACION;

	UPDATE TA_Tarea 
	SET IdEstatus = 1,
		Comentario = NULL,
		FechaCambioEstatus = NULL
	WHERE IdOperacion = @ID_OPERACION
	AND Activo=1


	IF ISNULL(@ID_OPERACION,0) <> 0
	BEGIN
		
		--CONSULTA DE LOS APROBADORES DE LAS TAREAS
		--SE CONSULTAN LOS APROBADORES PARA ESA FACTURA
		INSERT INTO @TABLE_APROBADORES
		(
		    IdAprobador,
		    IdSecuencia,
		    Nombre,
		    Correo
		)
		SELECT
			US.IdUsuario,
			APR.NoSecuencia,
			US.Nombre,
			US.Correo
		FROM dbo.TA_Tarea AS APR
			JOIN dbo.S_Usuario AS US 
				ON US.IdUsuario = APR.IdAprobador
				AND US.Activo = 1
		WHERE APR.IdOperacion = @ID_OPERACION
			AND APR.Activo = 1
		GROUP BY US.IdUsuario,
                 APR.NoSecuencia,
                 US.Nombre,
                 US.Correo
		ORDER BY APR.NoSecuencia ASC;

		SET @ID_FLUJO_APROBACION = (SELECT IdFlujoTarea FROM dbo.TA_Operacion WHERE IdOperacion = @ID_OPERACION);

		SET @ID_TIPO_FLUJO = (SELECT IdTipoFlujo FROM dbo.TA_FlujoTarea WHERE IdFlujoTarea = @ID_FLUJO_APROBACION);

		--ENVIO DE LOS CORREOS DE APROBACION
		IF @ID_TIPO_FLUJO = 1--FLUJO SERIAL
		BEGIN
		    
			SET @CONT = 1;
			SET @CONTTOTAL = 1;-- SOLO SE LE ENVIARA AL PRIMERO

		END

		IF @ID_TIPO_FLUJO = 2--FLUJO PARALELO
		BEGIN
		    
			SET @CONT = 1;
			SET @CONTTOTAL = (SELECT COUNT(1) FROM @TABLE_APROBADORES);--SE ENVIA A TODOS

		END
		
		
		SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
									FROM TA_Correo AS C
										INNER JOIN TA_CorreoServidor AS S
											ON S.IdServidor = C.IdServidor
									WHERE IdCorreo = 37) --> CTE NUMERO CORREO (TA_Correo)

		WHILE @CONT <= @CONTTOTAL
		BEGIN
			SET @NOMBRE_APROBADOR = (SELECT Nombre FROM @TABLE_APROBADORES WHERE ID = @CONT);
			SET @CORREO_APROBADOR = (SELECT Correo FROM @TABLE_APROBADORES WHERE ID = @CONT);
			SET @IDUSUARIOAPROBADOR = (SELECT IdAprobador FROM @TABLE_APROBADORES WHERE ID = @CONT)
		    SET @PLANTILLA_CORREO = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 37);
			SET @PLANTILLA_ASUNTO = (SELECT Asunto FROM dbo.TA_Correo WHERE IdCorreo = 37);

			SET @PLANTILLA_ASUNTO = REPLACE(@PLANTILLA_ASUNTO,'##NUMERO_OPERACION##', CAST(@IdAceptacionPedido AS NVARCHAR));
			SET @PLANTILLA_CORREO = REPLACE(@PLANTILLA_CORREO,'##NUMERO_OPERACION##', CAST(@IdAceptacionPedido AS NVARCHAR));
			SET @PLANTILLA_CORREO = REPLACE(@PLANTILLA_CORREO,'##NOMBRE_USUARIO##', ISNULL(@NOMBRE_APROBADOR,''));
			SET @PLANTILLA_CORREO = REPLACE(@PLANTILLA_CORREO,'#CONTRATO#', ISNULL(@NOMBRE_CONTRATO,''));
			SET @PLANTILLA_CORREO = REPLACE(@PLANTILLA_CORREO,'##ANIO_ACTUAL##', YEAR(GETDATE()));
			SET @PLANTILLA_CORREO = REPLACE(@PLANTILLA_CORREO,'##TIPO_OPERACION##', 'Aprobación de Factura');
			SET @PLANTILLA_CORREO = REPLACE(@PLANTILLA_CORREO,'##URL_TAREA##', 'https://procura.adinco.mx/02Proveedores/RecepcionVentanillaDetalle.aspx?aceptacion=' + CAST(@IdAceptacionPedido AS NVARCHAR));

			SET @IDNOTIFICACION = ((SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion) + 1);

			IF NOT EXISTS (SELECT * FROM dbo.TA_NoNotificacion WHERE		IDPROVEEDOR = @IDPROVEEDOROPERADORA AND
																			IdUsuario = @IDUSUARIOAPROBADOR
																			AND IdCorreo = 37
																			AND IsEliminado = 0)
			BEGIN
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
				@CORREO_APROBADOR,        -- Para - varchar(1000)
				@PLANTILLA_ASUNTO,        -- Asunto - varchar(500)
				@PLANTILLA_CORREO,        -- Mensaje - text
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
			(   @IdNotificacion, -- IdEnvioAdinco - int
					37, -- CORREO DE PETICION OFERTA
					CONCAT(@ID_OPERACION,' - Aprobación Factura de Aceptación Pedido #' , @IdAceptacionPedido),  -- IdIdentificacion - int
					@IdUsuario,
					GETDATE()
			);

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
			(   @IdAceptacionPedido,         -- IdDocumento - int
				@PLANTILLA_ASUNTO,       -- Detalle - nvarchar(max)
				@CORREO_APROBADOR,       -- Correo - nvarchar(350)
				1,      -- Enviado - bit
				GETDATE(), -- FechaEnvio - datetime
				0,         -- IdUsuarioEnvio - int
				0,         -- IdProveedorEnvio - int
				0          -- IdUsuarioReceptor - int
			);	
			END

			SET @CONT = @CONT + 1;

		END

	END;
	
	SELECT
		OP.IdOperacion,
		OP.IdEstatusOperacion
	FROM dbo.TA_Operacion AS OP
	WHERE OP.IdOperacion = @ID_OPERACION;
	
	 
END