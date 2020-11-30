CREATE PROCEDURE [dbo].[BTU_VistaComparativa]
    @idContrato INT,
    @fechaMesDiaAnio DATE
AS
BEGIN
    --+-----------+-----------+--------+-----+------------+-------------- +---------+----------+----------------+
    --|IdContrato | Nombre P.E| Aceite | Gas | Condensado | Cromatografía | FactGas |FactAceite| FactCondensado |
    --+-----------+-----------+--------+-----+------------+---------------+---------+----------+----------------+
    --|           |           |        |     |            |               |         |          |                |
    --+-----------+-----------+--------+-----+------------+---------------+---------+----------+----------------+
    --|           |           |        |     |            |               |         |          |                |
    --+-----------+-----------+--------+-----+------------+---------------+---------+----------+----------------+
    --------- CREACIÓN DE LA TABLA
    --DROP TABLE #TemporalBTU
    CREATE TABLE #TemporalBTU
    (
        temporalId INT PRIMARY KEY IDENTITY(1, 1),
        IdPuntoEntrega INT,
        Nombre VARCHAR(50),
        Aceite FLOAT,
        Gas FLOAT,
        Condensado FLOAT,
        GasBN FLOAT,
        Cromatografia FLOAT,
        FacturaGas INT,
        FacturaAceite INT,
        FacturaCondensado INT,
    );
    --select * from #TemporalBTU;
    --CREAR TABLA DE HIDROCARBUROS |Acite | Gas | Condensado |
    CREATE TABLE #TemporalHidrocarburos
    (
        pktemp INT PRIMARY KEY NOT NULL IDENTITY(10000, 1),
        PuntoEntregaId INT,
        aceite FLOAT,
        gas FLOAT,
        condensado FLOAT,
        GasBN FLOAT
    );
    --INSERTAR EN LA TABLA LOS DATOS DE FILAS EN COLUMNAS 
    INSERT INTO #TemporalHidrocarburos (PuntoEntregaId, aceite, gas, condensado, GasBN)
    SELECT *
    FROM
    (
        SELECT CP.nombre,
               CASE
                   WHEN VolumenProgramado IS NULL THEN
                       0
                   ELSE
                       VolumenProgramado
               END AS Volumen,
               PE.PuntoEntregaID AS PuntoEntregaID
        FROM PR_ProduccionMensualSipac PS
        JOIN CO_PuntosdeEntrega PE ON PS.PuntoEntregaID = PE.PuntoEntregaID
        JOIN CO_ClasificacionProductoNominacion CP ON PS.idHidrocarburo = CP.ProductoNominacionID
        JOIN CO_UnidadMedida UM ON PS.idUnidadMedida = UM.idUnidadMedida
        WHERE MONTH(idFecha) = MONTH(@fechaMesDiaAnio)
              AND YEAR(idFecha) = YEAR(@fechaMesDiaAnio)
              AND idContrato = @idContrato
    ) AS SourceTable
    PIVOT
    (
        AVG([Volumen])
        FOR [nombre] IN ([Aceite], [Gas], [Condensado],[Gas BN])
    ) AS PivotTable;

    -----------------------
    ---INSERTAR LOS PUNTOS DE ENTREGA EN LA TABLA
    INSERT INTO #TemporalBTU (IdPuntoEntrega, Nombre)
    SELECT PEC.PuntoEntregaID,
           Nombre AS nombreMostrar
    FROM CO_PuntosdeEntrega PE
    JOIN CO_PuntosdeEntregaContrato PEC ON PE.PuntoEntregaID = PEC.PuntoEntregaID
    WHERE idContrato = @idContrato
          AND PE.Activo = 1;
    --and PEC.Activo=1
    ----------------------------
    ---- INSERTAR LOS PRODUCTOS, ACEITE|GAS | CONDENSADO
    UPDATE #TemporalBTU
    SET Aceite = #TemporalHidrocarburos.aceite,
        Gas = #TemporalHidrocarburos.gas,
        Condensado = #TemporalHidrocarburos.condensado,
		GasBN=#TemporalHidrocarburos.GasBN
    FROM #TemporalHidrocarburos
    WHERE #TemporalHidrocarburos.PuntoEntregaId = #TemporalBTU.IdPuntoEntrega;
    ----------------------------
    -- ACTUALIZAR GAS
    -----------------
    UPDATE #TemporalBTU
    SET FacturaGas = FI_FacturaPuntoEntrega.ProductoId
    FROM FI_FacturaPuntoEntrega
    WHERE FI_FacturaPuntoEntrega.PuntoEntregaId = #TemporalBTU.IdPuntoEntrega
          AND MONTH(MesReporte) = MONTH(@fechaMesDiaAnio)
          AND YEAR(MesReporte) = YEAR(@fechaMesDiaAnio)
          AND ProductoId = 1000;
    ----------------------------
    -- ACTUALIZAR ACEITE
    -----------------
    UPDATE #TemporalBTU
    SET FacturaAceite = FI_FacturaPuntoEntrega.ProductoId
    FROM FI_FacturaPuntoEntrega
    WHERE FI_FacturaPuntoEntrega.PuntoEntregaId = #TemporalBTU.IdPuntoEntrega
          AND MONTH(MesReporte) = MONTH(@fechaMesDiaAnio)
          AND YEAR(MesReporte) = YEAR(@fechaMesDiaAnio)
          AND ProductoId = 1001;
    ----------------------------
    -- ACTUALIZAR CONDENSADO
    -----------------
    UPDATE #TemporalBTU
    SET FacturaCondensado = FI_FacturaPuntoEntrega.ProductoId
    FROM FI_FacturaPuntoEntrega
    WHERE FI_FacturaPuntoEntrega.PuntoEntregaId = #TemporalBTU.IdPuntoEntrega
          AND MONTH(MesReporte) = MONTH(@fechaMesDiaAnio)
          AND YEAR(MesReporte) = YEAR(@fechaMesDiaAnio)
          AND ProductoId = 1002;
    -------------------------------------------------------------------------
    --Actualizar Cromatografia valores
    --
    CREATE TABLE #temporalCromato
    (
        idcromato INT PRIMARY KEY NOT NULL IDENTITY(1, 1),
        PuntoEntregaId INT,
        IdCromatografiaValor INT
    );
    ------ Insertar cromatografia en tabla temporal	
    INSERT INTO #temporalCromato (PuntoEntregaId, IdCromatografiaValor)
    SELECT PEC.PuntoEntregaID,
           IdCromatografiaValor
    FROM CO_Cromatografia C
    JOIN CO_CromatografiaValores CV ON C.IdCromatografia = CV.IdCromatografia
    JOIN [CO_PuntosdeEntregaContrato] PEC ON CV.IdPuntoEntregaContrato = PEC.PuntoEntregaContratoID
    WHERE C.IdContrato = @idContrato
          AND Mes = MONTH(@fechaMesDiaAnio)
          AND Anio = YEAR(@fechaMesDiaAnio)
          AND CV.IdPuntoEntregaContrato IN
              (
                  SELECT PuntoEntregaContratoID
                  FROM [CO_PuntosdeEntregaContrato]
                  WHERE idContrato = @idContrato
              );
    -------------------
    UPDATE #TemporalBTU
    SET Cromatografia = #temporalCromato.IdCromatografiaValor
    FROM #temporalCromato
    WHERE #temporalCromato.PuntoEntregaId = #TemporalBTU.IdPuntoEntrega;
    --------------------------------------------------
    --select * from #TemporalBTU
    ----------------------
    SELECT
        --  CASE WHEN temporalId IS NULL THEN 'No cargado' ELSE 'Cargado' END,
        Te.IdPuntoEntrega,
        Te.Nombre,
        --CASE WHEN Aceite IS NULL THEN 'NO' ELSE 'SI' END as Aceite,
        CASE
            WHEN Te.Aceite IS NULL THEN
                '0.0'
            ELSE
                Te.Aceite
        END AS Aceite,
        --CASE WHEN Gas IS NULL THEN 'NO' ELSE 'SI' END as Gas, 
        CASE
            WHEN Te.Gas IS NULL THEN
                '0.0'
            ELSE
                Te.Gas
        END AS Gas,
        --CASE WHEN Condensado IS NULL THEN 'NO' ELSE 'SI' END as Condensado,
        CASE
            WHEN Te.Condensado IS NULL THEN
                '0.0'
            ELSE
                Te.Condensado
        END AS Condensado,

		   CASE
            WHEN Te.GasBN IS NULL THEN
                '0.0'
            ELSE
                Te.GasBN
        END AS GasBN,

        CASE
            WHEN Cromatografia IS NULL THEN
             0  -- 'NO'
            ELSE
              1 -- 'SI'
        END AS Cromatografia,
        CASE
            WHEN FacturaGas IS NULL THEN
              0 -- 'NO'
            ELSE
             1 --  'SI'
        END AS FacturaGas,
        CASE
            WHEN FacturaAceite IS NULL THEN
             0 --  'NO'
            ELSE
             1 --  'SI'
        END AS FacturaAceite,
        CASE
            WHEN FacturaCondensado IS NULL THEN
             0 --  'NO'
            ELSE
              1  --'SI'
        END AS FacturaCondensado
    FROM #TemporalBTU AS Te;
END;

