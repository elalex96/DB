-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Llama las rondas
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeMacroProcesos] --3,10061,10001
    @idContrato INT,
    @idUsuario INT,
    @idTipoProceso INT
AS
BEGIN

    SET NOCOUNT ON;
    IF (@idTipoProceso = 0)
    BEGIN

        SELECT p.IdProceso,
               NombreProceso,
               p.Descripcion,
               idTipoProceso,
               CASE idTipoProceso
                   WHEN 10001 THEN
                       'Es macroproceso'
                   WHEN 10000 THEN
                       CASE
                           WHEN p.IdInstalacion IS NULL THEN
                               'Proceso para copiar en diferentes instalaciones'
                           ELSE
                               LTRIM(COUNT(IPF.IdInstanciasProcesos)) + ' estimación de fechas guardadas'
                       END
               END AS instancias,
               p.IsProcesoEvento,
               ISNULL(p.IdInstalacion, 0) AS IdInstalacion,
			   0 AS IsMacroprocesoCalculo
        FROM EN_Procesos p
        JOIN EN_ProcesosContrato PC ON p.IdProceso = PC.idProceso
                                       AND PC.idContrato = @idContrato
        LEFT JOIN dbo.EN_InstanciasProcesosFecha IPF ON p.IdProceso = IPF.IdProceso
        GROUP BY p.IdProceso,
                 NombreProceso,
                 p.Descripcion,
                 idTipoProceso,
                 p.IsProcesoEvento,
                 p.IdInstalacion
        ORDER BY idTipoProceso, COUNT(IPF.IdInstanciasProcesos) desc;
    END;
    ELSE
    BEGIN
        SELECT p.IdProceso,
               NombreProceso  as NombreProceso,
               Descripcion,
               idTipoProceso,
               'Macroproceso' AS instancias,
               p.IsProcesoEvento,
               0 AS IdInstalacion,
			   CASE p.idTipoProceso
				   WHEN 10001
				   THEN 0
				   WHEN 10002
				   THEN 1
			   END AS IsMacroprocesoCalculo
        FROM EN_Procesos p
        JOIN EN_ProcesosContrato PC ON p.IdProceso = PC.idProceso
                                       AND PC.idContrato = @idContrato
		Left join CO_Instalacion C on p.IdInstalacion=C.IdInstalacion
        WHERE idTipoProceso IN (@idTipoProceso,10002);
    END;
END;






