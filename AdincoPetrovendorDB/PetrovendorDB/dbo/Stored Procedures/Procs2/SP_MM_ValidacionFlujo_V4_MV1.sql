USE Petrovendor
GO
DROP PROCEDURE IF EXISTS SP_MM_ValidacionFlujo_V4_MV1
GO
CREATE PROCEDURE SP_MM_ValidacionFlujo_V4_MV1
@IdSolicitudPedido INT,
@IdUsuarioCompras INT,
@IdProveedorCompras INT
AS
BEGIN 
	DECLARE @COUNT_PROVEEDORES INT;
    DECLARE @INCREMENTO INT = 1;
    DECLARE @IdFlujo INT = 0;
    DECLARE @TotalSumaPedidos FLOAT;
    DECLARE @IdMonedaDLS INT = 2;
	DECLARE @suma FLOAT;
    DECLARE @sumacadena NVARCHAR(MAX);
	DECLARE @ID_MONEDA_ACTUAL INT;

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
	DROP TABLE IF EXISTS #TABLA_PROVEEDORES
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
    SET @COUNT_PROVEEDORES =
    (
        SELECT COUNT(idrow) FROM #TABLA_PROVEEDORES
    );
    SET @INCREMENTO = 1;
	DROP TABLE IF EXISTS #RESULTADOSFLUJO
	CREATE TABLE #RESULTADOSFLUJO
	(
		ROW INT PRIMARY KEY NOT NULL IDENTITY (1,1),
		RESULT VARCHAR(100),
		FLOWID INT
	)
    WHILE @COUNT_PROVEEDORES >= @INCREMENTO
    BEGIN
         SET @ID_MONEDA_ACTUAL = (
                                            SELECT idTipoMoneda FROM #TABLA_PROVEEDORES WHERE idrow = @INCREMENTO
                                        );
        DELETE #TIPO_CAMBIO;


        INSERT INTO #TIPO_CAMBIO
        SELECT *
        FROM dbo.GetTipoCambioActual(@ID_MONEDA_ACTUAL, GETDATE());

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
        (
            Fila,
            IdFlujoTarea,
            ValorInicial,
            ValorFinal,
            Predeterminado,
            Nombre,
            Orden
        )
        EXEC dbo.SP_ObtenerFlujoAprobacionxValor @Total = @TotalSumaPedidos,                -- float

                                                 @IdProveedorCompras = @IdProveedorCompras; -- int
        SELECT @IdFlujo = IdFlujoTarea
        FROM @tablaFlujos
        WHERE Fila = 1;

        IF ISNULL(@IdFlujo, 0) = 0
        BEGIN
            -- NO SE ENCONTRO EL FLUJO EN EL SP, VOLVAMOS A BUSCARLO 
            SELECT @IdFlujo = IdFlujoTarea
            FROM dbo.TA_FlujoTarea
            WHERE IdProveedor = @IdProveedorCompras
                  AND Activo = 1
                  AND ISNULL(Eliminado, 0) = 0
                  AND IdTipoOperacion = 7
                  AND Predeterminado = 1;	 
        END;
		IF ISNULL(@IdFlujo, 0) = 0
		BEGIN
			INSERT INTO #RESULTADOSFLUJO(RESULT,FLOWID) VALUES ('ERROR',ISNULL(@IdFlujo, 0))

		END
		ELSE
		BEGIN 
			INSERT INTO #RESULTADOSFLUJO(RESULT,FLOWID) VALUES ('SUCCESS',ISNULL(@IdFlujo, 0))
			SET @TotalSumaPedidos = 0; --Resetear el valor del pedido
		END
		SET @INCREMENTO = @INCREMENTO + 1;
END
SELECT * FROM #RESULTADOSFLUJO
END
