USE Adinco
GO
DROP PROCEDURE IF EXISTS Mobile_sp_CambioEstatusAprobacion
GO
-- =============================================
-- Author:		Luis David
-- Create date: 23-03-2022
-- Description:	Se actualiza el sp para aprobación de pedimento comprobante
-- =============================================
CREATE PROCEDURE [dbo].[Mobile_sp_CambioEstatusAprobacion] --25374,3,2,12,'APROBANDO DESDE EL SP DE LA APP',0,14
@IdAprobacion INT ,	--APP
@IdContrato Int ,		--APP
@IdStatus INT ,			--APP
@IdUsuario INT ,		--APP
@Comentario nvarchar(max) = NULL,	--APP
@NoVersion Int ,			--APP
@TipoPedido INT				--APP
as
begin
DECLARE @IdFirma nvarchar(max),
		@IdOperacion INT,
		@fecha datetime = GETDATE(),
		@IdAprobador INT,
		@Estatus Int,
		@SolicitudPedido iNT,
		@IdProveedor INT,
		@NumAprobadores INT,
		@NumAprobados INT,
		@UUID NVARCHAR(100),
		@IdFacturaPetro INT,
		@IdPedidoCD INT,
		@IdFacturaAdinco INT,
		@Secuencia INT,
		@IdPedimentoComprobante INT;
	---- Se obtiene el id usuario  de petrovendor
	SET @IdAprobador = (SELECT top 1 IdUsuario FROM Petrovendor.dbo.S_Usuario WHERE IdUsuarioADINCO = @IdUsuario)
	--- HISTORIAL
	INSERT INTO Petrovendor..APP_BitacoraAprobacionesApp(IdTarea,IdTipoPedido,IdEstatus,Fecha,App)
	VALUES (@IdAprobacion,@TipoPedido,@IdStatus,GETDATE(),'V2')
	------------------------------------
	--SE VALIDA QUE SEA DEL TIPO SOLPED-
	------------------------------------
	IF @TipoPedido = 2
	begin
		set @Estatus = (SELECT TOP 1
						PTA.IdEstatus AS 'Estatus Petrovendor' 
						from Petrovendor.dbo.TA_Tarea AS PTA 
						JOIN Petrovendor.dbo.TA_Operacion AS OP ON OP.IdOperacion = PTA.IdOperacion
						WHERE PTA.IdTarea = @IdAprobacion)
		if @Estatus = 1
		begin
		-- se obtiene la firma y el operador
			SELECT TOP 1 @IdFirma =  idfirma,
					@IdOperacion  =  IdOperacion
			FROM Petrovendor.dbo.TA_Tarea 
			WHERE IdTarea = @IdAprobacion
			EXEC Petrovendor.dbo.SP_TA_ActualizarEstatusTarea	@IdOperacion = @IdOperacion,-- int
													@IdEstatus = @IdStatus,                        -- int
													@IdUsuario = @IdAprobador,                        -- int
													@Comentario = @Comentario,                     -- nvarchar(max)
													@IdFirma = @IdFirma,                        -- nvarchar(max)
													@IdContrato = @IdContrato,                       -- int
													@FechaRegistro = @fecha -- datetime
		-- Se registra en la bitacora de aprobados 
			exec Adinco..Mobile_sp_RegistroBitacora_Aprobacio @IdTarea = @IdAprobacion,
																@IdContrato = @IdContrato,
																@IdEstatus = @IdStatus,
																@Comentario = @Comentario,
																@AprobadorPetrovendor = @IdAprobador,
																@AprobadorAdinco = @IdUsuario,
																@FechaAprobacion = @fecha; 
		end
		else
		BEGIN
			SELECT 'El estatus del pedido ya fue cambiado con anterioridad' AS MENSAJE
		END
	end
	------------------------------------
	--SE VALIDA QUE SEA DEL TIPO PEDIDO-
	------------------------------------
	IF @TipoPedido = 9
	begin
		set @Estatus = (	SELECT TOP 1 TA.IdEstatus
							FROM Petrovendor.dbo.TA_Tarea AS TA
							JOIN Petrovendor.dbo.TA_Operacion AS TAO ON TAO.IdOperacion = TA.IdOperacion
							INNER JOIN Petrovendor.dbo.MM_Pedido AS P ON P.IdSolicitudPedido = TAO.IdDocumento
							AND TAO.NoVersion = P.Version
							WHERE TAO.IdTipoOperacion = 9 AND
							TA.IdTarea =  @IdAprobacion)
		if @Estatus = 1 
		begin
							SELECT top 1 @SolicitudPedido = P.IdSolicitudPedido,
							@IdFirma = TA.IdFirma
							FROM Petrovendor.dbo.TA_Tarea AS TA
							JOIN Petrovendor.dbo.TA_Operacion AS TAO ON TAO.IdOperacion = TA.IdOperacion
							INNER JOIN Petrovendor.dbo.MM_Pedido AS P ON TAO.IdDocumento = P.IdSolicitudPedido   AND TAO.NoVersion = P.Version
							WHERE TAO.IdTipoOperacion = 9 AND TA.IdTarea = @IdAprobacion
			--------
			EXEC Petrovendor.dbo.SP_TA_ActualizarEstatusPedidoAprobacion	@IdEstatus = @IdStatus,  
																			@IdSoliciudPedido = @SolicitudPedido, 
																			@IdAprobador = @IdAprobador,
																			@Comentario = @Comentario,     
																			@Version = @NoVersion,      
																			@IdFirma = @IdFirma
			-- Se registra en la bitacora de aprobados 
			exec Adinco..Mobile_sp_RegistroBitacora_Aprobacio @IdTarea = @IdAprobacion,
																@IdContrato = @IdContrato,
																@IdEstatus = @IdStatus,
																@Comentario = @Comentario,
																@AprobadorPetrovendor = @IdAprobador,
																@AprobadorAdinco = @IdUsuario,
																@FechaAprobacion = @fecha;
																
			/*Se valida y envia CORREO de notificacion de aprobacion  de pedido al siguiente aprobador, si es Flujo de aprobación SERIAL*/
			EXEC Petrovendor..Mobile_EnviarNotificacionAprobacionPedido  @IdTareaActual= @IdAprobacion,@Origen='Mobile_sp_CambioEstatusAprobacion'   	
			
			
		end
		else
		BEGIN
			SELECT 'El estatus del pedido ya fue cambiado con anterioridad' AS MENSAJE
		END
	end

	------------------------------------
	--SE VALIDA QUE SEA DEL TIPO PEDIDO-COMPRA DIRECTA
	------------------------------------
	IF @TipoPedido = 14
	BEGIN
		
		--OBTENCION DEL ESTATUS ORIGINAL
		set @Estatus = (SELECT TOP 1
						PTA.IdEstatus AS 'Estatus Petrovendor' 
						from Petrovendor.dbo.TA_Tarea AS PTA 
						JOIN Petrovendor.dbo.TA_Operacion AS OP ON OP.IdOperacion = PTA.IdOperacion
						WHERE PTA.IdTarea = @IdAprobacion);

		--OBTENCION DE LA OPERACION
		set @IdOperacion = (SELECT TOP 1
								OP.IdOperacion
							from Petrovendor.dbo.TA_Tarea AS PTA 
							JOIN Petrovendor.dbo.TA_Operacion AS OP ON OP.IdOperacion = PTA.IdOperacion
							WHERE PTA.IdTarea = @IdAprobacion);

		--OBTENCION DEL IDPROVEEDOR DE LA OPERACION
		set @IdProveedor = (SELECT TOP 1
								OP.IdProveedor
							from Petrovendor.dbo.TA_Tarea AS PTA 
							JOIN Petrovendor.dbo.TA_Operacion AS OP ON OP.IdOperacion = PTA.IdOperacion
							WHERE PTA.IdTarea = @IdAprobacion);

		--EVALUACION DEL VALOR ORIGINAL
		if @Estatus = 1 
		BEGIN
				


				--CAMBIO DE ESTATUS DE LA TAREA DE COMPRA DIRECTA
				CREATE TABLE #RESULTADOAPROBACION (
					ACCION NVARCHAR(200),
					IdFactura INT,
					IdAsignador INT
				);

				INSERT INTO #RESULTADOAPROBACION
				EXEC Petrovendor.dbo.SP_TA_ActualizarEstatusTarea_CD @IdProveedor = @IdProveedor,
																	@IdUsuario = @IdAprobador,
																	@Comentario = @Comentario,
																	@IdEstatus = @IdStatus,
																	@IdOperacion = @IdOperacion,
																	@ACCION = 'CAMBIAR_ESTATUS_APROBADOR',
																	@IdFirma = '',
																	@IdContrato = @IdContrato,
																	@FechaRegistro = @fecha;

				exec Adinco..Mobile_sp_RegistroBitacora_Aprobacio @IdTarea = @IdAprobacion,
																@IdContrato = @IdContrato,
																@IdEstatus = @IdStatus,
																@Comentario = @Comentario,
																@AprobadorPetrovendor = @IdAprobador,
																@AprobadorAdinco = @IdUsuario,
																@FechaAprobacion = @fecha;

				--SE CONSULTA EL NUMERO DE APROBADORES DE LA OPERACION
				set @NumAprobadores = (SELECT
									COUNT(1)
							from Petrovendor.dbo.TA_Tarea AS PTA 
							WHERE PTA.IdTarea = @IdOperacion and PTA.Activo = 1);

				--SE CONSULTA EL NUMERO DE APROBADORES QUE APROBARON LA OPERACION
				set @NumAprobados = (SELECT
									COUNT(1)
							from Petrovendor.dbo.TA_Tarea AS PTA 
							WHERE PTA.IdTarea = @IdOperacion and PTA.Activo = 1 and PTA.IdEstatus = 2);--APROBADO

				--SE VALIDA EL NUMERO DE APROBACIONES
				IF @NumAprobadores = @NumAprobados --COMPRA DIRECTA APROBADA
				BEGIN
					
					--APROBACION DE LA OPERACION
					EXEC Petrovendor.dbo.SP_TA_ActualizarEstatusTarea @IdOperacion = @IdOperacion,
																		@IdEstatus = @IdStatus,
																		@IdUsuario = @IdAprobador,
																		@Comentario = @Comentario,
																		@IdFirma = @IdFirma,
																		@IdContrato = @IdContrato,
																		@FechaRegistro = @fecha;

					--BUSQUEDA DE FACTURA EN PETRO
					set @IdFacturaPetro =  (SELECT TOP 1
											OP.IdDocumento
										from Petrovendor.dbo.TA_Operacion AS OP
										WHERE OP.IdTipoOperacion = 14
												AND OP.IdOperacion = @IdOperacion);
					SET @UUID = (SELECT TOP 1 UUID FROM Petrovendor.dbo.FI_Factura WHERE IdFactura = @IdFacturaPetro);

					IF NOT EXISTS(SELECT IdFactura FROM Adinco.dbo.FI_Factura WHERE UUID = @UUID)--VALIDAR SI LA FACTURA EXISTE EN ADINCO
					BEGIN

						--PASE DE FACTURA PETRO-ADINCO
						INSERT INTO Adinco.dbo.FI_Factura
						( Serie,
						 Folio,
						 Fecha,
						 Sello,
						 FormaPago,
						 NoCertificado,
						 Certificado,
						 CondicionesDePago,
						 SubTotal,
						 Descuento,
						 TipoCambio,
						 Moneda,
						 MontoConIva,
						 TipoComprobante,
						 MetodoPago,
						 LugarExpedicion,
						 NumCtaPago,
						 Emisor,
						 Receptor,
						 UUID,
						 FechaTimbrado,
						 SelloCFD,
						 NoCertificadoSAT,
						 SelloSAT,
						 FechaRecepcion,
						 IdMoneda,
						 IdContrato,
						XML,
						Activa,
						ArchivoPDF,
						ArchivoXML,
						CreadoPor,
						CreadoEn,
						--ModificadoPor,
						--ModificadoEn,
						NombreXML,
						IdEstudioPrecioTransfer,
						ProcesadoSIPAC)
						SELECT Serie,
							 Folio,
							 Fecha,
							 Sello,
							 FormaPago,
							 NoCertificado,
							 Certificado,
							 CondicionesDePago,
							 SubTotal,
							 Descuento,
							 TipoCambio,
							 Moneda,
							 MontoConIva,
							 TipoComprobante,
							 MetodoPago,
							 LugarExpedicion,
							 NumCtaPago,
							 Emisor,
							 Receptor,
							 UUID,
							 FechaTimbrado,
							 SelloCFD,
							 NoCertificadoSAT,
							 SelloSAT,
							 FechaRecepcion,
							 IdMoneda,
							 IdContrato,
							XML,
							Activa,
							ArchivoPDF,
							ArchivoXML,
							@IdUsuario,
							CreadoEn,
							--ModificadoPor,
							--ModificadoEn,
							NombreXML,
							IdEstudioPrecioTransfer,
							ProcesadoSIPAC
						FROM Petrovendor.dbo.FI_Factura
						WHERE IdFactura = @IdFacturaPetro

						--OBTENCION DEL ID FACTURA EN ADINCO
						SET @IdFacturaAdinco = SCOPE_IDENTITY();

						--PASE DE CONCEPTOS PETRO-ADINCO
						INSERT INTO Adinco.dbo.FI_CFDIConcepto (IdFactura,Descripcion,Cantidad,Unidad,ValorUnitario,Importe,NoIdentificacion,Descuento)
						SELECT
							@IdFacturaAdinco,
							Descripcion,
							Cantidad,
							Unidad,
							ValorUnitario,
							Importe,
							NoIdentificacion,
							Descuento
						FROM Petrovendor.dbo.FI_CFDIConcepto
						WHERE IdFactura = @IdFacturaPetro;

						--PASE DE IMPUESTOS PETRO-ADINCO
						INSERT INTO Adinco.dbo.FI_CFDIImpuesto (IdFactura,IdTipoImpuesto,Impuesto,Tasa,Importe)
						SELECT
							@IdFacturaAdinco,
							IdTipoImpuesto,
							Impuesto,
							Tasa,
							Importe
						FROM Petrovendor.dbo.FI_CFDIImpuesto
						WHERE IdFactura = @IdFacturaPetro;

						--GUARDADO DE LA RELACION PETRO-ADINCO
						INSERT INTO Adinco.dbo.FI_FacturaAdincoPetrovendor(IdFacturaPetrovendor, IdFacturaAdinco, FechaIntercambio, Activo)
																	VALUES(@IdFacturaPetro, @IdFacturaAdinco, GETDATE(), 1);
						
						--PASE DE GASTOS PETRO-ADINCO
						EXEC Petrovendor.dbo.MM_SP_EnvioDeGastoAdinco @idFacturaP = @IdFacturaPetro,
																	@IdFacturaAdinco = @IdFacturaAdinco,
																	@IdContrato = @IdContrato,
																	@IdUsuario = @IdAprobador,
																	@FechaRegistro = @fecha;

					END

				END


				
		END
		ELSE
		BEGIN 
			SELECT 'El estatus del pedido ya fue cambiado con anterioridad' AS MENSAJE
		END

	END
	------------------------------------
	--SE VALIDA QUE SEA DEL TIPO PEDIDO-COMPROBANTE/PEDIMENTO
	------------------------------------
	IF @TipoPedido = 19
	BEGIN
		
		--OBTENCION DEL ESTATUS ORIGINAL
		set @Estatus = (SELECT TOP 1
						PTA.IdEstatus AS 'Estatus Petrovendor' 
						from Petrovendor.dbo.TA_Tarea AS PTA 
						JOIN Petrovendor.dbo.TA_Operacion AS OP ON OP.IdOperacion = PTA.IdOperacion
						WHERE PTA.IdTarea = @IdAprobacion);

		IF @Estatus = 1
		BEGIN
				
			SELECT 
				@IdOperacion = OP.IdOperacion,
				@IdProveedor = OP.IdProveedor,
				@Secuencia = PTA.NoSecuencia,
				@IdPedimentoComprobante = APC.IdPedimentoComprobante
			from Petrovendor.dbo.TA_Tarea AS PTA 
			JOIN Petrovendor.dbo.TA_Operacion AS OP ON OP.IdOperacion = PTA.IdOperacion
			JOIN Petrovendor.dbo.FI_AceptacionPedido_PedimentoComprobante AS APC ON APC.IdAceptacionPedidoPedimentoComprobante = OP.IdDocumento
			WHERE PTA.IdTarea = @IdAprobacion;

			CREATE TABLE #RESULTADOAPROBACIONPC (RESPUESTA NVARCHAR(200));

			INSERT INTO #RESULTADOAPROBACIONPC
			EXEC Petrovendor.dbo.SP_PC_CambiarEstatusTareaPedimentoComprobante_CD @IdAprobador,
																								@IdOperacion,
																								@IdProveedor,
																								@IdStatus,
																								@Secuencia,
																								@Comentario,
																								@IdPedimentoComprobante;


				SELECT DISTINCT
				   TOO.IdOperacion,
				   FT.IdFlujoTarea,
				   FT.IdTipoFlujo,
				   TOO.IdEstatusOperacion,
				   TAE.Nombre,
				   TOO.IdEstadoFlujo,
				   TOO.IdTipoOperacion,
				   TTO.NombreOperacion,
				   U.IdUsuario,
				   T.NoSecuencia,
				   U.Nombre,
				   U.Correo,
				   T.IdEstatus,
				   TOO.IdDocumento,
				   TOO.IdAsignador,
				   TOO.IdProveedor,
				   ISNULL(T.Comentario, '') AS Comentario,
				   TAE.Name
			FROM Petrovendor.dbo.TA_Tarea AS T
				LEFT JOIN Petrovendor.dbo.TA_Operacion AS TOO
					ON TOO.IdOperacion = T.IdOperacion
				LEFT JOIN Petrovendor.dbo.TA_FlujoTarea AS FT
					ON FT.IdFlujoTarea = TOO.IdFlujoTarea
				LEFT JOIN Petrovendor.dbo.S_Usuario AS U
					ON U.IdUsuario = T.IdAprobador
				LEFT JOIN Petrovendor.dbo.TA_TipoOperacion AS TTO
					ON TTO.IdTipoOperacion = TOO.IdTipoOperacion
				LEFT JOIN Petrovendor.dbo.TA_Estatus AS TAE
					ON TAE.IdEstatus = TOO.IdEstatusOperacion
			WHERE TOO.IdOperacion = @IdOperacion
			ORDER BY NoSecuencia ASC
			
			
			exec Adinco..Mobile_sp_RegistroBitacora_Aprobacio @IdTarea = @IdAprobacion,
																@IdContrato = @IdContrato,
																@IdEstatus = @IdStatus,
																@Comentario = @Comentario,
																@AprobadorPetrovendor = @IdAprobador,
																@AprobadorAdinco = @IdUsuario,
																@FechaAprobacion = @fecha;



		END
		ELSE
		BEGIN
			SELECT 'El estatus del pedido ya fue cambiado con anterioridad' AS MENSAJE
		END


	END
END
