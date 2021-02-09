-- =============================================
-- Author:		<Stephany>
-- Create date: <30/04/2020>
-- Description:	<Exporta Macroprocesos>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ExportaMacroprocesos] --3, 10082
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MC.NombreProceso AS NombreMacroproceso,			   
		  --MC.Descripcion AS DescripcionMacroproceso,
		  P.NombreProceso,
		  --P.Descripcion,
		  CASE WHEN P.IsProcesoEvento = 1 
		        THEN 'Proceso por Evento' 
				ELSE 'Proceso de Frecuencia' 
		   END AS    TipoProceso,
		   CASE WHEN P.IsSerie = 1 
				THEN 'Proceso con Actividades Secuenciales' 
				ELSE 'Proceso con Actividades en Paralelo' 
			END	AS TipoFlujoProceso,
		  A.NombreActividad,
		  ISNULL(E.DocumentoEntregable,'') AS DocumentoEntregable,
		  (IA.FechaInicioActividad) AS FechaInicio,
		  ISNULL(IA.FechaRealActividad,FechaActividad) AS FechaFin
	       
	FROM
		EN_MacroProcesosRelacion MP
    JOIN EN_Procesos MC ON MP.idMacroProceso = MC.IdProceso
	JOIN EN_ProcesosContrato PC ON MC.IdProceso	= PC.IdProceso
					AND PC.IdContrato =	@IdContrato
    JOIN EN_Procesos P ON MP.idProcesoHijo = P.IdProceso	

	JOIN EN_ProcesosActividades PA ON P.IdProceso = PA.IdProceso
	JOIN EN_Actividades A ON PA.IdActividad = A.IdActividad
	LEFT JOIN EN_InstanciasActividades IA ON IA.IdActividad = A.IdActividad
	LEFT JOIN En_InstanciasProcesosFecha	IPF	ON IA.IdInstanciasProcesos = IPF.IdInstanciasProcesos
	LEFT JOIN EN_ActividadesEntregables AE ON A.IdActividad = AE.IdActividad
	LEFT JOIN EN_Entregable E ON E.IdEntregable = AE.IdEntregable

	WHERE P.idTipoProceso <> 10000
	      --PC.idContrato = @idContrato	      
          AND PC.Activo = 1
          AND P.Activo = 1
		  AND PA.Activo = 1
		  AND A.Activo = 1


	GROUP BY MC.NombreProceso,
			-- MC.Descripcion,
			 P.NombreProceso,
			 --P.Descripcion,
			 CASE WHEN P.IsProcesoEvento = 1 
		        THEN 'Proceso por Evento' 
				ELSE 'Proceso de Frecuencia' 
		   END,
		   CASE WHEN P.IsSerie = 1 
				THEN 'Proceso con Actividades Secuenciales' 
				ELSE 'Proceso con Actividades en Paralelo' 
			END,
             A.NombreActividad,
			 E.DocumentoEntregable,
			 IA.FechaInicioActividad,
		     IA.FechaRealActividad,FechaActividad

    ORDER BY P.NombreProceso ASC
	
END
GO


