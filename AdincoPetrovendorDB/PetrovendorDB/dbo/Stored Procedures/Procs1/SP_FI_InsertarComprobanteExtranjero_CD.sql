USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_InsertarComprobanteExtranjero_CD'
)
    DROP PROCEDURE SP_FI_InsertarComprobanteExtranjero_CD;
GO
/****** Object:  StoredProcedure [dbo].[SP_FI_InsertarComprobanteExtranjero_CD]    Script Date: 03/06/2022 11:26:34 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <27/08/2020>
-- Description:	<Creacion del flujo de aprobacion para los pedimentos/comprobantes >
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 03/06/2022
-- Description:	Se obtiene correo de notificaciones directamente desde la tabla TA_CorreoServidor
-- =============================================
CREATE  PROCEDURE [dbo].[SP_FI_InsertarComprobanteExtranjero_CD]
	-- Add the parameters for the stored procedure here
	@IdContrato                 INT,
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
	@IdentificadorDoc			NVARCHAR(MAX),
	@Mime						NVARCHAR(MAX),
	@Extension				    NVARCHAR(MAX),
	@NombreDocumento			NVARCHAR(MAX),
	@Archivo					IMAGE,
	@DiasCredito				INT,
	@Periodo					INT = NULL,
	@Presupuesto				INT = NULL,
	@IdLineaPresupuesto			INT = NULL,
	@Bucket						varchar(500) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @idped INT;
    DECLARE @IdSubcontratistaImportador INT;
	DECLARE @IDACEPTACIONPEDIMENTO INT;
	DECLARE @TIPOFLUJO INT;
	DECLARE @NOMBRESIGAPROBADOR NVARCHAR(100);
	DECLARE @CORREOSIGAPROBADOR NVARCHAR(100);
	DECLARE @IDNOTIFICACION INT;
	DECLARE @CORREOSIG NVARCHAR(MAX);
	DECLARE @NOMBRESUBCONTRATISTA NVARCHAR(100);
	DECLARE @CONTTOTAL INT;
	DECLARE @CONT INT;
	DECLARE @IDAPROBPARALELO INT;
	DECLARE @APROBADORESTABLE TABLE(ID INT IDENTITY(1,1),IdAprobador INT, Nombre NVARCHAR(1000), Correo NVARCHAR(MAX));
	DECLARE @DescripcionH NVARCHAR(MAX);
	DECLARE @IdFlujoTarea INT;
	DECLARE @IdOperacion INT;
	DECLARE @IDSIGAPROBADOR INT;
	DECLARE @CorreoNotificaciones NVARCHAR(MAX);    

    INSERT INTO [dbo].[FI_PedimentoComprobante]
	([IdContrato],
	 [FolioComprobante],
	 [FechaPago],
	 [IdSubcontratistaExportador],
	 [IdMoneda],
	 [CvTipoDocFacturacion],
	 [CreadoPor],
	 [CreadoEn],
	 [NumFacturaC],
	 EsnotaCredito,
	 TipoOrigen,
	 IdCentroCosto,
	 IdCuentaContable,
	 DiasCredito,
	 IdPeriodo,
	 IdPresupuesto,
	 IdLineaPresupuesto
	)
	VALUES
	(@IdContrato,
	 @FolioComprobante,
	 @FechaPago,
	 @IdSubcontratistaExportador,
	 @IdMoneda,
	 @CvTipoDoc,
	 @IdUsuario,
	 GETDATE(),
	 @NumFac,
	 @IsNotaCredito,
	 'CE_CD',
	 @IdCentroCosto,
	 @IdCuentaContable,
	 @DiasCredito,
	 @Periodo,
	 @Presupuesto,
	 @IdLineaPresupuesto
	);

	 SET @idped = SCOPE_IDENTITY();

	 INSERT INTO [dbo].[FI_PedimentoComprobanteDetalle]
	([IdPedimentoComprobante],
	 [IdUnidadMedida],
	 [ClaseBienServicio],
	 [PrecioUnitario],
	 [CreadoPor],
	 [CreadoEn]
	)
					 VALUES
	(@idped,
	 @IdUnidadMedida,
	 @ClaseBienServicio,
	 @Subtotal,
	 @IdUsuario,
	 GETDATE()
	);

	IF @Extension = '.pdf'
	BEGIN
	    
		INSERT INTO dbo.FI_Documento
		(
		    Documento,
		    IdTipoDocumento,
		    IdFactura,
		    IdPedimentoComprobante,
		    IdDocFacturacionSIPAC,
		    NombreExtensionArchivo,
		    IdUsuario,
		    FechaCarga,
		    IsEliminado,
		    DocumentoByte
		)
		VALUES
		(   NULL,       -- Documento - nvarchar(max)
		    4,         -- IdTipoDocumento - int
		    NULL,         -- IdFactura - int
		    @idped,         -- IdPedimentoComprobante - int
		    NULL,       -- IdDocFacturacionSIPAC - nvarchar(50)
		    'PE_' + CAST(@idped AS NVARCHAR) + '.pdf',       -- NombreExtensionArchivo - nvarchar(150)
		    @IdUsuario,         -- IdUsuario - int
		    GETDATE(), -- FechaCarga - datetime
		    NULL,      -- IsEliminado - bit
		    @Archivo       -- DocumentoByte - image
		    )

	END

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
	    IdDocumentoTabla,
	    Bucket
	)
	VALUES
	(   53,         -- IdTipoDocumento - int Pedimento/Comprobante - Compra Directa
	    @IdUsuario,         -- IdUsuario - int
	    1003,         -- IdTipoValidacionDocumento - int
	    @IdProveedor,         -- IdProveedor - int
	    1,      -- Activo - bit
	    NULL,       -- Documento - nvarchar(max)
	    @IdUsuario,         -- CreadoPor - int
	    GETDATE(), -- CreadoEl - datetime
	    NULL,         -- ModificadoPor - int
	    NULL, -- ModificadoEl - datetime
	    NULL,       -- Descripcion - nvarchar(max)
	    'PEDIMENTO_COMPROBANTE_CD/',       -- Carpeta - nvarchar(max)
	    @IdentificadorDoc,       -- Identificador - nvarchar(max)
	    @Mime,       -- Mime - nvarchar(max)
	    @Extension,       -- Extension - nvarchar(max)
	    @NombreDocumento,       -- NombreDocumento - nvarchar(max)
	    NULL,       -- Duplicado - nvarchar(40)
	    NULL,       -- SizeDocumento - float
	    @idped,         -- IdDocumentoTabla - int
	    @Bucket        -- Bucket - nvarchar(200)
	    );

		INSERT INTO dbo.FI_AceptacionPedido_PedimentoComprobante
    (
		IdAceptacionPedido,
        IdPedimentoComprobante,
        NoVersion,
        IdPedido,
        CreadoEl,
        CreadoPor,         
        Activo,
		IdProveedor
     )
     VALUES
     (   
		NULL,         -- IdAceptacionPedido - int
        @idped,         -- IdPedimentoComprobante - int
        1,         -- NoVersion - int
        NULL,         -- IdPedido - int
        GETDATE(), -- CreadoEl - datetime
        @IdUsuario,         -- CreadoPor - int          
        1,       -- Activo - bit
		@IdProveedor
      );

	  SET @IDACEPTACIONPEDIMENTO = SCOPE_IDENTITY();


	
	--REGISTRO DE LA APROBACION DEL PEDIMENTO COMPROBANTE
  

  SET @IdFlujoTarea = (@IdFlujoAprobacion) --DONDE 19 ES PEDIMENTO/COMPROBANTE COMPRA DIRECTA

		--SE OBTIENE EL IDOPERACION SI ES QUE EXISTE CON LOS MISMOS DATOS
	INSERT INTO TA_Operacion(IdDocumento,IdTipoOperacion,IdFlujoTarea,IdEstatusOperacion,IdEstadoFlujo,IdProveedor,IdAsignador,FechaRegistro,Descripcion, IdVigencia, IdPrioridad)
	VALUES(@IDACEPTACIONPEDIMENTO,19,@IdFlujoTarea,1,1,@IdProveedor,@IdUsuario,GETDATE(), NULL,NULL,NULL)

	SET @IdOperacion = (SCOPE_IDENTITY());
			
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
			ON FT.IdFlujoTarea = APT.IdFlujoTarea
	WHERE FT.IdFlujoTarea = @IdFlujoTarea
	GROUP BY APT.IdUsuario,
             APT.NoSecuencia;


	----Agregar Evento al Historial del Flujo de Tarea----
	SET @DescripcionH = 'El Usuario ' +(SELECT Nombre FROM S_USuario WHERE IdUsuario = @IdUsuario)+ ' ha registrado la Tarea de Tipo ' + (SELECT NombreOperacion FROM TA_TipoOperacion WHERE IdTipoOperacion= 19)

	INSERT INTO TA_HistorialFlujoTarea(IdOperacion, Fecha,Descripcion, IdEstadoFlujo)
	VALUES(@IdOperacion,GETDATE(),@DescripcionH,1);

	SET @TIPOFLUJO = (SELECT TOP 1
									TFT.IdTipoFlujoTarea
								FROM dbo.TA_Operacion AS OP
									JOIN dbo.TA_FlujoTarea AS FT
										ON FT.IdFlujoTarea = OP.IdFlujoTarea
									JOIN dbo.TA_TipoFlujoTarea AS TFT
										ON TFT.IdTipoFlujoTarea = FT.IdTipoFlujo
								WHERE OP.IdOperacion = @IdOperacion);

	SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C
									INNER JOIN TA_CorreoServidor AS S
										ON S.IdServidor = C.IdServidor
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
																		ON PVS.IdSubcontratista = PC.IdSubcontratistaExportador
																WHERE PC.IdPedimentoComprobante = @idped);
			    
				SET @NOMBRESIGAPROBADOR = (SELECT Nombre FROM dbo.S_Usuario WHERE IdUsuario = @IDSIGAPROBADOR);
				SET @CORREOSIGAPROBADOR = (SELECT Correo FROM dbo.S_Usuario WHERE IdUsuario = @IDSIGAPROBADOR);
				SET @CORREOSIG = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 107);

				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_USUARIO##',@NOMBRESIGAPROBADOR));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_CLIENTE##',@NOMBRESUBCONTRATISTA));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##COMPROBANTE##',CAST(@idped AS NVARCHAR(10))));
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
					CONCAT('0 - Notificacion para Aprobacion del Pedimento/Comprobante #' , @idped),  -- IdIdentificacion - int
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
				(   @idped,         -- IdDocumento - int
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
				ON US.IdUsuario = T.IdAprobador
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
																		ON PVS.IdSubcontratista = PC.IdSubcontratistaExportador
																WHERE PC.IdPedimentoComprobante = @idped);
			    
				SET @NOMBRESIGAPROBADOR = (SELECT Nombre FROM @APROBADORESTABLE WHERE ID = @CONT);
				SET @CORREOSIGAPROBADOR = (SELECT Correo FROM @APROBADORESTABLE WHERE ID = @CONT);
				SET @CORREOSIG = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 107);

				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_USUARIO##',@NOMBRESIGAPROBADOR));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_CLIENTE##',@NOMBRESUBCONTRATISTA));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##COMPROBANTE##',CAST(@idped AS NVARCHAR(10))));
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
					CONCAT('0 - Notificacion para Aprobacion del Pedimento/Comprobante #' , @idped),  -- IdIdentificacion - int
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
				(   @idped,         -- IdDocumento - int
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


	SELECT @IdOperacion AS IdOperacion, @idped AS IdPedimentoComprobante

END