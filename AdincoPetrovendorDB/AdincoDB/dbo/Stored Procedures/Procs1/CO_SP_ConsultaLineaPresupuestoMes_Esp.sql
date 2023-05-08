CREATE  PROCEDURE [dbo].[CO_SP_ConsultaLineaPresupuestoMes_Esp] 
	@presupuesto INT
AS
     BEGIN
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 10 Noviembre 2014
-- Description:	Presupuestos
-- =============================================
         SET NOCOUNT ON;
         SET LANGUAGE spanish; 

				SELECT dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
                --CONCAT(RIGHT('00'+CAST(MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', DATENAME(month, dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES), ' ', YEAR(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES)) AS Mes_Presupuestado,

                CO_ActividadPetroleraCNH.id_Actividad AS ID_TIPOSER,
                CO_ActividadPetroleraCNH.DescripcionActividadPetrolera AS DescripcionActividadPetrolera,
                CO_SubactividadPetrolera.[id_Sub-actividad] AS ID_CATACTIV,
                CO_SubactividadPetrolera.SubactividadPetrolera AS Actividad,
                CO_TareaPetrolera.id_Tarea AS ID_CATSUBACTIV,
                CO_TareaPetrolera.TareaPetrolera AS TareaPetrolera,
                CO_Servicio.NombreServicio AS Servicio,
				dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES AS Mes_Presupuestado,
                CO_Instalacion.NombreInstalacion AS Instalacion,
				CO_LineaPresupuestoMes.Monto
         FROM dbo.CO_LineaPresupuestoMes
              LEFT OUTER JOIN CO_ActividadPetroleraCNH ON dbo.CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
              LEFT OUTER JOIN CO_SubactividadPetrolera ON dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
              LEFT OUTER JOIN CO_TareaPetrolera ON dbo.CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
              LEFT OUTER JOIN CO_Servicio ON dbo.CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
              LEFT OUTER JOIN CO_Instalacion ON dbo.CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
         WHERE(dbo.CO_LineaPresupuestoMes.IdPresupuesto = @presupuesto) --and MONTH ( CO_LineaPresupuestoMes.AC_FEC_INI ) = @mes 
		 --and CO_TareaPetrolera.id_Tarea = 'TA-113'
		 --and CO_Servicio.NombreServicio like '%costo%'
         GROUP BY dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
                  dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES,
                  dbo.CO_LineaPresupuestoMes.ID_PADRE,
                  CO_Servicio.NombreServicio,
                  CO_Instalacion.NombreInstalacion,
                  dbo.CO_LineaPresupuestoMes.Monto,
                  CO_ActividadPetroleraCNH.id_Actividad,
                  CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
                  CO_SubactividadPetrolera.[id_Sub-actividad],
                  CO_SubactividadPetrolera.SubactividadPetrolera,
                  CO_TareaPetrolera.id_Tarea,
                  CO_TareaPetrolera.TareaPetrolera
         ORDER BY
				  CO_TareaPetrolera.id_Tarea
/*
	SELECT 
                CO_ActividadPetroleraCNH.id_Actividad AS ID_TIPOSER,
                CO_ActividadPetroleraCNH.DescripcionActividadPetrolera AS DescripcionActividadPetrolera,
                CO_SubactividadPetrolera.[id_Sub-actividad] AS ID_CATACTIV,
                CO_SubactividadPetrolera.SubactividadPetrolera AS Actividad,
                CO_TareaPetrolera.id_Tarea AS ID_CATSUBACTIV,
                CO_TareaPetrolera.TareaPetrolera AS TareaPetrolera,
                CO_Servicio.NombreServicio AS Servicio,
                CO_Instalacion.NombreInstalacion AS Instalacion,
				SUM(CO_LineaPresupuestoMes.Monto) AS Monto
         FROM dbo.CO_LineaPresupuestoMes
              LEFT OUTER JOIN CO_ActividadPetroleraCNH ON dbo.CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
              LEFT OUTER JOIN CO_SubactividadPetrolera ON dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
              LEFT OUTER JOIN CO_TareaPetrolera ON dbo.CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
              LEFT OUTER JOIN CO_Servicio ON dbo.CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
              LEFT OUTER JOIN CO_Instalacion ON dbo.CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
         WHERE(dbo.CO_LineaPresupuestoMes.IdPresupuesto = @presupuesto) --and MONTH ( CO_LineaPresupuestoMes.AC_FEC_INI ) = @mes 
         GROUP BY
                  dbo.CO_LineaPresupuestoMes.ID_PADRE,
                  CO_Servicio.NombreServicio,
                  CO_Instalacion.NombreInstalacion,
                  CO_ActividadPetroleraCNH.id_Actividad,
                  CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
                  CO_SubactividadPetrolera.[id_Sub-actividad],
                  CO_SubactividadPetrolera.SubactividadPetrolera,
                  CO_TareaPetrolera.id_Tarea,
                  CO_TareaPetrolera.TareaPetrolera
         ORDER BY
				  CO_TareaPetrolera.id_Tarea
*/
	SELECT 
                CO_ActividadPetroleraCNH.id_Actividad AS ID_TIPOSER,
                CO_ActividadPetroleraCNH.DescripcionActividadPetrolera AS DescripcionActividadPetrolera,
                CO_SubactividadPetrolera.[id_Sub-actividad] AS ID_CATACTIV,
                CO_SubactividadPetrolera.SubactividadPetrolera AS Actividad,
                CO_TareaPetrolera.id_Tarea AS ID_CATSUBACTIV,
                CO_TareaPetrolera.TareaPetrolera AS TareaPetrolera,
                CO_Servicio.NombreServicio AS Servicio,
				SUM(CO_LineaPresupuestoMes.Monto) AS Monto
         FROM dbo.CO_LineaPresupuestoMes
              LEFT OUTER JOIN CO_ActividadPetroleraCNH ON dbo.CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
              LEFT OUTER JOIN CO_SubactividadPetrolera ON dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
              LEFT OUTER JOIN CO_TareaPetrolera ON dbo.CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
              LEFT OUTER JOIN CO_Servicio ON dbo.CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
              LEFT OUTER JOIN CO_Instalacion ON dbo.CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
         WHERE(dbo.CO_LineaPresupuestoMes.IdPresupuesto = @presupuesto) --and MONTH ( CO_LineaPresupuestoMes.AC_FEC_INI ) = @mes 
         GROUP BY
                  dbo.CO_LineaPresupuestoMes.ID_PADRE,
                  CO_Servicio.NombreServicio,
                  CO_ActividadPetroleraCNH.id_Actividad,
                  CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
                  CO_SubactividadPetrolera.[id_Sub-actividad],
                  CO_SubactividadPetrolera.SubactividadPetrolera,
                  CO_TareaPetrolera.id_Tarea,
                  CO_TareaPetrolera.TareaPetrolera
         ORDER BY
				  CO_TareaPetrolera.id_Tarea

     END

