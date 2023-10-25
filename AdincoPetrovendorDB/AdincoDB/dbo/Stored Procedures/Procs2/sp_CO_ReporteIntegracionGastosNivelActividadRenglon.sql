USE Adinco;
GO
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'sp_CO_ReporteIntegracionGastosNivelActividadRenglon'
    )
    DROP PROCEDURE sp_CO_ReporteIntegracionGastosNivelActividadRenglon
GO
-- =============================================    
-- Author:  Miguel    
-- Create date: Domingo 1 Diciembre 2016 12:59 p.m.    
-- Description: Reporte de Integraci?n de Gastos a Nivel Actividad    
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
CREATE PROCEDURE [dbo].[sp_CO_ReporteIntegracionGastosNivelActividadRenglon]
    @Anio          INT = 0,
    @Mes           INT = 0,
    @IdPresupuesto INT = 0
AS
    BEGIN
        SET NOCOUNT ON;
        IF OBJECT_ID('tempdb..#Reporte', 'U') IS NOT NULL
            DROP TABLE #Reporte;
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
                Programa              MONEY,
                Gastos                MONEY,
                Acumulado             MONEY,
                Saldo                 MONEY,
                DisplayServicio       VARCHAR(500),
                DisplayActividad      VARCHAR(500),
                NoServicio            INT,
                DesServicio           VARCHAR(500),
                GastoHastaMesAnterior MONEY,
                Presupuesto           MONEY,
                orden                 INT,
                NoRubro               INT,
                DisplayRubro          VARCHAR(500)
            );
        CREATE TABLE #Gastos
            (
                Servicio   INT,
                Actividad  INT,
                Gastos     MONEY,
                NoServicio INT,
                NoRubro    INT
            );
        CREATE TABLE #Acumulado
            (
                Servicio   INT,
                Actividad  INT,
                Gastos     MONEY,
                NoServicio INT,
                NoRubro    INT
            );
        CREATE TABLE #AcumuladoHastaMesAnterior
            (
                Servicio   INT,
                Actividad  INT,
                Gastos     MONEY,
                NoServicio INT,
                NoRubro    INT
            );
        CREATE TABLE #Presupuesto
            (
                Servicio   INT,
                Actividad  INT,
                Gastos     MONEY,
                NoServicio INT,
                NoRubro    INT
            );
        DECLARE @TipoCambioMesMXN FLOAT;
        /**/
        DECLARE @MesActual datetime = DATEFROMPARTS(@Anio, @Mes, 1);
        DECLARE @MesAnterior datetime = DATEADD(MONTH, -1, @MesActual);
        DECLARE @nombrePresupuesto VARCHAR(200);

        INSERT INTO #Reporte
                    SELECT
                        CO_LineaPresupuestoMes.IdTipoServicio AS Servicio,
                        CO_LineaPresupuestoMes.IdActividad    AS Actividad,
                        SUM(ISNULL(CO_LineaPresupuestoMes.Monto, 0)),
                        0,
                        0,
                        0,
                        '',
                        '',
                        CO_LineaPresupuestoMes.IdServicio     AS NoServicio,
                        '',
                        0,
                        0,
                        0,
                        CO_LineaPresupuestoMes.IdRubro        AS NoRubro,
                        ''
                    FROM
                        CO_Servicio (NOLOCK)
                        JOIN
                            CO_LineaPresupuestoMes (NOLOCK)
                                ON CO_Servicio.IdServicio = CO_LineaPresupuestoMes.IdServicio
                    WHERE
                        CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
                    GROUP BY
                        CO_LineaPresupuestoMes.IdServicio,
                        CO_LineaPresupuestoMes.IdActividad,
                        CO_LineaPresupuestoMes.IdTipoServicio,
                        CO_LineaPresupuestoMes.IdRubro
        /**/
        INSERT INTO #Presupuesto
                    SELECT
                        CO_LineaPresupuestoMes.IdTipoServicio,
                        CO_LineaPresupuestoMes.IdActividad,
                        ISNULL(CO_LineaPresupuestoMes.Monto, 0) AS Gastos,
                        CO_Servicio.IdServicio                  AS NoServicio,
                        CO_LineaPresupuestoMes.IdRubro
                    FROM
                        CO_LineaPresupuestoMes (NOLOCK)
                        JOIN
                            CO_ActividadCIEP (NOLOCK)
                                ON CO_LineaPresupuestoMes.IDActividad = CO_ActividadCIEP.IdActividad
                        JOIN
                            CO_TipoServicio (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.IdTipoServicio
                        JOIN
                            CO_Servicio (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                    WHERE
                        CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
                        AND MONTH(CO_LineaPresupuestoMes.[AC_PRESUP_MES]) = @Mes
                        AND YEAR(CO_LineaPresupuestoMes.[AC_PRESUP_MES]) = @Anio
                        AND CO_Servicio.IdServicio = CO_LineaPresupuestoMes.IdServicio;
        /**/
        -- gasto acumulado mes actual   
        INSERT INTO #Gastos
                    SELECT
                        CO_LineaPresupuestoMes.IdTipoServicio AS Servicio,
                        CO_LineaPresupuestoMes.IdActividad    AS Actividad,
                        SUM(   CAST((CASE
                                         WHEN CO_Registro.CvTipoDocFacturacion = 1
                                             THEN (CASE
                                                       WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%'
                                                            OR FI_Factura.TipoComprobante LIKE 'E%'
                                                           THEN ISNULL(
                                                                          (ABS(ISNULL(
                                                                                         ABS(ISNULL(
                                                                                                       CO_RegistroMarkup.MontoGasto,
                                                                                                       CO_Registro.MontoRegistro
                                                                                                   )
                                                                                            )
                                                                                         + ABS(ISNULL(
                                                                                                         CO_RegistroMarkup.MontoEquivalente,
                                                                                                         0
                                                                                                     )
                                                                                              ), 0
                                                                                     )
                                                                              ) * -1
                                                                          ), 0
                                                                      )
                                                       ELSE
                                                           ISNULL(
                                                                     ISNULL(
                                                                               CO_RegistroMarkup.MontoGasto,
                                                                               CO_Registro.MontoRegistro
                                                                           )
                                                                     + ISNULL(CO_RegistroMarkup.MontoEquivalente, 0), 0
                                                                 )
                                                   END
                                                  )
                                         ELSE
                                             ISNULL(
                                                       ISNULL(CO_RegistroMarkup.MontoGasto, CO_Registro.MontoRegistro)
                                                       + ISNULL(CO_RegistroMarkup.MontoEquivalente, 0), 0
                                                   )
                                     END
                                    )
                                    / (CASE
                                           WHEN CO_Registro.CvTipoDocFacturacion = 1
                                               THEN ISNULL(
                                                              CO_RegistroMarkup.TipoCambio,
                                                              CO_TipoCambioMensual.TipoCambio
                                                          )
                                           WHEN CO_Registro.CvTipoDocFacturacion IN (
                                                                                        2, 3
                                                                                    )
                                               THEN ISNULL(
                                                              CO_RegistroMarkup.TipoCambio,
                                                              CO_TipoCambioMensualPC.TipoCambio
                                                          )
                                           ELSE
                                               0
                                       END
                                      ) AS DECIMAL(15, 2))
                           )                                  AS Gastos,
                        CO_LineaPresupuestoMes.IdServicio     AS NoServicio,
                        CO_LineaPresupuestoMes.IdRubro
                    FROM
                        CO_LineaPresupuestoMes (NOLOCK)
                        LEFT JOIN
                            CO_Registro (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
                        LEFT JOIN
                            CO_Servicio (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                        LEFT JOIN
                            FI_Factura (NOLOCK)
                                ON CO_Registro.IdFactura = FI_Factura.IdFactura
                        LEFT JOIN
                            CO_TipoCambioMensual (NOLOCK)
                                ON FI_Factura.IdMoneda = CO_TipoCambioMensual.IdMoneda
                                   AND MONTH(FI_Factura.Fecha) = CO_TipoCambioMensual.IdMes
                                   AND YEAR(FI_Factura.Fecha) = CO_TipoCambioMensual.Anio
                        LEFT OUTER JOIN
                            FI_PedimentoComprobante (NOLOCK)
                                ON CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
                        LEFT OUTER JOIN
                            CO_TipoCambioMensual   CO_TipoCambioMensualPC (NOLOCK)
                                ON FI_PedimentoComprobante.IdMoneda = CO_TipoCambioMensualPC.IdMoneda
                                   AND YEAR(FI_PedimentoComprobante.FechaPago) = CO_TipoCambioMensualPC.Anio
                                   AND MONTH(FI_PedimentoComprobante.FechaPago) = CO_TipoCambioMensualPC.IdMes
                        LEFT JOIN
                            CO_RegistroMarkup (NOLOCK)
                                ON CO_Registro.IdRegistro = CO_RegistroMarkup.GastoId
                    WHERE
                        (
                            MONTH(CO_Registro.MesPresentacion) = @Mes
                            AND (YEAR(CO_Registro.MesPresentacion) = @Anio)
                            AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
                        )
                    GROUP BY
                        CO_LineaPresupuestoMes.IdTipoServicio,
                        CO_LineaPresupuestoMes.IdActividad,
                        CO_LineaPresupuestoMes.IdServicio,
                        CO_LineaPresupuestoMes.IdRubro

        -- gasto aculumado mes anterior  
        INSERT INTO #AcumuladoHastaMesAnterior
                    SELECT
                        CO_LineaPresupuestoMes.IdTipoServicio AS Servicio,
                        CO_LineaPresupuestoMes.IdActividad    AS Actividad,
                        SUM(   CASE
                                   WHEN CO_Registro.CvTipoDocFacturacion = 1
                                        AND ISNULL(ISNULL(CO_Registro.MontoRegistro, CO_RegistroMarkup.MontoGasto), 0) <> 0
                                       THEN (CASE
                                                 WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%'
                                                      OR FI_Factura.TipoComprobante LIKE 'E%'
                                                     THEN ISNULL(
                                                                    (ABS(ISNULL(
                                                                                   (ISNULL(
                                                                                              ABS(CO_Registro.MontoRegistro),
                                                                                              ABS(CO_RegistroMarkup.MontoGasto)
                                                                                          )
                                                                                    + ISNULL(
                                                                                                ABS(CO_RegistroMarkup.MontoEquivalente),
                                                                                                0
                                                                                            )
                                                                                   ), 0
                                                                               )
                                                                        ) * -1
                                                                    ), 0
                                                                )
                                                 ELSE
                                                     ISNULL(
                                                               (ISNULL(
                                                                          CO_Registro.MontoRegistro,
                                                                          CO_RegistroMarkup.MontoGasto
                                                                      ) + ISNULL(CO_RegistroMarkup.MontoEquivalente, 0)
                                                               ),
                                                               0
                                                           )
                                             END
                                            ) / ISNULL(CO_RegistroMarkup.TipoCambio, CO_TipoCambioMensual.TipoCambio)
                                   WHEN CO_Registro.CvTipoDocFacturacion IN (
                                                                                2, 3
                                                                            )
                                        AND ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                                       THEN ISNULL(CO_RegistroMarkup.MontoGasto + CO_RegistroMarkup.MontoEquivalente, 0)
                                            / ISNULL(CO_RegistroMarkup.TipoCambio, CO_TipoCambioMensualPC.TipoCambio)
                                   ELSE
                                       0
                               END
                           )                                  AS Gastos,
                        CO_LineaPresupuestoMes.IdServicio     AS NoServicio,
                        CO_LineaPresupuestoMes.IdRubro
                    FROM
                        CO_LineaPresupuestoMes (NOLOCK)
                        LEFT JOIN
                            CO_Registro (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
                        LEFT JOIN
                            CO_Servicio (NOLOCK)
                                ON CO_Servicio.IdServicio = CO_LineaPresupuestoMes.IdServicio
                        LEFT JOIN
                            FI_Factura (NOLOCK)
                                ON CO_Registro.IdFactura = FI_Factura.IdFactura
                        LEFT JOIN
                            CO_TipoCambioMensual (NOLOCK)
                                ON FI_Factura.IdMoneda = CO_TipoCambioMensual.IdMoneda
                                   AND MONTH(FI_Factura.Fecha) = CO_TipoCambioMensual.IdMes
                                   AND YEAR(FI_Factura.Fecha) = CO_TipoCambioMensual.Anio
                        LEFT OUTER JOIN
                            FI_PedimentoComprobante (NOLOCK)
                                ON CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
                        LEFT OUTER JOIN
                            CO_TipoCambioMensual   CO_TipoCambioMensualPC (NOLOCK)
                                ON FI_PedimentoComprobante.IdMoneda = CO_TipoCambioMensualPC.IdMoneda
                                   AND YEAR(FI_PedimentoComprobante.FechaPago) = CO_TipoCambioMensualPC.Anio
                                   AND MONTH(FI_PedimentoComprobante.FechaPago) = CO_TipoCambioMensualPC.IdMes
                        LEFT JOIN
                            CO_RegistroMarkup (NOLOCK)
                                ON CO_Registro.IdRegistro = CO_RegistroMarkup.GastoId
                    WHERE
                        (
                            CO_Registro.MesPresentacion <= EOMONTH(@MesAnterior)
                            AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
                        )
                    GROUP BY
                        CO_LineaPresupuestoMes.IdTipoServicio,
                        CO_LineaPresupuestoMes.IdActividad,
                        CO_LineaPresupuestoMes.IdServicio,
                        CO_LineaPresupuestoMes.IdRubro

        UPDATE
            #Reporte
        SET
            Gastos = #Gastos.Gastos
        FROM
            #Gastos
        WHERE
            #Reporte.Actividad = #Gastos.Actividad
            AND #Reporte.Servicio = #Gastos.Servicio
            AND #Reporte.NoServicio = #Gastos.NoServicio
            AND #Reporte.NoRubro = #Gastos.NoRubro;
        --    
        UPDATE
            #Reporte
        SET
            GastoHastaMesAnterior = #AcumuladoHastaMesAnterior.Gastos
        FROM
            #AcumuladoHastaMesAnterior
        WHERE
            #Reporte.Actividad = #AcumuladoHastaMesAnterior.Actividad
            AND #Reporte.Servicio = #AcumuladoHastaMesAnterior.Servicio
            AND #Reporte.NoServicio = #AcumuladoHastaMesAnterior.NoServicio
            AND #Reporte.NoRubro = #AcumuladoHastaMesAnterior.NoRubro;
        --  
        UPDATE
            #Reporte
        SET
            Presupuesto = #Presupuesto.Gastos
        FROM
            #Presupuesto
        WHERE
            #Reporte.Actividad = #Presupuesto.Actividad
            AND #Reporte.Servicio = #Presupuesto.Servicio
            AND #Reporte.NoServicio = #Presupuesto.NoServicio
            AND #Reporte.NoRubro = #Presupuesto.NoRubro;

        UPDATE
            #Reporte
        SET
            DisplayRubro = NombreRubro
        FROM
            CO_Rubro
        WHERE
            CO_Rubro.IdRubro = NoRubro;
        --    
        UPDATE
            #Reporte
        SET
            DisplayServicio = NombreTipoServicio
        FROM
            CO_TipoServicio
        WHERE
            CO_TipoServicio.IdTipoServicio = Servicio;
        --    
        UPDATE
            #Reporte
        SET
            DisplayActividad = CO_ActividadCIEP.NombreActividad
        FROM
            CO_ActividadCIEP
        WHERE
            CO_ActividadCIEP.IdActividad = Actividad;
        --    
        UPDATE
            #Reporte
        SET
            DesServicio = CO_Servicio.NombreServicio
        FROM
            CO_Servicio
        WHERE
            CO_Servicio.IdServicio = NoServicio;
        --    
        UPDATE
            #Reporte
        SET
            orden = CO_ServicioActividad.Orden
        FROM
            CO_ServicioActividad
        WHERE
            CO_ServicioActividad.IdTipoServicio = #Reporte.Servicio
            AND CO_ServicioActividad.IdActividad = #Reporte.Actividad;

        UPDATE
            #Reporte
        SET
            Saldo = 0;
        /**/
        DELETE FROM TempReporteIntegracionGastosNivelActividadRenglon;
        /**/
        INSERT INTO TempReporteIntegracionGastosNivelActividadRenglon
            (
                [DisplayServicio],
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
                [orden],
                IdRubro,
                Rubro
            )
                    SELECT
                        DisplayServicio,
                        DisplayActividad,
                        Servicio,
                        Actividad,
                        Programa,
                        ISNULL((Gastos), 0),
                        ISNULL(((GastoHastaMesAnterior) + (Gastos)), 0) AS Acumulado,
                        Saldo,
                        NoServicio,
                        DesServicio,
                        DATEFROMPARTS(@Anio, @Mes, 1),
                        ISNULL((GastoHastaMesAnterior), 0),
                        Presupuesto,
                        TS.orden,
                        R.NoRubro,
                        R.DisplayRubro
                    FROM
                        #Reporte            R
                        JOIN
                            CO_TipoServicio TS (NOLOCK)
                                ON R.Servicio = TS.ID_TIPOSER
                    ORDER BY
                        TS.Orden,
                        DisplayServicio,
                        DisplayActividad,
                        DesServicio;
        /**/
        select
            @nombrePresupuesto = nombre
        from
            co_Presupuesto (NOLOCK)
        where
            idpresupuesto = @idpresupuesto

        SELECT
            Servicio,
            Actividad,
            NoServicio,
            DisplayServicio,
            DisplayActividad,
            DesServicio,
            ISNULL(CAST(Programa AS DECIMAL(15, 2)), 0.00)                  AS Programa,
            ISNULL(CAST(GastoHastaMesAnterior AS DECIMAL(15, 2)), 0.00)     AS GastoHastaMesAnterior,
            ISNULL(CAST(Presupuesto AS DECIMAL(15, 2)), 0.00)               AS Presupuesto,
            ISNULL(CAST(Gastos AS DECIMAL(15, 2)), 0.00)                    AS Gastos,
            ISNULL(CAST(Acumulado AS DECIMAL(15, 2)), 0.00)                 AS Acumulado,
            ISNULL(CAST(Programa - Acumulado AS DECIMAL(15, 2)), 0.00)      AS Saldo,
            Fecha,
            orden,
            GNAR.IdReporteGastosNivelActividadRenglon,
            @MesAnterior                                                    AS FechaMesAnterior,
            IdRubro,
            Rubro,
            @nombrePresupuesto                                              as NombrePresupuesto,
            'Saldo Remanente ' + isnull(@nombrePresupuesto, '') + ' ($USD)' as Etiqueta1
        FROM
            TempReporteIntegracionGastosNivelActividadRenglon GNAR (NOLOCK);
        END;
