-- =============================================
-- Author:	Reyna Olvera
-- Create date: 12/01/2018
-- Description:	Extrae las actividades
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeCatalogoActividades] --3,10061,10011
    @idContrato INT,
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT P.IdProceso,
           P.NombreProceso,
           A.IdActividad AS IdActividad,
           NombreActividad,
           Dias,
           CASE DiasNaturales
               WHEN 0 THEN
                   'Habiles'
               ELSE
                   'Naturales'
           END AS Tipodias,
           Orden,
           COUNT(AE.IdEntregable) AS CantEntreg ,
		    pa.Activo
    FROM EN_Actividades A
    JOIN EN_ProcesosActividades PA ON A.IdActividad = PA.idActividad
    JOIN EN_Procesos P ON PA.IdProceso = P.IdProceso
    JOIN EN_ProcesosContrato PC ON P.IdProceso = PC.idProceso
                                   AND PC.idContrato = @idContrato
    LEFT JOIN dbo.EN_ActividadesEntregables AE ON A.IdActividad = AE.IdActividad
    WHERE PC.idContrato = @idContrato
          AND PC.Activo = 1
          AND P.Activo = 1
		  AND PA.Orden >= 0
    GROUP BY P.IdProceso,
             P.NombreProceso,
             A.IdActividad,
             NombreActividad,
             Dias,
             DiasNaturales,
             Orden,
			 pa.Activo
    ORDER BY idProceso,
             Orden ASC;


END;




