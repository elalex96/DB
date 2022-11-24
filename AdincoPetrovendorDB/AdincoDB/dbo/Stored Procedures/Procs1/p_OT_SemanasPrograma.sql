--******************************************************************
-- ESTE SP TAMBIEN SE UTILIZA DENTRO DE p_OT_Estimacion_Cerrar_Semana EN ADINCO
--******************************************************************
-- p_OT_SemanasPrograma 1
CREATE PROC [dbo].[p_OT_SemanasPrograma] @pIdOTSolicitud INT
AS
BEGIN
    DECLARE @fechaIni DATETIME,
            @fechafin DATETIME,
            @fechaIndice DATETIME,
            @fechaIniSemana DATETIME,
            @fechaFinSemana DATETIME,
            @diaindice INT,
            @fechaFinExtendida DATETIME

    SELECT @fechaFinExtendida = FechaFinExtendida
    FROM dbo.OT_Solicitud (NOLOCK)
    WHERE IdOTSolicitud = @pIdOTSolicitud

    CREATE TABLE #tmpSemanas
    (
        ID varchar(21),
        FechaIni DATETIME,
        FechaFin datetime
    )

    SELECT @fechaIni = MIN(OT_SolicitudMaterial.FechaProgramaInicio),
           @fechafin = CASE
                           WHEN @fechaFinExtendida IS NULL then
                               MAX(OT_SolicitudMaterial.FechaProgramaFin)
                           ELSE
                               @fechaFinExtendida
                       end,
           @fechaIndice = MIN(OT_SolicitudMaterial.FechaProgramaInicio),
           @fechaIniSemana = MIN(OT_SolicitudMaterial.FechaProgramaInicio)
    FROM OT_SolicitudMaterial (NOLOCK)
    WHERE IdOTSolicitud = @pIdOTSolicitud

    WHILE @fechaIndice <= @fechafin
    BEGIN

        SELECT @diaindice = DiaDeSemana
        FROM ap_calendario (NOLOCK)
        WHERE convert(VARCHAR, InicioDia, 112) = convert(VARCHAR, @fechaIndice, 112)
        IF (@diaindice = 7 OR DATEADD(dd, 1, @fechaIndice) > @fechafin)
        BEGIN
            SET @fechaFinSemana = @fechaIndice
            INSERT INTO #tmpSemanas
            (
                ID,
                FechaIni,
                FechaFin
            )
            SELECT CONVERT(VARCHAR, @fechaIniSemana, 112) + '-' + CONVERT(VARCHAR, @fechaFinSemana, 112),
                   @fechaIniSemana,
                   @fechaFinSemana

            SET @fechaIniSemana = DATEADD(dd, 1, @fechaIndice)
        END

        SET @fechaIndice = DATEADD(dd, 1, @fechaIndice)

    END

    SELECT ID,
           FechaIniText = CONVERT(VARCHAR, FechaIni, 103),
           FechaFinText = CONVERT(VARCHAR, FechaFin, 103),
           FechaIni = FechaIni,
           FechaFin = FechaFin,
           Cerrada = cast(case
                              when OT_ProgramaSemanaCerrada.SemanaID is not null then
                                  1
                              else
                                  0
                          end as bit),
           Estado = case
                        when OT_ProgramaSemanaCerrada.SemanaID is not null then
                            'CERRADA'
                        else
                            'ABIERTA'
                    end
    FROM #tmpSemanas
        LEFT JOIN OT_ProgramaSemanaCerrada (NOLOCK)
            on OT_ProgramaSemanaCerrada.SemanaID = #tmpSemanas.ID
               and OT_ProgramaSemanaCerrada.IdOTSolicitud = @pIdOTSolicitud
               and OT_ProgramaSemanaCerrada.isActivo = 1
--WHERE FechaFin >= DATEADD(dd,-15,GETDATE())
--Solo mostrar semanas que no excedan los 15 días de tolerancia


END
