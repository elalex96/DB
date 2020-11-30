CREATE PROCEDURE [dbo].[sp_CO_ReporteIntegracionGastosNivelActividadRenglon]
-- Add the parameters for the stored procedure here
@Anio          INT = 0,
@Mes           INT = 0,
@IdPresupuesto INT = 0
AS
--exec sp_CO_ReporteIntegracionGastosNivelActividadRenglon 2016,7,10000
    -- =============================================
    -- Author:		Miguel
    -- Create date: Domingo 1 Diciembre 2016 12:59 p.m.
    -- Description:	Reporte de Integración de Gastos a Nivel Actividad
    -- =============================================
         BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
             SET NOCOUNT ON;
             CREATE TABLE #Reporte
(Servicio              INT,
 Actividad             INT,
 Programa              MONEY,
 Gastos                MONEY,
 Acumulado             MONEY,
 Saldo                 MONEY,
 DisplayServicio       NVARCHAR(500),
 DisplayActividad      NVARCHAR(500),
 NoServicio            INT,
 DesServicio           NVARCHAR(500),
 GastoHastaMesAnterior MONEY,
 Presupuesto           MONEY,
 orden                 INT
);
             CREATE TABLE #Gastos
(Servicio   INT,
 Actividad  INT,
 Gastos     MONEY,
 NoServicio INT
);
             CREATE TABLE #Acumulado
(Servicio   INT,
 Actividad  INT,
 Gastos     MONEY,
 NoServicio INT
);
             CREATE TABLE #AcumuladoHastaMesAnterior
(Servicio   INT,
 Actividad  INT,
 Gastos     MONEY,
 NoServicio INT
);
             CREATE TABLE #Presupuesto
(Servicio   INT,
 Actividad  INT,
 Gastos     MONEY,
 NoServicio INT
);
             DECLARE @TipoCambioMesMXN FLOAT;
		   
/**/

             INSERT INTO #Reporte
                    SELECT CO_LineaPresupuestoMes.IdTipoServicio AS Servicio,
                           CO_LineaPresupuestoMes.IdActividad AS Actividad,
                           SUM(ISNULL(CO_LineaPresupuestoMes.Monto, 0)),
                           0,
                           0,
                           0,
                           '',
                           '',
                           CO_LineaPresupuestoMes.IdServicio AS NoServicio,
                           '',
                           0,
                           0,
                           0
                    FROM CO_Servicio
                         JOIN CO_LineaPresupuestoMes ON CO_Servicio.IdServicio = CO_LineaPresupuestoMes.IdServicio
                    WHERE CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto --and year(CO_LineaPresupuestoMes.AC_FEC_FIN)= @Anio  
                    GROUP BY CO_LineaPresupuestoMes.IdServicio,
                             CO_LineaPresupuestoMes.IdActividad,
                             CO_LineaPresupuestoMes.IdTipoServicio;
					    
/**/

             INSERT INTO #Presupuesto
                    SELECT L.IdTipoServicio,
                           L.IdActividad,
                           ISNULL(L.Monto, 0) AS Gastos,
                           S.IdServicio AS NoServicio
                    FROM CO_LineaPresupuestoMes L
                         JOIN CO_ActividadCIEP A ON A.IdActividad = L.IDActividad
                         JOIN CO_TipoServicio TS ON TS.IdTipoServicio = L.IdTipoServicio
                         JOIN CO_Servicio S ON S.IdServicio = L.IdServicio
                    WHERE L.IdPresupuesto = @IdPresupuesto
                          AND MONTH(L.[AC_PRESUP_MES]) = @Mes
                          AND YEAR(L.[AC_PRESUP_MES]) = @Anio
                          AND S.IdServicio = L.IdServicio;
					 
/**/

             INSERT INTO #Gastos
                    SELECT CO_LineaPresupuestoMes.IdTipoServicio AS Servicio,
                           CO_LineaPresupuestoMes.IdActividad AS Actividad,
                           SUM(CASE
                                   WHEN CO_Registro.CvTipoDocFacturacion = 1
                                        AND ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                                   THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                                   WHEN CO_Registro.CvTipoDocFacturacion IN(2, 3)
                           AND ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                                   THEN ISNULL(CO_Registro.MontoRegistro, 0) / TCDPC.TipoCambio
                                   ELSE 0
                               END) AS Gastos,
                           CO_LineaPresupuestoMes.IdServicio AS NoServicio
                    FROM CO_LineaPresupuestoMes
                         LEFT JOIN CO_Registro ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                         LEFT JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                         LEFT JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura
                         LEFT JOIN CO_TipoCambioMensual ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda
                                                           AND CO_TipoCambioMensual.IdMes = MONTH(dbo.FI_Factura.Fecha)
                                                           AND CO_TipoCambioMensual.Anio = YEAR(dbo.FI_Factura.Fecha)
                         LEFT OUTER JOIN dbo.FI_PedimentoComprobante AS PC ON PC.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
                         LEFT OUTER JOIN dbo.CO_TipoCambioMensual AS TCDPC ON TCDPC.IdMoneda = PC.IdMoneda
                                                                              AND TCDPC.Anio = YEAR(PC.FechaPago)
                                                                              AND TCDPC.IdMes = MONTH(PC.FechaPago)
                    WHERE(MONTH(CO_Registro.MesPresentacion) = @Mes
                          AND (YEAR(CO_Registro.MesPresentacion) = @Anio)
                          --AND CO_Registro.IdEstado = 10004
                          AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto)
                    GROUP BY CO_LineaPresupuestoMes.IdTipoServicio,
                             CO_LineaPresupuestoMes.IdActividad,
                             CO_LineaPresupuestoMes.IdServicio;

/*				 
/**/

             INSERT INTO #Acumulado
                    SELECT CO_LineaPresupuestoMes.IdTipoServicio AS Servicio,
                           CO_LineaPresupuestoMes.IdActividad AS Actividad,
                           SUM(CASE
                                   WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                                   THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                                   ELSE 0
                               END) AS Gastos,
                           CO_LineaPresupuestoMes.IdServicio AS NoServicio
                    FROM CO_LineaPresupuestoMes
                         LEFT JOIN CO_Registro ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                         LEFT JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                         LEFT JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura
                         LEFT JOIN CO_TipoCambioMensual ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda
                                                           AND CO_TipoCambioMensual.IdMes = MONTH(CO_Registro.MesPresentacion)
                                                           AND CO_TipoCambioMensual.Anio = YEAR(CO_Registro.MesPresentacion)
                    WHERE(MONTH(CO_Registro.MesPresentacion) <= @Mes
                          AND (YEAR(CO_Registro.MesPresentacion) = @Anio)
                          OR (YEAR(CO_Registro.MesPresentacion) < @Anio))
                         AND CO_Registro.IdEstado = 10004
                         AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
                    GROUP BY CO_LineaPresupuestoMes.IdTipoServicio,
                             CO_LineaPresupuestoMes.IdActividad,
                             CO_LineaPresupuestoMes.IdServicio;
					    
/**/

             INSERT INTO #AcumuladoHastaMesAnterior
                    SELECT CO_LineaPresupuestoMes.IdTipoServicio,
                           CO_LineaPresupuestoMes.IdActividad,
                           SUM(CASE
                                   WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                                   THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                                   ELSE 0
                               END) AS Gastos,
                           CO_LineaPresupuestoMes.IdServicio AS NoServicio
                    FROM CO_LineaPresupuestoMes
                         LEFT JOIN CO_Registro ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                         LEFT JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                         LEFT JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura
                         LEFT JOIN CO_TipoCambioMensual ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda
                                                           AND CO_TipoCambioMensual.IdMes = MONTH(CO_Registro.MesPresentacion)
                                                           AND CO_TipoCambioMensual.Anio = YEAR(CO_Registro.MesPresentacion)
                    WHERE(MONTH(CO_Registro.MesPresentacion) <= @Mes - 1
                          AND (YEAR(CO_Registro.MesPresentacion) = @Anio)
                          OR (YEAR(CO_Registro.MesPresentacion) < @Anio))
                         AND CO_Registro.IdEstado = 10004
                         AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
                    GROUP BY CO_LineaPresupuestoMes.IdTipoServicio,
                             CO_LineaPresupuestoMes.IdActividad,
                             CO_LineaPresupuestoMes.IdServicio;
					    
/**/
*/

             UPDATE #Reporte
               SET
                   Gastos = #Gastos.Gastos
             FROM #Gastos
             WHERE #Reporte.Actividad = #Gastos.Actividad
                   AND #Reporte.Servicio = #Gastos.Servicio
                   AND #Reporte.NoServicio = #Gastos.NoServicio;
             --
             UPDATE #Reporte
               SET
                   Presupuesto = #Presupuesto.Gastos
             FROM #Presupuesto
             WHERE #Reporte.Actividad = #Presupuesto.Actividad
                   AND #Reporte.Servicio = #Presupuesto.Servicio
                   AND #Reporte.NoServicio = #Presupuesto.NoServicio;
             --
/*UPDATE #Reporte
               SET
                   Acumulado = #Acumulado.Gastos
             FROM #Acumulado
             WHERE #Reporte.Actividad = #Acumulado.Actividad
                   AND #Reporte.Servicio = #Acumulado.Servicio
                   AND #Reporte.NoServicio = #Acumulado.NoServicio;
             --
             UPDATE #Reporte
               SET
                   GastoHastaMesAnterior = #AcumuladoHastaMesAnterior.Gastos
             FROM #AcumuladoHastaMesAnterior
             WHERE #Reporte.Actividad = #AcumuladoHastaMesAnterior.Actividad
                   AND #Reporte.Servicio = #AcumuladoHastaMesAnterior.Servicio
                   AND #Reporte.NoServicio = #AcumuladoHastaMesAnterior.NoServicio;*/

--
             UPDATE #Reporte
               SET
                   DisplayServicio = NombreTipoServicio
             FROM CO_TipoServicio
             WHERE CO_TipoServicio.IdTipoServicio = Servicio;
             --
             UPDATE #Reporte
               SET
                   DisplayActividad = CO_ActividadCIEP.NombreActividad
             FROM CO_ActividadCIEP
             WHERE CO_ActividadCIEP.IdActividad = Actividad;
             --
             UPDATE #Reporte
               SET
                   DesServicio = CO_Servicio.NombreServicio
             FROM CO_Servicio
             WHERE CO_Servicio.IdServicio = NoServicio;
		   --
             UPDATE #Reporte
               SET
                   orden = CO_ServicioActividad.Orden
             FROM CO_ServicioActividad
             WHERE CO_ServicioActividad.IdTipoServicio = #Reporte.Servicio
                   AND CO_ServicioActividad.IdActividad = #Reporte.Actividad;
			    --UPDATE #Reporte SET orden = ROW_NUMBER()OVER(ORDER BY orden)
		   --
             --update #Reporte set orden = ServicioActividad.Orden from ServicioActividad 
		   --where ServicioActividad.TipoServicio = #Reporte.Servicio and  ServicioActividad.Actividad = #Reporte.Actividad
             --
             UPDATE #Reporte
               SET
                   Saldo = 0;--Programa - Acumulado;
/**/

             DELETE FROM dbo.TempReporteIntegracionGastosNivelActividadRenglon;
		   
/**/

             INSERT INTO dbo.TempReporteIntegracionGastosNivelActividadRenglon
([DisplayServicio],
 [DisplayActividad],
 [Servicio],
 [Actividad],
 [Programa],
 [Gastos],
 [Acumulado],
 [Saldo],
 [NoServicio],
 [DesServicio],
 [Fecha],
 [GastoHastaMesAnterior],
 [Presupuesto],
 [orden]
)
                    SELECT DisplayServicio,
                           DisplayActividad,
                           Servicio,
                           Actividad,
                           Programa,
                           Gastos,
                           Acumulado,
                           Saldo,
                           NoServicio,
                           DesServicio,
                           DATEFROMPARTS(@Anio, @Mes, 1),
                           GastoHastaMesAnterior,
                           Presupuesto,
                           TS.orden
                    FROM #Reporte R
                         JOIN dbo.CO_TipoServicio TS ON R.Servicio = TS.ID_TIPOSER
                    ORDER BY TS.Orden,
                             DisplayServicio,
                             DisplayActividad,
                             DesServicio;
					    
					    
/**/

             SELECT Servicio,
                    Actividad,
                    NoServicio,
                    DisplayServicio,
                    DisplayActividad,
                    DesServicio,
                    Programa,
                    GastoHastaMesAnterior,
                    Presupuesto,
                    Gastos,
                    Acumulado,
                    Saldo,
                    Fecha,
                    orden,
                    GNAR.IdReporteGastosNivelActividadRenglon
             FROM TempReporteIntegracionGastosNivelActividadRenglon GNAR;
                  --JOIN dbo.CO_TipoServicio TS ON GNAR.Servicio = TS.ID_TIPOSER
             --ORDER BY TS.Orden;

         END;

	    --[sp_CO_ReporteIntegracionGastosNivelActividadRenglon] 2015,6,10000