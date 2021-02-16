-- =============================================
-- Author:		<Stephany>
-- Create date: < 04/05/20>
-- Description:	<Exporta Procesos de Pantalla Alta de Procesos>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ExportaProcesos] --3, 10082
	-- Add the parameters for the stored procedure here
	@idContrato INT,
    @idUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT --P.IdProceso,
		   --idTipoProceso,
		   --IdInstalacion,
		   P.NombreProceso,
		   P.Descripcion,
		   CASE WHEN IsProcesoEvento = 1 
		        THEN 'Proceso por Evento' 
				ELSE 'Proceso de Frecuencia' 
		   END AS    TipoProceso,
		   CASE WHEN IsSerie = 1 
				THEN 'Proceso con Actividades Secuenciales' 
				ELSE 'Proceso con Actividades en Paralelo' 
			END	AS TipoFlujoProceso,
		   --MIN(IA.FechaInicioActividad) AS FechaInicio,
		  -- MAX(ISNULL(IA.FechaRealActividad,FechaActividad)) AS FechaFin,
		   A.NombreActividad,
		   --PA.IdActividad,
		   ISNULL(E.DocumentoEntregable,'') AS DocumentoEntregable
		   --E.IdEntregable
	FROM EN_Procesos P
	JOIN EN_ProcesosContrato PC ON P.IdProceso = PC.idProceso
                                   AND PC.idContrato = @idContrato
    JOIN EN_ProcesosActividades PA ON P.IdProceso = PA.IdProceso
	JOIN EN_Actividades A ON PA.IdActividad = A.IdActividad
	LEFT JOIN EN_ActividadesEntregables AE ON A.IdActividad = AE.IdActividad
	--JOIN EN_InstanciasActividades IA ON AE.IdActividad = IA.IdActividad
	--JOIN EN_InstanciasProcesosFecha IPF ON IPF.IdInstanciasProcesos = IA.IdInstanciasProcesos
    --JOIN EN_Procesos P ON PA.IdProceso = P.IdProceso
    
	LEFT JOIN EN_Entregable E ON E.IdEntregable = AE.IdEntregable
	WHERE PC.idContrato = @idContrato
	      AND P.IdTipoProceso = 10000
          AND PC.Activo = 1
          AND P.Activo = 1
		  AND PA.Activo = 1
		  AND A.Activo = 1


    GROUP BY --P.IdProceso,
             P.NombreProceso,
			 P.Descripcion,
			CASE WHEN IsProcesoEvento = 1 
		        THEN 'Proceso por Evento' 
				ELSE 'Proceso de Frecuencia' 
		   END,
		   CASE WHEN IsSerie = 1 
				THEN 'Proceso con Actividades Secuenciales' 
				ELSE 'Proceso con Actividades en Paralelo' 
			END,
             --PA.IdActividad,
			 --FechaInicio,
			-- FechaFin,
             A.NombreActividad,
			 E.DocumentoEntregable

    ORDER BY --idProceso,
			 P.NombreProceso ASC


END
GO


