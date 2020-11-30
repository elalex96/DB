-- =============================================
-- Author:		Miguel Gomez
-- Create date:  2017
-- Description:	Presupuestos
-- =============================================
-- [sp_DG_InformacionBaseGrafica] 10010, 13,1

CREATE PROCEDURE [dbo].[sp_DG_InformacionBaseGrafica] @IdContrato INT,
                                                     @IdGrafica AS  INT,
                                                     @Language AS   INT
AS
         BEGIN
             SET NOCOUNT ON;
             SET LANGUAGE spanish;
             CREATE TABLE #DatosGrafica
(Titulo         NVARCHAR(MAX),
 Subtitulo      NVARCHAR(MAX),
 Titulo_yAxis   NVARCHAR(MAX),
 Titulo_xAxis   NVARCHAR(MAX),
 Fecha          NVARCHAR(MAX),
 CantidadSeries INT,
 valueSuffix    NVARCHAR(MAX),
 SerieName0     NVARCHAR(MAX),
 SerieValues0   FLOAT,
 SerieType0     NVARCHAR(MAX),
 SerieColor0    NVARCHAR(MAX),
 SerieName1     NVARCHAR(MAX),
 SerieValues1   FLOAT,
 SerieType1     NVARCHAR(MAX),
 SerieColor1    NVARCHAR(MAX),
 SerieName2     NVARCHAR(MAX),
 SerieValues2   FLOAT,
 SerieType2     NVARCHAR(MAX),
 SerieColor2    NVARCHAR(MAX),
 SerieName3     NVARCHAR(MAX),
 SerieValues3   FLOAT,
 SerieType3     NVARCHAR(MAX),
 SerieColor3    NVARCHAR(MAX),
 SerieName4     NVARCHAR(MAX),
 SerieValues4   FLOAT,
 SerieType4     NVARCHAR(MAX),
 SerieColor4    NVARCHAR(MAX),
 SerieName5     NVARCHAR(MAX),
 SerieValues5   FLOAT,
 SerieType5     NVARCHAR(MAX),
 SerieColor5    NVARCHAR(MAX),
 SerieName6     NVARCHAR(MAX),
 SerieValues6   FLOAT,
 SerieType6     NVARCHAR(MAX),
 SerieColor6    NVARCHAR(MAX),
);
         END;
             DECLARE @ContratoCNH NVARCHAR(MAX);
	    
/*
	    ====================================================================================
	    Precio WTS
	    ====================================================================================	    
	    */

             IF @IdGrafica = 1
                 BEGIN
                     INSERT INTO #DatosGrafica
(Titulo,
 Subtitulo,
 Titulo_yAxis,
 Titulo_xAxis,
 Fecha,
 CantidadSeries,
 valueSuffix,
 SerieName0,
 SerieValues0,
 SerieType0,
 SerieColor0
)
                            SELECT CASE @Language
                                       WHEN 0
                                       THEN G.Titulo
                                       ELSE G.Title
                                   END AS Titulo,
                                   CASE @Language
                                       WHEN 0
                                       THEN G.Subtitulo
                                       ELSE G.Subtitle
                                   END AS Subtitulo,
                                   CASE @Language
                                       WHEN 0
                                       THEN G.Titulo_yAxis
                                       ELSE G.Title_yAxis
                                   END AS Titulo_yAxis,
                                   CASE @Language
                                       WHEN 0
                                       THEN G.Titulo_xAxis
                                       ELSE G.Title_xAxis
                                   END AS Titulo_xAxis,
                                   CONCAT(RIGHT('00'+CAST(MONTH(PMM.Mes) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(PMM.Mes)), 0, 4), ' ', SUBSTRING(CAST(YEAR(PMM.Mes) AS VARCHAR(4)), 3, 2)) AS Fecha,
                                   1 AS CantidadSeries,
                                   'Dls' AS valueSuffix,
                                   G.Titulo AS SerieName0,
                                   PMM.Precio AS SerieValues0,
                                   'area' AS SerieType0,
                                   'blue' AS SerieColor0
                            FROM DG_Grafica G
                                 LEFT OUTER JOIN CO_PrecioMarcadorMensual PMM ON @IdGrafica = G.Id_Grafica
                            WHERE IdMarcador = 10000
                                  AND IdContrato = @IdContrato;
                 END;
                 ELSE
			  	    
/*
	    ====================================================================================
	    Presupuesto
	    ====================================================================================	    
	    */

             IF @IdGrafica = 2
                 BEGIN
                     DECLARE @idpresupuesto AS INT;
                     SELECT @idpresupuesto = CO_Presupuesto.idpresupuesto
                     FROM CO_ProgramaActividad
                          INNER JOIN CO_PeriodoContrato ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
                          INNER JOIN CO_Presupuesto ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
                          INNER JOIN CO_Contrato ON CO_PeriodoContrato.IdContrato = CO_Contrato.IdContrato
                     WHERE CO_Contrato.IdContrato = @IdContrato
                           AND CO_Presupuesto.Actual = 1;
                     SELECT CASE @Language
                                WHEN 0
                                THEN CO_Presupuesto.nombre
                                ELSE CO_Presupuesto.nombre
                            END AS Titulo,
                            CASE @Language
                                WHEN 0
                                THEN DG_Grafica.Subtitulo
                                ELSE DG_Grafica.Subtitle
                            END AS Subtitulo,
                            CASE @Language
                                WHEN 0
                                THEN DG_Grafica.Titulo_yAxis
                                ELSE DG_Grafica.Title_yAxis
                            END AS Titulo_yAxis,
                            CASE @Language
                                WHEN 0
                                THEN DG_Grafica.Titulo_xAxis
                                ELSE DG_Grafica.Title_xAxis
                            END AS Titulo_xAxis,
                            CONCAT(RIGHT('00'+CAST(MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES)), 0, 4), ' ', SUBSTRING(CAST(YEAR(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(4)), 3, 2)) AS Mes_Presupuestado,
                            CASE @Language
                                WHEN 0
                                THEN 'Presupuesto (USD)'
                                ELSE 'Budget (USD)'
                            END AS 'SerieName0',
                            CAST(SUM(dbo.CO_LineaPresupuestoMes.Monto) AS INT) AS 'SerieValues0',
                            CASE @Language
                                WHEN 0
                                THEN 'Registrado (USD)'
                                ELSE 'Registered (USD)'
                            END AS 'SerieName1',
                            SUM(CASE
                                    WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                                    THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioDiario.TipoCambio
                                    ELSE 0
                                END) AS 'SerieValues1',
                            ' Dls' AS 'valueSuffix',
                            RAND(SUM(CASE
                                         WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                                         THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioDiario.TipoCambio
                                         ELSE 0
                                     END)) AS monto,
                            dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES
                     INTO #tmp
                     FROM dbo.CO_LineaPresupuestoMes
                          LEFT OUTER JOIN CO_ActividadPetroleraCNH ON dbo.CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
                          LEFT OUTER JOIN CO_SubactividadPetrolera ON dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
                          LEFT OUTER JOIN CO_TareaPetrolera ON dbo.CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
                          LEFT OUTER JOIN CO_ActividadCIEP ON dbo.CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
                          LEFT OUTER JOIN CO_TipoServicio ON dbo.CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.ID_TIPOSER
                          LEFT OUTER JOIN CO_SubactividadCIEP ON dbo.CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
                          LEFT OUTER JOIN CO_Servicio ON dbo.CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                          LEFT OUTER JOIN CO_Area ON dbo.CO_LineaPresupuestoMes.IdArea = CO_Area.IdArea
                          LEFT OUTER JOIN CO_Instalacion ON dbo.CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
                          LEFT OUTER JOIN CO_Registro ON dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
                          LEFT OUTER JOIN CO_ClasificacionAnexo4 ON dbo.CO_LineaPresupuestoMes.IdAnexo4 = CO_ClasificacionAnexo4.IdAnexo4
                          LEFT OUTER JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura
                          LEFT OUTER JOIN CO_TipoCambioDiario ON CO_TipoCambioDiario.IdMoneda = FI_Factura.IdMoneda
                                                                 AND MONTH(CO_TipoCambioDiario.fecha) = MONTH(FI_Factura.fecha)
                                                                 AND YEAR(CO_TipoCambioDiario.fecha) = YEAR(FI_Factura.fecha)
                                                                 AND DAY(CO_TipoCambioDiario.fecha) = DAY(FI_Factura.fecha)
                          LEFT OUTER JOIN CO_RubroInterno ON dbo.CO_LineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno
                          LEFT OUTER JOIN DG_Grafica ON @IdGrafica = DG_Grafica.Id_Grafica
                          JOIN co_presupuesto ON CO_Presupuesto.idpresupuesto = CO_LineaPresupuestoMes.idpresupuesto
                     WHERE(dbo.CO_LineaPresupuestoMes.IdPresupuesto = @idpresupuesto) 
         --and MONTH ( CO_LineaPresupuestoMes.AC_FEC_INI ) = @mes 
                     GROUP BY
         -- dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
                     dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES,
                     CO_Presupuesto.nombre,
         --DG_Grafica.Titulo,
                     DG_Grafica.Title,
                     DG_Grafica.Subtitulo,
                     DG_Grafica.Subtitle,
                     DG_Grafica.Titulo_yAxis,
                     DG_Grafica.Title_yAxis,
                     DG_Grafica.Titulo_xAxis,
                     DG_Grafica.Title_xAxis
                     ORDER BY-- Mes_Presupuestado;

                     dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES;--,--Area;

                     SELECT t2.AC_PRESUP_MES,
                            SUM(CASE
                                    WHEN t1.ac_Presup_mes <= t2.ac_Presup_mes
                                    THEN t1.serievalues0
                                    ELSE 0
                                END) AS presupuesto,
                            SUM(CASE
                                    WHEN t1.ac_Presup_mes <= t2.ac_Presup_mes
                                    THEN t1.serievalues1
                                    ELSE 0
                                END) AS gasto
                     INTO #tmp2
                     FROM #tmp t1
                          CROSS JOIN #tmp t2
                     GROUP BY t2.AC_PRESUP_MES
                     ORDER BY t2.AC_PRESUP_MES;
                     UPDATE t1
                       SET
                           SerieValues0 = t2.presupuesto,
                           t1.SerieValues1 = t2.gasto
                     FROM #tmp t1
                          JOIN #tmp2 t2 ON t1.AC_PRESUP_MES = t2.AC_PRESUP_MES;
                     INSERT INTO #DatosGrafica
(Titulo,
 Subtitulo,
 Titulo_yAxis,
 Titulo_xAxis,
 Fecha,
 CantidadSeries,
 valueSuffix,
 SerieName0,
 SerieValues0,
 SerieType0,
 SerieColor0,
 SerieName1,
 SerieValues1,
 SerieType1,
 SerieColor1
)
                            SELECT Titulo,
                                   Subtitulo,
                                   Titulo_yAxis,
                                   Titulo_xAxis,
                                   Mes_Presupuestado,
                                   2,
                                   valueSuffix,
                                   SerieName0,
                                   CAST(SerieValues0 AS INT) AS SerieValues0,
                                   'line',
                                   'blue',
                                   SerieName1,
                                   CAST(SerieValues1 AS INT) AS SerieValues1,
                                   'line',
                                   'green'
                            FROM #tmp
                            ORDER BY AC_PRESUP_MES;
                 END;

			  /*
	    ====================================================================================
	    Producción: Volumen contractual de petróleo
	    ====================================================================================	    
	    */

                 ELSE
             IF @IdGrafica = 11
                 BEGIN
                     SELECT CASE @Language
                                WHEN 0
                                THEN G.Titulo
                                ELSE G.Title
                            END AS Titulo,
                            CASE @Language
                                WHEN 0
                                THEN G.Subtitulo
                                ELSE G.Subtitle
                            END AS Subtitulo,
                            CASE @Language
                                WHEN 0
                                THEN G.Titulo_yAxis
                                ELSE G.Title_yAxis
                            END AS Titulo_yAxis,
                            CASE @Language
                                WHEN 0
                                THEN G.Titulo_xAxis
                                ELSE G.Title_xAxis
                            END AS Titulo_xAxis,
                            CONCAT(RIGHT('00'+CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)), 0, 4), ' ', SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2)) AS Fecha,
                            2 AS CantidadSeries,
                            ' MBls' AS valueSuffix,
                            CASE @Language
                                WHEN 0
                                THEN 'Mensual'
                                ELSE 'Monthly'
                            END AS SerieName0,
                            ROUND(VMPP.VolumenPetroleoPuntoMedicion / 1000, 2) AS SerieValues0,
                            'line' AS SerieType0,
                            'gray' AS SerieColor0,
                            CASE @Language
                                WHEN 0
                                THEN 'Acumulado'
                                ELSE 'Accumulated'
                            END AS SerieName1,
                            ROUND(VMPP.VolumenPetroleoPuntoMedicion / 1000, 2) AS SerieValues1,
                            'line' AS SerieType1,
                            'green' AS SerieColor1,
                            vmpp.MesReporte
                     INTO #VolumenPetroleo
                     FROM DG_Grafica G
                          LEFT OUTER JOIN PR_VolumenMensualProduccionPetroleo VMPP ON @IdGrafica = G.Id_Grafica
                     WHERE IdContrato = @IdContrato;

				-- SELECT* FROM #VolumenPetroleo

				 --||||||||||||||||||||||||||||||||||||||||||||
				 -- Acumular
				 --||||||||||||||||||||||||||||||||||||||||||||
                     SELECT t2.MesReporte,
                            SUM(CASE
                                    WHEN t1.MesReporte <= t2.MesReporte
                                    THEN t1.serievalues1
                                    ELSE 0
                                END) AS acumulado
                     INTO #ProduccionPetroleo
                     FROM #VolumenPetroleo t1
                          CROSS JOIN #VolumenPetroleo t2
                     GROUP BY t2.MesReporte
                     ORDER BY t2.MesReporte;

				 --||||||||||||||||||||||||||||||||||||||||||||
                     UPDATE t1
                       SET
                           t1.SerieValues1 = t2.acumulado
                     FROM #VolumenPetroleo t1
                          JOIN #ProduccionPetroleo t2 ON t1.MesReporte = t2.MesReporte;
                     SELECT Fecha AS Mes,
                            FORMAT(SerieValues0, 'N', 'es-mx') AS [Producción (MBls)],
                            FORMAT(SerieValues1, 'N', 'es-mx') AS [Producción Acumulada (MBls)]
                     FROM #VolumenPetroleo;
                 END;

/*	    ====================================================================================
	    Producción: Gas Asociado
	    ====================================================================================	    
	    */

                 ELSE
             IF @IdGrafica = 12
                 BEGIN
                     SELECT CASE @Language
                                WHEN 0
                                THEN G.Titulo
                                ELSE G.Title
                            END AS Titulo,
                            CASE @Language
                                WHEN 0
                                THEN G.Subtitulo
                                ELSE G.Subtitle
                            END AS Subtitulo,
                            CASE @Language
                                WHEN 0
                                THEN G.Titulo_yAxis
                                ELSE G.Title_yAxis
                            END AS Titulo_yAxis,
                            CASE @Language
                                WHEN 0
                                THEN G.Titulo_xAxis
                                ELSE G.Title_xAxis
                            END AS Titulo_xAxis,
                            CONCAT(RIGHT('00'+CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)), 0, 4), ' ', SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2)) AS Fecha,
                            2 AS CantidadSeries,
                            ' MMBTU' AS valueSuffix,
                            CASE @Language
                                WHEN 0
                                THEN 'Metano C1'
                                ELSE 'Methane C1'
                            END AS SerieName0,
                            VMPP.MetanoC1 AS SerieValues0,
                            'line' AS SerieType0,
                            'blue' AS SerieColor0,
                            CASE @Language
                                WHEN 0
                                THEN 'Etano C2'
                                ELSE 'Ethane C2'
                            END AS SerieName1,
                            VMPP.EtanoC2 AS SerieValues1,
                            'line' AS SerieType1,
                            'blue' AS SerieColor1,
                            CASE @Language
                                WHEN 0
                                THEN 'Propano C3'
                                ELSE 'Propane C3'
                            END AS SerieName2,
                            VMPP.PropanoC3 AS SerieValues2,
                            'line' AS SerieType2,
                            'blue' AS SerieColor2,
                            CASE @Language
                                WHEN 0
                                THEN 'Butano C4'
                                ELSE 'Butane C4'
                            END AS SerieName3,
                            VMPP.ButanoC4 AS SerieValues3,
                            'line' AS SerieType3,
                            'blue' AS SerieColor3,
                            CASE @Language
                                WHEN 0
                                THEN 'Gas Asociado'
                                ELSE 'Asociate Gas'
                            END AS SerieName4,
                            VMPP.MetanoC1 + VMPP.EtanoC2 + VMPP.PropanoC3 + VMPP.ButanoC4 AS SerieValues4,
                            'line' AS SerieType4,
                            'blue' AS SerieColor4,
                            CASE @Language
                                WHEN 0
                                THEN 'Gas Asociado Acumulado'
                                ELSE 'Acum. Asociate Gas'
                            END AS SerieName5,
                            0 AS SerieValues5,
                            'line' AS SerieType5,
                            'blue' AS SerieColor5,
                            vmpp.MesReporte
                     INTO #VolumenGas
                     FROM DG_Grafica G
                          LEFT OUTER JOIN PR_VolumenMensualProduccionPetroleo VMPP ON @IdGrafica = G.Id_Grafica
                     WHERE IdContrato = @IdContrato;

				 --||||||||||||||||||||||||||||||||||||||||||||
				 -- Acumular
				 --||||||||||||||||||||||||||||||||||||||||||||
                     SELECT t2.MesReporte,
                            SUM(CASE
                                    WHEN t1.MesReporte <= t2.MesReporte
                                    THEN t1.serievalues4
                                    ELSE 0
                                END) AS acumulado
                     INTO #ProduccionGas
                     FROM #VolumenGas t1
                          CROSS JOIN #VolumenGas t2
                     GROUP BY t2.MesReporte
                     ORDER BY t2.MesReporte;

				 --||||||||||||||||||||||||||||||||||||||||||||
                     UPDATE t1
                       SET
                           t1.SerieValues5 = t2.acumulado
                     FROM #VolumenGas t1
                          JOIN #ProduccionGas t2 ON t1.MesReporte = t2.MesReporte;
                     SELECT Fecha AS Mes,
                            FORMAT(ROUND(SerieValues0, 2), 'N', 'es-mx') AS [Metano (MMBTU)],
                            FORMAT(ROUND(SerieValues1, 2), 'N', 'es-mx') AS [Etano (MMBTU)],
                            FORMAT(ROUND(SerieValues2, 2), 'N', 'es-mx') AS [Propano (MMBTU)],
                            FORMAT(ROUND(SerieValues3, 2), 'N', 'es-mx') AS [Butano (MMBTU)],
                            FORMAT(ROUND(SerieValues4, 2), 'N', 'es-mx') AS [Gas (MMBTU)],
                            FORMAT(ROUND(SerieValues5, 2), 'N', 'es-mx') AS [Gas Acumulado (MMBTU)]
                     FROM #VolumenGas;
                 END;
			  
			  /*
	    ====================================================================================
	    Producción: Volumen contractual de condensado
	    ====================================================================================	    
	    */

                 ELSE
             IF @IdGrafica = 13
                 BEGIN
                     SELECT CASE @Language
                                WHEN 0
                                THEN G.Titulo
                                ELSE G.Title
                            END AS Titulo,
                            CASE @Language
                                WHEN 0
                                THEN G.Subtitulo
                                ELSE G.Subtitle
                            END AS Subtitulo,
                            CASE @Language
                                WHEN 0
                                THEN G.Titulo_yAxis
                                ELSE G.Title_yAxis
                            END AS Titulo_yAxis,
                            CASE @Language
                                WHEN 0
                                THEN G.Titulo_xAxis
                                ELSE G.Title_xAxis
                            END AS Titulo_xAxis,
                            CONCAT(RIGHT('00'+CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)), 0, 4), ' ', SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2)) AS Fecha,
                            2 AS CantidadSeries,
                            ' MBls' AS valueSuffix,
                            CASE @Language
                                WHEN 0
                                THEN 'Mensual'
                                ELSE 'Monthly'
                            END AS SerieName0,
                            ROUND(VMPP.VolumenCondensadoPuntoMedicion / 1000, 2) AS SerieValues0,
                            'line' AS SerieType0,
                            'gray' AS SerieColor0,
                            CASE @Language
                                WHEN 0
                                THEN 'Acumulado'
                                ELSE 'Accumulated'
                            END AS SerieName1,
                            ROUND(VMPP.VolumenCondensadoPuntoMedicion / 1000, 2) AS SerieValues1,
                            'line' AS SerieType1,
                            'green' AS SerieColor1,
                            vmpp.MesReporte
                     INTO #VolumenCondensado
                     FROM DG_Grafica G
                          LEFT OUTER JOIN PR_VolumenMensualProduccionPetroleo VMPP ON @IdGrafica = G.Id_Grafica
                     WHERE IdContrato = @IdContrato;

				-- SELECT* FROM #VolumenPetroleo

				 --||||||||||||||||||||||||||||||||||||||||||||
				 -- Acumular
				 --||||||||||||||||||||||||||||||||||||||||||||
                     SELECT t2.MesReporte,
                            SUM(CASE
                                    WHEN t1.MesReporte <= t2.MesReporte
                                    THEN t1.serievalues1
                                    ELSE 0
                                END) AS acumulado
                     INTO #ProduccionCondensado
                     FROM #VolumenCondensado t1
                          CROSS JOIN #VolumenCondensado t2
                     GROUP BY t2.MesReporte
                     ORDER BY t2.MesReporte;

				 --||||||||||||||||||||||||||||||||||||||||||||
                     UPDATE t1
                       SET
                           t1.SerieValues1 = t2.acumulado
                     FROM #VolumenCondensado t1
                          JOIN #ProduccionCondensado t2 ON t1.MesReporte = t2.MesReporte;
                     SELECT Fecha AS Mes,
                            FORMAT(SerieValues0, 'N', 'es-mx') AS [Producción (MBls)],
                            FORMAT(SerieValues1, 'N', 'es-mx') AS [Producción Acumulada (MBls)]
                     FROM #VolumenCondensado;
                 END


				 		  			  
/*
	   ====================================================================================
	    Producción: Volumen entrega de petroleo contratista
	    ====================================================================================	    
	    */

                     ;
                 ELSE
             IF @IdGrafica = 14
                 BEGIN
                     SELECT @ContratoCNH = NumeroContrato
                     FROM dbo.CO_Contrato
                     WHERE IdContrato = @IdContrato; 

				
			  --AA_RMP_CONT_32
     --                SELECT RMPCT32_28 AS Peliminar,
				 --RMPCT32_28 + RMPCT32_40 AS Final
     --                FROM AA_RMP_CONT_32
     --                WHERE RF01_01 = @ContratoCNH;






                     SELECT CASE @Language
                                WHEN 0
                                THEN G.Titulo
                                ELSE G.Title
                            END AS Titulo,
                            CASE @Language
                                WHEN 0
                                THEN G.Subtitulo
                                ELSE G.Subtitle
                            END AS Subtitulo,
                            CASE @Language
                                WHEN 0
                                THEN G.Titulo_yAxis
                                ELSE G.Title_yAxis
                            END AS Titulo_yAxis,
                            CASE @Language
                                WHEN 0
                                THEN G.Titulo_xAxis
                                ELSE G.Title_xAxis
                            END AS Titulo_xAxis,
                            CONCAT(RIGHT('00'+CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, VMPP.RMPCT32_00), 0, 4), ' ', SUBSTRING(CAST(RMPCT32_01 AS VARCHAR(4)), 3, 2)) AS Fecha,
                            2 AS CantidadSeries,
                            ' MBls' AS valueSuffix,
                            CASE @Language
                                WHEN 0
                                THEN 'Preliminar'
                                ELSE 'Preliminar'
                            END AS SerieName0,
                            ROUND(VMPP.RMPCT32_28 / 1000, 2) AS SerieValues0,
                            'line' AS SerieType0,
                            'gray' AS SerieColor0,
                            CASE @Language
                                WHEN 0
                                THEN 'Final'
                                ELSE 'Final'
                            END AS SerieName1,
                            ROUND((VMPP.RMPCT32_28 + RMPCT32_40) / 1000, 2) AS SerieValues1,
                            'line' AS SerieType1,
                            'green' AS SerieColor1,
                            CASE @Language
                                WHEN 0
                                THEN 'Acumulado'
                                ELSE 'Acumulado'
                            END AS SerieName2,
                            ROUND((VMPP.RMPCT32_28 + RMPCT32_40) / 1000, 2) AS SerieValues2,
                            'line' AS SerieType2,
                            'green' AS SerieColor2,
                            DATEFROMPARTS(VMPP.RMPCT32_01, VMPP.RMPCT32_00, 1) AS MesReporte
                     INTO #VolumenEntregaPetroleo
                     FROM AA_RMP_CONT_32 VMPP
                          LEFT JOIN DG_Grafica G ON @IdGrafica = G.Id_Grafica
                     WHERE RTRIM(VMPP.RF01_01) = RTRIM(@ContratoCNH);--AND 
				 -- g.Id_Grafica= 14

				-- SELECT* FROM #VolumenEntregaPetroleo

				 --||||||||||||||||||||||||||||||||||||||||||||
				 -- Acumular
				 --||||||||||||||||||||||||||||||||||||||||||||
                     SELECT t2.MesReporte,
                            SUM(CASE
                                    WHEN t1.MesReporte <= t2.MesReporte
                                    THEN t1.serievalues1
                                    ELSE 0
                                END) AS acumulado
                     INTO #ProduccionEntregaPetroleo
                     FROM #VolumenEntregaPetroleo t1
                          CROSS JOIN #VolumenEntregaPetroleo t2
                     GROUP BY t2.MesReporte
                     ORDER BY t2.MesReporte;

				 --||||||||||||||||||||||||||||||||||||||||||||
                     UPDATE t1
                       SET
                           t1.SerieValues2 = t2.acumulado
                     FROM #VolumenEntregaPetroleo t1
                          JOIN #ProduccionEntregaPetroleo t2 ON t1.MesReporte = t2.MesReporte;
                     SELECT Fecha AS Mes,
                            FORMAT(SerieValues0, 'N', 'es-mx') AS [Preliminar (MBls)],
                            FORMAT(SerieValues1, 'N', 'es-mx') AS [Final (MBls)],
                            FORMAT(SerieValues2, 'N', 'es-mx') AS [Final Acumulada (MBls)]
                     FROM #VolumenEntregaPetroleo;
                 END;

			  
			  			  			  
/*
	   ====================================================================================
	    Producción: Volumen entrega de condensado contratista
	    ====================================================================================	    
	    */

                 ELSE
             IF @IdGrafica = 16
                 BEGIN
                     --DECLARE @ContratoCNH NVARCHAR(MAX);
                     SELECT @ContratoCNH = NumeroContrato
                     FROM dbo.CO_Contrato
                     WHERE IdContrato = @IdContrato; 

				
			  --AA_RMP_CONT_32
     --                SELECT RMPCT32_28 AS Peliminar,
				 --RMPCT32_28 + RMPCT32_40 AS Final
     --                FROM AA_RMP_CONT_32
     --                WHERE RF01_01 = @ContratoCNH;






                     SELECT CASE @Language
                                WHEN 0
                                THEN G.Titulo
                                ELSE G.Title
                            END AS Titulo,
                            CASE @Language
                                WHEN 0
                                THEN G.Subtitulo
                                ELSE G.Subtitle
                            END AS Subtitulo,
                            CASE @Language
                                WHEN 0
                                THEN G.Titulo_yAxis
                                ELSE G.Title_yAxis
                            END AS Titulo_yAxis,
                            CASE @Language
                                WHEN 0
                                THEN G.Titulo_xAxis
                                ELSE G.Title_xAxis
                            END AS Titulo_xAxis,
                            CONCAT(RIGHT('00'+CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, VMPP.RMPCT32_00), 0, 4), ' ', SUBSTRING(CAST(RMPCT32_01 AS VARCHAR(4)), 3, 2)) AS Fecha,
                            2 AS CantidadSeries,
                            ' MBls' AS valueSuffix,
                            CASE @Language
                                WHEN 0
                                THEN 'Preliminar'
                                ELSE 'Preliminar'
                            END AS SerieName0,
                            ROUND(VMPP.RMPCT32_33 / 1000, 2) AS SerieValues0,
                            'line' AS SerieType0,
                            'gray' AS SerieColor0,
                            CASE @Language
                                WHEN 0
                                THEN 'Final'
                                ELSE 'Final'
                            END AS SerieName1,
                            ROUND((VMPP.RMPCT32_33 + RMPCT32_45) / 1000, 2) AS SerieValues1,
                            'line' AS SerieType1,
                            'green' AS SerieColor1,
                            CASE @Language
                                WHEN 0
                                THEN 'Acumulado'
                                ELSE 'Acumulado'
                            END AS SerieName2,
                            ROUND((VMPP.RMPCT32_33 + RMPCT32_45) / 1000, 2) AS SerieValues2,
                            'line' AS SerieType2,
                            'green' AS SerieColor2,
                            DATEFROMPARTS(VMPP.RMPCT32_01, VMPP.RMPCT32_00, 1) AS MesReporte
                     INTO #VolumenEntregaCondensado
                     FROM AA_RMP_CONT_32 VMPP
                          LEFT JOIN DG_Grafica G ON @IdGrafica = G.Id_Grafica
                     WHERE RTRIM(VMPP.RF01_01) = RTRIM(@ContratoCNH);--AND 
				 -- g.Id_Grafica= 14

				-- SELECT* FROM #VolumenEntregaPetroleo

				 --||||||||||||||||||||||||||||||||||||||||||||
				 -- Acumular
				 --||||||||||||||||||||||||||||||||||||||||||||
                     SELECT t2.MesReporte,
                            SUM(CASE
                                    WHEN t1.MesReporte <= t2.MesReporte
                                    THEN t1.serievalues1
                                    ELSE 0
                                END) AS acumulado
                     INTO #ProduccionEntregaCondensado
                     FROM #VolumenEntregaCondensado t1
                          CROSS JOIN #VolumenEntregaCondensado t2
                     GROUP BY t2.MesReporte
                     ORDER BY t2.MesReporte;

				 --||||||||||||||||||||||||||||||||||||||||||||
                     UPDATE t1
                       SET
                           t1.SerieValues2 = t2.acumulado
                     FROM #VolumenEntregaCondensado t1
                          JOIN #ProduccionEntregaCondensado t2 ON t1.MesReporte = t2.MesReporte;
                      SELECT Fecha AS Mes,
                            FORMAT(SerieValues0, 'N', 'es-mx') AS [Preliminar (MBls)],
                            FORMAT(SerieValues1, 'N', 'es-mx') AS [Final (MBls)],
                            FORMAT(SerieValues2, 'N', 'es-mx') AS [Final Acumulada (MBls)]
                     FROM #VolumenEntregaCondensado;
                 END;