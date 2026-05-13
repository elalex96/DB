USE [Petrovendor]
GO
IF OBJECT_ID('SP_FI_ActualizarPedimento_CD') IS NOT NULL
BEGIN
DROP PROCEDURE SP_FI_ActualizarPedimento_CD;
END
GO
/****** Object:  StoredProcedure [dbo].[SP_FI_InsertarPedimentoComprobante_CD]    Script Date: 03/11/2025 02:30:10 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		DANIEL AC
-- Create date: 12/11/2025
-- Description:	Se guardan datos para editar un pedimento y actualización de datos presupuestales
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ActualizarPedimento_CD]
	-- Add the parameters for the stored procedure here
	@IdPedimentoComprobante INT,
	@NumeroPedimento            NVARCHAR(MAX),
	@ClavePedimento             INT,
	@FolioComprobante           NVARCHAR(MAX),
	@FechaPago                  DATE,
	@Regimen                    NVARCHAR(MAX),
	@AduanaES                   NVARCHAR(MAX),
	@IdSubcontratistaExportador INT,
	@IdMoneda                   INT,
	@AcuseElectronico           NVARCHAR(MAX),
	@DescripcionMercancia       NVARCHAR(MAX),
	@SubTotal                   MONEY,
	@IdUsuario                  INT,
	@CvTipoDoc                  INT,
	@IdFiscal                   NVARCHAR(50),
	@RazonSocial                NVARCHAR(MAX),
	@ImporteInco                MONEY,
	@CuentaBancaria				NVARCHAR(500)='',
	@IdFlujoAprobacion			INT,
	@IdCuentaContable			INT,
	@IdCentroCosto				INT,
	@DiasCredito				INT,
	@Periodo					INT = NULL,
	@Presupuesto				INT = NULL,
	@IdLineaPresupuesto			INT = NULL,
	@IdContrato					INT,
	@IdProveedor			    INT,
	@IdInstalacion				INT = NULL,
	@IdCuentaSectorHidrocarburos INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	CREATE TABLE #TemporalCorreosUsuario (  
		Para VARCHAR(500),  
		Asunto VARCHAR(500),  
		Mensaje NVARCHAR(MAX),  
		De VARCHAR(200),
		CreadoPor INT,
		UsuarioAdincoId INT
	);  

	DECLARE @CorreoNotificaciones NVARCHAR(MAX);
    DECLARE @IdSubcontratistaImportador INT;
	DECLARE @TIPOFLUJO INT;
	DECLARE @NOMBRESIGAPROBADOR NVARCHAR(100);
	DECLARE @CORREOSIGAPROBADOR NVARCHAR(100);
	DECLARE @IDNOTIFICACION INT;
	DECLARE @CORREOSIG NVARCHAR(MAX);
	DECLARE @NOMBRESUBCONTRATISTA NVARCHAR(100);
	DECLARE @CONTTOTAL INT;
	DECLARE @CONT INT;
	DECLARE @IDAPROBPARALELO INT;
	DECLARE @UsuarioAdincoId INT;
	DECLARE @APROBADORESTABLE TABLE(ID INT IDENTITY(1,1),IdAprobador INT, Nombre NVARCHAR(1000), Correo NVARCHAR(MAX), UsuarioAdincoId INT);
	DECLARE @DominioProcura NVARCHAR(500) = (SELECT URL FROM TA_Dominios WHERE IdDominio = 2) --> CTE DOMINIO PROCURA
	DECLARE @DescripcionH NVARCHAR(MAX);
	DECLARE @IdFlujoTarea INT;	
	DECLARE @IdOperacion INT

	SELECT @IdSubcontratistaImportador = CC.IdProveedor
    FROM Adinco.dbo.CO_Contrato C
        JOIN Adinco.dbo.CO_Contratista CC 
		ON C.IdContratista = CC.IdContratista
    WHERE C.IdContrato = @IdContrato;

	UPDATE [dbo].[FI_PedimentoComprobante]
	SET 
	 [NumeroPedimento] =  @NumeroPedimento,
	 [ClavePedimento] = @ClavePedimento,
	 [FolioComprobante] = @FolioComprobante,
	 [FechaPago] = @FechaPago,
	 [Regimen] = @Regimen,
	 [IdSubcontratistaImportador] = @IdSubcontratistaImportador,
	 [AduanaES] = @AduanaES,
	 [IdSubcontratistaExportador] = @IdSubcontratistaExportador,
	 [IdMoneda] = @IdMoneda,
	 [AcuseElectronico] = @AcuseElectronico,
	 [CvTipoDocFacturacion] = @CvTipoDoc,	
	 [IdFiscalP] = @IdFiscal,
	 [RazonSocialP] = @RazonSocial,
	 CuentaBancaria = @CuentaBancaria,
	 TipoOrigen = 'PC_CD',
	 IsActivo = 1,
	 IdCentroCosto = @IdCentroCosto,
	 IdCuentaContable = @IdCuentaContable,
	 DiasCredito = @DiasCredito,
	 IdPeriodo = ISNULL(@Periodo,IdPeriodo),
	 IdPresupuesto = ISNULL(@Presupuesto, IdPresupuesto),
	 IdLineaPresupuesto = ISNULL(@IdLineaPresupuesto, IdLineaPresupuesto),
	 IdInstalacion = @IdInstalacion,
	 IdCuentaSectorHidrocarburos = @IdCuentaSectorHidrocarburos,
	 ModificadoPor = @IdUsuario,
	 ModificadoEn = GETDATE()
	WHERE IdPedimentoComprobante = @IdPedimentoComprobante


	 UPDATE [dbo].[FI_PedimentoComprobanteDetalle]
	 SET 
	 [DescripcionMercancia] = @DescripcionMercancia,
	 [PrecioUnitario] = @SubTotal,
	 [ModificadoPor] = @IdUsuario,
	 [ModificadoEn] = GETDATE(),
	 [ImporteTotal] = @ImporteInco
	WHERE IdPedimentoComprobante = @IdPedimentoComprobante
	

	--REGISTRO DE LA APROBACION DEL PEDIMENTO COMPROBANTE
	 SET @IdFlujoTarea = (@IdFlujoAprobacion) --DONDE 19 ES PEDIMENTO/COMPROBANTE COMPRA DIRECTA
	
	 SET @IdOperacion = (SELECT
							OP.IdOperacion
						FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
							JOIN dbo.TA_Operacion AS OP
								ON APC.IdAceptacionPedidoPedimentoComprobante = OP.IdDocumento
								AND OP.IdTipoOperacion = 19 --> CTE APROBACIÓN DE PEDIMENTO
								AND	OP.IdProveedor = APC.IdProveedor
						WHERE APC.IdPedimentoComprobante = @IdPedimentoComprobante);

	UPDATE dbo.TA_Operacion
		SET IdEstatusOperacion = 1, --> CTE SE REINICIA APROBACIÓN
			IdEstadoFlujo = 2,
			IdFlujoTarea = @IdFlujoAprobacion
		WHERE IdOperacion = @IdOperacion;

	 --ELIMINADO LOGICO DE LAS TAREAS DE ESTE PEDIMENTO
	UPDATE dbo.TA_Tarea
	SET Activo = 0
	WHERE IdOperacion = @IdOperacion;

	--AGREGADO DE LAS NUEVAS TAREAS DE ESTE PEDIMENTO
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
	WHERE FT.IdFlujoTarea = @IdFlujoTarea
	GROUP BY APT.IdUsuario,
             APT.NoSecuencia;


	----Agregar Evento al Historial del Flujo de Tarea----
	SET @DescripcionH = 'El Usuario ' +(SELECT Nombre FROM S_USuario WHERE IdUsuario = @IdUsuario)+ ' ha reenviado la Tarea de Tipo ' + ISNULL((SELECT NombreOperacion FROM TA_TipoOperacion WHERE IdTipoOperacion= 19),'Aprobación de pedimento')

	INSERT INTO TA_HistorialFlujoTarea(IdOperacion, Fecha,Descripcion, IdEstadoFlujo)
	VALUES(@IdOperacion,GETDATE(),@DescripcionH,1)

	SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C
									INNER JOIN TA_CorreoServidor AS S
										ON C.IdServidor = S.IdServidor
								WHERE IdCorreo = 107) --> CTE NUMERO CORREO (TA_Correo)

	SET @TIPOFLUJO = (SELECT TOP 1
									TFT.IdTipoFlujoTarea
								FROM dbo.TA_Operacion AS OP
									JOIN dbo.TA_FlujoTarea AS FT
										ON OP.IdFlujoTarea = FT.IdFlujoTarea
									JOIN dbo.TA_TipoFlujoTarea AS TFT
										ON FT.IdTipoFlujo = TFT.IdTipoFlujoTarea
								WHERE OP.IdOperacion = @IdOperacion);

	IF @TIPOFLUJO = 1
		BEGIN

			DECLARE @IDSIGAPROBADOR INT = (SELECT TOP 1
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
																		ON PC.IdSubcontratistaExportador = PVS.IdSubcontratista
																WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante);
			    
				SET @NOMBRESIGAPROBADOR = (SELECT Nombre FROM dbo.S_Usuario WHERE IdUsuario = @IDSIGAPROBADOR);
				SET @CORREOSIGAPROBADOR = (SELECT Correo FROM dbo.S_Usuario WHERE IdUsuario = @IDSIGAPROBADOR);
				SET @UsuarioAdincoId = (SELECT IdUsuarioADINCO FROM dbo.S_Usuario WHERE IdUsuario = @IDSIGAPROBADOR);
				SET @CORREOSIG = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 107);

				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_USUARIO##',@NOMBRESIGAPROBADOR));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_CLIENTE##',@NOMBRESUBCONTRATISTA));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##COMPROBANTE##',CAST(@IdPedimentoComprobante AS NVARCHAR(10))));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##ANIO_ACTUAL##',YEAR(GETDATE())));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##URL_PEDIDO##', ISNULL(@DominioProcura,'')+'04Tareas/AprobacionPedimentoComprobante_CD.aspx'));
												
				INSERT INTO #TemporalCorreosUsuario (   
					Para,
					Asunto,
					Mensaje,                                       
					CreadoPor,
					UsuarioAdincoId
				) 	
				VALUES
				(	
				    @CORREOSIGAPROBADOR,        -- Para - varchar(1000)
				    'Aprobación Pendiente de Pedimento/Comprobante Extranjero',        -- Asunto - varchar(500)
				    @CORREOSIG,        -- Mensaje - text				   
				    3,         -- CTE Usuario CreadoPor - int
					@UsuarioAdincoId
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
				(   @IdPedimentoComprobante,         -- IdDocumento - int
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
			    Correo,
				UsuarioAdincoId
			)
			SELECT
				T.IdAprobador,
				US.Nombre,
				US.Correo,
				US.IdUsuarioADINCO
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
																WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante);
			    
				SET @NOMBRESIGAPROBADOR = (SELECT Nombre FROM @APROBADORESTABLE WHERE ID = @CONT);
				SET @CORREOSIGAPROBADOR = (SELECT Correo FROM @APROBADORESTABLE WHERE ID = @CONT);
				SET @UsuarioAdincoId = (SELECT UsuarioAdincoId FROM @APROBADORESTABLE WHERE ID = @CONT);
				SET @CORREOSIG = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 107);

				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_USUARIO##',@NOMBRESIGAPROBADOR));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_CLIENTE##',@NOMBRESUBCONTRATISTA));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##COMPROBANTE##',CAST(@IdPedimentoComprobante AS NVARCHAR(10))));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##ANIO_ACTUAL##',YEAR(GETDATE())));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##URL_PEDIDO##', ISNULL(@DominioProcura,'')+'04Tareas/AprobacionPedimentoComprobante_CD.aspx'));
				
				INSERT INTO #TemporalCorreosUsuario (   
					Para,
					Asunto,
					Mensaje,                                       
					CreadoPor,
					UsuarioAdincoId
				) 	
				VALUES
				(	
				    @CORREOSIGAPROBADOR,        -- Para - varchar(1000)
				    'Aprobación Pendiente de Pedimento/Comprobante Extranjero',        -- Asunto - varchar(500)
				    @CORREOSIG,        -- Mensaje - text				   
				    3,        -- CTE USUARIO CreadoPor - int
					@UsuarioAdincoId
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
				(   @IdPedimentoComprobante,         -- IdDocumento - int
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


	SELECT @IdOperacion AS IdOperacion,
	@IdPedimentoComprobante AS IdPedimento

	SELECT 
	Para,
	Asunto,
	Mensaje,
	CreadoPor,
	UsuarioAdincoId
	FROM #TemporalCorreosUsuario 
END
