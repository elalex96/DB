IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CO_ObtenPresupuestoPorContratoId'
)
    DROP PROCEDURE USP_SEL_CO_ObtenPresupuestoPorContratoId;
GO

CREATE PROCEDURE [dbo].[USP_SEL_CO_ObtenPresupuestoPorContratoId]
    @ContratoId INT,
    @UsuarioId INT,
    @ContratoIdSeleccionado INT
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #Temporal_Presupuesto
    (
        [IdPresupuesto] INT NULL,
        [IdAnioContractual] INT NULL,
        [AnioContractual] VARCHAR(100) NULL,
        [IdProgramaActividad] INT NULL,
        [Programa] VARCHAR(100) NULL,
        [Version] INT NULL,
        [Nombre] VARCHAR(200) NULL,
        [Comentario] VARCHAR(200) NULL,
        [FechaAprobacionPEP] DATE NULL,
        [CreadoId] INT NULL,
        [CreadoPor] VARCHAR(100) NULL,
        [CreadoEl] DATETIME NULL,
        [ModificadoId] INT NULL,
        [ModificadoPor] VARCHAR(100) NULL,
        [ModificadoEl] DATETIME NULL,
        [Activo] BIT NULL,
        [IdPresupuestoCNH] VARCHAR(100) NULL,
        [Actual] BIT NULL,
        [CIEP] BIT NULL,
        [ActivoProcura] BIT NULL,
        [InicioPresupuesto] DATE NULL,
        [FinPresupuesto] DATE NULL
    );

    INSERT INTO #Temporal_Presupuesto
    (
        IdPresupuesto,
        IdAnioContractual,
        AnioContractual,
        IdProgramaActividad,
        Programa,
        Version,
        Nombre,
        Comentario,
        FechaAprobacionPEP,
        CreadoId,
        CreadoPor,
        CreadoEl,
        ModificadoId,
        ModificadoPor,
        ModificadoEl,
        Activo,
        IdPresupuestoCNH,
        Actual,
        CIEP,
        ActivoProcura,
        InicioPresupuesto,
        FinPresupuesto
    )
    SELECT CO_Presupuesto.IdPresupuesto,
           CO_Presupuesto.IdAnioContractual,
           '',
           CO_Presupuesto.IdProgramaActividad,
           ISNULL(CO_ProgramaActividad.NombrePrograma, ''),
           CO_Presupuesto.Version,
           ISNULL(CO_Presupuesto.Nombre, ''),
           ISNULL(CO_Presupuesto.Comentario, ''),
           CO_Presupuesto.FechaAprobacionPEP,
           CO_Presupuesto.CreadoPor,
           '',
           CO_Presupuesto.CreadoEl,
           CO_Presupuesto.ModificadoPor,
           '',
           CO_Presupuesto.ModificadoEl,
           ISNULL(CO_Presupuesto.Activo, 0),
           ISNULL(CO_Presupuesto.IdPresupuestoCNH, ''),
           ISNULL(CO_Presupuesto.Actual, 0),
           ISNULL(CO_Presupuesto.CIEP, 0),
           ISNULL(CO_Presupuesto.ActivoProcura, 0),
           CO_Presupuesto.InicioPresupuesto,
           CO_Presupuesto.FinPresupuesto
    FROM CO_PeriodoContrato (NOLOCK)
        JOIN CO_ProgramaActividad (NOLOCK)
            ON CO_PeriodoContrato.IdContrato = @ContratoIdSeleccionado
               AND CO_PeriodoContrato.IdPeriodo = CO_ProgramaActividad.IdPeriodoContrato
        JOIN CO_Presupuesto (NOLOCK)
            ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad;

    UPDATE #Temporal_Presupuesto
    SET #Temporal_Presupuesto.CreadoPor = LTRIM(RTRIM(ISNULL(AP_Usuario.Nombre, '')))
    FROM #Temporal_Presupuesto
        JOIN AP_Usuario
            ON #Temporal_Presupuesto.CreadoId = AP_Usuario.UsuarioID;

    UPDATE #Temporal_Presupuesto
    SET #Temporal_Presupuesto.ModificadoPor = LTRIM(RTRIM(ISNULL(AP_Usuario.Nombre, '')))
    FROM #Temporal_Presupuesto
        JOIN AP_Usuario
            ON #Temporal_Presupuesto.ModificadoId = AP_Usuario.UsuarioID;

    UPDATE #Temporal_Presupuesto
    SET #Temporal_Presupuesto.AnioContractual = CONCAT(
                                                          CONVERT(VARCHAR(10), CO_AnioContractual.Anio),
                                                          ' (',
                                                          FORMAT(CO_AnioContractual.Inicio, 'dd/MM/yyyy'),
                                                          ' - ',
                                                          FORMAT(CO_AnioContractual.Termino, 'dd/MM/yyyy'),
                                                          ')'
                                                      )
    FROM #Temporal_Presupuesto
        JOIN CO_AnioContractual
            ON #Temporal_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual;

    SELECT IdPresupuesto,
           AnioContractual,
           Programa,
           Version,
           Nombre,
           Comentario,
           FechaAprobacionPEP,
           CreadoPor,
           CreadoEl,
           ModificadoPor,
           ModificadoEl,
           Activo,
           IdPresupuestoCNH,
           Actual,
           CIEP,
           ActivoProcura,
           InicioPresupuesto,
           FinPresupuesto
    FROM #Temporal_Presupuesto
    ORDER BY IdPresupuesto ASC;
END;