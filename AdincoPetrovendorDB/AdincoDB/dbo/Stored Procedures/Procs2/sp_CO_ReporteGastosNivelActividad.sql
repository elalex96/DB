IF EXISTS
(
    SELECT 1
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_CO_ReporteGastosNivelActividad]')
      AND type = 'P'
)
BEGIN
    DROP PROCEDURE [dbo].[sp_CO_ReporteGastosNivelActividad];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
    @MesGE         INT = 0,
    @Anio          INT = 0
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
        Servicio              INT,
        Actividad             INT,
        DisplayServicio       VARCHAR(50),
        DisplayActividad      VARCHAR(50),
        Programa              DECIMAL(18, 4),
        GastoHastaMesAnterior DECIMAL(18, 4),
        Presupuesto           DECIMAL(18, 4),
        Gastos                DECIMAL(18, 4),
        Acumulado             DECIMAL(18, 4),
        Saldo                 DECIMAL(18, 4),
        orden                 INT
    );

    CREATE TABLE #Programa
    (
        Servicio  INT,
        Actividad INT,
        Gastos    DECIMAL(18, 4)
    );

    CREATE TABLE #Gastos
    (
        Servicio  INT,
        Actividad INT,
        Gastos    DECIMAL(18, 4)
    );

    CREATE TABLE #Acumulado
    (
        Servicio  INT,
        Actividad INT,
        Gastos    DECIMAL(18, 4)
    );

    CREATE TABLE #AcumuladoHastaMesAnterior
    (
        Servicio  INT,
        Actividad INT,
        Gastos    DECIMAL(18, 4)
    );

    CREATE TABLE #Presupuesto
    (
        Servicio  INT,
        Actividad INT,
        Gastos    DECIMAL(18, 4)
    );

    DECLARE @MesActual DATETIME = DATEFROMPARTS(@Anio, @MesGE, 1);
    DECLARE @MesAnterior DATETIME = DATEADD(MONTH, -1, @MesActual);
    DECLARE @NombrePresupuesto VARCHAR(600);
    DECLARE @ContratoDestino INT = 10007;

    SELECT
        @NombrePresupuesto = P.Nombre
    FROM CO_Presupuesto P WITH (NOLOCK)
    WHERE P.IdPresupuesto = @IdPresupuesto;

    ;WITH Servicios AS
    (
        SELECT DISTINCT
            LPM.IdTipoServicio
        FROM CO_LineaPresupuestoMes LPM WITH (NOLOCK)
        WHERE LPM.IdPresupuesto = @IdPresupuesto
    ),
    Actividades AS
    (
        SELECT
            AC.IdActividad,
            AC.NombreActividad
        FROM CO_ActividadCIEP AC WITH (NOLOCK)
        WHERE AC.IdContrato = @ContratoDestino
          AND AC.NombreActividad IN
          (
              N'Administración',
              N'Ductos',
              N'Estudios',
              N'Instalaciones',
              N'Pozos'
          )
    )
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
    SELECT
        S.IdTipoServicio    AS Servicio,
        A.IdActividad       AS Actividad,
        ''                  AS DisplayServicio,
        ''                  AS DisplayActividad,
        0                   AS Programa,
        0                   AS GastoHastaMesAnterior,
        0                   AS Presupuesto,
        0                   AS Gastos,
        0                   AS Acumulado,
        0                   AS Saldo,
        ISNULL(TS.Orden, 0) AS orden
    FROM Servicios S
    CROSS JOIN Actividades A
    LEFT JOIN CO_TipoServicio TS WITH (NOLOCK)
        ON S.IdTipoServicio = TS.IdTipoServicio;

    INSERT INTO #Programa
    (
        Servicio,
        Actividad,
        Gastos
    )
    SELECT
        LPM.IdTipoServicio AS Servicio,
        ACDestino.IdActividad AS Actividad,
        CAST(SUM(ISNULL(LPM.Monto, 0)) AS DECIMAL(18, 4)) AS Gastos
    FROM CO_LineaPresupuestoMes LPM WITH (NOLOCK)
    INNER JOIN CO_ActividadCIEP ACOrigen WITH (NOLOCK)
        ON LPM.IdActividad = ACOrigen.IdActividad
    INNER JOIN CO_ActividadCIEP ACDestino WITH (NOLOCK)
        ON ACDestino.IdContrato = @ContratoDestino
       AND ACDestino.NombreActividad = ACOrigen.NombreActividad
    WHERE LPM.IdPresupuesto = @IdPresupuesto
      AND ACDestino.NombreActividad IN
      (
          N'Administración',
          N'Ductos',
          N'Estudios',
          N'Instalaciones',
          N'Pozos'
      )
    GROUP BY
        LPM.IdTipoServicio,
        ACDestino.IdActividad;

    INSERT INTO #Presupuesto
    (
        Servicio,
        Actividad,
        Gastos
    )
    SELECT
        LPM.IdTipoServicio AS Servicio,
        ACDestino.IdActividad AS Actividad,
        CAST(SUM(ISNULL(LPM.Monto, 0)) AS DECIMAL(18, 4)) AS Gastos
    FROM CO_LineaPresupuestoMes LPM WITH (NOLOCK)
    INNER JOIN CO_ActividadCIEP ACOrigen WITH (NOLOCK)
        ON LPM.IdActividad = ACOrigen.IdActividad
    INNER JOIN CO_ActividadCIEP ACDestino WITH (NOLOCK)
        ON ACDestino.IdContrato = @ContratoDestino
       AND ACDestino.NombreActividad = ACOrigen.NombreActividad
    WHERE LPM.IdPresupuesto = @IdPresupuesto
      AND MONTH(LPM.AC_PRESUP_MES) = @MesGE
      AND YEAR(LPM.AC_PRESUP_MES) = @Anio
      AND ACDestino.NombreActividad IN
      (
          N'Administración',
          N'Ductos',
          N'Estudios',
          N'Instalaciones',
          N'Pozos'
      )
    GROUP BY
        LPM.IdTipoServicio,
        ACDestino.IdActividad;

    INSERT INTO #Gastos
    (
        Servicio,
        Actividad,
        Gastos
    )
    SELECT
        LPM.IdTipoServicio AS Servicio,
        ACDestino.IdActividad AS Actividad,
        CAST
        (
            SUM
            (
                CAST
                (
                    (
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1 THEN
                                CASE
                                    WHEN FI_Factura.TipoComprobante LIKE '%egreso%'
                                      OR FI_Factura.TipoComprobante LIKE 'E%' THEN
                                        ISNULL
                                        (
                                            (
                                                ABS
                                                (
                                                    ISNULL
                                                    (
                                                        ABS(ISNULL(CO_RegistroMarkup.MontoGasto, CO_Registro.MontoRegistro))
                                                        + ABS(ISNULL(CO_RegistroMarkup.MontoEquivalente, 0)),
                                                        0
                                                    )
                                                ) * -1
                                            ),
                                            0
                                        )
                                    ELSE
                                        ISNULL
                                        (
                                            ISNULL(CO_RegistroMarkup.MontoGasto, CO_Registro.MontoRegistro)
                                            + ISNULL(CO_RegistroMarkup.MontoEquivalente, 0),
                                            0
                                        )
                                END
                            ELSE
                                ISNULL
                                (
                                    ISNULL(CO_RegistroMarkup.MontoGasto, CO_Registro.MontoRegistro)
                                    + ISNULL(CO_RegistroMarkup.MontoEquivalente, 0),
                                    0
                                )
                        END
                    )
                    /
                    NULLIF
                    (
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1 THEN
                                ISNULL(CO_RegistroMarkup.TipoCambio, CO_TipoCambioMensual.TipoCambio)
                            WHEN CO_Registro.CvTipoDocFacturacion IN (2, 3) THEN
                                ISNULL(CO_RegistroMarkup.TipoCambio, CO_TipoCambioMensualPC.TipoCambio)
                            ELSE
                                0
                        END,
                        0
                    )
                    AS DECIMAL(18, 2)
                )
            ) AS DECIMAL(18, 4)
        ) AS Gastos
    FROM CO_LineaPresupuestoMes LPM WITH (NOLOCK)
    LEFT JOIN CO_Registro WITH (NOLOCK)
        ON LPM.IdLineaPresupuestoMes = CO_Registro.IdPrograma
    LEFT JOIN CO_Servicio WITH (NOLOCK)
        ON LPM.IdServicio = CO_Servicio.IdServicio
    LEFT JOIN FI_Factura WITH (NOLOCK)
        ON CO_Registro.IdFactura = FI_Factura.IdFactura
    LEFT JOIN CO_TipoCambioMensual WITH (NOLOCK)
        ON FI_Factura.IdMoneda = CO_TipoCambioMensual.IdMoneda
       AND MONTH(FI_Factura.Fecha) = CO_TipoCambioMensual.IdMes
       AND YEAR(FI_Factura.Fecha) = CO_TipoCambioMensual.Anio
    LEFT JOIN dbo.FI_PedimentoComprobante WITH (NOLOCK)
        ON CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
    LEFT JOIN dbo.CO_TipoCambioMensual CO_TipoCambioMensualPC WITH (NOLOCK)
        ON FI_PedimentoComprobante.IdMoneda = CO_TipoCambioMensualPC.IdMoneda
       AND YEAR(FI_PedimentoComprobante.FechaPago) = CO_TipoCambioMensualPC.Anio
       AND MONTH(FI_PedimentoComprobante.FechaPago) = CO_TipoCambioMensualPC.IdMes
    LEFT JOIN CO_RegistroMarkup WITH (NOLOCK)
        ON CO_Registro.IdRegistro = CO_RegistroMarkup.GastoId
    INNER JOIN CO_ActividadCIEP ACOrigen WITH (NOLOCK)
        ON LPM.IdActividad = ACOrigen.IdActividad
    INNER JOIN CO_ActividadCIEP ACDestino WITH (NOLOCK)
        ON ACDestino.IdContrato = @ContratoDestino
       AND ACDestino.NombreActividad = ACOrigen.NombreActividad
    WHERE MONTH(CO_Registro.MesPresentacion) = @MesGE
      AND YEAR(CO_Registro.MesPresentacion) = @Anio
      AND LPM.IdPresupuesto = @IdPresupuesto
      AND ACDestino.NombreActividad IN
      (
          N'Administración',
          N'Ductos',
          N'Estudios',
          N'Instalaciones',
          N'Pozos'
      )
    GROUP BY
        LPM.IdTipoServicio,
        ACDestino.IdActividad;

    INSERT INTO #AcumuladoHastaMesAnterior
    (
        Servicio,
        Actividad,
        Gastos
    )
    SELECT
        LPM.IdTipoServicio AS Servicio,
        ACDestino.IdActividad AS Actividad,
        CAST
        (
            SUM
            (
                CAST
                (
                    CASE
                        WHEN CO_Registro.CvTipoDocFacturacion = 1
                             AND ISNULL(ISNULL(CO_Registro.MontoRegistro, CO_RegistroMarkup.MontoGasto), 0) <> 0 THEN
                            (
                                CASE
                                    WHEN FI_Factura.TipoComprobante LIKE '%egreso%'
                                      OR FI_Factura.TipoComprobante LIKE 'E%' THEN
                                        ISNULL
                                        (
                                            (
                                                ABS
                                                (
                                                    ISNULL
                                                    (
                                                        ISNULL(ABS(CO_Registro.MontoRegistro), ABS(CO_RegistroMarkup.MontoGasto))
                                                        + ISNULL(ABS(CO_RegistroMarkup.MontoEquivalente), 0),
                                                        0
                                                    )
                                                ) * -1
                                            ),
                                            0
                                        )
                                    ELSE
                                        ISNULL
                                        (
                                            ISNULL(CO_Registro.MontoRegistro, CO_RegistroMarkup.MontoGasto)
                                            + ISNULL(CO_RegistroMarkup.MontoEquivalente, 0),
                                            0
                                        )
                                END
                            )
                            / NULLIF(ISNULL(CO_RegistroMarkup.TipoCambio, CO_TipoCambioMensual.TipoCambio), 0)

                        WHEN CO_Registro.CvTipoDocFacturacion IN (2, 3)
                             AND ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN
                            ISNULL(CO_RegistroMarkup.MontoGasto + CO_RegistroMarkup.MontoEquivalente, 0)
                            / NULLIF(ISNULL(CO_RegistroMarkup.TipoCambio, CO_TipoCambioMensualPC.TipoCambio), 0)
                        ELSE
                            0
                    END
                    AS DECIMAL(18, 2)
                )
            ) AS DECIMAL(18, 4)
        ) AS Gastos
    FROM CO_LineaPresupuestoMes LPM WITH (NOLOCK)
    LEFT JOIN CO_Registro WITH (NOLOCK)
        ON LPM.IdLineaPresupuestoMes = CO_Registro.IdPrograma
    LEFT JOIN CO_Servicio WITH (NOLOCK)
        ON LPM.IdServicio = CO_Servicio.IdServicio
    LEFT JOIN FI_Factura WITH (NOLOCK)
        ON CO_Registro.IdFactura = FI_Factura.IdFactura
    LEFT JOIN CO_TipoCambioMensual WITH (NOLOCK)
        ON FI_Factura.IdMoneda = CO_TipoCambioMensual.IdMoneda
       AND MONTH(FI_Factura.Fecha) = CO_TipoCambioMensual.IdMes
       AND YEAR(FI_Factura.Fecha) = CO_TipoCambioMensual.Anio
    LEFT JOIN dbo.FI_PedimentoComprobante WITH (NOLOCK)
        ON CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
    LEFT JOIN dbo.CO_TipoCambioMensual CO_TipoCambioMensualPC WITH (NOLOCK)
        ON FI_PedimentoComprobante.IdMoneda = CO_TipoCambioMensualPC.IdMoneda
       AND YEAR(FI_PedimentoComprobante.FechaPago) = CO_TipoCambioMensualPC.Anio
       AND MONTH(FI_PedimentoComprobante.FechaPago) = CO_TipoCambioMensualPC.IdMes
    LEFT JOIN CO_RegistroMarkup WITH (NOLOCK)
        ON CO_Registro.IdRegistro = CO_RegistroMarkup.GastoId
    INNER JOIN CO_ActividadCIEP ACOrigen WITH (NOLOCK)
        ON LPM.IdActividad = ACOrigen.IdActividad
    INNER JOIN CO_ActividadCIEP ACDestino WITH (NOLOCK)
        ON ACDestino.IdContrato = @ContratoDestino
       AND ACDestino.NombreActividad = ACOrigen.NombreActividad
    WHERE CO_Registro.MesPresentacion <= EOMONTH(@MesAnterior)
      AND LPM.IdPresupuesto = @IdPresupuesto
      AND ACDestino.NombreActividad IN
      (
          N'Administración',
          N'Ductos',
          N'Estudios',
          N'Instalaciones',
          N'Pozos'
      )
    GROUP BY
        LPM.IdTipoServicio,
        ACDestino.IdActividad;

    UPDATE R
    SET R.Programa = P.Gastos
    FROM #Reporte R
    INNER JOIN #Programa P
        ON R.Actividad = P.Actividad
       AND R.Servicio = P.Servicio;

    UPDATE R
    SET R.Gastos = G.Gastos
    FROM #Reporte R
    INNER JOIN #Gastos G
        ON R.Actividad = G.Actividad
       AND R.Servicio = G.Servicio;

    UPDATE R
    SET R.GastoHastaMesAnterior = A.Gastos
    FROM #Reporte R
    INNER JOIN #AcumuladoHastaMesAnterior A
        ON R.Actividad = A.Actividad
       AND R.Servicio = A.Servicio;

    UPDATE R
    SET R.Presupuesto = P.Gastos
    FROM #Reporte R
    INNER JOIN #Presupuesto P
        ON R.Actividad = P.Actividad
       AND R.Servicio = P.Servicio;

    UPDATE R
    SET R.DisplayServicio = TS.NombreTipoServicio
    FROM #Reporte R
    INNER JOIN CO_TipoServicio TS
        ON TS.IdTipoServicio = R.Servicio;

    UPDATE R
    SET R.DisplayActividad = AC.NombreActividad
    FROM #Reporte R
    INNER JOIN CO_ActividadCIEP AC
        ON AC.IdActividad = R.Actividad;

    UPDATE #Reporte
    SET Acumulado = ISNULL(GastoHastaMesAnterior, 0) + ISNULL(Gastos, 0),
        Saldo = ISNULL(Programa, 0) - (ISNULL(GastoHastaMesAnterior, 0) + ISNULL(Gastos, 0));

    DELETE FROM dbo.TempReporteGastosNivelActividad;

    INSERT INTO dbo.TempReporteGastosNivelActividad
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
        Fecha,
        orden
    )
    SELECT
        R.Servicio,
        R.Actividad,
        R.DisplayServicio,
        R.DisplayActividad,
        R.Programa,
        ISNULL(R.GastoHastaMesAnterior, 0) AS GastoHastaMesAnterior,
        R.Presupuesto,
        ISNULL(R.Gastos, 0) AS Gastos,
        ISNULL(R.Acumulado, 0) AS Acumulado,
        ISNULL(R.Saldo, 0) AS Saldo,
        DATEFROMPARTS(@Anio, @MesGE, 1) AS Fecha,
        R.orden
    FROM #Reporte R
    ORDER BY
        R.DisplayServicio,
        R.DisplayActividad;

    SELECT
        RGNA.Servicio,
        RGNA.Actividad,
        RGNA.DisplayServicio,
        RGNA.DisplayActividad,
        ISNULL(CAST(RGNA.Programa AS DECIMAL(18, 2)), 0.00)              AS Programa,
        ISNULL(CAST(RGNA.GastoHastaMesAnterior AS DECIMAL(18, 2)), 0.00) AS GastoHastaMesAnterior,
        ISNULL(CAST(RGNA.Presupuesto AS DECIMAL(18, 2)), 0.00)           AS Presupuesto,
        ISNULL(CAST(RGNA.Gastos AS DECIMAL(18, 2)), 0.00)                AS Gastos,
        ISNULL(CAST(RGNA.Acumulado AS DECIMAL(18, 2)), 0.00)             AS Acumulado,
        ISNULL(CAST(RGNA.Saldo AS DECIMAL(18, 2)), 0.00)                 AS Saldo,
        RGNA.Fecha,
        RGNA.Orden,
        RGNA.IdReporteGastosNivelActividad,
        @MesAnterior                                                      AS FechaMesAnterior,
        'PRESUPUESTO ' + UPPER(ISNULL(@NombrePresupuesto, '')) + ' AREA CONTRACTUAL'    AS NombrePresupuesto,
        'Reporte de Integración  de Gastos Elegibles ' + ISNULL(@NombrePresupuesto, '') AS Etiqueta1
    FROM dbo.TempReporteGastosNivelActividad RGNA WITH (NOLOCK)
    ORDER BY
        RGNA.DisplayServicio,
        RGNA.DisplayActividad;
END;
GO