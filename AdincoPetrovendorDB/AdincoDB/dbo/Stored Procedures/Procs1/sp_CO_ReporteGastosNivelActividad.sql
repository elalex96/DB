USE [Adinco]
GO

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
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
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
            (
                Servicio  INT,
                Actividad INT,
                Gastos    MONEY
            );
        CREATE TABLE #Gastos
            (
                Servicio  INT,
                Actividad INT,
                Gastos    MONEY
            );
        CREATE TABLE #Acumulado
            (
                Servicio  INT,
                Actividad INT,
                Gastos    MONEY
            );
        CREATE TABLE #AcumuladoHastaMesAnterior
            (
                Servicio  INT,
                Actividad INT,
                Gastos    MONEY
            );
        CREATE TABLE #Presupuesto
            (
                Servicio  INT,
                Actividad INT,
                Gastos    MONEY
            );

        DECLARE @MesActual datetime = DATEFROMPARTS(@Anio, @MesGE, 1);
        DECLARE @MesAnterior datetime = DATEADD(MONTH, -1, @MesActual);
        /**/
        INSERT INTO #Reporte(  Servicio,Actividad,DisplayServicio,DisplayActividad,Programa,GastoHastaMesAnterior,
                Presupuesto,Gastos,Acumulado,Saldo,orden)
                    SELECT
                        CO_ServicioActividad.IdTipoServicio,
                        CO_ServicioActividad.IdActividad,
                        '' AS Expr1,
                        '' AS Expr2,
                        0  AS Expr3,
                        0  AS Expr4,
                        0  AS Expr5,
                        0  AS Expr6,
                        0  AS Expr7,
                        0  AS Expr8,
                        0  AS Expr9
                    FROM
                        CO_ServicioActividad;
        /**/
        INSERT INTO #Programa (Servicio  ,Actividad ,Gastos)
                    SELECT
                        CO_LineaPresupuestoMes.IdTipoServicio,
                        CO_LineaPresupuestoMes.IdActividad,
                        SUM(ISNULL(CO_LineaPresupuestoMes.Monto, 0)) AS Gasto
                    FROM
                        CO_LineaPresupuestoMes
                    WHERE
                        CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto 
                    GROUP BY
                        CO_LineaPresupuestoMes.IdTipoServicio,
                        CO_LineaPresupuestoMes.IdActividad;
        /**/
        INSERT INTO #Presupuesto(Servicio,Actividad,Gastos)
                    SELECT
                        L.IdTipoServicio,
                        L.IdActividad,
                        SUM(ISNULL(L.Monto, 0)) AS Gasto
                    FROM
                        CO_LineaPresupuestoMes L
                        JOIN
                            CO_ActividadCIEP   A
                                ON A.IdActividad = L.IDActividad
                        JOIN
                            CO_TipoServicio    S
                                ON L.IdTipoServicio = S.IdTipoServicio
                    WHERE
                        L.IdPresupuesto = @IdPresupuesto
                        AND MONTH(L.[AC_PRESUP_MES]) = @MesGE
                        AND YEAR(L.[AC_PRESUP_MES]) = @Anio
                    GROUP BY
                        L.IdTipoServicio,
                        L.IdActividad;

        INSERT INTO #Gastos
                    SELECT
                        CO_LineaPresupuestoMes.IdTipoServicio,
                        CO_LineaPresupuestoMes.IdActividad,
                        SUM(   CASE
                                   WHEN 
										CO_Registro.CvTipoDocFacturacion = 1 AND ISNULL(ISNULL(CO_Registro.MontoRegistro, RM.MontoGasto), 0) <> 0
                                       THEN 
											(CASE
												WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%' OR FI_Factura.TipoComprobante LIKE 'E%'
												THEN 
													ISNULL((ABS(ISNULL((ISNULL(ABS(CO_Registro.MontoRegistro), ABS(RM.MontoGasto)) + ISNULL(ABS(rm.MontoEquivalente), 0) ), 0))*-1),0)
												ELSE	
													ISNULL((ISNULL(CO_Registro.MontoRegistro, RM.MontoGasto) + ISNULL(rm.MontoEquivalente, 0) ), 0) 
												END)
											/ ISNULL(RM.TipoCambio, CO_TipoCambioMensual.TipoCambio)
                                   WHEN 
									CO_Registro.CvTipoDocFacturacion IN (2, 3) AND ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                                       THEN 
										ISNULL(RM.MontoGasto + rm.MontoEquivalente, 0)/ ISNULL(RM.TipoCambio, TCDPC.TipoCambio)
                                   ELSE
                                       0
                               END
                           ) AS Gastos
                    FROM
                        CO_LineaPresupuestoMes
                        LEFT JOIN
                            CO_Registro
                                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                        LEFT JOIN
                            CO_Servicio
                                ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                        LEFT JOIN
                            FI_Factura
                                ON FI_Factura.IdFactura = CO_Registro.IdFactura
                        LEFT JOIN
                            CO_TipoCambioMensual
                                ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda
                                   AND CO_TipoCambioMensual.IdMes = MONTH(FI_Factura.Fecha)
                                   AND CO_TipoCambioMensual.Anio = YEAR(FI_Factura.Fecha)
                        LEFT OUTER JOIN
                            dbo.FI_PedimentoComprobante AS PC
                                ON PC.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
                        LEFT OUTER JOIN
                            dbo.CO_TipoCambioMensual    AS TCDPC
                                ON TCDPC.IdMoneda = PC.IdMoneda
                                   AND TCDPC.Anio = YEAR(PC.FechaPago)
                                   AND TCDPC.IdMes = MONTH(PC.FechaPago)
                        LEFT JOIN
                            CO_RegistroMarkup           RM
                                ON RM.GastoId = CO_Registro.IdRegistro
                    WHERE
                        (
                            MONTH(CO_Registro.MesPresentacion) = @MesGE
                            AND (YEAR(CO_Registro.MesPresentacion) = @Anio)
                        )
                        AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
                    GROUP BY
                        CO_LineaPresupuestoMes.IdTipoServicio,
                        CO_LineaPresupuestoMes.IdActividad;
        /**/
        -- gasto aculumado mes anterior  
        INSERT INTO #AcumuladoHastaMesAnterior
                    SELECT
                        CO_LineaPresupuestoMes.IdTipoServicio,
                        CO_LineaPresupuestoMes.IdActividad,
                        SUM(   CASE
                                   WHEN CO_Registro.CvTipoDocFacturacion = 1
                                        AND ISNULL(ISNULL(CO_Registro.MontoRegistro, RM.MontoGasto), 0) <> 0
                                       THEN 
											(CASE
												WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%' OR FI_Factura.TipoComprobante LIKE 'E%'
												THEN 
													ISNULL((ABS(ISNULL((ISNULL(ABS(CO_Registro.MontoRegistro), ABS(RM.MontoGasto)) + ISNULL(ABS(rm.MontoEquivalente), 0) ), 0))*-1),0)
												ELSE	
													ISNULL((ISNULL(CO_Registro.MontoRegistro, RM.MontoGasto) + ISNULL(rm.MontoEquivalente, 0) ), 0) 
												END)
											/ ISNULL(RM.TipoCambio, CO_TipoCambioMensual.TipoCambio) 
                                   WHEN CO_Registro.CvTipoDocFacturacion IN (
                                                                                2, 3
                                                                            )
                                        AND ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                                       THEN ISNULL(RM.MontoGasto + rm.MontoEquivalente, 0)
                                            / ISNULL(RM.TipoCambio, TCDPC.TipoCambio)
                                   ELSE
                                       0
                               END
                           ) AS Gastos
                    FROM
                        CO_LineaPresupuestoMes
                        LEFT JOIN
                            CO_Registro
                                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                        LEFT JOIN
                            CO_Servicio
                                ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                        LEFT JOIN
                            FI_Factura
                                ON FI_Factura.IdFactura = CO_Registro.IdFactura
                        LEFT JOIN
                            CO_TipoCambioMensual
                                ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda
                                   AND CO_TipoCambioMensual.IdMes = MONTH(FI_Factura.Fecha)
                                   AND CO_TipoCambioMensual.Anio = YEAR(FI_Factura.Fecha)
                        LEFT OUTER JOIN
                            dbo.FI_PedimentoComprobante AS PC
                                ON PC.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
                        LEFT OUTER JOIN
                            dbo.CO_TipoCambioMensual    AS TCDPC
                                ON TCDPC.IdMoneda = PC.IdMoneda
                                   AND TCDPC.Anio = YEAR(PC.FechaPago)
                                   AND TCDPC.IdMes = MONTH(PC.FechaPago)
                        LEFT JOIN
                            CO_RegistroMarkup           RM
                                ON RM.GastoId = CO_Registro.IdRegistro
                    WHERE
                        (
                            MONTH(CO_Registro.MesPresentacion) <= MONTH(@MesAnterior)
                            AND (YEAR(CO_Registro.MesPresentacion) = YEAR(@MesAnterior))
                            AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
                        )
                    GROUP BY
                        CO_LineaPresupuestoMes.IdTipoServicio,
                        CO_LineaPresupuestoMes.IdActividad;

        UPDATE
            #Reporte
        SET
            Programa = #Programa.Gastos
        FROM
            #Programa
        WHERE
            #Reporte.Actividad = #Programa.Actividad
            AND #Reporte.Servicio = #Programa.Servicio;
        --  
        UPDATE
            #Reporte
        SET
            Gastos = #Gastos.Gastos
        FROM
            #Gastos
        WHERE
            #Reporte.Actividad = #Gastos.Actividad
            AND #Reporte.Servicio = #Gastos.Servicio;

        UPDATE
            #Reporte
        SET
            GastoHastaMesAnterior = #AcumuladoHastaMesAnterior.Gastos
        FROM
            #AcumuladoHastaMesAnterior
        WHERE
            #Reporte.Actividad = #AcumuladoHastaMesAnterior.Actividad
            AND #Reporte.Servicio = #AcumuladoHastaMesAnterior.Servicio
        --  
        UPDATE
            #Reporte
        SET
            Presupuesto = #Presupuesto.Gastos
        FROM
            #Presupuesto
        WHERE
            #Reporte.Actividad = #Presupuesto.Actividad
            AND #Reporte.Servicio = #Presupuesto.Servicio;
        --  
        UPDATE
            #Reporte
        SET
            DisplayServicio = CO_TipoServicio.NombreTipoServicio
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
            orden = CO_ServicioActividad.Orden
        FROM
            CO_ServicioActividad
        WHERE
            CO_ServicioActividad.IdTipoServicio = #Reporte.Servicio
            AND CO_ServicioActividad.IdActividad = #Reporte.Actividad;
        --  
        UPDATE
            #Reporte
        SET
            Saldo = 0;

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
                    SELECT
                        Servicio,
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
                    FROM
                        #Reporte                R
                        JOIN
                            dbo.CO_TipoServicio TS
                                ON R.Servicio = TS.ID_TIPOSER
                    ORDER BY
                        TS.Orden;
        /**/
        declare @NombrePresupuesto nvarchar(600)
        select
            @NombrePresupuesto = nombre
        from
            co_presupuesto
        where
            idPresupuesto = @IdPresupuesto

        SELECT
            Servicio,
            Actividad,
            DisplayServicio,
            DisplayActividad,
            Programa,
            GastoHastaMesAnterior,
            Presupuesto,
            Gastos,
            Acumulado,
            Programa - Acumulado                                                            AS Saldo,
            Fecha,
            Orden,
            RGNA.IdReporteGastosNivelActividad,
            @MesAnterior                                                                    AS FechaMesAnterior,
            'PRESUPUESTO ' + UPPER(ISNULL(@NombrePresupuesto, '')) + ' AREA CONTRACTUAL'    as NombrePresupuesto,
            'Reporte de Integración  de Gastos Elegibles ' + ISNULL(@NombrePresupuesto, '') as Etiqueta1
        FROM
            TempReporteGastosNivelActividad RGNA;
			
			END;  
GO


