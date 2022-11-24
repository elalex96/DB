-- =============================================
-- Author:		Alexander Gomez
-- Create date: 09/09/2021
-- Description:	Creacion automatica de pedidos
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_WDEA_CotizacionAutomatico_WDEA]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT,
	@IdPeticionOferta INT,
	@Purchasing NVARCHAR(100),
	@IdOperadora INT,
	@IdContrato INT, 
	@IdBitacoraLectura INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IdOperacion INT,
		@MENSAJEFINAL NVARCHAR(1000),
		@IdPeticionOfertaDetalle INT, 
		@PrecioUnitario FLOAT,
		@Disponibilidad FLOAT, 
		@IdMoneda INT ,
		@ComentarioSubcontratista NVARCHAR (MAX), 
		@IdMaterialVendedor INT, 
		@FechaVigencia DATETIME = GETDATE(),
		@IdProveedorActual INT, 
		@NoCotizar BIT, 
		@IdEdicionCotizacion INT, 
		@IdEstatusEdicionCotizacion INT ,
		@IdUnidadVendedor INT, 
		@FechaEntrega DATETIME = (SELECT FechaEntregaRequerida FROM dbo.MM_SolicitudPedido WHERE IdSolicitudPedido = @IdSolicitudPedido),
		@IdUsuario INT = (SELECT TOP 1 IDUSUARIOSOLICITANTE FROM dbo.WDEA_PurchasingDocumentsImportados WHERE PURCHASING_DOCUMENT = @Purchasing AND IDCONTRATO = @IdContrato), 
		@FechaRegistro DATETIME,
		@IdCondicionPago INT,
		@DiasCredito INT,
		@CONT INT = 1,
		@CONTTOTAL INT,
		@RESPUESTACOTIZACION INT,
		@IdProveedor INT = (SELECT TOP 1 IDPROVEEDOR FROM dbo.WDEA_PurchasingDocumentsImportados WHERE PURCHASING_DOCUMENT = @Purchasing AND IDCONTRATO = @IdContrato);

	SELECT 
		ROW_NUMBER() over( order by SPD.IdSolicitudPedidoDetalle desc) as RN,
		SPD.IdSolicitudPedidoDetalle,
		SPD.NET_PRICE AS PrecioUnitario,
		SPD.Cantidad AS Disponibilidad,
		SPD.IDMONEDA_WS AS IdMoneda,
		'' AS ComentarioSubcontratista,
		SPD.IdMaterial AS IdMaterial,
		SPD.IdUnidad AS IdUnidad,
		CASE	
			WHEN SPD.TERMINOS_PAGO = 0 THEN 2
			ELSE 0
		END AS IdCondicionPago,
		SPD.TERMINOS_PAGO AS DiasCredito,
		POD.IdPeticionOfertaDetalle AS IdPeticionOfertaDetalle
	INTO #DETALLE_SOLPED
	FROM dbo.MM_SolicitudPedidoDetalle AS SPD
		JOIN dbo.MM_PeticionOfertaDetalle AS POD ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle 
	WHERE IdSolicitudPedido = @IdSolicitudPedido;

	SET @CONTTOTAL = (SELECT COUNT(RN) FROM #DETALLE_SOLPED);

	WHILE @CONT <= @CONTTOTAL
	BEGIN

	
		SELECT
			@IdPeticionOfertaDetalle = IdPeticionOfertaDetalle,
			@PrecioUnitario = PrecioUnitario,
			@Disponibilidad = Disponibilidad,
			@IdMoneda = IdMoneda,
			@ComentarioSubcontratista = ComentarioSubcontratista,
			@IdMaterialVendedor = IdMaterial,
			@IdUnidadVendedor = IdUnidad,
			@IdCondicionPago = IdCondicionPago,
			@DiasCredito = DiasCredito
		FROM #DETALLE_SOLPED
		WHERE RN = @CONT;

		EXEC SP_CO_ActualizarDetallePeticionMaterial_MV1_5 @IdPeticionOfertaDetalle,
															@PrecioUnitario,
															@Disponibilidad,
															@IdMoneda,
															@ComentarioSubcontratista,
															@IdMaterialVendedor,
															@IdPeticionOferta,
															@FechaVigencia,
															@IdOperadora,
															0,
															0,
															0,
															@IdUnidadVendedor,
															@FechaEntrega,
															@IdContrato,
															@IdUsuario,
															@FechaVigencia,
															@IdCondicionPago,
															@DiasCredito;

			SET @CONT = @CONT + 1;

	END


	SET @IdOperacion = (SELECT TOP 1 IdOperacion
						FROM  dbo.TA_Operacion 
						WHERE IdTipoOperacion = 6
						AND IdProveedor = @IdOperadora
						AND IdDocumento = @IdSolicitudPedido);


	UPDATE MM_PeticionOferta 
	SET Cotizado = 1,
		NoCotizar=0,
		FechaFinalizado = GETDATE(),
		IdEstatus = 2,
		ModificadoPor = @IdUsuario,
		AceptoTerminosCondiciones = 1,
		Verificable = 1
	WHERE IdPeticionOferta = @IdPeticionOferta;

	UPDATE  TA_Operacion 
			SET IdEstatusOperacion= 2,
			FechaModificacion = GETDATE()
	WHERE IdOperacion= @IdOperacion;


	EXEC SP_MM_PR_ImportarMaterialesCotizados @IdPeticionOferta,
												@IdProveedor,
												@IdUsuario;

	SET @RESPUESTACOTIZACION = (SELECT IdEstatusOperacion FROM TA_Operacion WHERE IdOperacion= @IdOperacion);

	IF @RESPUESTACOTIZACION = 2
	BEGIN

		--SE GAURDO EXITOSAMENTE LA COTIZACION
		SET @MENSAJEFINAL = 'PURCHASING_DOCUMENT ' + @Purchasing + ' PROCESADO EN PROCURA CON LA COTIZACIÓN DE LA SOLICITUD DE PEDIDO #' + CAST(@IdSolicitudPedido AS NVARCHAR) + ' CORRECTAMENTE';

		INSERT INTO WDEA_Bitacora_AdincoSAP
		(
			Fecha,
			Mensaje,
			NoConsecutivoProcesamiento,
			IdBitacoraLectura
		)
		VALUES
		(
			GETDATE(),
			@MENSAJEFINAL,
			NULL,
			@IdBitacoraLectura
		);

		--SE PROCEDE A REALIZAR LA CREACION DEL PEDIDO
		EXEC SP_MM_WDEA_NuevoPedidoAutomatico_SAP @IdSolicitudPedido,
													@IdPeticionOferta,
													@Purchasing,
													@IdOperadora,
													@IdContrato,
													@IdBitacoraLectura;

	END
	ELSE
	BEGIN

		--OCURRIO ALGUN ERROR EN LA INCERSION
		SET @MENSAJEFINAL = 'ERROR AL PROCESAR EL PURCHASING_DOCUMENT ' + @Purchasing + ' EN LA COTIZACIÓN DE PROCURA, FALTÓ DE PROCESAR EL PEDIDO.';


		INSERT INTO WDEA_Bitacora_AdincoSAP
		(
			Fecha,
			Mensaje,
			NoConsecutivoProcesamiento,
			IdBitacoraLectura
		)
		VALUES
		(
			GETDATE(),
			@MENSAJEFINAL,
			NULL,
			@IdBitacoraLectura
		);

	END
END