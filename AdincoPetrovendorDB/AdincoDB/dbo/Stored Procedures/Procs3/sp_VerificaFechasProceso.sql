-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Genera Calculo de fechas
-- =============================================
CREATE PROCEDURE [dbo].[sp_VerificaFechasProceso]--3,10061,12092,11047--SIMULACION 
    @idContrato INT,
    @idUsuario INT,
    @idProceso INT,
    @idInstanciaProceso INT
AS
BEGIN
    --DECLARE @idContrato INT=3,
    --    @idUsuario INT=2,
    --    @idProceso INT=10011

    IF OBJECT_ID('tempdb.dbo.#ActividadesGuarda', 'U') IS NOT NULL
        DROP TABLE #ActividadesGuarda;
    CREATE TABLE #ActividadesGuarda
    (
        IdProceso INT,
        DescripcionProceso VARCHAR(500),
        IdContrato INT,
        Orden INT,
        IdActividad INT,
        NombreActividad VARCHAR(500),
        Dias INT,
        DiasNaturales BIT,
        FechaInicial DATE,
        FechaLimite DATE,
        IdActividadPredecesora INT,
        IdActividadSucesora INT
    );

    IF OBJECT_ID('tempdb.dbo.#ProcesosDeMacro', 'U') IS NOT NULL
        DROP TABLE #ProcesosDeMacro;
    CREATE TABLE #ProcesosDeMacro
    (
        id INT IDENTITY(1, 1),
        IdProceso INT
    );

    CREATE TABLE #InstanciasProcesos
    (
        id INT IDENTITY(1, 1),
        IdinstanciaProceso INT
    );
    IF OBJECT_ID('tempdb.dbo.#SelectFinal', 'U') IS NOT NULL
        DROP TABLE #SelectFinal;
    CREATE TABLE #SelectFinal
    (
        IdProceso INT,
        DescripcionProceso VARCHAR(500),
        IdContrato INT,
        Orden INT,
        IdActividad INT,
        NombreActividad VARCHAR(500),
        Dias INT,
        DiasNaturales BIT,
        FechaInicial DATE,
        FechaLimite DATE,
        IdActividadPredecesora INT,
        IdActividadSucesora INT,
        Fecha DATE,
        FechaInicialBit BIT,
        Descripcion VARCHAR(1000),
        idTipoProceso INT,
        IdInstalacion INT,
        Banderas INT,
        idInstanciaActividad INT,
        FechaRealActividad BIT
    );

    CREATE TABLE #FechasRepetidass
    (
        BanderaCount INT,
        FechaLimite DATE
    );
    DECLARE @Fecha DATE,
            @FechaSeleccionada INT,
            @CountProcesos INT,
            @idTipoProceso INT,
            @contador INT = 1,
            @idProcecito INT,
            @IdInstanciasProcesos INT;

    SELECT @idTipoProceso = idTipoProceso
    FROM dbo.EN_Procesos
    WHERE IdProceso = @idProceso;

    IF (@idTipoProceso = 10000)
    BEGIN
        SELECT @Fecha = Fecha,
               @FechaSeleccionada = FechaInicial
        FROM EN_InstanciasProcesosFecha
        WHERE idContrato = @idContrato
              AND IdProceso = @idProceso
              AND IdInstanciasProcesos = @idInstanciaProceso;

        IF (@FechaSeleccionada = 1) --Fecha Inicial
        BEGIN

            INSERT INTO #ActividadesGuarda (IdProceso, DescripcionProceso, IdContrato, Orden, IdActividad,
                                            NombreActividad, Dias, DiasNaturales, FechaInicial, FechaLimite,
                                            IdActividadPredecesora, IdActividadSucesora)
            EXEC sp_GeneraFechasProcesos @idContrato, @idUsuario, @Fecha, @idProceso;

        END;
        ELSE IF (@FechaSeleccionada = 0) --Fecha final
        BEGIN

            INSERT INTO #ActividadesGuarda (IdProceso, DescripcionProceso, IdContrato, Orden, IdActividad,
                                            NombreActividad, Dias, DiasNaturales, FechaInicial, FechaLimite,
                                            IdActividadPredecesora, IdActividadSucesora)
            EXEC sp_GeneraFechasProcesosConFechaFinal @idContrato,
                                                      @idUsuario,
                                                      @Fecha,
                                                      @idProceso;

        END;

        -----*********************************Modificar aquí****************************************
        INSERT INTO #SelectFinal (IdProceso, DescripcionProceso, IdContrato, Orden, IdActividad, NombreActividad, Dias,
                                  DiasNaturales, FechaInicial, FechaLimite, IdActividadPredecesora,
                                  IdActividadSucesora, Fecha, FechaInicialBit, Descripcion, idTipoProceso,
                                  IdInstalacion, Banderas, idInstanciaActividad, FechaRealActividad)
        SELECT A.IdProceso,
               A.DescripcionProceso,
               A.IdContrato,
               A.Orden,
               A.IdActividad,
               A.NombreActividad,
               A.Dias,
               A.DiasNaturales,
               A.FechaInicial,
               CASE ISNULL(IA.FechaRealActividad, '')
                   WHEN '' THEN
                       A.FechaLimite
                   ELSE
                       IA.FechaRealActividad
               END AS FechaLimite,
               A.IdActividadPredecesora,
               A.IdActividadSucesora,
               P.Fecha,
               P.FechaInicial,
               P.Descripcion,
               @idTipoProceso,
               pr.IdInstalacion,
               NULL,
               IA.idInstanciaActividad AS IdInstanciaActividad,
               CASE ISNULL(IA.FechaRealActividad, '')
                   WHEN '' THEN
                       'False'
                   ELSE
                       'True'
               END AS FechaRealActividad
        FROM #ActividadesGuarda A
        JOIN EN_InstanciasProcesosFecha P ON P.IdProceso = A.IdProceso
                                             AND P.idContrato = @idContrato
                                             AND P.IdInstanciasProcesos = @idInstanciaProceso
        JOIN dbo.EN_Procesos pr ON P.IdProceso = pr.IdProceso
        JOIN dbo.EN_InstanciasActividades IA ON P.IdInstanciasProcesos = IA.IdInstanciasProcesos
                                                AND A.FechaLimite = IA.FechaActividad
                                                AND IA.Activo = 1
                                                AND A.IdActividad = IA.IdActividad;

        INSERT INTO #FechasRepetidass (BanderaCount, FechaLimite)
        SELECT COUNT(*),
               FechaLimite
        FROM #SelectFinal
        GROUP BY FechaLimite
        HAVING COUNT(*) > 1;

        UPDATE SF
        SET Banderas = ISNULL(FR.BanderaCount, 0)
        FROM #SelectFinal SF
        LEFT JOIN #FechasRepetidass FR ON FR.FechaLimite = SF.FechaLimite;

        SELECT s.*,
               ROW_NUMBER() OVER (ORDER BY FechaLimite ASC) AS c,
               p.NombreProceso,
               'False' AS isMacroProceso,
               s.idInstanciaActividad,
               s.FechaRealActividad
        FROM #SelectFinal s
        JOIN dbo.EN_Procesos p ON s.IdProceso = p.IdProceso
        ORDER BY FechaLimite ASC;
    -----********************************************************************************************
    END;
    ELSE
    BEGIN
        SELECT @CountProcesos = COUNT(*)
        FROM EN_MacroProcesosRelacion
        WHERE idMacroProceso = @idProceso;
        INSERT INTO #ProcesosDeMacro (IdProceso)
        (SELECT idProcesoHijo
         FROM dbo.EN_MacroProcesosRelacion
         WHERE idMacroProceso = @idProceso);
        --SELECT * From #ProcesosDeMacro
        WHILE (@contador <= @CountProcesos)
        BEGIN
            SELECT @idProcecito = IdProceso
            FROM #ProcesosDeMacro
            WHERE id = @contador;

            SET @IdInstanciasProcesos = 0;
            SET @IdInstanciasProcesos =
   (
       SELECT TOP 1
                       (IdInstanciasProcesos)
                FROM EN_InstanciasProcesosFecha
                WHERE idContrato = @idContrato
                      AND IdProceso = @idProcecito
                ORDER BY IdInstanciasProcesos DESC
            );

            INSERT INTO #InstanciasProcesos (IdinstanciaProceso)
            VALUES
            (@IdInstanciasProcesos);

            --SELECT @IdInstanciasProcesos;
            SELECT --*
                @Fecha = Fecha,
                @FechaSeleccionada = FechaInicial
            FROM EN_InstanciasProcesosFecha
            WHERE idContrato = @idContrato
                  AND IdProceso = @idProcecito
                  AND IdInstanciasProcesos = @IdInstanciasProcesos; --************
            --			ORDER BY IdInstanciasProcesos DESC;

            IF (@IdInstanciasProcesos <> 0)
            BEGIN
                IF (@FechaSeleccionada = 1) --Fecha Inicial
                BEGIN

                    INSERT INTO #ActividadesGuarda (IdProceso, DescripcionProceso, IdContrato, Orden, IdActividad,
                                                    NombreActividad, Dias, DiasNaturales, FechaInicial, FechaLimite,
                                                    IdActividadPredecesora, IdActividadSucesora)
                    EXEC sp_GeneraFechasProcesos @idContrato, @idUsuario, @Fecha, @idProcecito;
                --3,2,'2019-05-16',11028--
                END;
                ELSE IF (@FechaSeleccionada = 0) --Fecha final
                BEGIN

                    INSERT INTO #ActividadesGuarda (IdProceso, DescripcionProceso, IdContrato, Orden, IdActividad,
                                                    NombreActividad, Dias, DiasNaturales, FechaInicial, FechaLimite,
                                                    IdActividadPredecesora, IdActividadSucesora)
                    EXEC sp_GeneraFechasProcesosConFechaFinal @idContrato,
                                                              @idUsuario,
                                                              @Fecha,
                                                              @idProcecito;


                END;
            END;
            SET @contador = @contador + 1;
        END;
        -----*********************************Modificar aquí****************************************
        INSERT INTO #SelectFinal (IdProceso, DescripcionProceso, IdContrato, Orden, IdActividad, NombreActividad, Dias,
                                  DiasNaturales, FechaInicial, FechaLimite, IdActividadPredecesora,
                                  IdActividadSucesora, Fecha, FechaInicialBit, Descripcion, idTipoProceso,
                                  IdInstalacion, Banderas, idInstanciaActividad, FechaRealActividad)
        SELECT A.IdProceso,
               A.DescripcionProceso,
               A.IdContrato,
               A.Orden,
               A.IdActividad,
               A.NombreActividad,
               A.Dias,
               A.DiasNaturales,
               A.FechaInicial,
               CASE ISNULL(IA.FechaRealActividad, '')
                   WHEN '' THEN
                       A.FechaLimite
                   ELSE
                       IA.FechaRealActividad
               END AS FechaLimite,
               A.IdActividadPredecesora,
               A.IdActividadSucesora,
               --  A.*,
               P.Fecha,
               P.FechaInicial,
               P.Descripcion,
               @idTipoProceso AS idtipoProceso,
               '0',
               NULL,
               IA.idInstanciaActividad,
               CASE ISNULL(IA.FechaRealActividad, '')
                   WHEN '' THEN
                       'False'
                   ELSE
                       'True'
               END AS FechaRealActividad
        FROM #ActividadesGuarda A
        JOIN EN_InstanciasProcesosFecha P ON P.IdProceso = A.IdProceso
                                             AND P.idContrato = @idContrato
        JOIN #InstanciasProcesos I ON P.IdInstanciasProcesos = I.IdinstanciaProceso
        JOIN dbo.EN_InstanciasActividades IA ON P.IdInstanciasProcesos = IA.IdInstanciasProcesos
                                                AND A.FechaLimite = IA.FechaActividad
                                                AND IA.Activo = 1
                                                AND A.IdActividad = IA.IdActividad
        ORDER BY A.FechaLimite ASC;
        -----********************************************************************************************
        INSERT INTO #FechasRepetidass (BanderaCount, FechaLimite)
        SELECT COUNT(*),
               FechaLimite
        FROM #SelectFinal
        GROUP BY FechaLimite
        HAVING COUNT(*) > 1;

        UPDATE SF
        SET Banderas = ISNULL(FR.BanderaCount, 0)
        FROM #SelectFinal SF
        LEFT JOIN #FechasRepetidass FR ON FR.FechaLimite = SF.FechaLimite;

        SELECT s.*,
               ROW_NUMBER() OVER (ORDER BY FechaLimite ASC) AS c,
               p.NombreProceso,
               'True' AS isMacroProceso,
               s.idInstanciaActividad AS IdInstanciaActividad,
               s.FechaRealActividad
        FROM #SelectFinal s
        JOIN dbo.EN_Procesos p ON p.IdProceso = @idProceso
        ORDER BY FechaLimite ASC;

    END;

END;

--[sp_VerificaFechasProceso]3,10061,12110,0


