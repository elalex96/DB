-----------------------------------------------------------------------------------------------------------------------------------
-- Modificado por Pedro Acuna 29-Jun-2022 por el issue 2088 Adinco
-- Modificado por Neri del Angel 20 de Julio del 2022 en Issue 2088 (Se quito el Max en NVARCHAR, se elimina subquery y los left join se eliminan completamente)

ALTER PROC p_OT_ConsultaSolicitudProgramaCaptura
    @pIdOTSolicitud INT,
    @pSemana VARCHAR(21),
    @pSoloVoBo BIT = 0
AS
BEGIN

    DECLARE @fechaIniFiltro DATETIME = NULL,
            @fechaFinFiltro DATETIME = NULL,
            @semanaCerrada BIT = 0

    CREATE TABLE #tmpResult
    (
        IdOTSolicitudMaterial INT,
        Material NVARCHAR(200),
        IdOTSolicitud INT,
        Folio VARCHAR(30),
        LunesCaptura DECIMAL(14, 5),
        MartesCaptura DECIMAL(14, 5),
        MiercolesCaptura DECIMAL(14, 5),
        JuevesCaptura DECIMAL(14, 5),
        ViernesCaptura DECIMAL(14, 5),
        SabadoCaptura DECIMAL(14, 5),
        DomingoCaptura DECIMAL(14, 5),
        IdEstatus INT,
        LunesVoBoC BIT,
        MartesVoBoC BIT,
        MiercolesVoBoC BIT,
        JuevesVoBoC BIT,
        ViernesVoBoC BIT,
        SabadoVoBoC BIT,
        DomingoVoBoC BIT,
        LunesVoBoSC BIT,
        MartesVoBoSC BIT,
        MiercolesVoBoSC BIT,
        JuevesVoBoSC BIT,
        ViernesVoBoSC BIT,
        SabadoVoBoSC BIT,
        DomingoVoBoSC BIT,
        LunesCerrado BIT,
        MartesCerrado BIT,
        MiercolesCerrado BIT,
        JuevesCerrado BIT,
        ViernesCerrado BIT,
        SabadoCerrado BIT,
        DomingoCerrado BIT,
        UploadFile VARCHAR(10),
        TieneArchivos BIT,
        Disponible DECIMAL(14, 5)
    )

    CREATE TABLE #tmpDatos
    (
        IdOTSolicitudMaterial INT,
        LunesCaptura DECIMAL(14, 5),
        MartesCaptura DECIMAL(14, 5),
        MiercolesCaptura DECIMAL(14, 5),
        JuevesCaptura DECIMAL(14, 5),
        ViernesCaptura DECIMAL(14, 5),
        SabadoCaptura DECIMAL(14, 5),
        DomingoCaptura DECIMAL(14, 5),
        LunesVoBoC BIT,
        MartesVoBoC BIT,
        MiercolesVoBoC BIT,
        JuevesVoBoC BIT,
        ViernesVoBoC BIT,
        SabadoVoBoC BIT,
        DomingoVoBoC BIT,
        LunesVoBoSC BIT,
        MartesVoBoSC BIT,
        MiercolesVoBoSC BIT,
        JuevesVoBoSC BIT,
        ViernesVoBoSC BIT,
        SabadoVoBoSC BIT,
        DomingoVoBoSC BIT,
        LunesCerrado BIT,
        MartesCerrado BIT,
        MiercolesCerrado BIT,
        JuevesCerrado BIT,
        ViernesCerrado BIT,
        SabadoCerrado BIT,
        DomingoCerrado BIT
    )

    CREATE TABLE #tmpSemana (Fecha VARCHAR(10))

    CREATE TABLE #tmpArchivos
    (
        Id INT,
        IdOTSolicitudMaterial INT
    )

    CREATE TABLE #tmpDisponibles
    (
        IdOTSolicitudMaterial INT,
        Cantidad DECIMAL(14, 5),
        Disponible DECIMAL(14, 5)
    )
    CREATE TABLE #tmpCaptura
    (
        IdOTSolicitudMaterial INT,
        Captura DECIMAL(14, 5)
    )

    IF (@pSemana <> '')
    BEGIN
        INSERT INTO #tmpSemana
        (
            Fecha
        )
        SELECT splitdata
        FROM [dbo].[fnSplitString](@pSemana, '-')
    END
    ELSE
    BEGIN
        INSERT INTO #tmpSemana
        (
            Fecha
        )
        SELECT CONVERT(VARCHAR, OT_SolicitudProgramaCaptura.Fecha, 112)
        FROM OT_Solicitud (NOLOCK)
            INNER JOIN [dbo].[OT_SolicitudMaterial] (NOLOCK)
                ON OT_Solicitud.idOTSolicitud = OT_SolicitudMaterial.IdOTSolicitud
            INNER JOIN [dbo].[OT_SolicitudProgramaCaptura] (NOLOCK)
                ON OT_SolicitudMaterial.IdOTSolicitudMaterial = OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial
        WHERE OT_Solicitud.IdOTSolicitud = @pIdOTSolicitud
        GROUP BY CONVERT(VARCHAR, OT_SolicitudProgramaCaptura.Fecha, 112)
    END

    IF EXISTS (SELECT 1 FROM #tmpSemana)
    BEGIN
        SELECT @fechaIniFiltro = MIN(Fecha),
               @fechaFinFiltro = MAX(fecha)
        FROM #tmpSemana
    END

    INSERT INTO #tmpDisponibles
    (
        IdOTSolicitudMaterial,
        Cantidad,
        Disponible
    )
    SELECT OT_SolicitudPrograma.IdOTSolicitudMaterial,
           Cantidad = SUM(OT_SolicitudPrograma.Cantidad),
           Disponible = 0
    FROM dbo.OT_SolicitudPrograma (NOLOCK)
        INNER JOIN dbo.OT_SolicitudMaterial (NOLOCK)
            ON OT_SolicitudPrograma.IdOTSolicitudMaterial = OT_SolicitudMaterial.IdOTSolicitudMaterial
    WHERE OT_SolicitudMaterial.IdOTSolicitud = @pIdOTSolicitud
    GROUP BY OT_SolicitudPrograma.IdOTSolicitudMaterial,
             OT_SolicitudMaterial.IdOTSolicitud

    INSERT INTO #tmpCaptura
    (
        IdOTSolicitudMaterial,
        Captura
    )
    SELECT #tmpDisponibles.IdOTSolicitudMaterial,
           ISNULL(SUM(   CASE
                             WHEN OT_ProgramaSemanaCerrada.IdOTSolicitud IS NOT NULL
                                  AND OT_SolicitudProgramaCaptura.VoBoSubcontratista = 1
                                  AND OT_SolicitudProgramaCaptura.VoBoContratista = 1 THEN
                                 OT_SolicitudProgramaCaptura.Captura
                             WHEN OT_ProgramaSemanaCerrada.IdOTSolicitud IS NULL THEN
                                 OT_SolicitudProgramaCaptura.Captura
                             ELSE
                                 0
                         END
                     ),
                  0
                 )
    FROM #tmpDisponibles
        INNER JOIN dbo.OT_SolicitudMaterial (NOLOCK)
            ON #tmpDisponibles.IdOTSolicitudMaterial = OT_SolicitudMaterial.IdOTSolicitudMaterial
        INNER JOIN dbo.OT_SolicitudProgramaCaptura (NOLOCK)
            ON #tmpDisponibles.IdOTSolicitudMaterial = OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial
        INNER JOIN [dbo].[OT_ProgramaSemanaCerrada] (NOLOCK)
            ON OT_ProgramaSemanaCerrada.IdOTSolicitud = @pIdOTSolicitud
               AND OT_SolicitudMaterial.IdOTSolicitud = OT_ProgramaSemanaCerrada.IdOTSolicitud
               AND OT_SolicitudProgramaCaptura.Fecha
               BETWEEN OT_ProgramaSemanaCerrada.FechaSemanaIni AND OT_ProgramaSemanaCerrada.FechaSemanaFin
               AND OT_ProgramaSemanaCerrada.isActivo = 1
    GROUP BY #tmpDisponibles.IdOTSolicitudMaterial

    UPDATE #tmpDisponibles
    SET #tmpDisponibles.Disponible = Cantidad - #tmpCaptura.Captura
    FROM #tmpDisponibles
        INNER JOIN #tmpCaptura
            ON #tmpDisponibles.IdOTSolicitudMaterial = #tmpCaptura.IdOTSolicitudMaterial

    SELECT @semanaCerrada = 1
    FROM OT_ProgramaSemanaCerrada (NOLOCK)
    WHERE IdOTSolicitud = @pIdOTSolicitud
          AND SemanaID = @pSemana
          AND isactivo = 1

    INSERT INTO #tmpArchivos
    (
        Id,
        IdOTSolicitudMaterial
    )
    SELECT OT_ProgramaAdjuntoSemana.ID,
           OT_ProgramaAdjuntoSemana.IdOTSolicitudMaterial
    FROM OT_ProgramaAdjuntoSemana
        INNER JOIN AWS_Documentos
            ON OT_ProgramaAdjuntoSemana.AWSDocumentoId = AWS_Documentos.AWSDocumentoId
    WHERE CONVERT(varchar, FechaInicioSemana, 112) = CONVERT(VARCHAR, substring(@pSemana, 0, 9), 112)
          AND CONVERT(VARCHAR, FechaFinSemana, 112) = CONVERT(VARCHAR, substring(@pSemana, 10, 16), 112)

    INSERT INTO #tmpResult
    (
        IdOTSolicitudMaterial,
        Material,
        IdOTSolicitud,
        Folio,
        LunesCaptura,
        MartesCaptura,
        MiercolesCaptura,
        JuevesCaptura,
        ViernesCaptura,
        SabadoCaptura,
        DomingoCaptura,
        IdEstatus,
        LunesVoBoC,
        MartesVoBoC,
        MiercolesVoBoC,
        JuevesVoBoC,
        ViernesVoBoC,
        SabadoVoBoC,
        DomingoVoBoC,
        LunesVoBoSC,
        MartesVoBoSC,
        MiercolesVoBoSC,
        JuevesVoBoSC,
        ViernesVoBoSC,
        SabadoVoBoSC,
        DomingoVoBoSC,
        LunesCerrado,
        MartesCerrado,
        MiercolesCerrado,
        JuevesCerrado,
        ViernesCerrado,
        SabadoCerrado,
        DomingoCerrado,
        UploadFile,
        TieneArchivos,
        Disponible
    )
    SELECT OT_SolicitudMaterial.IdOTSolicitudMaterial,
           Material = CAST('[' + SC_Materiales.Concepto + ']' + SC_Materiales.Descripcion AS VARCHAR(200)),
           OT_Solicitud.IdOTSolicitud,
           Folio = OT_Solicitud.Folio,
           LunesCaptura = NULL,
           MartesCaptura = NULL,
           MiercolesCaptura = NULL,
           JuevesCaptura = NULL,
           ViernesCaptura = NULL,
           SabadoCaptura = NULL,
           DomingoCaptura = NULL,
           -----------------------------  
           IdEstatus = 0,
           -----------------------------  
           LunesVoBoC = 0,
           MartesVoBoC = 0,
           MiercolesVoBoC = 0,
           JuevesVoBoC = 0,
           ViernesVoBoC = 0,
           SabadoVoBoC = 0,
           DomingoVoBoC = 0,
           ---------------------------------  
           LunesVoBoSC = 0,
           MartesVoBoSC = 0,
           MiercolesVoBoSC = 0,
           JuevesVoBoSC = 0,
           ViernesVoBoSC = 0,
           SabadoVoBoSC = 0,
           DomingoVoBoSC = 0,
           ----------------------------------  
           LunesCerrado = 0,
           MartesCerrado = 0,
           MiercolesCerrado = 0,
           JuevesCerrado = 0,
           ViernesCerrado = 0,
           SabadoCerrado = 0,
           DomingoCerrado = 0,
           UploadFile = '',
           TieneArchivos = 0,
           Disponible = 0
    FROM dbo.OT_SolicitudMaterial (NOLOCK)
        INNER JOIN dbo.SC_Materiales (NOLOCK)
            ON OT_SolicitudMaterial.IdSCMaterial = SC_Materiales.IdSCMaterial
               AND ISNULL(OT_SolicitudMaterial.Cantidad, 0) > 0
        INNER JOIN Petrovendor.dbo.MM_Material (NOLOCK)
            ON SC_Materiales.IdMaestro = Petrovendor.dbo.MM_Material.IdMaterial
        INNER JOIN dbo.OT_Solicitud (NOLOCK)
            ON OT_SolicitudMaterial.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
    WHERE OT_Solicitud.IdOTSolicitud = @pIdOTSolicitud
    GROUP BY OT_SolicitudMaterial.IdOTSolicitudMaterial,
             OT_Solicitud.IdOTSolicitud,
             OT_Solicitud.Folio,
             SC_Materiales.Concepto,
             SC_Materiales.Descripcion

    UPDATE #tmpResult
    SET #tmpResult.IdEstatus = ISNULL(OT_SolicitudPrograma.IdEstatus, 0)
    FROM #tmpResult
        INNER JOIN dbo.OT_SolicitudPrograma (NOLOCK)
            ON #tmpResult.IdOTSolicitudMaterial = OT_SolicitudPrograma.IdOTSolicitudMaterial

    INSERT INTO #tmpDatos
    (
        IdOTSolicitudMaterial,
        LunesCaptura,
        MartesCaptura,
        MiercolesCaptura,
        JuevesCaptura,
        ViernesCaptura,
        SabadoCaptura,
        DomingoCaptura,
        LunesVoBoC,
        MartesVoBoC,
        MiercolesVoBoC,
        JuevesVoBoC,
        ViernesVoBoC,
        SabadoVoBoC,
        DomingoVoBoC,
        LunesVoBoSC,
        MartesVoBoSC,
        MiercolesVoBoSC,
        JuevesVoBoSC,
        ViernesVoBoSC,
        SabadoVoBoSC,
        DomingoVoBoSC,
        LunesCerrado,
        MartesCerrado,
        MiercolesCerrado,
        JuevesCerrado,
        ViernesCerrado,
        SabadoCerrado,
        DomingoCerrado
    )
    SELECT IdOTSolicitudMaterial = #tmpResult.IdOTSolicitudMaterial,
           LunesCaptura = CASE
                              WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 2 THEN
                                  OT_SolicitudProgramaCaptura.Captura
                          END,
           MartesCaptura = CASE
                               WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 3 THEN
                                   OT_SolicitudProgramaCaptura.Captura
                           END,
           MiercolesCaptura = CASE
                                  WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 4 THEN
                                      OT_SolicitudProgramaCaptura.Captura
                              END,
           JuevesCaptura = CASE
                               WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 5 THEN
                                   OT_SolicitudProgramaCaptura.Captura
                           END,
           ViernesCaptura = CASE
                                WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 6 THEN
                                    OT_SolicitudProgramaCaptura.Captura
                            END,
           SabadoCaptura = CASE
                               WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 7 THEN
                                   OT_SolicitudProgramaCaptura.Captura
                           END,
           DomingoCaptura = CASE
                                WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 1 THEN
                                    OT_SolicitudProgramaCaptura.Captura
                            END,
           -----------------------------  
           LunesVoBoC = CASE
                            WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 2 THEN
                                CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoContratista AS INT)), 0) AS BIT)
                            ELSE
                                0
                        END,
           MartesVoBoC = CASE
                             WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 3 THEN
                                 CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoContratista AS INT)), 0) AS BIT)
                             ELSE
                                 0
                         END,
           MiercolesVoBoC = CASE
                                WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 4 THEN
                                    CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoContratista AS INT)), 0) AS BIT)
                                ELSE
                                    0
                            END,
           JuevesVoBoC = CASE
                             WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 5 THEN
                                 CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoContratista AS INT)), 0) AS BIT)
                             ELSE
                                 0
                         END,
           ViernesVoBoC = CASE
                              WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 6 THEN
                                  CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoContratista AS INT)), 0) AS BIT)
                              ELSE
                                  0
                          END,
           SabadoVoBoC = CASE
                             WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 7 THEN
                                 CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoContratista AS INT)), 0) AS BIT)
                             ELSE
                                 0
                         END,
           DomingoVoBoC = CASE
                              WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 1 THEN
                                  CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoContratista AS INT)), 0) AS BIT)
                              ELSE
                                  0
                          END,
           ---------------------------------  
           LunesVoBoSC = CASE
                             WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 2 THEN
                                 CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoSubcontratista AS INT)), 0) AS BIT)
                             ELSE
                                 0
                         END,
           MartesVoBoSC = CASE
                              WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 3 THEN
                                  CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoSubcontratista AS INT)), 0) AS BIT)
                              ELSE
                                  0
                          END,
           MiercolesVoBoSC = CASE
                                 WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 4 THEN
                                     CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoSubcontratista AS INT)), 0) AS BIT)
                                 ELSE
                                     0
                             END,
           JuevesVoBoSC = CASE
                              WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 5 THEN
                                  CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoSubcontratista AS INT)), 0) AS BIT)
                              ELSE
                                  0
                          END,
           ViernesVoBoSC = CASE
                               WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 6 THEN
                                   CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoSubcontratista AS INT)), 0) AS BIT)
                               ELSE
                                   0
                           END,
           SabadoVoBoSC = CASE
                              WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 7 THEN
                                  CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoSubcontratista AS INT)), 0) AS BIT)
                              ELSE
                                  0
                          END,
           DomingoVoBoSC = CASE
                               WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 1 THEN
                                   CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoSubcontratista AS INT)), 0) AS BIT)
                               ELSE
                                   0
                           END,
           ----------------------------------  
           LunesCerrado = CASE
                              WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 2 THEN
                                  CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.Cerrado AS INT)), 0) AS BIT)
                              ELSE
                                  0
                          END,
           MartesCerrado = CASE
                               WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 3 THEN
                                   CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.Cerrado AS INT)), 0) AS BIT)
                               ELSE
                                   0
                           END,
           MiercolesCerrado = CASE
                                  WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 4 THEN
                                      CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.Cerrado AS INT)), 0) AS BIT)
                                  ELSE
                                      0
                              END,
           JuevesCerrado = CASE
                               WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 5 THEN
                                   CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.Cerrado AS INT)), 0) AS BIT)
                               ELSE
                                   0
                           END,
           ViernesCerrado = CASE
                                WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 6 THEN
                                    CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.Cerrado AS INT)), 0) AS BIT)
                                ELSE
                                    0
                            END,
           SabadoCerrado = CASE
                               WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 7 THEN
                                   CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.Cerrado AS INT)), 0) AS BIT)
                               ELSE
                                   0
                           END,
           DomingoCerrado = CASE
                                WHEN DATEPART(WEEKDAY, OT_SolicitudProgramaCaptura.Fecha) = 1 THEN
                                    CAST(ISNULL(MAX(CAST(OT_SolicitudProgramaCaptura.Cerrado AS INT)), 0) AS BIT)
                                ELSE
                                    0
                            END
    FROM #tmpResult (NOLOCK)
        INNER JOIN dbo.OT_SolicitudProgramaCaptura (NOLOCK)
            ON #tmpResult.IdOTSolicitudMaterial = OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial
               AND OT_SolicitudProgramaCaptura.Fecha
               BETWEEN @fechaIniFiltro AND @fechaFinFiltro
               AND (
                       (
                           @pSoloVoBo = 1
                           AND OT_SolicitudProgramaCaptura.VoBoSubcontratista = 1
                           AND OT_SolicitudProgramaCaptura.VoBoContratista = 1
                       )
                       OR @pSoloVoBo = 0
                   )
    GROUP BY #tmpResult.IdOTSolicitudMaterial,
             OT_SolicitudProgramaCaptura.Captura,
             OT_SolicitudProgramaCaptura.Fecha

    UPDATE #tmpResult
    SET #tmpResult.LunesCaptura = #tmpDatos.LunesCaptura,
        #tmpResult.MartesCaptura = #tmpDatos.MartesCaptura,
        #tmpResult.MiercolesCaptura = #tmpDatos.MiercolesCaptura,
        #tmpResult.JuevesCaptura = #tmpDatos.JuevesCaptura,
        #tmpResult.ViernesCaptura = #tmpDatos.ViernesCaptura,
        #tmpResult.SabadoCaptura = #tmpDatos.SabadoCaptura,
        #tmpResult.DomingoCaptura = #tmpDatos.DomingoCaptura,
        -----------------------------  
        #tmpResult.LunesVoBoC = #tmpDatos.LunesVoBoC,
        #tmpResult.MartesVoBoC = #tmpDatos.MartesVoBoC,
        #tmpResult.MiercolesVoBoC = #tmpDatos.MiercolesVoBoC,
        #tmpResult.JuevesVoBoC = #tmpDatos.JuevesVoBoC,
        #tmpResult.ViernesVoBoC = #tmpDatos.ViernesVoBoC,
        #tmpResult.SabadoVoBoC = #tmpDatos.SabadoVoBoC,
        #tmpResult.DomingoVoBoC = #tmpDatos.DomingoVoBoC,
        ---------------------------------  
        #tmpResult.LunesVoBoSC = #tmpDatos.LunesVoBoSC,
        #tmpResult.MartesVoBoSC = #tmpDatos.MartesVoBoSC,
        #tmpResult.MiercolesVoBoSC = #tmpDatos.MiercolesVoBoSC,
        #tmpResult.JuevesVoBoSC = #tmpDatos.JuevesVoBoSC,
        #tmpResult.ViernesVoBoSC = #tmpDatos.ViernesVoBoSC,
        #tmpResult.SabadoVoBoSC = #tmpDatos.SabadoVoBoSC,
        #tmpResult.DomingoVoBoSC = #tmpDatos.DomingoVoBoSC,
        ----------------------------------  
        #tmpResult.LunesCerrado = #tmpDatos.LunesCerrado,
        #tmpResult.MartesCerrado = #tmpDatos.MartesCerrado,
        #tmpResult.MiercolesCerrado = #tmpDatos.MiercolesCerrado,
        #tmpResult.JuevesCerrado = #tmpDatos.JuevesCerrado,
        #tmpResult.ViernesCerrado = #tmpDatos.ViernesCerrado,
        #tmpResult.SabadoCerrado = #tmpDatos.SabadoCerrado,
        #tmpResult.DomingoCerrado = #tmpDatos.DomingoCerrado
    FROM #tmpResult
        INNER JOIN #tmpDatos
            ON #tmpResult.IdOTSolicitudMaterial = #tmpDatos.IdOTSolicitudMaterial

    UPDATE #tmpResult
    SET #tmpResult.Disponible = ISNULL(#tmpDisponibles.Disponible, 0)
    FROM #tmpResult
        INNER JOIN #tmpDisponibles
            ON #tmpResult.IdOTSolicitudMaterial = #tmpDisponibles.IdOTSolicitudMaterial

    UPDATE #tmpResult
    SET #tmpResult.Disponible = CASE
                                    WHEN #tmpArchivos.IdOTSolicitudMaterial > 0 THEN
                                        CAST(1 AS BIT)
                                    ELSE
                                        CAST(0 AS BIT)
                                END
    FROM #tmpResult
        INNER JOIN #tmpArchivos
            ON #tmpResult.IdOTSolicitudMaterial = #tmpArchivos.IdOTSolicitudMaterial

    SELECT #tmpResult.IdOTSolicitudMaterial,
           #tmpResult.Material,
           #tmpResult.IdOTSolicitud,
           #tmpResult.Folio,
           #tmpResult.Disponible,
           LunesCaptura = MAX(#tmpResult.LunesCaptura),
           MartesCaptura = MAX(#tmpResult.MartesCaptura),
           MiercolesCaptura = MAX(#tmpResult.MiercolesCaptura),
           JuevesCaptura = MAX(#tmpResult.JuevesCaptura),
           ViernesCaptura = MAX(#tmpResult.ViernesCaptura),
           SabadoCaptura = MAX(#tmpResult.SabadoCaptura),
           DomingoCaptura = MAX(#tmpResult.DomingoCaptura),
           TotalSemana = MAX(#tmpResult.LunesCaptura) + MAX(#tmpResult.MartesCaptura)
                         + MAX(#tmpResult.MiercolesCaptura) + MAX(#tmpResult.JuevesCaptura)
                         + MAX(#tmpResult.ViernesCaptura) + MAX(#tmpResult.SabadoCaptura)
                         + MAX(#tmpResult.DomingoCaptura),
           IdEstatus = #tmpResult.IdEstatus,
           #tmpResult.LunesVoBoC,
           #tmpResult.MartesVoBoC,
           #tmpResult.MiercolesVoBoC,
           #tmpResult.JuevesVoBoC,
           #tmpResult.ViernesVoBoC,
           #tmpResult.SabadoVoBoC,
           #tmpResult.DomingoVoBoC,
           ---------------------------------  
           #tmpResult.LunesVoBoSC,
           #tmpResult.MartesVoBoSC,
           #tmpResult.MiercolesVoBoSC,
           #tmpResult.JuevesVoBoSC,
           #tmpResult.ViernesVoBoSC,
           #tmpResult.SabadoVoBoSC,
           #tmpResult.DomingoVoBoSC,
           --------------------------------    
           LunesCerrado = @semanaCerrada,
           MartesCerrado = @semanaCerrada,
           MiercolesCerrado = @semanaCerrada,
           JuevesCerrado = @semanaCerrada,
           ViernesCerrado = @semanaCerrada,
           SabadoCerrado = @semanaCerrada,
           DomingoCerrado = @semanaCerrada,
           #tmpResult.UploadFile,
           #tmpResult.TieneArchivos
    FROM #tmpResult
    GROUP BY #tmpResult.IdOTSolicitudMaterial,
             #tmpResult.Material,
             #tmpResult.IdOTSolicitud,
             #tmpResult.Folio,
             #tmpResult.Disponible,
             #tmpResult.IdEstatus,
             #tmpResult.LunesVoBoC,
             #tmpResult.MartesVoBoC,
             #tmpResult.MiercolesVoBoC,
             #tmpResult.JuevesVoBoC,
             #tmpResult.ViernesVoBoC,
             #tmpResult.SabadoVoBoC,
             #tmpResult.DomingoVoBoC,
             #tmpResult.LunesVoBoSC,
             #tmpResult.MartesVoBoSC,
             #tmpResult.MiercolesVoBoSC,
             #tmpResult.JuevesVoBoSC,
             #tmpResult.ViernesVoBoSC,
             #tmpResult.SabadoVoBoSC,
             #tmpResult.DomingoVoBoSC,
             #tmpResult.UploadFile,
             #tmpResult.TieneArchivos
END