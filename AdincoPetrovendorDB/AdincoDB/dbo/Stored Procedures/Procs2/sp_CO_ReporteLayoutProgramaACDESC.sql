-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ReporteLayoutProgramaACDESC] 
-- Add the parameters for the stored procedure here
@IdPresupuesto INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         -- Insert statements for procedure here

         SELECT AC.ID_CATACTIV AS [ID_CATACTIV],
                SA.ID_CATSUBACTIV AS [ID SUBACTIVIDAD],
                ID_TIPOSER AS [ID_TIPOSER],
                ROUND(SUM(LP.Monto), 2) AS [AC_PRESUP_MES],
                I.NombreInstalacion AS [AC_NOMBRE],
                SA.NombreSubactividad AS [AC_DESCRIPCION],
                CONCAT('01/', RIGHT('00'+CONVERT(NVARCHAR(2), MONTH(LP.AC_FEC_FIN)), 2), '/', YEAR(LP.AC_FEC_FIN)) AS [AC_FEC_INI],
                CONCAT(DATEPART(d, EOMONTH(CAST(CONCAT(YEAR(LP.AC_FEC_FIN), RIGHT('00'+CONVERT(NVARCHAR(2), MONTH(LP.AC_FEC_FIN)), 2), '01') AS DATE))), '/', RIGHT('00'+CONVERT(NVARCHAR(2), MONTH(LP.AC_FEC_FIN)), 2), '/', YEAR(LP.AC_FEC_FIN)) AS [AC_FEC_FIN],
                'N' AS [AC_TERMINADO],
                ISNULL(I.IdInstalacionPemex, 0) AS [ID_INSTALACION],
                1 AS [ID_CATACTHC]
         FROM CO_LineaPresupuestoMes LP
              LEFT JOIN CO_Servicio S ON LP.idServicio = S.IdServicio
              LEFT JOIN CO_SubactividadCIEP SA ON LP.IdSubactividad = SA.IdSubactividad
              LEFT JOIN CO_Instalacion I ON LP.IdInstalacion = I.IdInstalacion
              LEFT JOIN CO_ActividadCIEP AC ON LP.IdActividad = AC.IdActividad
              LEFT JOIN CO_TipoServicio TS ON TS.IdTipoServicio = LP.IdTipoServicio
         WHERE LP.IdPresupuesto = @IdPresupuesto
         GROUP BY AC.ID_CATACTIV,
                  SA.ID_CATSUBACTIV,
                  ID_TIPOSER,
                  I.NombreInstalacion,
                  SA.NombreSubactividad,
                  LP.AC_FEC_FIN,
                  LP.AC_FEC_FIN,
                  I.IdInstalacionPemex
         ORDER BY LP.AC_FEC_FIN;
     END;