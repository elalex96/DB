-- [sp_CO_ReporteGastosNivelActividad] 10159,09,2020  
CREATE PROCEDURE [dbo].[sp_CO_ReporteGastosNivelActividad] --10159,09,2020  
@IdPresupuesto INT = 0,  
@MesGE         INT = 0,  
@Anio          INT = 0  
AS  
         BEGIN   
-- =============================================  
-- Author:        Miguel  
-- Create date: Domingo 1 Diciembre 2017 12:59 p.m.  
-- Description:    Reporte de Integración de Gastos a Nivel Actividad  
-- =============================================  
             SET NOCOUNT ON;  
             CREATE TABLE #Reporte  
(Servicio              INT,  
 Actividad             INT,  
 DisplayServicio       NVARCHAR(50),  
 DisplayActividad      NVARCHAR(50),  
 Programa              MONEY,  
 GastoHastaMesAnterior MONEY,  
 Presupuesto           MONEY,  
 Gastos                MONEY,  
 Acumulado             MONEY,  
 Saldo                 MONEY,  
 orden                 INT  
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
             CREATE TABLE #AcumuladoHastaMesAnterior  
(Servicio  INT,  
 Actividad INT,  
 Gastos    MONEY  
);  
             CREATE TABLE #Presupuesto  
(Servicio  INT,  
 Actividad INT,  
 Gastos    MONEY  
);  
DECLARE @MesActual datetime = DATEFROMPARTS(@Anio, @MesGE, 1);  
DECLARE @MesAnterior datetime = DATEADD(MONTH,-1,@MesActual);  
/**/  
             INSERT INTO #Reporte  
                    SELECT CO_ServicioActividad.IdTipoServicio,  
                           CO_ServicioActividad.IdActividad,  
                           '' AS Expr1,  
                           '' AS Expr2,  
                           0 AS Expr3,  
                           0 AS Expr4,  
                           0 AS Expr5,  
                           0 AS Expr6,  
                           0 AS Expr7,  
                           0 AS Expr8,  
                           0 AS Expr9  
                    FROM CO_ServicioActividad;  
/**/  
             INSERT INTO #Programa  
                    SELECT CO_LineaPresupuestoMes.IdTipoServicio,  
                           CO_LineaPresupuestoMes.IdActividad,  
                           SUM(ISNULL(CO_LineaPresupuestoMes.Monto, 0)) AS Gasto  
                    FROM CO_LineaPresupuestoMes  
                    WHERE CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto --and year(CO_LineaPresupuestoMes.AC_FEC_FIN)= @Anio   
                    GROUP BY CO_LineaPresupuestoMes.IdTipoServicio,  
                             CO_LineaPresupuestoMes.IdActividad;  
/**/  
             INSERT INTO #Presupuesto  
                    SELECT L.IdTipoServicio,  
                           L.IdActividad,  
                           SUM(ISNULL(L.Monto, 0)) AS Gasto  
                    FROM CO_LineaPresupuestoMes L  
                         JOIN CO_ActividadCIEP A ON A.IdActividad = L.IDActividad  
                         JOIN CO_TipoServicio S ON L.IdTipoServicio = S.IdTipoServicio  
                    WHERE L.IdPresupuesto = @IdPresupuesto  
                          AND MONTH(L.[AC_PRESUP_MES]) = @MesGE  
                          AND YEAR(L.[AC_PRESUP_MES]) = @Anio  
                    GROUP BY L.IdTipoServicio,  
                             L.IdActividad;   
    --------INSERT INTO [#Reporte]  
    --------SELECT CO_ServicioActividad.IdTipoServicio , CO_ServicioActividad.IdActividad ,   
    --------SUM(ISNULL(CO_LineaPresupuestoMes.Monto  , 0)) AS Expr1, 0 AS Expr2, 0 AS Expr3, 0 AS Expr4, '' AS Expr5,   
    --------'' AS Expr6, 0 AS Expr7  
    --------FROM CO_ServicioActividad   
    --------LEFT JOIN CO_LineaPresupuestoMes ON CO_LineaPresupuestoMes.IdActividad = CO_ServicioActividad.IdActividad   
    --------and CO_LineaPresupuestoMes.IdTipoServicio = CO_ServicioActividad.IdTipoServicio       
    --------WHERE CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto and year(CO_LineaPresupuestoMes.AC_FEC_FIN)= @Anio   
 --------GROUP BY CO_ServicioActividad.IdTipoServicio , CO_ServicioActividad.IdActividad   
    --------Insert statements for procedure here  
    --------insert into #Gastos     select    Servicio.TipoServicio, Servicio.Actividad,      sum(  CASE WHEN TipoDeCambio  =1 THEN  ISNULL(Registro.Monto,0)    
    --------WHEN TipoDeCambio =186  and ISNULL(Registro.Monto,0)>0  THEN   ISNULL(Registro.Monto,0)/ dsrf_TipoCambioMes.Valor  else 0 END  ) as Gastos  
/**/  
             INSERT INTO #Gastos  
                    SELECT CO_LineaPresupuestoMes.IdTipoServicio,  
                           CO_LineaPresupuestoMes.IdActividad,  
                           SUM(CASE  
                                    WHEN CO_Registro.CvTipoDocFacturacion = 1  
                                       AND ISNULL(ISNULL(CO_Registro.MontoRegistro,RM.MontoGasto), 0) <> 0  
                                   
										THEN ISNULL(ISNULL(CO_Registro.MontoRegistro,RM.MontoGasto), 0) / ISNULL (RM.TipoCambio, CO_TipoCambioMensual.TipoCambio) 
                                   WHEN CO_Registro.CvTipoDocFacturacion IN(2, 3)  
                           AND ISNULL(CO_Registro.MontoRegistro, 0) <> 0  
                                   --THEN ISNULL(CO_Registro.MontoRegistro, 0) / TCDPC.TipoCambio  
            THEN ISNULL(RM.MontoGasto+ rm.MontoEquivalente, 0) / ISNULL (RM.TipoCambio, TCDPC.TipoCambio)
                                   ELSE 0  
                               END) AS Gastos  
                    FROM CO_LineaPresupuestoMes  
                         LEFT JOIN CO_Registro ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes  
                         LEFT JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio  
                         LEFT JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura  
                         LEFT JOIN CO_TipoCambioMensual ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda  
                                                           AND CO_TipoCambioMensual.IdMes = MONTH(FI_Factura.Fecha)  
                                                           AND CO_TipoCambioMensual.Anio = YEAR(FI_Factura.Fecha)  
                         LEFT OUTER JOIN dbo.FI_PedimentoComprobante AS PC ON PC.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante  
                         LEFT OUTER JOIN dbo.CO_TipoCambioMensual AS TCDPC ON TCDPC.IdMoneda = PC.IdMoneda  
                                                                              AND TCDPC.Anio = YEAR(PC.FechaPago)  
                                                                              AND TCDPC.IdMes = MONTH(PC.FechaPago)  
                     LEFT JOIN CO_RegistroMarkup RM ON RM.GastoId= CO_Registro.IdRegistro  
                    WHERE(MONTH(CO_Registro.MesPresentacion) = @MesGE  
                          AND (YEAR(CO_Registro.MesPresentacion) = @Anio)) --  AND CO_Registro.IdEstado = 10002  
                         AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto  
                    GROUP BY CO_LineaPresupuestoMes.IdTipoServicio,  
                             CO_LineaPresupuestoMes.IdActividad;  
/**/  
-- INSERT INTO #Acumulado  
-- SELECT   
--     CO_LineaPresupuestoMes.IdTipoServicio,   
--     CO_LineaPresupuestoMes.IdActividad,   
--     SUM(  
--         CASE WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio ELSE 0 END  
--     ) AS Gastos   
-- FROM   
--     CO_LineaPresupuestoMes   
--     LEFT JOIN CO_Registro ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes   
--     LEFT JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio   
--     LEFT JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura   
--     LEFT JOIN CO_TipoCambioMensual ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda   
--     AND CO_TipoCambioMensual.IdMes = MONTH(CO_Registro.MesPresentacion)   
--     AND CO_TipoCambioMensual.Anio = YEAR(CO_Registro.MesPresentacion)   
-- WHERE   
--     (  
--         (  
--             MONTH(CO_Registro.MesPresentacion) <= @MesGE   
--             AND (  
--                 YEAR(CO_Registro.MesPresentacion) = @Anio  
--   )  
--         ) --AND CO_Registro.IdEstado = 10002  
--         AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto  
--     )   
--     OR (  
--         (  
--             (  
--                 YEAR(CO_Registro.MesPresentacion) < @Anio  
--             )  
--         ) --AND CO_Registro.IdEstado = 10002  
--         AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto  
--     )   
-- GROUP BY   
--     CO_LineaPresupuestoMes.IdTipoServicio,   
--     CO_LineaPresupuestoMes.IdActividad;  
/**/  
--INSERT INTO #AcumuladoHastaMesAnterior  
-- SELECT   
--     CO_LineaPresupuestoMes.IdTipoServicio,   
--     CO_LineaPresupuestoMes.IdActividad,   
--     SUM(  
--         CASE WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio ELSE 0 END  
--     ) AS Gastos   
-- FROM   
--     CO_LineaPresupuestoMes   
--     LEFT JOIN CO_Registro ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes   
--     LEFT JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio   
--     LEFT JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura   
--     LEFT JOIN CO_TipoCambioMensual ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda   
--     AND CO_TipoCambioMensual.IdMes = MONTH(CO_Registro.MesPresentacion)   
--     AND CO_TipoCambioMensual.Anio = YEAR(CO_Registro.MesPresentacion)   
-- WHERE   
--     (  
--         (  
--             MONTH(CO_Registro.MesPresentacion) <= @MesGE -1   
--             AND (  
--                 YEAR(CO_Registro.MesPresentacion) = @Anio  
--)  
--         ) --AND CO_Registro.IdEstado = 10002  
--         AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto  
--     )   
--     OR (  
--         (  
--             (  
--                 YEAR(CO_Registro.MesPresentacion) < @Anio  
--             )  
--         ) --AND CO_Registro.IdEstado = 10002  
--         AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto  
--     )   
-- GROUP BY   
--     CO_LineaPresupuestoMes.IdTipoServicio,   
--     CO_LineaPresupuestoMes.IdActividad;   
/**/  
 -- gasto aculumado mes anterior  
             INSERT INTO #AcumuladoHastaMesAnterior    
             SELECT CO_LineaPresupuestoMes.IdTipoServicio,  
                           CO_LineaPresupuestoMes.IdActividad,  
                           SUM(CASE  
                                    WHEN CO_Registro.CvTipoDocFacturacion = 1  
                                       AND ISNULL(ISNULL(CO_Registro.MontoRegistro,RM.MontoGasto), 0) <> 0  
                                   
										THEN ISNULL(ISNULL(CO_Registro.MontoRegistro,RM.MontoGasto), 0) / ISNULL (RM.TipoCambio, CO_TipoCambioMensual.TipoCambio) 
                                   WHEN CO_Registro.CvTipoDocFacturacion IN(2, 3)  
                           AND ISNULL(CO_Registro.MontoRegistro, 0) <> 0  
                                   THEN ISNULL(RM.MontoGasto+ rm.MontoEquivalente, 0) / ISNULL (RM.TipoCambio, TCDPC.TipoCambio)
                                   ELSE 0  
                               END) AS Gastos  
                    FROM CO_LineaPresupuestoMes  
                         LEFT JOIN CO_Registro ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes  
                         LEFT JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio  
                         LEFT JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura  
                         LEFT JOIN CO_TipoCambioMensual ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda  
                                                           AND CO_TipoCambioMensual.IdMes = MONTH(FI_Factura.Fecha)  
                                                           AND CO_TipoCambioMensual.Anio = YEAR(FI_Factura.Fecha)  
                         LEFT OUTER JOIN dbo.FI_PedimentoComprobante AS PC ON PC.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante  
                         LEFT OUTER JOIN dbo.CO_TipoCambioMensual AS TCDPC ON TCDPC.IdMoneda = PC.IdMoneda  
                                                                              AND TCDPC.Anio = YEAR(PC.FechaPago)  
                                                                              AND TCDPC.IdMes = MONTH(PC.FechaPago)  
                      LEFT JOIN CO_RegistroMarkup RM ON RM.GastoId= CO_Registro.IdRegistro  
     WHERE(MONTH(CO_Registro.MesPresentacion) <= MONTH(@MesAnterior)  
                          AND (YEAR(CO_Registro.MesPresentacion) = YEAR(@MesAnterior)  
        )    
                          AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto  
        )    
                    GROUP BY CO_LineaPresupuestoMes.IdTipoServicio,    
                             CO_LineaPresupuestoMes.IdActividad;  
             UPDATE #Reporte  
               SET  
                   Programa = #Programa.Gastos  
             FROM #Programa  
             WHERE #Reporte.Actividad = #Programa.Actividad  
                   AND #Reporte.Servicio = #Programa.Servicio;  
             --  
             UPDATE #Reporte  
               SET  
                   Gastos = #Gastos.Gastos  
             FROM #Gastos  
             WHERE #Reporte.Actividad = #Gastos.Actividad  
                   AND #Reporte.Servicio = #Gastos.Servicio;  
   UPDATE #Reporte    
            SET    
                GastoHastaMesAnterior = #AcumuladoHastaMesAnterior.Gastos    
            FROM #AcumuladoHastaMesAnterior    
            WHERE   
    #Reporte.Actividad = #AcumuladoHastaMesAnterior.Actividad    
                AND #Reporte.Servicio = #AcumuladoHastaMesAnterior.Servicio    
-- UPDATE   
--     #Reporte  
-- SET   
--     Acumulado = #Acumulado.Gastos  
-- FROM   
--     #Acumulado  
-- WHERE   
--     #Reporte.Actividad = #Acumulado.Actividad  
--     AND #Reporte.Servicio = #Acumulado.Servicio;  
-- UPDATE   
--     #Reporte  
-- SET   
--     GastoHastaMesAnterior = #AcumuladoHastaMesAnterior.Gastos  
-- FROM   
--     #AcumuladoHastaMesAnterior  
-- WHERE   
--     #Reporte.Actividad = #AcumuladoHastaMesAnterior.Actividad  
--     AND #Reporte.Servicio = #AcumuladoHastaMesAnterior.Servicio;  
             --  
             UPDATE #Reporte  
               SET  
                   Presupuesto = #Presupuesto.Gastos  
             FROM #Presupuesto  
             WHERE #Reporte.Actividad = #Presupuesto.Actividad  
                   AND #Reporte.Servicio = #Presupuesto.Servicio;  
             --  
             UPDATE #Reporte  
               SET  
                   DisplayServicio = CO_TipoServicio.NombreTipoServicio  
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
                   orden = CO_ServicioActividad.Orden  
             FROM CO_ServicioActividad  
             WHERE CO_ServicioActividad.IdTipoServicio = #Reporte.Servicio  
                   AND CO_ServicioActividad.IdActividad = #Reporte.Actividad;  
             --  
             UPDATE #Reporte  
               SET  
                   Saldo = 0; -- Programa - Acumulado;  
    --delete from #reporte where programa = 0  
    --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  
    --Para reportes  
    --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  
    --update #Reporte set Gastos  = #Programa .Gastos   from #Programa  where #Reporte.Actividad   = #Programa.Actividad and #Reporte.Servicio = #Programa.Servicio    
/**/  
             DELETE FROM dbo.TempReporteGastosNivelActividad;  
/**/  
             INSERT INTO [dbo].[TempReporteGastosNivelActividad]  
([Servicio],  
 [Actividad],  
 [DisplayServicio],  
 [DisplayActividad],  
 [Programa],  
 [GastoHastaMesAnterior],  
 [Presupuesto],  
 [Gastos],  
 [Acumulado],  
 [Saldo],  
 [Fecha],  
 [orden]  
)  
                    SELECT Servicio,  
                           Actividad,  
                           DisplayServicio,  
                           DisplayActividad,  
                           Programa,  
                           --ISNULL((GastoHastaMesAnterior * 1.07),0),  
                           ISNULL((GastoHastaMesAnterior ),0),  
         Presupuesto,  
         --ISNULL((Gastos * 1.07),0),    
         ISNULL((Gastos),0),    
         --ISNULL(((GastoHastaMesAnterior * 1.07) + (Gastos * 1.07)),0) AS Acumulado,  
          ISNULL(((GastoHastaMesAnterior ) + (Gastos )),0) AS Acumulado,  
                           Saldo,  
                           DATEFROMPARTS(@anio, @mesge, 1),  
                           R.orden  
                    FROM #Reporte R  
                         JOIN dbo.CO_TipoServicio TS ON R.Servicio = TS.ID_TIPOSER  
                    ORDER BY TS.Orden;  
/**/  
declare @NombrePresupuesto nvarchar(600)  
select @NombrePresupuesto = nombre from co_presupuesto where idPresupuesto = @IdPresupuesto  
             SELECT Servicio,  
                    Actividad,  
                    DisplayServicio,  
                    DisplayActividad,  
                    Programa,  
                    GastoHastaMesAnterior,  
                    Presupuesto,  
                    Gastos,  
                    Acumulado,  
                    Programa - Acumulado AS Saldo,   
                    Fecha,  
                    Orden,  
                    RGNA.IdReporteGastosNivelActividad,  
     @MesAnterior  AS FechaMesAnterior,  
     'PRESUPUESTO ' + UPPER(ISNULL(@NombrePresupuesto, '')) + ' AREA CONTRACTUAL' as NombrePresupuesto,  
     'Reporte de Integración  de Gastos Elegibles ' + ISNULL(@NombrePresupuesto, '') as Etiqueta1  
             FROM TempReporteGastosNivelActividad RGNA;  
                  --JOIN dbo.CO_TipoServicio TS ON RGNA.Servicio = TS.ID_TIPOSER  
             --ORDER BY TS.Orden  
         END;  
     --[sp_CO_ReporteGastosNivelActividad] 10000,6,2015

