-- =============================================
-- Author:		Miguel
-- Create date: 10 Abril 2017
-- Description:	Obtiene el layout de informe de avance de acuerdo a la actividad y el mes
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ReporteLayoutReporteGastosElegiblesPorActividadMes] 
-- Add the parameters for the stored procedure here
@Actividad     INT = 0,
@Mes           INT,
@Anio          INT,
@IdPresupuesto INT = 0
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT A.ID_CATACTIV,
                SA.ID_CATSUBACTIV,
                YEAR(LP.AC_FEC_FIN) AS PR_ANO,
                P.version AS PR_VERSION,
                @Mes AS AC_MES,
                I.IdInstalacionPemex AS ID_ADMINISTRACION,
                CONCAT('DS-', RIGHT('00'+CAST(MONTH(R.mespresentacion) AS VARCHAR(2)), 2), YEAR(R.mespresentacion) - 2000, '-', A.ID_CATACTIV, '-', ROW_NUMBER() OVER(ORDER BY A.ID_CATACTIV,
                                                                                                                                                                               SA.ID_CATSUBACTIV)) AS GE_NO_COMPROBANTE,
                SUM(CASE
                        WHEN ISNULL(R.MontoRegistro, 0) <> 0
                        THEN ISNULL(R.MontoRegistro, 0) / TCM.TipoCambio
                        ELSE 0
                    END) AS GE_MONTO,
                CONCAT('DS-', RIGHT('00'+CAST(MONTH(R.mespresentacion) AS VARCHAR(2)), 2), YEAR(R.mespresentacion) - 2000, '-', A.ID_CATACTIV, '-', ROW_NUMBER() OVER(ORDER BY A.ID_CATACTIV,
                                                                                                                                                                               SA.ID_CATSUBACTIV), '.PDF') AS GE_REF_DOCUMENTO,
                'DS Servicios Petroleros' AS GE_PROVEEDOR,
                SA.NombreSubactividad AS AC_DESCRIPCION,
                MONTH(R.mespresentacion) AS GE_MES
         FROM CO_LineaPresupuestoMes LP
              LEFT JOIN CO_Servicio S ON LP.IdServicio = S.IdServicio
              LEFT JOIN CO_ActividadCIEP A ON LP.IdActividad = A.IdActividad
              LEFT JOIN CO_Instalacion I ON LP.IdInstalacion = I.IdInstalacion
              LEFT JOIN CO_Registro R ON LP.IdLineaPresupuestoMes = R.IdPrograma
              LEFT JOIN CO_SubactividadCIEP SA ON LP.IdSubactividad = SA.IdSubactividad
              LEFT JOIN FI_Factura F ON R.IdFactura = F.IdFactura
              LEFT JOIN CO_Presupuesto P ON LP.idpresupuesto = P.idpresupuesto
              LEFT JOIN CO_TipoCambioMensual TCM ON TCM.IdMoneda = F.IdMoneda
                                                    AND TCM.IdMes = MONTH(R.MesPresentacion)
                                                    AND TCM.Anio = YEAR(R.MesPresentacion)
         WHERE A.ID_CATACTIV = @Actividad
               AND MONTH(R.mespresentacion) = @Mes
               AND YEAR(R.mespresentacion) = @anio
               AND IdEstado = 1
               AND LP.IdPresupuesto = @IdPresupuesto
         GROUP BY A.ID_CATACTIV,
                  SA.ID_CATSUBACTIV,
                  I.IdInstalacionPemex,
                  YEAR(LP.AC_FEC_FIN),
                  P.version,
                  MONTH(LP.AC_FEC_FIN),
                  CONCAT('DS-', RIGHT('00'+CAST(MONTH(R.mespresentacion) AS VARCHAR(2)), 2), YEAR(R.mespresentacion) - 2000, '-', A.ID_CATACTIV, '-'),
                  MONTH(R.mespresentacion),
                  R.mespresentacion,
                  SA.NombreSubactividad
         ORDER BY A.ID_CATACTIV,
                  SA.ID_CATSUBACTIV,
                  I.IdInstalacionPemex;
     END;