-- =============================================
-- Author:		Alexander E
-- Create date:30/05/2018
-- Description:	historial de una solicitud de pedido
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 18/10/2018
-- Description:	correccion de store para fecha antiguas
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 14/11/2019
-- Description:	agregado del flujo de aprobacion de comprobantes extranjeros
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarHistorialXSolicitudPedido] 
	-- Add the parameters for the stored procedure here
	@IDSOLPED INT ,
	/*--------------------
    parametros contrato
  --------------------*/
	@IdContrato INT = NULL, @IdUsuario INT = NULL, @FechaRegistro DATETIME = NULL
/*--------------------
  --------------------*/
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON 

		-- Insert statements for procedure here
		DECLARE @CANTCOT INT
		DECLARE @CANTRECIN INT =
					(	SELECT	COUNT ( IdSolPedReciclada )
						FROM	dbo.TA_RecicajeSolPed
						WHERE	IdSolPedNueva = @IDSOLPED ) ;

		CREATE TABLE #tempHistorial
			( IdSecuencia INT IDENTITY(1, 1) ,
			  Fecha DATETIME ,
			  NombreEstado NVARCHAR(MAX) ,
			  IdOperacion INT ,
			  Descripcion NVARCHAR(MAX) ,
			  IdTipoOperacion INT )

		IF @IDSOLPED > 0
			BEGIN
				IF @CANTRECIN > 0
					BEGIN
						INSERT INTO #tempHistorial
							( Fecha, NombreEstado, IdOperacion, Descripcion )
						SELECT		SP.FechaAlta, 'Reciclaje de Solicitud de Pedido', RS.IdSolPedAnterior ,
									CONCAT (
										'Se Registró la Solicitud de Pedido N° ' , RS.IdSolPedNueva ,
										', Reciclada de la Solicitud de Pedido N°' , RS.IdSolPedAnterior )
						FROM		dbo.TA_RecicajeSolPed AS RS
						LEFT JOIN	dbo.MM_SolicitudPedido AS SP
							ON SP.IdSolicitudPedido = RS.IdSolPedNueva
						WHERE		SP.IdSolicitudPedido = @IDSOLPED
					END

				INSERT INTO #tempHistorial
					( Fecha, NombreEstado, IdOperacion, Descripcion )
				SELECT		SP.FechaAlta, 'Registro de Solicitud de Pedido', SP.IdSolicitudPedido ,
							CONCAT (
								'Se ha registrado la Tarea de Tipo ' , 'Solicitud de Pedido', ' N°', SP.IdSolicitudPedido )
				FROM		dbo.MM_SolicitudPedido AS SP
				LEFT JOIN	dbo.TA_Operacion AS TAO
					ON TAO.IdDocumento = SP.IdSolicitudPedido
				WHERE
							SP.IdSolicitudPedido = @IDSOLPED
							AND TAO.IdTipoOperacion = 2

				INSERT INTO #tempHistorial
					( Fecha, NombreEstado, IdOperacion, Descripcion, IdTipoOperacion )
				SELECT		TH.Fecha, EF.NombreEstado, TAO.IdDocumento ,
							CASE WHEN TAO.IdTipoOperacion = 9 THEN
									 TH.Descripcion + ' N° ' + CONVERT ( NVARCHAR(50), ps.IdPedido )
							ELSE
								TH.Descripcion
							END AS Descripcion, TAO.IdTipoOperacion
				FROM		TA_HistorialFlujoTarea AS TH
				INNER JOIN	TA_EstadoFlujoTarea AS EF
					ON EF.Idestado = TH.IdEstadoFlujo
				INNER JOIN	TA_Operacion AS TAO
					ON TAO.IdOperacion = TH.IdOperacion
					AND TAO.IdTipoOperacion != 14
				LEFT JOIN	dbo.MM_Pedido p
					ON p.IdSolicitudPedido = TAO.IdDocumento
					   AND	p.Version = TAO.NoVersion	   
				LEFT JOIN	dbo.MM_Pedidos ps
					ON ps.IdIdentificador = p.IdPedido
				WHERE		TAO.IdDocumento = @IDSOLPED
				ORDER BY	TH.IdHistorial ASC

				SET @CANTCOT =
					(	SELECT	COUNT ( IdPeticionOferta )
						FROM	dbo.MM_PeticionOferta
						WHERE
								IdSolicitudPedido = @IDSOLPED
								AND Cotizado = 1 )

				IF @CANTCOT > 0
					BEGIN
						INSERT INTO #tempHistorial
							( Fecha, NombreEstado, IdOperacion, Descripcion )
						SELECT		CASE WHEN PO.FechaFinalizado IS NULL THEN
												(	 SELECT FechaFinalizacion
													FROM	dbo.TA_Operacion
													WHERE
														IdDocumento = @IDSOLPED
														AND ISNULL ( IdEstatusEliminado, 0 ) = 0
														AND FechaFinalizacion IS NOT NULL
														AND IdTipoOperacion = 6 )
									ELSE
										PO.FechaFinalizado
									END, 'Proveedor ha Cotizado', PO.IdSolicitudPedido ,
									CONCAT ( 'La Empresa ', P.RazonSocial, ' ', P.RegimenCapital, ' Cotizó la Peticion de Oferta N°', @IDSOLPED )
						FROM		S_Proveedor AS P
						INNER JOIN	MM_PeticionOferta AS PO
							ON PO.IdSubcontratista = P.IdProveedor
						WHERE
									PO.IdSolicitudPedido = @IDSOLPED
									AND PO.Cotizado = 1
						ORDER BY	PO.FechaFinalizado DESC
					END

				DECLARE @EDICIONFECHALIMIT INT =
							(	SELECT	COUNT ( Id_Historial )
								FROM	dbo.MM_HistorialCambiosCotizacion
								WHERE	IdSolicitudPedido = @IDSOLPED ) 

				IF @EDICIONFECHALIMIT > 0
					BEGIN
						INSERT INTO #tempHistorial
							( Fecha, NombreEstado, IdOperacion, Descripcion )
						SELECT		HCC.FechaEdicion, 'Cambio de Fecha Límite de Cotizacion', HCC.IdSolicitudPedido ,
									CONCAT (
										'El Usuario ' , US.Nombre, ' cambió la fecha de límite de cotización de ' ,
										HCC.FechaActual, ' a ', HCC.FechaNueva )
						FROM		dbo.MM_HistorialCambiosCotizacion AS HCC
						LEFT JOIN	dbo.S_Usuario AS US
							ON US.IdUsuario = HCC.IdEditadoPor
						WHERE		HCC.IdSolicitudPedido = @IDSOLPED ;
					END

				DECLARE @FECHAFINALOFERT DATETIME =
							(	SELECT	TOP 1 FechaFinalizacion
								FROM	dbo.TA_Operacion
								WHERE
										IdDocumento = @IDSOLPED
										AND IdTipoOperacion = 6
										AND FechaFinalizacion IS NOT NULL
										AND ISNULL(IdEstatusEliminado, 0) = 0 ) ;

				IF @FECHAFINALOFERT < GETDATE ()
					BEGIN
						INSERT INTO #tempHistorial
							( Fecha, NombreEstado, IdOperacion, Descripcion )
						SELECT		TAO.FechaFinalizacion, 'Fecha límite de cotización', TAO.IdDocumento ,
									CONCAT (
										'La Fecha límite de la ' , TOA.NombreOperacion, ' N°', CAST(@IDSOLPED AS NVARCHAR(100)), ' a Finalizado' )
						FROM		dbo.TA_Operacion AS TAO
						LEFT JOIN	dbo.TA_TipoOperacion AS TOA
							ON TOA.IdTipoOperacion = TAO.IdTipoOperacion
						WHERE
									TAO.IdDocumento = @IDSOLPED
									AND TAO.IdTipoOperacion = 6 
					END

				DECLARE @AceptaSerPedido INT =
							(	SELECT	COUNT ( IdPedido )
								FROM	MM_Pedido
								WHERE
										IdSolicitudPedido = @IDSOLPED
										AND RecepcionServicio = 1 ) 

				IF @AceptaSerPedido > 0
					BEGIN
						INSERT INTO #tempHistorial
							( Fecha, NombreEstado, IdOperacion, Descripcion )
						SELECT		PO.FechaRecepcionServicio, 'Orden de Compra', PO.IdPedido ,
									CONCAT (
										'La Empresa ' , P.RazonSocial, ' ', P.RegimenCapital, ' confirmó el Pedido N°' ,
										PD.IdPedido )
						FROM		S_Proveedor AS P
						INNER JOIN	MM_Pedido AS PO
							ON PO.IdSubcontratista = P.IdProveedor
						LEFT JOIN	dbo.MM_Pedidos AS PD
							ON PD.IdIdentificador = PO.IdPedido
							   AND	PO.IdProveedorCompras = PD.IdProveedorCliente
						--AND PD.IdTipoPedido = 2
						--2 ES DE MERCADEO
						WHERE
									PO.IdSolicitudPedido = @IDSOLPED
									AND PO.RecepcionServicio = 1
						ORDER BY	PO.FechaRecepcionServicio ASC
					END

				--DECLARE @IDPEDIDO INT = (SELECT IdPedido FROM MM_Pedido WHERE IdSolicitudPedido = @IDSOLPED AND RecepcionServicio = 1)
				DECLARE @ACEPPEDIDO INT =
							(	SELECT		COUNT ( AP.IdAceptacionPedido )
								FROM		MM_AceptacionPedido AS AP
								LEFT JOIN	dbo.MM_Pedido AS PED
									ON PED.IdPedido = AP.IdPedido
								LEFT JOIN	dbo.MM_SolicitudPedido AS SOL
									ON SOL.IdSolicitudPedido = PED.IdSolicitudPedido
								WHERE		SOL.IdSolicitudPedido = @IDSOLPED )

				IF @ACEPPEDIDO > 0
					BEGIN
						INSERT INTO #tempHistorial
							( Fecha, NombreEstado, IdOperacion, Descripcion )
						SELECT		AP.Creado, 'Aceptación de Servicio', AP.IdAceptacionPedido ,
									CONCAT (
										'Confirmación Recepción Servicio N°' , AP.IdAceptacionPedido, ', Recibido por ' ,
										AP.NombreRecibidoPor )
						FROM		MM_AceptacionPedido AS AP
						LEFT JOIN	dbo.MM_Pedido AS PED
							ON PED.IdPedido = AP.IdPedido
						LEFT JOIN	dbo.MM_SolicitudPedido AS SOL
							ON SOL.IdSolicitudPedido = PED.IdSolicitudPedido
						WHERE		SOL.IdSolicitudPedido = @IDSOLPED ;
					END

				DECLARE @IDPCN INT =
							(	SELECT		COUNT ( CCN.IdAceptacionCartaPCN )
								FROM		dbo.MM_AceptacionCartaPCN AS CCN
								LEFT JOIN	MM_AceptacionPedido AS AP
									ON AP.IdAceptacionPedido = CCN.IdAceptacionPedido
								LEFT JOIN	dbo.MM_Pedido AS PED
									ON PED.IdPedido = AP.IdPedido
								LEFT JOIN	dbo.MM_SolicitudPedido AS SOL
									ON SOL.IdSolicitudPedido = PED.IdSolicitudPedido
								WHERE		SOL.IdSolicitudPedido = @IDSOLPED )

				IF @IDPCN > 0
					BEGIN
						INSERT INTO #tempHistorial
							( Fecha, NombreEstado, IdOperacion, Descripcion )
						SELECT		CCN.CreadoEl, 'Registro de Carta PCN', CCN.IdAceptacionCartaPCN ,
									CONCAT (
										'Se ha registrado el documento de la Carta de Contenido Nacional asociado a la recepción de servicio N°' ,
										CCN.IdAceptacionPedido )
						FROM		dbo.MM_AceptacionCartaPCN AS CCN
						LEFT JOIN	MM_AceptacionPedido AS AP
							ON AP.IdAceptacionPedido = CCN.IdAceptacionPedido
						LEFT JOIN	dbo.MM_Pedido AS PED
							ON PED.IdPedido = AP.IdPedido
						LEFT JOIN	dbo.MM_SolicitudPedido AS SOL
							ON SOL.IdSolicitudPedido = PED.IdSolicitudPedido
						WHERE		SOL.IdSolicitudPedido = @IDSOLPED ;

						INSERT INTO #tempHistorial
							( Fecha, NombreEstado, IdOperacion, Descripcion )
						SELECT		CCN.CreadoEl, 'Carta PCN', CCN.IdAceptacionCartaPCN ,
									CONCAT (
										'El Usuario ' , US.Nombre ,
										' a Registrado el Documento de Carta PCN, de la Recepción de Servicio N°' ,
										CCN.IdAceptacionPedido )
						FROM		dbo.MM_AceptacionCartaPCN AS CCN
						LEFT JOIN	MM_AceptacionPedido AS AP
							ON AP.IdAceptacionPedido = CCN.IdAceptacionPedido
						LEFT JOIN	dbo.MM_Pedido AS PED
							ON PED.IdPedido = AP.IdPedido
						LEFT JOIN	dbo.MM_SolicitudPedido AS SOL
							ON SOL.IdSolicitudPedido = PED.IdSolicitudPedido
						LEFT JOIN	dbo.S_Usuario AS US
							ON US.IdUsuario = CCN.CreadoPor
						WHERE		SOL.IdSolicitudPedido = @IDSOLPED ;

						INSERT INTO #tempHistorial
							( Fecha, NombreEstado, IdOperacion, Descripcion )
						SELECT		CASE WHEN CCN.FechaEvaluacion IS NULL THEN CCN.CreadoEl ELSE CCN.FechaEvaluacion END, 'Evaluación Carta PCN', CCN.IdAceptacionCartaPCN AS IdSolPed ,
									CONCAT (
										'El Usuario ' , US.Nombre, ' Designó como ', TAE.Nombre, ' la Carta PCN ' ,
										'de la recepción de Servicio N°' , CCN.IdAceptacionPedido )
						FROM		dbo.MM_AceptacionCartaPCN AS CCN
						LEFT JOIN	MM_AceptacionPedido AS AP
							ON AP.IdAceptacionPedido = CCN.IdAceptacionPedido
						LEFT JOIN	dbo.MM_Pedido AS PED
							ON PED.IdPedido = AP.IdPedido
						LEFT JOIN	dbo.MM_SolicitudPedido AS SOL
							ON SOL.IdSolicitudPedido = PED.IdSolicitudPedido
						LEFT JOIN	dbo.S_Usuario AS US
							ON US.IdUsuario = CCN.IdUsuarioEvaluador
						LEFT JOIN	dbo.TA_Estatus AS TAE
							ON TAE.IdEstatus = CCN.IdEstatus
						WHERE
									SOL.IdSolicitudPedido = @IDSOLPED
									AND CCN.IdEstatus <> 1	---> SE AGREGO VALIDACIÓN DE CARTA DE CONTENIDO NACIONAL SEA APROBADA O RECHAZADA 30/05 DAC
					END

				DECLARE @TablaFactura TABLE	(Fila INT IDENTITY, IdFactura INT)
				DECLARE @FACTURA INT, @Contador INT = 1, @CantidadFact INT 
								
							INSERT INTO @TablaFactura
								( IdFactura )
							SELECT	AF.IdFactura
								FROM		MM_AceptacionFactura AS AF
								LEFT JOIN	MM_AceptacionPedido AS AP
									ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
								LEFT JOIN	dbo.MM_Pedido AS PED
									ON PED.IdPedido = AP.IdPedido
								LEFT JOIN	dbo.MM_SolicitudPedido AS SOL
									ON SOL.IdSolicitudPedido = PED.IdSolicitudPedido
								LEFT JOIN	dbo.TA_Operacion AS O
									ON O.IdDocumento = AF.IdAceptacionFactura
									   AND	O.IdTipoOperacion = 10
								WHERE		SOL.IdSolicitudPedido = @IDSOLPED
								AND AF.IdFactura IS NOT NULL
				---> SE AGREGO VALIDACIÓN PARA QUE EXISTA UNA APROBACIÓN DE FACTURA
				

				SELECT @CantidadFact = COUNT(1) FROM @TablaFactura
				WHILE(@Contador < @CantidadFact)
				BEGIN	
				SELECT @FACTURA = IdFactura FROM @TablaFactura WHERE Fila = @Contador
				
				IF ISNULL ( @FACTURA, 0 ) > 0
					BEGIN	
						INSERT INTO #tempHistorial
							( Fecha, NombreEstado, IdOperacion, Descripcion )
						SELECT		AF.CreadoEl, 'Aprobación de factura', AF.IdAceptacionPedido ,
									CONCAT (
										'Se Registró la tarea de aprobación de Factura, de la recepción de servicio N°' ,
										AF.IdAceptacionPedido )
						FROM		MM_AceptacionFactura AS AF
						LEFT JOIN	MM_AceptacionPedido AS AP
							ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
						LEFT JOIN	dbo.MM_Pedido AS PED
							ON PED.IdPedido = AP.IdPedido
						LEFT JOIN	dbo.MM_SolicitudPedido AS SOL
							ON SOL.IdSolicitudPedido = PED.IdSolicitudPedido
						WHERE		SOL.IdSolicitudPedido = @IDSOLPED

						INSERT INTO #tempHistorial
							( Fecha, NombreEstado, IdOperacion, Descripcion )
						SELECT		TH.Fecha, EF.NombreEstado, TAO.IdDocumento, TH.Descripcion
						FROM		TA_HistorialFlujoTarea AS TH
						INNER JOIN	TA_EstadoFlujoTarea AS EF
							ON EF.Idestado = TH.IdEstadoFlujo
						INNER JOIN	TA_Operacion AS TAO
							ON TAO.IdOperacion = TH.IdOperacion
						LEFT JOIN	dbo.MM_AceptacionFactura AS AF
							ON AF.IdAceptacionFactura = TAO.IdDocumento
						LEFT JOIN	MM_AceptacionPedido AS AP
							ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
						LEFT JOIN	dbo.MM_Pedido AS PED
							ON PED.IdPedido = AP.IdPedido
						LEFT JOIN	dbo.MM_SolicitudPedido AS SOL
							ON SOL.IdSolicitudPedido = PED.IdSolicitudPedido
						WHERE
									SOL.IdSolicitudPedido = @IDSOLPED
									AND TAO.IdTipoOperacion = 10
						ORDER BY	TH.IdHistorial ASC

						SET @Contador += 1
						SELECT @FACTURA = NULL
					END
					END

					DECLARE @TablaComprobanteExtranjero TABLE(Fila INT IDENTITY, IdComprobante INT)
					DECLARE @COMPROBANTE INT, @Contadorc INT = 1, @CantidadCompr INT 
								
							INSERT INTO @TablaComprobanteExtranjero
								( IdComprobante )
							SELECT	APC.IdPedimentoComprobante
								FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
								LEFT JOIN	MM_AceptacionPedido AS AP
									ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
								LEFT JOIN	dbo.MM_Pedido AS PED
									ON PED.IdPedido = AP.IdPedido
								LEFT JOIN	dbo.MM_SolicitudPedido AS SOL
									ON SOL.IdSolicitudPedido = PED.IdSolicitudPedido
								LEFT JOIN	dbo.TA_Operacion AS O
									ON O.IdDocumento = APC.IdPedimentoComprobante
									   AND	O.IdTipoOperacion = 16
								WHERE		SOL.IdSolicitudPedido = @IDSOLPED
								AND APC.IdPedimentoComprobante IS NOT NULL
								GROUP BY APC.IdPedimentoComprobante
				---> SE AGREGO VALIDACIÓN PARA QUE EXISTA UNA APROBACIÓN DE FACTURA
				

				SELECT @CantidadCompr = COUNT(IdComprobante) FROM @TablaComprobanteExtranjero
				--WHILE(@Contadorc < @CantidadCompr)
				--BEGIN	
				SELECT @COMPROBANTE = IdComprobante FROM @TablaComprobanteExtranjero WHERE Fila = @Contadorc
				
				IF ISNULL ( @CantidadCompr, 0 ) > 0
					BEGIN	
						INSERT INTO #tempHistorial
							( Fecha, NombreEstado, IdOperacion, Descripcion )
						SELECT		APC.CreadoEl, 'Aprobación de Pedimento/Comprobante Extranjero', APC.IdAceptacionPedido ,
									CONCAT (
										'Se Registró la tarea de aprobación de Pedimento/Comprobante Extranjero, de la recepción de servicio N°' ,
										APC.IdAceptacionPedido )
						FROM		FI_AceptacionPedido_PedimentoComprobante AS APC
						LEFT JOIN	MM_AceptacionPedido AS AP
							ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
						LEFT JOIN	dbo.MM_Pedido AS PED
							ON PED.IdPedido = AP.IdPedido
						LEFT JOIN	dbo.MM_SolicitudPedido AS SOL
							ON SOL.IdSolicitudPedido = PED.IdSolicitudPedido
						WHERE		SOL.IdSolicitudPedido = @IDSOLPED

						INSERT INTO #tempHistorial
							( Fecha, NombreEstado, IdOperacion, Descripcion )
						SELECT		TH.Fecha, EF.NombreEstado, TAO.IdDocumento, TH.Descripcion
						FROM		TA_HistorialFlujoTarea AS TH
						INNER JOIN	TA_EstadoFlujoTarea AS EF
							ON EF.Idestado = TH.IdEstadoFlujo
						INNER JOIN	TA_Operacion AS TAO
							ON TAO.IdOperacion = TH.IdOperacion
						LEFT JOIN dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
							ON APC.IdPedimentoComprobante = TAO.IdDocumento
						LEFT JOIN	MM_AceptacionPedido AS AP
							ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
						LEFT JOIN	dbo.MM_Pedido AS PED
							ON PED.IdPedido = AP.IdPedido
						LEFT JOIN	dbo.MM_SolicitudPedido AS SOL
							ON SOL.IdSolicitudPedido = PED.IdSolicitudPedido
						WHERE
									SOL.IdSolicitudPedido = @IDSOLPED
									AND TAO.IdTipoOperacion = 16
						ORDER BY	TH.IdHistorial ASC

						--SET @Contadorc += 1
						--SELECT @COMPROBANTE = NULL
					END
					--END
                    
				DECLARE @CANTRECFIN INT =
							(	SELECT	COUNT ( IdSolPedReciclada )
								FROM	dbo.TA_RecicajeSolPed
								WHERE	IdSolPedAnterior = @IDSOLPED ) ;

				IF @CANTRECFIN > 0
					BEGIN
						INSERT INTO #tempHistorial
							( Fecha, NombreEstado, IdOperacion, Descripcion )
						SELECT		SP.FechaAlta, 'Reciclaje de solicitud de pedido', RS.IdSolPedNueva ,
									CONCAT (
										'Se registró la solicitud de Pedido N° ' , RS.IdSolPedNueva ,
										', Reciclada de la solicitud de Pedido N°' , RS.IdSolPedAnterior )
						FROM		dbo.TA_RecicajeSolPed AS RS
						LEFT JOIN	dbo.MM_SolicitudPedido AS SP
							ON SP.IdSolicitudPedido = RS.IdSolPedNueva
						WHERE		RS.IdSolPedAnterior = @IDSOLPED ;
					END
			END

		SELECT *  FROM #tempHistorial  ORDER BY Fecha ASC ;
	END


