-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Verifica las instancias de los procesos
-- =============================================
CREATE PROCEDURE [dbo].[sp_VerificainstanciasProcesoReal] --3,10061,12092--SIMULACION 
    @idContrato INT,
    @idUsuario INT,
    @idProceso INT
AS
BEGIN
    SET LANGUAGE spanish;
    DECLARE @idTipoProceso INT;
    SELECT @idTipoProceso = idTipoProceso
    FROM dbo.EN_Procesos
    WHERE IdProceso = @idProceso;

    CREATE TABLE #ContienenFechaReal
    (
        IdInstanciasProcesos INT
    );

    IF (@idTipoProceso = 10001)
    BEGIN
        SELECT IdInstanciasProcesos,
               MP.Descripcion,
               LTRIM(DAY(Fecha)) + '-' + DATENAME(MONTH, Fecha) + '-' + LTRIM(YEAR(Fecha)) AS Fecha,
               U.Nombre AS 'Creadopor',
               MIN(MCP.CreadoEn),
               LTRIM(DAY(FechaInicioProceso)) + '-' + DATENAME(MONTH, FechaInicioProceso) + '-'
               + LTRIM(YEAR(FechaInicioProceso)) AS FechaInicioProceso,
               LTRIM(DAY(FechaFinProceso)) + '-' + DATENAME(MONTH, FechaFinProceso) + '-'
               + LTRIM(YEAR(FechaFinProceso)) AS FechaFinProceso
        FROM dbo.EN_MacroProcesosRelacion MCP
        JOIN dbo.EN_Procesos MP ON MP.IdProceso = MCP.idProcesoHijo
        JOIN dbo.EN_InstanciasProcesosFecha IP ON MCP.idProcesoHijo = IP.IdProceso
        JOIN dbo.AP_Usuario U ON U.UsuarioID = IP.CreadoPor
        WHERE MCP.idMacroProceso = @idProceso
              AND idContrato = @idContrato
        GROUP BY IdInstanciasProcesos,
                 MP.Descripcion,
                 Fecha,
                 U.Nombre,
                 FechaInicioProceso,
                 FechaFinProceso; --*********************************

    END;
    ELSE
    BEGIN
        SELECT IP.IdInstanciasProcesos,
               LTRIM(DAY(Fecha)) + '-' + DATENAME(MONTH, Fecha) + '-' + LTRIM(YEAR(Fecha)) AS Fecha,
               U.Nombre AS 'Creadopor',
               Descripcion,
               LTRIM(DAY(FechaInicioProceso)) + '-' + DATENAME(MONTH, FechaInicioProceso) + '-'
               + LTRIM(YEAR(FechaInicioProceso)) AS FechaInicioProceso,
               LTRIM(DAY(FechaFinProceso)) + '-' + DATENAME(MONTH, FechaFinProceso) + '-'
               + LTRIM(YEAR(FechaFinProceso)) AS FechaFinProceso
        FROM dbo.EN_InstanciasProcesosFecha IP
        JOIN EN_InstanciasActividades IA ON IP.IdInstanciasProcesos = IA.IdInstanciasProcesos
                                            AND IA.FechaRealActividad IS NOT NULL
        JOIN dbo.AP_Usuario U ON U.UsuarioID = IP.CreadoPor
        WHERE IdProceso = @idProceso
              AND idContrato = @idContrato
        GROUP BY IP.IdInstanciasProcesos,
                 Descripcion,
                 Fecha,
                 U.Nombre,
                 FechaInicioProceso,
                 FechaFinProceso;
    END;
END;

