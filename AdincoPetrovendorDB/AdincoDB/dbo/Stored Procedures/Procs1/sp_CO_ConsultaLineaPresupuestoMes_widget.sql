-- =============================================
-- Author:		Josue Gonzalez
-- Create date: 21 Junio 2017
-- Description:	Presupuestos
-- =============================================
-- Modificado Por:		Miguel Gomez
-- Create date: 22 Nov 2017
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaLineaPresupuestoMes_widget] @presupuesto INT,
                                                                 @IdGrafica AS   INT,
                                                                 @Language AS    INT
AS
         BEGIN
             SET NOCOUNT ON;
             SET LANGUAGE spanish;
				/*Grafica del Presupuesto Actual*/
             IF @IdGrafica = 2
                 BEGIN
                     DECLARE @idpresupuesto AS INT;
                     SELECT @idpresupuesto = CO_Presupuesto.idpresupuesto
                     FROM CO_ProgramaActividad
                          INNER JOIN CO_PeriodoContrato ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
                          INNER JOIN CO_Presupuesto ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
                          INNER JOIN CO_Contrato ON CO_PeriodoContrato.IdContrato = CO_Contrato.IdContrato
                     WHERE CO_Contrato.IdContrato = @presupuesto
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
                     FROM dbo.CO_LineaPresupuestoMes (NOLOCK)
					 JOIN co_presupuesto (NOLOCK)
						ON CO_Presupuesto.idpresupuesto = CO_LineaPresupuestoMes.idpresupuesto
					 AND dbo.CO_LineaPresupuestoMes.IdPresupuesto = @idpresupuesto
                          JOIN CO_ActividadPetroleraCNH 
							ON dbo.CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
                          JOIN CO_SubactividadPetrolera ON dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
                          JOIN CO_TareaPetrolera ON dbo.CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
                          JOIN CO_ActividadCIEP ON dbo.CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
                          JOIN CO_TipoServicio ON dbo.CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.ID_TIPOSER
                          JOIN CO_SubactividadCIEP ON dbo.CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
                          JOIN CO_Servicio ON dbo.CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                          JOIN CO_Area ON dbo.CO_LineaPresupuestoMes.IdArea = CO_Area.IdArea
                          JOIN CO_Instalacion ON dbo.CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
                          JOIN CO_Registro ON dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
                          JOIN CO_ClasificacionAnexo4 ON dbo.CO_LineaPresupuestoMes.IdAnexo4 = CO_ClasificacionAnexo4.IdAnexo4
                          JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura
                          JOIN CO_TipoCambioDiario ON CO_TipoCambioDiario.IdMoneda = FI_Factura.IdMoneda
                                                                 AND MONTH(CO_TipoCambioDiario.fecha) = MONTH(FI_Factura.fecha)
                                                                 AND YEAR(CO_TipoCambioDiario.fecha) = YEAR(FI_Factura.fecha)
                                                                 AND DAY(CO_TipoCambioDiario.fecha) = DAY(FI_Factura.fecha)
                          LEFT OUTER JOIN CO_RubroInterno ON dbo.CO_LineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno
                          LEFT OUTER JOIN DG_Grafica ON @IdGrafica = DG_Grafica.Id_Grafica
                          
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
                     SELECT Titulo,
                            Subtitulo,
                            Titulo_yAxis,
                            Titulo_xAxis,
                            Mes_Presupuestado,
                            SerieName0,
                            CAST(SerieValues0 AS INT) AS SerieValues0,
                            SerieName1,
                            CAST(SerieValues1 AS INT) AS SerieValues1,
                            valueSuffix,
                            monto
                     FROM #tmp
                     ORDER BY AC_PRESUP_MES;
                 END;
                 ELSE
				/*Grafica del OPEX*/
             IF @IdGrafica = 10
                 BEGIN
                     SELECT @idpresupuesto = CO_Presupuesto.idpresupuesto
                     FROM CO_ProgramaActividad
                          INNER JOIN CO_PeriodoContrato ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
                          INNER JOIN CO_Presupuesto ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
                          INNER JOIN CO_Contrato ON CO_PeriodoContrato.IdContrato = CO_Contrato.IdContrato
                     WHERE CO_Contrato.IdContrato = @presupuesto
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
                            CASE @Language
                                WHEN 1
                                THEN 'Plan (USD)'
                                ELSE 'Plan (USD)'
                            END AS 'SerieName0',
                            CAST(SUM(dbo.CO_LineaPresupuestoMes.Monto) AS INT) AS 'SerieValues0',
                            CASE @Language
                                WHEN 1
                                THEN 'Real (USD/Bl)'
                                ELSE 'Real (USD/Bl)'
                            END AS 'SerieName1',
                            SUM(CASE    WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
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
                     INTO #opex
                     FROM dbo.CO_LineaPresupuestoMes	(NOLOCK)
					 JOIN co_presupuesto (NOLOCK)
						ON CO_Presupuesto.idpresupuesto = CO_LineaPresupuestoMes.idpresupuesto
						AND dbo.CO_LineaPresupuestoMes.IdPresupuesto = @idpresupuesto
                          JOIN CO_ActividadPetroleraCNH ON dbo.CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
                          JOIN CO_SubactividadPetrolera ON dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
                          JOIN CO_TareaPetrolera ON dbo.CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
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


                 END;
         END;

