-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_SCIEPPrograma] 
	-- Add the parameters for the stored procedure here
@IdPresupuesto INT = 0
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
    -- Insert statements for procedure here

         SELECT CO_ActividadCIEP.ID_CATACTIV AS [ID_CATACTIV],
                CO_SubactividadCIEP.ID_CATSUBACTIV AS [ID Subatividad],
                ID_TIPOSER AS [ID_TIPOSER],
                ROUND(SUM(CO_LineaPresupuestoMes.Monto), 2) AS [AC_PRESUP_MES],
                CO_Instalacion.NombreInstalacion AS [AC_NOMBRE],
                'N' AS [AC_DESCRIPCION],
                CONCAT('01/', RIGHT('00'+CONVERT(NVARCHAR(2), MONTH(CO_LineaPresupuestoMes.AC_FEC_FIN)), 2), '/', YEAR(CO_LineaPresupuestoMes.AC_FEC_FIN)) AS [AC_FEC_INI],
                concat(DATEPART(d, EOMONTH(CAST(CONCAT(YEAR(CO_LineaPresupuestoMes.AC_FEC_FIN), RIGHT('00'+CONVERT(NVARCHAR(2), MONTH(CO_LineaPresupuestoMes.AC_FEC_FIN)), 2), '01') AS DATE))), '/', RIGHT('00'+CONVERT(NVARCHAR(2), MONTH(CO_LineaPresupuestoMes.AC_FEC_FIN)), 2), '/', YEAR(CO_LineaPresupuestoMes.AC_FEC_FIN)) AS [AC_FEC_FIN],
                'N' AS [AC_TERMINADO],
                ISNULL(CO_Instalacion.IdInstalacionPemex, 0) AS [ID_INSTALACION],
                1 AS [ID_CATACTHC]
         FROM CO_LineaPresupuestoMes
              LEFT JOIN CO_Servicio ON CO_LineaPresupuestoMes.idServicio = CO_Servicio.IdServicio
              LEFT JOIN CO_SubactividadCIEP ON CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
              LEFT JOIN CO_Instalacion ON CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
              LEFT JOIN CO_ActividadCIEP ON CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
              LEFT JOIN CO_TipoServicio ON CO_TipoServicio.IdTipoServicio = CO_LineaPresupuestoMes.IdTipoServicio
         WHERE CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
         GROUP BY CO_ActividadCIEP.ID_CATACTIV,
                  CO_SubactividadCIEP.ID_CATSUBACTIV,
                  ID_TIPOSER,
                  CO_Instalacion.NombreInstalacion,
                  CO_LineaPresupuestoMes.AC_FEC_FIN,
                  CO_LineaPresupuestoMes.AC_FEC_FIN,
                  CO_Instalacion.IdInstalacionPemex
         ORDER BY CO_LineaPresupuestoMes.AC_FEC_FIN;
     END;
