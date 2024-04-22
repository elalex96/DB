USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_DOC_CambiarEstatusAceptacionDocumento'
)
    DROP PROCEDURE SP_DOC_CambiarEstatusAceptacionDocumento;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <27/07/2020>
-- Description:	<Cambiar de estatus la revision del documento>
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 03/06/2022
-- Description:	Se obtiene correo de notificaciones directamente desde la tabla TA_CorreoServidor
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 17/04/2024
-- Description:	se corrige el envio de notificacion al aprobador
-- =============================================
CREATE PROCEDURE [dbo].[SP_DOC_CambiarEstatusAceptacionDocumento] 
	-- Add the parameters for the stored procedure here
	@IdAceptacionDocumento INT,
	@IdEstatus INT,
	@Comentario NVARCHAR(MAX),
	@IdProveedor INT,
	@IdUsuario INT,
	@IdSecuencia INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CorreoNotificaciones NVARCHAR(MAX);
	DECLARE @HTMLCORREO NVARCHAR(MAX) = (SELECT HTML FROM dbo.TA_Correo (NOLOCK) WHERE Asunto = 'Notificacion de Cambio de estatus de la revision de documento solicitados al Proveedor');
    -- Insert statements for procedure here
	DECLARE @IDNOTIFICACION INT;
	DECLARE @NOMBREAPROBADOR NVARCHAR(100) = (SELECT Nombre FROM dbo.S_Usuario (NOLOCK) WHERE IdUsuario = @IdUsuario);
	DECLARE @CORREOAPROBADOR NVARCHAR(100);
	DECLARE @NOMBRETIPODOCUMENTO NVARCHAR(MAX) = (SELECT 
													DPO.NombreDocumentoObligatorio
												FROM dbo.S_DocumentoPlantillaOperadora AS DPO (NOLOCK)
													LEFT JOIN dbo.MM_AceptacionDocumento_Proveedor AS ADP (NOLOCK)
														ON DPO.IdDocumentoPlantilla = ADP.IdTipoDocumentoOperadora
												WHERE ADP.IdAceptacionDocumento = @IdAceptacionDocumento);

	DECLARE @NOMBREPROVEEDOR NVARCHAR(MAX) = (SELECT 
													PR.RazonSocial
												FROM dbo.S_Proveedor AS PR (NOLOCK)
													LEFT JOIN dbo.MM_AceptacionDocumento_Proveedor AS ADP (NOLOCK)
														ON PR.IdProveedor = ADP.IdProveedor
												WHERE ADP.IdAceptacionDocumento = @IdAceptacionDocumento);

	DECLARE @NOMBREOPERADORA NVARCHAR(MAX) = (SELECT 
													PR.RazonSocial
												FROM dbo.S_Proveedor AS PR (NOLOCK)
													LEFT JOIN dbo.MM_AceptacionDocumento_Proveedor AS ADP (NOLOCK)
														ON PR.IdProveedor = ADP.IdOperadora
												WHERE ADP.IdAceptacionDocumento = @IdAceptacionDocumento);
	--SE OBTIENE LA OPERACION
	DECLARE @IDOPERACION INT = (SELECT
									IdOperacion
								FROM dbo.TA_Operacion (NOLOCK)
								WHERE IdDocumento = @IdAceptacionDocumento 
									AND IdTipoOperacion = 18
									AND IdProveedor = @IdProveedor);

	DECLARE @SIGUIENTETAREA INT = (SELECT 
										IdTarea
									FROM dbo.TA_Tarea (NOLOCK)
									WHERE IdOperacion = @IDOPERACION
									AND NoSecuencia = (@IdSecuencia + 1)
									AND Activo = 1);

	--SE CAMBIA DE ESTATUS LA TAREA
	UPDATE dbo.TA_Tarea
	SET IdEstatus = @IdEstatus,
		Comentario = @Comentario,
		FechaCambioEstatus = GETDATE()
	WHERE IdAprobador = @IdUsuario
		AND NoSecuencia = @IdSecuencia
		AND IdOperacion = @IDOPERACION
		AND Activo = 1;

	--SE OBTIENE EL TOTAL DE APROBADORES EN LA TAREA
	DECLARE @TOTALAPROBADORES INT = (SELECT
										COUNT(IdTarea)
									FROM dbo.TA_Tarea (NOLOCK)
									WHERE IdOperacion = @IDOPERACION
										AND Activo = 1);

	--SE OBTIENE EL TOTAL DE APROBADOS
	DECLARE @TOTALAPROBADOS INT = (SELECT
										COUNT(IdTarea)
									FROM dbo.TA_Tarea (NOLOCK)
									WHERE IdOperacion = @IDOPERACION
									AND IdEstatus = 2
									AND Activo = 1);

	--SE OBTIENE EL TOTAL DE RECHAZADOS
	DECLARE @TOTALRECHAZADOS INT = (SELECT
										COUNT(IdTarea)
									FROM dbo.TA_Tarea (NOLOCK)
									WHERE IdOperacion = @IDOPERACION
									AND IdEstatus = 3
									AND Activo = 1);
	
	--SE OBTIENE EL TOTAL EN APROBACION
	DECLARE @TOTALENAPROBACION INT = (SELECT
										COUNT(IdTarea)
									FROM dbo.TA_Tarea (NOLOCK)
									WHERE IdOperacion = @IDOPERACION
									AND IdEstatus = 1
									AND Activo = 1);

	--SE INCERTA EL HISTORIAL DE APROBACION
	IF @IdEstatus = 2
	BEGIN
	    
		INSERT INTO dbo.TA_HistorialFlujoTarea
		(
			Descripcion,
			IdOperacion,
			Fecha,
			IdEstadoFlujo
		)
		VALUES
		(   'El Usuario ' + @NOMBREAPROBADOR + ' ha Aprobado la Tarea',       -- Descripcion - nvarchar(max)
			@IDOPERACION,         -- IdOperacion - int
			GETDATE(), -- Fecha - datetime
			3          -- IdEstadoFlujo - int
			);

		IF ISNULL(@SIGUIENTETAREA,0) <> 0
		BEGIN
		    
				--SE NOTIFICA AL PRIMER APROBADOR
				SET @NOMBREAPROBADOR = (SELECT
											US.Nombre
										FROM dbo.S_Usuario AS US (NOLOCK)
											LEFT JOIN dbo.TA_Tarea AS T (NOLOCK)
												ON US.IdUsuario = T.IdAprobador
										WHERE T.IdTarea = @SIGUIENTETAREA
										GROUP BY US.Nombre);

				SET @CORREOAPROBADOR = (SELECT
											US.Correo
										FROM dbo.S_Usuario AS US (NOLOCK)
											LEFT JOIN dbo.TA_Tarea AS T (NOLOCK)
												ON US.IdUsuario = T.IdAprobador
										WHERE T.IdTarea = @SIGUIENTETAREA
										GROUP BY US.Correo)

				SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C (NOLOCK)
									INNER JOIN TA_CorreoServidor AS S (NOLOCK)
										ON C.IdServidor = S.IdServidor
								WHERE IdCorreo = 102) --> CTE NUMERO CORREO (TA_Correo)

				SET @HTMLCORREO = (SELECT HTML FROM dbo.TA_Correo (NOLOCK) WHERE IdCorreo = 102);
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_USUARIO##',@NOMBREAPROBADOR));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##TIPO_DOCUMENTO##',@NOMBRETIPODOCUMENTO));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_PROVEEDOR##',@NOMBREPROVEEDOR));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##ANIO_ACTUAL##',YEAR(GETDATE())));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##URL_PEDIDO##','https://procura.adinco.mx/04Tareas/ListaAprobacionesDocs.aspx'));

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
					@CORREOAPROBADOR,        -- Para - varchar(1000)
					'Documento Solicitado al Proveedor',        -- Asunto - varchar(500)
					@HTMLCORREO,        -- Mensaje - text
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
						102, -- CORREO DE PETICION OFERTA
						CONCAT('0 - Notificacion Revision Documentos por Operadora #' , @IDACEPTACIONDOCUMENTO),  -- IdIdentificacion - int
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
					(   @IDACEPTACIONDOCUMENTO,         -- IdDocumento - int
						N'Notificacion Revision Documentos Solicitado al Proveedor',       -- Detalle - nvarchar(max)
						@CORREOAPROBADOR,       -- Correo - nvarchar(350)
						1,      -- Enviado - bit
						GETDATE(), -- FechaEnvio - datetime
						0,         -- IdUsuarioEnvio - int
						0,         -- IdProveedorEnvio - int
						0          -- IdUsuarioReceptor - int
					);

		END

	END;

	IF @IdEstatus = 3
	BEGIN
	    
		INSERT INTO dbo.TA_HistorialFlujoTarea
		(
			Descripcion,
			IdOperacion,
			Fecha,
			IdEstadoFlujo
		)
		VALUES
		(   'El Usuario ' + @NOMBREAPROBADOR + ' ha Rechazado la Tarea',       -- Descripcion - nvarchar(max)
			@IDOPERACION,         -- IdOperacion - int
			GETDATE(), -- Fecha - datetime
			4          -- IdEstadoFlujo - int
			);

	END;

	--ESTADO DEL FLUJO EN APROBACION
	UPDATE dbo.TA_Operacion
	SET IdEstadoFlujo = 2
	WHERE IdOperacion = @IDOPERACION;

	--SI EL TOTAL DE APROBADORES ES IGUAL A TODOS LOS APROBADORES APROBADOS
	IF @TOTALAPROBADORES = @TOTALAPROBADOS
	BEGIN

	    --SE CAMBIA EL ESTATUS DE LA APROBACION
		UPDATE dbo.MM_AceptacionDocumento_Proveedor
		SET IdEstatus = @IdEstatus
			--Comentario = @Comentario
		WHERE IdAceptacionDocumento = @IdAceptacionDocumento;

		--SE CAMBIA EL ESTATUS DE LA TAREA
		UPDATE dbo.TA_Operacion
		SET IdEstatusOperacion = 2,
			IdEstadoFlujo = 3
		WHERE IdDocumento = @IdAceptacionDocumento 
			AND IdTipoOperacion = 18
			AND IdProveedor = @IdProveedor;

		
				--SE NOTIFICA AL PRIMER APROBADOR
				SET @NOMBREAPROBADOR = (SELECT
											US.Nombre
										FROM dbo.S_Usuario AS US (NOLOCK)
											LEFT JOIN dbo.MM_AceptacionDocumento_Proveedor AS ADP (NOLOCK)
												ON US.IdUsuario = ADP.CreadoPor
										WHERE ADP.IdAceptacionDocumento = @IdAceptacionDocumento
										GROUP BY US.Nombre);

				SET @CORREOAPROBADOR = (SELECT
											US.Correo
										FROM dbo.S_Usuario AS US (NOLOCK)
											LEFT JOIN dbo.MM_AceptacionDocumento_Proveedor AS ADP (NOLOCK)
												ON US.IdUsuario = ADP.CreadoPor
										WHERE ADP.IdAceptacionDocumento = @IdAceptacionDocumento
										GROUP BY US.Correo)

				SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C (NOLOCK)
									INNER JOIN TA_CorreoServidor AS S (NOLOCK)
										ON C.IdServidor = S.IdServidor
								WHERE IdCorreo = 101) --> CTE NUMERO CORREO (TA_Correo)

				SET @HTMLCORREO = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 101);
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_USUARIO##',@NOMBREAPROBADOR));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##TIPO_DOCUMENTO##',@NOMBRETIPODOCUMENTO));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_OPERADORA##',@NOMBREOPERADORA));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##COMENTARIO_APROBACION##',@Comentario));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##ANIO_ACTUAL##',YEAR(GETDATE())));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##ESTATUS##','Aprobado'));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##RECHAZADO##',''));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##URL_PEDIDO##','https://petrovendor.com.mx/02Proveedores/CargaDocumentos.aspx'));

				

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
					@CORREOAPROBADOR,        -- Para - varchar(1000)
					'Documento Solicitado al Proveedor',        -- Asunto - varchar(500)
					@HTMLCORREO,        -- Mensaje - text
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
						101, -- CORREO DE PETICION OFERTA
						CONCAT('0 - Notificacion Revision Documentos por Operadora #' , @IDACEPTACIONDOCUMENTO),  -- IdIdentificacion - int
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
					(   @IDACEPTACIONDOCUMENTO,         -- IdDocumento - int
						N'Notificacion Revision Documentos Solicitado al Proveedor',       -- Detalle - nvarchar(max)
						@CORREOAPROBADOR,       -- Correo - nvarchar(350)
						1,      -- Enviado - bit
						GETDATE(), -- FechaEnvio - datetime
						0,         -- IdUsuarioEnvio - int
						0,         -- IdProveedorEnvio - int
						0          -- IdUsuarioReceptor - int
					);

	INSERT INTO dbo.TA_HistorialFlujoTarea
	(
			Descripcion,
			IdOperacion,
			Fecha,
			IdEstadoFlujo
	)
	VALUES
	(   'Se ha Finalizado la aprobación de la Tarea ',       -- Descripcion - nvarchar(max)
		@IDOPERACION,         -- IdOperacion - int
		GETDATE(), -- Fecha - datetime
		7          -- IdEstadoFlujo - int
	);

		
	END
	ELSE
	BEGIN
	    
		IF @IdEstatus = 3
		BEGIN
		    
			--SE CAMBIA EL ESTATUS DE LA APROBACION
			UPDATE dbo.MM_AceptacionDocumento_Proveedor
			SET IdEstatus = @IdEstatus,
				Comentario = @Comentario
			WHERE IdAceptacionDocumento = @IdAceptacionDocumento;

			--SE CAMBIA EL ESTATUS DE LA TAREA
			UPDATE dbo.TA_Operacion
			SET IdEstatusOperacion = 3,
				IdEstadoFlujo = 4
			WHERE IdDocumento = @IdAceptacionDocumento 
				AND IdTipoOperacion = 18
				AND IdProveedor = @IdProveedor;

			--SE CAMBIO EL ESTATUS DE TODOS LOS PENDIENTES
			UPDATE dbo.TA_Tarea
			SET IdEstatus = 3,
				Activo = 0
			WHERE IdAprobador = @IdUsuario
				AND IdOperacion = @IDOPERACION;

			--SE INACTIVAN TODAS LAS TAREAS ASOCIADAS AL FLUJO
			UPDATE dbo.TA_Tarea
			SET IdEstatus = 4,
				Activo = 0
			WHERE IdAprobador <> @IdUsuario
				AND IdOperacion = @IDOPERACION
				AND IdEstatus = 1;

			SET @NOMBREAPROBADOR = (SELECT
											US.Nombre
										FROM dbo.S_Usuario AS US (NOLOCK)
											LEFT JOIN dbo.MM_AceptacionDocumento_Proveedor AS ADP (NOLOCK)
												ON US.IdUsuario = ADP.CreadoPor
										WHERE ADP.IdAceptacionDocumento = @IdAceptacionDocumento
										GROUP BY US.Nombre);

			SET @CORREOAPROBADOR = (SELECT
											US.Correo
										FROM dbo.S_Usuario AS US (NOLOCK)
											LEFT JOIN dbo.MM_AceptacionDocumento_Proveedor AS ADP (NOLOCK)
												ON US.IdUsuario = ADP.CreadoPor
										WHERE ADP.IdAceptacionDocumento = @IdAceptacionDocumento
										GROUP BY US.Correo)

				SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C (NOLOCK)
									INNER JOIN TA_CorreoServidor AS S (NOLOCK)
										ON C.IdServidor = S.IdServidor
								WHERE IdCorreo = 101) --> CTE NUMERO CORREO (TA_Correo)

				SET @HTMLCORREO = (SELECT HTML FROM dbo.TA_Correo (NOLOCK) WHERE IdCorreo = 101);
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_USUARIO##',@NOMBREAPROBADOR));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##TIPO_DOCUMENTO##',@NOMBRETIPODOCUMENTO));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_OPERADORA##',@NOMBREOPERADORA));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##COMENTARIO_APROBACION##',@Comentario));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##ANIO_ACTUAL##',YEAR(GETDATE())));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##ESTATUS##','Rechazado'));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##RECHAZADO##',''));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##URL_PEDIDO##','https://petrovendor.com.mx/02Proveedores/CargaDocumentos.aspx'));

				

				SET @IDNOTIFICACION = ((SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion (NOLOCK)) + 1);
				
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
					@CORREOAPROBADOR,        -- Para - varchar(1000)
					'Documento Solicitado al Proveedor',        -- Asunto - varchar(500)
					@HTMLCORREO,        -- Mensaje - text
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
						101, -- CORREO DE PETICION OFERTA
						CONCAT('0 - Notificacion Revision Documentos por Operadora #' , @IDACEPTACIONDOCUMENTO),  -- IdIdentificacion - int
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
					(   @IDACEPTACIONDOCUMENTO,         -- IdDocumento - int
						N'Notificacion Revision Documentos Solicitado al Proveedor',       -- Detalle - nvarchar(max)
						@CORREOAPROBADOR,       -- Correo - nvarchar(350)
						1,      -- Enviado - bit
						GETDATE(), -- FechaEnvio - datetime
						0,         -- IdUsuarioEnvio - int
						0,         -- IdProveedorEnvio - int
						0          -- IdUsuarioReceptor - int
					);

					INSERT INTO dbo.TA_HistorialFlujoTarea
					(
							Descripcion,
							IdOperacion,
							Fecha,
							IdEstadoFlujo
					)
					VALUES
					(   'Se ha Finalizado la aprobación de la Tarea ',       -- Descripcion - nvarchar(max)
						@IDOPERACION,         -- IdOperacion - int
						GETDATE(), -- Fecha - datetime
						7          -- IdEstadoFlujo - int
					);

		END;

	END;

	SELECT 'TAREA_ACTUALIZADA'


END
