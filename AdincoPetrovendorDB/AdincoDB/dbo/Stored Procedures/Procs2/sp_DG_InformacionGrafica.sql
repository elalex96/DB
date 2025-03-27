IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'sp_DG_InformacionGrafica'
    )
    DROP PROCEDURE sp_DG_InformacionGrafica;
GO
-- =============================================  
-- Author:  Miguel Gomez  
-- Create date:  2017  
-- Description: Presupuestos  
-- =============================================
-- Author:  Reyna olvera  
-- Create date:  20221118  
-- Description: Creación de tablas temporales, se agregan is nulls  
-- =============================================
CREATE PROCEDURE [dbo].[sp_DG_InformacionGrafica]
    @IdContrato   INT,
    @IdGrafica AS INT,
    @Language AS  INT
AS
    BEGIN
        SET NOCOUNT ON;
        SET LANGUAGE spanish;
        CREATE TABLE #DatosGrafica
            (
                Titulo         VARCHAR(5000),
                Subtitulo      VARCHAR(5000),
                Titulo_yAxis   VARCHAR(5000),
                Titulo_xAxis   VARCHAR(5000),
                Fecha          VARCHAR(5000),
                CantidadSeries INT,
                valueSuffix    VARCHAR(5000),
                SerieName0     VARCHAR(5000),
                SerieValues0   FLOAT,
                SerieType0     VARCHAR(5000),
                SerieColor0    VARCHAR(5000),
                SerieName1     VARCHAR(5000),
                SerieValues1   FLOAT,
                SerieType1     VARCHAR(5000),
                SerieColor1    VARCHAR(5000),
                SerieName2     VARCHAR(5000),
                SerieValues2   FLOAT,
                SerieType2     VARCHAR(5000),
                SerieColor2    VARCHAR(5000),
                SerieName3     VARCHAR(5000),
                SerieValues3   FLOAT,
                SerieType3     VARCHAR(5000),
                SerieColor3    VARCHAR(5000),
                SerieName4     VARCHAR(5000),
                SerieValues4   FLOAT,
                SerieType4     VARCHAR(5000),
                SerieColor4    VARCHAR(5000),
                SerieName5     VARCHAR(5000),
                SerieValues5   FLOAT,
                SerieType5     VARCHAR(5000),
                SerieColor5    VARCHAR(5000),
                SerieName6     VARCHAR(5000),
                SerieValues6   FLOAT,
                SerieType6     VARCHAR(5000),
                SerieColor6    VARCHAR(5000),
            );
        CREATE TABLE #tmp
            (
                Titulo            VARCHAR(5000),
                Subtitulo         VARCHAR(5000),
                Titulo_yAxis      VARCHAR(5000),
                Titulo_xAxis      VARCHAR(5000),
                Mes_Presupuestado VARCHAR(5000),
                SerieName0        VARCHAR(5000),
                SerieValues0      DECIMAL(20,6),
                SerieName1        VARCHAR(5000),
                SerieValues1      DECIMAL(20,6),
                valueSuffix       VARCHAR(5000),
                monto             DECIMAL(20,6),
                AC_PRESUP_MES     DATE
            );
        CREATE TABLE #tmp2
            (
                AC_PRESUP_MES DATE,
                presupuesto   FLOAT,
                gasto         FLOAT
            );
        CREATE TABLE #VolumenPetroleo
            (
                Titulo         VARCHAR(5000),
                Subtitulo      VARCHAR(5000),
                Titulo_yAxis   VARCHAR(5000),
                Titulo_xAxis   VARCHAR(5000),
                Fecha          VARCHAR(5000),
                CantidadSeries INT,
                valueSuffix    VARCHAR(5000),
                SerieName0     VARCHAR(5000),
                SerieValues0   FLOAT,
                SerieType0     VARCHAR(5000),
                SerieColor0    VARCHAR(5000),
                SerieName1     VARCHAR(5000),
                SerieValues1   FLOAT,
                SerieType1     VARCHAR(5000),
                SerieColor1    VARCHAR(5000),
                MesReporte     DATE
            );
        CREATE TABLE #ProduccionPetroleo
            (
                MesReporte DATE,
                acumulado  FLOAT
            );
        CREATE TABLE #VolumenGas
            (
                Titulo      VARCHAR(5000),
                Subtitulo      VARCHAR(5000),
                Titulo_yAxis   VARCHAR(5000),
                Titulo_xAxis   VARCHAR(5000),
                Fecha          VARCHAR(5000),
                CantidadSeries INT,
                valueSuffix    VARCHAR(5000),
                SerieName0     VARCHAR(5000),
                SerieValues0   FLOAT,
                SerieType0     VARCHAR(5000),
                SerieColor0    VARCHAR(5000),
                SerieName1     VARCHAR(5000),
                SerieValues1   FLOAT,
                SerieType1     VARCHAR(5000),
                SerieColor1    VARCHAR(5000),
                SerieName2     VARCHAR(5000),
                SerieValues2   FLOAT,
                SerieType2     VARCHAR(5000),
                SerieColor2    VARCHAR(5000),
                SerieName3     VARCHAR(5000),
                SerieValues3   FLOAT,
                SerieType3     VARCHAR(5000),
                SerieColor3    VARCHAR(5000),
                SerieName4     VARCHAR(5000),
                SerieValues4   FLOAT,
                SerieType4     VARCHAR(5000),
                SerieColor4    VARCHAR(5000),
                SerieName5     VARCHAR(5000),
                SerieValues5   FLOAT,
                SerieType5     VARCHAR(5000),
                SerieColor5    VARCHAR(5000),
                MesReporte     DATE
            );
        CREATE TABLE #ProduccionGas
            (
                MesReporte DATE,
                acumulado  FLOAT
            );
        CREATE TABLE #VolumenCondensado
            (
                Titulo         VARCHAR(5000),
                Subtitulo      VARCHAR(5000),
                Titulo_yAxis   VARCHAR(5000),
                Titulo_xAxis   VARCHAR(5000),
                Fecha          VARCHAR(5000),
                CantidadSeries INT,
                valueSuffix    VARCHAR(5000),
                SerieName0     VARCHAR(5000),
                SerieValues0   FLOAT,
                SerieType0     VARCHAR(5000),
                SerieColor0    VARCHAR(5000),
                SerieName1     VARCHAR(5000),
                SerieValues1   FLOAT,
                SerieType1     VARCHAR(5000),
                SerieColor1    VARCHAR(5000),
                MesReporte     DATE
            );
        CREATE TABLE #ProduccionCondensado
            (
                MesReporte DATE,
                acumulado  FLOAT
            );
        CREATE TABLE #VolumenEntregaPetroleo
            (
                Titulo         VARCHAR(5000),
                Subtitulo      VARCHAR(5000),
                Titulo_yAxis   VARCHAR(5000),
                Titulo_xAxis   VARCHAR(5000),
                Fecha          VARCHAR(5000),
                CantidadSeries INT,
                valueSuffix    VARCHAR(5000),
                SerieName0     VARCHAR(5000),
                SerieValues0   FLOAT,
                SerieType0     VARCHAR(5000),
                SerieColor0    VARCHAR(5000),
                SerieName1     VARCHAR(5000),
                SerieValues1   FLOAT,
                SerieType1     VARCHAR(5000),
                SerieColor1    VARCHAR(5000),
                SerieName2     VARCHAR(5000),
                SerieValues2   FLOAT,
                SerieType2     VARCHAR(5000),
                SerieColor2    VARCHAR(5000),
                MesReporte     DATE
            );
        CREATE TABLE #ProduccionEntregaPetroleo
            (
                MesReporte DATE,
                acumulado  FLOAT
            );
        CREATE TABLE #VolumenEntregaCondensado
            (
                Titulo         VARCHAR(5000),
                Subtitulo      VARCHAR(5000),
                Titulo_yAxis   VARCHAR(5000),
                Titulo_xAxis   VARCHAR(5000),
                Fecha          VARCHAR(5000),
                CantidadSeries INT,
                valueSuffix    VARCHAR(5000),
            SerieName0     VARCHAR(5000),
                SerieValues0   FLOAT,
                SerieType0     VARCHAR(5000),
                SerieColor0    VARCHAR(5000),
                SerieName1     VARCHAR(5000),
                SerieValues1   FLOAT,
                SerieType1     VARCHAR(5000),
                SerieColor1    VARCHAR(5000),
                SerieName2     VARCHAR(5000),
                SerieValues2   FLOAT,
                SerieType2     VARCHAR(5000),
                SerieColor2    VARCHAR(5000),
                MesReporte     DATE
            );
        CREATE TABLE #ProduccionEntregaCondensado
            (
                MesReporte DATE,
                acumulado  FLOAT
            );
        CREATE TABLE #VolumenEntregaGas
            (
                Titulo         VARCHAR(5000),
                Subtitulo      VARCHAR(5000),
                Titulo_yAxis   VARCHAR(5000),
                Titulo_xAxis   VARCHAR(5000),
                Fecha          VARCHAR(5000),
                CantidadSeries INT,
                valueSuffix    VARCHAR(5000),
                SerieName0     VARCHAR(5000),
                SerieValues0   FLOAT,
                SerieType0     VARCHAR(5000),
                SerieColor0    VARCHAR(5000),
                SerieName1     VARCHAR(5000),
                SerieValues1   FLOAT,
                SerieType1     VARCHAR(5000),
                SerieColor1    VARCHAR(5000),
                SerieName2     VARCHAR(5000),
                SerieValues2   FLOAT,
                SerieType2     VARCHAR(5000),
                SerieColor2    VARCHAR(5000),
                MesReporte     DATE
            );
        CREATE TABLE #ProduccionEntregaGas
            (
                MesReporte DATE,
                acumulado  FLOAT
            );
        CREATE TABLE #tmpprecioscrudo
            (
                Titulo            VARCHAR(5000),
                Subtitulo         VARCHAR(5000),
                Titulo_yAxis      VARCHAR(5000),
                Titulo_xAxis      VARCHAR(5000),
                Mes_Presupuestado INT,
                SerieName0        VARCHAR(5000),
                SerieValues0      FLOAT,
                SerieName1        VARCHAR(5000),
                SerieValues1      FLOAT,
                valueSuffix       VARCHAR(5000)
            );
        CREATE TABLE #tmppreciosgas
            (
                Titulo            VARCHAR(5000),
                Subtitulo         VARCHAR(5000),
                Titulo_yAxis      VARCHAR(5000),
                Titulo_xAxis      VARCHAR(5000),
                Mes_Presupuestado INT,
                SerieName0        VARCHAR(5000),
                SerieValues0      FLOAT,
                SerieName1        VARCHAR(5000),
                SerieValues1      FLOAT,
                valueSuffix       VARCHAR(5000)
            );
        CREATE TABLE #tmpIngreso
            (
                Titulo            VARCHAR(5000),
                Subtitulo         VARCHAR(5000),
                Titulo_yAxis      VARCHAR(5000),
                Titulo_xAxis      VARCHAR(5000),
                Mes_Presupuestado VARCHAR(5000),
                SerieName0        VARCHAR(5000),
                SerieValues0      FLOAT,
                SerieName1        VARCHAR(5000),
                SerieValues1      FLOAT,
                valueSuffix       VARCHAR(5000)
            );
        CREATE TABLE #tmpEgreso
            (
                Monto             FLOAT,
                Mes_Presupuestado VARCHAR(5000)
            );

        DECLARE @ContratoCNH VARCHAR(5000), 
		@idpresupuesto AS INT,
		@CO_PresupuestoNombre VARCHAR(300);

        /*  
     ====================================================================================  
     Precio WTS  
     ====================================================================================       
     */

        IF @IdGrafica = 1
BEGIN
                INSERT INTO #DatosGrafica
                    (
                        Titulo,
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
                            SELECT
                                CASE @Language
                                    WHEN 0
                                        THEN G.Titulo
                                    ELSE
                                        G.Title
                                END        AS Titulo,
                                CASE @Language
                                    WHEN 0
                                        THEN G.Subtitulo
                                    ELSE
                                        G.Subtitle
                                END        AS Subtitulo,
                                CASE @Language
                                    WHEN 0
                                        THEN G.Titulo_yAxis
                                    ELSE
                                        G.Title_yAxis
                                END        AS Titulo_yAxis,
                                CASE @Language
                                    WHEN 0
                                        THEN G.Titulo_xAxis
                                    ELSE
                                        G.Title_xAxis
                                END        AS Titulo_xAxis,
                                CONCAT(
                                          RIGHT('00' + CAST(MONTH(PMM.Mes) AS VARCHAR(2)), 2), ' ',
                                          SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(PMM.Mes)), 0, 4), ' ',
                                          SUBSTRING(CAST(YEAR(PMM.Mes) AS VARCHAR(4)), 3, 2)
                                      )    AS Fecha,
                                1          AS CantidadSeries,
                                'Dls'      AS valueSuffix,
                                G.Titulo   AS SerieName0,
                                PMM.Precio AS SerieValues0,
                                'area'     AS SerieType0,
                                'blue'     AS SerieColor0
                            FROM
                                DG_Grafica                   G (NOLOCK)
                                LEFT OUTER JOIN
                                    CO_PrecioMarcadorMensual PMM (NOLOCK)
                                        ON @IdGrafica = G.Id_Grafica
                            WHERE
                                IdMarcador = 10000
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

                SELECT
                    @idpresupuesto = CO_Presupuesto.idpresupuesto,
					@CO_PresupuestoNombre = nombre
                FROM
					CO_PeriodoContrato (NOLOCK)
				INNER JOIN
                    CO_ProgramaActividad (NOLOCK)
					ON CO_PeriodoContrato.IdPeriodo	=	CO_ProgramaActividad.IdPeriodoContrato 
						AND CO_PeriodoContrato.IdContrato	= @IdContrato
                    INNER JOIN
                        CO_Presupuesto (NOLOCK)
                            ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
                               AND CO_Presupuesto.Actual = 1
							   
                WHERE
                    CO_PeriodoContrato.IdContrato = @IdContrato
                    AND CO_Presupuesto.Actual = 1;


                INSERT INTO #tmp
                    (
                        Titulo,
                        Subtitulo,
                        Titulo_yAxis,
                        Titulo_xAxis,
                        Mes_Presupuestado,
                        SerieName0,
                        SerieValues0,
                        SerieName1,
                        SerieValues1,
                        valueSuffix,
                        monto,
                        AC_PRESUP_MES
                    )
                            SELECT
                              CASE @Language
                                    WHEN 0
                                        THEN @CO_PresupuestoNombre
                                    ELSE
                                        @CO_PresupuestoNombre
                                END                                                AS Titulo,
                                CASE @Language
                                    WHEN 0
                                        THEN DG_Grafica.Subtitulo
                                    ELSE
                                        DG_Grafica.Subtitle
                                END                                                AS Subtitulo,
                                CASE @Language
                                    WHEN 0
                                        THEN DG_Grafica.Titulo_yAxis
                                    ELSE
                                        DG_Grafica.Title_yAxis
                                END                                                AS Titulo_yAxis,
                                CASE @Language
                                    WHEN 0
                                        THEN DG_Grafica.Titulo_xAxis
                                    ELSE
                                        DG_Grafica.Title_xAxis
                                END                                                AS Titulo_xAxis,
                                CONCAT(
                                          RIGHT('00'
                                                + CAST(MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2),
                                          ' ',
                                          SUBSTRING(
                                                       dbo.Fn_ObtenerNombreMes(
                                                                                  @Language,
                                                                                  MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES)
                                                                              ), 0, 4
                                                   ), ' ',
                                          SUBSTRING(
                                                       CAST(YEAR(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(4)),
                                                       3, 2
                                                   )
                                      )                                            AS Mes_Presupuestado,
                                CASE @Language
                                    WHEN 0
                                        THEN 'Presupuesto (USD)'
                                    ELSE
                                        'Budget (USD)'
                                END                                                AS 'SerieName0',
                                CAST(SUM(ISNULL(dbo.CO_LineaPresupuestoMes.Monto,0)) AS bigint) AS 'SerieValues0',
                                CASE @Language
                                    WHEN 0
                                        THEN 'Registrado (USD)'
                                    ELSE
                                        'Registered (USD)'
                                END                                                AS 'SerieName1',
                                SUM(   CASE
                                           WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0	AND  ISNULL(CO_TipoCambioDiario.TipoCambio,0)<>0
                                               THEN ISNULL(CO_Registro.MontoRegistro, 0)
                                                    /  ISNULL(CO_TipoCambioDiario.TipoCambio,0)
                                           ELSE
                                               0
                                       END
                                   )                                               AS 'SerieValues1',
                                ' Dls'                                             AS 'valueSuffix',
                                RAND(SUM(   CASE
                                                WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0	AND  ISNULL(CO_TipoCambioDiario.TipoCambio,0)<>0
                                                    THEN ISNULL(CO_Registro.MontoRegistro, 0)
                                                         / ISNULL(CO_TipoCambioDiario.TipoCambio,0)
                                                ELSE
                                                    0
                                            END
                                        )
                                    )                                              AS monto,
                                dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES
                            FROM
                                dbo.CO_LineaPresupuestoMes (NOLOCK)
                           
								JOIN
                                    CO_Servicio (NOLOCK)
                                        ON dbo.CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
										AND dbo.CO_LineaPresupuestoMes.IdPresupuesto = @idpresupuesto
                                LEFT  JOIN
                                    CO_Registro (NOLOCK)
                                        ON dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
                                LEFT  JOIN
                                    FI_Factura (NOLOCK)
                                        ON CO_Registro.IdFactura	=	 FI_Factura.IdFactura
                                LEFT OUTER JOIN
                                    CO_TipoCambioDiario (NOLOCK)
                                        ON CO_TipoCambioDiario.IdMoneda = FI_Factura.IdMoneda
                                           AND MONTH(CO_TipoCambioDiario.fecha) = MONTH(FI_Factura.fecha)
                                           AND YEAR(CO_TipoCambioDiario.fecha) = YEAR(FI_Factura.fecha)
                                           AND DAY(CO_TipoCambioDiario.fecha) = DAY(FI_Factura.fecha)
                             
                                LEFT OUTER JOIN
                                    DG_Grafica (NOLOCK)
                                        ON @IdGrafica = DG_Grafica.Id_Grafica
                            WHERE
                                (dbo.CO_LineaPresupuestoMes.IdPresupuesto = @idpresupuesto)
                            GROUP BY
                                dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES,
                                DG_Grafica.Title,
                                DG_Grafica.Subtitulo,
                                DG_Grafica.Subtitle,
                                DG_Grafica.Titulo_yAxis,
                                DG_Grafica.Title_yAxis,
                                DG_Grafica.Titulo_xAxis,
                                DG_Grafica.Title_xAxis
                            ORDER BY
                                dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES;

                INSERT INTO #tmp2
                    (
                        AC_PRESUP_MES,
                        presupuesto,
                        gasto
                    )
                            SELECT
                                t2.AC_PRESUP_MES,
                                SUM(   CASE
                                           WHEN t1.ac_Presup_mes <= t2.ac_Presup_mes
                                               THEN t1.serievalues0
                                           ELSE
                                               0
                                       END
                                   ) AS presupuesto,
                                SUM(   CASE
                                           WHEN t1.ac_Presup_mes <= t2.ac_Presup_mes
                                               THEN t1.serievalues1
                                           ELSE
                                               0
                                       END
                                   ) AS gasto
                            FROM
                                #tmp            t1
                                CROSS JOIN #tmp t2
                            GROUP BY
                                t2.AC_PRESUP_MES
                            ORDER BY
                                t2.AC_PRESUP_MES;

                UPDATE
                    t1
                SET
                    SerieValues0 = ISNULL(t2.presupuesto, 0),
                  t1.SerieValues1 = ISNULL(t2.gasto, 0)
                FROM
                    #tmp      t1
                    JOIN
                        #tmp2 t2
                            ON t1.AC_PRESUP_MES = t2.AC_PRESUP_MES;

                INSERT INTO #DatosGrafica
                    (
                        Titulo,
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
                            SELECT
                                Titulo,
                                Subtitulo,
                                Titulo_yAxis,
                                Titulo_xAxis,
                                Mes_Presupuestado,
                                2,
                                valueSuffix,
                                SerieName0,
                                CAST(SerieValues0 AS bigint) AS SerieValues0,
                                'line',
                                'blue',
                                SerieName1,
                                CAST(SerieValues1 AS bigint) AS SerieValues1,
                                'line',
                                'green'
                            FROM
                                #tmp
                            ORDER BY
                                AC_PRESUP_MES;
            END;

        /*  
     ====================================================================================  
     Producción: Volumen contractual de petróleo  
     ====================================================================================       
     */

        ELSE IF @IdGrafica = 11
                 BEGIN
                     INSERT INTO #VolumenPetroleo
                         (
                             Titulo,
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
                             SerieColor1,
                             MesReporte
                         )
                                 SELECT
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo
                                         ELSE
                                             G.Title
                                     END                                         AS Titulo,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Subtitulo
                                         ELSE
                                             G.Subtitle
                                     END                                         AS Subtitulo,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo_yAxis
                                         ELSE
                                             G.Title_yAxis
       END                                         AS Titulo_yAxis,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo_xAxis
                                         ELSE
                                             G.Title_xAxis
                                     END                                         AS Titulo_xAxis,
                                     CONCAT(
                                               SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2), ' ',
                                               RIGHT('00' + CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2), ' ',
                                               SUBSTRING(
                                                            dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)),
                                                            0, 4
                                                        )
                                           )                                     AS Fecha,
                                     2                                           AS CantidadSeries,
                                     ' Bls'                                      AS valueSuffix,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Mensual'
                                         ELSE
                                             'Monthly'
                                     END                                         AS SerieName0,
                                     ROUND(VMPP.VolumenPetroleoPuntoMedicion, 0) AS SerieValues0,
                                     'line'                                      AS SerieType0,
                                     'green'                                     AS SerieColor0,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Acumulado'
                                         ELSE
                                             'Accumulated'
                                     END                                         AS SerieName1,
                                     ROUND(VMPP.VolumenPetroleoPuntoMedicion, 0) AS SerieValues1,
                                     'line'                                      AS SerieType1,
                                     'gray'                                      AS SerieColor1,
                                     vmpp.MesReporte
                                 FROM
                                     DG_Grafica                              G (NOLOCK)
                                 LEFT OUTER JOIN
										PR_VolumenMensualProduccionPetroleo VMPP (NOLOCK)
											ON	G.Id_Grafica	=	@IdGrafica
											AND	IdContrato = @IdContrato
                                 WHERE
                                     IdContrato = @IdContrato
                                 ORDER BY
                                     CONCAT(
                                               SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2), ' ',
                                               RIGHT('00' + CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2), ' ',
                                               SUBSTRING(
                                                            dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)),
                                                            0, 4
                                                        )
                                           );
                     --||||||||||||||||||||||||||||||||||||||||||||  
                     -- Acumular  
                     --||||||||||||||||||||||||||||||||||||||||||||  
     INSERT INTO #ProduccionPetroleo
                         (
                             MesReporte,
                             acumulado
                         )
                                 SELECT
                                     t2.MesReporte,
                                     SUM(   CASE
                                                WHEN t1.MesReporte <= t2.MesReporte
                                                    THEN t1.serievalues1
                                                ELSE
                                                    0
                                            END
                                        ) AS acumulado
                                 FROM
                                     #VolumenPetroleo            t1
                                     CROSS JOIN #VolumenPetroleo t2
                                 GROUP BY
                                     t2.MesReporte
                                 ORDER BY
                                     t2.MesReporte;

                     --||||||||||||||||||||||||||||||||||||||||||||  
                     UPDATE
                         t1
                     SET
                         t1.SerieValues1 = ISNULL(t2.acumulado, 0)
                     FROM
                         #VolumenPetroleo        t1
                         JOIN
                             #ProduccionPetroleo t2
                                 ON t1.MesReporte = t2.MesReporte;

                     INSERT INTO #DatosGrafica
                         (
                             Titulo,
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
                                 SELECT
                                     Titulo,
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
                                 FROM
                                     #VolumenPetroleo;
                 END;

        /*     ====================================================================================  
     Producción: Gas Asociado  
     ====================================================================================       
     */

        ELSE IF @IdGrafica = 12
                 BEGIN

                     INSERT INTO #VolumenGas
                         (
                             Titulo,
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
                             MesReporte
                         )
                                 SELECT
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo
                                         ELSE
                                             G.Title
                                     END                                                           AS Titulo,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Subtitulo
                                         ELSE
                                             G.Subtitle
                                     END                                                           AS Subtitulo,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo_yAxis
                                         ELSE
                                             G.Title_yAxis
                                     END                                                           AS Titulo_yAxis,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo_xAxis
                                         ELSE
                                             G.Title_xAxis
                                     END                                                           AS Titulo_xAxis,
                                     CONCAT(
                                               SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2), ' ',
                                               RIGHT('00' + CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2), ' ',
                                               SUBSTRING(
                                                            dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)),
                                                            0, 4
                                                        )
                                           )                                                       AS Fecha,
                                     2                                                             AS CantidadSeries,
                                     ' MMBTU'                                                      AS valueSuffix,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Metano C1'
                                         ELSE
                                             'Methane C1'
                                     END                                                           AS SerieName0,
                                     VMPP.MetanoC1                                                 AS SerieValues0,
                                     'line'                                               AS SerieType0,
                                     'blue'                                                        AS SerieColor0,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Etano C2'
                                         ELSE
                                             'Ethane C2'
                                     END                                                           AS SerieName1,
                                     VMPP.EtanoC2                                                  AS SerieValues1,
                                     'line'                                                        AS SerieType1,
                                     'blue'                                                        AS SerieColor1,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Propano C3'
                                         ELSE
                                             'Propane C3'
                                     END                                                           AS SerieName2,
                                     VMPP.PropanoC3                                                AS SerieValues2,
                                     'line'                                                        AS SerieType2,
                                     'blue'                                                        AS SerieColor2,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Butano C4'
                                         ELSE
                                             'Butane C4'
                                     END                                                           AS SerieName3,
                                     VMPP.ButanoC4                                                 AS SerieValues3,
                                     'line'                                                        AS SerieType3,
                                     'blue'                                                        AS SerieColor3,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Gas '
                                         ELSE
                                             ' Gas'
                                     END                                                           AS SerieName4,
                                     VMPP.MetanoC1 + VMPP.EtanoC2 + VMPP.PropanoC3 + VMPP.ButanoC4 AS SerieValues4,
                                     'line'                                                        AS SerieType4,
                                     'blue'                                                        AS SerieColor4,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Gas  Acumulado'
                                         ELSE
                                             'Acum.  Gas'
                                     END                                                           AS SerieName5,
                                     0                                                             AS SerieValues5,
                                     'line'                                                        AS SerieType5,
                                     'blue'                                                        AS SerieColor5,
                                     vmpp.MesReporte
                                 FROM
                                     DG_Grafica           G (NOLOCK)
                                     LEFT OUTER JOIN
                                         PR_VolumenMensualProduccionPetroleo VMPP
                                             ON	G.Id_Grafica	=	@IdGrafica
											 AND  VMPP.IdContrato = @IdContrato
                                 WHERE
                                     IdContrato = @IdContrato
                                 ORDER BY
                                     CONCAT(
                                               SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2), ' ',
                                               RIGHT('00' + CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2), ' ',
                                               SUBSTRING(
                                                            dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)),
                                                            0, 4
                                                        )
                                           );
                     --||||||||||||||||||||||||||||||||||||||||||||  
                     -- Acumular  
                     --||||||||||||||||||||||||||||||||||||||||||||  
                     INSERT INTO #ProduccionGas
                         (
                             MesReporte,
                             acumulado
                         )
                                 SELECT
                                     t2.MesReporte,
                                     SUM(   CASE
                                                WHEN t1.MesReporte <= t2.MesReporte
                                                    THEN t1.serievalues4
                                                ELSE
                                                    0
                                            END
                                        ) AS acumulado
                                 FROM
                                     #VolumenGas            t1
                                     CROSS JOIN #VolumenGas t2
                                 GROUP BY
                                     t2.MesReporte
                                 ORDER BY
                                     t2.MesReporte;

                     --||||||||||||||||||||||||||||||||||||||||||||  
                     UPDATE
                         t1
                     SET
                         t1.SerieValues5 = ISNULL(t2.acumulado, 0)
                     FROM
                         #VolumenGas        t1
                         JOIN
                             #ProduccionGas t2
                                 ON t1.MesReporte = t2.MesReporte;

                     INSERT INTO #DatosGrafica
                         (
                             Titulo,
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
                             SerieColor5
                         )
                                 SELECT
                                     Titulo,
                                     Subtitulo,
                                     Titulo_yAxis,
                                     Titulo_xAxis,
                                     Fecha,
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
                                     SerieColor3
                                 FROM
                                     #VolumenGas;
                 END;

        /*  
    ====================================================================================  
     Producción: Volumen contractual de condensado  
     ====================================================================================       
     */

        ELSE IF @IdGrafica = 13
                 BEGIN

                     INSERT INTO #VolumenCondensado
                         (
                             Titulo,
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
                             SerieColor1,
                             MesReporte
                         )
                                 SELECT
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo
                                         ELSE
                                             G.Title
                                     END                                                  AS Titulo,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Subtitulo
                                         ELSE
                                             G.Subtitle
                                     END                                                  AS Subtitulo,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo_yAxis
                                         ELSE
                                             G.Title_yAxis
                                     END                                                  AS Titulo_yAxis,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo_xAxis
                                         ELSE
                                             G.Title_xAxis
                                     END                                                  AS Titulo_xAxis,
                                     CONCAT(
                                               RIGHT('00' + CAST(MONTH(VMPP.MesReporte) AS VARCHAR(2)), 2), ' ',
                                               SUBSTRING(
                                                            dbo.Fn_ObtenerNombreMes(@Language, MONTH(VMPP.MesReporte)),
                                                            0, 4
                                                        ), ' ',
                                               SUBSTRING(CAST(YEAR(VMPP.MesReporte) AS VARCHAR(4)), 3, 2)
                                           )                                              AS Fecha,
                                     2                                                    AS CantidadSeries,
                                     ' MBls'                                              AS valueSuffix,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Mensual'
                                         ELSE
                                             'Monthly'
                                     END                                                  AS SerieName0,
                                     ROUND(VMPP.VolumenCondensadoPuntoMedicion / 1000, 2) AS SerieValues0,
                                     'line'                                               AS SerieType0,
                                     'gray'                                               AS SerieColor0,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Acumulado'
                                         ELSE
                                             'Accumulated'
                                     END                                                  AS SerieName1,
                                     ROUND(VMPP.VolumenCondensadoPuntoMedicion / 1000, 2) AS SerieValues1,
                                     'line'                                               AS SerieType1,
                                     'green'                                              AS SerieColor1,
                                     vmpp.MesReporte
                                 FROM
                                     DG_Grafica                              G (NOLOCK)
                                     LEFT OUTER JOIN
                                         PR_VolumenMensualProduccionPetroleo VMPP
                                             ON @IdGrafica = G.Id_Grafica
											 AND VMPP.IdContrato = @IdContrato
                                 WHERE
                                     IdContrato = @IdContrato;

                     --||||||||||||||||||||||||||||||||||||||||||||  
                     -- Acumular  
                     --||||||||||||||||||||||||||||||||||||||||||||
                     INSERT INTO #ProduccionCondensado
                         (
                             MesReporte,
                             acumulado
                         )
                                 SELECT
                                     t2.MesReporte,
                                     SUM(   CASE
                                                WHEN t1.MesReporte <= t2.MesReporte
                                                    THEN t1.serievalues1
      ELSE
                                                    0
                                            END
                                        ) AS acumulado
                                 FROM
                                     #VolumenCondensado            t1
                                     CROSS JOIN #VolumenCondensado t2
                                 GROUP BY
                                     t2.MesReporte
                                 ORDER BY
                                     t2.MesReporte;

                     --||||||||||||||||||||||||||||||||||||||||||||  
                     UPDATE
                         t1
                     SET
                         t1.SerieValues1 = ISNULL(t2.acumulado, 0)
                     FROM
                         #VolumenCondensado        t1
                         JOIN
                             #ProduccionCondensado t2
                                 ON t1.MesReporte = t2.MesReporte;

                     INSERT INTO #DatosGrafica
                         (
                             Titulo,
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
                                 SELECT
                                     Titulo,
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
                                 FROM
                                     #VolumenCondensado;
                 END;


        /*  
    ====================================================================================  
     Producción: Volumen entrega de petroleo contratista  
     ====================================================================================       
     */

        ELSE IF @IdGrafica = 14
                 BEGIN

                     SELECT
                         @ContratoCNH = NumeroContrato
                     FROM
                         dbo.CO_Contrato
                     WHERE
                         IdContrato = @IdContrato;

                     INSERT INTO #VolumenEntregaPetroleo
                         (
                             Titulo,
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
                             SerieColor1,
                             SerieName2,
                          SerieValues2,
                             SerieType2,
                             SerieColor2,
                             MesReporte
                         )
                                 SELECT
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo
                                         ELSE
                                             G.Title
                                     END                                                AS Titulo,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Subtitulo
                                         ELSE
                                             G.Subtitle
                                     END                                                AS Subtitulo,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo_yAxis
                                         ELSE
                                             G.Title_yAxis
                                     END                                                AS Titulo_yAxis,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo_xAxis
                                         ELSE
                                             G.Title_xAxis
                                     END                                                AS Titulo_xAxis,
                                     CONCAT(
                                               RIGHT('00' + CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2), ' ',
                                               SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, VMPP.RMPCT32_00), 0, 4),
                                               ' ', SUBSTRING(CAST(RMPCT32_01 AS VARCHAR(4)), 3, 2)
                                           )                                            AS Fecha,
                                     2                                                  AS CantidadSeries,
                                     ' MBls'                                            AS valueSuffix,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Preliminar'
                                         ELSE
                                             'Preliminar'
                                     END                                                AS SerieName0,
                                     ROUND(VMPP.RMPCT32_28 / 1000, 2)                   AS SerieValues0,
                                     'line'                                             AS SerieType0,
                                     'gray'                                             AS SerieColor0,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Final'
                                         ELSE
                                             'Final'
                                     END                                                AS SerieName1,
                                     ROUND((VMPP.RMPCT32_28 + RMPCT32_40) / 1000, 2)    AS SerieValues1,
                                     'line'                                             AS SerieType1,
                                     'green'                                            AS SerieColor1,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Acumulado'
                                         ELSE
                                             'Acumulado'
                                     END                                                AS SerieName2,
                                     ROUND((VMPP.RMPCT32_28 + RMPCT32_40) / 1000, 2)    AS SerieValues2,
                                     'line'                                             AS SerieType2,
                                     'green'                                            AS SerieColor2,
                                     DATEFROMPARTS(VMPP.RMPCT32_01, VMPP.RMPCT32_00, 1) AS MesReporte
                                 FROM
                                     AA_RMP_CONT_32 VMPP (NOLOCK)
                                     LEFT JOIN
                                         DG_Grafica G
                                             ON @IdGrafica = G.Id_Grafica
											 AND  RTRIM(VMPP.RF01_01) = RTRIM(@ContratoCNH)
                                 WHERE
                                     RTRIM(VMPP.RF01_01) = RTRIM(@ContratoCNH);

                     --||||||||||||||||||||||||||||||||||||||||||||  
                     -- Acumular  
                     --||||||||||||||||||||||||||||||||||||||||||||  
                     INSERT INTO #ProduccionEntregaPetroleo
                         (
                             MesReporte,
                             acumulado
                         )
                                 SELECT
                                     t2.MesReporte,
                                     SUM(   CASE
                                                WHEN t1.MesReporte <= t2.MesReporte
                                                    THEN t1.serievalues1
                                                ELSE
                                                    0
                                            END
                                        ) AS acumulado
                                 FROM
                                     #VolumenEntregaPetroleo            t1
                                     CROSS JOIN #VolumenEntregaPetroleo t2
                                 GROUP BY
                                     t2.MesReporte
                                 ORDER BY
                                     t2.MesReporte;

                     --||||||||||||||||||||||||||||||||||||||||||||  
                     UPDATE
                         t1
                     SET
                         t1.SerieValues2 = ISNULL(t2.acumulado, 0)
                     FROM
                         #VolumenEntregaPetroleo        t1
                         JOIN
                             #ProduccionEntregaPetroleo t2
                                 ON t1.MesReporte = t2.MesReporte;

                     INSERT INTO #DatosGrafica
                         (
                             Titulo,
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
                             SerieColor1,
                             SerieName2,
                             SerieValues2,
                             SerieType2,
                             SerieColor2
                         )
                                 SELECT
                                     Titulo,
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
                                     SerieColor1,
                                     SerieName2,
                                     SerieValues2,
                                     SerieType2,
                                     SerieColor2
                                 FROM
                                     #VolumenEntregaPetroleo;
                 END;

        /*  
    ====================================================================================  
     Producción: Volumen entrega de condensado contratista  
     ====================================================================================       
     */

        ELSE IF @IdGrafica = 15
                 BEGIN
                     SELECT
                         @ContratoCNH = NumeroContrato
                     FROM
                         dbo.CO_Contrato
                     WHERE
                         IdContrato = @IdContrato;

                     INSERT INTO #VolumenEntregaCondensado
                         (
                             Titulo,
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
                             SerieColor1,
                             SerieName2,
                             SerieValues2,
                             SerieType2,
                             SerieColor2,
                             MesReporte
                         )
                                 SELECT
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo
                                         ELSE
                                             G.Title
                                     END                                                AS Titulo,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Subtitulo
                                         ELSE
                                             G.Subtitle
                                     END                                                AS Subtitulo,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo_yAxis
                                         ELSE
                                             G.Title_yAxis
                                     END                                                AS Titulo_yAxis,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo_xAxis
                                         ELSE
                                             G.Title_xAxis
                                     END                                                AS Titulo_xAxis,
                                     CONCAT(
                                               RIGHT('00' + CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2), ' ',
                                          SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, VMPP.RMPCT32_00), 0, 4),
                                               ' ', SUBSTRING(CAST(RMPCT32_01 AS VARCHAR(4)), 3, 2)
                                           )                                            AS Fecha,
                                     2                                                  AS CantidadSeries,
                                     ' MBls'                                            AS valueSuffix,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Preliminar'
                                         ELSE
                                             'Preliminar'
                                     END                                                AS SerieName0,
                                     ROUND(VMPP.RMPCT32_33 / 1000, 2)                   AS SerieValues0,
                                     'line'                                             AS SerieType0,
                                     'gray'                                             AS SerieColor0,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Final'
                                         ELSE
                                             'Final'
                                     END                                                AS SerieName1,
                                     ROUND((VMPP.RMPCT32_33 + RMPCT32_45) / 1000, 2)    AS SerieValues1,
                                     'line'                                             AS SerieType1,
                                     'green'                                            AS SerieColor1,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Acumulado'
                                         ELSE
                                             'Acumulado'
                                     END                                                AS SerieName2,
                                     ROUND((VMPP.RMPCT32_33 + RMPCT32_45) / 1000, 2)    AS SerieValues2,
                                     'line'                                             AS SerieType2,
                                     'green'                                            AS SerieColor2,
                                     DATEFROMPARTS(VMPP.RMPCT32_01, VMPP.RMPCT32_00, 1) AS MesReporte
                                 FROM
                                     AA_RMP_CONT_32 VMPP (NOLOCK)
                                     LEFT JOIN
                                         DG_Grafica G
                                             ON @IdGrafica = G.Id_Grafica
											 AND	 RTRIM(VMPP.RF01_01) = RTRIM(@ContratoCNH)
                                 WHERE
                                     RTRIM(VMPP.RF01_01) = RTRIM(@ContratoCNH);

                     --||||||||||||||||||||||||||||||||||||||||||||  
                     -- Acumular  
                     --||||||||||||||||||||||||||||||||||||||||||||

                     INSERT INTO #ProduccionEntregaCondensado
                         (
                             MesReporte,
                             acumulado
                         )
                                 SELECT
                                     t2.MesReporte,
                                     SUM(   CASE
                                                WHEN t1.MesReporte <= t2.MesReporte
                                                    THEN t1.serievalues1
                                                ELSE
                                                    0
                                            END
                                        ) AS acumulado
                          FROM
                                     #VolumenEntregaCondensado            t1
                                     CROSS JOIN #VolumenEntregaCondensado t2
                                 GROUP BY
                                     t2.MesReporte
                                 ORDER BY
                                     t2.MesReporte;

                     --||||||||||||||||||||||||||||||||||||||||||||  
                     UPDATE
                         t1
                     SET
                         t1.SerieValues2 = ISNULL(t2.acumulado, 0)
                     FROM
                         #VolumenEntregaCondensado        t1
                         JOIN
                             #ProduccionEntregaCondensado t2
                                 ON t1.MesReporte = t2.MesReporte;

                     INSERT INTO #DatosGrafica
                         (
                             Titulo,
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
                             SerieColor1,
                             SerieName2,
                             SerieValues2,
                             SerieType2,
                             SerieColor2
                         )
                                 SELECT
                                     Titulo,
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
                                     SerieColor1,
                                     SerieName2,
                                     SerieValues2,
                                     SerieType2,
                                     SerieColor2
                                 FROM
                                     #VolumenEntregaCondensado;
                 END;


        /*  
    ====================================================================================  
     Producción: Volumen entrega de condensado contratista  
     ====================================================================================       
     */

        ELSE IF @IdGrafica = 16
                 BEGIN
                     SELECT
                         @ContratoCNH = NumeroContrato
                     FROM
                         dbo.CO_Contrato
                     WHERE
                         IdContrato = @IdContrato;

                     INSERT INTO #VolumenEntregaGas
                         (
                             Titulo,
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
                             SerieColor1,
                             SerieName2,
                             SerieValues2,
                             SerieType2,
                             SerieColor2,
                             MesReporte
                         )
                                 SELECT
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo
                                         ELSE
                                             G.Title
                                     END                                                AS Titulo,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Subtitulo
                                         ELSE
                                             G.Subtitle
                                     END                                                AS Subtitulo,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo_yAxis
                                         ELSE
                                             G.Title_yAxis
                                     END                                                AS Titulo_yAxis,
                                     CASE @Language
                                         WHEN 0
                                             THEN G.Titulo_xAxis
                                         ELSE
                                             G.Title_xAxis
                                     END                                                AS Titulo_xAxis,
                                     CONCAT(
                                               RIGHT('00' + CAST(VMPP.RMPCT32_00 AS VARCHAR(2)), 2), ' ',
                                               SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, VMPP.RMPCT32_00), 0, 4),
                                               ' ', SUBSTRING(CAST(RMPCT32_01 AS VARCHAR(4)), 3, 2)
                                           )                                            AS Fecha,
                                     2                                                  AS CantidadSeries,
                                     ' MBls'                                            AS valueSuffix,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Preliminar'
                                         ELSE
                                             'Preliminar'
                                     END                                                AS SerieName0,
                                     ROUND(VMPP.RMPCT32_33 / 1000, 2)                   AS SerieValues0,
                                     'line'                                             AS SerieType0,
                                     'gray'                                             AS SerieColor0,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Final'
                                         ELSE
                                             'Final'
                                     END                                                AS SerieName1,
                                     ROUND((VMPP.RMPCT32_33 + RMPCT32_45) / 1000, 2)    AS SerieValues1,
                                     'line'                                             AS SerieType1,
                                     'green'                                            AS SerieColor1,
                                     CASE @Language
                                         WHEN 0
                                             THEN 'Acumulado'
                                         ELSE
                                             'Acumulado'
                                     END                                                AS SerieName2,
                                     ROUND((VMPP.RMPCT32_33 + RMPCT32_45) / 1000, 2)    AS SerieValues2,
                                     'line'                                             AS SerieType2,
                                     'green'                                            AS SerieColor2,
                                     DATEFROMPARTS(VMPP.RMPCT32_01, VMPP.RMPCT32_00, 1) AS MesReporte
                                 FROM
                                     AA_RMP_CONT_32 VMPP (NOLOCK)
                                     LEFT JOIN
                                         DG_Grafica G
                                             ON @IdGrafica = G.Id_Grafica
											 AND RTRIM(VMPP.RF01_01) = RTRIM(@ContratoCNH)
                                 WHERE
                                     RTRIM(VMPP.RF01_01) = RTRIM(@ContratoCNH);
                     --||||||||||||||||||||||||||||||||||||||||||||  
                     -- Acumular  
                     --||||||||||||||||||||||||||||||||||||||||||||  
                     INSERT INTO #ProduccionEntregaGas
                         (
                             MesReporte,
                             acumulado
                         )
                                 SELECT
                                     t2.MesReporte,
                                     SUM(   CASE
                                                WHEN t1.MesReporte <= t2.MesReporte
                                                    THEN t1.serievalues1
                                                ELSE
                                                    0
                                            END
                                        ) AS acumulado
                                 FROM
                                     #VolumenEntregaGas            t1
                                     CROSS JOIN #VolumenEntregaGas t2
                                 GROUP BY
                                     t2.MesReporte
                                 ORDER BY
                                     t2.MesReporte;

                     --||||||||||||||||||||||||||||||||||||||||||||  
                     UPDATE
                         t1
                     SET
                         t1.SerieValues2 = ISNULL(t2.acumulado, 0)
                     FROM
                         #VolumenEntregaGas        t1
                         JOIN
                             #ProduccionEntregaGas t2
                                 ON t1.MesReporte = t2.MesReporte;

                     INSERT INTO #DatosGrafica
                         (
                             Titulo,
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
                             SerieColor1,
                             SerieName2,
                             SerieValues2,
                             SerieType2,
                             SerieColor2
                         )
                                 SELECT
                                     Titulo,
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
                                     SerieColor1,
                                     SerieName2,
                                     SerieValues2,
                                     SerieType2,
                                     SerieColor2
                                 FROM
                                     #VolumenEntregaGas;
                 END;



        /*  
     ====================================================================================  
     Precio Venta Petroleo   
     ====================================================================================       
     */

        IF @IdGrafica = 17
            BEGIN

                INSERT INTO #tmpprecioscrudo
                    (
                        Titulo,
                        Subtitulo,
                        Titulo_yAxis,
                        Titulo_xAxis,
                        Mes_Presupuestado,
                        SerieName0,
                        SerieValues0,
                        SerieName1,
                        SerieValues1,
                        valueSuffix
                    )
                            SELECT
                                CASE @Language
                                    WHEN 0
                                        THEN 'Precio de Venta Petroleo'
                                    ELSE
                                        'Precio de Venta Petroleo'
                                END                                  AS Titulo,
                                CASE @Language
                                    WHEN 0
                                        THEN DG_Grafica.Subtitulo
                                    ELSE
                                        DG_Grafica.Subtitle
                                END                                  AS Subtitulo,
                                CASE @Language
                                    WHEN 0
                                        THEN DG_Grafica.Titulo_yAxis
                                    ELSE
                                        DG_Grafica.Title_yAxis
                                END                                  AS Titulo_yAxis,
                                CASE @Language
                                    WHEN 0
                                        THEN DG_Grafica.Titulo_xAxis
                                    ELSE
                                        DG_Grafica.Title_xAxis
                                END                                  AS Titulo_xAxis,
                                PA.Anio                              AS Mes_Presupuestado,
                                CASE @Language
                                    WHEN 0
                                        THEN 'Plan Price (USD)'
                                    ELSE
                                        'Plan Precio (USD)'
                                END                                  AS 'SerieName0',
                                SUM(PA.PetroleoUSDBl)                AS 'SerieValues0',
                                CASE @Language
                                    WHEN 0
                                        THEN 'Real Price (USD)'
                                    ELSE
                                        'Real Precio (USD)'
    END                                  AS 'SerieName1',
                                isnull(SUM(PA.RealPetroleoUSDBl), 0) AS 'SerieValues1',
                                ' USD Bl'                            AS 'valueSuffix'
                            FROM
                                AA_PlanPrecioVentaHidrocarburoAnual PA (NOLOCK)
                                LEFT OUTER JOIN
                                    DG_Grafica (NOLOCK)
                                        ON @IdGrafica = DG_Grafica.Id_Grafica
										AND PA.IdContrato = @IdContrato
                            WHERE
                                (PA.IdContrato = @IdContrato)
                            GROUP BY
                                DG_Grafica.Title,
                                DG_Grafica.Subtitulo,
                                DG_Grafica.Subtitle,
                                DG_Grafica.Titulo_yAxis,
                                DG_Grafica.Title_yAxis,
                                DG_Grafica.Titulo_xAxis,
                                DG_Grafica.Title_xAxis,
                                PA.Anio;

                INSERT INTO #DatosGrafica
                    (
                        Titulo,
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
                            SELECT
                                Titulo,
                                Subtitulo,
                                Titulo_yAxis,
                                Titulo_xAxis,
                                Mes_Presupuestado,
                                2,
                                valueSuffix,
                                SerieName0,
                                SerieValues0     AS SerieValues0,
                                'line',
                                'blue',
                                SerieName1,
                                SerieValues1     AS SerieValues1,
                                'line',
                                'green'
                            FROM
                                #tmpprecioscrudo;
            END;


        /*   ====================================================================================  
     Precio Venta Gas   
     ====================================================================================       
     */

        IF @IdGrafica = 18
            BEGIN

                INSERT INTO #tmppreciosgas
                    (
                        Titulo,
                        Subtitulo,
                        Titulo_yAxis,
                        Titulo_xAxis,
                        Mes_Presupuestado,
                        SerieName0,
                        SerieValues0,
                        SerieName1,
                        SerieValues1,
                        valueSuffix
                    )
                            SELECT
                                CASE @Language
                                    WHEN 0
                                        THEN 'Precio de Venta Gas'
                                    ELSE
                                        'Precio de Venta Gas'
                                END                              AS Titulo,
                                CASE @Language
                                    WHEN 0
                                        THEN DG_Grafica.Subtitulo
                                    ELSE
                                        DG_Grafica.Subtitle
                        END                              AS Subtitulo,
                                CASE @Language
                                    WHEN 0
                                        THEN DG_Grafica.Titulo_yAxis
                                    ELSE
                                        DG_Grafica.Title_yAxis
                                END                              AS Titulo_yAxis,
                                CASE @Language
                                    WHEN 0
                                        THEN DG_Grafica.Titulo_xAxis
                                    ELSE
                                        DG_Grafica.Title_xAxis
                                END                              AS Titulo_xAxis,
                                PA.Anio                          AS Mes_Presupuestado,
                                CASE @Language
                                    WHEN 0
                                        THEN 'Plan Price (USD)'
                                    ELSE
                                        'Plan Precio (USD)'
                                END                              AS 'SerieName0',
                                SUM(PA.GasUSDMPc)                AS 'SerieValues0',
                                CASE @Language
                                    WHEN 0
                                        THEN 'Real Price (USD)'
                                    ELSE
                                        'Real Precio (USD)'
                                END                              AS 'SerieName1',
                                isnull(SUM(PA.RealGasUSDMPc), 0) AS 'SerieValues1',
                                ' USD MPc'                       AS 'valueSuffix'
                            FROM
                                AA_PlanPrecioVentaHidrocarburoAnual PA (NOLOCK)
                                LEFT OUTER JOIN
                                    DG_Grafica (NOLOCK)
                                        ON @IdGrafica = DG_Grafica.Id_Grafica
										AND PA.IdContrato = @IdContrato
                            WHERE
                                (PA.IdContrato = @IdContrato)
                            GROUP BY

                                -- PA,Anio,  
                                DG_Grafica.Title,
                                DG_Grafica.Subtitulo,
                                DG_Grafica.Subtitle,
                                DG_Grafica.Titulo_yAxis,
                                DG_Grafica.Title_yAxis,
                                DG_Grafica.Titulo_xAxis,
                                DG_Grafica.Title_xAxis,
                                PA.Anio;

                INSERT INTO #DatosGrafica
                    (
                        Titulo,
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
                            SELECT
                                Titulo,
                                Subtitulo,
                                Titulo_yAxis,
                                Titulo_xAxis,
                                Mes_Presupuestado,
                                2,
                                valueSuffix,
                                SerieName0,
                                SerieValues0     AS SerieValues0,
                                'line',
                                'blue',
                                SerieName1,
                                SerieValues1     AS SerieValues1,
                                'line',
                                'green'
                            FROM
                                #tmppreciosgas;
            END;


        /*  
     ====================================================================================  
     Ingresos comercializacion  
     ====================================================================================       
     */

        IF @IdGrafica = 19
            BEGIN

                INSERT INTO #tmpIngreso
                    (
                        Titulo,
                        Subtitulo,
                        Titulo_yAxis,
                        Titulo_xAxis,
                        Mes_Presupuestado,
                        SerieName0,
                        SerieValues0,
                        SerieName1,
                        SerieValues1,
                        valueSuffix
                    )
                            SELECT
                                CASE @Language
                                    WHEN 0
                                        THEN DG_Grafica.Titulo
                                    ELSE
                                        DG_Grafica.Title
                                END                                                                                     AS Titulo,
                                CASE @Language
                                    WHEN 0
                                        THEN DG_Grafica.Subtitulo
                                    ELSE
                                        DG_Grafica.Subtitle
                                END                                                                                     AS Subtitulo,
                                CASE @Language
                                    WHEN 0
                                        THEN DG_Grafica.Titulo_yAxis
                                    ELSE
                                        DG_Grafica.Title_yAxis
                                END                                                                                     AS Titulo_yAxis,
                                CASE @Language
                                    WHEN 0
                                        THEN DG_Grafica.Titulo_xAxis
                                    ELSE
                                        DG_Grafica.Title_xAxis
                                END                                                                                     AS Titulo_xAxis,
                                CONCAT(
                                          SUBSTRING(CAST(YEAR(COM.FechaTransaccion) AS VARCHAR(4)), 3, 2), ' ',
                                          RIGHT('00' + CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2), ' ',
                                          SUBSTRING(
                                                       dbo.Fn_ObtenerNombreMes(@Language, MONTH(COM.FechaTransaccion)),
                                                       0, 4
                                                   )
                                      )                                                                                 AS Mes_Presupuestado,
                                CASE @Language
                                    WHEN 0
                                        THEN 'Ingresos (USD)'
                                    ELSE
                                        'Ingresos (USD)'
                                END                                                                                     AS 'SerieName0',
                                SUM((com.PrecioVentaUnitario - com.CostoUnitarioComercializacion) * COM.VolumenVendido) AS 'SerieValues0',
                                CASE @Language
                                    WHEN 0
                                        THEN 'CGI (USD)'
                             ELSE
                                        'CGI (USD)'
                                END                                                                                     AS 'SerieName1',
                                0                                                                                       AS 'SerieValues1',
                                ' Dls'                                                                                  AS 'valueSuffix'
                            FROM
                                COM_OperacionComercializacion COM (NOLOCK)
                                LEFT OUTER JOIN
                                    DG_Grafica (NOLOCK)
                                        ON @IdGrafica = DG_Grafica.Id_Grafica
										AND	COM.IdContrato = @IdContrato
                            WHERE
                                (COM.IdContrato = @IdContrato)
                            GROUP BY
                                CONCAT(
                                          SUBSTRING(CAST(YEAR(COM.FechaTransaccion) AS VARCHAR(4)), 3, 2), ' ',
                                          RIGHT('00' + CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2), ' ',
                                          SUBSTRING(
                                                       dbo.Fn_ObtenerNombreMes(@Language, MONTH(COM.FechaTransaccion)),
                                                       0, 4
                                                   )
                                      ),
                                DG_Grafica.Titulo,
                                DG_Grafica.Title,
                                DG_Grafica.Subtitulo,
                                DG_Grafica.Subtitle,
                                DG_Grafica.Titulo_yAxis,
                                DG_Grafica.Title_yAxis,
                                DG_Grafica.Titulo_xAxis,
                                DG_Grafica.Title_xAxis
                            ORDER BY
                                CONCAT(
                                          SUBSTRING(CAST(YEAR(COM.FechaTransaccion) AS VARCHAR(4)), 3, 2), ' ',
                                          RIGHT('00' + CAST(MONTH(COM.FechaTransaccion) AS VARCHAR(2)), 2), ' ',
                                          SUBSTRING(
                                                       dbo.Fn_ObtenerNombreMes(@Language, MONTH(COM.FechaTransaccion)),
                                                       0, 4
                                                   )
                                      );

                INSERT INTO #tmpEgreso
                    (
                        Monto,
                        Mes_Presupuestado
                    )
                            SELECT
                                CAST(SUM(   CASE
                                                WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                                    THEN ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio
                                                ELSE
                                                    0
                                            END
                                        ) AS DECIMAL(15, 2)) AS Monto,
                                CONCAT(
                                          SUBSTRING(CAST(YEAR(R.MesPresentacion) AS VARCHAR(4)), 3, 2), ' ',
                                          RIGHT('00' + CAST(MONTH(R.MesPresentacion) AS VARCHAR(2)), 2), ' ',
                                          SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(R.MesPresentacion)), 0, 4)
                                      )                      as Mes_Presupuestado
                            FROM
                                CO_Registro                 R (NOLOCK)
                                JOIN
                                    FI_Factura              F (NOLOCK)
								on	R.IdFactura = F.IdFactura
									AND F.IdContrato = (@IdContrato)
                                JOIN
                                    FI_TransferFactura      TF (NOLOCK)
                                        on F.IdFactura = TF.IdFactura
                                JOIN
                                    FI_Transfer             T (NOLOCK)
                                        on TF.IdTransfer = T.IdTransferencia
										AND T.IdContrato = (@IdContrato)
                               LEFT JOIN
                                    FI_CPDocRelacionado     DR (NOLOCK)
                                        on F.UUID = DR.IdDocumento
                                LEFT JOIN
                                    FI_ComplementoDePago    CP (NOLOCK)
                                        on DR.IdComplementoDePago = CP.IdComplementoDePago
                                LEFT JOIN
                                    dbo.CO_TipoCambioDiario TCD (NOLOCK)
                                        ON T.IdMoneda = TCD.IdMoneda
                                           AND DAY(T.FechaPago) = DAY(TCD.Fecha)
                                           AND MONTH(T.FechaPago) = MONTH(TCD.Fecha)
                                           AND YEAR(T.FechaPago) = YEAR(TCD.Fecha)
                            WHERE
                                F.IdContrato = (@IdContrato)
                            GROUP BY
                                CONCAT(
                                          SUBSTRING(CAST(YEAR(R.MesPresentacion) AS VARCHAR(4)), 3, 2), ' ',
                                          RIGHT('00' + CAST(MONTH(R.MesPresentacion) AS VARCHAR(2)), 2), ' ',
                                          SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(R.MesPresentacion)), 0, 4)
                                      )
                            ORDER BY
                                CONCAT(
                                          SUBSTRING(CAST(YEAR(R.MesPresentacion) AS VARCHAR(4)), 3, 2), ' ',
                                          RIGHT('00' + CAST(MONTH(R.MesPresentacion) AS VARCHAR(2)), 2), ' ',
                                          SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(R.MesPresentacion)), 0, 4)
                                      )

                update
                    tI
                set
                    SerieValues1 = ISNULL(tE.Monto, 0)
                FROM
                    #tmpIngreso    tI
                    JOIN
                        #tmpEgreso tE
                            ON tI.Mes_Presupuestado = tE.Mes_Presupuestado

                INSERT INTO #DatosGrafica
                    (
                        Titulo,
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
                            SELECT
                                Titulo,
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
                            FROM
                                #tmpIngreso
                            ORDER BY
                                Mes_Presupuestado;
            END;

        SELECT
            *
        FROM
            #DatosGrafica
        ORDER BY
            Fecha;

    END;

