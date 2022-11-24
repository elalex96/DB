-- =============================================
-- Author:		<Stephany>
-- Create date: <01/05/20>
-- Description:	<Exporta Catálogo de Actividades>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ExportaCatalogoActividadesProceso] --3, 10082
	
    @idContrato INT,
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT --P.IdProceso,
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
           --Orden,
           --COUNT(AE.IdEntregable) AS CantEntreg ,
		   --pa.Activo,
			ISNULL(R.Regulador,'Calendario Default') AS Regulador
    FROM EN_Actividades A
    JOIN EN_ProcesosActividades PA ON A.IdActividad = PA.idActividad
    JOIN EN_Procesos P ON PA.IdProceso = P.IdProceso
    JOIN EN_ProcesosContrato PC ON P.IdProceso = PC.idProceso
                                   AND PC.idContrato = @idContrato
    LEFT JOIN dbo.EN_ActividadesEntregables AE ON A.IdActividad = AE.IdActividad
	LEFT JOIN CO_Regulador AS R ON R.IdRegulador = A.IdRegulador
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
			 pa.Activo,
			 R.Regulador
    ORDER BY --idProceso,
			 P.NombreProceso,	
             Orden ASC;


END;
