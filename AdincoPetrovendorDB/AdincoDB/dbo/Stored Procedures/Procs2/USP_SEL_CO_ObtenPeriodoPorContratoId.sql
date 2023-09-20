IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CO_ObtenPeriodoPorContratoId'
)
    DROP PROCEDURE USP_SEL_CO_ObtenPeriodoPorContratoId;
GO

CREATE PROCEDURE [dbo].[USP_SEL_CO_ObtenPeriodoPorContratoId]
    @ContratoId INT,
    @UsuarioId INT,
    @ContratoIdSeleccionado INT
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #Temporal_Periodo
    (
        [IdPeriodo] INT NULL,
        [NombrePeriodo] VARCHAR(100) NULL,
        [Inicio] DATE NULL,
        [Fin] DATE NULL,
        [CreadoId] INT NULL,
        [CreadoPor] VARCHAR(100) NULL,
        [CreadoEl] DATETIME NULL,
        [ModificadoId] INT NULL,
        [ModificadoPor] VARCHAR(100) NULL,
        [ModificadoEl] DATETIME NULL,
        [Activo] BIT NULL
    );

    INSERT INTO #Temporal_Periodo
    (
        IdPeriodo,
        NombrePeriodo,
        Inicio,
        Fin,
        CreadoId,
        CreadoPor,
        CreadoEl,
        ModificadoId,
        ModificadoPor,
        ModificadoEl,
        Activo
    )
    SELECT CO_PeriodoContrato.IdPeriodo,
           CO_PeriodoContrato.NombrePeriodo,
           CO_PeriodoContrato.Inicio,
           CO_PeriodoContrato.Fin,
           CO_PeriodoContrato.CreadoPor,
           '',
           CO_PeriodoContrato.CreadoEl,
           CO_PeriodoContrato.ModificadoPor,
           '',
           CO_PeriodoContrato.ModificadoEl,
           ISNULL(CO_PeriodoContrato.Activo, 0)
    FROM CO_PeriodoContrato (NOLOCK)
    WHERE IdContrato = @ContratoIdSeleccionado
    ORDER BY CO_PeriodoContrato.IdPeriodo ASC;

    UPDATE #Temporal_Periodo
    SET #Temporal_Periodo.CreadoPor = LTRIM(RTRIM(ISNULL(AP_Usuario.Nombre, '')))
    FROM #Temporal_Periodo
        JOIN AP_Usuario
            ON #Temporal_Periodo.CreadoId = AP_Usuario.UsuarioID;

    UPDATE #Temporal_Periodo
    SET #Temporal_Periodo.ModificadoPor = LTRIM(RTRIM(ISNULL(AP_Usuario.Nombre, '')))
    FROM #Temporal_Periodo
        JOIN AP_Usuario
            ON #Temporal_Periodo.ModificadoId = AP_Usuario.UsuarioID;

    SELECT IdPeriodo,
           NombrePeriodo,
           Inicio,
           Fin,
           CreadoPor,
           CreadoEl,
           ModificadoPor,
           ModificadoEl,
           Activo
    FROM #Temporal_Periodo
    ORDER BY IdPeriodo ASC;
END;