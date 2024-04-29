IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_CO_GastosActualizar_Ins'
)
    DROP PROCEDURE p_CO_GastosActualizar_Ins
GO
CREATE proc [dbo].[p_CO_GastosActualizar_Ins]
    @Gastos CO_GastosActualizarType READONLY,
    @CreadoPor INT,
    @IdContrato INT
AS
BEGIN
    DECLARE @IdMaximo INT,
            @UUIDImport VARCHAR(100)

    CREATE TABLE #Gastos
    (
        Id INT,
        UUIDImport VARCHAR(100),
        RFCEmisor VARCHAR(18),
        UUID VARCHAR(100),
        CuentaContable VARCHAR(20),
        Poliza VARCHAR(20),
        GastoAdmon BIT,
        IdLineaPresupuesto INT,
        Error VARCHAR(8000)
    )

    SELECT @IdMaximo = ISNULL(MAX(Id), 0)
    FROM CO_GastosActualizar

    SELECT TOP 1
        @UUIDImport = UUIDImport
    FROM @Gastos

    INSERT INTO #Gastos
    (
        Id,
        UUIDImport,
        RFCEmisor,
        UUID,
        CuentaContable,
        Poliza,
        GastoAdmon,
        IdLineaPresupuesto,
        Error
    )
    SELECT Id,
           UUIDImport,
           RFCEmisor,
           UUID,
           CuentaContable,
           Poliza,
           GastoAdmon,
           IdLineaPresupuesto,
           Error
    FROM @Gastos

    ;WITH CTE
    AS (SELECT *,
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
        FROM #Gastos
       )
    UPDATE CTE
    SET Id = @IdMaximo + RowNum,
        IdLineaPresupuesto = CASE
                                 WHEN IdLineaPresupuesto = 0 THEN
                                     NULL
                                 ELSE
                                     IdLineaPresupuesto
                             END;



    INSERT INTO CO_GastosActualizar
    (
        Id,
        UUIDImport,
        RFCEmisor,
        UUID,
        CuentaContable,
        Poliza,
        GastoAdmon,
        Procesado,
        CreadoEl,
        CreadoPor,
        IdLineaPresupuesto,
        ErrorDesc,
        Error
    )
    SELECT Id,
           UUIDImport,
           RFCEmisor,
           UUID,
           CuentaContable,
           Poliza,
           GastoAdmon,
           0,
           GETDATE(),
           @CreadoPor,
           IdLineaPresupuesto,
           ISNULL(Error, ''),
           CASE
               WHEN ISNULL(Error, '') <> '' THEN
                   1
               ELSE
                   0
           END
    FROM #Gastos

    -- Aqui se agrega la misma logica que en el sp p_CO_GastosActualizar_Gen

    -- Validacion de datos
	UPDATE CO_GastosActualizar -- Se inhabilitan los que vienen con error de validacion del servidor
	SET Error = 1,
	Procesado = 1
	WHERE ISNULL(ErrorDesc, '') <> ''


	UPDATE CO_GastosActualizar
    SET Error = 1,
        Procesado = 1,
        ErrorDesc = ISNULL(ErrorDesc, '') + 'El RFC es requerido. '
    FROM CO_GastosActualizar 
    WHERE ISNULL(CO_GastosActualizar.RFCEmisor, '') = '' AND CO_GastosActualizar.UUIDImport = @UUIDImport


	UPDATE CO_GastosActualizar
    SET Error = 1,
        Procesado = 1,
        ErrorDesc = ISNULL(ErrorDesc, '') + 'El UUID es requerido. '
    FROM CO_GastosActualizar 
    WHERE ISNULL(CO_GastosActualizar.UUID, '') = '' AND CO_GastosActualizar.UUIDImport = @UUIDImport AND ISNULL(Error, 0) = 0


	UPDATE CO_GastosActualizar
    SET Error = 1,
        Procesado = 1,
        ErrorDesc = ISNULL(ErrorDesc, '') + 'La cuenta contable es requerida. '
    FROM CO_GastosActualizar
    WHERE ISNULL(CO_GastosActualizar.CuentaContable, '') = '' AND CO_GastosActualizar.UUIDImport = @UUIDImport


	UPDATE CO_GastosActualizar
    SET Error = 1,
        Procesado = 1,
        ErrorDesc = ISNULL(ErrorDesc, '') + 'La póliza es requerida. '
    FROM CO_GastosActualizar
    WHERE ISNULL(CO_GastosActualizar.Poliza, '') = '' AND CO_GastosActualizar.UUIDImport = @UUIDImport


    UPDATE CO_GastosActualizar
    SET Error = 1,
        Procesado = 1,
        ErrorDesc = ISNULL(ErrorDesc, '') + 'La factura no existe. '
    FROM CO_GastosActualizar 
        LEFT JOIN FI_Factura
            ON UPPER(CO_GastosActualizar.UUID) = UPPER(FI_Factura.UUID)
		LEFT JOIN #Gastos gastos
			ON CO_GastosActualizar.UUIDImport = @UUIDImport 
			AND UPPER(FI_Factura.UUID) = UPPER(gastos.UUID)
    WHERE FI_Factura.IdFactura IS NULL AND CO_GastosActualizar.UUIDImport = @UUIDImport

	UPDATE CO_GastosActualizar
    SET Error = 1,
        Procesado = 1,
        ErrorDesc = ISNULL(ErrorDesc, '') + 'La factura no pertenece al emisor. '
    FROM CO_GastosActualizar 
        INNER JOIN FI_Factura
            ON  CO_GastosActualizar.UUIDImport = @UUIDImport
			AND UPPER(CO_GastosActualizar.UUID) = UPPER(FI_Factura.UUID)
		INNER JOIN #Gastos gastos
			ON gastos.UUIDImport = @UUIDImport 
			AND UPPER(FI_Factura.UUID) = UPPER(gastos.UUID)
    WHERE CO_GastosActualizar.RFCEmisor <> FI_Factura.Emisor     


    UPDATE CO_GastosActualizar
    SET Error = 1,
        Procesado = 1,
        ErrorDesc = ISNULL(ErrorDesc, '') + 'La cuenta contable no existe. '
    FROM CO_GastosActualizar 
        INNER JOIN #Gastos gastos
            ON CO_GastosActualizar.Id = gastos.Id  
               AND CO_GastosActualizar.UUIDImport = @UUIDImport
               AND CO_GastosActualizar.UUIDImport = gastos.UUIDImport 
               AND UPPER(CO_GastosActualizar.UUID) = UPPER(gastos.UUID)
			   AND ISNULL(CO_GastosActualizar.CuentaContable, '') <> ''
        LEFT JOIN CO_CatalogoCuentaSH
            ON rtrim(CO_CatalogoCuentaSH.Nivel3) = rtrim(CO_GastosActualizar.CuentaContable)
		INNER JOIN CO_VersionCatalogoCuentasSH
			ON CO_CatalogoCuentaSH.IdVersion = CO_VersionCatalogoCuentasSH.IdVersion
				AND CO_VersionCatalogoCuentasSH.Activo = 1
    WHERE CO_CatalogoCuentaSH.IdCatalogoCuentasSH IS NULL AND CO_VersionCatalogoCuentasSH.Activo = 1

	UPDATE CO_GastosActualizar
    SET Error = 1,
        Procesado = 1,
        ErrorDesc = ISNULL(ErrorDesc, '') + 'La línea presupuesto no existe. '
    FROM CO_GastosActualizar 
        INNER JOIN #Gastos gastos
            ON CO_GastosActualizar.Id = gastos.Id 
               AND CO_GastosActualizar.UUIDImport = gastos.UUIDImport  
               AND UPPER(CO_GastosActualizar.UUID) = UPPER(gastos.UUID)
			   AND CO_GastosActualizar.UUIDImport = @UUIDImport
			   AND CO_GastosActualizar.IdLineaPresupuesto IS NOT NULL
        LEFT JOIN CO_LineapresupuestoMes
            ON  CO_GastosActualizar.IdLineaPresupuesto = CO_LineapresupuestoMes.IdLineaPresupuestoMes
    WHERE CO_GastosActualizar.UUIDImport = @UUIDImport AND CO_LineapresupuestoMes.IdLineaPresupuestoMes IS NULL

    UPDATE CO_GastosActualizar
    SET Error = 1,
        Procesado = 1,
        ErrorDesc = ISNULL(ErrorDesc, '') + 'La línea presupuesto no corresponde al contrato. '
    FROM CO_GastosActualizar 
        INNER JOIN #Gastos gastos
            ON CO_GastosActualizar.Id = gastos.Id 
               AND CO_GastosActualizar.UUIDImport = gastos.UUIDImport  
               AND UPPER(CO_GastosActualizar.UUID) = UPPER(gastos.UUID)
        INNER JOIN CO_LineapresupuestoMes
            ON CO_GastosActualizar.IdLineaPresupuesto = CO_LineapresupuestoMes.IdLineaPresupuestoMes
        INNER JOIN CO_PResupuesto
            on CO_LineapresupuestoMes.IdPresupuesto = CO_PResupuesto.IdPresupuesto
        INNER JOIN CO_ProgramaActividad
            on CO_PResupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad
        INNER JOIN CO_PeriodoContrato
            on CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
    WHERE CO_PeriodoContrato.IdContrato <> @IdContrato
          AND CO_GastosActualizar.UUIDImport = @UUIDImport

    -- se utiliza el CTE para obtener solo el primer registro como estaba antes del top 1
    
    ;WITH UltimosCatalogos
    AS (SELECT cr.IdRegistro,
               CO_GastosActualizar.Poliza,
               CO_GastosActualizar.GastoAdmon,
               CO_CatalogoCuentaSH.IdCatalogoCuentasSH,
               CASE
                   WHEN CO_GastosActualizar.IdLineaPresupuesto IS NULL THEN
                       cr.IdPrograma
                   ELSE
                       CO_GastosActualizar.IdLineaPresupuesto
               END AS IdPrograma,
               ROW_NUMBER() OVER (PARTITION BY cr.IdRegistro
                                  ORDER BY CO_CatalogoCuentaSH.IdVersion DESC
                                 ) AS RowNum
        FROM CO_Registro cr
            INNER JOIN FI_Factura
                ON FI_Factura.idFactura = cr.IdFactura
            INNER JOIN CO_GastosActualizar
                ON UPPER(FI_Factura.UUID) = UPPER(CO_GastosActualizar.UUID)
            INNER JOIN CO_CatalogoCuentaSH
                ON RTRIM(CO_CatalogoCuentaSH.Nivel3) = RTRIM(CO_GastosActualizar.CuentaContable)
        WHERE CO_GastosActualizar.Procesado = 0
              AND CO_GastosActualizar.Error = 0
              AND CO_GastosActualizar.UUIDImport = @UUIDImport
       )
    UPDATE CO_Registro
    SET Poliza = ro.Poliza,
        CostosAtribuiblesAdministracion = ro.GastoAdmon,
        IdCatalogoCuentasSH = ro.IdCatalogoCuentasSH,
        IdPrograma = ro.IdPrograma
    FROM CO_Registro cr
        INNER JOIN UltimosCatalogos ro
            ON cr.IdRegistro = ro.IdRegistro
               AND ro.RowNum = 1;

    SELECT RFCEmisor,
           UUID,
		   UUIDImport,
           CuentaContable,
           Poliza,
           CASE
               WHEN GastoAdmon = 0 THEN
                   2
               ELSE
                   1
           END AS GastoAdmon,
           IdLineaPresupuesto,
           ErrorDesc,
		   CreadoEl
    FROM CO_GastosActualizar
    WHERE UUIDImport = @UUIDImport

    -- Por ultimo se setea todos los registros como Procesados para que no se vuelvan a procesar
    UPDATE CO_GastosActualizar
    SET Procesado = 1
    FROM CO_GastosActualizar
    WHERE UUIDImport = @UUIDImport
	AND ISNULL(Error, 0) = 0

END