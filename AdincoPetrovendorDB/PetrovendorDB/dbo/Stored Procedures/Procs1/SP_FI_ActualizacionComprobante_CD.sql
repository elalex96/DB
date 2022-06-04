USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_ActualizacionComprobante_CD'
)
    DROP PROCEDURE SP_FI_ActualizacionComprobante_CD;
GO
/****** Object:  StoredProcedure [dbo].[SP_FI_ActualizacionComprobante_CD]    Script Date: 03/06/2022 11:42:30 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <08/10/2020>
-- Description:	<Actualizacion del comprobante extranjero>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <04/11/2020>
-- Description:	<se agregaN dias de credito a la actualizacion>
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 03/06/2022
-- Description:	Se obtiene correo de notificaciones directamente desde la tabla TA_CorreoServidor
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ActualizacionComprobante_CD]
	-- Add the parameters for the stored procedure here
	@IdComprobante INT,
	@FolioComprobante           NVARCHAR(MAX),
	@FechaPago                  DATE,
	@IdSubcontratistaExportador INT,
	@IdMoneda                   INT,
	@IdUnidadMedida             INT,
	@NumFac                     NVARCHAR(50),
	@ClaseBienServicio          NVARCHAR(MAX),
	@Subtotal                   MONEY,
	@IdUsuario                  INT,
	@CvTipoDoc                  INT,
	@IsNotaCredito				BIT,
	@IdProveedor				INT,
	@IdFlujoAprobacion			INT,
	@IdCentroCosto				INT,
	@IdCuentaContable			INT,
	@DiasCredito				INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdOperacion			INT,
			@CONTTOTAL				INT,
			@CONT					INT,
			@TIPOFLUJO				INT,
			@IDSIGAPROBADOR			INT,
			@IDAPROBPARALELO		INT,
			@DescripcionH			NVARCHAR(MAX),
			@NOMBRESUBCONTRATISTA	NVARCHAR(MAX),
			@NOMBRESIGAPROBADOR		NVARCHAR(MAX),
			@CORREOSIGAPROBADOR		NVARCHAR(MAX),
			@CORREOSIG				NVARCHAR(MAX),
			@IDNOTIFICACION			NVARCHAR(MAX);
	DECLARE @APROBADORESTABLE		TABLE(ID INT IDENTITY(1,1),IdAprobador INT, Nombre NVARCHAR(1000), Correo NVARCHAR(MAX));
	DECLARE @CorreoNotificaciones NVARCHAR(MAX);

	SET @IdOperacion = (SELECT
							OP.IdOperacion
						FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
							JOIN dbo.TA_Operacion AS OP
								ON APC.IdAceptacionPedidoPedimentoComprobante = OP.IdDocumento
								AND OP.IdTipoOperacion = 19
								AND	OP.IdProveedor = APC.IdProveedor
						WHERE APC.IdPedimentoComprobante = @IdComprobante);

    -- Insert statements for procedure here
	UPDATE dbo.FI_PedimentoComprobante
	SET FolioComprobante = @FolioComprobante,
		FechaPago = @FechaPago,
		IdSubcontratistaExportador = @IdSubcontratistaExportador,
		IdMoneda = @IdMoneda,
		CvTipoDocFacturacion = @CvTipoDoc,
		NumFacturaC = @NumFac,
		EsnotaCredito = @IsNotaCredito,
		IdCentroCosto = @IdCentroCosto,
		IdCuentaContable = @IdCuentaContable,
		ModificadoPor = @IdUsuario,
		ModificadoEn = GETDATE(),
		DiasCredito = @DiasCredito
	WHERE IdPedimentoComprobante = @IdComprobante;

	UPDATE dbo.FI_PedimentoComprobanteDetalle
	SET IdUnidadMedida = @IdUnidadMedida,
		ClaseBienServicio = @ClaseBienServicio,
		PrecioUnitario = @Subtotal,
		ModificadoPor = @IdUsuario,
		ModificadoEn = GETDATE()
	WHERE IdPedimentoComprobante = @IdComprobante;

	--ACTUALIZACION DE LA APROBACION DE LA OPERACION
		UPDATE dbo.TA_Operacion
		SET IdEstatusOperacion = 1,
			IdEstadoFlujo = 2,
			IdFlujoTarea = @IdFlujoAprobacion
		WHERE IdOperacion = @IdOperacion;

	--ELIMINADO LOGICO DE LAS TAREAS DE ESTE PEDIMENTO
		UPDATE dbo.TA_Tarea
		SET Activo = 0
		WHERE IdOperacion = @IdOperacion;

	--AGREGADO DE LAS TAREAS DE ESTE PEDIMENTO
		INSERT INTO dbo.TA_Tarea
		(
			NombreTarea,
			IdAprobador,
			IdEstatus,
			FechaRegistro,
			Activo,
			NoSecuencia,
			IdOperacion
		)
		SELECT
			'Aprobacion Pedimento/Comprobante Compra Directa',
			APT.IdUsuario,
			1,
			GETDATE(),
			1,
			APT.NoSecuencia,
			@IdOperacion
		FROM dbo.TA_Aprobador AS APT
			JOIN dbo.TA_FlujoTarea AS FT 
				ON APT.IdFlujoTarea = FT.IdFlujoTarea
		WHERE FT.IdFlujoTarea = @IdFlujoAprobacion
		GROUP BY APT.IdUsuario,
				 APT.NoSecuencia;
			
	  
	SET @DescripcionH = 'El Usuario ' +(SELECT Nombre FROM S_USuario WHERE IdUsuario = @IdUsuario)+ ' ha reenviado la Tarea de Tipo ' + (SELECT NombreOperacion FROM TA_TipoOperacion WHERE IdTipoOperacion= 19)

	INSERT INTO TA_HistorialFlujoTarea(IdOperacion, Fecha,Descripcion, IdEstadoFlujo)
	VALUES(@IdOperacion,GETDATE(),@DescripcionH,1);

	SET @TIPOFLUJO = (SELECT TOP 1
									TFT.IdTipoFlujoTarea
								FROM dbo.TA_Operacion AS OP
									JOIN dbo.TA_FlujoTarea AS FT
										ON OP.IdFlujoTarea = FT.IdFlujoTarea
									JOIN dbo.TA_TipoFlujoTarea AS TFT
										ON FT.IdTipoFlujo = TFT.IdTipoFlujoTarea
								WHERE OP.IdOperacion = @IdOperacion);

	SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C
									INNER JOIN TA_CorreoServidor AS S
										ON C.IdServidor = S.IdServidor
								WHERE IdCorreo = 107) --> CTE NUMERO CORREO (TA_Correo)

	IF @TIPOFLUJO = 1
		BEGIN

			SET @IDSIGAPROBADOR = (SELECT TOP 1
											IdAprobador
										FROM dbo.TA_Tarea
										WHERE IdOperacion = @IdOperacion
											AND Activo = 1
											AND NoSecuencia = 1);
		    
			IF @IDSIGAPROBADOR IS NOT NULL
			BEGIN
				
				SET @NOMBRESUBCONTRATISTA = (SELECT TOP 1
																	PVS.RazonSocial
																FROM dbo.FI_PedimentoComprobante AS PC
																	JOIN Adinco.dbo.PV_Subcontratista AS PVS
																		ON  PC.IdSubcontratistaExportador = PVS.IdSubcontratista
																WHERE PC.IdPedimentoComprobante = @IdComprobante);
			    
				SET @NOMBRESIGAPROBADOR = (SELECT Nombre FROM dbo.S_Usuario WHERE IdUsuario = @IDSIGAPROBADOR);
				SET @CORREOSIGAPROBADOR = (SELECT Correo FROM dbo.S_Usuario WHERE IdUsuario = @IDSIGAPROBADOR);
				SET @CORREOSIG = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 107);

				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_USUARIO##',@NOMBRESIGAPROBADOR));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_CLIENTE##',@NOMBRESUBCONTRATISTA));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##COMPROBANTE##',CAST(@IdComprobante AS NVARCHAR(10))));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##ANIO_ACTUAL##',YEAR(GETDATE())));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##URL_PEDIDO##','https://procura.adinco.mx/04Tareas/AprobacionPedimentoComprobante_CD.aspx'));

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
				    @CORREOSIGAPROBADOR,        -- Para - varchar(1000)
				    'Aprobación Pendiente de Pedimento/Comprobante Extranjero',        -- Asunto - varchar(500)
				    @CORREOSIG,        -- Mensaje - text
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
					107, -- CORREO DE PETICION OFERTA
					CONCAT('0 - Notificacion para Aprobacion del Pedimento/Comprobante #' , @IdComprobante),  -- IdIdentificacion - int
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
				(   @IdComprobante,         -- IdDocumento - int
					N'Notificacion de Aprobacion para Pedimento/Comprobante',       -- Detalle - nvarchar(max)
					@CORREOSIGAPROBADOR,       -- Correo - nvarchar(350)
					1,      -- Enviado - bit
					GETDATE(), -- FechaEnvio - datetime
					0,         -- IdUsuarioEnvio - int
					0,         -- IdProveedorEnvio - int
					0          -- IdUsuarioReceptor - int
					);

			END

		END
		

		IF @TIPOFLUJO = 2
		BEGIN
		    
			INSERT INTO @APROBADORESTABLE
			(
			    IdAprobador,
			    Nombre,
			    Correo
			)
			SELECT
				T.IdAprobador,
				US.Nombre,
				US.Correo
			FROM dbo.TA_Tarea AS T
			JOIN dbo.S_Usuario AS US
				ON T.IdAprobador = US.IdUsuario
			WHERE T.IdOperacion = @IdOperacion
			AND T.Activo = 1
			AND T.FechaCambioEstatus IS NULL;

			SET @CONTTOTAL = (SELECT COUNT(1) FROM @APROBADORESTABLE);
			SET @CONT = 1;

			WHILE @CONT <= @CONTTOTAL
			BEGIN
			    
				SET @IDAPROBPARALELO = (SELECT IdAprobador FROM @APROBADORESTABLE WHERE ID = @CONT);
				
				SET @NOMBRESUBCONTRATISTA = (SELECT TOP 1
																	PVS.RazonSocial
																FROM dbo.FI_PedimentoComprobante AS PC
																	JOIN Adinco.dbo.PV_Subcontratista AS PVS
																		ON PC.IdSubcontratistaExportador = PVS.IdSubcontratista
																WHERE PC.IdPedimentoComprobante = @IdComprobante);
			    
				SET @NOMBRESIGAPROBADOR = (SELECT Nombre FROM @APROBADORESTABLE WHERE ID = @CONT);
				SET @CORREOSIGAPROBADOR = (SELECT Correo FROM @APROBADORESTABLE WHERE ID = @CONT);
				SET @CORREOSIG = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 107);

				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_USUARIO##',@NOMBRESIGAPROBADOR));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_CLIENTE##',@NOMBRESUBCONTRATISTA));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##COMPROBANTE##',CAST(@IdComprobante AS NVARCHAR(10))));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##ANIO_ACTUAL##',YEAR(GETDATE())));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##URL_PEDIDO##','https://procura.adinco.mx/04Tareas/AprobacionPedimentoComprobante_CD.aspx'));

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
				    @CORREOSIGAPROBADOR,        -- Para - varchar(1000)
				    'Aprobación Pendiente de Pedimento/Comprobante Extranjero',        -- Asunto - varchar(500)
				    @CORREOSIG,        -- Mensaje - text
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
					107, -- CORREO DE PETICION OFERTA
					CONCAT('0 - Notificacion para Aprobacion del Pedimento/Comprobante #' , @IdComprobante),  -- IdIdentificacion - int
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
				(   @IdComprobante,         -- IdDocumento - int
					N'Notificacion de Aprobacion para Pedimento/Comprobante',       -- Detalle - nvarchar(max)
					@CORREOSIGAPROBADOR,       -- Correo - nvarchar(350)
					1,      -- Enviado - bit
					GETDATE(), -- FechaEnvio - datetime
					0,         -- IdUsuarioEnvio - int
					0,         -- IdProveedorEnvio - int
					0          -- IdUsuarioReceptor - int
					);

				SET @CONT = @CONT + 1;

			END
		END

		SELECT @IdComprobante

END
