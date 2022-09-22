CREATE PROCEDURE [dbo].[SP_CO_InformeRevGast_TotalAprobados_CertificadoGastosElegibles]
    @IdPresupuesto INT,
    @MesPresentacion DATE
AS
BEGIN
    SET LANGUAGE SPANISH;
    DECLARE @Contrato INT;
    DECLARE @FechaSumaMes DATE = DATEADD(month, 1, @MesPresentacion)
    DECLARE @Fecha VARCHAR(150) = LTRIM(UPPER(CONCAT(datename(month, @MesPresentacion), '/', YEAR(@MesPresentacion))));
    DECLARE @FechaRevGastosElegibles VARCHAR(150)
        = LTRIM(CONCAT(
                          '(Ver el Informe de Revisión de Gastos Elegibles ',
                          datename(month, @MesPresentacion),
                          '/',
                          YEAR(@MesPresentacion),
                          ')'
                      )
               );
    DECLARE @FechaGastosPendientesReconocer VARCHAR(150)
        = LTRIM(CONCAT(
                          '(Ver el Informe de Saldos de Gastos Elegibles Pendientes de Reconocer a ',
                          datename(month, @MesPresentacion),
                          '/',
                          YEAR(@MesPresentacion),
                          ')'
                      )
               );
    DECLARE @FechaInformeContableGastos VARCHAR(200)
        = LTRIM(CONCAT(
                          'De acuerdo al Informe Contable de Gastos elegibles correspondiente al mes de ',
                          datename(month, @MesPresentacion),
                          ' ',
                          YEAR(@MesPresentacion),
                          ' que se presento con fecha de 06/',
                          RIGHT('0' + RTRIM(MONTH(@FechaSumaMes)), 2),
                          '/',
                          YEAR(@FechaSumaMes),
                          ' le notifico lo siguiente de acuerdo a nuestra revisión:'
                      )
               );
    DECLARE @Presupuesto VARCHAR(150) = (
                                            SELECT TOP 1
                                                Nombre
                                            FROM CO_Presupuesto
                                            WHERE IdPresupuesto = @IdPresupuesto
                                        );
    SET @Presupuesto = LTRIM(UPPER(@Presupuesto));

    SELECT TOP 1
        @Contrato = CO_PeriodoContrato.IdContrato
    FROM CO_Presupuesto (NOLOCK)
        JOIN CO_ProgramaActividad (NOLOCK)
            ON CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad
        JOIN CO_PeriodoContrato (NOLOCK)
            ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
    WHERE CO_Presupuesto.IdPresupuesto = @IdPresupuesto

    SELECT ISNULL(CAST(SUM(SRC.USD) AS DECIMAL(10, 2)), 0.00) AS TOTAL,
           @Fecha AS MES,
           @FechaRevGastosElegibles AS MesRevGastosElegibles,
           @FechaGastosPendientesReconocer AS MesGastosPendientesReconocer,
           @FechaInformeContableGastos AS MesInformeContableGastos,
           @Presupuesto AS Presupuesto
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
    ) SRC
END;