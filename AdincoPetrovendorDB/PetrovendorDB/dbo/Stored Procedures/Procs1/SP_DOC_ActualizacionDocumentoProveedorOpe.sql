USE [Petrovendor]
GO
IF OBJECT_ID('Petrovendor..SP_DOC_ActualizacionDocumentoProveedorOpe') IS NOT NULL
BEGIN
DROP PROCEDURE SP_DOC_ActualizacionDocumentoProveedorOpe;
END
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <25/07/2020>
-- Description:	<Actualizacion y creacion de aprobacion de documentos solicitados al proveedor>
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 03/06/2022
-- Description:	Se obtiene correo de notificaciones directamente desde la tabla TA_CorreoServidor
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 08/07/2025
-- Description:	se retorna las notificaciones para enviarlas por medio del sdk
-- =============================================
CREATE PROCEDURE [dbo].[SP_DOC_ActualizacionDocumentoProveedorOpe]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdTipoDocumento INT,
	@IdUsuario INT,
	@Carpeta NVARCHAR(1000),
	@Identificador NVARCHAR(MAX),
	@Mime NVARCHAR(1000),
	@Extension NVARCHAR(1000),
	@NombreDocumento NVARCHAR(1000),
	@Size FLOAT,
	@IdAceptacionDocumento INT,
	@IdOperacion INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @APROBADORES TABLE(
		ID INT IDENTITY(1,1),
		IdAprobador INT,
		Nombre NVARCHAR(1000),
		Correo NVARCHAR(1000),
		Mensaje NVARCHAR(MAX)
	);

	DECLARE @IDDOCUMENTOS3 INT;
	--DECLARE @IDACEPTACIONDOCUMENTO INT;
	DECLARE @CorreoNotificaciones NVARCHAR(MAX);
	DECLARE @HTMLCORREO NVARCHAR(MAX);
	DECLARE @CONTOTAL INT;
	DECLARE @CONT INT = 1;
	DECLARE @NOMBREAPROBADOR NVARCHAR(1000);
	DECLARE @CORREOAPROBADOR NVARCHAR(1000);
	DECLARE @IDNOTIFICACION INT;
	DECLARE @NOMBREUSUARIODOCUMENTO NVARCHAR(100) = (SELECT Nombre FROM dbo.S_Usuario WHERE IdUsuario = @IdUsuario);
	DECLARE @NOMBRETIPODOCUMENTO NVARCHAR(1000) = (SELECT NombreDocumentoObligatorio FROM dbo.S_DocumentoPlantillaOperadora WHERE IdDocumentoPlantilla = @IdTipoDocumento);
	DECLARE @NOMBREPROVEEDOR NVARCHAR(1000) = (SELECT RazonSocial FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor);
	DECLARE @IDOPERADORA INT = (SELECT TOP 1 IdProveedor FROM dbo.S_DocumentoPlantillaOperadora WHERE IdDocumentoPlantilla = @IdTipoDocumento);
	DECLARE @IDFLUJOAPROBACION INT = (SELECT TOP 1 IdFlujoTarea FROM dbo.TA_FlujoTarea WHERE IdTipoOperacion = 18 AND Activo = 1 AND Predeterminado = 1 AND IdProveedor = @IDOPERADORA);
	DECLARE @NOTIFICACION BIT = (SELECT TOP 1 SoloNotificar FROM dbo.TA_FlujoTarea WHERE IdTipoFlujo = 18 AND Activo = 1 AND Predeterminado = 1 AND IdProveedor = @IDOPERADORA);
	DECLARE @TIPOFLUJO INT = (SELECT TOP 1 IdTipoFlujo FROM dbo.TA_FlujoTarea WHERE IdTipoOperacion = 18 AND Activo = 1 AND Predeterminado = 1 AND IdProveedor = @IDOPERADORA);
    --DECLARE @IDOPERACION INT = (SELECT IdOperacion FROM dbo.TA_Operacion WHERE IdDocumento = @IdAceptacionDocumento AND IdTipoOperacion = 18 AND IdProveedor = @IDOPERADORA);
	-- Insert statements for procedure here

	INSERT INTO dbo.S_Documento_S3
	(
	    IdTipoDocumento,
	    IdUsuario,
	    IdTipoValidacionDocumento,
	    IdProveedor,
	    Activo,
	    Documento,
	    CreadoPor,
	    CreadoEl,
	    ModificadoPor,
	    ModificadoEl,
	    Descripcion,
	    Carpeta,
	    Identificador,
	    Mime,
	    Extension,
	    NombreDocumento,
	    Duplicado,
	    SizeDocumento,
	    IdDocumentoTabla
	)
	VALUES
	(   
		52,         -- IdTipoDocumento - int
	    @IdUsuario,         -- IdUsuario - int
	    1,         -- IdTipoValidacionDocumento - int
	    @IdProveedor,         -- IdProveedor - int
	    1,      -- Activo - bit
	    NULL,       -- Documento - nvarchar(max)
	    @IdUsuario,         -- CreadoPor - int
	    GETDATE(), -- CreadoEl - datetime
	    NULL,         -- ModificadoPor - int
	    NULL, -- ModificadoEl - datetime
	    NULL,       -- Descripcion - nvarchar(max)
	    @Carpeta,       -- Carpeta - nvarchar(max)
	    @Identificador,       -- Identificador - nvarchar(max)
	    @Mime,       -- Mime - nvarchar(max)
	    @Extension,       -- Extension - nvarchar(max)
	    @NombreDocumento,       -- NombreDocumento - nvarchar(max)
	    NULL,       -- Duplicado - nvarchar(40)
	    @Size,       -- SizeDocumento - float
	    NULL          -- IdDocumentoTabla - int
	);

	SET @IDDOCUMENTOS3 = (SCOPE_IDENTITY());

	UPDATE dbo.MM_AceptacionDocumento_Proveedor
	SET IdDocumentoS3Proveedor = @IDDOCUMENTOS3,
		IdEstatus = 1
	WHERE IdAceptacionDocumento = @IdAceptacionDocumento;
	
	--SET @IDOPERACION = (SELECT	
	--						IdOperacion
	--					FROM dbo.TA_Operacion
	--					WHERE IdDocumento = @IdAceptacionDocumento
	--						AND IdOperacion = 18
	--						AND IdProveedor = @IDOPERADORA);

	UPDATE dbo.TA_Operacion
	SET IdFlujoTarea = @IDFLUJOAPROBACION,
		IdEstatusOperacion = 1,
		IdEstadoFlujo = 2
	WHERE IdOperacion = @IdOperacion;

	INSERT INTO dbo.TA_HistorialFlujoTarea
	(
		Descripcion,
		IdOperacion,
		Fecha,
		IdEstadoFlujo
	)
	VALUES
	(   
		'El Usuario ' + @NOMBREPROVEEDOR + '(' + @NOMBREUSUARIODOCUMENTO + ') ha reenviado la operación de Revisión de Documentos Obligatorios.',       -- Descripcion - nvarchar(max)
		@IdOperacion,         -- IdOperacion - int
		GETDATE(), -- Fecha - datetime
		1          -- IdEstadoFlujo - int
	);

	IF ISNULL(@NOTIFICACION,0) = 1
		BEGIN
			
			UPDATE dbo.TA_Operacion
			SET IdFlujoTarea = @IDFLUJOAPROBACION,
				IdEstatusOperacion = 13,
				IdEstadoFlujo = 12
			WHERE IdOperacion = @IdOperacion;
		    
			INSERT INTO dbo.TA_Tarea
			(
			    NombreTarea,
			    IdAprobador,
			    IdEstatus,
			    Visto,
			    Comentario,
			    Descripcion,
			    FechaRegistro,
			    FechaCambioEstatus,
			    IdPrioridad,
			    Activo,
			    IdVencimiento,
			    NoSecuencia,
			    IdOperacion,
			    IdFirma,
			    IdEstatusEliminado,
			    IdEliminado,
			    ModificadoPor,
			    ModificadoEl,
			    EliminadoPor,
			    AsignadoPor,
			    EliminadoEl,
			    MensajeAsignacion,
			    FechaActivacionSerial,
			    UpdateByApp
			)
			SELECT 
				'Revisión de Documentos Obligatorios',
				IdUsuario,
				13,
				NULL,
				NULL,
				NULL,
				GETDATE(),
				NULL,
				NULL,
				1,
				NULL,
				NoSecuencia,
				@IdOperacion,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL
			FROM dbo.TA_Aprobador
			WHERE IdFlujoTarea = @IDFLUJOAPROBACION
			ORDER BY NoSecuencia ASC;

			--ENVIO DE CORREOS

			INSERT INTO @APROBADORES
			(
			    IdAprobador,
			    Nombre,
			    Correo
			)
			SELECT
				TA.IdAprobador,
				US.Nombre,
				US.Correo
			FROM dbo.TA_Aprobador AS TA
			LEFT JOIN dbo.S_Usuario AS US 
				ON TA.IdUsuario = US.IdUsuario
			WHERE TA.IdFlujoTarea = @IDFLUJOAPROBACION
			ORDER BY TA.NoSecuencia ASC;

			SET @CONTOTAL = (SELECT COUNT(ID) FROM @APROBADORES);

			SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C
									INNER JOIN TA_CorreoServidor AS S
										ON C.IdServidor = S.IdServidor
								WHERE IdCorreo = 102) --> CTE NUMERO CORREO (TA_Correo)

			WHILE @CONT <= @CONTOTAL
			BEGIN
			    
				SET @NOMBREAPROBADOR = (SELECT Nombre FROM @APROBADORES WHERE ID = @CONT);
				SET @CORREOAPROBADOR = (SELECT Correo FROM @APROBADORES WHERE ID = @CONT)

				SET @HTMLCORREO = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 102);
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_USUARIO##',@NOMBREAPROBADOR));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##TIPO_DOCUMENTO##',@NOMBRETIPODOCUMENTO));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_PROVEEDOR##',@NOMBREPROVEEDOR));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##ANIO_ACTUAL##',YEAR(GETDATE())));

				UPDATE @APROBADORES
				SET Mensaje = @HTMLCORREO
				WHERE ID = @CONT;

				SET @CONT = @CONT + 1;

			END

		END
		ELSE
		--FLUJO QUE REQUIERE APROBACION
		BEGIN

			UPDATE dbo.TA_Tarea
			SET Activo = 0
			WHERE IdOperacion = @IdOperacion;
		    
			INSERT INTO dbo.TA_Tarea
			(
			    NombreTarea,
			    IdAprobador,
			    IdEstatus,
			    Visto,
			    Comentario,
			    Descripcion,
			    FechaRegistro,
			    FechaCambioEstatus,
			    IdPrioridad,
			    Activo,
			    IdVencimiento,
			    NoSecuencia,
			    IdOperacion,
			    IdFirma,
			    IdEstatusEliminado,
			    IdEliminado,
			    ModificadoPor,
			    ModificadoEl,
			    EliminadoPor,
			    AsignadoPor,
			    EliminadoEl,
			    MensajeAsignacion,
			    FechaActivacionSerial,
			    UpdateByApp
			)
			SELECT 
				'Revisión de Documentos Obligatorios',
				IdUsuario,
				1,
				NULL,
				NULL,
				NULL,
				GETDATE(),
				NULL,
				NULL,
				1,
				NULL,
				NoSecuencia,
				@IdOperacion,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL
			FROM dbo.TA_Aprobador
			WHERE IdFlujoTarea = @IDFLUJOAPROBACION
			ORDER BY NoSecuencia ASC;


			SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C
									INNER JOIN TA_CorreoServidor AS S
										ON C.IdServidor = S.IdServidor
								WHERE IdCorreo = 100) --> CTE NUMERO CORREO (TA_Correo)

			IF @TIPOFLUJO = 1 --FLUJO SERIAL SE NOTIFICARA SOLO AL PRIMER APROBADOR
			BEGIN
			    --SE OBTIENE LOS APROBADORES
				INSERT INTO @APROBADORES
				(
					IdAprobador,
					Nombre,
					Correo
				)
				SELECT
					TA.IdAprobador,
					US.Nombre,
					US.Correo
				FROM dbo.TA_Aprobador AS TA
				LEFT JOIN dbo.S_Usuario AS US 
					ON TA.IdUsuario = US.IdUsuario
				WHERE TA.IdFlujoTarea = @IDFLUJOAPROBACION
				ORDER BY TA.NoSecuencia ASC;

				--SE NOTIFICA AL PRIMER APROBADOR
				SET @NOMBREAPROBADOR = (SELECT Nombre FROM @APROBADORES WHERE ID = 1);
				SET @CORREOAPROBADOR = (SELECT Correo FROM @APROBADORES WHERE ID = 1)

				SET @HTMLCORREO = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 100);
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_USUARIO##',@NOMBREAPROBADOR));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##TIPO_DOCUMENTO##',@NOMBRETIPODOCUMENTO));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_PROVEEDOR##',@NOMBREPROVEEDOR));
				SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##ANIO_ACTUAL##',YEAR(GETDATE())));

				UPDATE @APROBADORES
				SET Mensaje = @HTMLCORREO
				WHERE ID = 1;

				DELETE @APROBADORES WHERE ID > 1

				END

				IF @TIPOFLUJO = 2 --FLUJO PARALELO SE NOTIFICA A TODOS LOS APROBADORES
				BEGIN
			    
					--SE OBTIENEN LOS APROBADORES
					INSERT INTO @APROBADORES
					(
						IdAprobador,
						Nombre,
						Correo
					)
					SELECT
						TA.IdAprobador,
						US.Nombre,
						US.Correo
					FROM dbo.TA_Aprobador AS TA
					LEFT JOIN dbo.S_Usuario AS US 
						ON TA.IdUsuario = US.IdUsuario
					WHERE TA.IdFlujoTarea = @IDFLUJOAPROBACION
					ORDER BY TA.NoSecuencia ASC;

					SET @CONTOTAL = (SELECT COUNT(ID) FROM @APROBADORES);					

					WHILE @CONT <= @CONTOTAL
					BEGIN
			    
						SET @NOMBREAPROBADOR = (SELECT Nombre FROM @APROBADORES WHERE ID = @CONT);
						SET @CORREOAPROBADOR = (SELECT Correo FROM @APROBADORES WHERE ID = @CONT)

						SET @HTMLCORREO = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 100);
						SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_USUARIO##',@NOMBREAPROBADOR));
						SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##TIPO_DOCUMENTO##',@NOMBRETIPODOCUMENTO));
						SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_PROVEEDOR##',@NOMBREPROVEEDOR));
						SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##ANIO_ACTUAL##',YEAR(GETDATE())));

						UPDATE @APROBADORES
						SET Mensaje = @HTMLCORREO
						WHERE ID = @CONT;


						SET @CONT = @CONT + 1;

					END

				END

		END

		SELECT 
			@IDOPERACION AS IDOPERACION,
			ID,
			IdAprobador,
			Nombre,
			Correo, 
			Mensaje,
			'Documento Solicitado al Proveedor' AS Asunto
		FROM @APROBADORES;

END
