-- =============================================
-- Author:      Reyna Olvera
-- Create date: 20181023
-- Description:Ordena los procesos por ronda
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_InsertaActividadesAProceso] -- 3,10061,10000,'Prueba Actividad 3,PruebaActividad','1,2'
    @idContrato INT,
    @idUsuario INT,
    @IdProceso INT,
    @NameActividades VARCHAR(MAX),
    @ORDEN NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    --DROP TABLE #NameActivide;
    CREATE TABLE #NameActivide
    (
        id INT PRIMARY KEY IDENTITY(1, 1),
        NombreActividad VARCHAR(MAX)
    );
    --DROP TABLE #ORDEN;
    CREATE TABLE #ORDEN
    (
        id INT PRIMARY KEY IDENTITY(1, 1),
        ORDEN INT
    );
    --DROP TABLE #ProcesosActividades;
    CREATE TABLE #ProcesosActividades
    (
        IdProceso INT,
        idActividad INT,
        IdContrato INT,
        Orden INT
    );
    DECLARE @CountEstatus INT,
            @error NVARCHAR(MAX);
    SELECT @CountEstatus = COUNT(1)
    FROM EN_InstanciasActividades IA
        JOIN 
            EN_InstanciasEntregables_InstanciaActividad IEIA
            ON IEIA.idInstanciaActividad = IA.idInstanciaActividad
        JOIN 
            EN_InstanciasEntregable IE
            ON IEIA.idInstanciaEntregable = IE.idInstanciaEntregable
        JOIN 
            EN_InstanciasProcesosFecha IPF
            ON IPF.IdInstanciasProcesos = IA.IdInstanciasProcesos
        JOIN 
            EN_ProcesosActividades PA
            ON IA.IdActividad = PA.idActividad
        JOIN 
            EN_Actividad
            ON EN_Actividad.ActividadID = IE.ActividadID
    WHERE 
        IPF.IdProceso = @IdProceso
        AND IPF.idContrato = @idContrato
        AND EstadoID <> 10003;
    --Select * from en_procesos
    IF (@CountEstatus = 0)
    BEGIN
        ------------------------------------------------------------------------------------------------***************************************************
        IF (@NameActividades <> '')
        BEGIN
            INSERT INTO #NameActivide (NombreActividad) 
            SELECT REPLACE(splitdata, '*>', '') AS NombreActividad
            FROM [dbo].[fnSplitString](@NameActividades, '<*>');
            INSERT INTO #ORDEN (ORDEN) 
            SELECT CONVERT(INT, splitdata) AS ORDEN
            FROM [dbo].[fnSplitString](@ORDEN, ',');
            INSERT INTO #ProcesosActividades (IdProceso, idActividad, IdContrato, Orden)
            SELECT @IdProceso,
                   A.IdActividad,
                   @idContrato,
                   #ORDEN.ORDEN
            --SELECT *
            FROM #NameActivide NA
                JOIN 
                    #ORDEN
                    ON #ORDEN.id = NA.id
                JOIN 
                    EN_Actividades A
                    ON LTRIM(RTRIM(REPLACE(REPLACE(NA.NombreActividad,CHAR(10),''),CHAR(13),''))) = LTRIM(RTRIM(REPLACE(REPLACE(A.NombreActividad,CHAR(10),''),CHAR(13),'')))
                JOIN 
                    EN_ProcesosActividades PA
                    ON A.IdActividad = PA.idActividad
                    AND PA.IdProceso = @IdProceso
            GROUP BY A.IdActividad,
                     #ORDEN.ORDEN;
            UPDATE EN_ProcesosActividades
            SET Activo = 0,
                Orden = NULL
            WHERE IdProceso = @IdProceso
                  AND IdContrato = @idContrato
                  AND ORDEN >= 0;

            DELETE PA
            --SELECT *
            FROM dbo.EN_ProcesosActividades PA
            JOIN 
                #ProcesosActividades PAG
                ON PA.IdProceso = PAG.IdProceso
                AND PA.idActividad = PAG.idActividad
                AND PA.IdContrato = PAG.IdContrato
            WHERE 
                PA.Orden IS NULL
            INSERT INTO dbo.EN_ProcesosActividades (IdProceso, idActividad, IdContrato, Orden, CreadoPor, CreadoEl,
                                               ModificadoPor, ModificadoEl, Activo)
            SELECT IdProceso,
                   idActividad,
                   IdContrato,
                   Orden,
                   @idUsuario,
                   GETDATE(),
                   @idUsuario,
                   GETDATE(),
                   1
            FROM #ProcesosActividades;
        ---------------------------------------------------------------------------------------------------------
        END;
    END;
    ELSE
    BEGIN
        SET @error
            = N'No puede modificarse, ya que las actividades ahora pertenecientes a este proceso tienen fechas ya calculadas con estatus diferentes a finalizado';
        SELECT @error;
    END;
END;