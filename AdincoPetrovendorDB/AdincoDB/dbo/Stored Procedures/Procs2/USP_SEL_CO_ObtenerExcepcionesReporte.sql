IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CO_ObtenerExcepcionesReporte'
)
    DROP PROCEDURE USP_SEL_CO_ObtenerExcepcionesReporte;
GO

CREATE PROCEDURE [dbo].[USP_SEL_CO_ObtenerExcepcionesReporte]
    @ContratoId INT,
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #Temporal_ExcepcionesReporte
    (
        [Id] INT NULL,
        [IdTipoReporte] INT NULL,
        [IdContrato] VARCHAR(500) NULL,
        [ContratoMostrar] INT NULL,
        [MesReporte] DATE NULL,
        [FechaFin] DATETIME NULL,
        [Motivo] VARCHAR(5000) NULL,
        [Activo] BIT NULL,
        [ContratoActivo] BIT NULL
    );

    INSERT INTO #Temporal_ExcepcionesReporte
    (
        [Id],
        [IdTipoReporte],
        [IdContrato],
        [ContratoMostrar],
        [MesReporte],
        [FechaFin],
        [Motivo],
        [Activo],
        [ContratoActivo]
    )
    SELECT [Id],
           [IdTipoReporte],
           CONVERT(VARCHAR(500), [IdContrato]),
           [IdContrato],
           [MesReporte],
           [FechaFin],
           [Motivo],
           [Activo],
           0
    FROM CO_ExcepcionesReporte (NOLOCK);

    UPDATE #Temporal_ExcepcionesReporte
    SET #Temporal_ExcepcionesReporte.ContratoActivo = 1
    FROM #Temporal_ExcepcionesReporte
        JOIN CO_Contrato
            ON #Temporal_ExcepcionesReporte.ContratoMostrar = CO_Contrato.IdContrato
        INNER JOIN CO_AreaContractual
            ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
               AND ISNULL(CO_Contrato.Activo, 0) = 1
               AND ISNULL(CO_AreaContractual.Activo, 0) = 1

    UPDATE #Temporal_ExcepcionesReporte
    SET #Temporal_ExcepcionesReporte.IdContrato = CO_Contrato.NumeroContrato + ' - '
                                                  + ISNULL(CO_AreaContractual.NombreAreaContractual, '')
    FROM #Temporal_ExcepcionesReporte
        JOIN CO_Contrato
            ON #Temporal_ExcepcionesReporte.ContratoActivo = 0
               AND #Temporal_ExcepcionesReporte.ContratoMostrar = CO_Contrato.IdContrato
        LEFT JOIN CO_AreaContractual
            ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual;

    SELECT [Id],
           [IdTipoReporte],
           [IdContrato],
           CONVERT(VARCHAR(50), [MesReporte]) AS MesReporte,
           [FechaFin],
           [Motivo],
           ISNULL([Activo], 0) AS Activo
    FROM #Temporal_ExcepcionesReporte
    ORDER BY [FechaFin] DESC;
END;