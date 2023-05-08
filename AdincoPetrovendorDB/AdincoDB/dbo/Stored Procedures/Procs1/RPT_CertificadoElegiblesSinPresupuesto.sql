--==============================================
-- Creado Por:	Pedro Pouchoulen
-- Fecha:		04-Enero-2023
-- Detalle:		Se retorna al reporte de Certificado Elegibles sin seleccionar el Presupuesto
-- Url:			donde se ocupa /3/CIEP/CertificadoGastosElegiblesSinPresupuesto.aspx 
--==============================================
CREATE PROCEDURE [dbo].[RPT_CertificadoElegiblesSinPresupuesto]
    @MesPresentacion datetime
AS
BEGIN
    DECLARE @TotalAprobado Decimal(18, 2)

    CREATE TABLE #TotalAprobados
    (
        Total Decimal(18, 2),
        Mes varchar(150),
        MesRevGastosElegibles varchar(150),
        MesGastosPendientesReconocer varchar(150),
        MesInformeContableGastos varchar(200),
        Presupuesto varchar(150),
        USD Decimal(18, 4)
    )

    INSERT INTO #TotalAprobados
    (
        Total,
        Mes,
        MesRevGastosElegibles,
        MesGastosPendientesReconocer,
        MesInformeContableGastos,
        Presupuesto
    )
    exec SP_CO_InformeRevGast_TotalAprobados_CertificadoGastosElegibles_SinPresupuesto @MesPresentacion

    SELECT @TotalAprobado = Total
    FROM #TotalAprobados

    SELECT 'Periodo de Desarrollo' as NombrePeriodo,
           ISNULL(@MesPresentacion, '') as PeriodoRevisado,
           ISNULL(@TotalAprobado, 0) as TotalGastosElegibles
END
