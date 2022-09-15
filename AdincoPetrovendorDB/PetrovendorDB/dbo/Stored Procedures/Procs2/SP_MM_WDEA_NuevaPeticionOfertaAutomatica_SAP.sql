USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_WDEA_NuevaPeticionOfertaAutomatica_SAP]    Script Date: 14/09/2022 10:47:38 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 09/09/2021
-- Description:	Generacion automatiza de solicitud oferta
-- =============================================
-- Author:		Luis David
-- Create date: 15/08/2022
-- Description:	Se corrigen los errores ortográficos para issue #1963 (Petrovendor)
-- =============================================
ALTER PROCEDURE [dbo].[SP_MM_WDEA_NuevaPeticionOfertaAutomatica_SAP]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT,
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
	DECLARE @IdProveedor INT,
		@IdPeticionOferta INT,
		@DescripcionH NVARCHAR(MAX),
        @IdOperacion INT,
		@IdFlujoTarea INT,
		@RESPUESTAPETICIONOFERTA INT,
		@RESPUESTAPETICIONOFERTADETALLE INT,
		@RESPUESTAOPERACION INT,
		@MENSAJEFINAL NVARCHAR(1000),
		@Solicitante INT;

	SELECT TOP 1
		@IdProveedor = IDPROVEEDOR,
		@Solicitante = IDUSUARIOSOLICITANTE
	FROM dbo.WDEA_PurchasingDocumentsImportados
	WHERE PURCHASING_DOCUMENT = @Purchasing AND IDCONTRATO = @IdContrato;

	SET @IdProveedor = (SELECT TOP 1 IDPROVEEDOR FROM WDEA_PurchasingDocumentsImportados WHERE PURCHASING_DOCUMENT = @Purchasing AND IDCONTRATO = @IdContrato);

	--CREACION DE LA PETICION OFERTA(COTIZACION)
	INSERT INTO dbo.MM_PeticionOferta
	(
		IdSolicitudPedido,
		IdSubcontratista,
		CreadoPor,
		CreadoEl,
		Activo,
		Visto,
		Iniciada,
		IdTipoProceso,
		CotizacionRestringida
	)
	VALUES
	(   
		@IdSolicitudPedido, 
		@IdProveedor, 
		@Solicitante, 
		GETDATE(), 
		1, 
		1, 
		1, 
		2, --MERCADEO
		0
	);

	SET @IdPeticionOferta = (SCOPE_IDENTITY());

	INSERT INTO MM_PeticionOfertaDetalle
	(
	  IdPeticionOferta,
	  IdSolicitudPedidoDetalle,
	  IdMaterial,
	  IdMaterialVendedor,
	  ComentariosComprador,
	  CreadoEl,
	  CreadoPor,
	  Activo,
	  NoMaterialesRequeridos,
	  IdProveedorVenta,
	  Cotizado,
	  IdUnidad,
	  IdUnidadProveedor,
	  DiasCreditoTemp
	)
	SELECT @IDPETICIONOFERTA,
		   IdSolicitudPedidoDetalle,
		   IdMaterial,
		   IdMaterial,
		   observaciones,
		   GETDATE(),
		   @Solicitante,
		   1,
		   Cantidad,
		   @IdProveedor,
		   0,
		   IdUnidad,
		   IdUnidad,
		   TERMINOS_PAGO
	FROM dbo.MM_SolicitudPedidoDetalle
	WHERE IdSolicitudPedido = @IdSolicitudPedido;

	--ACTUALIZAR EL TIPO DE PROCESO EN LA SOLICITUD DE PEDIDO
	UPDATE dbo.MM_SolicitudPedido
	SET IdTipoProceso = 2 --MERCADEO
	WHERE IdSolicitudPedido = @IdSolicitudPedido

	SET @IdOperacion =
					(   SELECT TOP 1
							   IdOperacion
						FROM dbo.TA_Operacion
						WHERE IdDocumento = @IdSolicitudPedido
							  AND IdTipoOperacion = 6
							  AND IdEstatusOperacion = 1
							  AND IdProveedor = @IdOperadora
							  AND IdAsignador = (SELECT TOP 1 IdUsuario FROM S_Usuario WHERE Correo = 'admin@adinco.mx' AND Activo = 1)
							  );

    IF ISNULL(@IdOperacion, 0) = 0
    BEGIN
        
        INSERT INTO dbo.TA_Operacion
        (
            IdDocumento,
            IdTipoOperacion,
            IdEstatusOperacion,
            IdProveedor,
            IdAsignador,
            FechaRegistro,
            Descripcion,
            IdVigencia,
            IdPrioridad
        )
        VALUES
        (
			@IdSolicitudPedido, 
			6, 
			1, 
			@IdOperadora, 
			@Solicitante, 
			GETDATE(), 
			'COTIZACIÓN AUTOMÁTICA',
			1,
			1
		 );

        SET @IdOperacion = (SCOPE_IDENTITY())

	END

	--ACTUALIZAR LA FECHA LIMITE A COTIZAR
    UPDATE TA_Operacion
    SET FechaFinalizacion = GETDATE()
    WHERE IdOperacion = @IdOperacion;

    --ACTUALIZAR ENVIO DE LA PETICION
    UPDATE [dbo].[MM_SolicitudPedido]
    SET [PeticionEnviada] = 1,
        JustificacionSolOferta = 'COTIZACIÓN AUTOMÁTICA'
    WHERE [IdSolicitudPedido] = @IdSolicitudPedido;

	INSERT INTO dbo.TA_TerminosCondicionesOperacion (IdOperacion, IdTerminosYCondiciones, TerminosCondicionesTexto)
    VALUES
    (   @IdOperacion,           -- IdOperacion - int
        (   SELECT TOP 1
                   IdTerminosYCondiciones
            FROM dbo.TC_TerminosYCondicionesDocV2
			WHERE IdProveedor = @IdOperadora), -- IdTerminosYCondiciones - int
        (   SELECT TOP 1
                   Documento
            FROM dbo.TC_TerminosYCondicionesDocV2
			WHERE IdProveedor = @IdOperadora)
	);
	

	--VALIDACION PARA LA CANTIDAD DE DATOS INSERTADOS
	--INSERCION EN MM_PeticionOferta
	SET @RESPUESTAPETICIONOFERTA = (SELECT COUNT(1) FROM MM_PeticionOferta WHERE IdSolicitudPedido = @IdSolicitudPedido);
	--INSERCION EN MM_PeticionOfertaDetalle
	SET @RESPUESTAPETICIONOFERTADETALLE = (SELECT COUNT(1) FROM MM_PeticionOfertaDetalle WHERE IdPeticionOferta = @IdPeticionOferta);
	--INSERCION EN TA_Operacion
	SET @RESPUESTAOPERACION = (SELECT COUNT(1) FROM TA_Operacion WHERE IdOperacion = @IdOperacion);


	IF @RESPUESTAPETICIONOFERTA > 0 AND 
		@RESPUESTAPETICIONOFERTADETALLE > 0 AND 
		@RESPUESTAOPERACION > 0
	BEGIN 
			
			--SE GAURDO EXITOSAMENTE LA SOLPED
		SET @MENSAJEFINAL = 'PURCHASING_DOCUMENT ' + @Purchasing + ' PROCESADO EN PROCURA CON LA PETICIÓN OFERTA DE LA SOLICITUD DE PEDIDO #' + CAST(@IdSolicitudPedido AS NVARCHAR) + ' CORRECTAMENTE';

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

		--SE EJECUTA LA COTIZACION AUTOMATICA
		EXEC SP_MM_WDEA_CotizacionAutomatico_WDEA @IdSolicitudPedido,
												@IdPeticionOferta,
												@Purchasing,
												@IdOperadora,
												@IdContrato, 
												@IdBitacoraLectura;

	END
	ELSE
	BEGIN 

		--OCURRIO ALGUN ERROR EN LA INCERSION
		SET @MENSAJEFINAL = 'ERROR AL PROCESAR EL PURCHASING_DOCUMENT ' + @Purchasing + ' EN LA PETICIÓN OFERTA DE PROCURA, FALTÓ DE PROCESAR LA COTIZACIÓN Y EL PEDIDO.';

		IF @RESPUESTAPETICIONOFERTA = 0
		BEGIN

			SET @MENSAJEFINAL = @MENSAJEFINAL + ', ERROR AL REGISTRAR EN MM_PeticionOferta'

		END

		IF @RESPUESTAPETICIONOFERTADETALLE = 0
		BEGIN

			SET @MENSAJEFINAL = @MENSAJEFINAL + ', ERROR AL REGISTRAR EN MM_PeticionOfertaDetalle'

		END

		IF @RESPUESTAOPERACION = 0
		BEGIN

			SET @MENSAJEFINAL = @MENSAJEFINAL + ', ERROR AL REGISTRAR EN TA_Operacion'

		END

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