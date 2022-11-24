-- =============================================  
-- Author:        Miguel  
-- Create date: Domingo 1 Diciembre 2017 12:59 p.m.  
-- Description:    Reporte de Integración de Gastos a Nivel Actividad  
-- =============================================
-- Author:  Reyna Olvera    
-- Create date: 1 junio 2022    
-- Description: se toma el cuenta el markup en los totales de mes actual y mes anterior    
-- ============================================= 
-- Author:  Reyna Olvera    
-- Create date: 1 Septiembre 2022    
-- Description: Se agrega ajuste, cuando el gasto se encuentre relacionado a una nota de credito, se colocará como negativo
-- ============================================= 
-- Author:  Neri del Angel    
-- Create date: 10 de Octubre del 2022    
-- Description: Se agrega ajuste de 2 dígitos en los montos salientes de las columnas:
--				[Programa,GastoHastaMesAnterior,Presupuesto,Gastos,Acumulado,Saldo],
--				Se agregaron (NOLOCK) y ajuste en el orden de llamado de las tablas en los join
-- ============================================= 
CREATE PROCEDURE [dbo].[sp_CO_ReporteGastosNivelActividad]
    @IdPresupuesto INT = 0,
    @MesGE INT = 0,
    @Anio INT = 0
AS
BEGIN

    SET NOCOUNT ON;
    IF OBJECT_ID('tempdb..#Reporte', 'U') IS NOT NULL
        DROP TABLE #Reporte;
    IF OBJECT_ID('tempdb..#Programa', 'U') IS NOT NULL
        DROP TABLE #Programa;
    IF OBJECT_ID('tempdb..#Gastos', 'U') IS NOT NULL
        DROP TABLE #Gastos;
    IF OBJECT_ID('tempdb..#Acumulado', 'U') IS NOT NULL
        DROP TABLE #Acumulado;
    IF OBJECT_ID('tempdb..#AcumuladoHastaMesAnterior', 'U') IS NOT NULL
        DROP TABLE #AcumuladoHastaMesAnterior;
    IF OBJECT_ID('tempdb..#Presupuesto', 'U') IS NOT NULL
        DROP TABLE #Presupuesto;

    CREATE TABLE #Reporte
    (
        Servicio INT,
        Actividad INT,
        DisplayServicio NVARCHAR(50),
        DisplayActividad NVARCHAR(50),
        Programa MONEY,
        GastoHastaMesAnterior MONEY,
        Presupuesto MONEY,
        Gastos MONEY,
        Acumulado MONEY,
        Saldo MONEY,
        orden INT
    );
    CREATE TABLE #Programa
    (
        Servicio INT,
        Actividad INT,
        Gastos MONEY
    );
    CREATE TABLE #Gastos
    (
        Servicio INT,
        Actividad INT,
        Gastos MONEY
    );
    CREATE TABLE #Acumulado
    (
        Servicio INT,
        Actividad INT,
        Gastos MONEY
    );
    CREATE TABLE #AcumuladoHastaMesAnterior
    (
        Servicio INT,
        Actividad INT,
        Gastos MONEY
    );
    CREATE TABLE #Presupuesto
    (
        Servicio INT,
        Actividad INT,
        Gastos MONEY
    );

    DECLARE @MesActual datetime = DATEFROMPARTS(@Anio, @MesGE, 1);
    DECLARE @MesAnterior datetime = DATEADD(MONTH, -1, @MesActual);
    /**/
    INSERT INTO #Reporte
    (
        Servicio,
        Actividad,
        DisplayServicio,
        DisplayActividad,
        Programa,
        GastoHastaMesAnterior,
        Presupuesto,
        Gastos,
        Acumulado,
        Saldo,
        orden
    )
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
    FROM CO_ServicioActividad (NOLOCK);
    /**/
    INSERT INTO #Programa
    (
        Servicio,
        Actividad,
        Gastos
    )
    SELECT CO_LineaPresupuestoMes.IdTipoServicio,
           CO_LineaPresupuestoMes.IdActividad,
           SUM(ISNULL(CO_LineaPresupuestoMes.Monto, 0)) AS Gasto
    FROM CO_LineaPresupuestoMes (NOLOCK)
    WHERE CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
    GROUP BY CO_LineaPresupuestoMes.IdTipoServicio,
             CO_LineaPresupuestoMes.IdActividad;
    /**/
    INSERT INTO #Presupuesto
    (
        Servicio,
        Actividad,
        Gastos
    )
    SELECT CO_LineaPresupuestoMes.IdTipoServicio,
           CO_LineaPresupuestoMes.IdActividad,
           SUM(ISNULL(CO_LineaPresupuestoMes.Monto, 0)) AS Gasto
    FROM CO_LineaPresupuestoMes (NOLOCK)
        JOIN CO_ActividadCIEP (NOLOCK)
            ON CO_LineaPresupuestoMes.IDActividad = CO_ActividadCIEP.IdActividad
        JOIN CO_TipoServicio (NOLOCK)
            ON CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.IdTipoServicio
    WHERE CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
          AND MONTH(CO_LineaPresupuestoMes.[AC_PRESUP_MES]) = @MesGE
          AND YEAR(CO_LineaPresupuestoMes.[AC_PRESUP_MES]) = @Anio
    GROUP BY CO_LineaPresupuestoMes.IdTipoServicio,
             CO_LineaPresupuestoMes.IdActividad;

    INSERT INTO #Gastos
    SELECT CO_LineaPresupuestoMes.IdTipoServicio,
           CO_LineaPresupuestoMes.IdActividad,
           SUM(   CAST((CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1 THEN
                  (CASE
                       WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%'
                            OR FI_Factura.TipoComprobante LIKE 'E%' THEN
                           ISNULL(
                                     (ABS(ISNULL(
                                                    ABS(ISNULL(CO_RegistroMarkup.MontoGasto, CO_Registro.MontoRegistro))
                                                    + ABS(ISNULL(CO_RegistroMarkup.MontoEquivalente, 0)),
                                                    0
                                                )
                                         ) * -1
                                     ),
                                     0
                                 )
                       ELSE
                           ISNULL(
                                     ISNULL(CO_RegistroMarkup.MontoGasto, CO_Registro.MontoRegistro)
                                     + ISNULL(CO_RegistroMarkup.MontoEquivalente, 0),
                                     0
                                 )
                   END
                  )
                            ELSE
                                ISNULL(
                                          ISNULL(CO_RegistroMarkup.MontoGasto, CO_Registro.MontoRegistro)
                                          + ISNULL(CO_RegistroMarkup.MontoEquivalente, 0),
                                          0
                                      )
                        END
                       ) / (CASE
                                WHEN CO_Registro.CvTipoDocFacturacion = 1 THEN
                                    ISNULL(CO_RegistroMarkup.TipoCambio, CO_TipoCambioMensual.TipoCambio)
                                WHEN CO_Registro.CvTipoDocFacturacion IN ( 2, 3 ) THEN
                                    ISNULL(CO_RegistroMarkup.TipoCambio, CO_TipoCambioMensualPC.TipoCambio)
                                ELSE
                                    0
                            END
                           ) AS DECIMAL(15, 2))
              ) AS Gastos
    FROM CO_LineaPresupuestoMes (NOLOCK)
        LEFT JOIN CO_Registro (NOLOCK)
            ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
        LEFT JOIN CO_Servicio (NOLOCK)
            ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
        LEFT JOIN FI_Factura (NOLOCK)
            ON CO_Registro.IdFactura = FI_Factura.IdFactura
        LEFT JOIN CO_TipoCambioMensual (NOLOCK)
            ON FI_Factura.IdMoneda = CO_TipoCambioMensual.IdMoneda
               AND MONTH(FI_Factura.Fecha) = CO_TipoCambioMensual.IdMes
               AND YEAR(FI_Factura.Fecha) = CO_TipoCambioMensual.Anio
        LEFT OUTER JOIN dbo.FI_PedimentoComprobante (NOLOCK)
            ON CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
        LEFT OUTER JOIN dbo.CO_TipoCambioMensual CO_TipoCambioMensualPC (NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = CO_TipoCambioMensualPC.IdMoneda
               AND YEAR(FI_PedimentoComprobante.FechaPago) = CO_TipoCambioMensualPC.Anio
               AND MONTH(FI_PedimentoComprobante.FechaPago) = CO_TipoCambioMensualPC.IdMes
        LEFT JOIN CO_RegistroMarkup (NOLOCK)
            ON CO_Registro.IdRegistro = CO_RegistroMarkup.GastoId
    WHERE (
              MONTH(CO_Registro.MesPresentacion) = @MesGE
              AND (YEAR(CO_Registro.MesPresentacion) = @Anio)
          )
          AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
    GROUP BY CO_LineaPresupuestoMes.IdTipoServicio,
             CO_LineaPresupuestoMes.IdActividad;
    /**/
    -- gasto aculumado mes anterior  
    INSERT INTO #AcumuladoHastaMesAnterior
    SELECT CO_LineaPresupuestoMes.IdTipoServicio,
           CO_LineaPresupuestoMes.IdActividad,
           SUM(   CASE
                      WHEN CO_Registro.CvTipoDocFacturacion = 1
                           AND ISNULL(ISNULL(CO_Registro.MontoRegistro, CO_RegistroMarkup.MontoGasto), 0) <> 0 THEN
                  (CASE
                       WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%'
                            OR FI_Factura.TipoComprobante LIKE 'E%' THEN
                           ISNULL(
                                     (ABS(ISNULL(
                                                    (ISNULL(
                                                               ABS(CO_Registro.MontoRegistro),
                                                               ABS(CO_RegistroMarkup.MontoGasto)
                                                           ) + ISNULL(ABS(CO_RegistroMarkup.MontoEquivalente), 0)
                                                    ),
                                                    0
                                                )
                                         ) * -1
                                     ),
                                     0
                                 )
                       ELSE
                           ISNULL(
                                     (ISNULL(CO_Registro.MontoRegistro, CO_RegistroMarkup.MontoGasto)
                                      + ISNULL(CO_RegistroMarkup.MontoEquivalente, 0)
                                     ),
                                     0
                                 )
                   END
                  ) / ISNULL(CO_RegistroMarkup.TipoCambio, CO_TipoCambioMensual.TipoCambio)
                      WHEN CO_Registro.CvTipoDocFacturacion IN ( 2, 3 )
                           AND ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN
                          ISNULL(CO_RegistroMarkup.MontoGasto + CO_RegistroMarkup.MontoEquivalente, 0)
                          / ISNULL(CO_RegistroMarkup.TipoCambio, CO_TipoCambioMensualPC.TipoCambio)
                      ELSE
                          0
                  END
              ) AS Gastos
    FROM CO_LineaPresupuestoMes (NOLOCK)
        LEFT JOIN CO_Registro (NOLOCK)
            ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
        LEFT JOIN CO_Servicio (NOLOCK)
            ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
        LEFT JOIN FI_Factura (NOLOCK)
            ON CO_Registro.IdFactura = FI_Factura.IdFactura
        LEFT JOIN CO_TipoCambioMensual (NOLOCK)
            ON FI_Factura.IdMoneda = CO_TipoCambioMensual.IdMoneda
               AND MONTH(FI_Factura.Fecha) = CO_TipoCambioMensual.IdMes
               AND YEAR(FI_Factura.Fecha) = CO_TipoCambioMensual.Anio
        LEFT OUTER JOIN dbo.FI_PedimentoComprobante (NOLOCK)
            ON CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
        LEFT OUTER JOIN dbo.CO_TipoCambioMensual CO_TipoCambioMensualPC (NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = CO_TipoCambioMensualPC.IdMoneda
               AND YEAR(FI_PedimentoComprobante.FechaPago) = CO_TipoCambioMensualPC.Anio
               AND MONTH(FI_PedimentoComprobante.FechaPago) = CO_TipoCambioMensualPC.IdMes
        LEFT JOIN CO_RegistroMarkup (NOLOCK)
            ON CO_Registro.IdRegistro = CO_RegistroMarkup.GastoId
    WHERE (
              MONTH(CO_Registro.MesPresentacion) <= MONTH(@MesAnterior)
              AND (YEAR(CO_Registro.MesPresentacion) = YEAR(@MesAnterior))
              AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
          )
    GROUP BY CO_LineaPresupuestoMes.IdTipoServicio,
             CO_LineaPresupuestoMes.IdActividad;

    UPDATE #Reporte
    SET Programa = #Programa.Gastos
    FROM #Programa
    WHERE #Reporte.Actividad = #Programa.Actividad
          AND #Reporte.Servicio = #Programa.Servicio;
    --  
    UPDATE #Reporte
    SET Gastos = #Gastos.Gastos
    FROM #Gastos
    WHERE #Reporte.Actividad = #Gastos.Actividad
          AND #Reporte.Servicio = #Gastos.Servicio;

    UPDATE #Reporte
    SET GastoHastaMesAnterior = #AcumuladoHastaMesAnterior.Gastos
    FROM #AcumuladoHastaMesAnterior
    WHERE #Reporte.Actividad = #AcumuladoHastaMesAnterior.Actividad
          AND #Reporte.Servicio = #AcumuladoHastaMesAnterior.Servicio
    --  
    UPDATE #Reporte
    SET Presupuesto = #Presupuesto.Gastos
    FROM #Presupuesto
    WHERE #Reporte.Actividad = #Presupuesto.Actividad
          AND #Reporte.Servicio = #Presupuesto.Servicio;
    --  
    UPDATE #Reporte
    SET DisplayServicio = CO_TipoServicio.NombreTipoServicio
    FROM CO_TipoServicio
    WHERE CO_TipoServicio.IdTipoServicio = Servicio;
    --  
    UPDATE #Reporte
    SET DisplayActividad = CO_ActividadCIEP.NombreActividad
    FROM CO_ActividadCIEP
    WHERE CO_ActividadCIEP.IdActividad = Actividad;
    --  
    UPDATE #Reporte
    SET orden = CO_ServicioActividad.Orden
    FROM CO_ServicioActividad
    WHERE CO_ServicioActividad.IdTipoServicio = #Reporte.Servicio
          AND CO_ServicioActividad.IdActividad = #Reporte.Actividad;
    --  
    UPDATE #Reporte
    SET Saldo = 0;

    DELETE FROM dbo.TempReporteGastosNivelActividad;
    /**/
    INSERT INTO [dbo].[TempReporteGastosNivelActividad]
    (
        [Servicio],
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
           ISNULL((GastoHastaMesAnterior), 0),
           Presupuesto,
           ISNULL((Gastos), 0),
           ISNULL(((GastoHastaMesAnterior) + (Gastos)), 0) AS Acumulado,
           Saldo,
           DATEFROMPARTS(@anio, @mesge, 1),
           R.orden
    FROM #Reporte R
        JOIN dbo.CO_TipoServicio TS (NOLOCK)
            ON R.Servicio = TS.ID_TIPOSER
    ORDER BY TS.Orden;
    /**/
    declare @NombrePresupuesto nvarchar(600)
    select @NombrePresupuesto = Nombre
    from CO_Presupuesto (NOLOCK)
    where idPresupuesto = @IdPresupuesto

    SELECT Servicio,
           Actividad,
           DisplayServicio,
           DisplayActividad,
           ISNULL(CAST(Programa AS DECIMAL(15, 2)), 0.00) AS Programa,
           ISNULL(CAST(GastoHastaMesAnterior AS DECIMAL(15, 2)), 0.00) AS GastoHastaMesAnterior,
           ISNULL(CAST(Presupuesto AS DECIMAL(15, 2)), 0.00) AS Presupuesto,
           ISNULL(CAST(Gastos AS DECIMAL(15, 2)), 0.00) AS Gastos,
           ISNULL(CAST(Acumulado AS DECIMAL(15, 2)), 0.00) AS Acumulado,
           ISNULL(CAST(Programa - Acumulado AS DECIMAL(15, 2)), 0.00) AS Saldo,
           Fecha,
           Orden,
           RGNA.IdReporteGastosNivelActividad,
           @MesAnterior AS FechaMesAnterior,
           'PRESUPUESTO ' + UPPER(ISNULL(@NombrePresupuesto, '')) + ' AREA CONTRACTUAL' as NombrePresupuesto,
           'Reporte de Integración  de Gastos Elegibles ' + ISNULL(@NombrePresupuesto, '') as Etiqueta1
    FROM TempReporteGastosNivelActividad RGNA (NOLOCK);
END;