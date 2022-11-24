CREATE PROCEDURE [dbo].[spReporteGastosNivelActividad] 
-- Add the parameters for the stored procedure here
@IdPresupuesto INT,
@MesGE         INT = 0,
@Anio          INT = 0
AS
     BEGIN
         -- =============================================
         -- Author:		Miguel
         -- Create date: Domingo 1 Diciembre 2017 12:59 p.m.
         -- Description:	Reporte de Integración de Gastos a Nivel Actividad
         -- =============================================
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         CREATE TABLE #Reporte
         (Servicio         INT,
          Actividad        INT,
          Programa         MONEY,
          Gastos           MONEY,
          Acumulado        MONEY,
          Saldo            MONEY,
          DisplayServicio  NVARCHAR(50),
          DisplayActividad NVARCHAR(50),
          orden            INT
         );
         CREATE TABLE #Programa
         (Servicio  INT,
          Actividad INT,
          Gastos    MONEY
         );
         CREATE TABLE #Gastos
         (Servicio  INT,
          Actividad INT,
          Gastos    MONEY
         );
         CREATE TABLE #Acumulado
         (Servicio  INT,
          Actividad INT,
          Gastos    MONEY
         );
         INSERT INTO [#Reporte]
                SELECT CO_ServicioActividad.IdTipoServicio,
                       CO_ServicioActividad.IdActividad,
                       0 AS Expr1,
                       0 AS Expr2,
                       0 AS Expr3,
                       0 AS Expr4,
                       '' AS Expr5,
                       '' AS Expr6,
                       0 AS Expr7
                FROM CO_ServicioActividad;
         INSERT INTO #Programa
                SELECT CO_LineaPresupuestoMes.IdTipoServicio,
                       CO_LineaPresupuestoMes.IdActividad,
                       SUM(ISNULL(CO_LineaPresupuestoMes.Monto, 0))
                FROM CO_LineaPresupuestoMes
                WHERE CO_LineaPresupuestoMes.IdPresupuesto = 7 --@IdPresupuesto --and year(CO_LineaPresupuestoMes.AC_FEC_FIN)= @Anio 
                GROUP BY CO_LineaPresupuestoMes.IdTipoServicio,
                         CO_LineaPresupuestoMes.IdActividad; 

         --------INSERT INTO [#Reporte]
         --------SELECT        CO_ServicioActividad.IdTipoServicio , CO_ServicioActividad.IdActividad , SUM(ISNULL(CO_LineaPresupuestoMes.Monto  , 0)) AS Expr1, 0 AS Expr2, 0 AS Expr3, 0 AS Expr4, '' AS Expr5, 
         --------                         '' AS Expr6, 0 AS Expr7
         --------FROM            CO_ServicioActividad 
         --------LEFT JOIN CO_LineaPresupuestoMes ON CO_LineaPresupuestoMes.IdActividad = CO_ServicioActividad.IdActividad and CO_LineaPresupuestoMes.IdTipoServicio = CO_ServicioActividad.IdTipoServicio     
         --------WHERE CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto and year(CO_LineaPresupuestoMes.AC_FEC_FIN)= @Anio 
         --------GROUP BY CO_ServicioActividad.IdTipoServicio , CO_ServicioActividad.IdActividad 
         -- Insert statements for procedure here
         --insert into #Gastos 	select    Servicio.TipoServicio, Servicio.Actividad,      sum(  CASE WHEN TipoDeCambio  =1 THEN  ISNULL(Registro.Monto,0)  WHEN TipoDeCambio =186  and ISNULL(Registro.Monto,0)>0  THEN   ISNULL(Registro.Monto,0)/ dsrf_TipoCambioMes.Valor  else 0 END  ) as Gastos
         INSERT INTO #Gastos
                SELECT CO_LineaPresupuestoMes.IdTipoServicio,
                       CO_LineaPresupuestoMes.IdActividad,
                       SUM(CASE
                               WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                               THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                               ELSE 0
                           END) AS Gastos
                FROM CO_LineaPresupuestoMes
                     INNER JOIN CO_Registro ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaProgramaActividadMes
                     INNER JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                     INNER JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura
                     INNER JOIN CO_TipoCambioMensual ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda
                                                        AND CO_TipoCambioMensual.IdMes = MONTH(CO_Registro.MesPresentacion)
                                                        AND CO_TipoCambioMensual.Anio = YEAR(CO_Registro.MesPresentacion)
                WHERE(MONTH(CO_Registro.MesPresentacion) = @MesGE
                      AND (YEAR(CO_Registro.MesPresentacion) = @Anio))
                     AND CO_Registro.IdEstado = 1
                     AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
                GROUP BY CO_LineaPresupuestoMes.IdTipoServicio,
                         CO_LineaPresupuestoMes.IdActividad;
         INSERT INTO #Acumulado
                SELECT CO_LineaPresupuestoMes.IdTipoServicio,
                       CO_LineaPresupuestoMes.IdActividad,
                       SUM(CASE
                               WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                               THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                               ELSE 0
                           END) AS Gastos
                FROM CO_LineaPresupuestoMes
                     INNER JOIN CO_Registro ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaProgramaActividadMes
                     INNER JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                     INNER JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura
                     INNER JOIN CO_TipoCambioMensual ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda
                                                        AND CO_TipoCambioMensual.IdMes = MONTH(CO_Registro.MesPresentacion)
                                                        AND CO_TipoCambioMensual.Anio = YEAR(CO_Registro.MesPresentacion)
                WHERE((MONTH(CO_Registro.MesPresentacion) <= @MesGE
                       AND (YEAR(CO_Registro.MesPresentacion) = @Anio))
                      AND CO_Registro.IdEstado = 1
                      AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto)
                     OR (((YEAR(CO_Registro.MesPresentacion) < @Anio))
                         AND CO_Registro.IdEstado = 1
                         AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto)
                GROUP BY CO_LineaPresupuestoMes.IdTipoServicio,
                         CO_LineaPresupuestoMes.IdActividad;
         UPDATE #Reporte
           SET
               Programa = #Programa.Gastos
         FROM #Programa
         WHERE #Reporte.Actividad = #Programa.Actividad
               AND #Reporte.Servicio = #Programa.Servicio;
         UPDATE #Reporte
           SET
               Gastos = #Gastos.Gastos
         FROM #Gastos
         WHERE #Reporte.Actividad = #Gastos.Actividad
               AND #Reporte.Servicio = #Gastos.Servicio;
         UPDATE #Reporte
           SET
               Acumulado = #Acumulado.Gastos
         FROM #Acumulado
         WHERE #Reporte.Actividad = #Acumulado.Actividad
               AND #Reporte.Servicio = #Acumulado.Servicio;
         UPDATE #Reporte
           SET
               DisplayServicio = CO_TipoServicio.NombreTipoServicio
         FROM CO_TipoServicio
         WHERE CO_TipoServicio.IdTipoServicio = Servicio;
         UPDATE #Reporte
           SET
               DisplayActividad = CO_ActividadCIEP.NombreActividad
         FROM CO_ActividadCIEP
         WHERE CO_ActividadCIEP.IdActividad = Actividad;
         UPDATE #Reporte
           SET
               orden = CO_ServicioActividad.Orden
         FROM CO_ServicioActividad
         WHERE CO_ServicioActividad.IdTipoServicio = #Reporte.Servicio
               AND CO_ServicioActividad.IdActividad = #Reporte.Actividad;
         UPDATE #Reporte
           SET
               Saldo = Programa - Acumulado;

         --delete from #reporte where programa = 0
         --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
         --Para reportes
         --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
         --update #Reporte set Gastos  = #Programa .Gastos   from #Programa  where #Reporte.Actividad   = #Programa.Actividad and #Reporte.Servicio = #Programa.Servicio  

         SELECT DisplayServicio,
                DisplayActividad,
                Servicio,
                Actividad,
                Programa,
                Gastos,
                Acumulado,
                Saldo,
                orden
         FROM #Reporte
         ORDER BY orden;
     END;