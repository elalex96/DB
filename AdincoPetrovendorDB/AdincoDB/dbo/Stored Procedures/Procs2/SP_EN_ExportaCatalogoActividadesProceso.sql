-- =============================================
-- Author:		<Stephany>
-- Create date: <01/05/20>
-- Description:	<Exporta Catálogo de Actividades>
-- =============================================
-- Author:		<Alexander>
-- Create date: <15/03/23>
-- Description:	<Agregado de columnas de DocumentoEntregable y ReceptorEntregable>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ExportaCatalogoActividadesProceso]
	
    @idContrato INT,
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT P.NombreProceso,
           A.IdActividad AS IdActividad,
           NombreActividad,
           Dias,
           CASE DiasNaturales
               WHEN 0 THEN
                   'Habiles'
               ELSE
                   'Naturales'
           END AS Tipodias,
			ISNULL(R.Regulador,'Calendario Default') AS Regulador,
			ENT.DocumentoEntregable,
			RET.ReceptorEntregable
    FROM EN_Actividades A
    JOIN EN_ProcesosActividades PA ON A.IdActividad = PA.idActividad
    JOIN EN_Procesos P ON PA.IdProceso = P.IdProceso
    JOIN EN_ProcesosContrato PC ON P.IdProceso = PC.idProceso
		AND PC.idContrato = @idContrato
    LEFT JOIN dbo.EN_ActividadesEntregables AE ON A.IdActividad = AE.IdActividad
	LEFT JOIN CO_Regulador AS R ON A.IdRegulador = R.IdRegulador
		JOIN EN_Entregable AS ENT
			ON AE.IdEntregable = ENT.IdEntregable
		JOIN EN_ReceptorEntregable AS RET
			ON ENT.IdReceptorEntregable = RET.IdReceptorEntregable
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
			 R.Regulador,
			 ENT.DocumentoEntregable,
			 RET.ReceptorEntregable
    ORDER BY P.NombreProceso,	
             Orden ASC;


END;
