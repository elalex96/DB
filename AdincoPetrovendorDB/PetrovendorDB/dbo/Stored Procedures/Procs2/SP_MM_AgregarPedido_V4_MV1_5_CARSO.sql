CREATE PROCEDURE [dbo].[SP_MM_AgregarPedido_V4_MV1_5_CARSO]
    @IdSolicitudPedido  INT,
    @Mensaje            NVARCHAR (MAX),
    @IdPrioridad        INT,
    @IdVigencia         INT,
    @IdUsuarioCompras   INT,
    @IdProveedorCompras INT,
    @HorasVigencia      INT = 24,
    @NoCartaCN          BIT = NULL,
    @IdTipoCompra       INT,
    /*--------------------parametros contrato--------------------*/
    @IdContrato         INT,
    @IdUsuario          INT,
    @FechaRegistro      DATETIME
/*-----------------------------------------------------------*/
AS
    BEGIN -- Empieza Store
        SET NOCOUNT ON


        DECLARE @COUNT_PROVEEDORES INT;
        DECLARE @INCREMENTO INT = 1;
        DECLARE @IdPedidoActual INT;
        DECLARE @IdFlujo INT = 0;
        DECLARE @IdOperacionActual INT;
        DECLARE @IdTipoOperacion INT = 9; ---Aprobación de pedido
        DECLARE @TotalSumaPedidos FLOAT;
        DECLARE @VERSION INT;
        DECLARE @IdMonedaDLS INT = 2;


        DECLARE @tablaFlujos TABLE ( Fila           INT,
                                     IdFlujoTarea   INT,
                                     ValorInicial   FLOAT,
                                     ValorFinal     FLOAT,
                                     Predeterminado INT,
                                     Nombre         NVARCHAR (MAX),
                                     Orden          FLOAT );


        CREATE TABLE #TABLA_PROVEEDORES ( idrow            INT,
                                          idProveedor      INT,
                                          sumaPedido       FLOAT,
                                          idflujo          INT,
                                          idTipoMoneda     INT,
                                          idPeticionOferta INT );


        DECLARE @TablaRevisionRetorno TABLE ( RFC               NVARCHAR (150),
                                              DataAreaId        NVARCHAR (MAX),
                                              IdPedidoAdinco    INT             NULL,
                                              OCIPurchId        NVARCHAR (150),
                                              OCIIdFormat       NVARCHAR (MAX),
                                              CurrencyCode      NVARCHAR (150),
                                              ItemId            NVARCHAR (150),
                                              Observations      NVARCHAR (MAX),
                                              Price             DECIMAL (18, 4) NULL,
                                              Qty               DECIMAL (18, 4) NULL,
                                              RecId             BIGINT          NULL,
                                              UnitId            NVARCHAR (150),
                                              IdSolicitudPedido INT             NULL,
											  IdPedidoGral INT )


        DECLARE @TablaPedidoAgregado TABLE ( IdPedido INT )


        CREATE TABLE #TIPO_CAMBIO ( TipoCambio DECIMAL (12, 4), Fecha DATETIME, IdMoneda INT );


        -- Obtener los datos del Peticion Oferta para pasarlos a las Pedido e identificar  --- 
        INSERT INTO
            #TABLA_PROVEEDORES ( idrow, idProveedor, sumaPedido, idTipoMoneda, idPeticionOferta )
        SELECT
                ROW_NUMBER() OVER ( ORDER BY PO.IdSubcontratista ASC ) AS Row#,
                PO.IdSubcontratista,
                SUM(POD.PrecioUnitario * POD.AddCantidadTemp),
                POD.IdMoneda,
                POD.IdPeticionOferta
        FROM
                dbo.MM_PeticionOferta         AS PO
            INNER JOIN
                dbo.MM_PeticionOfertaDetalle  AS POD
                    ON POD.IdPeticionOferta = PO.IdPeticionOferta
            INNER JOIN
                dbo.MM_SolicitudPedido        AS SP
                    ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            INNER JOIN
                dbo.MM_SolicitudPedidoDetalle AS SPD
                    ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
        WHERE
                PO.IdSolicitudPedido = @IdSolicitudPedido
                AND POD.AddValidado = 1
                AND POD.Cotizado = 1
                AND POD.AddPedidoTemp = 1
        GROUP BY
                PO.IdSubcontratista, POD.IdMoneda, POD.IdPeticionOferta;


        --cuantos pedidos se van a realizar y ta_operaciones a realizar (aprobaciones)
        SET @COUNT_PROVEEDORES = ( SELECT COUNT(idrow) FROM #TABLA_PROVEEDORES );


        --variables donde se lleva el total de cada pedido 
        DECLARE @suma FLOAT;
        DECLARE @sumacadena NVARCHAR (MAX);


        SET @INCREMENTO = 1;


        WHILE @COUNT_PROVEEDORES >= @INCREMENTO
            BEGIN

                --Se genera una version por cada TA_operacion para relacionarlo con el pedido
                --- OBTENER LA VERSION DE PEDIDO A REALIZAR
                SET @VERSION = (   SELECT TOP 1
                                          P.Version
                                   FROM
                                          MM_Pedido AS P
                                   WHERE
                                          IdSolicitudPedido = @IdSolicitudPedido
                                   ORDER BY
                                          Version DESC );
                SET @VERSION = ISNULL(@VERSION, 0) + 1;


                --#Obtener el IdMoneda la peticion oferta, el total del pedido del proveedor actual 
                DECLARE @IdPeticionOfertaActual INT
                    =   ( SELECT idPeticionOferta FROM #TABLA_PROVEEDORES WHERE idrow = @INCREMENTO );
                DECLARE @ID_MONEDA_ACTUAL INT
                    =   ( SELECT idTipoMoneda FROM #TABLA_PROVEEDORES WHERE idrow = @INCREMENTO );
                DECLARE @SumaPedidoProveedor FLOAT
                    =   ( SELECT sumaPedido FROM #TABLA_PROVEEDORES WHERE idrow = @INCREMENTO );
                DECLARE @FECHA_TIPO_CONVERSION_ACTUAL DATETIME;


                DELETE #TIPO_CAMBIO;


                INSERT INTO
                    #TIPO_CAMBIO
                SELECT * FROM dbo.GetTipoCambioActual(
                              @ID_MONEDA_ACTUAL, GETDATE());


                DECLARE @TipoCambio FLOAT
                    =   (   SELECT  TC.TipoCambio
                            FROM
                                    #TABLA_PROVEEDORES AS TP
                                LEFT JOIN
                                    #TIPO_CAMBIO       AS TC
                                        ON TC.IdMoneda = TP.idTipoMoneda
                            WHERE
                                    idrow = @INCREMENTO );
                DECLARE @ValorDivision FLOAT
                    =   (   SELECT  TP.sumaPedido
                            FROM
                                    #TABLA_PROVEEDORES AS TP
                                LEFT JOIN
                                    #TIPO_CAMBIO       AS TC
                                        ON TC.IdMoneda = TP.idTipoMoneda
                            WHERE
                                    idrow = @INCREMENTO );


                SET @suma = (   SELECT
                                        CASE
                                            WHEN TP.idTipoMoneda <> @IdMonedaDLS
                                                THEN
                                                ISNULL(
                                                    ( TP.sumaPedido
                                                  / TC.TipoCambio ), 0)
                                            ELSE
                                                TP.sumaPedido
                                        END
                                FROM
                                        #TABLA_PROVEEDORES AS TP
                                    LEFT JOIN
                                        #TIPO_CAMBIO       AS TC
                                            ON TC.IdMoneda = TP.idTipoMoneda
                                WHERE
                                        idrow = @INCREMENTO );
                SET @TotalSumaPedidos = ISNULL(@TotalSumaPedidos, 0) + @suma;


                DECLARE @ID_PROVEEDOR_VENTAS INT
                    =   ( SELECT idProveedor FROM #TABLA_PROVEEDORES WHERE idrow = @INCREMENTO );


                --#AGREGAR  Al pedido 
                INSERT INTO
                    dbo.MM_Pedido ( IdPeticionOferta,
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
                                    NoCartaCN )
                SELECT
                        PO.IdPeticionOferta,
                        '',
                        SP.IdSolicitudPedido,
                        PO.IdSubcontratista,
                        SP.IdContrato,
                        0                  AS editado,
                        GETDATE(),
                        @IdUsuarioCompras,
                        @IdProveedorCompras,
                        @VERSION,
                        @ID_MONEDA_ACTUAL,
                        @NoCartaCN
                FROM
                        dbo.MM_PeticionOferta         AS PO
                    INNER JOIN
                        dbo.MM_PeticionOfertaDetalle  AS POD
                            ON POD.IdPeticionOferta = PO.IdPeticionOferta
                    INNER JOIN
                        dbo.MM_SolicitudPedido        AS SP
                            ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
                    INNER JOIN
                        dbo.MM_SolicitudPedidoDetalle AS SPD
                            ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
                WHERE
                        PO.IdSolicitudPedido = @IdSolicitudPedido
                        AND PO.IdSubcontratista = @ID_PROVEEDOR_VENTAS
                        AND POD.AddValidado = 1
                        AND POD.Cotizado = 1
                        AND POD.AddPedidoTemp = 1
                        AND PO.IdPeticionOferta = @IdPeticionOfertaActual
                        AND POD.IdMoneda = @ID_MONEDA_ACTUAL
                GROUP BY
                        PO.IdPeticionOferta,
                        SP.IdSolicitudPedido,
                        PO.IdSubcontratista,
                        SP.IdContrato;


                SELECT @IdPedidoActual = SCOPE_IDENTITY();


                -- tabla para saber cuales son los pedidos que se han estado agregando
                INSERT INTO @TablaPedidoAgregado ( IdPedido ) SELECT
                                                              @IdPedidoActual


                INSERT INTO
                    dbo.MM_HorasVigenciaPedido ( IdPedido, HorasVigencia, FechaVigencia )
                VALUES ( @IdPedidoActual, -- IdPedido - int
                         @HorasVigencia,  -- HorasVigencia - int
                         NULL             -- FechaCreacionPedido - smalldatetime
                    );


                ---#Agregar al pedido detalle
                INSERT INTO
                    dbo.MM_PedidoDetalle ( IdPedido,
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
                                           IdUnidadProveedor )
                SELECT
                        @IdPedidoActual   AS IdPedido,
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
                        GETDATE()         AS CreadoEl,
                        POD.IdUnidad,
                        POD.IdUnidadProveedor
                FROM
                        dbo.MM_PeticionOferta         AS PO
                    INNER JOIN
                        dbo.MM_PeticionOfertaDetalle  AS POD
                            ON POD.IdPeticionOferta = PO.IdPeticionOferta
                    INNER JOIN
                        dbo.MM_SolicitudPedido        AS SP
                            ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
                    INNER JOIN
                        dbo.MM_SolicitudPedidoDetalle AS SPD
                            ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
                WHERE
                        PO.IdSolicitudPedido = @IdSolicitudPedido
                        AND PO.IdSubcontratista = @ID_PROVEEDOR_VENTAS
                        AND POD.AddValidado = 1
                        AND POD.Cotizado = 1
                        AND POD.AddPedidoTemp = 1
                        AND PO.IdPeticionOferta = @IdPeticionOfertaActual
                        AND POD.IdMoneda = @ID_MONEDA_ACTUAL;


                --#Almacenar historial del tipo de cambio de la modeda actual 
                SET @FECHA_TIPO_CONVERSION_ACTUAL = ( SELECT Fecha FROM #TIPO_CAMBIO );


                DECLARE @TIPO_CAMBIO_ACTUAL DECIMAL (12, 4)
                    =   ( SELECT TipoCambio FROM #TIPO_CAMBIO );


                INSERT INTO
                    dbo.MM_PedidoTipoCambio ( IdPedido, IdTipoMoneda, FechaTipoCambio, TipoCambio )
                VALUES ( @IdPedidoActual,               -- IdPedido - int
                         @ID_MONEDA_ACTUAL,             -- IdTipoMoneda - int
                         @FECHA_TIPO_CONVERSION_ACTUAL, -- FechaTipoCambio - datetime
                         @TIPO_CAMBIO_ACTUAL            -- TipoCambio - decimal(12, 4)
                    );


                --#Generar el IdPedidoGeneral   
                DECLARE @IdPedidoGeneral INT;
                DECLARE @FECHA_ACTUAL DATETIME = ( SELECT GETDATE());


                EXEC dbo.SP_MM_GenerarIdPedidoGeneral
                    @IdTipoPedido = @IdTipoCompra,            -- int 2 = MERCADEO, 4  Adjudicacion Directa
                    @IdPrimaryKey = @IdPedidoActual,          -- int
                    @CreadoPor = @IdUsuarioCompras,           -- int
                    @CreadoEl = @FECHA_ACTUAL,                -- datetime
                    @IdProveedorActual = @IdProveedorCompras, -- int
                    @IdPedidoGeneral = @IdPedidoGeneral OUTPUT;


                -- int

                --Asignar el flujo correspondiente al monto
                -- SECCION AGREGADA FLUJO DE APROBACION

                --se asigna el idflujo 
                SELECT  @IdFlujo = FT.IdFlujoTarea
                FROM
                        dbo.TA_FlujoTarea     FT
                    INNER JOIN
                        dbo.TA_TipoFlujoTarea AS TF
                            ON TF.IdTipoFlujoTarea = FT.IdTipoFlujo
                               AND FT.IdTipoOperacion = 7
                               AND FT.Predeterminado = 1
                               AND FT.IdProveedor = ( SELECT idProveedor FROM #TABLA_PROVEEDORES WHERE idrow = @INCREMENTO )
                WHERE
                        ISNULL(FT.Eliminado, 0) = 0


                -- En caso de que no exista se debe de crear
                IF ( @IdFlujo IS NULL OR @IdFlujo = 0 )
                    BEGIN
                        DECLARE @NombreFlujo NVARCHAR (100)
                            = N'Flujo Aprobacion Carso'


                        DECLARE @TablaUsuarioProveedor TABLE ( IdUsuario INT, IdProveedor INT )


                        INSERT INTO
                            @TablaUsuarioProveedor ( IdProveedor, IdUsuario )
                        SELECT
                                prov.idProveedor, uprov.IdUsuario
                        FROM
                                #TABLA_PROVEEDORES     prov
                            INNER JOIN
                                dbo.S_UsuarioProveedor uprov
                                    ON uprov.IdProveedor = prov.idProveedor
                        WHERE
                                prov.idrow = @INCREMENTO


                        INSERT INTO
                            dbo.TA_FlujoTarea ( Nombre,
                                                Descripcion,
                                                IdTipoFlujo,
                                                IdTipoOperacion,
                                                Condicion,
                                                FechaCreacion,
                                                CreadorPor,
                                                IdProveedor,
                                                Activo,
                                                Eliminado,
                                                Predeterminado )
                        SELECT
                            @NombreFlujo,
                            @NombreFlujo,
                            1,
                            7,
                            1,
                            GETDATE(),
                            IdUsuario,
                            IdProveedor,
                            1,
                            0,
                            1
                        FROM
                            @TablaUsuarioProveedor


                        SELECT @IdFlujo = SCOPE_IDENTITY()


                        INSERT INTO
                            dbo.TA_Aprobador ( IdFlujoTarea, IdUsuario, NoSecuencia )
                        SELECT @IdFlujo, IdUsuario, IdProveedor FROM @TablaUsuarioProveedor


                        INSERT INTO
                            dbo.TA_FlujoTareaCondicion ( NombreCondicion, IdFlujoTarea, IdConstanteCondicion, ValorInicial, ValorFinal )
                        SELECT
                            'Total Pedido 0.01 a 99999999999999',
                            @IdFlujo,
                            5,
                            0.01,
                            99999999999999
                    END


                --- REALIZAR REGISTRO DE OPERACION DE APROBACION 
                INSERT INTO
                    dbo.TA_Operacion ( IdDocumento,
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
                                       NoVersion )
                VALUES ( @IdSolicitudPedido, @IdTipoOperacion, @IdFlujo, 1,
                         1, @IdProveedorCompras, @IdUsuarioCompras,
                         GETDATE(), @Mensaje, @IdVigencia, @IdPrioridad,
                         @VERSION );


                SELECT @IdOperacionActual = SCOPE_IDENTITY();


                DECLARE @DescripcionH NVARCHAR (MAX);


                SET @DescripcionH
                    = N'El Usuario '
                      + ( SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdUsuarioCompras )
                      + N' ha registrado la operación '
                      + (   SELECT
                                ISNULL(
                                    NombreOperacion,
                                    'APROBACIÓN DE PEDIDO con valor de $'
                                    + @TotalSumaPedidos + ' USD')
                            FROM
                                TA_TipoOperacion
                            WHERE
                                IdTipoOperacion = @IdTipoOperacion );


                INSERT INTO
                    dbo.TA_HistorialFlujoTarea ( IdOperacion, Fecha, Descripcion, IdEstadoFlujo )
                VALUES ( @IdOperacionActual, GETDATE(), @DescripcionH, 1 );


                --#REMOVER TODOS LAS CANTIDADADES DEL TEMPORAL ADD PEDIDO
                --tener cuidado cuando son dos monedas
                UPDATE
                        POD
                SET
                        POD.AddPedidoTemp = 0,
                        POD.AddCantidadTemp = 0,
                        POD.AddSubTotalTemp = 0,
                        POD.AddPedidoFinal = 0
                FROM
                        dbo.MM_PeticionOfertaDetalle  AS POD
                    INNER JOIN
                        dbo.MM_PeticionOferta         AS PO
                            ON POD.IdPeticionOferta = PO.IdPeticionOferta
                    INNER JOIN
                        dbo.MM_SolicitudPedido        AS SP
                            ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
                    INNER JOIN
                        dbo.MM_SolicitudPedidoDetalle AS SPD
                            ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
                WHERE
                        PO.IdSolicitudPedido = @IdSolicitudPedido
                        AND POD.AddValidado = 1
                        AND POD.Cotizado = 1
                        AND POD.AddPedidoTemp = 1
                        AND PO.IdPeticionOferta = @IdPeticionOfertaActual
                        AND POD.IdMoneda = @ID_MONEDA_ACTUAL;


                SET @TotalSumaPedidos = 0; --Resetear el valor del pedido
                SET @INCREMENTO = @INCREMENTO + 1;
                SET @IdFlujo = NULL
            END;


        --Se retorna los usuarios que van a ser notificados ademas se agrego un retorno mas detallado para hacer pruebas
        --se agregaron los siguientes campos TotalEnDls, NombreFlujo, MonedaActual, SumaTotalProveedor, TipoCambio, ValorADividir (no se utilizan solo es para hacer pruebas)
        -- Adj Directa 3
        -- Mercadeo 4
        -- Licitacion publica 5
        -- Relacionada de Carso 6
        INSERT INTO
            @TablaRevisionRetorno ( RFC,
                                    DataAreaId,
                                    IdPedidoAdinco,
                                    OCIPurchId,
                                    OCIIdFormat,
                                    CurrencyCode,
                                    ItemId,
                                    Observations,
                                    Price,
                                    Qty,
                                    RecId,
                                    UnitId,
                                    IdSolicitudPedido )
        SELECT
                prov.RFC                                            AS RFC,
                comp.DataAreaId,
                CAST(p.IdPedido AS NVARCHAR (100))                  AS IdPedidoAdinco,
                CAST(CASE

                       WHEN sp.IdTipoProceso =  1
							THEN
							'02'
						WHEN sp.IdTipoProceso =  4
							THEN
							'03'
                         WHEN sp.IdTipoProceso = 2
                             THEN
                             '04'
                         WHEN sp.IdTipoProceso = 3
                             THEN
                             '05'
                         WHEN sp.IdTipoProceso = 5
                             THEN
                             '06'
                     END AS NVARCHAR (100))                         AS OCIPurchId,
                terminos.Nombre                                     AS OCIIdFormat,
                CASE WHEN pd.IdMoneda = 2 THEN 'USD' ELSE 'MXP' END AS CurrencyCode,
                SUBSTRING(comp.Item, 1, 9)                          AS ItemId,
                pd.ComentariosCompras                               AS Observations,
                CAST(pd.PrecioUnitario AS DECIMAL (18, 4))          AS Price,
                CAST(pd.Cantidad AS DECIMAL (18, 4))                AS Qty,
                CAST(comp.IdPosicion AS BIGINT)                     AS RecId,
                comp.Unidad                                         AS UnitId,
                comp.IdSolicitudPedido
        FROM
                #TABLA_PROVEEDORES               tprov
            INNER JOIN
                dbo.MM_PeticionOferta            po
                    ON po.IdPeticionOferta = tprov.idPeticionOferta
            INNER JOIN
                dbo.MM_PeticionOfertaDetalle     pod
                    ON pod.IdPeticionOferta = po.IdPeticionOferta
            INNER JOIN
                dbo.MM_SolicitudPedido           sp
                    ON sp.IdSolicitudPedido = po.IdSolicitudPedido
            LEFT JOIN
                dbo.S_Proveedor                  prov
                    ON po.IdSubcontratista = prov.IdProveedor
            INNER JOIN
                dbo.MM_Pedido                    p
                    ON p.IdSolicitudPedido = sp.IdSolicitudPedido
                       AND p.IdPeticionOferta = po.IdPeticionOferta
            INNER JOIN
                @TablaPedidoAgregado             pa
                    ON pa.IdPedido = p.IdPedido
            LEFT JOIN
                dbo.MM_PedidoDetalle             pd
                    ON pd.IdPedido = p.IdPedido
                       AND pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle
            LEFT JOIN
                dbo.MM_SolicitudPedidoDetalle    spd
                    ON spd.IdSolicitudPedido = sp.IdSolicitudPedido
                       AND spd.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle
            LEFT JOIN
                dbo.AX_MATERIAL                  m
                    ON m.IdMaterialPetrov = pd.IdMaterial
            LEFT JOIN
                dbo.MM_Material                  mp
                    ON mp.IdMaterial = m.IdMaterialPetrov
            LEFT JOIN
                dbo.AX_Comparativa               comp
                    ON comp.IdSolicitudPedido = p.IdSolicitudPedido
                       AND comp.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
            LEFT JOIN
                dbo.TC_TerminosYCondicionesDocV2 terminos
                    ON terminos.IdProveedor = comp.IdProveedor
        WHERE
                pd.IdPedidoDetalle IS NOT NULL
        GROUP BY
                p.IdPedido,
                sp.IdTipoProceso,
                pd.IdMoneda,
                comp.Item,
                pd.PrecioUnitario,
                pd.Cantidad,
                comp.IdPosicion,
                prov.RFC,
                comp.DataAreaId,
                terminos.Nombre,
                pd.ComentariosCompras,
                comp.Unidad,
                comp.IdSolicitudPedido


        INSERT INTO
            dbo.Ax_PedidoLog ( RFC,
                               DataAreaId,
                               IdPedidoAdinco,
                               OCIPurchId,
                               OCIIdFormat,
                               CurrencyCode,
                               ItemId,
                               Observations,
                               Price,
                               Qty,
                               RecId,
                               UnitId,
                               IdSolicitudPedido,
                               FechaRegistro )
        SELECT
            RFC,
            DataAreaId,
            IdPedidoAdinco,
            OCIPurchId,
            OCIIdFormat,
            CurrencyCode,
            ItemId,
            Observations,
            Price,
            Qty,
            RecId,
            UnitId,
            IdSolicitudPedido,
            GETDATE()
        FROM
            @TablaRevisionRetorno
			WHERE IdSolicitudPedido IS NOT NULL


        IF NOT EXISTS ( SELECT 1 FROM @TablaRevisionRetorno )
            BEGIN
                RAISERROR('Table does not exist', 16, 1)
            END
		
		UPDATE r
		SET r.IdPedidoGral = ps.IdPedido
		FROM @TablaRevisionRetorno r 
		INNER JOIN dbo.MM_Pedidos ps ON ps.IdIdentificador = r.IdPedidoAdinco
		AND ps.IdProveedorCliente = @IdProveedorCompras

        SELECT
            RFC,
            DataAreaId,
            LTRIM(IdPedidoAdinco) AS IdPedidoAdinco,
            OCIPurchId,
            OCIIdFormat,
            CurrencyCode,
            ItemId,
            Observations,
            Price,
            Qty,
            RecId,
            UnitId,
            IdSolicitudPedido,
			IdPedidoGral
        FROM
            @TablaRevisionRetorno
			WHERE IdSolicitudPedido IS NOT NULL
    END


