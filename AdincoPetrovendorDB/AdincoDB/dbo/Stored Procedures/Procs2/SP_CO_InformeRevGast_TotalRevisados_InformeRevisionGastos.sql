CREATE PROCEDURE [dbo].[SP_CO_InformeRevGast_TotalRevisados_InformeRevisionGastos]
    @IdPresupuesto INT,
    @MesPresentacion DATE
AS
BEGIN
    DECLARE @Contrato INT,
            @TotalAprobados DECIMAL(10, 2) = 0.00,
            @TotalObjetado DECIMAL(10, 2) = 0.00,
            @TotalNoProcedentes DECIMAL(10, 2) = 0.00,
            @TotalRevisados DECIMAL(10, 2) = 0.00;

    SELECT TOP 1
        @Contrato = CO_PeriodoContrato.IdContrato
    FROM CO_Presupuesto (NOLOCK)
        JOIN CO_ProgramaActividad (NOLOCK)
            ON CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad
        JOIN CO_PeriodoContrato (NOLOCK)
            ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
    WHERE CO_Presupuesto.IdPresupuesto = @IdPresupuesto
    /*@TotalAprobados*/
    SELECT @TotalAprobados = ISNULL(CAST(SUM(TotalAprobados.USD) AS DECIMAL(10, 2)), 0.00)
    FROM
    (
        SELECT SUM(   CASE
                          WHEN ISNULL(GastosAmatitlan2020.MontoUSDConMarkup, 0) <> 0 THEN
                              ISNULL(GastosAmatitlan2020.MontoUSDConMarkup, 0)
                          ELSE
                              0
                      END
                  ) AS USD
        FROM CO_LineaPresupuestoMes (NOLOCK)
            JOIN CO_Presupuesto (NOLOCK)
                ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
                   AND CO_Presupuesto.IdPresupuesto = @IdPresupuesto
            JOIN CO_Registro (NOLOCK)
                ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
                   AND CO_Registro.IdRegistro IS NOT NULL
            JOIN CO_RegistroMarkup (NOLOCK)
                ON CO_Registro.IdRegistro = CO_RegistroMarkup.GastoId
            JOIN CO_EstadoRegistro_V2 (NOLOCK)
                ON ISNULL(CO_RegistroMarkup.IdEstadoPemex, 0) = CO_EstadoRegistro_V2.IdClvEstado
                   AND CO_RegistroMarkup.MesEstadoPemex = @MesPresentacion
                   AND CO_EstadoRegistro_V2.NombreEstado = 'Certificado GE Aprobado CACI'
                   AND CO_EstadoRegistro_V2.IdContrato = @Contrato
            JOIN GastosAmatitlan2020 (NOLOCK)
                ON CO_Registro.IdRegistro = GastosAmatitlan2020.IdRegistro
    ) TotalAprobados
    /*@TotalObjetado*/
    SELECT @TotalObjetado = ISNULL(CAST(SUM(TotalObjetado.USD) AS DECIMAL(10, 2)), 0.00)
    FROM
    (
        SELECT SUM(   CASE
                          WHEN ISNULL(GastosAmatitlan2020.MontoUSDConMarkup, 0) <> 0 THEN
                              ISNULL(GastosAmatitlan2020.MontoUSDConMarkup, 0)
                          ELSE
                              0
                      END
                  ) AS USD
        FROM CO_LineaPresupuestoMes (NOLOCK)
            JOIN CO_Presupuesto (NOLOCK)
                ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
                   AND CO_Presupuesto.IdPresupuesto = @IdPresupuesto
            JOIN CO_Registro (NOLOCK)
                ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
                   AND CO_Registro.IdRegistro IS NOT NULL
            JOIN CO_RegistroMarkup (NOLOCK)
                ON CO_Registro.IdRegistro = CO_RegistroMarkup.GastoId
            JOIN CO_EstadoRegistro_V2 (NOLOCK)
                ON ISNULL(CO_RegistroMarkup.IdEstadoPemex, 0) = CO_EstadoRegistro_V2.IdClvEstado
                   AND CO_RegistroMarkup.MesEstadoPemex = @MesPresentacion
                   AND CO_EstadoRegistro_V2.NombreEstado = 'Aclaración'
                   AND CO_EstadoRegistro_V2.IdContrato = @Contrato
            JOIN GastosAmatitlan2020 (NOLOCK)
                ON CO_Registro.IdRegistro = GastosAmatitlan2020.IdRegistro
    ) TotalObjetado
    /*@TotalNoProcedentes*/
    SELECT @TotalNoProcedentes = ISNULL(CAST(SUM(TotalNoProcedentes.USD) AS DECIMAL(10, 2)), 0.00)
    FROM
    (
        SELECT SUM(   CASE
                          WHEN ISNULL(GastosAmatitlan2020.MontoUSDConMarkup, 0) <> 0 THEN
                              ISNULL(GastosAmatitlan2020.MontoUSDConMarkup, 0)
                          ELSE
                              0
                      END
                  ) AS USD
        FROM CO_LineaPresupuestoMes (NOLOCK)
            JOIN CO_Presupuesto (NOLOCK)
                ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
                   AND CO_Presupuesto.IdPresupuesto = @IdPresupuesto
            JOIN CO_Registro (NOLOCK)
                ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
                   AND CO_Registro.IdRegistro IS NOT NULL
            JOIN CO_RegistroMarkup (NOLOCK)
                ON CO_Registro.IdRegistro = CO_RegistroMarkup.GastoId
            JOIN CO_EstadoRegistro_V2 (NOLOCK)
                ON ISNULL(CO_RegistroMarkup.IdEstadoPemex, 0) = CO_EstadoRegistro_V2.IdClvEstado
                   AND CO_RegistroMarkup.MesEstadoPemex = @MesPresentacion
                   AND CO_EstadoRegistro_V2.NombreEstado = 'NO Elegible'
                   AND CO_EstadoRegistro_V2.IdContrato = @Contrato
            JOIN GastosAmatitlan2020 (NOLOCK)
                ON CO_Registro.IdRegistro = GastosAmatitlan2020.IdRegistro
    ) TotalNoProcedentes
	/*@TotalRevisados*/
    SET @TotalRevisados
        = ISNULL(@TotalAprobados, 0.00) + ISNULL(@TotalObjetado, 0.00) + ISNULL(@TotalNoProcedentes, 0.00);
    SELECT ISNULL(@TotalRevisados, 0.00) AS TOTALRevisados;
END