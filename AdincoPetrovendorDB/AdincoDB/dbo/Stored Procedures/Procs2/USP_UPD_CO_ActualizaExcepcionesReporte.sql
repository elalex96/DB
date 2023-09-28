IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_UPD_CO_ActualizaExcepcionesReporte'
)
    DROP PROCEDURE USP_UPD_CO_ActualizaExcepcionesReporte;
GO

CREATE PROCEDURE [dbo].[USP_UPD_CO_ActualizaExcepcionesReporte]
    @ContratoId INT,
    @UsuarioId INT,
    @Id INT,
    @IdTipoReporte INT,
    @IdContrato INT,
    @MesReporte VARCHAR(50),
    @FechaFin DATETIME,
    @Motivo VARCHAR(5000),
    @Activo BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;

    DECLARE @FechaHoy DATETIME = GETDATE(),
            @DetalleBitacora VARCHAR(8000) = '',
            @FechaFinDate DATE = CONVERT(DATE, @FechaFin);

    CREATE TABLE #Temporal_ExcepcionesReporte
    (
        [Id] INT NULL,
        [IdTipoReporte] INT NULL,
        [IdContrato] INT NULL,
        [MesReporte] DATE NULL,
        [FechaFin] DATETIME NULL,
        [Motivo] VARCHAR(5000) NULL,
        [Activo] BIT NULL
    );

    SET @FechaFin = DATEADD(HOUR, 23, DATEADD(MINUTE, 59, DATEADD(SECOND, 59, CONVERT(DATETIME, @FechaFinDate))));

    INSERT INTO #Temporal_ExcepcionesReporte
    (
        Id,
        IdTipoReporte,
        IdContrato,
        MesReporte,
        FechaFin,
        Motivo,
        Activo
    )
    SELECT TOP 1
        Id,
        IdTipoReporte,
        IdContrato,
        MesReporte,
        FechaFin,
        LTRIM(RTRIM(ISNULL(Motivo, ''))),
        Activo
    FROM CO_ExcepcionesReporte (NOLOCK)
    WHERE Id = @Id

    SELECT TOP 1
        @DetalleBitacora
            = CONCAT(
                        @DetalleBitacora,
                        ' TipoReporte: Antes [',
                        CONVERT(VARCHAR(10), #Temporal_ExcepcionesReporte.IdTipoReporte),
                        '], Despues [',
                        CONVERT(VARCHAR(10), @IdTipoReporte),
                        ']'
                    )
    FROM #Temporal_ExcepcionesReporte
    WHERE #Temporal_ExcepcionesReporte.IdTipoReporte <> @IdTipoReporte;

    SELECT TOP 1
        @DetalleBitacora
            = CONCAT(
                        @DetalleBitacora,
                        ' IdContrato: Antes [',
                        CONVERT(VARCHAR(10), #Temporal_ExcepcionesReporte.IdContrato),
                        '], Despues [',
                        CONVERT(VARCHAR(10), @IdContrato),
                        ']'
                    )
    FROM #Temporal_ExcepcionesReporte
    WHERE #Temporal_ExcepcionesReporte.IdContrato <> @IdContrato;

    SELECT TOP 1
        @DetalleBitacora
            = CONCAT(
                        @DetalleBitacora,
                        ' MesReporte: Antes [',
                        CONVERT(VARCHAR(10), #Temporal_ExcepcionesReporte.MesReporte),
                        '], Despues [',
                        @MesReporte,
                        ']'
                    )
    FROM #Temporal_ExcepcionesReporte
    WHERE CONVERT(VARCHAR(10), ISNULL(#Temporal_ExcepcionesReporte.MesReporte, '')) <> ISNULL(@MesReporte, '');

    SELECT TOP 1
        @DetalleBitacora
            = CONCAT(
                        @DetalleBitacora,
                        ' FechaFin: Antes [',
                        CONVERT(VARCHAR(100), #Temporal_ExcepcionesReporte.FechaFin),
                        '], Despues [',
                        CONVERT(VARCHAR(100), @FechaFin),
                        ']'
                    )
    FROM #Temporal_ExcepcionesReporte
    WHERE ISNULL(CONVERT(DATE, #Temporal_ExcepcionesReporte.FechaFin), '') <> ISNULL(CONVERT(DATE, @FechaFin), '');

    SELECT TOP 1
        @DetalleBitacora
            = CONCAT(
                        @DetalleBitacora,
                        ' Motivo: Antes [',
                        #Temporal_ExcepcionesReporte.Motivo,
                        '], Despues [',
                        LTRIM(RTRIM(ISNULL(@Motivo, ''))),
                        ']'
                    )
    FROM #Temporal_ExcepcionesReporte
    WHERE #Temporal_ExcepcionesReporte.Motivo <> LTRIM(RTRIM(ISNULL(@Motivo, '')));

    SELECT TOP 1
        @DetalleBitacora
            = CONCAT(   @DetalleBitacora,
                        ' Activo: Antes [',
                        CASE
                            WHEN #Temporal_ExcepcionesReporte.Activo = 0 THEN
                                'Inactivo'
                            ELSE
                                'Activo'
                        END,
                        '], Despues [',
                        CASE
                            WHEN @Activo = 0 THEN
                                'Inactivo'
                            ELSE
                                'Activo'
                        END,
                        ']'
                    )
    FROM #Temporal_ExcepcionesReporte
    WHERE #Temporal_ExcepcionesReporte.Activo <> @Activo;

    IF (LEN(@DetalleBitacora) > 0)
    BEGIN
        UPDATE CO_ExcepcionesReporte
        SET [IdTipoReporte] = @IdTipoReporte,
            [IdContrato] = @IdContrato,
            [MesReporte] = CONVERT(DATE, @MesReporte),
            [FechaFin] = @FechaFin,
            [Motivo] = LTRIM(RTRIM(ISNULL(@Motivo, ''))),
            [Activo] = ISNULL(@Activo, 0),
            [ModificadoPor] = @UsuarioId,
            [ModificadoEl] = @FechaHoy
        WHERE Id = @Id;

        INSERT INTO AP_Bitacora
        (
            [Fecha],
            [Tipo],
            [Mensaje],
            [Detalle],
            [UsuarioId],
            [ContratoId]
        )
        VALUES
        (@FechaHoy,
         'Edición',
         'Edición de Valores de CO_ExcepcionesReporte en la página ExcepcionesReporte.aspx',
         CONCAT('De la Excepción de Reporte con Id: ', CONVERT(VARCHAR(10), @Id), ' -', @DetalleBitacora),
         @UsuarioId,
         @ContratoId
        );
    END

END;