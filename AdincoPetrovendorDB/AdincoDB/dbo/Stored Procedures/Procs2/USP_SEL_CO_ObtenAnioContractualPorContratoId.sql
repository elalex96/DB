IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CO_ObtenAnioContractualPorContratoId'
)
    DROP PROCEDURE USP_SEL_CO_ObtenAnioContractualPorContratoId;
GO

CREATE PROCEDURE [dbo].[USP_SEL_CO_ObtenAnioContractualPorContratoId]
    @ContratoId INT,
    @UsuarioId INT,
    @ContratoIdSeleccionado INT
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #Temporal_AnioContractual
    (
        [IdAnioContractual] INT NULL,
        [Anio] INT NULL,
        [Inicio] DATE NULL,
        [Termino] DATE NULL,
        [CreadoId] INT NULL,
        [CreadoPor] VARCHAR(100) NULL
    );

    INSERT INTO #Temporal_AnioContractual
    (
        IdAnioContractual,
        Anio,
        Inicio,
        Termino,
        CreadoId,
        CreadoPor
    )
    SELECT IdAnioContractual,
           Anio,
           Inicio,
           Termino,
           CreadoPor,
           ''
    FROM CO_AnioContractual (NOLOCK)
    WHERE IdContrato = @ContratoIdSeleccionado;

    UPDATE #Temporal_AnioContractual
    SET #Temporal_AnioContractual.CreadoPor = LTRIM(RTRIM(ISNULL(AP_Usuario.Nombre, '')))
    FROM #Temporal_AnioContractual
        JOIN AP_Usuario
            ON #Temporal_AnioContractual.CreadoId = AP_Usuario.UsuarioID;

    SELECT IdAnioContractual,
           Anio,
           Inicio,
           Termino,
           CreadoPor
    FROM #Temporal_AnioContractual
    ORDER BY IdAnioContractual ASC;
END;