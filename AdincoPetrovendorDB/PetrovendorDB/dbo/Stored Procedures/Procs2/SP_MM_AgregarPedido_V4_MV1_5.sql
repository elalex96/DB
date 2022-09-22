USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_AgregarPedido_V4_MV1_5]    Script Date: 22/09/2022 11:01:46 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 09/07/2018
-- Description:	ahora la aprobacion es por cada pedido y no una aprobacion para todos los pedidos generados
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 17-10-2019
-- Description:	se quita la funcionalidad de la carta de contenido ya que se pasa a la aceptacion de servicio
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: 25-10-2019
-- Description:	Se agrega personalización de días de crédito por detalle 
-- =============================================

ALTER PROCEDURE [dbo].[SP_MM_AgregarPedido_V4_MV1_5]
    @IdSolicitudPedido INT,
    @Mensaje NVARCHAR(MAX),
    @IdPrioridad INT,
    @IdVigencia INT,
    @IdUsuarioCompras INT,
    @IdProveedorCompras INT,
    @HorasVigencia INT = 24,
    @NoCartaCN BIT = NULL,
	@DiasCredito INT = NULL,
	@UnicaCondicionPago BIT = NULL,
	@IdCondicionPago INT = NULL,
	@FechaEntregaPedido DATETIME, 
    /*--------------------parametros contrato--------------------*/
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME
/*-----------------------------------------------------------*/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @COUNT_PROVEEDORES INT;
    DECLARE @INCREMENTO INT = 1;
    DECLARE @IdPedidoActual INT;
    DECLARE @IdFlujo INT = 0;
    DECLARE @IdOperacionActual INT;
    DECLARE @IdTipoOperacion INT = 9; ---Aprobación de pedido
    DECLARE @TotalSumaPedidos FLOAT;
    DECLARE @VERSION INT;
    DECLARE @IdMonedaDLS INT = 2;

    DECLARE @tablaFlujos TABLE
    (
        Fila INT,
        IdFlujoTarea INT,
        ValorInicial FLOAT,
        ValorFinal FLOAT,
        Predeterminado INT,
        Nombre NVARCHAR(MAX),
        Orden FLOAT
    );

    CREATE TABLE #TABLA_PROVEEDORES
    (
        idrow INT,
        idProveedor INT,
        sumaPedido FLOAT,
        idflujo INT,
        idTipoMoneda INT,
        idPeticionOferta INT
    );

    CREATE TABLE #APROBADORES_PEDIDOS
    (
        row_group_pedido INT,
        version_pedido INT,
        id_usuario INT,
        numero_secuencia INT,
        nombre_aprobador NVARCHAR(MAX),
        correo_aprobador NVARCHAR(MAX),
        id_tipo_flujo INT,
        id_operacion INT,
        id_proveedor_compras INT,
        IdFlujo INT,
        TotalEnDls FLOAT,
        NombreFlujo NVARCHAR(MAX),
        MonedaActual INT,
        SumaTotalProveedor FLOAT,
        TipoCambio FLOAT,
        ValorADividir FLOAT,
        Telefono NVARCHAR(100)
    );

    CREATE TABLE #TIPO_CAMBIO
    (
        TipoCambio DECIMAL(12, 4),
        Fecha DATETIME,
        IdMoneda INT
    );

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
        INNER JOIN MM_PeticionOfertaDetalle AS POD
            ON POD.IdPeticionOferta = PO.IdPeticionOferta
        INNER JOIN MM_SolicitudPedido AS SP
            ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
        INNER JOIN MM_SolicitudPedidoDetalle AS SPD
            ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
    WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
          AND POD.AddValidado = 1
          AND POD.Cotizado = 1
          AND POD.AddPedidoTemp = 1
    GROUP BY PO.IdSubcontratista,
             POD.IdMoneda,
             POD.IdPeticionOferta

    --cuantos pedidos se van a realizar y ta_operaciones a realizar (aprobaciones)
    SET @COUNT_PROVEEDORES =
    (
        SELECT COUNT(idrow) FROM #TABLA_PROVEEDORES
    );

    --variables donde se lleva el total de cada pedido 
    DECLARE @suma FLOAT;
    DECLARE @sumacadena NVARCHAR(MAX);

    SET @INCREMENTO = 1;

    WHILE @COUNT_PROVEEDORES >= @INCREMENTO
    BEGIN

        --Se genera una version por cada TA_operacion para relacionarlo con el pedido
        --- OBTENER LA VERSION DE PEDIDO A REALIZAR
        SET @VERSION =
        (
            SELECT TOP 1
                P.Version
            FROM MM_Pedido AS P
            WHERE IdSolicitudPedido = @IdSolicitudPedido
            ORDER BY Version DESC
        );
        SET @VERSION = ISNULL(@VERSION, 0) + 1;

        --#Obtener el IdMoneda la peticion oferta, el total del pedido del proveedor actual 

        DECLARE @IdPeticionOfertaActual INT
            =   (
                    SELECT idPeticionOferta FROM #TABLA_PROVEEDORES WHERE idrow = @INCREMENTO
                );

        DECLARE @ID_MONEDA_ACTUAL INT = (
                                            SELECT idTipoMoneda FROM #TABLA_PROVEEDORES WHERE idrow = @INCREMENTO
                                        );

        DECLARE @SumaPedidoProveedor FLOAT = (
                                                 SELECT sumaPedido FROM #TABLA_PROVEEDORES WHERE idrow = @INCREMENTO
                                             );

        DECLARE @FECHA_TIPO_CONVERSION_ACTUAL DATETIME;

        DELETE #TIPO_CAMBIO;

        INSERT INTO #TIPO_CAMBIO
        SELECT *
        FROM dbo.GetTipoCambioActual(@ID_MONEDA_ACTUAL, GETDATE());

        DECLARE @TipoCambio FLOAT = (
                                        SELECT TC.TipoCambio
                                        FROM #TABLA_PROVEEDORES AS TP
                                            LEFT JOIN #TIPO_CAMBIO AS TC
                                                ON TC.IdMoneda = TP.idTipoMoneda
                                        WHERE idrow = @INCREMENTO
                                    );

        DECLARE @ValorDivision FLOAT = (
                                           SELECT TP.sumaPedido
                                           FROM #TABLA_PROVEEDORES AS TP
                                               LEFT JOIN #TIPO_CAMBIO AS TC
                                                   ON TC.IdMoneda = TP.idTipoMoneda
                                           WHERE idrow = @INCREMENTO
                                       );

        SET @suma =
        (
            SELECT CASE
                       WHEN TP.idTipoMoneda <> @IdMonedaDLS THEN
                           ISNULL((TP.sumaPedido / TC.TipoCambio), 0)
                       ELSE
                           TP.sumaPedido
                   END
            FROM #TABLA_PROVEEDORES AS TP
                LEFT JOIN #TIPO_CAMBIO AS TC
                    ON TC.IdMoneda = TP.idTipoMoneda
            WHERE idrow = @INCREMENTO
        );

        SET @TotalSumaPedidos = ISNULL(@TotalSumaPedidos, 0) + @suma;

        DECLARE @ID_PROVEEDOR_VENTAS INT = (
                                               SELECT idProveedor FROM #TABLA_PROVEEDORES WHERE idrow = @INCREMENTO
                                           );

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
			FechaEntregaPedido 
        )
        SELECT PO.IdPeticionOferta,
               '',
               SP.IdSolicitudPedido,
               PO.IdSubcontratista,
               SP.IdContrato,
               0 AS editado,
               GETDATE(),
               @IdUsuarioCompras,
               @IdProveedorCompras,
               @VERSION,
               @ID_MONEDA_ACTUAL,
			   @NoCartaCN,
			   @UnicaCondicionPago,
			   @FechaEntregaPedido
        FROM MM_PeticionOferta AS PO
            INNER JOIN MM_PeticionOfertaDetalle AS POD
                ON POD.IdPeticionOferta = PO.IdPeticionOferta
            INNER JOIN MM_SolicitudPedido AS SP
                ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            INNER JOIN MM_SolicitudPedidoDetalle AS SPD
                ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
        WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
              AND PO.IdSubcontratista = @ID_PROVEEDOR_VENTAS
              AND POD.AddValidado = 1
              AND POD.Cotizado = 1
              AND POD.AddPedidoTemp = 1
              AND PO.IdPeticionOferta = @IdPeticionOfertaActual
              AND POD.IdMoneda = @ID_MONEDA_ACTUAL
        GROUP BY PO.IdPeticionOferta,
                 SP.IdSolicitudPedido,
                 PO.IdSubcontratista,
                 SP.IdContrato;

        SELECT @IdPedidoActual = SCOPE_IDENTITY();

        INSERT INTO dbo.MM_HorasVigenciaPedido
        (
            IdPedido,
            HorasVigencia,
            FechaVigencia
        )
        VALUES
        (   @IdPedidoActual, -- IdPedido - int
            @HorasVigencia,  -- HorasVigencia - int
            NULL             -- FechaCreacionPedido - smalldatetime
        );

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
               @IdUsuarioCompras AS CreadoPor,
               GETDATE() AS CreadoEl,
               POD.IdUnidad,
               POD.IdUnidadProveedor,
			   CASE WHEN ISNULL(@UnicaCondicionPago,0) = 1 THEN ---> SI ES UNICO DIAS DE CREDITO PARA TODAS LAS PARTIDAS SE AGREGA EL IDCONDICION DE PAGO ENCABEZADO 
			    @IdCondicionPago
				ELSE
                POD.IdCondicionPagoTemp
				END,
				CASE WHEN  ISNULL(@UnicaCondicionPago,0)= 1 THEN  ---> SI ES UNICO DIAS DE CREDITO PARA TODAS LAS PARTIDAS SE AGREGA EL DIASCREDITO DE PAGO ENCABEZADO 
				@DiasCredito
				ELSE 
				POD.DiasCreditoTemp
				END 
        FROM MM_PeticionOferta AS PO
            INNER JOIN MM_PeticionOfertaDetalle AS POD
                ON POD.IdPeticionOferta = PO.IdPeticionOferta
            INNER JOIN MM_SolicitudPedido AS SP
                ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            INNER JOIN MM_SolicitudPedidoDetalle AS SPD
                ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
        WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
              AND PO.IdSubcontratista = @ID_PROVEEDOR_VENTAS
              AND POD.AddValidado = 1
              AND POD.Cotizado = 1
              AND POD.AddPedidoTemp = 1
              AND PO.IdPeticionOferta = @IdPeticionOfertaActual
              AND POD.IdMoneda = @ID_MONEDA_ACTUAL;

        --#Almacenar historial del tipo de cambio de la modeda actual 
		
        SET @FECHA_TIPO_CONVERSION_ACTUAL =
        (
            SELECT Fecha FROM #TIPO_CAMBIO
        );
		
        DECLARE @TIPO_CAMBIO_ACTUAL DECIMAL(12, 4) = (
                                                         SELECT TipoCambio FROM #TIPO_CAMBIO
                                                     );

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
        DECLARE @IdPedidoGeneral INT;
        DECLARE @FECHA_ACTUAL DATETIME = (
                                             SELECT GETDATE()
                                         );
		
        EXEC dbo.SP_MM_GenerarIdPedidoGeneral @IdTipoPedido = 2,                        -- int 2 = MERCADEO
                                              @IdPrimaryKey = @IdPedidoActual,          -- int
                                              @CreadoPor = @IdUsuarioCompras,           -- int
                                              @CreadoEl = @FECHA_ACTUAL,                -- datetime
                                              @IdProveedorActual = @IdProveedorCompras, -- int
                                              @IdPedidoGeneral = @IdPedidoGeneral OUTPUT;

        -- int
		
        --Asignar el flujo correspondiente al monto

        INSERT INTO @tablaFlujos
        EXEC dbo.SP_ObtenerFlujoAprobacionxValor @Total = @TotalSumaPedidos,                -- float
                                                 @IdProveedorCompras = @IdProveedorCompras; -- int
        SELECT @IdFlujo = IdFlujoTarea
        FROM @tablaFlujos
        WHERE Fila = 1;


        --- REALIZAR REGISTRO DE OPERACION DE APROBACION 
        INSERT INTO TA_Operacion
        (
            IdDocumento,
            IdTipoOperacion,
            IdFlujoTarea,
            IdEstadoFlujo,
            IdEstatusOperacion,
            IdProveedor,
            IdAsignador,
            FechaRegistro,
            Descripcion,
            IdVigencia,
            IdPrioridad,
            NoVersion
        )
        VALUES
        (@IdSolicitudPedido,
         @IdTipoOperacion,
         @IdFlujo,
         1  ,
         1  ,
         @IdProveedorCompras,
         @IdUsuarioCompras,
         GETDATE(),
         @Mensaje,
         @IdVigencia,
         @IdPrioridad,
         @VERSION
        );

        SELECT @IdOperacionActual = SCOPE_IDENTITY();


        DECLARE @DescripcionH NVARCHAR(MAX);

        SET @DescripcionH
            = N'El Usuario ' +
              (
                  SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdUsuarioCompras
              ) + N' ha registrado la operación ' +
              (
                  SELECT ISNULL(NombreOperacion, 'APROBACIÓN DE PEDIDO con valor de $' + @TotalSumaPedidos + ' USD')
                  FROM TA_TipoOperacion
                  WHERE IdTipoOperacion = @IdTipoOperacion
              );

        INSERT INTO TA_HistorialFlujoTarea
        (
            IdOperacion,
            Fecha,
            Descripcion,
            IdEstadoFlujo
        )
        VALUES
        (@IdOperacionActual, GETDATE(), @DescripcionH, 1);

        ----#AGREGAR RELACION OPERACION PEDIDO APROBACION 
        INSERT INTO TA_Tarea
        (
            IdAprobador,
            IdEstatus,
            NombreTarea,
            Visto,
            FechaRegistro,
            Activo,
            NoSecuencia,
            IdOperacion
        )
        SELECT A.IdUsuario,
               1 AS Estatus,
               'Aprobación de pedido',
               0 AS Visto,
               GETDATE() AS FechaRegistro,
               1,
               A.NoSecuencia,
               @IdOperacionActual AS IdOperacion
        FROM TA_Aprobador AS A
            INNER JOIN TA_FlujoTarea AS FT
                ON FT.IdFlujoTarea = A.IdFlujoTarea
            INNER JOIN S_Usuario AS U
                ON U.IdUsuario = A.IdUsuario
        WHERE A.IdFlujoTarea = @IdFlujo
        ORDER BY NoSecuencia ASC;
	
		EXEC dbo.Mobile_NotificacionPetrovendor @IdtareaIdentity = 0,				--Se agrega aprobacion movil
		                                        @IdOperacion = @IdOperacionActual      
	
        --Usuarios a notificar
        INSERT INTO #APROBADORES_PEDIDOS
        (
            row_group_pedido,
            version_pedido,
            id_usuario,
            nombre_aprobador,
            correo_aprobador,
            numero_secuencia,
            id_operacion,
            id_tipo_flujo,
            id_proveedor_compras,
            IdFlujo,
            TotalEnDls,
            NombreFlujo,
            MonedaActual,
            SumaTotalProveedor,
            TipoCambio,
            ValorADividir,
            Telefono
        )
        SELECT 1,
               @VERSION AS version_pedido,
               A.IdUsuario,
               U.Nombre,
               U.Correo,
               A.NoSecuencia,
               @IdOperacionActual AS IdOperacion,
               FT.IdTipoFlujo,
               @IdProveedorCompras,
               @IdFlujo,
               @TotalSumaPedidos,
               FT.Nombre,
               @ID_MONEDA_ACTUAL,
               @SumaPedidoProveedor,
               @TipoCambio,
               @ValorDivision,
               ISNULL(U.Telefono, '')
        FROM TA_Aprobador AS A
            INNER JOIN TA_FlujoTarea AS FT
                ON FT.IdFlujoTarea = A.IdFlujoTarea
            INNER JOIN S_Usuario AS U
                ON U.IdUsuario = A.IdUsuario
        WHERE A.IdFlujoTarea = @IdFlujo
        GROUP BY A.IdUsuario,
                 U.Nombre,
                 U.Correo,
                 A.NoSecuencia,
                 FT.IdTipoFlujo,
                 FT.Nombre,
                 U.Telefono
        ORDER BY NoSecuencia ASC;

        --#REMOVER TODOS LAS CANTIDADADES DEL TEMPORAL ADD PEDIDO
        --tener cuidado cuando son dos monedas
        UPDATE POD
        SET POD.AddPedidoTemp = 0,
            POD.AddCantidadTemp = 0,
            POD.AddSubTotalTemp = 0,
            POD.AddPedidoFinal = 0,
			POD.IdCondicionPagoTemp= NULL, -->NUEVO DIAS DE CREDITO
			POD.DiasCreditoTemp=NULL -->NUEVO DIAS DE CREDITO
        FROM MM_PeticionOfertaDetalle AS POD
            INNER JOIN MM_PeticionOferta AS PO
                ON POD.IdPeticionOferta = PO.IdPeticionOferta
            INNER JOIN MM_SolicitudPedido AS SP
                ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            INNER JOIN MM_SolicitudPedidoDetalle AS SPD
                ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
        WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
              AND POD.AddValidado = 1
              AND POD.Cotizado = 1
              AND POD.AddPedidoTemp = 1
              AND PO.IdPeticionOferta = @IdPeticionOfertaActual
              AND POD.IdMoneda = @ID_MONEDA_ACTUAL;

        --Se guarda en el historial del flujo en caso de que el usuario cambie el monto del valor inicial y valor final del flujo saber por que en esu momento se catalogo en el flujo dado
        INSERT INTO dbo.HistorialFlujoPedido
        (
            IdOperacion,
            IdPedido,
            Idflujo,
            ValorInicial,
            ValorFinal,
            TotalPedidoEnDls,
            FechaCreacion
        )
        SELECT @IdOperacionActual,
               @IdPedidoActual,
               @IdFlujo,
               FTC.ValorInicial,
               FTC.ValorFinal,
               @TotalSumaPedidos,
               GETDATE()
        FROM TA_FlujoTarea AS FT
            INNER JOIN TA_FlujoTareaCondicion AS FTC
                ON FTC.IdFlujoTarea = FT.IdFlujoTarea
        WHERE FT.IdFlujoTarea = @IdFlujo;
		
        SET @TotalSumaPedidos = 0; --Resetear el valor del pedido
        SET @INCREMENTO = @INCREMENTO + 1;
    END;
    --Se retorna los usuarios que van a ser notificados ademas se agrego un retorno mas detallado para hacer pruebas
    --se agregaron los siguientes campos TotalEnDls, NombreFlujo, MonedaActual, SumaTotalProveedor, TipoCambio, ValorADividir (no se utilizan solo es para hacer pruebas)
    SELECT *
    FROM #APROBADORES_PEDIDOS
    ORDER BY row_group_pedido ASC;
END;



