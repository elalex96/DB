USE [Petrovendor]
GO
IF OBJECT_ID('SP_PC_CambiarEstatusTareaPedimentoComprobante_CD') IS NOT NULL
BEGIN
DROP PROCEDURE SP_PC_CambiarEstatusTareaPedimentoComprobante_CD;
END
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <01/09/2020>
-- Description:	<Cambio de estatus de de la tarea de la aprobacion de comprobante extranjero>
-- =============================================
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <01/09/2023>
-- Description:	<se pasa el importe total en el campo de precio unitario para adinco>
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 16-08-2023
-- Description:	se agrega la actualizacion del campo updateByApp para localizacion de actualizaciones desde la app
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <22/07/2025>
-- Description:	<Retorno del correo de compra directa>
-- =============================================
-- Author:		DANIEL AC
-- Create date: <29/10/2025>
-- Description:	<Se habilita enviar gastos y cn en Adinco una vez aprobado el comprobante/pedimento >
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_CambiarEstatusTareaPedimentoComprobante_CD]
	-- Add the parameters for the stored procedure here
	@IdUsuario INT,
	@IdOperacion INT,
	@IdProveedor INT,
	@IdEstatus INT,
	@NoSecuencia INT,
	@Comentario NVARCHAR(MAX),
	@IdPedimentoComprobante INT,
	@updateByApp BIT = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ID_DOCUMENTO_FI INT;
	DECLARE @TOTAL_APROBADORES INT;
	DECLARE @TOTAL_APROBADOS INT;
	DECLARE @SIGNSECUENCIA INT = @NoSecuencia + 1;
	DECLARE @DescripcionH NVARCHAR(MAX);
	DECLARE @IdPedimentoComprobante_ADINCO INT;
	DECLARE @NOMBRESIGAPROBADOR NVARCHAR(100);
	DECLARE @CORREOSIGAPROBADOR NVARCHAR(100);
	DECLARE @IDNOTIFICACION INT;
	DECLARE @CORREOSIG NVARCHAR(MAX);
	DECLARE @NOMBRESUBCONTRATISTA NVARCHAR(100);
	DECLARE @TIPOFLUJO INT;
	DECLARE @IDSIGAPROBADOR INT;
	DECLARE @DominioProcura NVARCHAR(500) = (SELECT URL FROM Petrovendor..TA_Dominios WHERE IdDominio = 2) --> CTE DOMINIO PROCURA
	DECLARE @ID_CONTRATO INT

	SET @NOMBRESUBCONTRATISTA = (SELECT TOP 1
														PVS.RazonSocial
													FROM dbo.FI_PedimentoComprobante AS PC (NOLOCK)
														JOIN Adinco.dbo.PV_Subcontratista AS PVS (NOLOCK)
															ON PVS.IdSubcontratista = PC.IdSubcontratistaExportador
													WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante);
	SET @TIPOFLUJO = (SELECT TOP 1
									TFT.IdTipoFlujoTarea
								FROM dbo.TA_Operacion AS OP (NOLOCK)
									JOIN dbo.TA_FlujoTarea AS FT (NOLOCK)
										ON OP.IdFlujoTarea = FT.IdFlujoTarea
									JOIN dbo.TA_TipoFlujoTarea AS TFT (NOLOCK)
										ON FT.IdTipoFlujo = TFT.IdTipoFlujoTarea
								WHERE OP.IdOperacion = @IdOperacion);
	SET @IDSIGAPROBADOR = (SELECT TOP 1
										IdAprobador
									FROM dbo.TA_Tarea (NOLOCK)
									WHERE IdOperacion = @IdOperacion
										AND Activo = 1
										AND NoSecuencia = @SIGNSECUENCIA);


	SET @ID_CONTRATO  = (SELECT P.IdContrato
						FROM FI_PedimentoComprobante P																
						WHERE P.IdPedimentoComprobante =@IdPedimentoComprobante )
	IF @TIPOFLUJO = 1
	BEGIN
	    
		UPDATE dbo.TA_Tarea 
		SET IdEstatus = @IdEstatus,
			Comentario = @Comentario,
			FechaCambioEstatus = GETDATE(),
			updateByApp = @updateByApp
		WHERE IdAprobador = @IdUsuario
			AND NoSecuencia = @NoSecuencia
			AND IdOperacion = @IdOperacion
			AND Activo = 1
			AND FechaCambioEstatus IS NULL;

	END

	IF @TIPOFLUJO = 2
	BEGIN
	    
		UPDATE dbo.TA_Tarea 
		SET IdEstatus = @IdEstatus,
			Comentario = @Comentario,
			FechaCambioEstatus = GETDATE(),
			updateByApp = @updateByApp
		WHERE IdAprobador = @IdUsuario
			AND IdOperacion = @IdOperacion
			AND Activo = 1
			AND FechaCambioEstatus IS NULL;

	END

	IF @IdEstatus = 3
	BEGIN
		SET @DescripcionH = 'El Usuario ' +(SELECT Nombre FROM S_USuario (NOLOCK) WHERE IdUsuario = @IdUsuario)+ ' ha Rechazado la Tarea de ' + (SELECT NombreOperacion FROM TA_TipoOperacion (NOLOCK) WHERE IdTipoOperacion= 19)

		INSERT INTO TA_HistorialFlujoTarea(IdOperacion, Fecha,Descripcion, IdEstadoFlujo)
		VALUES(@IdOperacion,GETDATE(),@DescripcionH,2)
		
	    --CANCELAR TODAS LAS TAREAS PENDIENTES
		UPDATE dbo.TA_Tarea 
		SET IdEstatus = 4
		WHERE IdOperacion = @IdOperacion
			AND IdEstatus = 1;

		--RECHAZAR LA OPERACION
		UPDATE dbo.TA_Operacion
		SET IdEstatusOperacion = 3,
			IdEstadoFlujo = 4
		WHERE IdOperacion = @IdOperacion
			AND IdProveedor = @IdProveedor;

		SET @DescripcionH = 'Se ha Finalizado la ' + (SELECT NombreOperacion FROM TA_TipoOperacion WHERE IdTipoOperacion= 19);
		INSERT INTO TA_HistorialFlujoTarea(IdOperacion, Fecha,Descripcion, IdEstadoFlujo)
		VALUES(@IdOperacion,GETDATE(),@DescripcionH,7)

	END

	IF @IdEstatus = 2
	BEGIN
		--AGREGADO DEL HISTORIAL
		SET @DescripcionH = 'El Usuario ' +(SELECT Nombre FROM S_USuario (NOLOCK) WHERE IdUsuario = @IdUsuario)+ ' ha Aprobado la Tarea de ' + (SELECT NombreOperacion FROM TA_TipoOperacion (NOLOCK) WHERE IdTipoOperacion= 19)

		INSERT INTO TA_HistorialFlujoTarea(IdOperacion, Fecha,Descripcion, IdEstadoFlujo)
		VALUES(@IdOperacion,GETDATE(),@DescripcionH,2)

		IF @TIPOFLUJO = 1
		BEGIN
		    
			IF @IDSIGAPROBADOR IS NOT NULL
			BEGIN
			    
				SET @NOMBRESIGAPROBADOR = (SELECT Nombre FROM dbo.S_Usuario (NOLOCK) WHERE IdUsuario = @IDSIGAPROBADOR);
				SET @CORREOSIGAPROBADOR = (SELECT Correo FROM dbo.S_Usuario (NOLOCK) WHERE IdUsuario = @IDSIGAPROBADOR);
				SET @CORREOSIG = (SELECT HTML FROM dbo.TA_Correo (NOLOCK) WHERE IdCorreo = 107);

				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_USUARIO##',@NOMBRESIGAPROBADOR));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_CLIENTE##',@NOMBRESUBCONTRATISTA));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##COMPROBANTE##',CAST(@IdPedimentoComprobante AS NVARCHAR(10))));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##ANIO_ACTUAL##',YEAR(GETDATE())));
				SET @CORREOSIG = (REPLACE(@CORREOSIG,'##URL_PEDIDO##',CONCAT(@DominioProcura,'04Tareas/AprobacionPedimentoComprobante_CD.aspx')));

			END

		END

	    --CONSULTAR EL TOTAL DE TAREAS
		SET @TOTAL_APROBADORES = (SELECT COUNT(IdTarea) FROM dbo.TA_Tarea (NOLOCK) WHERE IdOperacion = @IdOperacion AND Activo = 1);
		--CONSULTAR EL TOTAL DE TAREAS APROBADAS
		SET @TOTAL_APROBADOS = (SELECT COUNT(IdTarea) FROM dbo.TA_Tarea (NOLOCK) WHERE IdOperacion = @IdOperacion AND Activo = 1 AND IdEstatus = 2);

		--APROBAR LA OPERACION
		IF @TOTAL_APROBADORES = @TOTAL_APROBADOS
		BEGIN
		    
			UPDATE dbo.TA_Operacion
			SET IdEstatusOperacion = 2,
				IdEstadoFlujo = 3
			WHERE IdOperacion = @IdOperacion
				AND IdProveedor = @IdProveedor;

			SET @DescripcionH = 'Se ha Finalizado la ' + (SELECT NombreOperacion FROM TA_TipoOperacion (NOLOCK) WHERE IdTipoOperacion= 19)

			INSERT INTO TA_HistorialFlujoTarea(IdOperacion, Fecha,Descripcion, IdEstadoFlujo)
			VALUES(@IdOperacion,GETDATE(),@DescripcionH,7)

			SET @ID_DOCUMENTO_FI = (SELECT TOP 1 IdDocumento FROM dbo.FI_Documento (NOLOCK) WHERE IdPedimentoComprobante = @IdPedimentoComprobante);

			--SE VERIFICA QUE EL PEDI/COMP EXISTA EN LA TABLA FI_DOCUMENTO(QUIERES DECIR QUE ES UN PDF)
			IF ISNULL(@ID_DOCUMENTO_FI,0) <> 0
			BEGIN
			    
				--GUARDADO EN ADINCO
				INSERT INTO Adinco.dbo.FI_PedimentoComprobante
				(
					 [IdContrato],
					 [NumeroPedimento],
					 [ClavePedimento],
					 [FolioComprobante],
					 [FechaPago],
					 [Regimen],
					 [IdSubcontratistaImportador],
					 [AduanaES],
					 [IdSubcontratistaExportador],
					 [IdMoneda],
					 [AcuseElectronico],
					 [CvTipoDocFacturacion],
					 [CreadoPor],
					 [CreadoEn],
					 [IdFiscalP],
					 [RazonSocialP],
					 CuentaBancaria,
					 IdPedimentoComprobantePetrovendor,
					 IdOrigen,
					 Activo,
					 FechaIntercambio,
					 EsnotaCredito,
					 NumFacturaC
				)
				SELECT
					PC.IdContrato,
					PC.NumeroPedimento,
					PC.ClavePedimento,
					PC.FolioComprobante,
					PC.FechaPago,
					PC.Regimen,
					PC.IdSubcontratistaImportador,
					PC.AduanaES,
					PC.IdSubcontratistaExportador,
					PC.IdMoneda,
					PC.AcuseElectronico,
					PC.CvTipoDocFacturacion,
					US.IdUsuarioADINCO,
					PC.CreadoEn,
					PC.IdFiscalP,
					PC.RazonSocialP,
					PC.CuentaBancaria,
					PC.IdPedimentoComprobante,
					1,                         ---IdOrigen -->Petrovendor 
					1,
					GETDATE(),
					PC.EsnotaCredito,
					PC.NumFacturaC
				FROM Petrovendor.dbo.FI_PedimentoComprobante AS PC (NOLOCK)
				LEFT JOIN dbo.S_Usuario AS US (NOLOCK) 
					ON PC.CreadoPor = US.IdUsuario 
				WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante;

				SET @IdPedimentoComprobante_ADINCO = SCOPE_IDENTITY();
				INSERT INTO Adinco.dbo.FI_PedimentoComprobanteDetalle
				(
					 [IdPedimentoComprobante],
					 [DescripcionMercancia],
					 [ClaseBienServicio],
					 [PrecioUnitario],
					 [CreadoPor],
					 [CreadoEn],
					 [ImporteTotal],
					 [Cantidad],
					 [IdUnidadMedida]
				)
				SELECT
					@IdPedimentoComprobante_ADINCO,
					ISNULL(PCD.DescripcionMercancia,'-'),
					ISNULL(PCD.ClaseBienServicio,'-'),
					CASE
						WHEN PC.TipoOrigen = 'PC_CD' THEN SUM(PCD.PrecioUnitario) --PEDIMENTO DE IMPORTACION COMPRA DIRECTA
						WHEN PC.TipoOrigen = 'CE_CD' THEN SUM(PCD.PrecioUnitario) --COMPROBANTE EXTRANJERO COMPRA DIRECTA
						WHEN PC.TipoOrigen = 'PC_M' THEN SUM(PCD.ImporteTotal) --PEDIMENTO/COMPROBANTE MERCADEO
						ELSE SUM(PCD.ImporteTotal)
					END,
					US.IdUsuarioADINCO,
					GETDATE(),
					CASE
						WHEN PC.TipoOrigen = 'PC_CD' THEN SUM(PCD.PrecioUnitario) --PEDIMENTO DE IMPORTACION COMPRA DIRECTA
						WHEN PC.TipoOrigen = 'CE_CD' THEN SUM(PCD.PrecioUnitario) --COMPROBANTE EXTRANJERO COMPRA DIRECTA
						WHEN PC.TipoOrigen = 'PC_M' THEN SUM(PCD.ImporteTotal) --PEDIMENTO/COMPROBANTE MERCADEO
						ELSE SUM(PCD.ImporteTotal)
					END,
					1, --> CTE CANTIDAD 
					PCD.IdUnidadMedida
				FROM Petrovendor.dbo.FI_PedimentoComprobanteDetalle AS PCD (NOLOCK)
				JOIN Petrovendor.dbo.S_Usuario AS US (NOLOCK)
					ON PCD.CreadoPor = US.IdUsuario 
				JOIN Petrovendor.dbo.FI_PedimentoComprobante AS PC (NOLOCK)
						ON PCD.IdPedimentoComprobante = PC.IdPedimentoComprobante
				WHERE PCD.IdPedimentoComprobante = @IdPedimentoComprobante
				GROUP BY PC.IdPedimentoComprobante,
						US.IdUsuarioADINCO,
						PC.TipoOrigen,
						PCD.IdUnidadMedida,
						PCD.DescripcionMercancia,
						PCD.ClaseBienServicio;
				
				/*AGREGAR DOCUMENTO PEDIMENTO*/
				INSERT INTO Adinco.dbo.FI_Documento
				(
					 [IdTipoDocumento],
					 [IdPedimentoComprobante],
					 [NombreExtensionArchivo],
					 [IdUsuario],
					 [FechaCarga],
					 [IsEliminado],
					 [DocumentoByte]
				)
				SELECT
					FID.IdTipoDocumento,
					@IdPedimentoComprobante_ADINCO,
					FID.NombreExtensionArchivo,
					US.IdUsuario,
					FID.FechaCarga,
					FID.IsEliminado,
					FID.DocumentoByte
				FROM Petrovendor.dbo.FI_Documento AS FID (NOLOCK)
				LEFT JOIN dbo.S_Usuario AS US (NOLOCK)
					ON FID.IdUsuario = US.IdUsuario 
				WHERE FID.IdPedimentoComprobante = @IdPedimentoComprobante;
								
				INSERT INTO dbo.FI_RelacionAdincoPedimentoComprobante
				(
					IdPedimentoComprobantePetrovendor,
					IdPedimentoComprobanteAdinco,
					CreadoEl
				)
				VALUES
				(   @IdPedimentoComprobante,        -- IdPedimentoComprobantePetrovendor - int
					@IdPedimentoComprobante_ADINCO,        -- IdPedimentoComprobanteAdinco - int
					GETDATE() -- CreadoEl - datetime
					)


					
						INSERT INTO dbo.CO_Registro
						(
							IdPrograma,
							IdFactura,
							MontoRegistro,
							InicioEjecucion,
							FinEjecucion,
							Comentarios,
							MesPresentacion,
							IdEstado,
							IdUsuarioCreadoPor,
							FecMovto,
							IdInstalacion,
							CreadoPor,
							IdPedimentoComprobante,
							CvTipoDocFacturacion,
							CentroCostos,
							IdLineaPresupuestoMes,
							CostosAtribuiblesAdministracion,
							IdGastoRubro,
							PCN,
							IdCBSISH,
							IdAceptacionPedidoDetalle
						)
						SELECT 
							PC.IdLineaPresupuesto,
							NULL,
							ISNULL(CCN.ValorFactura,PCD.PrecioUnitario) AS MontoRegistro,
							pc.FechaPago,
							pc.FechaPago,
							ISNULL(CCN.DescripcionBienesServicios,PCD.DescripcionMercancia) AS Comentarios,
							DATEADD(MONTH, DATEDIFF(MONTH, 0, pc.CreadoEn), 0),
							10004, --> CTE IdEstado
							@IdUsuario,
							GETDATE(),
							NULL,
							@IdUsuario,
							@IdPedimentoComprobante,
							PC.CvTipoDocFacturacion,--> CvTipoDocFacturacion CTE  (2- Pedimento/ 3 Comprobante)
							NULL,
							PC.IdLineaPresupuesto,
							0,
							CCN.ClasificacionSH,
							SUBSTRING(CAST(ISNULL(CCN.PCN,0) AS NVARCHAR(50)), 1, 5),
							CCN.IdActividadBS,
							PCD.IdAceptacionPedidoDetalle
						FROM dbo.FI_PedimentoComprobante PC						
						LEFT JOIN CN_CompraDirecta CCN
							ON PC.IdPedimentoComprobante = CCN.IdPedimentoComprobante
						LEFT JOIN FI_PedimentoComprobanteDetalle PCD
							ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
						WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante

					--SE COPIA A CO_REGISTRO DE ADINCO
					INSERT INTO Adinco.dbo.CO_Registro
					(
						IdPrograma,
						IdFactura,
						MontoRegistro,
						InicioEjecucion,
						FinEjecucion,
						Comentarios,
						MesPresentacion,
						IdEstado,
						IdUsuarioCreadoPor,
						IdUsuarioModPor,
						FecMovto,
						IdInstalacion,
						IdCatalogoCuentasSH,
						CreadoPor,
						Fila,
						IdPedimentoComprobante,
						CvTipoDocFacturacion,
						Poliza,
						IsEditable,
						CostosAtribuiblesAdministracion,
						IdGastoRubro,
						PCN,
						IdCBSISH,
						IdAceptacionPedidoDetalle
					)
					SELECT 
						r.IdPrograma,
						r.IdFactura,
						r.MontoRegistro,
						r.InicioEjecucion,
						r.FinEjecucion,
						r.Comentarios,
						r.MesPresentacion,
						r.IdEstado,
						ISNULL(u.IdUsuarioADINCO, u.IdUsuario),
						ISNULL(u.IdUsuarioADINCO, u.IdUsuario),
						r.FecMovto,
						r.IdInstalacion,
						r.IdCatalogoCuentasSH,
						ISNULL(u.IdUsuarioADINCO, u.IdUsuario),
						r.Fila,
						@IdPedimentoComprobante_ADINCO,
						r.CvTipoDocFacturacion,
						r.Poliza,
						1, --> Es editable
						r.CostosAtribuiblesAdministracion,
						r.IdGastoRubro,
						r.PCN,
						r.IdCBSISH,
						r.IdAceptacionPedidoDetalle
					FROM dbo.CO_Registro r
					LEFT JOIN dbo.S_Usuario u 
						ON  r.CreadoPor = u.IdUsuario 
					WHERE r.IdPedimentoComprobante = @IdPedimentoComprobante

					--SE AGREGA LA RELACION DE COMPROBANTE PETROVENDOR/ADINCO
						INSERT INTO dbo.FI_RelacionComprobanteAdinco
						(
							IdComprobantePetrovendor,
							IdComprobanteAdinco,
							FechaEnvio
						)
						VALUES
						(   @IdPedimentoComprobante,        -- IdComprobantePetrovendor - int
							@IdPedimentoComprobante_ADINCO,        -- IdComprobanteAdinco - int
							GETDATE() -- FechaEnvio - datetime
						)

						EXEC dbo.SP_WA_InserRegistroPaseAdinco  @IdPedimentoComprobante,       -- int
		                                    3,       -- int
		                                    @IdPedimentoComprobante_ADINCO, -- int
		                                    @IdUsuario,         -- int
		                                    @IdProveedor,       -- int
		                                    @ID_CONTRATO,        -- int
		                                    'PASE DE PEDIMENTO EXTRANJERO DIRECTO  - ENVIO POR SP_PC_CambiarEstatusTareaPedimentoComprobante_CD',       -- nvarchar(max)
		                                    '',            -- nvarchar(50)
		                                    0;           -- bit
				END 
	
			
		END
	END

	IF (SELECT TOP 1 IdEstatus FROM dbo.TA_Tarea WHERE IdOperacion = @IdOperacion AND IdAprobador = @IdUsuario) = @IdEstatus
	BEGIN
	    
		SELECT 'SUCCESS' AS RESPONSE,
				@CORREOSIGAPROBADOR AS Para,        -- Para - varchar(1000)
				'Aprobación Pendiente de Pedimento/Comprobante Extranjero' AS Asunto,        -- Asunto - varchar(500)
				@CORREOSIG AS Mensaje;

	END
	ELSE
	BEGIN
	    
		SELECT 'ERROR LOGICO' AS RESPONSE,
		NULL AS Para,
		NULL AS Asunto,
		NULL AS Mensaje;

	END

END