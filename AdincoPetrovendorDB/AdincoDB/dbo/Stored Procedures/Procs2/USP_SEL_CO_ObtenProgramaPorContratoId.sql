IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CO_ObtenProgramaPorContratoId'
)
    DROP PROCEDURE USP_SEL_CO_ObtenProgramaPorContratoId;
GO

CREATE PROCEDURE [dbo].[USP_SEL_CO_ObtenProgramaPorContratoId]
    @ContratoId INT,
    @UsuarioId INT,
    @ContratoIdSeleccionado INT
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #Temporal_Programa
    (
        [IdProgramaActividad] INT NULL,
        [IdPeriodoContrato] INT NULL,
        [Periodo] VARCHAR(100) NULL,
        [IdTipoProgramaActividad] INT NULL,
        [TipoProgramaActividad] VARCHAR(100),
        [NombrePrograma] VARCHAR(200) NULL,
        [FechaPresentacion] DATE NULL,
        [NumeroRegistroContenidoNacional] VARCHAR(200) NULL,
        [CreadoId] INT NULL,
        [CreadoPor] VARCHAR(100) NULL,
        [CreadoEl] DATETIME NULL,
        [ModificadoId] INT NULL,
        [ModificadoPor] VARCHAR(100) NULL,
        [ModificadoEl] DATETIME NULL,
        [Activo] BIT NULL
    );

    INSERT INTO #Temporal_Programa
    (
        IdProgramaActividad,
        IdPeriodoContrato,
        Periodo,
        IdTipoProgramaActividad,
        TipoProgramaActividad,
        NombrePrograma,
        FechaPresentacion,
        NumeroRegistroContenidoNacional,
        CreadoId,
        CreadoPor,
        CreadoEl,
        ModificadoId,
        ModificadoPor,
        ModificadoEl,
        Activo
    )
    SELECT CO_ProgramaActividad.IdProgramaActividad,
           CO_ProgramaActividad.IdPeriodoContrato,
           ISNULL(CO_PeriodoContrato.NombrePeriodo, ''),
           CO_ProgramaActividad.IdTipoProgramaActividad,
           '',
           ISNULL(CO_ProgramaActividad.NombrePrograma, ''),
           CO_ProgramaActividad.FechaPresentacion,
           ISNULL(CO_ProgramaActividad.NumeroRegistroContenidoNacional, ''),
           CO_ProgramaActividad.CreadoPor,
           '',
           CO_ProgramaActividad.CreadoEl,
           CO_ProgramaActividad.ModificadoPor,
           '',
           CO_ProgramaActividad.ModificadoEl,
           CO_ProgramaActividad.Activo
    FROM CO_PeriodoContrato (NOLOCK)
        JOIN CO_ProgramaActividad (NOLOCK)
            ON CO_PeriodoContrato.IdContrato = @ContratoIdSeleccionado
               AND CO_PeriodoContrato.IdPeriodo = CO_ProgramaActividad.IdPeriodoContrato;

    UPDATE #Temporal_Programa
    SET #Temporal_Programa.CreadoPor = LTRIM(RTRIM(ISNULL(AP_Usuario.Nombre, '')))
    FROM #Temporal_Programa
        JOIN AP_Usuario
            ON #Temporal_Programa.CreadoId = AP_Usuario.UsuarioID;

    UPDATE #Temporal_Programa
    SET #Temporal_Programa.ModificadoPor = LTRIM(RTRIM(ISNULL(AP_Usuario.Nombre, '')))
    FROM #Temporal_Programa
        JOIN AP_Usuario
            ON #Temporal_Programa.ModificadoId = AP_Usuario.UsuarioID;

    UPDATE #Temporal_Programa
    SET #Temporal_Programa.TipoProgramaActividad = LTRIM(RTRIM(ISNULL(CO_TipoProgramaActividad.TipoPrograma, '')))
    FROM #Temporal_Programa
        JOIN CO_TipoProgramaActividad
            ON #Temporal_Programa.IdTipoProgramaActividad = CO_TipoProgramaActividad.IdTipoProgramaActividad;

    SELECT IdProgramaActividad,
           Periodo,
           TipoProgramaActividad,
		   NombrePrograma,
           FechaPresentacion,
           NumeroRegistroContenidoNacional,
           CreadoPor,
           CreadoEl,
           ModificadoPor,
           ModificadoEl,
           Activo
    FROM #Temporal_Programa
    ORDER BY IdProgramaActividad ASC;
END;