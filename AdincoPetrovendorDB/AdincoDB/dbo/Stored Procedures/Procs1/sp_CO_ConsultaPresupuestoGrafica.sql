-- =============================================-- Author:		Miguel-- Create date: -- Description:	-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaPresupuestoGrafica] 
-- Add the parameters for the stored procedure here
@IdPresupuesto INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from-- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SET LANGUAGE spanish;
         SELECT CONCAT(RIGHT('00'+CAST(MONTH(CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', DATENAME(month, CO_LineaPresupuestoMes.AC_PRESUP_MES), ' ', YEAR(CO_LineaPresupuestoMes.AC_PRESUP_MES)) AS Mes_Presupuestado,
                SUM(CO_LineaPresupuestoMes.Monto) AS [Presupuesto (USD)],
                SUM(CASE
                        WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                        THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                        ELSE 0
                    END) AS [Registrado (USD)],
               SUM( CO_LineaPresupuestoMes.Monto) - SUM(CASE
                                                       WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                                                       THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                                                       ELSE 0
                                                   END) AS [Saldo (USD)],
                SUM(CASE
                        WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                        THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                        ELSE 0
                    END) / CO_LineaPresupuestoMes.Monto * 100 AS Porcentaje,
                SUM(CASE
                        WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                        THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                        ELSE 0
                    END) / CO_LineaPresupuestoMes.Monto * 100 AS Progreso100,
                CASE
                    WHEN((SUM(CASE
                                  WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                                  THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                                  ELSE 0
                              END) / monto) * 100) > 100
                    THEN((SUM(CASE
                                  WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                                  THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                                  ELSE 0
                              END) / monto) * 100) - 100
                    ELSE 0
                END AS ProgresoM100,
                CO_LineaPresupuestoMes.AC_PRESUP_MES
         FROM CO_LineaPresupuestoMes
              INNER JOIN CO_ActividadPetroleraCNH ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
              INNER JOIN CO_SubactividadPetrolera ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
              INNER JOIN CO_TareaPetrolera ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
              LEFT OUTER JOIN CO_ActividadCIEP ON CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
              LEFT OUTER JOIN CO_TipoServicio ON CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.ID_TIPOSER
              LEFT OUTER JOIN CO_SubactividadCIEP ON CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
              LEFT OUTER JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
              LEFT OUTER JOIN CO_Area ON CO_LineaPresupuestoMes.IdArea = CO_Area.IdArea
              LEFT OUTER JOIN CO_Instalacion ON CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
              LEFT OUTER JOIN CO_Registro ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
              LEFT OUTER JOIN CO_ClasificacionAnexo4 ON CO_LineaPresupuestoMes.IdAnexo4 = CO_ClasificacionAnexo4.IdAnexo4
              LEFT OUTER JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura
              LEFT OUTER JOIN CO_TipoCambioMensual ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda
                                                      AND CO_TipoCambioMensual.IdMes = MONTH(CO_Registro.MesPresentacion)
                                                      AND CO_TipoCambioMensual.Anio = YEAR(CO_Registro.MesPresentacion)
              LEFT OUTER JOIN CO_RubroInterno ON CO_LineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno
         WHERE(CO_LineaPresupuestoMes.IdPresupuesto = 2)
         GROUP BY CO_LineaPresupuestoMes.AC_PRESUP_MES,
                
                  CO_LineaPresupuestoMes.Monto ORDER BY Mes_Presupuestado,
                                                        CO_LineaPresupuestoMes.AC_PRESUP_MES
                                                      
     END;