CREATE PROCEDURE [dbo].[spReporteIntegracionGastosPorBolsas]
-- Add the parameters for the stored procedure here
@Anio          INT = 0,
@Mes           INT = 0,
@IdPresupuesto INT = 0
AS
     BEGIN
         -- =============================================
         -- Author:		Miguel
         -- Create date: Domingo 1 Diciembre 2016 12:59 p.m.
         -- Description:	Reporte de Integración de Gastos a Nivel Actividad
         -- =============================================
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         SELECT TP.NombreTipoServicio AS Servicio,
                A.NombreActividad AS Actividad,
                I.NombreInstalacion AS Bolsa,
                IR.NombreInstalacion AS Instalacion,
                SUM(CASE
                        WHEN ISNULL(R.MontoRegistro, 0) <> 0
                        THEN ISNULL(R.MontoRegistro, 0) / TCM.TipoCambio
                        ELSE 0
                    END) AS Importe,
                IR.NombreInstalacion AS InstalacionPresupuesto
         FROM CO_LineaPresupuestoMes LP
              INNER JOIN CO_Registro R ON LP.IdLineaPresupuestoMes = R.IdPrograma
              INNER JOIN CO_Servicio S ON LP.IdServicio = S.IdServicio
              JOIN CO_Instalacion I ON LP.IdInstalacion = I.IdInstalacion
              JOIN CO_TipoServicio TP ON LP.IdTipoServicio = TP.IdTipoServicio
              JOIN CO_ActividadCIEP A ON LP.IdActividad = A.IdActividad
              JOIN CO_Instalacion IR ON R.IdInstalacion = IR.IdInstalacion
              JOIN FI_Factura F ON F.IdFactura = R.IdFactura
              JOIN CO_TipoCambioMensual TCM ON TCM.IdMoneda = F.IdMoneda
                                               AND TCM.IdMes = MONTH(R.MesPresentacion)
                                               AND TCM.Anio = YEAR(R.MesPresentacion)
         WHERE MONTH(R.MesPresentacion) = @Mes
               AND YEAR(R.MesPresentacion) = @Anio
               AND ISNULL(I.EsBolsa, 0) = 1
               AND R.IdEstado = 1
               AND LP.IdPresupuesto = @IdPresupuesto
         --and year(LP.AC_FEC_FIN)= @Anio  
         GROUP BY TP.NombreTipoServicio,
                  A.NombreActividad,
                  I.NombreInstalacion,
                  IR.NombreInstalacion,
                  IR.NombreInstalacion
         ORDER BY TP.NombreTipoServicio,
                  A.NombreActividad,
                  I.NombreInstalacion,
                  IR.NombreInstalacion;
     END;