USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_WDEA_NuevoPedidoAutomatico_SAP]    Script Date: 27/07/2022 12:26:55 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
DROP PROCEDURE IF EXISTS SP_MM_WDEA_NuevoPedidoAutomatico_SAP
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 09/09/2021
-- Description:	Creacion de pedido automatica
-- =============================================
-- Author:		Luis David
-- Create date: 04/10/2022
-- Description:	Se obtiene el tipo de pedido a partir de la columna PrefijoSAP
-- =============================================
-- Author:		Luis David
-- Create date: 10/10/2022
-- Description:	Se cambia la aprobación a "Aprobado"
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_WDEA_NuevoPedidoAutomatico_SAP] --26383,18030,'4500564101',907,10038,1318
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
	DECLARE @IdProveedor INT = (SELECT TOP 1 IDPROVEEDOR FROM dbo.WDEA_PurchasingDocumentsImportados WHERE PURCHASING_DOCUMENT = @Purchasing AND IDCONTRATO = @IdContrato),
		--@IdContrato INT = (SELECT IdContrato FROM dbo.MM_SolicitudPedido WHERE IdSolicitudPedido = @IdSolicitudPedido), 
		@idTipoPedidoP int = (SELECT TOP 1 ISNULL(TP.IdTipoPedido,2) FROM 
								dbo.WDEA_PurchasingDocumentsImportados PDI
								LEFT JOIN MM_TipoPedido TP
								on LTRIM(RTRIM(PDI.MECANISMO_CONTRATACION)) = LTRIM(RTRIM(TP.PrefijoSAP))
								WHERE PDI.PURCHASING_DOCUMENT = @Purchasing AND PDI.IDCONTRATO = @IdContrato),
		@IdUsuario INT = (SELECT TOP 1 IDUSUARIOSOLICITANTE FROM dbo.WDEA_PurchasingDocumentsImportados WHERE PURCHASING_DOCUMENT = @Purchasing AND IDCONTRATO = @IdContrato),
		@FechaEntrega DATETIME = (SELECT FechaEntregaRequerida FROM dbo.MM_SolicitudPedido WHERE IdSolicitudPedido = @IdSolicitudPedido),
		@COUNT_PROVEEDORES INT,
		@IdFlujoTarea INT,
		@TipoCambio FLOAT,
		@ValorDivision FLOAT,
		@TotalSumaPedidos FLOAT,
		@ID_MONEDA_ACTUAL INT,
		@INCREMENTO INT,
		@IdPeticionOfertaActual INT,
		@IdPedidoActual INT,
		@CONTTOTAL INT,
		@CONT INT = 1,
		@IdPeticionOfertaDetalle INT,
		@PrecioUnitario FLOAT,
		@Disponibilidad FLOAT,
		@IdMoneda INT,
		@ComentarioSubcontratista NVARCHAR(100),
		@IdMaterialVendedor INT,
		@IdUnidadVendedor INT,
		@IdCondicionPago INT,
		@DiasCredito INT,
		@IdOperacion INT,
		@FECHA_ACTUAL DATETIME,
		@FECHA_TIPO_CONVERSION_ACTUAL DATETIME,
		@TIPO_CAMBIO_ACTUAL DECIMAL(12, 4),
		@SumaPedidoProveedor FLOAT,
		@suma FLOAT,
		@IdPedidoGeneral INT,
		@IdMonedaDLS INT = 2,
		@RESPONSEPEDIDO INT,
		@RESPONSEPEDIDODETALLE INT,
		@MENSAJEFINAL NVARCHAR(1000),
		@CANT_TERMINOS_PAGO INT;


CREATE TABLE #TABLA_PROVEEDORES
(
	idrow INT,
    idProveedor INT,
    sumaPedido FLOAT,
    idflujo INT,
    idTipoMoneda INT,
    idPeticionOferta INT
);

CREATE TABLE #TIPO_CAMBIO
    (
        TipoCambio DECIMAL(12, 4),
        Fecha DATETIME,
        IdMoneda INT
    );

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

	SET @CONTTOTAL = (SELECT COUNT(1) FROM #DETALLE_SOLPED);

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

		EXEC SP_MM_ActualizarListaPedidoTemp @IdPeticionOfertaDetalle,
											1,
											@Disponibilidad,
											@IdOperadora,
											@IdUsuario;

		SET @CONT = @CONT + 1;

	END

	 -- Obtener los datos del Peticion Oferta para pasarlos a las Pedido e identificar  --- 
    INSERT INTO #TABLA_PROVEEDORES
    (
        idrow,
        idProveedor,
        sumaPedido,
        idTipoMoneda,
        idPeticionOferta
    )
    SELECT ROW_NUMBER() OVER (ORDER BY PO.IdSubcontratista ASC) AS Row#,
           PO.IdSubcontratista,
           SUM(POD.PrecioUnitario * POD.AddCantidadTemp),
           POD.IdMoneda,
           POD.IdPeticionOferta
    FROM MM_PeticionOferta AS PO
        INNER JOIN MM_PeticionOfertaDetalle AS POD (NOLOCK)
            ON PO.IdPeticionOferta = POD.IdPeticionOferta
        INNER JOIN MM_SolicitudPedido AS SP (NOLOCK)
            ON PO.IdSolicitudPedido = SP.IdSolicitudPedido 
        INNER JOIN MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
            ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
    WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
          AND POD.AddValidado = 1
          AND POD.Cotizado = 1
          AND POD.AddPedidoTemp = 1
    GROUP BY PO.IdSubcontratista,
             POD.IdMoneda,
             POD.IdPeticionOferta;

		SET @IdPeticionOfertaActual = (@IdPeticionOferta);

        SET @ID_MONEDA_ACTUAL = ( SELECT TOP 1 idTipoMoneda FROM #TABLA_PROVEEDORES);


        SET @SumaPedidoProveedor = (SELECT TOP 1 sumaPedido FROM #TABLA_PROVEEDORES);

        DELETE #TIPO_CAMBIO;

        INSERT INTO #TIPO_CAMBIO
        SELECT *
        FROM dbo.GetTipoCambioActual(@ID_MONEDA_ACTUAL, GETDATE());

        SET @TipoCambio = (
                                        SELECT TOP 1 TC.TipoCambio
                                        FROM #TABLA_PROVEEDORES AS TP
                                            LEFT JOIN #TIPO_CAMBIO AS TC
                                                ON TC.IdMoneda = TP.idTipoMoneda
                                    );

        SET @ValorDivision = (
                                           SELECT TOP 1 TP.sumaPedido
                                           FROM #TABLA_PROVEEDORES AS TP
                                               LEFT JOIN #TIPO_CAMBIO AS TC
                                                   ON TC.IdMoneda = TP.idTipoMoneda
                                       );

        SET @suma =
        (
            SELECT TOP 1 CASE
                       WHEN TP.idTipoMoneda <> @IdMonedaDLS THEN
                           ISNULL((TP.sumaPedido / TC.TipoCambio), 0)
                       ELSE
                           TP.sumaPedido
                   END
            FROM #TABLA_PROVEEDORES AS TP
                LEFT JOIN #TIPO_CAMBIO AS TC
                    ON TC.IdMoneda = TP.idTipoMoneda
        );

        SET @TotalSumaPedidos = ISNULL(@TotalSumaPedidos, 0) + @suma;


        --#AGREGAR  Al pedido 
        INSERT INTO MM_Pedido
        (
            IdPeticionOferta,
            Comentarios,
            IdSolicitudPedido,
            IdSubcontratista,
            IdContrato,
            Editado,
            CreadoEl,
            CreadoPor,
            IdProveedorCompras,
            Version,
            IdMoneda,
			NoCartaCN,
			UnicaCondicionPago,
			FechaEntregaPedido,
			FechaEnvioPedido
        )
        SELECT PO.IdPeticionOferta,
               '',
               SP.IdSolicitudPedido,
               PO.IdSubcontratista,
               SP.IdContrato,
               0 AS editado,
               GETDATE(),
               @IdUsuario,
               @IdOperadora,
               1,
               POD.IdMoneda,
			   1,
			   1,
			   @FechaEntrega,
			   GETDATE()
        FROM MM_PeticionOferta AS PO (NOLOCK)
            INNER JOIN MM_PeticionOfertaDetalle AS POD (NOLOCK)
                ON PO.IdPeticionOferta = POD.IdPeticionOferta
            INNER JOIN MM_SolicitudPedido AS SP (NOLOCK)
                ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
            INNER JOIN MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
                ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
        WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
              AND PO.IdSubcontratista = @IdProveedor
              AND POD.AddValidado = 1
              AND POD.Cotizado = 1
              AND POD.AddPedidoTemp = 1
              AND PO.IdPeticionOferta = @IdPeticionOferta
        GROUP BY PO.IdPeticionOferta,
                 SP.IdSolicitudPedido,
                 PO.IdSubcontratista,
                 SP.IdContrato,
				 POD.IdMoneda;

        SELECT @IdPedidoActual = @@IDENTITY;

        ---#Agregar al pedido detalle
        INSERT INTO MM_PedidoDetalle
        (
            IdPedido,
            IdMaterial,
            IdMaterialVendedor,
            IdPeticionOfertaDetalle,
            PrecioUnitario,
            Cantidad,
            IdMoneda,
            Subtotal,
            Activo,
            ComentariosCompras,
            CreadoPor,
            CreadoEl,
            IdUnidad,
            IdUnidadProveedor,
			IdCondicionPago,
			DiasCredito
        )
        SELECT @IdPedidoActual AS IdPedido,
               POD.IdMaterial,
               POD.IdMaterialVendedor,
               POD.IdPeticionOfertaDetalle,
               POD.PrecioUnitario,
               POD.AddCantidadTemp,
               POD.IdMoneda,
               POD.AddSubTotalTemp,
               1,
               '',
               @IdUsuario AS CreadoPor,
               GETDATE() AS CreadoEl,
               POD.IdUnidad,
               POD.IdUnidadProveedor,
			   CASE 
					WHEN POD.DiasCredito = 0 THEN 2
					ELSE 1
				END,
			   POD.DiasCredito 
        FROM MM_PeticionOferta AS PO (NOLOCK)
            INNER JOIN MM_PeticionOfertaDetalle AS POD (NOLOCK)
                ON PO.IdPeticionOferta = POD.IdPeticionOferta
            INNER JOIN MM_SolicitudPedido AS SP (NOLOCK)
                ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
            INNER JOIN MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
                ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
        WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
              AND PO.IdSubcontratista = @IdProveedor
              AND POD.AddValidado = 1
              AND POD.Cotizado = 1
              AND POD.AddPedidoTemp = 1
              AND PO.IdPeticionOferta = @IdPeticionOferta;

		
		SET @CANT_TERMINOS_PAGO = (SELECT TOP 1 IdCondicionPago FROM MM_PedidoDetalle WHERE IdPedido = @IdPedidoActual);

		UPDATE MM_Pedido
		SET UnicaCondicionPago = @CANT_TERMINOS_PAGO
		WHERE IdPedido = @IdPedidoActual;

		INSERT INTO dbo.MM_HorasVigenciaPedido
        (
            IdPedido,
            HorasVigencia,
            FechaVigencia
        )
        VALUES
        (   @IdPedidoActual, -- IdPedido - int
            24,  -- HorasVigencia - int
            GETDATE()             -- FechaCreacionPedido - smalldatetime
        );
        --#Almacenar historial del tipo de cambio de la modeda actual 
		
        SET @FECHA_TIPO_CONVERSION_ACTUAL =
        (
            SELECT Fecha FROM #TIPO_CAMBIO
        );
		
        SET @TIPO_CAMBIO_ACTUAL = (SELECT TipoCambio FROM #TIPO_CAMBIO);

        INSERT INTO dbo.MM_PedidoTipoCambio
        (
            IdPedido,
            IdTipoMoneda,
            FechaTipoCambio,
            TipoCambio
        )
        VALUES
        (   @IdPedidoActual,               -- IdPedido - int
            @ID_MONEDA_ACTUAL,             -- IdTipoMoneda - int
            @FECHA_TIPO_CONVERSION_ACTUAL, -- FechaTipoCambio - datetime
            @TIPO_CAMBIO_ACTUAL            -- TipoCambio - decimal(12, 4)
        );

        --#Generar el IdPedidoGeneral   
        SET @FECHA_ACTUAL = (SELECT GETDATE());
		
		SET @idTipoPedidoP = ISNULL(@idTipoPedidoP,2);
        EXEC dbo.SP_MM_GenerarIdPedidoGeneral @IdTipoPedido = @idTipoPedidoP,                        -- int 2 = MERCADEO
                                              @IdPrimaryKey = @IdPedidoActual,          -- int
                                              @CreadoPor = @IdUsuario,           -- int
                                              @CreadoEl = @FECHA_ACTUAL,                -- datetime
                                              @IdProveedorActual = @IdOperadora, -- int
                                              @IdPedidoGeneral = @IdPedidoGeneral OUTPUT;

		


		--BUSQUEDA DEL FLUJO DEFAULT DE APROBACION AUTOMATICA
	SET @IdFlujoTarea = (SELECT TOP 1 IdFlujoTarea FROM TA_FlujoTarea WHERE Nombre = 'FLUJO APROBACION AUTOMATICA - PEDIDO');

	IF ISNULL(@IdFlujoTarea,0) = 0
	BEGIN

		--CREACION DE UN NUEVO FLUJO AUTOMATICO
		INSERT INTO TA_FlujoTarea
		(
			Nombre,
			Descripcion,
			IdTipoFlujo,
			IdTipoOperacion,
			Condicion,
			FechaCreacion,
			CreadorPor,
			IdProveedor,
			Activo,
			Eliminado
		)
		VALUES
		(
			'FLUJO APROBACION AUTOMATICA - PEDIDO',
			'FLUJO APROBACION AUTOMATICA - PEDIDO',
			1,
			9,
			0,
			GETDATE(),
			@IdUsuario,
			@IdOperadora,
			1,
			0
		);

		SET @IdFlujoTarea = (SCOPE_IDENTITY());

		--CREACION DE LOS APROBADORES PARA EL FLUJO (SOLO 1)
		INSERT INTO TA_Aprobador
		(
			IdFlujoTarea,
			IdUsuario,
			NoSecuencia
		)
		VALUES
		(
			@IdFlujoTarea,
			@IdUsuario,
			1
		);

	END
	--CREACION DE LA OPERACION PARA LA APROBACION DE LA SOLPED
	INSERT INTO TA_Operacion
	(
		IdDocumento,
		IdTipoOperacion,
		IdFlujoTarea,
		IdEstatusOperacion,
		IdEstadoFlujo,
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
		9,--APROBACION DE SOLICITUD DE PEDIDO
		@IdFlujoTarea,
		2,--APROBADA
		3,--TAREA APROBADA
		@IdOperadora,
		@IdUsuario,
		GETDATE(),
		'FLUJO APROBACION AUTOMATICA - PEDIDO',
		1,
		2
	);

	SET @IdOperacion = (SCOPE_IDENTITY());

	INSERT INTO WDEA_PedidosPendientesCorreosConfirmacion
	(IdSolicitudPedido,		IdOperacion,	IdAprobador,	Procesado,	CreadoEl ) VALUES
	(@IdSolicitudPedido,	@IdOperacion,	@IdUsuario,		0,			GETDATE())

	--CREACION DE LAS TAREAS
	INSERT INTO TA_Tarea
	(
		NombreTarea,
		FechaRegistro,
		IdEstatus,
		Activo, 
		IdAprobador,
		NoSecuencia,
		IdOperacion,
		Comentario,
		FechaCambioEstatus
	)
	VALUES
	(
		'Aprobación de Pedido',
		GETDATE(),
		2,--APROBADA
		1,
		@IdUsuario,
		1,
		@IdOperacion,
		'APROBACION AUTOMATICA - PEDIDO',
		GETDATE()
	);

	INSERT INTO TA_TareaOperacion
	(
		IdTarea,
		IdOperacion
	)
	SELECT
		IdTarea,
		IdOperacion
	FROM TA_Tarea
	WHERE IdOperacion = @IdOperacion;

	 --#REMOVER TODOS LAS CANTIDADADES DEL TEMPORAL ADD PEDIDO
        --tener cuidado cuando son dos monedas
        UPDATE POD
        SET POD.AddPedidoTemp = 0,
            POD.AddCantidadTemp = 0,
            POD.AddSubTotalTemp = 0,
            POD.AddPedidoFinal = 0,
			POD.IdCondicionPagoTemp= NULL, -->NUEVO DIAS DE CREDITO
			POD.DiasCreditoTemp=NULL -->NUEVO DIAS DE CREDITO
        FROM MM_PeticionOfertaDetalle AS POD (NOLOCK)
            INNER JOIN MM_PeticionOferta AS PO (NOLOCK)
                ON POD.IdPeticionOferta = PO.IdPeticionOferta
            INNER JOIN MM_SolicitudPedido AS SP (NOLOCK)
                ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            INNER JOIN MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
                ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
        WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
              AND POD.AddValidado = 1
              AND POD.Cotizado = 1
              AND POD.AddPedidoTemp = 1
              AND PO.IdPeticionOferta = @IdPeticionOferta;

		--CONFIRMACION POR PARTE DEL PROVEEDOR
		--UPDATE MM_PedidoDetalle
		--   SET RecepcionPedido = 1, 
		--   FechaRecepcionPedido = GETDATE(),
		--   IdUsuarioRecepcionServicio = @IdUsuario
		--WHERE IdPedido = @IdPedidoActual;

		--UPDATE MM_Pedido
	 --  SET RecepcionServicio = 1, 
	 --  FechaRecepcionServicio = GETDATE(),
	 --  IdUsuarioRecepcionServicio = @IdUsuario
	 --  WHERE IdPedido = @IdPedidoActual;

		SET @RESPONSEPEDIDO = (SELECT COUNT(IdPedido) FROM MM_Pedido WHERE IdPedido = @IdPedidoActual);


		IF ISNULL(@RESPONSEPEDIDO,0) > 0
		BEGIN

			UPDATE WDEA_PurchasingDocumentsImportados
			SET IdPedidoADINCO = @IdPedidoActual
			WHERE IDCONTRATO = @IdContrato AND PURCHASING_DOCUMENT = @Purchasing;

			UPDATE PendientesProcesarProcura_WSDEA
			SET Procesado = 1
			WHERE IdBitacora = @IdBitacoraLectura;

			SET @MENSAJEFINAL = 'PURCHASING_DOCUMENT ' + @Purchasing + ' PROCESADO EN PROCURA CON EL PEDIDO #' + CAST(@IdPedidoActual AS NVARCHAR) + ' DE LA SOLICITUD DE PEDIDO #' + CAST(@IdSolicitudPedido AS NVARCHAR) + ' CORRECTAMENTE';

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
		ELSE
		BEGIN

			--OCURRIO ALGUN ERROR EN LA INCERSION
			SET @MENSAJEFINAL = 'ERROR AL PROCESAR EL PURCHASING_DOCUMENT ' + @Purchasing + ' EN EL PEDIDO DE PROCURA';


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
