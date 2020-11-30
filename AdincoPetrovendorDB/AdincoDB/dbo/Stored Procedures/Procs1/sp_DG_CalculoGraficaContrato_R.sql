-- =============================================
-- Author:  	Reyna Olvera
-- Create date:  20/06/2017
-- Description:	Graficas
--=============================================

create PROCEDURE [dbo].[sp_DG_CalculoGraficaContrato_R] 
@IdContrato INT,
@Language   INT,
@IdUsuario  INT=0
AS
--[sp_DG_CalculoGraficaContrato_R]3,0
         BEGIN
             SET NOCOUNT ON;
             SET LANGUAGE spanish;
         END;

            DECLARE @ContratoCNH NVARCHAR(MAX);

			Delete DG_DatosGrafica where Lenguaje=@Language And IdContrato=@IdContrato	And IdGrafica IN(11,12,13,14,15,16,19);
/*
	    ====================================================================================
	    Precio WTS							IdGrafica = 1
	    ====================================================================================	    
*/
		 /*
                     INSERT INTO DG_DatosGrafica
(Titulo,
 Subtitulo,
 Titulo_yAxis,
 Titulo_xAxis,
 Fecha,
 Fecha_NuevoFormato,
 CantidadSeries,
 valueSuffix,
 SerieName0,
 SerieValues0,
 SerieType0,
 SerieColor0,
 IdGrafica ,
 Lenguaje ,
 IdContrato 
)
                            SELECT CASE @Language
                                       WHEN 1 
                                       THEN G.Titulo
                                       ELSE G.Title
                                   END AS Titulo,
                                   CASE @Language
                                       WHEN 1
                                       THEN G.Subtitulo
                                       ELSE G.Subtitle
                                   END AS Subtitulo,
                                   CASE @Language
                                       WHEN 1
                                       THEN G.Titulo_yAxis
                                       ELSE G.Title_yAxis
                                   END AS Titulo_yAxis,
                                   CASE @Language
                                       WHEN 1
                                       THEN G.Titulo_xAxis
                                       ELSE G.Title_xAxis
                                   END AS Titulo_xAxis,
                                   CONCAT(RIGHT('00'+CAST(MONTH(PMM.Mes) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(PMM.Mes)), 0, 4), ' ', SUBSTRING(CAST(YEAR(PMM.Mes) AS VARCHAR(4)), 3, 2)) AS Fecha,
								   convert(varchar, PMM.Mes, 111),
                                   1 AS CantidadSeries,
                                   'Dls' AS valueSuffix,
                                   G.Titulo AS SerieName0,
                                   PMM.Precio AS SerieValues0,
                                   'area' AS SerieType0,
                                   'blue' AS SerieColor0,
								   1,
								   @Language,
								   @IdContrato
                            FROM DG_Grafica G
                                 LEFT OUTER JOIN CO_PrecioMarcadorMensual PMM ON 1 = G.Id_Grafica
                            WHERE IdMarcador = 10000
                                  AND IdContrato = @IdContrato;

/*
	    ====================================================================================
	    Presupuesto							IdGrafica = 2
	    ====================================================================================	    
	    */
		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
		DROP TABLE #tmp

		IF OBJECT_ID('tempdb..#tmp2') IS NOT NULL
		DROP TABLE #tmp2

                     DECLARE @idpresupuesto AS INT;
                     SELECT @idpresupuesto = CO_Presupuesto.idpresupuesto
                     FROM CO_ProgramaActividad
                          INNER JOIN CO_PeriodoContrato ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
                          INNER JOIN CO_Presupuesto ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
                          INNER JOIN CO_Contrato ON CO_PeriodoContrato.IdContrato = CO_Contrato.IdContrato
                     WHERE CO_Contrato.IdContrato = @IdContrato
                           AND CO_Presupuesto.Actual = 1;
                     SELECT CASE @Language
                                WHEN 1
                                THEN CO_Presupuesto.nombre
                                ELSE CO_Presupuesto.nombre
                            END AS Titulo,
                            CASE @Language
                                WHEN 1
                                THEN DG_Grafica.Subtitulo
                                ELSE DG_Grafica.Subtitle
                            END AS Subtitulo,
                            CASE @Language
                                WHEN 1
                                THEN DG_Grafica.Titulo_yAxis
                                ELSE DG_Grafica.Title_yAxis
                            END AS Titulo_yAxis,
                            CASE @Language
                                WHEN 1
                                THEN DG_Grafica.Titulo_xAxis
                                ELSE DG_Grafica.Title_xAxis
                            END AS Titulo_xAxis,
                            CONCAT(RIGHT('00'+CAST(MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES)), 0, 4), ' ', SUBSTRING(CAST(YEAR(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(4)), 3, 2)) AS Mes_Presupuestado,
							convert(varchar, CO_LineaPresupuestoMes.AC_PRESUP_MES, 111) as fechaNuevoFormato,
                            CASE @Language
                                WHEN 1
                                THEN 'Presupuesto (USD)'
                                ELSE 'Budget (USD)'
                            END AS 'SerieName0',
                            CAST(SUM(dbo.CO_LineaPresupuestoMes.Monto) AS INT) AS 'SerieValues0',
                            CASE @Language
                                WHEN 1
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
                          LEFT OUTER JOIN DG_Grafica ON 2 = DG_Grafica.Id_Grafica
                          JOIN co_presupuesto ON CO_Presupuesto.idpresupuesto = CO_LineaPresupuestoMes.idpresupuesto
                     WHERE(dbo.CO_LineaPresupuestoMes.IdPresupuesto = @idpresupuesto) 
         
                     GROUP BY
         
                     dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES,
					 	convert(varchar, CO_LineaPresupuestoMes.AC_PRESUP_MES, 111) ,
                     CO_Presupuesto.nombre,
       
                     DG_Grafica.Title,
                     DG_Grafica.Subtitulo,
                     DG_Grafica.Subtitle,
                     DG_Grafica.Titulo_yAxis,
                     DG_Grafica.Title_yAxis,
                     DG_Grafica.Titulo_xAxis,
                     DG_Grafica.Title_xAxis
                     ORDER BY

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

                     INSERT INTO DG_DatosGrafica
(Titulo,
 Subtitulo,
 Titulo_yAxis,
 Titulo_xAxis,
 Fecha,
 Fecha_NuevoFormato,
 CantidadSeries,
 valueSuffix,
 SerieName0,
 SerieValues0,
 SerieType0,
 SerieColor0,
 SerieName1,
 SerieValues1,
 SerieType1,
 SerieColor1,
  IdGrafica,
 Lenguaje,
 IdContrato 
)
                            SELECT Titulo,
                                   Subtitulo,
                                   Titulo_yAxis,
                                   Titulo_xAxis,
                                   Mes_Presupuestado,
								   fechaNuevoFormato,
                                   2,
                                   valueSuffix,
                                   SerieName0,
                                   CAST(SerieValues0 AS INT) AS SerieValues0,
                                   'line',
                                   'blue',
                                   SerieName1,
                                   CAST(SerieValues1 AS INT) AS SerieValues1,
                                   'line',
                                   'green',
								      2,
								   @Language,
								   @IdContrato
                            FROM #tmp
                            ORDER BY AC_PRESUP_MES;

               
			  /**/
			  
	    ====================================================================================
	    Producción: Volumen contractual de petróleo				IdGrafica = 11
	    ====================================================================================	    
	    */
	

                     SELECT CASE @Language
                                WHEN 1
                                THEN G.Titulo
                                ELSE G.Title
                            END AS Titulo,
                            CASE @Language
                                WHEN 1
                                THEN G.Subtitulo
                                ELSE G.Subtitle
                            END AS Subtitulo,
                            CASE @Language
                                WHEN 1
                                THEN G.Titulo_yAxis
                                ELSE G.Title_yAxis
                            END AS Titulo_yAxis,
                            CASE @Language
                                WHEN 1
                                THEN G.Titulo_xAxis
                                ELSE G.Title_xAxis
                            END AS Titulo_xAxis,
                            CONCAT(SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2), ' ', RIGHT('00'+CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)), 0, 4)) AS Fecha,
							convert(varchar,VMPP.MesReporte, 111) as fechaNuevoFormato,
                            2 AS CantidadSeries,
                            ' Bls' AS valueSuffix,
                            CASE @Language
                                WHEN 1
                                THEN 'Mensual'
                                ELSE 'Monthly'
                            END AS SerieName0,
                            ROUND(VMPP.VolumenPetroleoPuntoMedicion, 0) AS SerieValues0,
                            'line' AS SerieType0,
                            'green' AS SerieColor0,
                            CASE @Language
                                WHEN 1
                                THEN 'Acumulado'
                                ELSE 'Accumulated'
                            END AS SerieName1,
                            ROUND(VMPP.VolumenPetroleoPuntoMedicion, 0) AS SerieValues1,
                            'line' AS SerieType1,
                            'gray' AS SerieColor1,
                            vmpp.MesReporte
                     INTO #VolumenPetroleo
                     FROM DG_Grafica G
                          LEFT OUTER JOIN PR_VolumenMensualProduccionPetroleo VMPP ON 11 = G.Id_Grafica
                     WHERE IdContrato = @IdContrato
                     ORDER BY CONCAT(SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2), ' ', RIGHT('00'+CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)), 0, 4));
		
				 --|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
				 -- Acumular
				 --|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
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
                     INSERT INTO DG_DatosGrafica
(Titulo,
 Subtitulo,
 Titulo_yAxis,
 Titulo_xAxis,
 Fecha,
  Fecha_NuevoFormato,
 CantidadSeries,
 valueSuffix,
 SerieName0,
 SerieValues0,
 SerieType0,
 SerieColor0,
 SerieName1,
 SerieValues1,
 SerieType1,
 SerieColor1,
   IdGrafica,
 Lenguaje,
 IdContrato 
)
                            SELECT Titulo,
                                   Subtitulo,
                                   Titulo_yAxis,
                                   Titulo_xAxis,
                                   Fecha,
								   fechaNuevoFormato,
                                   CantidadSeries,
                                   valueSuffix,
                                   SerieName0,
                                   SerieValues0,
                                   SerieType0,
                                   SerieColor0,
                                   SerieName1,
                                   SerieValues1,
                                   SerieType1,
                                   SerieColor1,
								      11,
								   @Language,
								   @IdContrato
                            FROM #VolumenPetroleo;

/*	    ====================================================================================
	    Producción: Gas Asociado						IdGrafica = 12
	    ====================================================================================	    
	    */
	
           
                     SELECT CASE @Language
                                WHEN 1
                                THEN G.Titulo
                                ELSE G.Title
                            END AS Titulo,
                            CASE @Language
                                WHEN 1
                                THEN G.Subtitulo
                                ELSE G.Subtitle
                            END AS Subtitulo,
                            CASE @Language
                                WHEN 1
                                THEN G.Titulo_yAxis
                                ELSE G.Title_yAxis
                            END AS Titulo_yAxis,
                            CASE @Language
                                WHEN 1
                                THEN G.Titulo_xAxis
                                ELSE G.Title_xAxis
                            END AS Titulo_xAxis,
                            CONCAT(SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2), ' ', RIGHT('00'+CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)), 0, 4)) AS Fecha,
							convert(varchar,VMPP.MesReporte, 111) as fechaNuevoFormato,
                            2 AS CantidadSeries,
                            ' MMBTU' AS valueSuffix,
                            CASE @Language
                                WHEN 1
                                THEN 'Metano C1'
                                ELSE 'Methane C1'
                            END AS SerieName0,
                            VMPP.MetanoC1 AS SerieValues0,
                            'line' AS SerieType0,
                            'blue' AS SerieColor0,
                            CASE @Language
                                WHEN 1
                                THEN 'Etano C2'
                                ELSE 'Ethane C2'
                            END AS SerieName1,
                            VMPP.EtanoC2 AS SerieValues1,
                            'line' AS SerieType1,
                            'blue' AS SerieColor1,
                            CASE @Language
                                WHEN 1
                                THEN 'Propano C3'
                                ELSE 'Propane C3'
                            END AS SerieName2,
                            VMPP.PropanoC3 AS SerieValues2,
                            'line' AS SerieType2,
                            'blue' AS SerieColor2,
                            CASE @Language
                                WHEN 1
                                THEN 'Butano C4'
                                ELSE 'Butane C4'
                            END AS SerieName3,
                            VMPP.ButanoC4 AS SerieValues3,
                            'line' AS SerieType3,
                            'blue' AS SerieColor3,
                            CASE @Language
                                WHEN 1
                                THEN 'Gas '
                                ELSE ' Gas'
                            END AS SerieName4,
                            VMPP.MetanoC1 + VMPP.EtanoC2 + VMPP.PropanoC3 + VMPP.ButanoC4 AS SerieValues4,
                            'line' AS SerieType4,
                            'blue' AS SerieColor4,
                            CASE @Language
                                WHEN 1
                                THEN 'Gas  Acumulado'
                                ELSE 'Acum.  Gas'
                            END AS SerieName5,
                            0 AS SerieValues5,
                            'line' AS SerieType5,
                            'blue' AS SerieColor5,
                            vmpp.MesReporte
                     INTO #VolumenGas
                     FROM DG_Grafica G
                          LEFT OUTER JOIN PR_VolumenMensualProduccionPetroleo VMPP ON 12 = G.Id_Grafica
                     WHERE IdContrato = @IdContrato
                     ORDER BY CONCAT(SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2), ' ', RIGHT('00'+CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)), 0, 4));
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
                     INSERT INTO DG_DatosGrafica
(Titulo,
 Subtitulo,
 Titulo_yAxis,
 Titulo_xAxis,
 Fecha,
 Fecha_NuevoFormato,
 CantidadSeries,
 valueSuffix,
 SerieName0,
 SerieValues0,
 SerieType0,
 SerieColor0,
 SerieName1,
 SerieValues1,
 SerieType1,
 SerieColor1,
 SerieName2,
 SerieValues2,
 SerieType2,
 SerieColor2,
 SerieName3,
 SerieValues3,
 SerieType3,
 SerieColor3,
 SerieName4,
 SerieValues4,
 SerieType4,
 SerieColor4,
 SerieName5,
 SerieValues5,
 SerieType5,
 SerieColor5,
  IdGrafica,
 Lenguaje,
 IdContrato 
)
                            SELECT Titulo,
                                   Subtitulo,
                                   Titulo_yAxis,
                                   Titulo_xAxis,
                                   Fecha,
								    fechaNuevoFormato,
                                   CantidadSeries,
                                   valueSuffix,
                                   SerieName5,
                                   SerieValues5,
                                   SerieType5,
                                   SerieColor5,
							 SerieName4,
                                   SerieValues4,
                                   SerieType4,
                                   SerieColor4,
                                   SerieName0,
                                   SerieValues0,
                                   SerieType0,
                                   SerieColor0,
                                   SerieName1,
                                   SerieValues1,
                                   SerieType1,
                                   SerieColor1,
                                   SerieName2,
                                   SerieValues2,
                                   SerieType2,
                                   SerieColor2,
                                   SerieName3,
                                   SerieValues3,
                                   SerieType3,
                                   SerieColor3,
								      12,
								   @Language,
								   @IdContrato
                            FROM #VolumenGas;

/*
	   ====================================================================================
	    Producción: Volumen contractual de condensado				IdGrafica = 13
	    ====================================================================================	    
	    */
		

                     SELECT CASE @Language
                                WHEN 1
                                THEN G.Titulo
                                ELSE G.Title
                            END AS Titulo,
                            CASE @Language
                                WHEN 1
                                THEN G.Subtitulo
                                ELSE G.Subtitle
                            END AS Subtitulo,
                            CASE @Language
                                WHEN 1
                                THEN G.Titulo_yAxis
                                ELSE G.Title_yAxis
                            END AS Titulo_yAxis,
                            CASE @Language
                                WHEN 1
                                THEN G.Titulo_xAxis
                                ELSE G.Title_xAxis
                            END AS Titulo_xAxis,
                            CONCAT(RIGHT('00'+CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)), 0, 4), ' ', SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2)) AS Fecha,
							convert(varchar,VMPP.MesReporte, 111) as fechaNuevoFormato,
                            2 AS CantidadSeries,
                            ' MBls' AS valueSuffix,
                            CASE @Language
                                WHEN 1
                                THEN 'Mensual'
                                ELSE 'Monthly'
                            END AS SerieName0,
                            ROUND(VMPP.VolumenCondensadoPuntoMedicion / 1000, 2) AS SerieValues0,
                            'line' AS SerieType0,
                            'gray' AS SerieColor0,
                            CASE @Language
                                WHEN 1
                                THEN 'Acumulado'
                                ELSE 'Accumulated'
                            END AS SerieName1,
                            ROUND(VMPP.VolumenCondensadoPuntoMedicion / 1000, 2) AS SerieValues1,
                            'line' AS SerieType1,
                            'green' AS SerieColor1,
                            vmpp.MesReporte
                     INTO #VolumenCondensado
                     FROM DG_Grafica G
                          LEFT OUTER JOIN PR_VolumenMensualProduccionPetroleo VMPP ON 13 = G.Id_Grafica
                     WHERE IdContrato = @IdContrato;

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

                     INSERT INTO DG_DatosGrafica
(Titulo,
 Subtitulo,
 Titulo_yAxis,
 Titulo_xAxis,
 Fecha,
Fecha_NuevoFormato,
 CantidadSeries,
 valueSuffix,
 SerieName0,
 SerieValues0,
 SerieType0,
 SerieColor0,
 SerieName1,
 SerieValues1,
 SerieType1,
 SerieColor1,
   IdGrafica,
 Lenguaje,
 IdContrato 
)
                            SELECT Titulo,
                                   Subtitulo,
                                   Titulo_yAxis,
                                   Titulo_xAxis,
                                   Fecha,
								   fechaNuevoFormato,
                                   CantidadSeries,
                                   valueSuffix,
                                   SerieName0,
                                   SerieValues0,
                                   SerieType0,
                                   SerieColor0,
                                   SerieName1,
                                   SerieValues1,
                                   SerieType1,
                                   SerieColor1,
								      13,
								   @Language,
								   @IdContrato
                            FROM #VolumenCondensado;
	  			  
/*
	   ====================================================================================
	    Producción: Volumen entrega de petroleo contratista			IdGrafica = 14
	    ====================================================================================	    
	    */
                     SELECT @ContratoCNH = NumeroContrato
                     FROM dbo.CO_Contrato
                     WHERE IdContrato = @IdContrato; 
	

                     SELECT CASE @Language
                                WHEN 1
                                THEN G.Titulo
                                ELSE G.Title
                            END AS Titulo,
                            CASE @Language
                                WHEN 1
                                THEN G.Subtitulo
                                ELSE G.Subtitle
                            END AS Subtitulo,
                            CASE @Language
                                WHEN 1
                                THEN G.Titulo_yAxis
                                ELSE G.Title_yAxis
                            END AS Titulo_yAxis,
                            CASE @Language
                                WHEN 1
                                THEN G.Titulo_xAxis
                                ELSE G.Title_xAxis
                            END AS Titulo_xAxis,
                            CONCAT(RIGHT('00'+CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, VMPP.RMPCT32_00), 0, 4), ' ', SUBSTRING(CAST(RMPCT32_01 AS VARCHAR(4)), 3, 2)) AS Fecha,
							
							concat(RMPCT32_01,'/',RIGHT('00'+CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2),'/01') as fechaNuevoFormato,
                            2 AS CantidadSeries,
                            ' MBls' AS valueSuffix,
                            CASE @Language
                                WHEN 1
                                THEN 'Preliminar'
                                ELSE 'Preliminar'
                            END AS SerieName0,
                            ROUND(VMPP.RMPCT32_28 / 1000, 2) AS SerieValues0,
                            'line' AS SerieType0,
                            'gray' AS SerieColor0,
                            CASE @Language
                                WHEN 1
                                THEN 'Final'
                                ELSE 'Final'
                            END AS SerieName1,
                            ROUND((VMPP.RMPCT32_28 + RMPCT32_40) / 1000, 2) AS SerieValues1,
                            'line' AS SerieType1,
                            'green' AS SerieColor1,
                            CASE @Language
                                WHEN 1
                                THEN 'Acumulado'
                                ELSE 'Acumulado'
                            END AS SerieName2,
                            ROUND((VMPP.RMPCT32_28 + RMPCT32_40) / 1000, 2) AS SerieValues2,
                            'line' AS SerieType2,
                            'green' AS SerieColor2,
                            DATEFROMPARTS(VMPP.RMPCT32_01, VMPP.RMPCT32_00, 1) AS MesReporte
                     INTO #VolumenEntregaPetroleo
                     FROM AA_RMP_CONT_32 VMPP
                          LEFT JOIN DG_Grafica G ON 14 = G.Id_Grafica
                     WHERE RTRIM(VMPP.RF01_01) = RTRIM(@ContratoCNH);

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

                     INSERT INTO DG_DatosGrafica
(Titulo,
 Subtitulo,
 Titulo_yAxis,
 Titulo_xAxis,
 Fecha,
 Fecha_NuevoFormato,
 CantidadSeries,
 valueSuffix,
 SerieName0,
 SerieValues0,
 SerieType0,
 SerieColor0,
 SerieName1,
 SerieValues1,
 SerieType1,
 SerieColor1,
 SerieName2,
 SerieValues2,
 SerieType2,
 SerieColor2,
   IdGrafica,
 Lenguaje,
 IdContrato 
)
                            SELECT Titulo,
                                   Subtitulo,
                                   Titulo_yAxis,
                                   Titulo_xAxis,
                                   Fecha,
								   fechaNuevoFormato,
                                   CantidadSeries,
                                   valueSuffix,
                                   SerieName0,
                                   SerieValues0,
                                   SerieType0,
                                   SerieColor0,
                                   SerieName1,
                                   SerieValues1,
                                   SerieType1,
                                   SerieColor1,
                                   SerieName2,
                                   SerieValues2,
                                   SerieType2,
                                   SerieColor2,
									14,
								   @Language,
								   @IdContrato
                            FROM #VolumenEntregaPetroleo;

             
			  			  			  
		/*
	   ====================================================================================
	    Producción: Volumen entrega de condensado contratista IdGrafica = 15
	    ====================================================================================	    
	    */
				

                     SELECT @ContratoCNH = NumeroContrato
                     FROM dbo.CO_Contrato
                     WHERE IdContrato = @IdContrato; 

                     SELECT CASE @Language
                                WHEN 1
                                THEN G.Titulo
                                ELSE G.Title
                            END AS Titulo,
                            CASE @Language
                                WHEN 1
                                THEN G.Subtitulo
                                ELSE G.Subtitle
                            END AS Subtitulo,
                            CASE @Language
                                WHEN 1
                                THEN G.Titulo_yAxis
                                ELSE G.Title_yAxis
                            END AS Titulo_yAxis,
                            CASE @Language
                                WHEN 1
                                THEN G.Titulo_xAxis
                                ELSE G.Title_xAxis
                            END AS Titulo_xAxis,
                            CONCAT(RIGHT('00'+CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, VMPP.RMPCT32_00), 0, 4), ' ', SUBSTRING(CAST(RMPCT32_01 AS VARCHAR(4)), 3, 2)) AS Fecha,
								concat(RMPCT32_01,'/',RIGHT('00'+CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2),'/01') as fechaNuevoFormato,
							
                            2 AS CantidadSeries,
                            ' MBls' AS valueSuffix,
                            CASE @Language
                                WHEN 1
                                THEN 'Preliminar'
                                ELSE 'Preliminar'
                            END AS SerieName0,
                            ROUND(VMPP.RMPCT32_33 / 1000, 2) AS SerieValues0,
                            'line' AS SerieType0,
                            'gray' AS SerieColor0,
                            CASE @Language
                                WHEN 1
                                THEN 'Final'
                                ELSE 'Final'
                            END AS SerieName1,
                            ROUND((VMPP.RMPCT32_33 + RMPCT32_45) / 1000, 2) AS SerieValues1,
                            'line' AS SerieType1,
                            'green' AS SerieColor1,
                            CASE @Language
                                WHEN 1
                                THEN 'Acumulado'
                                ELSE 'Acumulado'
                            END AS SerieName2,
                            ROUND((VMPP.RMPCT32_33 + RMPCT32_45) / 1000, 2) AS SerieValues2,
                            'line' AS SerieType2,
                            'green' AS SerieColor2,
                            DATEFROMPARTS(VMPP.RMPCT32_01, VMPP.RMPCT32_00, 1) AS MesReporte
                     INTO #VolumenEntregaCondensado
                     FROM AA_RMP_CONT_32 VMPP
                          LEFT JOIN DG_Grafica G ON 15 = G.Id_Grafica
                     WHERE RTRIM(VMPP.RF01_01) = RTRIM(@ContratoCNH);
			
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
                     INSERT INTO DG_DatosGrafica
(Titulo,
 Subtitulo,
 Titulo_yAxis,
 Titulo_xAxis,
 Fecha,
 Fecha_NuevoFormato,
 CantidadSeries,
 valueSuffix,
 SerieName0,
 SerieValues0,
 SerieType0,
 SerieColor0,
 SerieName1,
 SerieValues1,
 SerieType1,
 SerieColor1,
 SerieName2,
 SerieValues2,
 SerieType2,
 SerieColor2,
   IdGrafica,
 Lenguaje,
 IdContrato 
)
                            SELECT Titulo,
                                   Subtitulo,
                                   Titulo_yAxis,
                                   Titulo_xAxis,
                                   Fecha,
								   fechaNuevoFormato,
                                   CantidadSeries,
                                   valueSuffix,
                                   SerieName0,
                                   SerieValues0,
                                   SerieType0,
                                   SerieColor0,
                                   SerieName1,
                                   SerieValues1,
                                   SerieType1,
                                   SerieColor1,
                                   SerieName2,
                                   SerieValues2,
                                   SerieType2,
                                   SerieColor2,
								   	15,
								   @Language,
								   @IdContrato
                            FROM #VolumenEntregaCondensado;


			  			  			  
/*
	   ====================================================================================
	    Producción: Volumen entrega de condensado contratista  IdGrafica = 16
	    ====================================================================================	    
	    */
		
         
                 
                     SELECT @ContratoCNH = NumeroContrato
                     FROM dbo.CO_Contrato
                     WHERE IdContrato = @IdContrato; 


                     SELECT CASE @Language
                                WHEN 1
                                THEN G.Titulo
                                ELSE G.Title
                            END AS Titulo,
                            CASE @Language
                                WHEN 1
                                THEN G.Subtitulo
                                ELSE G.Subtitle
                            END AS Subtitulo,
                            CASE @Language
                                WHEN 1
                                THEN G.Titulo_yAxis
                                ELSE G.Title_yAxis
                            END AS Titulo_yAxis,
                            CASE @Language
                                WHEN 1
                                THEN G.Titulo_xAxis
                                ELSE G.Title_xAxis
                            END AS Titulo_xAxis,
                            CONCAT(RIGHT('00'+CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, VMPP.RMPCT32_00), 0, 4), ' ', SUBSTRING(CAST(RMPCT32_01 AS VARCHAR(4)), 3, 2)) AS Fecha,
							concat(RMPCT32_01,'/',RIGHT('00'+CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2),'/01') as fechaNuevoFormato,
							
                            2 AS CantidadSeries,
                            ' MBls' AS valueSuffix,
                            CASE @Language
                                WHEN 1
                                THEN 'Preliminar'
                                ELSE 'Preliminar'
                            END AS SerieName0,
                            ROUND(VMPP.RMPCT32_33 / 1000, 2) AS SerieValues0,
                            'line' AS SerieType0,
                            'gray' AS SerieColor0,
                            CASE @Language
                                WHEN 1
                                THEN 'Final'
                                ELSE 'Final'
                            END AS SerieName1,
                            ROUND((VMPP.RMPCT32_33 + RMPCT32_45) / 1000, 2) AS SerieValues1,
                            'line' AS SerieType1,
                            'green' AS SerieColor1,
                            CASE @Language
                                WHEN 1
                                THEN 'Acumulado'
                                ELSE 'Acumulado'
                            END AS SerieName2,
                            ROUND((VMPP.RMPCT32_33 + RMPCT32_45) / 1000, 2) AS SerieValues2,
                            'line' AS SerieType2,
                            'green' AS SerieColor2,
                            DATEFROMPARTS(VMPP.RMPCT32_01, VMPP.RMPCT32_00, 1) AS MesReporte
                     INTO #VolumenEntregaGas
                     FROM AA_RMP_CONT_32 VMPP
                          LEFT JOIN DG_Grafica G ON 16 = G.Id_Grafica
                     WHERE RTRIM(VMPP.RF01_01) = RTRIM(@ContratoCNH);
			

				 --||||||||||||||||||||||||||||||||||||||||||||
				 -- Acumular
				 --||||||||||||||||||||||||||||||||||||||||||||
                     SELECT t2.MesReporte,
                            SUM(CASE
                                    WHEN t1.MesReporte <= t2.MesReporte
                                    THEN t1.serievalues1
                                    ELSE 0
                                END) AS acumulado
                     INTO #ProduccionEntregaGas
                     FROM #VolumenEntregaGas t1
                          CROSS JOIN #VolumenEntregaGas t2
                     GROUP BY t2.MesReporte
                     ORDER BY t2.MesReporte;

				 --||||||||||||||||||||||||||||||||||||||||||||
                     UPDATE t1
                       SET
                           t1.SerieValues2 = t2.acumulado
                     FROM #VolumenEntregaGas t1
                          JOIN #ProduccionEntregaGas t2 ON t1.MesReporte = t2.MesReporte;
                     INSERT INTO DG_DatosGrafica
(Titulo,
 Subtitulo,
 Titulo_yAxis,
 Titulo_xAxis,
 Fecha,
 Fecha_NuevoFormato,
 CantidadSeries,
 valueSuffix,
 SerieName0,
 SerieValues0,
 SerieType0,
 SerieColor0,
 SerieName1,
 SerieValues1,
 SerieType1,
 SerieColor1,
 SerieName2,
 SerieValues2,
 SerieType2,
 SerieColor2,
   IdGrafica,
 Lenguaje,
 IdContrato 
)
                            SELECT Titulo,
                                   Subtitulo,
                                   Titulo_yAxis,
                                   Titulo_xAxis,
                                   Fecha,
								   fechaNuevoFormato,
                                   CantidadSeries,
                                   valueSuffix,
                                   SerieName0,
                                   SerieValues0,
                                   SerieType0,
                                   SerieColor0,
                                   SerieName1,
                                   SerieValues1,
                                   SerieType1,
                                   SerieColor1,
                                   SerieName2,
                                   SerieValues2,
                                   SerieType2,
                                   SerieColor2,
								      	16,
								   @Language,
								   @IdContrato
                            FROM #VolumenEntregaGas;

          


		/*
	    ====================================================================================
	    Precio Venta Petroleo  IdGrafica = 17
	    ====================================================================================	    
	    */
	

----                     SELECT CASE @Language
----                                WHEN 1
----                                THEN 'Precio de Venta Petroleo'
----                                ELSE 'Precio de Venta Petroleo'
----                            END AS Titulo,
----                            CASE @Language
----                                WHEN 1
----                                THEN DG_Grafica.Subtitulo
----                                ELSE DG_Grafica.Subtitle
----                            END AS Subtitulo,
----                            CASE @Language
----                                WHEN 1
----                                THEN DG_Grafica.Titulo_yAxis
----                                ELSE DG_Grafica.Title_yAxis
----                            END AS Titulo_yAxis,
----                            CASE @Language
----                                WHEN 1
----                                THEN DG_Grafica.Titulo_xAxis
----                                ELSE DG_Grafica.Title_xAxis
----                            END AS Titulo_xAxis,
----                            PA.Anio AS Mes_Presupuestado,
----							convert(varchar,PA.Anio, 111) as fechaNuevoFormato,
----                            CASE @Language
----                                WHEN 1
----                                THEN 'Plan Price (USD)'
----                                ELSE 'Plan Precio (USD)'
----                            END AS 'SerieName0',
----                            SUM(PA.PetroleoUSDBl) AS 'SerieValues0',
----                            CASE @Language
----                                WHEN 1
----                                THEN 'Real Price (USD)'
----                                ELSE 'Real Precio (USD)'
----                            END AS 'SerieName1',
----                            isnull(SUM(PA.RealPetroleoUSDBl), 0) AS 'SerieValues1',
----                            ' USD Bl' AS 'valueSuffix'
----                     INTO #tmpprecioscrudo
----                     FROM AA_PlanPrecioVentaHidrocarburoAnual PA
----                          LEFT OUTER JOIN DG_Grafica ON 17 = DG_Grafica.Id_Grafica
----                     WHERE(PA.IdContrato = @IdContrato)
----                     GROUP BY

----		-- PA,Anio,
----                     DG_Grafica.Title,
----                     DG_Grafica.Subtitulo,
----                     DG_Grafica.Subtitle,
----                     DG_Grafica.Titulo_yAxis,
----                     DG_Grafica.Title_yAxis,
----                     DG_Grafica.Titulo_xAxis,
----                     DG_Grafica.Title_xAxis,
----                     PA.Anio;
----                 --    ORDER BY-- Mes_Presupuestado;
----                     INSERT INTO DG_DatosGrafica
----(Titulo,
---- Subtitulo,
---- Titulo_yAxis,
---- Titulo_xAxis,
---- Fecha,
---- Fecha_NuevoFormato,
---- CantidadSeries,
---- valueSuffix,
---- SerieName0,
---- SerieValues0,
---- SerieType0,
---- SerieColor0,
---- SerieName1,
---- SerieValues1,
---- SerieType1,
---- SerieColor1,
----    IdGrafica,
---- Lenguaje,
---- IdContrato 
----)
----                            SELECT Titulo,
----                                   Subtitulo,
----                                   Titulo_yAxis,
----                                   Titulo_xAxis,
----                                   Mes_Presupuestado,
----								   fechaNuevoFormato,
----                                   2,
----                                   valueSuffix,
----                                   SerieName0,
----                                   SerieValues0 AS SerieValues0,
----                                   'line',
----                                   'blue',
----                                   SerieName1,
----                                   SerieValues1 AS SerieValues1,
----                                   'line',
----                                   'green',
----								    	17,
----								   @Language,
----								   @IdContrato
----                            FROM #tmpprecioscrudo;




----			/*	  ====================================================================================
----	    Precio Venta Gas  IdGrafica = 18
----	    ====================================================================================	    
----	    */

----           

----                     SELECT CASE @Language
----                                WHEN 1
----                                THEN 'Precio de Venta Gas'
----                                ELSE 'Precio de Venta Gas'
----                            END AS Titulo,
----                            CASE @Language
----                                WHEN 1
----                                THEN DG_Grafica.Subtitulo
----                                ELSE DG_Grafica.Subtitle
----                            END AS Subtitulo,
----                            CASE @Language
----                                WHEN 1
----                                THEN DG_Grafica.Titulo_yAxis
----                                ELSE DG_Grafica.Title_yAxis
----                            END AS Titulo_yAxis,
----                            CASE @Language
----                                WHEN 1
----                                THEN DG_Grafica.Titulo_xAxis
----                                ELSE DG_Grafica.Title_xAxis
----                            END AS Titulo_xAxis,
----                            PA.Anio AS Mes_Presupuestado,
----							convert(varchar,PA.Anio, 111) as fechaNuevoFormato,
----                            CASE @Language
----                                WHEN 1
----                                THEN 'Plan Price (USD)'
----                                ELSE 'Plan Precio (USD)'
----                            END AS 'SerieName0',
----                            SUM(PA.GasUSDMPc) AS 'SerieValues0',
----                            CASE @Language
----                                WHEN 1
----                                THEN 'Real Price (USD)'
----                                ELSE 'Real Precio (USD)'
----                            END AS 'SerieName1',
----                            isnull(SUM(PA.RealGasUSDMPc), 0) AS 'SerieValues1',
----                            ' USD MPc' AS 'valueSuffix'
----                     INTO #tmppreciosgas
----                     FROM AA_PlanPrecioVentaHidrocarburoAnual PA
----                          LEFT OUTER JOIN DG_Grafica ON 18 = DG_Grafica.Id_Grafica
----                     WHERE(PA.IdContrato = @IdContrato)
----                     GROUP BY

----		-- PA,Anio,
----                     DG_Grafica.Title,
----                     DG_Grafica.Subtitulo,
----                     DG_Grafica.Subtitle,
----                     DG_Grafica.Titulo_yAxis,
----                     DG_Grafica.Title_yAxis,
----                     DG_Grafica.Titulo_xAxis,
----                     DG_Grafica.Title_xAxis,
----                     PA.Anio;
----                 --    ORDER BY-- Mes_Presupuestado;
----                     INSERT INTO DG_DatosGrafica
----(Titulo,
---- Subtitulo,
---- Titulo_yAxis,
---- Titulo_xAxis,
---- Fecha,
---- Fecha_NuevoFormato,
---- CantidadSeries,
---- valueSuffix,
---- SerieName0,
---- SerieValues0,
---- SerieType0,
---- SerieColor0,
---- SerieName1,
---- SerieValues1,
---- SerieType1,
---- SerieColor1,
----     IdGrafica,
---- Lenguaje,
---- IdContrato 
----)
----                            SELECT Titulo,
----                                   Subtitulo,
----                                   Titulo_yAxis,
----                                   Titulo_xAxis,
----                                   Mes_Presupuestado,
----								   fechaNuevoFormato,
----                                   2,
----                                   valueSuffix,
----                                   SerieName0,
----                                   SerieValues0 AS SerieValues0,
----                                   'line',
----                                   'blue',
----                                   SerieName1,
----                                   SerieValues1 AS SerieValues1,
----                                   'line',
----                                   'green',
----								   18,
----								   @Language,
----								   @IdContrato
----                            FROM #tmppreciosgas;




		 /*
		====================================================================================
	    Ingresos comercializacion	IdGrafica = 19
	    ====================================================================================	    
	    */

  	IF OBJECT_ID('tempdb..#tmpIngreso') IS NOT NULL
				DROP TABLE #tmpIngreso

		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
		DROP TABLE #tmp

		IF OBJECT_ID('tempdb..#tmp2') IS NOT NULL
		DROP TABLE #tmp2
			
                     SELECT CASE @Language
                                WHEN 1
                                THEN DG_Grafica.Titulo
                                ELSE DG_Grafica.Title
                            END AS Titulo,
                            CASE @Language
                                WHEN 1
                                THEN DG_Grafica.Subtitulo
                                ELSE DG_Grafica.Subtitle
                            END AS Subtitulo,
                            CASE @Language
                                WHEN 1
                                THEN DG_Grafica.Titulo_yAxis
                                ELSE DG_Grafica.Title_yAxis
                            END AS Titulo_yAxis,
                            CASE @Language
                                WHEN 1
                                THEN DG_Grafica.Titulo_xAxis
                                ELSE DG_Grafica.Title_xAxis
                            END AS Titulo_xAxis,
                            CONCAT(SUBSTRING(CAST(YEAR(COM.FechaTransaccion) AS VARCHAR(4)), 3, 2), ' ', RIGHT('00'+CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(COM.FechaTransaccion)), 0, 4)) AS Mes_Presupuestado,
							CONCAT(SUBSTRING(CAST(YEAR(COM.FechaTransaccion) AS VARCHAR(4)), 3, 2), '/', RIGHT('00'+CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2), '/', RIGHT('00'+CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2)) as fechaNuevoFormato,
                            CASE @Language
                                WHEN 1
                                THEN 'Ingresos (USD)'
                                ELSE 'Ingresos (USD)'
                            END AS 'SerieName0',
                            SUM((com.PrecioVentaUnitario - com.CostoUnitarioComercializacion) * COM.VolumenVendido) AS 'SerieValues0',
                            CASE @Language
                                WHEN 1
                                THEN 'CGI (USD)'
                                ELSE 'CGI (USD)'
                            END AS 'SerieName1',
                            0 AS 'SerieValues1',
                            ' Dls' AS 'valueSuffix'
					  INTO #tmpIngreso
                     FROM COM_OperacionComercializacion COM
                          LEFT OUTER JOIN DG_Grafica ON 19 = DG_Grafica.Id_Grafica
                     WHERE(COM.IdContrato = @IdContrato) 
         
                     GROUP BY
         
                     CONCAT(SUBSTRING(CAST(YEAR(COM.FechaTransaccion) AS VARCHAR(4)), 3, 2), ' ', RIGHT('00'+CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(COM.FechaTransaccion)), 0, 4)),
					CONCAT(SUBSTRING(CAST(YEAR(COM.FechaTransaccion) AS VARCHAR(4)), 3, 2), '/', RIGHT('00'+CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2), '/', RIGHT('00'+CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2)),
                     DG_Grafica.Titulo,
                     DG_Grafica.Title,
                     DG_Grafica.Subtitulo,
                     DG_Grafica.Subtitle,
                     DG_Grafica.Titulo_yAxis,
                     DG_Grafica.Title_yAxis,
                     DG_Grafica.Titulo_xAxis,
                     DG_Grafica.Title_xAxis
                     ORDER BY

                     CONCAT(SUBSTRING(CAST(YEAR(COM.FechaTransaccion) AS VARCHAR(4)), 3, 2), ' ', RIGHT('00'+CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(COM.FechaTransaccion)), 0, 4));--,--Area;

                     INSERT INTO DG_DatosGrafica
(Titulo,
 Subtitulo,
 Titulo_yAxis,
 Titulo_xAxis,
 Fecha,
 Fecha_NuevoFormato,
 CantidadSeries,
 valueSuffix,
 SerieName0,
 SerieValues0,
 SerieType0,
 SerieColor0,
 SerieName1,
 SerieValues1,
 SerieType1,
 SerieColor1,
    IdGrafica,
 Lenguaje,
 IdContrato 
)
                            SELECT Titulo,
                                   Subtitulo,
                                   Titulo_yAxis,
                                   Titulo_xAxis,
                                   Mes_Presupuestado,
								   fechaNuevoFormato,
                                   2,
                                   valueSuffix,
                                   SerieName0,
                                   CAST(SerieValues0 AS INT) AS SerieValues0,
                                   'line',
                                   'blue',
                                   SerieName1,
                                   CAST(SerieValues1 AS INT) AS SerieValues1,
                                   'line',
                                   'green',
								      19,
								   @Language,
								   @IdContrato
                            FROM #tmpIngreso
                            ORDER BY Mes_Presupuestado;
				

		/*
		====================================================================================
			
	    ====================================================================================	    
	    */