CREATE PROCEDURE [dbo].[sp_EN_ExtraeActividadesExcluyeProceso] --10010,10061,10011
    @idContrato INT,
    @idUsuario INT,
    @idProceso INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT A.IdActividad,
           NombreActividad,
           Dias,
           CASE DiasNaturales
               WHEN 0 THEN
                   'Habiles'
               ELSE
                   'Naturales'
           END AS Tipodedias,
           IdProceso,
           IdContrato,
           P.Orden
    FROM EN_Actividades A
    JOIN 
        EN_ProcesosActividades P
        ON A.IdActividad = P.idActividad
        AND P.IdProceso = @idProceso
        AND P.IdContrato = @idContrato
      
    WHERE
        P.Orden IS NULL
     AND P.Activo = 0
END;