USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_EditarPedimento_CD'
)
    DROP PROCEDURE SP_FI_EditarPedimento_CD;
GO
/****** Object:  StoredProcedure [dbo].[SP_FI_EditarPedimento_CD]    Script Date: 03/06/2022 11:36:56 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Alexander Gomez
-- Create date: 08/09/2020
-- Description: Editar Pedimento
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 03/06/2022
-- Description:	Se obtiene correo de notificaciones directamente desde la tabla TA_CorreoServidor
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EditarPedimento_CD]
-- Add the parameters for the stored procedure here
@IdPedimentoComprobante     INT, 
@IdContrato                 INT, 
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
@DocumentoPDF               IMAGE, 
@IdFiscal                   NVARCHAR(50), 
@RazonSocial                NVARCHAR(MAX), 
@ImporteInco                MONEY,
@CuentaBancaria             NVARCHAR(500) = '',
@IdFlujoAprobacion INT
AS
     BEGIN
         SET NOCOUNT ON;
		 DECLARE @CorreoNotificaciones NVARCHAR(MAX);
         DECLARE @IdSubcontratistaImportador INT;
         DECLARE @Validacion INT;
         SET @Validacion = (DATALENGTH(@DocumentoPDF));
         /*PEDIMENTO*/
         --Obtener proveedor importador
         SELECT @IdSubcontratistaImportador = CC.IdProveedor
         FROM Adinco.dbo.CO_Contrato C
              JOIN Adinco.dbo.CO_Contratista CC ON C.IdContratista = CC.IdContratista
         WHERE C.IdContrato = @IdContrato;

         BEGIN
             UPDATE dbo.FI_PedimentoComprobante
               SET 
                   NumeroPedimento = @NumeroPedimento, 
                   ClavePedimento = @ClavePedimento, 
                   FolioComprobante = @FolioComprobante, 
                   FechaPago = @FechaPago, 
                   Regimen = @Regimen, 
                   IdSubcontratistaImportador = @IdSubcontratistaImportador, 
                   AduanaES = @AduanaES, 
                   IdSubcontratistaExportador = @IdSubcontratistaExportador, 
                   IdMoneda = @IdMoneda, 
                   AcuseElectronico = @AcuseElectronico, 
                   CvTipoDocFacturacion = @CvTipoDoc, 
                   ModificadoPor = @IdUsuario, 
                   ModificadoEn = GETDATE(), 
                   IdFiscalP = @IdFiscal, 
                   RazonSocialP = @RazonSocial,
                   CuentaBancaria = @CuentaBancaria
             WHERE IdPedimentoComprobante = @IdPedimentoComprobante;
         END;
         --
         BEGIN
             UPDATE dbo.FI_PedimentoComprobanteDetalle
               SET 
                   DescripcionMercancia = @DescripcionMercancia, 
                   PrecioUnitario = @SubTotal, 
                   ModificadoPor = @IdUsuario, 
                   ModificadoEn = GETDATE(), 
                   ImporteTotal = @ImporteInco
             WHERE IdPedimentoComprobante = @IdPedimentoComprobante;
         END;

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
		DECLARE @DescripcionH NVARCHAR(MAX);
		DECLARE @IdOperacion INT;
		DECLARE @IDESTATUS INT;
		DECLARE @APROBADORESTABLE TABLE(ID INT IDENTITY(1,1),IdAprobador INT, Nombre NVARCHAR(1000), Correo NVARCHAR(MAX));
	    

	SET @IdOperacion = (SELECT
							OP.IdOperacion
						FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
							JOIN dbo.TA_Operacion AS OP
								ON APC.IdAceptacionPedidoPedimentoComprobante = OP.IdDocumento
								AND OP.IdTipoOperacion = 19
								AND	OP.IdProveedor = APC.IdProveedor
						WHERE APC.IdPedimentoComprobante = @IdPedimentoComprobante);

	SET @IDESTATUS = (SELECT
							OP.IdEstatusOperacion
						FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
							JOIN dbo.TA_Operacion AS OP
								ON APC.IdAceptacionPedidoPedimentoComprobante = OP.IdDocumento
								AND OP.IdTipoOperacion = 19
								AND	OP.IdProveedor = APC.IdProveedor
						WHERE APC.IdPedimentoComprobante = @IdPedimentoComprobante);

	DECLARE @IdFlujoTarea INT;
	DECLARE @IDPROVEEDOR INT = (SELECT IdProveedor FROM dbo.FI_AceptacionPedido_PedimentoComprobante WHERE IdPedimentoComprobante = @IdPedimentoComprobante);
	SET @IdFlujoTarea = (  SELECT FT.IdFlujoTarea
							  FROM dbo.TA_FlujoTarea  FT
							  WHERE FT.IdProveedor= @IDPROVEEDOR 
							  AND FT.Predeterminado=1 
							  AND FT.IdTipoOperacion= 19);
	
	--VERIFICACION DEL ESTATUS PARA REVISICION
	IF @IDESTATUS = 3
	BEGIN

		UPDATE dbo.TA_Operacion
		SET IdEstatusOperacion = 1,
			IdEstadoFlujo = 2
		WHERE IdOperacion = @IdOperacion;

		UPDATE dbo.TA_Tarea
		SET Activo = 0
		WHERE IdOperacion = @IdOperacion;

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
				SET @CORREOSIG = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 107);

				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_USUARIO##',@NOMBRESIGAPROBADOR));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_CLIENTE##',@NOMBRESUBCONTRATISTA));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##COMPROBANTE##',CAST(@IdPedimentoComprobante AS NVARCHAR(10))));
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
					CONCAT('0 - Notificacion para Aprobacion del Pedimento/Comprobante #' , @IdPedimentoComprobante),  -- IdIdentificacion - int
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
																WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante);
			    
				SET @NOMBRESIGAPROBADOR = (SELECT Nombre FROM @APROBADORESTABLE WHERE ID = @CONT);
				SET @CORREOSIGAPROBADOR = (SELECT Nombre FROM @APROBADORESTABLE WHERE ID = @CONT);
				SET @CORREOSIG = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 107);

				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_USUARIO##',@NOMBRESIGAPROBADOR));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_CLIENTE##',@NOMBRESUBCONTRATISTA));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##COMPROBANTE##',CAST(@IdPedimentoComprobante AS NVARCHAR(10))));
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
					CONCAT('0 - Notificacion para Aprobacion del Pedimento/Comprobante #' , @IdPedimentoComprobante),  -- IdIdentificacion - int
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

	END

         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj, 
                @IdPedimentoComprobante;
     END;
