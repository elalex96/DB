-- =============================================
-- Author:		Pedro Acuña
-- Create date: 23/05/2018
-- Description:	Simula el  agregar al PEDIDO  y al PEDIDO DETALLE
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 23/05/2018
-- Description:	MODICACIÓN PARA DIAS DE CRÉDITO YA SE LLAMA DIRECTAMENTE DESDE EL GRIDVIEW
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Simulacion_AgregarPedido_V4_MV1_5]
    -- Add the parameters for the stored procedure here
    @IdSolicitudPedido INT,
    @IdUsuarioCompras INT,
    @IdProveedorCompras INT,
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME=NULL 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @COUNT_PROVEEDORES INT;
    DECLARE @COUNT_FLUJOS INT;
    DECLARE @FOR_STRING NVARCHAR(MAX) = N'';
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
        id_proveedor_compras INT
    );

    CREATE TABLE #TIPO_CAMBIO
    (
        TipoCambio DECIMAL(12, 4),
        Fecha DATETIME,
        IdMoneda INT
    );

    --- Obtener los datos del Peticion Oferta para pasarlos a las Pedido e identificar  --- 
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
             POD.IdPeticionOferta;



    --cuantos pedidos se van a realizar y ta_operaciones a realizar (aprobaciones)
    SET @COUNT_PROVEEDORES =
    (
        SELECT COUNT(idrow) FROM #TABLA_PROVEEDORES
    );


    --variables donde se lleva el total de cada pedido 
    DECLARE @suma FLOAT;
    DECLARE @sumacadena NVARCHAR(MAX);

    DECLARE @tablaAuxPedido TABLE
    (
        IdPedidoSimul INT IDENTITY,
        IdPeticionOferta INT,
        Comentarios NVARCHAR(MAX),
        IdSolicitudPedido INT,
        IdSubcontratista INT,
        IdContrato INT,
        Editado BIT,
        CreadoEl DATETIME,
        CreadoPor INT,
        IdProveedorCompras INT,
        VERSION INT,
        IdMoneda INT,
        IdFlujo INT,
        TotalDls FLOAT
    );

    DECLARE @tablaAuxPedidoDetalle TABLE
    (
        IdPedidoDetalleSimul INT IDENTITY,
        IdPedido INT,
        IdMaterial INT,
        IdMaterialVendedor INT,
        IdPeticionOfertaDetalle INT,
        PrecioUnitario DECIMAL,
        Cantidad DECIMAL,
        IdMoneda INT,
        Subtotal DECIMAL,
        Activo BIT,
        ComentariosCompras NVARCHAR(MAX),
        CreadoPor INT,
        CreadoEl DATETIME,
        IdUnidad INT,
        IdUnidadProveedor INT
    );

    SET @INCREMENTO = 1;

    --- OBTERNER LA VERSION DE PEDIDO A REALIZAR
    SET @VERSION =
    (
        SELECT TOP 1
               P.Version
        FROM MM_Pedido AS P
        WHERE IdSolicitudPedido = @IdSolicitudPedido
        ORDER BY Version DESC
    );
    SET @VERSION = ISNULL(@VERSION, 0) + 1;

    WHILE @COUNT_PROVEEDORES >= @INCREMENTO
    BEGIN

        --#Obtener el IdMoneda la peticion oferta, el total del pedido del proveedor actual 
        DECLARE @IdPeticionOfertaActual INT =
                (
                    SELECT idPeticionOferta FROM #TABLA_PROVEEDORES WHERE idrow = @INCREMENTO
                );
        DECLARE @ID_MONEDA_ACTUAL INT =
                (
                    SELECT idTipoMoneda FROM #TABLA_PROVEEDORES WHERE idrow = @INCREMENTO
                );
        DECLARE @SumaPedidoProveedor FLOAT =
                (
                    SELECT sumaPedido FROM #TABLA_PROVEEDORES WHERE idrow = @INCREMENTO
                );
        DECLARE @FECHA_TIPO_CONVERSION_ACTUAL DATETIME;

        DELETE #TIPO_CAMBIO;

        INSERT INTO #TIPO_CAMBIO
        SELECT *
        FROM dbo.GetTipoCambioActual(@ID_MONEDA_ACTUAL, GETDATE());

        DECLARE @TipoCambio FLOAT =
                (
                    SELECT TC.TipoCambio
                    FROM #TABLA_PROVEEDORES AS TP
                        LEFT JOIN #TIPO_CAMBIO AS TC
                            ON TC.IdMoneda = TP.idTipoMoneda
                    WHERE idrow = @INCREMENTO
                );
        DECLARE @ValorDivision FLOAT =
                (
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

        --Asignar el flujo correspondiente al monto
        INSERT INTO @tablaFlujos
        EXEC dbo.SP_ObtenerFlujoAprobacionxValor @Total = @TotalSumaPedidos,                -- float
                                                 @IdProveedorCompras = @IdProveedorCompras; -- int

        SELECT @IdFlujo = IdFlujoTarea
        FROM @tablaFlujos
        WHERE Fila = 1;

        DECLARE @ID_PROVEEDOR_VENTAS INT =
                (
                    SELECT idProveedor FROM #TABLA_PROVEEDORES WHERE idrow = @INCREMENTO
                );

        --#AGREGAR  Al pedido 
        INSERT INTO @tablaAuxPedido
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
            VERSION,
            IdMoneda,
            IdFlujo,
            TotalDls
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
               @IdFlujo,
               @TotalSumaPedidos
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

        SET @IdPedidoActual =
        (
            SELECT @INCREMENTO
        );

        ---#Agregar al pedido detalle
        INSERT INTO @tablaAuxPedidoDetalle
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
            IdUnidadProveedor
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
               POD.IdUnidadProveedor
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
              AND POD.IdMoneda = @ID_MONEDA_ACTUAL
              AND PO.IdPeticionOferta = @IdPeticionOfertaActual;

        SET @TotalSumaPedidos = 0;
        SET @VERSION += 1;
        SET @INCREMENTO = @INCREMENTO + 1;
    END;

    SELECT pedido.IdPedidoSimul,
           pedido.IdSolicitudPedido,
           pedido.CreadoEl AS FechaEnvioPedido,
           SUM(detalle.Subtotal) AS TotalPedido,
           ISNULL(prov.RazonSocial, '') + ' ' + ISNULL(prov.RegimenCapital, '') AS Proveedor,
           pedido.VERSION,
           tm.TipoMonedaCorto AS TipoMoneda,
           ISNULL(condici.DiasCredito, 0) AS DiasCredito,
           pedido.IdSubcontratista,
           pedido.IdMoneda,
           pedido.IdFlujo,
           pedido.TotalDls,
		   pedido.IdSubcontratista AS IdProveedorVenta,
           pedido.IdMoneda,  
           pedido.IdPeticionOferta
    FROM @tablaAuxPedido pedido
        INNER JOIN @tablaAuxPedidoDetalle detalle
            ON pedido.IdPedidoSimul = detalle.IdPedido
        INNER JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = pedido.IdSubcontratista
        INNER JOIN dbo.PV_TipoMoneda tm
            ON tm.IdMoneda = pedido.IdMoneda
        LEFT JOIN dbo.PV_ContratistaSubContratista contratista
            ON contratista.IdContratista = pedido.IdSubcontratista
               AND contratista.IsActivo = 1
               AND contratista.IdSubContratista = @IdProveedorCompras
        LEFT JOIN PV_CondicionesPago condici
            ON condici.IdContratistaSubContratista = contratista.IdRelacion		
    GROUP BY pedido.IdPedidoSimul,
             pedido.IdSolicitudPedido,
             pedido.CreadoEl,
             prov.RazonSocial,
             prov.RegimenCapital,
             pedido.VERSION,
             tm.TipoMonedaCorto,
             condici.DiasCredito,
             pedido.IdSubcontratista,
             pedido.IdMoneda,
             pedido.IdFlujo,
             pedido.TotalDls,
			 pedido.IdMoneda,  
			 pedido.IdPeticionOferta


END;





