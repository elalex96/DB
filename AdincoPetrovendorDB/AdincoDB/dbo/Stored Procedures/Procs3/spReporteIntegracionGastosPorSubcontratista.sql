CREATE PROCEDURE [dbo].[spReporteIntegracionGastosPorSubcontratista] 
-- Add the parameters for the stored procedure here
@Anio          INT = 0,
@Mes           INT = 0,
@IdPresupuesto INT = 0
AS
     BEGIN
         -- =============================================
         -- Author:		Miguel
         -- Create date: Domingo 1 Diciembre 2016 19:49 p.m.
         -- Description:	Reporte de Integración de Gastos a Nivel Actividad
         -- =============================================

         SELECT RTRIM(P.RazonSocial) AS Prestadora_de_Servicios,
                RTRIM(TS.NombreTipoServicio) AS Servicio,
                RTRIM(A.NombreActividad) AS Actividad,
                LTRIM(MONTH(R.MesPresentacion))+'-'+LTRIM(YEAR((R.MesPresentacion))-2000) AS Periodo,
                SUM(CASE
                        WHEN ISNULL(R.MontoRegistro, 0) <> 0
                        THEN ISNULL(R.MontoRegistro, 0) / TCM.TipoCambio
                        ELSE 0
                    END) AS [Importe],
                CASE P.Relacionada
                    WHEN 1
                    THEN 'Relacionadas'
                    ELSE 'Prestadora de Servicios'
                END AS Segmento
         FROM CO_Registro R
              LEFT JOIN CO_LineaPresupuestoMes C ON R.IdPrograma = C.IdLineaPresupuestoMes
              LEFT JOIN CO_Servicio S ON C.IdServicio = S.IdServicio
              LEFT JOIN CO_TipoServicio TS ON C.IdTipoServicio = TS.IdTipoServicio
              LEFT JOIN FI_Factura F ON F.IdFactura = R.IdFactura
              LEFT JOIN PV_Subcontratista P ON F.IdSubcontratista = P.IdSubcontratista
              LEFT JOIN CO_ActividadCIEP A ON C.IdActividad = A.IdActividad
              LEFT JOIN CO_TipoCambioMensual TCM ON TCM.IdMoneda = f.IdMoneda
                                  AND TCM.IdMes = MONTH(R.MesPresentacion)
                                  AND TCM.Anio = YEAR(R.MesPresentacion)
         WHERE YEAR(R.MesPresentacion) = @Anio
               AND MONTH(R.MesPresentacion) = @Mes
               --AND R.IdEstado = 1
               AND C.IdPresupuesto = @IdPresupuesto
         GROUP BY RTRIM(P.RazonSocial),
                  RTRIM(TS.NombreTipoServicio),
                  RTRIM(A.NombreActividad),
                  LTRIM(MONTH(MesPresentacion))+'-'+LTRIM(YEAR((MesPresentacion))-2000),
                  P.Relacionada
         ORDER BY RTRIM(TS.NombreTipoServicio),
                  RTRIM(A.NombreActividad),
                  RTRIM(P.RazonSocial);
     END;