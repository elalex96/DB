IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_InsertarProgramaCaptura'
    )
    DROP PROCEDURE p_OT_InsertarProgramaCaptura;
GO

CREATE PROCEDURE p_OT_InsertarProgramaCaptura
    @pIdOTSolicitudProgramaCaptura INT,
    @pIdOTSolicitudMaterial        INT,
    @pSemana                       VARCHAR(21),
    @pCaptura                      DECIMAL(14, 3),
    @pDiaSemana                    TINYINT,
    @pCreadoPor                    VARCHAR(50),
    @pCreadlEl                     DATETIME,
    @pErrorOut                     VARCHAR(250) out
AS
BEGIN
    GOTO fin
    DECLARE
        @fechaIni     DATETIME,
        @fechaFin     DATETIME,
        @fechaIndex   DATETIME,
        @fechaCaptura DATETIME,
        @anioMesDia   int


    CREATE TABLE #tmpSemana (Fecha VARCHAR(10))

    INSERT INTO #tmpSemana
                SELECT
                    *
                FROM
                    [dbo].[fnSplitString](@pSemana, '-')

    IF exists
        (
            SELECT
                1
            FROM
                #tmpSemana
        )
        BEGIN
            SELECT
                @fechaIni   = MIN(Fecha),
                @fechaIndex = MIN(Fecha),
                @fechaFin   = MAX(fecha)
            FROM
                #tmpSemana
        END

    /**********Recorrer las fechas hasta encontrar la fecha que corresponde al día capturado*****/

    WHILE @fechaIndex <= @fechaFin
        BEGIN
            SELECT
                1
            IF (datepart(WEEKDAY, @fechaIndex) = @pDiaSemana)
                BEGIN
                    SET @fechaCaptura = @fechaIndex
                    SET @fechaIndex = DATEADD(dd, 1, @fechaFin)
                END
            ELSE
                BEGIN
                    SET @fechaIndex = DATEADD(dd, 1, @fechaIndex)
                end

        end


    IF (@fechaCaptura IS NOT null)
        BEGIN
            SET @anioMesDia
                = (DATEPART(yy, @fechaCaptura) * 10000) + (DATEPART(mm, @fechaCaptura) * 100)
                  + DATEPART(dd, @fechaCaptura)
        END

    IF (@fechaCaptura IS NULL)
        BEGIN
            SET @pErrorOut = 'Se encontró un error al calcular las fechas'
        END
    ELSE
        begin

            SELECT
                @pIdOTSolicitudProgramaCaptura = ISNULL(MAX(IdOTSolicitudProgramaCaptura), 0) + 1
            FROM
                OT_SolicitudProgramaCaptura (NOLOCK)

            INSERT INTO OT_SolicitudProgramaCaptura
                (
                    IdOTSolicitudProgramaCaptura,
                    IdOTSolicitudMaterial,
                    IdAnioMesDia,
                    Fecha,
                    Captura,
                    CreadoPor,
                    CreadoEl,
                    ModificadoPor,
                    ModificadoEl
                )
            VALUES
                (
                    @pIdOTSolicitudProgramaCaptura,
                    @pIdOTSolicitudMaterial,
                    @anioMesDia,
                    @fechaCaptura,
                    @pCaptura,
                    @pCreadoPor,
                    GETDATE(),
                    NULL,
                    null
                )

        End

    fin:
END
