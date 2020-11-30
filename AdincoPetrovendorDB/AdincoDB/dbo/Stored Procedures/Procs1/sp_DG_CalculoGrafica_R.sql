--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--SP para realizar calculos de graficas y guardarlos en DG_DatosGrafica
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


CREATE PROCEDURE [dbo].[sp_DG_CalculoGrafica_R] --3,8,1
    @IdContrato INT,
    @IdGrafica AS INT,
    @Language AS INT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;

END;

DECLARE @ContratoCNH NVARCHAR(MAX);
DELETE DG_DatosGrafica
WHERE IdGrafica = @IdGrafica
      AND Lenguaje = @Language
      AND IdContrato = @IdContrato;
/*
	    ====================================================================================
	    Precio WTS					Grafica 1
	    ====================================================================================	    
	    */

IF @IdGrafica = 1
BEGIN

    INSERT INTO DG_DatosGrafica
    (
        Titulo,
        Subtitulo,
        Titulo_yAxis,
        Titulo_xAxis,
        Fecha,
        Fecha_NuevoFormato,
        CantidadSeries,
        valueSuffix,
        SerieName0,
        SerieValues0,
        SerieType0,
        SerieColor0,
        IdGrafica,
        Lenguaje,
        IdContrato
    )
    SELECT CASE @Language
               WHEN 1 THEN
                   G.Titulo
               ELSE
                   G.Title
           END AS Titulo,
           CASE @Language
               WHEN 1 THEN
                   G.Subtitulo
               ELSE
                   G.Subtitle
           END AS Subtitulo,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_yAxis
               ELSE
                   G.Title_yAxis
           END AS Titulo_yAxis,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_xAxis
               ELSE
                   G.Title_xAxis
           END AS Titulo_xAxis,
           CONCAT(
                     RIGHT('00' + CAST(MONTH(PMM.Mes) AS VARCHAR(2)), 2),
                     ' ',
                     SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(PMM.Mes)), 0, 4),
                     ' ',
                     SUBSTRING(CAST(YEAR(PMM.Mes) AS VARCHAR(4)), 3, 2)
                 ) AS Fecha,
           CONVERT(VARCHAR, PMM.Mes, 111),
           1 AS CantidadSeries,
           'Dls' AS valueSuffix,
           G.Titulo AS SerieName0,
           PMM.Precio AS SerieValues0,
           'area' AS SerieType0,
           'blue' AS SerieColor0,
           @IdGrafica,
           @Language,
           @IdContrato
    FROM DG_Grafica G
        LEFT OUTER JOIN CO_PrecioMarcadorMensual PMM
            ON @IdGrafica = G.Id_Grafica
    WHERE IdMarcador = 10000
          AND IdContrato = @IdContrato;

END;
ELSE

/*
	    ====================================================================================
	    Presupuesto					Grafica 2
	    ====================================================================================	    
	    */

IF @IdGrafica = 2
BEGIN

    DECLARE @idpresupuesto AS INT;
    SELECT @idpresupuesto = CO_Presupuesto.IdPresupuesto
    FROM CO_ProgramaActividad
        INNER JOIN CO_PeriodoContrato
            ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
        INNER JOIN CO_Presupuesto
            ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
        INNER JOIN CO_Contrato
            ON CO_PeriodoContrato.IdContrato = CO_Contrato.IdContrato
    WHERE CO_Contrato.IdContrato = @IdContrato
          AND CO_Presupuesto.Actual = 1;
    SELECT CASE @Language
               WHEN 1 THEN
                   CO_Presupuesto.Nombre
               ELSE
                   CO_Presupuesto.Nombre
           END AS Titulo,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Subtitulo
               ELSE
                   DG_Grafica.Subtitle
           END AS Subtitulo,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Titulo_yAxis
               ELSE
                   DG_Grafica.Title_yAxis
           END AS Titulo_yAxis,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Titulo_xAxis
               ELSE
                   DG_Grafica.Title_xAxis
           END AS Titulo_xAxis,
           CONCAT(
                     RIGHT('00' + CAST(MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2),
                     ' ',
                     SUBSTRING(
                                  dbo.Fn_ObtenerNombreMes(@Language, MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES)),
                                  0,
                                  4
                              ),
                     ' ',
                     SUBSTRING(CAST(YEAR(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(4)), 3, 2)
                 ) AS Mes_Presupuestado,
           CONVERT(VARCHAR, CO_LineaPresupuestoMes.AC_PRESUP_MES, 111) AS fechaNuevoFormato,
           CASE @Language
               WHEN 1 THEN
                   'Presupuesto (USD)'
               ELSE
                   'Budget (USD)'
           END AS 'SerieName0',
           CAST(SUM(dbo.CO_LineaPresupuestoMes.Monto) AS INT) AS 'SerieValues0',
           CASE @Language
               WHEN 1 THEN
                   'Registrado (USD)'
               ELSE
                   'Registered (USD)'
           END AS 'SerieName1',
           SUM(   CASE
                      WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN
                          ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioDiario.TipoCambio
                      ELSE
                          0
                  END
              ) AS 'SerieValues1',
           ' Dls' AS 'valueSuffix',
           RAND(SUM(   CASE
                           WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN
                               ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioDiario.TipoCambio
                           ELSE
                               0
                       END
                   )
               ) AS monto,
           dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES
    INTO #tmp
    FROM dbo.CO_LineaPresupuestoMes
        LEFT OUTER JOIN CO_ActividadPetroleraCNH
            ON dbo.CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
        LEFT OUTER JOIN CO_SubactividadPetrolera
            ON dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
        LEFT OUTER JOIN CO_TareaPetrolera
            ON dbo.CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
        LEFT OUTER JOIN CO_ActividadCIEP
            ON dbo.CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
        LEFT OUTER JOIN CO_TipoServicio
            ON dbo.CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.ID_TIPOSER
        LEFT OUTER JOIN CO_SubactividadCIEP
            ON dbo.CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
        LEFT OUTER JOIN CO_Servicio
            ON dbo.CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
        LEFT OUTER JOIN CO_Area
            ON dbo.CO_LineaPresupuestoMes.IdArea = CO_Area.IdArea
        LEFT OUTER JOIN CO_Instalacion
            ON dbo.CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
        LEFT OUTER JOIN CO_Registro
            ON dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
        LEFT OUTER JOIN CO_ClasificacionAnexo4
            ON dbo.CO_LineaPresupuestoMes.IdAnexo4 = CO_ClasificacionAnexo4.IdAnexo4
        LEFT OUTER JOIN FI_Factura
            ON FI_Factura.IdFactura = CO_Registro.IdFactura
        LEFT OUTER JOIN CO_TipoCambioDiario
            ON CO_TipoCambioDiario.IdMoneda = FI_Factura.IdMoneda
               AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Factura.Fecha)
               AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Factura.Fecha)
               AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Factura.Fecha)
        LEFT OUTER JOIN CO_RubroInterno
            ON dbo.CO_LineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno
        LEFT OUTER JOIN DG_Grafica
            ON @IdGrafica = DG_Grafica.Id_Grafica
        JOIN CO_Presupuesto
            ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
    WHERE (dbo.CO_LineaPresupuestoMes.IdPresupuesto = @idpresupuesto)
    --and MONTH ( CO_LineaPresupuestoMes.AC_FEC_INI ) = @mes 
    GROUP BY
        -- dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
        dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES,
        CO_Presupuesto.Nombre,
        --DG_Grafica.Titulo,
        DG_Grafica.Title,
        DG_Grafica.Subtitulo,
        DG_Grafica.Subtitle,
        DG_Grafica.Titulo_yAxis,
        DG_Grafica.Title_yAxis,
        DG_Grafica.Titulo_xAxis,
        DG_Grafica.Title_xAxis
    ORDER BY -- Mes_Presupuestado;

        dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES; --,--Area;

    SELECT t2.AC_PRESUP_MES,
           SUM(   CASE
                      WHEN t1.AC_PRESUP_MES <= t2.AC_PRESUP_MES THEN
                          t1.SerieValues0
                      ELSE
                          0
                  END
              ) AS presupuesto,
           SUM(   CASE
                      WHEN t1.AC_PRESUP_MES <= t2.AC_PRESUP_MES THEN
                          t1.SerieValues1
                      ELSE
                          0
                  END
              ) AS gasto
    INTO #tmp2
    FROM #tmp t1
        CROSS JOIN #tmp t2
    GROUP BY t2.AC_PRESUP_MES
    ORDER BY t2.AC_PRESUP_MES;
    UPDATE t1
    SET SerieValues0 = t2.presupuesto,
        t1.SerieValues1 = t2.gasto
    FROM #tmp t1
        JOIN #tmp2 t2
            ON t1.AC_PRESUP_MES = t2.AC_PRESUP_MES;

    INSERT INTO DG_DatosGrafica
    (
        Titulo,
        Subtitulo,
        Titulo_yAxis,
        Titulo_xAxis,
        Fecha,
        Fecha_NuevoFormato,
        CantidadSeries,
        valueSuffix,
        SerieName0,
        SerieValues0,
        SerieType0,
        SerieColor0,
        SerieName1,
        SerieValues1,
        SerieType1,
        SerieColor1,
        IdGrafica,
        Lenguaje,
        IdContrato
    )
    SELECT Titulo,
           Subtitulo,
           Titulo_yAxis,
           Titulo_xAxis,
           Mes_Presupuestado,
           fechaNuevoFormato,
           2,
           valueSuffix,
           SerieName0,
           CAST(SerieValues0 AS INT) AS SerieValues0,
           'line',
           'blue',
           SerieName1,
           CAST(SerieValues1 AS INT) AS SerieValues1,
           'line',
           'green',
           @IdGrafica,
           @Language,
           @IdContrato
    FROM #tmp
    ORDER BY AC_PRESUP_MES;

END;

/*
	    ====================================================================================
	    Producción: Volumen contractual de petróleo			Grafica 11
	    ====================================================================================	    
	    */

ELSE IF @IdGrafica = 11
BEGIN

    SELECT CASE @Language
               WHEN 1 THEN
                   G.Titulo
               ELSE
                   G.Title
           END AS Titulo,
           CASE @Language
               WHEN 1 THEN
                   G.Subtitulo
               ELSE
                   G.Subtitle
           END AS Subtitulo,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_yAxis
               ELSE
                   G.Title_yAxis
           END AS Titulo_yAxis,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_xAxis
               ELSE
                   G.Title_xAxis
           END AS Titulo_xAxis,
           CONCAT(
                     SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2),
                     ' ',
                     RIGHT('00' + CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2),
                     ' ',
                     SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)), 0, 4)
                 ) AS Fecha,
           CONVERT(VARCHAR, VMPP.MesReporte, 111) AS fechaNuevoFormato,
           2 AS CantidadSeries,
           ' Bls' AS valueSuffix,
           CASE @Language
               WHEN 1 THEN
                   'Mensual'
               ELSE
                   'Monthly'
           END AS SerieName0,
           --ROUND(VMPP.VolumenPetroleoPuntoMedicion / 1000, 2) AS SerieValues0,
           ROUND(VMPP.VolumenPetroleoPuntoMedicion, 0) AS SerieValues0,
           'line' AS SerieType0,
           'green' AS SerieColor0,
           CASE @Language
               WHEN 1 THEN
                   'Acumulado'
               ELSE
                   'Accumulated'
           END AS SerieName1,
           --ROUND(VMPP.VolumenPetroleoPuntoMedicion / 1000, 2) AS SerieValues1,
           ROUND(VMPP.VolumenPetroleoPuntoMedicion, 0) AS SerieValues1,
           'line' AS SerieType1,
           'gray' AS SerieColor1,
           VMPP.MesReporte
    INTO #VolumenPetroleo
    FROM DG_Grafica G
        LEFT OUTER JOIN PR_VolumenMensualProduccionPetroleo VMPP
            ON @IdGrafica = G.Id_Grafica
    WHERE IdContrato = @IdContrato
    ORDER BY CONCAT(
                       SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2),
                       ' ',
                       RIGHT('00' + CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2),
                       ' ',
                       SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)), 0, 4)
                   );
    -- SELECT* FROM #VolumenPetroleo

    --|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    -- Acumular
    --|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    SELECT t2.MesReporte,
           SUM(   CASE
                      WHEN t1.MesReporte <= t2.MesReporte THEN
                          t1.SerieValues1
                      ELSE
                          0
                  END
              ) AS acumulado
    INTO #ProduccionPetroleo
    FROM #VolumenPetroleo t1
        CROSS JOIN #VolumenPetroleo t2
    GROUP BY t2.MesReporte
    ORDER BY t2.MesReporte;

    --||||||||||||||||||||||||||||||||||||||||||||
    UPDATE t1
    SET t1.SerieValues1 = t2.acumulado
    FROM #VolumenPetroleo t1
        JOIN #ProduccionPetroleo t2
            ON t1.MesReporte = t2.MesReporte;
    INSERT INTO DG_DatosGrafica
    (
        Titulo,
        Subtitulo,
        Titulo_yAxis,
        Titulo_xAxis,
        Fecha,
        Fecha_NuevoFormato,
        CantidadSeries,
        valueSuffix,
        SerieName0,
        SerieValues0,
        SerieType0,
        SerieColor0,
        SerieName1,
        SerieValues1,
        SerieType1,
        SerieColor1,
        IdGrafica,
        Lenguaje,
        IdContrato
    )
    SELECT Titulo,
           Subtitulo,
           Titulo_yAxis,
           Titulo_xAxis,
           Fecha,
           fechaNuevoFormato,
           CantidadSeries,
           valueSuffix,
           SerieName0,
           SerieValues0,
           SerieType0,
           SerieColor0,
           SerieName1,
           SerieValues1,
           SerieType1,
           SerieColor1,
           @IdGrafica,
           @Language,
           @IdContrato
    FROM #VolumenPetroleo;

END;

/*	    ====================================================================================
	    Producción: Gas Asociado			Grafica 12
	    ====================================================================================	    
	    */

ELSE IF @IdGrafica = 12
BEGIN

    SELECT CASE @Language
               WHEN 1 THEN
                   G.Titulo
               ELSE
                   G.Title
           END AS Titulo,
           CASE @Language
               WHEN 1 THEN
                   G.Subtitulo
               ELSE
                   G.Subtitle
           END AS Subtitulo,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_yAxis
               ELSE
                   G.Title_yAxis
           END AS Titulo_yAxis,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_xAxis
               ELSE
                   G.Title_xAxis
           END AS Titulo_xAxis,
           CONCAT(
                     SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2),
                     ' ',
                     RIGHT('00' + CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2),
                     ' ',
                     SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)), 0, 4)
                 ) AS Fecha,
           CONVERT(VARCHAR, VMPP.MesReporte, 111) AS fechaNuevoFormato,
           2 AS CantidadSeries,
           ' MMBTU' AS valueSuffix,
           CASE @Language
               WHEN 1 THEN
                   'Metano C1'
               ELSE
                   'Methane C1'
           END AS SerieName0,
           VMPP.MetanoC1 AS SerieValues0,
           'line' AS SerieType0,
           'blue' AS SerieColor0,
           CASE @Language
               WHEN 1 THEN
                   'Etano C2'
               ELSE
                   'Ethane C2'
           END AS SerieName1,
           VMPP.EtanoC2 AS SerieValues1,
           'line' AS SerieType1,
           'blue' AS SerieColor1,
           CASE @Language
               WHEN 1 THEN
                   'Propano C3'
               ELSE
                   'Propane C3'
           END AS SerieName2,
           VMPP.PropanoC3 AS SerieValues2,
           'line' AS SerieType2,
           'blue' AS SerieColor2,
           CASE @Language
               WHEN 1 THEN
                   'Butano C4'
               ELSE
                   'Butane C4'
           END AS SerieName3,
           VMPP.ButanoC4 AS SerieValues3,
           'line' AS SerieType3,
           'blue' AS SerieColor3,
           CASE @Language
               WHEN 1 THEN
                   'Gas '
               ELSE
                   ' Gas'
           END AS SerieName4,
           VMPP.MetanoC1 + VMPP.EtanoC2 + VMPP.PropanoC3 + VMPP.ButanoC4 AS SerieValues4,
           'line' AS SerieType4,
           'blue' AS SerieColor4,
           CASE @Language
               WHEN 1 THEN
                   'Gas  Acumulado'
               ELSE
                   'Acum.  Gas'
           END AS SerieName5,
           0 AS SerieValues5,
           'line' AS SerieType5,
           'blue' AS SerieColor5,
           VMPP.MesReporte
    INTO #VolumenGas
    FROM DG_Grafica G
        LEFT OUTER JOIN PR_VolumenMensualProduccionPetroleo VMPP
            ON @IdGrafica = G.Id_Grafica
    WHERE IdContrato = @IdContrato
    ORDER BY CONCAT(
                       SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2),
                       ' ',
                       RIGHT('00' + CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2),
                       ' ',
                       SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)), 0, 4)
                   );
    --||||||||||||||||||||||||||||||||||||||||||||
    -- Acumular
    --||||||||||||||||||||||||||||||||||||||||||||
    SELECT t2.MesReporte,
           SUM(   CASE
                      WHEN t1.MesReporte <= t2.MesReporte THEN
                          t1.SerieValues4
                      ELSE
                          0
                  END
              ) AS acumulado
    INTO #ProduccionGas
    FROM #VolumenGas t1
        CROSS JOIN #VolumenGas t2
    GROUP BY t2.MesReporte
    ORDER BY t2.MesReporte;

    --||||||||||||||||||||||||||||||||||||||||||||
    UPDATE t1
    SET t1.SerieValues5 = t2.acumulado
    FROM #VolumenGas t1
        JOIN #ProduccionGas t2
            ON t1.MesReporte = t2.MesReporte;
    INSERT INTO DG_DatosGrafica
    (
        Titulo,
        Subtitulo,
        Titulo_yAxis,
        Titulo_xAxis,
        Fecha,
        Fecha_NuevoFormato,
        CantidadSeries,
        valueSuffix,
        SerieName0,
        SerieValues0,
        SerieType0,
        SerieColor0,
        SerieName1,
        SerieValues1,
        SerieType1,
        SerieColor1,
        SerieName2,
        SerieValues2,
        SerieType2,
        SerieColor2,
        SerieName3,
        SerieValues3,
        SerieType3,
        SerieColor3,
        SerieName4,
        SerieValues4,
        SerieType4,
        SerieColor4,
        SerieName5,
        SerieValues5,
        SerieType5,
        SerieColor5,
        IdGrafica,
        Lenguaje,
        IdContrato
    )
    SELECT Titulo,
           Subtitulo,
           Titulo_yAxis,
           Titulo_xAxis,
           Fecha,
           CantidadSeries,
           valueSuffix,
           fechaNuevoFormato,
           SerieName5,
           SerieValues5,
           SerieType5,
           SerieColor5,
           SerieName4,
           SerieValues4,
           SerieType4,
           SerieColor4,
           SerieName0,
           SerieValues0,
           SerieType0,
           SerieColor0,
           SerieName1,
           SerieValues1,
           SerieType1,
           SerieColor1,
           SerieName2,
           SerieValues2,
           SerieType2,
           SerieColor2,
           SerieName3,
           SerieValues3,
           SerieType3,
           SerieColor3,
           @IdGrafica,
           @Language,
           @IdContrato
    FROM #VolumenGas;

END;

/*
	   ====================================================================================
	    Producción: Volumen contractual de condensado				Grafica 13
	    ====================================================================================	    
	    */

ELSE IF @IdGrafica = 13
BEGIN

    SELECT CASE @Language
               WHEN 1 THEN
                   G.Titulo
               ELSE
                   G.Title
           END AS Titulo,
           CASE @Language
               WHEN 1 THEN
                   G.Subtitulo
               ELSE
                   G.Subtitle
           END AS Subtitulo,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_yAxis
               ELSE
                   G.Title_yAxis
           END AS Titulo_yAxis,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_xAxis
               ELSE
                   G.Title_xAxis
           END AS Titulo_xAxis,
           CONCAT(
                     RIGHT('00' + CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2),
                     ' ',
                     SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)), 0, 4),
                     ' ',
                     SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2)
                 ) AS Fecha,
           CONVERT(VARCHAR, VMPP.MesReporte, 111) AS fechaNuevoFormato,
           2 AS CantidadSeries,
           ' MBls' AS valueSuffix,
           CASE @Language
               WHEN 1 THEN
                   'Mensual'
               ELSE
                   'Monthly'
           END AS SerieName0,
           ROUND(VMPP.VolumenCondensadoPuntoMedicion / 1000, 2) AS SerieValues0,
           'line' AS SerieType0,
           'gray' AS SerieColor0,
           CASE @Language
               WHEN 1 THEN
                   'Acumulado'
               ELSE
                   'Accumulated'
           END AS SerieName1,
           ROUND(VMPP.VolumenCondensadoPuntoMedicion / 1000, 2) AS SerieValues1,
           'line' AS SerieType1,
           'green' AS SerieColor1,
           VMPP.MesReporte
    INTO #VolumenCondensado
    FROM DG_Grafica G
        LEFT OUTER JOIN PR_VolumenMensualProduccionPetroleo VMPP
            ON @IdGrafica = G.Id_Grafica
    WHERE IdContrato = @IdContrato;

    -- SELECT* FROM #VolumenPetroleo

    --||||||||||||||||||||||||||||||||||||||||||||
    -- Acumular
    --||||||||||||||||||||||||||||||||||||||||||||
    SELECT t2.MesReporte,
           SUM(   CASE
                      WHEN t1.MesReporte <= t2.MesReporte THEN
                          t1.SerieValues1
                      ELSE
                          0
                  END
              ) AS acumulado
    INTO #ProduccionCondensado
    FROM #VolumenCondensado t1
        CROSS JOIN #VolumenCondensado t2
    GROUP BY t2.MesReporte
    ORDER BY t2.MesReporte;

    --||||||||||||||||||||||||||||||||||||||||||||
    UPDATE t1
    SET t1.SerieValues1 = t2.acumulado
    FROM #VolumenCondensado t1
        JOIN #ProduccionCondensado t2
            ON t1.MesReporte = t2.MesReporte;

    INSERT INTO DG_DatosGrafica
    (
        Titulo,
        Subtitulo,
        Titulo_yAxis,
        Titulo_xAxis,
        Fecha,
        Fecha_NuevoFormato,
        CantidadSeries,
        valueSuffix,
        SerieName0,
        SerieValues0,
        SerieType0,
        SerieColor0,
        SerieName1,
        SerieValues1,
        SerieType1,
        SerieColor1,
        IdGrafica,
        Lenguaje,
        IdContrato
    )
    SELECT Titulo,
           Subtitulo,
           Titulo_yAxis,
           Titulo_xAxis,
           Fecha,
           fechaNuevoFormato,
           CantidadSeries,
           valueSuffix,
           SerieName0,
           SerieValues0,
           SerieType0,
           SerieColor0,
           SerieName1,
           SerieValues1,
           SerieType1,
           SerieColor1,
           @IdGrafica,
           @Language,
           @IdContrato
    FROM #VolumenCondensado;

END;


/*
	   ====================================================================================
	    Producción: Volumen entrega de petroleo contratista				grafica 14
	    ====================================================================================	    
	    */

ELSE IF @IdGrafica = 14
BEGIN

    SELECT @ContratoCNH = NumeroContrato
    FROM dbo.CO_Contrato
    WHERE IdContrato = @IdContrato;
    --AA_RMP_CONT_32
    --                SELECT RMPCT32_28 AS Peliminar,
    --RMPCT32_28 + RMPCT32_40 AS Final
    --                FROM AA_RMP_CONT_32
    --                WHERE RF01_01 = @ContratoCNH;

    SELECT CASE @Language
               WHEN 1 THEN
                   G.Titulo
               ELSE
                   G.Title
           END AS Titulo,
           CASE @Language
               WHEN 1 THEN
                   G.Subtitulo
               ELSE
                   G.Subtitle
           END AS Subtitulo,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_yAxis
               ELSE
                   G.Title_yAxis
           END AS Titulo_yAxis,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_xAxis
               ELSE
                   G.Title_xAxis
           END AS Titulo_xAxis,
           CONCAT(
                     RIGHT('00' + CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2),
                     ' ',
                     SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, VMPP.RMPCT32_00), 0, 4),
                     ' ',
                     SUBSTRING(CAST(RMPCT32_01 AS VARCHAR(4)), 3, 2)
                 ) AS Fecha,
           CONCAT(RMPCT32_01, '/', RIGHT('00' + CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2), '/01') AS fechaNuevoFormato,
           2 AS CantidadSeries,
           ' MBls' AS valueSuffix,
           CASE @Language
               WHEN 1 THEN
                   'Preliminar'
               ELSE
                   'Preliminar'
           END AS SerieName0,
           ROUND(VMPP.RMPCT32_28 / 1000, 2) AS SerieValues0,
           'line' AS SerieType0,
           'gray' AS SerieColor0,
           CASE @Language
               WHEN 1 THEN
                   'Final'
               ELSE
                   'Final'
           END AS SerieName1,
           ROUND((VMPP.RMPCT32_28 + RMPCT32_40) / 1000, 2) AS SerieValues1,
           'line' AS SerieType1,
           'green' AS SerieColor1,
           CASE @Language
               WHEN 1 THEN
                   'Acumulado'
               ELSE
                   'Acumulado'
           END AS SerieName2,
           ROUND((VMPP.RMPCT32_28 + RMPCT32_40) / 1000, 2) AS SerieValues2,
           'line' AS SerieType2,
           'green' AS SerieColor2,
           DATEFROMPARTS(VMPP.RMPCT32_01, VMPP.RMPCT32_00, 1) AS MesReporte
    INTO #VolumenEntregaPetroleo
    FROM AA_RMP_CONT_32 VMPP
        LEFT JOIN DG_Grafica G
            ON @IdGrafica = G.Id_Grafica
    WHERE RTRIM(VMPP.RF01_01) = RTRIM(@ContratoCNH); --AND 
    -- g.Id_Grafica= 14

    -- SELECT* FROM #VolumenEntregaPetroleo

    --||||||||||||||||||||||||||||||||||||||||||||
    -- Acumular
    --||||||||||||||||||||||||||||||||||||||||||||
    SELECT t2.MesReporte,
           SUM(   CASE
                      WHEN t1.MesReporte <= t2.MesReporte THEN
                          t1.SerieValues1
                      ELSE
                          0
                  END
              ) AS acumulado
    INTO #ProduccionEntregaPetroleo
    FROM #VolumenEntregaPetroleo t1
        CROSS JOIN #VolumenEntregaPetroleo t2
    GROUP BY t2.MesReporte
    ORDER BY t2.MesReporte;

    --||||||||||||||||||||||||||||||||||||||||||||
    UPDATE t1
    SET t1.SerieValues2 = t2.acumulado
    FROM #VolumenEntregaPetroleo t1
        JOIN #ProduccionEntregaPetroleo t2
            ON t1.MesReporte = t2.MesReporte;

    INSERT INTO DG_DatosGrafica
    (
        Titulo,
        Subtitulo,
        Titulo_yAxis,
        Titulo_xAxis,
        Fecha,
        Fecha_NuevoFormato,
        CantidadSeries,
        valueSuffix,
        SerieName0,
        SerieValues0,
        SerieType0,
        SerieColor0,
        SerieName1,
        SerieValues1,
        SerieType1,
        SerieColor1,
        SerieName2,
        SerieValues2,
        SerieType2,
        SerieColor2,
        IdGrafica,
        Lenguaje,
        IdContrato
    )
    SELECT Titulo,
           Subtitulo,
           Titulo_yAxis,
           Titulo_xAxis,
           Fecha,
           fechaNuevoFormato,
           CantidadSeries,
           valueSuffix,
           SerieName0,
           SerieValues0,
           SerieType0,
           SerieColor0,
           SerieName1,
           SerieValues1,
           SerieType1,
           SerieColor1,
           SerieName2,
           SerieValues2,
           SerieType2,
           SerieColor2,
           @IdGrafica,
           @Language,
           @IdContrato
    FROM #VolumenEntregaPetroleo;

END;

/*
	   ====================================================================================
	    Producción: Volumen entrega de condensado contratista				grafica 15
	    ====================================================================================	    
	    */

ELSE IF @IdGrafica = 15
BEGIN

    --DECLARE @ContratoCNH NVARCHAR(MAX);
    SELECT @ContratoCNH = NumeroContrato
    FROM dbo.CO_Contrato
    WHERE IdContrato = @IdContrato;

    --AA_RMP_CONT_32
    --                SELECT RMPCT32_28 AS Peliminar,
    --RMPCT32_28 + RMPCT32_40 AS Final
    --                FROM AA_RMP_CONT_32
    --                WHERE RF01_01 = @ContratoCNH;

    SELECT CASE @Language
               WHEN 1 THEN
                   G.Titulo
               ELSE
                   G.Title
           END AS Titulo,
           CASE @Language
               WHEN 1 THEN
                   G.Subtitulo
               ELSE
                   G.Subtitle
           END AS Subtitulo,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_yAxis
               ELSE
                   G.Title_yAxis
           END AS Titulo_yAxis,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_xAxis
               ELSE
                   G.Title_xAxis
           END AS Titulo_xAxis,
           CONCAT(
                     RIGHT('00' + CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2),
                     ' ',
                     SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, VMPP.RMPCT32_00), 0, 4),
                     ' ',
                     SUBSTRING(CAST(RMPCT32_01 AS VARCHAR(4)), 3, 2)
                 ) AS Fecha,
           CONCAT(RMPCT32_01, '/', RIGHT('00' + CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2), '/01') AS fechaNuevoFormato,
           2 AS CantidadSeries,
           ' MBls' AS valueSuffix,
           CASE @Language
               WHEN 1 THEN
                   'Preliminar'
               ELSE
                   'Preliminar'
           END AS SerieName0,
           ROUND(VMPP.RMPCT32_33 / 1000, 2) AS SerieValues0,
           'line' AS SerieType0,
           'gray' AS SerieColor0,
           CASE @Language
               WHEN 1 THEN
                   'Final'
               ELSE
                   'Final'
           END AS SerieName1,
           ROUND((VMPP.RMPCT32_33 + RMPCT32_45) / 1000, 2) AS SerieValues1,
           'line' AS SerieType1,
           'green' AS SerieColor1,
           CASE @Language
               WHEN 1 THEN
                   'Acumulado'
               ELSE
                   'Acumulado'
           END AS SerieName2,
           ROUND((VMPP.RMPCT32_33 + RMPCT32_45) / 1000, 2) AS SerieValues2,
           'line' AS SerieType2,
           'green' AS SerieColor2,
           DATEFROMPARTS(VMPP.RMPCT32_01, VMPP.RMPCT32_00, 1) AS MesReporte
    INTO #VolumenEntregaCondensado
    FROM AA_RMP_CONT_32 VMPP
        LEFT JOIN DG_Grafica G
            ON @IdGrafica = G.Id_Grafica
    WHERE RTRIM(VMPP.RF01_01) = RTRIM(@ContratoCNH); --AND 
    -- g.Id_Grafica= 14

    -- SELECT* FROM #VolumenEntregaPetroleo

    --||||||||||||||||||||||||||||||||||||||||||||
    -- Acumular
    --||||||||||||||||||||||||||||||||||||||||||||
    SELECT t2.MesReporte,
           SUM(   CASE
                      WHEN t1.MesReporte <= t2.MesReporte THEN
                          t1.SerieValues1
                      ELSE
                          0
                  END
              ) AS acumulado
    INTO #ProduccionEntregaCondensado
    FROM #VolumenEntregaCondensado t1
        CROSS JOIN #VolumenEntregaCondensado t2
    GROUP BY t2.MesReporte
    ORDER BY t2.MesReporte;

    --||||||||||||||||||||||||||||||||||||||||||||
    UPDATE t1
    SET t1.SerieValues2 = t2.acumulado
    FROM #VolumenEntregaCondensado t1
        JOIN #ProduccionEntregaCondensado t2
            ON t1.MesReporte = t2.MesReporte;
    INSERT INTO DG_DatosGrafica
    (
        Titulo,
        Subtitulo,
        Titulo_yAxis,
        Titulo_xAxis,
        Fecha,
        Fecha_NuevoFormato,
        CantidadSeries,
        valueSuffix,
        SerieName0,
        SerieValues0,
        SerieType0,
        SerieColor0,
        SerieName1,
        SerieValues1,
        SerieType1,
        SerieColor1,
        SerieName2,
        SerieValues2,
        SerieType2,
        SerieColor2,
        IdGrafica,
        Lenguaje,
        IdContrato
    )
    SELECT Titulo,
           Subtitulo,
           Titulo_yAxis,
           Titulo_xAxis,
           Fecha,
           fechaNuevoFormato,
           CantidadSeries,
           valueSuffix,
           SerieName0,
           SerieValues0,
           SerieType0,
           SerieColor0,
           SerieName1,
           SerieValues1,
           SerieType1,
           SerieColor1,
           SerieName2,
           SerieValues2,
           SerieType2,
           SerieColor2,
           @IdGrafica,
           @Language,
           @IdContrato
    FROM #VolumenEntregaCondensado;

END;


/*
	   ====================================================================================
	    Producción: Volumen entrega de condensado contratista				Grafica 16
	    ====================================================================================	    
	    */

ELSE IF @IdGrafica = 16
BEGIN

    --DECLARE @ContratoCNH NVARCHAR(MAX);
    SELECT @ContratoCNH = NumeroContrato
    FROM dbo.CO_Contrato
    WHERE IdContrato = @IdContrato;

    --AA_RMP_CONT_32
    --                SELECT RMPCT32_28 AS Peliminar,
    --RMPCT32_28 + RMPCT32_40 AS Final
    --                FROM AA_RMP_CONT_32
    --                WHERE RF01_01 = @ContratoCNH;

    SELECT CASE @Language
               WHEN 1 THEN
                   G.Titulo
               ELSE
                   G.Title
           END AS Titulo,
           CASE @Language
               WHEN 1 THEN
                   G.Subtitulo
               ELSE
                   G.Subtitle
           END AS Subtitulo,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_yAxis
               ELSE
                   G.Title_yAxis
           END AS Titulo_yAxis,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_xAxis
               ELSE
                   G.Title_xAxis
           END AS Titulo_xAxis,
           CONCAT(
                     RIGHT('00' + CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2),
                     ' ',
                     SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, VMPP.RMPCT32_00), 0, 4),
                     ' ',
                     SUBSTRING(CAST(RMPCT32_01 AS VARCHAR(4)), 3, 2)
                 ) AS Fecha,
           CONCAT(RMPCT32_01, '/', RIGHT('00' + CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2), '/01') AS fechaNuevoFormato,
           2 AS CantidadSeries,
           ' MBls' AS valueSuffix,
           CASE @Language
               WHEN 1 THEN
                   'Preliminar'
               ELSE
                   'Preliminar'
           END AS SerieName0,
           ROUND(VMPP.RMPCT32_33 / 1000, 2) AS SerieValues0,
           'line' AS SerieType0,
           'gray' AS SerieColor0,
           CASE @Language
               WHEN 1 THEN
                   'Final'
               ELSE
                   'Final'
           END AS SerieName1,
           ROUND((VMPP.RMPCT32_33 + RMPCT32_45) / 1000, 2) AS SerieValues1,
           'line' AS SerieType1,
           'green' AS SerieColor1,
           CASE @Language
               WHEN 1 THEN
                   'Acumulado'
               ELSE
                   'Acumulado'
           END AS SerieName2,
           ROUND((VMPP.RMPCT32_33 + RMPCT32_45) / 1000, 2) AS SerieValues2,
           'line' AS SerieType2,
           'green' AS SerieColor2,
           DATEFROMPARTS(VMPP.RMPCT32_01, VMPP.RMPCT32_00, 1) AS MesReporte
    INTO #VolumenEntregaGas
    FROM AA_RMP_CONT_32 VMPP
        LEFT JOIN DG_Grafica G
            ON @IdGrafica = G.Id_Grafica
    WHERE RTRIM(VMPP.RF01_01) = RTRIM(@ContratoCNH); --AND 
    -- g.Id_Grafica= 14

    -- SELECT* FROM #VolumenEntregaPetroleo

    --||||||||||||||||||||||||||||||||||||||||||||
    -- Acumular
    --||||||||||||||||||||||||||||||||||||||||||||
    SELECT t2.MesReporte,
           SUM(   CASE
                      WHEN t1.MesReporte <= t2.MesReporte THEN
                          t1.SerieValues1
                      ELSE
                          0
                  END
              ) AS acumulado
    INTO #ProduccionEntregaGas
    FROM #VolumenEntregaGas t1
        CROSS JOIN #VolumenEntregaGas t2
    GROUP BY t2.MesReporte
    ORDER BY t2.MesReporte;

    --||||||||||||||||||||||||||||||||||||||||||||
    UPDATE t1
    SET t1.SerieValues2 = t2.acumulado
    FROM #VolumenEntregaGas t1
        JOIN #ProduccionEntregaGas t2
            ON t1.MesReporte = t2.MesReporte;
    INSERT INTO DG_DatosGrafica
    (
        Titulo,
        Subtitulo,
        Titulo_yAxis,
        Titulo_xAxis,
        Fecha,
        Fecha_NuevoFormato,
        CantidadSeries,
        valueSuffix,
        SerieName0,
        SerieValues0,
        SerieType0,
        SerieColor0,
        SerieName1,
        SerieValues1,
        SerieType1,
        SerieColor1,
        SerieName2,
        SerieValues2,
        SerieType2,
        SerieColor2,
        IdGrafica,
        Lenguaje,
        IdContrato
    )
    SELECT Titulo,
           Subtitulo,
           Titulo_yAxis,
           Titulo_xAxis,
           Fecha,
           fechaNuevoFormato,
           CantidadSeries,
           valueSuffix,
           SerieName0,
           SerieValues0,
           SerieType0,
           SerieColor0,
           SerieName1,
           SerieValues1,
           SerieType1,
           SerieColor1,
           SerieName2,
           SerieValues2,
           SerieType2,
           SerieColor2,
           @IdGrafica,
           @Language,
           @IdContrato
    FROM #VolumenEntregaGas;

END;



/*
	    ====================================================================================
	    Precio Venta Petroleo     Grafica 17
	    ====================================================================================	    
	    */

IF @IdGrafica = 17
BEGIN

    SELECT CASE @Language
               WHEN 1 THEN
                   'Precio de Venta Petroleo'
               ELSE
                   'Precio de Venta Petroleo'
           END AS Titulo,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Subtitulo
               ELSE
                   DG_Grafica.Subtitle
           END AS Subtitulo,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Titulo_yAxis
               ELSE
                   DG_Grafica.Title_yAxis
           END AS Titulo_yAxis,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Titulo_xAxis
               ELSE
                   DG_Grafica.Title_xAxis
           END AS Titulo_xAxis,
           PA.Anio AS Mes_Presupuestado,
           CONVERT(VARCHAR, PA.Anio, 111) AS fechaNuevoFormato,
           CASE @Language
               WHEN 1 THEN
                   'Plan Price (USD)'
               ELSE
                   'Plan Precio (USD)'
           END AS 'SerieName0',
           SUM(PA.PetroleoUSDBl) AS 'SerieValues0',
           CASE @Language
               WHEN 1 THEN
                   'Real Price (USD)'
               ELSE
                   'Real Precio (USD)'
           END AS 'SerieName1',
           ISNULL(SUM(PA.RealPetroleoUSDBl), 0) AS 'SerieValues1',
           ' USD Bl' AS 'valueSuffix'
    INTO #tmpprecioscrudo
    FROM AA_PlanPrecioVentaHidrocarburoAnual PA
        LEFT OUTER JOIN DG_Grafica
            ON @IdGrafica = DG_Grafica.Id_Grafica
    WHERE (PA.IdContrato = @IdContrato)
    GROUP BY

        -- PA,Anio,
        DG_Grafica.Title,
        DG_Grafica.Subtitulo,
        DG_Grafica.Subtitle,
        DG_Grafica.Titulo_yAxis,
        DG_Grafica.Title_yAxis,
        DG_Grafica.Titulo_xAxis,
        DG_Grafica.Title_xAxis,
        PA.Anio;
    --    ORDER BY-- Mes_Presupuestado;
    INSERT INTO DG_DatosGrafica
    (
        Titulo,
        Subtitulo,
        Titulo_yAxis,
        Titulo_xAxis,
        Fecha,
        Fecha_NuevoFormato,
        CantidadSeries,
        valueSuffix,
        SerieName0,
        SerieValues0,
        SerieType0,
        SerieColor0,
        SerieName1,
        SerieValues1,
        SerieType1,
        SerieColor1,
        IdGrafica,
        Lenguaje,
        IdContrato
    )
    SELECT Titulo,
           Subtitulo,
           Titulo_yAxis,
           Titulo_xAxis,
           Mes_Presupuestado,
           fechaNuevoFormato,
           2,
           valueSuffix,
           SerieName0,
           SerieValues0 AS SerieValues0,
           'line',
           'blue',
           SerieName1,
           SerieValues1 AS SerieValues1,
           'line',
           'green',
           @IdGrafica,
           @Language,
           @IdContrato
    FROM #tmpprecioscrudo;

END;


/*	  ====================================================================================
	    Precio Venta Gas     Grafica 18
	    ====================================================================================	    
	    */

IF @IdGrafica = 18
BEGIN

    SELECT CASE @Language
               WHEN 1 THEN
                   'Precio de Venta Gas'
               ELSE
                   'Precio de Venta Gas'
           END AS Titulo,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Subtitulo
               ELSE
                   DG_Grafica.Subtitle
           END AS Subtitulo,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Titulo_yAxis
               ELSE
                   DG_Grafica.Title_yAxis
           END AS Titulo_yAxis,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Titulo_xAxis
               ELSE
                   DG_Grafica.Title_xAxis
           END AS Titulo_xAxis,
           PA.Anio AS Mes_Presupuestado,
           CONVERT(VARCHAR, PA.Anio, 111) AS fechaNuevoFormato,
           CASE @Language
               WHEN 1 THEN
                   'Plan Price (USD)'
               ELSE
                   'Plan Precio (USD)'
           END AS 'SerieName0',
           SUM(PA.GasUSDMPc) AS 'SerieValues0',
           CASE @Language
               WHEN 1 THEN
                   'Real Price (USD)'
               ELSE
                   'Real Precio (USD)'
           END AS 'SerieName1',
           ISNULL(SUM(PA.RealGasUSDMPc), 0) AS 'SerieValues1',
           ' USD MPc' AS 'valueSuffix'
    INTO #tmppreciosgas
    FROM AA_PlanPrecioVentaHidrocarburoAnual PA
        LEFT OUTER JOIN DG_Grafica
            ON @IdGrafica = DG_Grafica.Id_Grafica
    WHERE (PA.IdContrato = @IdContrato)
    GROUP BY

        -- PA,Anio,
        DG_Grafica.Title,
        DG_Grafica.Subtitulo,
        DG_Grafica.Subtitle,
        DG_Grafica.Titulo_yAxis,
        DG_Grafica.Title_yAxis,
        DG_Grafica.Titulo_xAxis,
        DG_Grafica.Title_xAxis,
        PA.Anio;
    --    ORDER BY-- Mes_Presupuestado;
    INSERT INTO DG_DatosGrafica
    (
        Titulo,
        Subtitulo,
        Titulo_yAxis,
        Titulo_xAxis,
        Fecha,
        Fecha_NuevoFormato,
        CantidadSeries,
        valueSuffix,
        SerieName0,
        SerieValues0,
        SerieType0,
        SerieColor0,
        SerieName1,
        SerieValues1,
        SerieType1,
        SerieColor1,
        IdGrafica,
        Lenguaje,
        IdContrato
    )
    SELECT Titulo,
           Subtitulo,
           Titulo_yAxis,
           Titulo_xAxis,
           Mes_Presupuestado,
           fechaNuevoFormato,
           2,
           valueSuffix,
           SerieName0,
           SerieValues0 AS SerieValues0,
           'line',
           'blue',
           SerieName1,
           SerieValues1 AS SerieValues1,
           'line',
           'green',
           @IdGrafica,
           @Language,
           @IdContrato
    FROM #tmppreciosgas;

END;


/*
	    ====================================================================================
	    Ingresos comercializacion			-------Grafica 19
	    ====================================================================================	    
	    */

IF @IdGrafica = 19
BEGIN

    SELECT CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Titulo
               ELSE
                   DG_Grafica.Title
           END AS Titulo,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Subtitulo
               ELSE
                   DG_Grafica.Subtitle
           END AS Subtitulo,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Titulo_yAxis
               ELSE
                   DG_Grafica.Title_yAxis
           END AS Titulo_yAxis,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Titulo_xAxis
               ELSE
                   DG_Grafica.Title_xAxis
           END AS Titulo_xAxis,
           CONCAT(
                     SUBSTRING(CAST(YEAR(COM.FechaTransaccion) AS VARCHAR(4)), 3, 2),
                     ' ',
                     RIGHT('00' + CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2),
                     ' ',
                     SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(COM.FechaTransaccion)), 0, 4)
                 ) AS Mes_Presupuestado,
           CONCAT(
                     SUBSTRING(CAST(YEAR(COM.FechaTransaccion) AS VARCHAR(4)), 3, 2),
                     '/',
                     RIGHT('00' + CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2),
                     '/',
                     RIGHT('00' + CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2)
                 ) AS fechaNuevoFormato,
           CASE @Language
               WHEN 1 THEN
                   'Ingresos (USD)'
               ELSE
                   'Ingresos (USD)'
           END AS 'SerieName0',
           SUM((COM.PrecioVentaUnitario - COM.CostoUnitarioComercializacion) * COM.VolumenVendido) AS 'SerieValues0',
           CASE @Language
               WHEN 1 THEN
                   'CGI (USD)'
               ELSE
                   'CGI (USD)'
           END AS 'SerieName1',
           0 AS 'SerieValues1',
           ' Dls' AS 'valueSuffix'
    INTO #tmpIngreso
    FROM COM_OperacionComercializacion COM
        LEFT OUTER JOIN DG_Grafica
            ON @IdGrafica = DG_Grafica.Id_Grafica
    WHERE (COM.IdContrato = @IdContrato)
    --and MONTH ( CO_LineaPresupuestoMes.AC_FEC_INI ) = @mes 
    GROUP BY
        -- dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
        CONCAT(
                  SUBSTRING(CAST(YEAR(COM.FechaTransaccion) AS VARCHAR(4)), 3, 2),
                  ' ',
                  RIGHT('00' + CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2),
                  ' ',
                  SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(COM.FechaTransaccion)), 0, 4)
              ),
        CONCAT(
                  SUBSTRING(CAST(YEAR(COM.FechaTransaccion) AS VARCHAR(4)), 3, 2),
                  '/',
                  RIGHT('00' + CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2),
                  '/',
                  RIGHT('00' + CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2)
              ),
        DG_Grafica.Titulo,
        DG_Grafica.Title,
        DG_Grafica.Subtitulo,
        DG_Grafica.Subtitle,
        DG_Grafica.Titulo_yAxis,
        DG_Grafica.Title_yAxis,
        DG_Grafica.Titulo_xAxis,
        DG_Grafica.Title_xAxis
    ORDER BY -- Mes_Presupuestado;

        CONCAT(
                  SUBSTRING(CAST(YEAR(COM.FechaTransaccion) AS VARCHAR(4)), 3, 2),
                  ' ',
                  RIGHT('00' + CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2),
                  ' ',
                  SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(COM.FechaTransaccion)), 0, 4)
              ); --,--Area;

    INSERT INTO DG_DatosGrafica
    (
        Titulo,
        Subtitulo,
        Titulo_yAxis,
        Titulo_xAxis,
        Fecha,
        Fecha_NuevoFormato,
        CantidadSeries,
        valueSuffix,
        SerieName0,
        SerieValues0,
        SerieType0,
        SerieColor0,
        SerieName1,
        SerieValues1,
        SerieType1,
        SerieColor1,
        IdGrafica,
        Lenguaje,
        IdContrato
    )
    SELECT Titulo,
           Subtitulo,
           Titulo_yAxis,
           Titulo_xAxis,
           Mes_Presupuestado,
           fechaNuevoFormato,
           2,
           valueSuffix,
           SerieName0,
           CAST(SerieValues0 AS INT) AS SerieValues0,
           'line',
           'blue',
           SerieName1,
           CAST(SerieValues1 AS INT) AS SerieValues1,
           'line',
           'green',
           @IdGrafica,
           @Language,
           @IdContrato
    FROM #tmpIngreso
    ORDER BY Mes_Presupuestado;

END;


/*
	    ====================================================================================
	  Porcentaje Contenido Nacional   --------Grafica 8
	    ====================================================================================	    
	    */

IF @IdGrafica = 8
BEGIN

    SELECT CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Titulo
               ELSE
                   DG_Grafica.Title
           END AS Titulo,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Subtitulo
               ELSE
                   DG_Grafica.Subtitle
           END AS Subtitulo,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Titulo_yAxis
               ELSE
                   DG_Grafica.Title_yAxis
           END AS Titulo_yAxis,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Titulo_xAxis
               ELSE
                   DG_Grafica.Title_xAxis
           END AS Titulo_xAxis,
           YEAR(dbo.FI_Factura.FechaTimbrado) AS Mes_Presupuestado,
           YEAR(dbo.FI_Factura.FechaTimbrado) AS fechaNuevoFormato,
           CASE @Language
               WHEN 1 THEN
                   'Extranjero'
               ELSE
                   'Extranjero'
           END AS 'SerieName0',

		SUM(ISNULL(CO_Registro.MontoRegistro, 0))-SUM( ISNULL(SubTotal, 0)* ISNULL(PCN, 0) )  AS 'SerieValues0',

           CASE @Language
               WHEN 1 THEN
                   'Nacional'
               ELSE
                   'Nacional'
           END AS 'SerieName1',
		SUM( ISNULL(SubTotal, 0)* ISNULL(PCN, 0) ) --Sin mostrar el porcentaje

     --((SUM(ISNULL(SubTotal, 0) * ISNULL(PCN, 0))) * 100)/(SUM(ISNULL(subtotal, 0))) -- Sacar Porcentaje
		   AS 'SerieValues1',
           '' AS 'valueSuffix'
		  
    INTO #tmpCN
    FROM dbo.CO_Registro
        JOIN dbo.FI_Factura
            ON FI_Factura.IdFactura = CO_Registro.IdFactura
        JOIN dbo.CO_LineaPresupuestoMes
            ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
        JOIN dbo.CO_Presupuesto
            ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
        JOIN dbo.CO_AnioContractual
            ON CO_AnioContractual.IdAnioContractual = CO_Presupuesto.IdAnioContractual
        LEFT OUTER JOIN DG_Grafica
            ON @IdGrafica = DG_Grafica.Id_Grafica
    WHERE (FI_Factura.IdContrato = @IdContrato)
    GROUP BY YEAR(dbo.FI_Factura.FechaTimbrado),
             DG_Grafica.Titulo,
             DG_Grafica.Title,
             DG_Grafica.Subtitulo,
             DG_Grafica.Subtitle,
             DG_Grafica.Titulo_yAxis,
             DG_Grafica.Title_yAxis,
             DG_Grafica.Titulo_xAxis,
             DG_Grafica.Title_xAxis
    ORDER BY YEAR(dbo.FI_Factura.FechaTimbrado) DESC;

    INSERT INTO DG_DatosGrafica
    (
        Titulo,
        Subtitulo,
        Titulo_yAxis,
        Titulo_xAxis,
        Fecha,
        Fecha_NuevoFormato,
        CantidadSeries,
        valueSuffix,
        SerieName0,
        SerieValues0,
        SerieType0,
        SerieColor0,
        SerieName1,
        SerieValues1,
        SerieType1,
        SerieColor1,
        IdGrafica,
        Lenguaje,
        IdContrato
    )
    SELECT Titulo,
           Subtitulo,
           Titulo_yAxis,
           Titulo_xAxis,
           Mes_Presupuestado,
           fechaNuevoFormato,
           2,
           valueSuffix,
           SerieName0,
           CAST(SerieValues0 AS FLOAT) AS SerieValues0,
           'column',
           '#7cb5ec',
           SerieName1,
           CAST(SerieValues1 AS FLOAT) AS SerieValues1,
           'column',
           '#DF0101',
           @IdGrafica,
           @Language,
           @IdContrato
    FROM #tmpCN;


END;
/*
	    ====================================================================================
	  Porcentaje Contenido Nacional Mensual   ------- Grafica 21
	    ====================================================================================	    
	    */

IF @IdGrafica = 21
BEGIN

    SELECT CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Titulo
               ELSE
                   DG_Grafica.Title
           END AS Titulo,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Subtitulo
               ELSE
                   DG_Grafica.Subtitle
           END AS Subtitulo,
           CASE @Language
               WHEN 1 THEN
                   DG_Grafica.Titulo_yAxis
               ELSE
                   DG_Grafica.Title_yAxis
           END AS Titulo_yAxis,
           CASE @Language
               WHEN 1 THEN
                   'Meses'
           --DG_Grafica.Titulo_xAxis
           --ELSE DG_Grafica.Title_xAxis
           END AS Titulo_xAxis,
           CONCAT(
                     SUBSTRING(CAST(YEAR(dbo.FI_Factura.FechaTimbrado) AS VARCHAR(4)), 3, 2),
                     ' ',
                     RIGHT('00' + CAST(MONTH(dbo.FI_Factura.FechaTimbrado) AS VARCHAR(2)), 2),
                     ' ',
                     SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(dbo.FI_Factura.FechaTimbrado)), 0, 4)
                 ) AS Mes_Presupuestado,
           CONCAT(
                     SUBSTRING(CAST(YEAR(dbo.FI_Factura.FechaTimbrado) AS VARCHAR(4)), 3, 2),
                     '/',
                     RIGHT('00' + CAST(MONTH(dbo.FI_Factura.FechaTimbrado) AS VARCHAR(2)), 2),
                     '/',
                     RIGHT('00' + CAST(MONTH(dbo.FI_Factura.FechaTimbrado) AS VARCHAR(2)), 2)
                 ) AS fechaNuevoFormato,
           CASE @Language
               WHEN 1 THEN
                   ' Extranjero'
               ELSE
                   ' Extranjero'
           END AS 'SerieName0',
        	SUM(ISNULL(CO_Registro.MontoRegistro, 0))-SUM( ISNULL(SubTotal, 0)* ISNULL(PCN, 0) )AS 'SerieValues0',   -----------Presupuesto del año * .25 
           CASE @Language
               WHEN 1 THEN
                   ' Nacional'
               ELSE
                   ' Nacional'
           END AS 'SerieName1',
           ISNULL(SUM(SubTotal * PCN), 0) AS 'SerieValues1',   -----------Suma de subtotal de las facturas 
           '' AS 'valueSuffix'
    INTO #tmpCNM
    FROM dbo.CO_Registro
        JOIN dbo.FI_Factura
            ON FI_Factura.IdFactura = CO_Registro.IdFactura
        JOIN dbo.CO_LineaPresupuestoMes
            ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
        JOIN dbo.CO_Presupuesto
            ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
        JOIN dbo.CO_AnioContractual
            ON CO_AnioContractual.IdAnioContractual = CO_Presupuesto.IdAnioContractual
        LEFT OUTER JOIN DG_Grafica
            ON 21 = DG_Grafica.Id_Grafica
    WHERE (FI_Factura.IdContrato = @IdContrato)
    GROUP BY CONCAT(
                       SUBSTRING(CAST(YEAR(dbo.FI_Factura.FechaTimbrado) AS VARCHAR(4)), 3, 2),
                       ' ',
                       RIGHT('00' + CAST(MONTH(dbo.FI_Factura.FechaTimbrado) AS VARCHAR(2)), 2),
                       ' ',
                       SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(dbo.FI_Factura.FechaTimbrado)), 0, 4)
                   ),
             CONCAT(
                       SUBSTRING(CAST(YEAR(dbo.FI_Factura.FechaTimbrado) AS VARCHAR(4)), 3, 2),
                       '/',
                       RIGHT('00' + CAST(MONTH(dbo.FI_Factura.FechaTimbrado) AS VARCHAR(2)), 2),
                       '/',
                       RIGHT('00' + CAST(MONTH(dbo.FI_Factura.FechaTimbrado) AS VARCHAR(2)), 2)
                   ),
             DG_Grafica.Titulo,
             DG_Grafica.Title,
             DG_Grafica.Subtitulo,
             DG_Grafica.Subtitle,
             DG_Grafica.Titulo_yAxis,
             DG_Grafica.Title_yAxis,
             DG_Grafica.Titulo_xAxis,
             DG_Grafica.Title_xAxis
    ORDER BY CONCAT(
                       SUBSTRING(CAST(YEAR(dbo.FI_Factura.FechaTimbrado) AS VARCHAR(4)), 3, 2),
                       '/',
                       RIGHT('00' + CAST(MONTH(dbo.FI_Factura.FechaTimbrado) AS VARCHAR(2)), 2),
                       '/',
                       RIGHT('00' + CAST(MONTH(dbo.FI_Factura.FechaTimbrado) AS VARCHAR(2)), 2)
                   ) DESC;

    INSERT INTO DG_DatosGrafica
    (
        Titulo,
        Subtitulo,
        Titulo_yAxis,
        Titulo_xAxis,
        Fecha,
        Fecha_NuevoFormato,
        CantidadSeries,
        valueSuffix,
        SerieName0,
        SerieValues0,
        SerieType0,
        SerieColor0,
        SerieName1,
        SerieValues1,
        SerieType1,
        SerieColor1,
        IdGrafica,
        Lenguaje,
        IdContrato
    )
    SELECT Titulo,
           Subtitulo,
           Titulo_yAxis,
           Titulo_xAxis,
           Mes_Presupuestado,
           fechaNuevoFormato,
           2,
           valueSuffix,
           SerieName0,
           ISNULL(CAST(SerieValues0 AS FLOAT), 0) AS SerieValues0,
           'area',
           '#7cb5ec',
           SerieName1,
           ISNULL(CAST(SerieValues1 AS FLOAT), 0) AS SerieValues1,
           'area',
           '#DF0101',
           @IdGrafica,
           @Language,
           @IdContrato
    FROM #tmpCNM;


END;

/*
	    ====================================================================================
					Volumen total de gas --------  Grafica 22
	    ====================================================================================	    
	    */

IF @IdGrafica = 22
BEGIN
    SELECT CASE @Language
               WHEN 1 THEN
                   G.Titulo
               ELSE
                   G.Title
           END AS Titulo,
           CASE @Language
               WHEN 1 THEN
                   G.Subtitulo
               ELSE
                   G.Subtitle
           END AS Subtitulo,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_yAxis
               ELSE
                   G.Title_yAxis
           END AS Titulo_yAxis,
           CASE @Language
               WHEN 1 THEN
                   G.Titulo_xAxis
               ELSE
                   G.Title_xAxis
           END AS Titulo_xAxis,
           CONCAT(
                     SUBSTRING(CAST(YEAR(VMPP.idFecha) AS VARCHAR(4)), 3, 2),
                     ' ',
                     RIGHT('00' + CAST(MONTH(VMPP.idFecha) AS VARCHAR(2)), 2),
                     ' ',
                     SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.idFecha)), 0, 4)
                 ) AS Fecha,
           CONVERT(VARCHAR, VMPP.idFecha, 111) AS fechaNuevoFormato,
           2 AS CantidadSeries,
           ' MMPC' AS valueSuffix,
           CASE @Language
               WHEN 1 THEN
                   'Mensual'
               ELSE
                   'Monthly'
           END AS SerieName0,
           ROUND(SUM(VMPP.VolumenProgramado), 0) AS SerieValues0,
           'line' AS SerieType0,
           'green' AS SerieColor0,
           CASE @Language
               WHEN 1 THEN
                   'Acumulado'
               ELSE
                   'Accumulated'
           END AS SerieName1,
           ROUND(SUM(VMPP.VolumenProgramado), 0) AS SerieValues1,
           'line' AS SerieType1,
           'gray' AS SerieColor1,
           VMPP.idFecha
    INTO #VolumenGasT
    FROM DG_Grafica G
        LEFT OUTER JOIN dbo.PR_ProduccionMensualSipac VMPP
            ON @IdGrafica = G.Id_Grafica
    WHERE idContrato = @IdContrato
          AND VMPP.idHidrocarburo = 1000
    GROUP BY G.Titulo,
             G.Title,
             G.Subtitulo,
             G.Subtitle,
             G.Titulo_yAxis,
             G.Title_yAxis,
             G.Titulo_xAxis,
             G.Title_xAxis,
             CONCAT(
                       SUBSTRING(CAST(YEAR(VMPP.idFecha) AS VARCHAR(4)), 3, 2),
                       ' ',
                       RIGHT('00' + CAST(MONTH(VMPP.idFecha) AS VARCHAR(2)), 2),
                       ' ',
                       SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.idFecha)), 0, 4)
                   ),
             CONVERT(VARCHAR, VMPP.idFecha, 111),
             VMPP.idFecha
    ORDER BY CONCAT(
                       SUBSTRING(CAST(YEAR(VMPP.idFecha) AS VARCHAR(4)), 3, 2),
                       ' ',
                       RIGHT('00' + CAST(MONTH(VMPP.idFecha) AS VARCHAR(2)), 2),
                       ' ',
                       SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.idFecha)), 0, 4)
                   );

    SELECT t2.idFecha,
           SUM(   CASE
                      WHEN t1.idFecha <= t2.idFecha THEN
                          t1.SerieValues1
                      ELSE
                          0
                  END
              ) AS acumulado
    INTO #ProduccionGasT
    FROM #VolumenGasT t1
        CROSS JOIN #VolumenGasT t2
    GROUP BY t2.idFecha
    ORDER BY t2.idFecha;

    --||||||||||||||||||||||||||||||||||||||||||||
    UPDATE t1
    SET t1.SerieValues1 = t2.acumulado
    FROM #VolumenGasT t1
        JOIN #ProduccionGasT t2
            ON t1.idFecha = t2.idFecha;


    INSERT INTO DG_DatosGrafica
    (
        Titulo,
        Subtitulo,
        Titulo_yAxis,
        Titulo_xAxis,
        Fecha,
        Fecha_NuevoFormato,
        CantidadSeries,
        valueSuffix,
        SerieName0,
        SerieValues0,
        SerieType0,
        SerieColor0,
        SerieName1,
        SerieValues1,
        SerieType1,
        SerieColor1,
        IdGrafica,
        Lenguaje,
        IdContrato
    )
    SELECT Titulo,
           Subtitulo,
           Titulo_yAxis,
           Titulo_xAxis,
           Fecha,
           fechaNuevoFormato,
           CantidadSeries,
           valueSuffix,
           SerieName0,
           SerieValues0,
           SerieType0,
           SerieColor0,
           SerieName1,
           SerieValues1,
           SerieType1,
           SerieColor1,
           @IdGrafica,
           @Language,
           @IdContrato
    FROM #VolumenGasT;


END;



