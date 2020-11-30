-- =============================================
-- Author:		Miguel Gomez
-- Create date:
-- Description:	Reporte de actividades SCIEP
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ReporteLayoutActividades] 
	-- Add the parameters for the stored procedure here
@Actividad     INT = 0,
@Mes           INT = 0,
@Anio          INT = 0,
@IdPresupuesto INT = 0
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

         SELECT DISTINCT
                CO_LineaPresupuestoMes.IdActividad AS ID_CATACTIV,
                CO_SubactividadCIEP.ID_CATSUBACTIV AS ID_CATSUBACTIV,
                CO_LineaPresupuestoMes.IdTipoServicio AS ID_TIPOSER,
                SUM(CO_LineaPresupuestoMes.Monto) AS AC_PRESUP_MES,
                CO_Instalacion.NombreInstalacion AS AC_NOMBRE,
                CO_SubactividadCIEP.NombreSubactividad AS AC_DESCRIPCION,
                CO_LineaPresupuestoMes.AC_FEC_INI AS AC_FEC_INI,
                CO_LineaPresupuestoMes.AC_FEC_FIN AS AC_FEC_FIN,
                'N' AS AC_TERMINADO,
                CO_Instalacion.IdInstalacionPemex AS ID_ADMON,
                1 AS ID_CATACTHC,
                CO_LineaPresupuestoMes.ID_PADRE AS ID_ACTIVIDAD_P
         FROM CO_LineaPresupuestoMes
              JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
              JOIN CO_Instalacion ON CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
              JOIN CO_SubactividadCIEP ON CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
         WHERE MONTH(CO_LineaPresupuestoMes.MesActividadIni) = @Mes
               AND YEAR(CO_LineaPresupuestoMes.MesActividadIni) = @Anio
               AND CO_LineaPresupuestoMes.IdActividad = @Actividad
               AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
         GROUP BY CO_LineaPresupuestoMes.IdActividad,
                  CO_SubactividadCIEP.ID_CATSUBACTIV,
                  CO_LineaPresupuestoMes.IdTipoServicio,
                  CO_Instalacion.NombreInstalacion,
                  CO_SubactividadCIEP.NombreSubactividad,
                  CO_LineaPresupuestoMes.AC_FEC_INI,
                  CO_LineaPresupuestoMes.AC_FEC_FIN,
                  CO_Instalacion.IdInstalacionPemex,
                  CO_LineaPresupuestoMes.ID_PADRE;
     END;
