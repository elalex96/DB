-- p_CO_ContraprestacionesResumen 2, '20180101','20190101'
CREATE PROC p_CO_ContraprestacionesResumen
--
@pIdContratista INT, 
@pMesInicio     DATETIME, 
@pMesFin        DATETIME
AS

     /**/

     CREATE TABLE #tmpCuotas
     (Mes                   DATETIME, 
      NumeroContrato        VARCHAR(50), 
      CuotaContractual      MONEY, 
      SuperficieKm2         MONEY, 
      TotalCuotaContractual MONEY, 
      Impuesto              MONEY, 
      TotalImpuesto         MONEY
     );

     /**/

     DECLARE @fechaIniCiclo DATETIME= @pMesInicio, @numContratos INT;
     SELECT @numContratos = COUNT(DISTINCT IdContrato)
     FROM CO_Contrato
     WHERE IdContratista = @pidContratista
	 AND Activo  = 1;

     /**/

     INSERT INTO #tmpCuotas
     EXEC sp_CP_CalculaCuotaContractualeImpuesto 
          @pIdContratista, 
          @pMesInicio, 
          @pMesFin;

     /******REGALIAS****************/

     SELECT c.IdContrato, 
            c.NumeroContrato, 
            ac.IdAreaContractual, 
            AreaContractual = ac.NombreAreaContractual, 
            Km = ac.SuperficieKm2, 
            ValorRegaliaAdicional = isnull(c.ValorRegaliaAdicional, 0), 
			CuotaContractualCC = 0,
			CuotaContractualTCC = 0,
			Impuesto=0,
			ImpuestoTotal=0,
            RegaliaBase = SUM(ROUND((t1.TasaRegalia / 100) * (ROUND(t1.Precio, 2) * ISNULL(t1.Volumen, 0)), 2)),

            /*Regalia Base*/

            RegaliaAdicional = SUM((ISNULL(t1.Volumen, 0) * ROUND(ISNULL(t1.Precio, 0), 2)) * (c.ValorRegaliaAdicional / 100)),

            /*Regalia Adicional*/

            Tipo = CAST('Regalias en USD' AS VARCHAR(300)), 
            Mes = DATEADD(month, DATEDIFF(month, 0, t1.Mes), 0), 
            NombreMes = CAST((DATEPART(year, t1.Mes) * 100) + DATEPART(month, t1.Mes) AS VARCHAR)+' '+CASE
                                                                                                          WHEN DATEPART(month, t1.Mes) = 1
                                                                                                          THEN 'Enero'
                                                                                                          WHEN DATEPART(month, t1.Mes) = 2
                                                                                                          THEN 'Febrero'
                                                                                                          WHEN DATEPART(month, t1.Mes) = 3
                                                                                                          THEN 'Marzo'
                                                                                                          WHEN DATEPART(month, t1.Mes) = 4
                                                                                                          THEN 'Abril'
                                                                                                          WHEN DATEPART(month, t1.Mes) = 5
                                                                                                          THEN 'Mayo'
                                                                                                          WHEN DATEPART(month, t1.Mes) = 6
                                                                                                          THEN 'Junio'
                                                                                                          WHEN DATEPART(month, t1.Mes) = 7
                                                                                                          THEN 'Julio'
                                                                                                          WHEN DATEPART(month, t1.Mes) = 8
                                                                                                          THEN 'Agosto'
                                  WHEN DATEPART(month, t1.Mes) = 9
                   THEN 'Septiembre'
                                                                                                          WHEN DATEPART(month, t1.Mes) = 10
                                                                                                          THEN 'Octubre'
                                                                                                          WHEN DATEPART(month, t1.Mes) = 11
                                                                                                          THEN 'Noviembre'
                                                                                                          WHEN DATEPART(month, t1.Mes) = 12
                                                                                                          THEN 'Diciembre'
                                                                                                      END+' '+CAST(DATEPART(year, t1.Mes) AS VARCHAR)
     INTO #tmpRegalias
     FROM CO_Contrato c
          INNER JOIN CO_AreaContractual ac 
			ON ac.IdAreaContractual = c.IdAreaContractual
			and c.Activo = 1
          INNER JOIN CP_MetodoCalculoHidrocarburoMes t1 ON c.IdContrato = t1.IdContrato
                                                           AND CONVERT(VARCHAR, t1.Mes, 112) <= CONVERT(VARCHAR, @pMesFin, 112)
                                                           AND CONVERT(VARCHAR, t1.Mes, 112) >= CONVERT(VARCHAR, @pMesInicio, 112)
     WHERE c.IdContratista = @pIdContratista
     GROUP BY c.IdContrato, 
              c.NumeroContrato, 
              ac.IdAreaContractual, 
              ac.NombreAreaContractual, 
              ac.SuperficieKm2, 
              c.ValorRegaliaAdicional, 
              t1.Mes
     --ORDER BY t1.Mes;

	 SELECT IdContrato, 
            NumeroContrato, 
            IdAreaContractual, 
            AreaContractual, 
            Km, 
            ValorRegaliaAdicional, 
			CuotaContractualCC = SUM(CuotaContractualCC),
			CuotaContractualTCC = sum(CuotaContractualTCC),
			Impuesto=sum(Impuesto),
			ImpuestoTotal=SUM(ImpuestoTotal),
            RegaliaBase = SUM(RegaliaBase),

            /*Regalia Base*/

            RegaliaAdicional = SUM(RegaliaAdicional),


            --CuotaContractualCC = SUM(CuotaContractualCC),
            /*Regalia Base*/
           --CuotaContractualTCC = SUM(CuotaContractualTCC),
            /*Regalia Adicional*/
            Tipo, 
            Mes, 
            NombreMes
	INTO #tmpRegalias2
	FROM #tmpRegalias
	GROUP BY IdContrato, 
            NumeroContrato, 
            IdAreaContractual, 
            AreaContractual, 
            Km, 
            ValorRegaliaAdicional,          
           
            Tipo, 
            Mes, 
            NombreMes
     /**********************************************/
	

     SET @fechaIniCiclo = @pMesInicio;
     IF NOT EXISTS
     (
         SELECT 1
         FROM #tmpCuotas
     )
         BEGIN
             WHILE CONVERT(VARCHAR, @fechaIniCiclo, 112) <= CONVERT(VARCHAR, @pMesFin, 112)
                 BEGIN
                     INSERT INTO #tmpCuotas
                            SELECT @fechaIniCiclo, 
                                   NumeroContrato, 
                                   0, 
                                   0, 
                                   0, 
                                   0, 
                                   0
                            FROM CO_Contrato
                            WHERE IdContratista = @pIdContratista
							and activo = 1;
                     SELECT @fechaIniCiclo = DATEADD(month, 1, @fechaIniCiclo);
                 END;
         END;

     /******************************************/

     INSERT INTO #tmpRegalias2
            SELECT c.IdContrato, 
                   c.NumeroContrato, 
                   ac.IdAreaContractual, 
                   AreaContractual = ac.NombreAreaContractual, 
                   Km = ac.SuperficieKm2, 
                   ValorRegaliaAdicional = isnull(c.ValorRegaliaAdicional, 0), 
                   CuotaContractualCC = isnull(t1.CuotaContractual, 0), 
                   CuotaContractualTCC = isnull(t1.TotalCuotaContractual, 0), 
				   0,
				   0,
				   0,
				   0,

                   Tipo = 'Cuota Contractual l, Art 23 LISH en MXN', 
                   Mes = DATEADD(month, DATEDIFF(month, 0, t1.Mes), 0), 
                   NombreMes = CAST((DATEPART(year, t1.Mes) * 100) + DATEPART(month, t1.Mes) AS VARCHAR)+' '+CASE
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 1
                                                                                                                 THEN 'Enero'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 2
 THEN 'Febrero'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 3
                                                                                                                 THEN 'Marzo'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 4
                                                                                                                 THEN 'Abril'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 5
                                                                                                                 THEN 'Mayo'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 6
                                                                                                                 THEN 'Junio'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 7
                                                                                                                 THEN 'Julio'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 8
                                                                                                                 THEN 'Agosto'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 9
                                                                                                                 THEN 'Septiembre'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 10
                                                                                                                 THEN 'Octubre'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 11
                                                                                                                 THEN 'Noviembre'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 12
                                                                                                                 THEN 'Diciembre'
                                                                                                             END+' '+CAST(DATEPART(year, t1.Mes) AS VARCHAR)
            FROM CO_Contrato c
                 INNER JOIN #tmpCuotas t1 
					ON C.NumeroContrato = t1.NumeroContrato
					and c.activo = 1
                 --		AND t1.Mes = t1.Mes 
                 INNER JOIN CO_AreaContractual ac ON ac.IdAreaContractual = c.IdAreaContractual
            WHERE c.IdContratista = @pIdContratista
            UNION
            SELECT c.IdContrato, 
                   c.NumeroContrato, 
                   ac.IdAreaContractual, 
                   AreaContractual = ac.NombreAreaContractual, 
                   Km = ac.SuperficieKm2, 
                   ValorRegaliaAdicional = isnull(c.ValorRegaliaAdicional, 0), 
				   0,
				   0,
                   CuotaContractualCC = t1.Impuesto, 
                   CuotaContractualTCC = t1.TotalImpuesto, 
				   0,
				   0,
                   Tipo = 'Impuesto Fase de exploración , Art 55 LISH en MXN', 
                   Mes = DATEADD(month, DATEDIFF(month, 0, t1.Mes), 0), 
                   NombreMes = CAST((DATEPART(year, t1.Mes) * 100) + DATEPART(month, t1.Mes) AS VARCHAR)+' '+CASE
                    WHEN DATEPART(month, t1.Mes) = 1
                                                                                                                 THEN 'Enero'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 2
                                                                                                                 THEN 'Febrero'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 3
                                                                                                                 THEN 'Marzo'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 4
                                                                                                                 THEN 'Abril'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 5
                                                                                                                 THEN 'Mayo'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 6
                                                                                                                 THEN 'Junio'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 7
                                                                                                                 THEN 'Julio'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 8
                                                                                                                 THEN 'Agosto'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 9
                                                                                                                 THEN 'Septiembre'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 10
                                                                                                                 THEN 'Octubre'
                                                                                                                 WHEN DATEPART(month, t1.Mes) = 11
                                                                                                                 THEN 'Noviembre'
                                                                                                WHEN DATEPART(month, t1.Mes) = 12
                                                                                                                 THEN 'Diciembre'
                                                                                                             END+' '+CAST(DATEPART(year, t1.Mes) AS VARCHAR)
            FROM CO_Contrato c
               INNER JOIN CO_AreaContractual ac 
				ON ac.IdAreaContractual = c.IdAreaContractual
					and c.activo = 1
                 INNER JOIN #tmpCuotas t1 ON C.NumeroContrato = t1.NumeroContrato
            --ON t1.Mes = t1.Mes 
            WHERE c.IdContratista = @pIdContratista;

     /******RELLENAR MESES VACIOS PARA REGALIAS**********************/

	

     SET @fechaIniCiclo = @pMesInicio;
     DECLARE @tipoCiclo VARCHAR(300)= '';
     WHILE @fechaIniCiclo <= @pMesFin
         BEGIN
             SET @tipoCiclo = '';
             IF
             (
                 SELECT COUNT(DISTINCT IdContrato)
                 FROM #tmpRegalias2
                 WHERE Mes = @fechaIniCiclo
                       AND Tipo = 'Regalias en USD'
             ) < @numContratos
                 BEGIN
                     INSERT INTO #tmpRegalias2
                     (IdContrato, 
                      NumeroContrato, 
                      IdAreaContractual, 
                      AreaContractual, 
                      Km, 
                      ValorRegaliaAdicional, 
                      RegaliaBase, 
                      regaliaAdicional, 
                      Tipo, 
                      Mes, 
                      NombreMes
                     )
                            SELECT IdContrato, 
                                   NumeroContrato, 
                                   ac.IdAreaContractual, 
                                   NombreAreaContractual, 
                                   ac.SuperficieKm2, 
                                   isnull(c.ValorRegaliaAdicional, 0), 
                                   cast(0.0 as money), 
                                   cast(0.0 as money), 

                                   'Regalias en USD', 
                                   @fechaIniCiclo, 
                                   CAST((DATEPART(year, @fechaIniCiclo) * 100) + DATEPART(month, @fechaIniCiclo) AS VARCHAR)+' '+CASE
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 1
                                                                                                                                     THEN 'Enero'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 2
                                                                                                                                     THEN 'Febrero'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 3
                                                                                                                                     THEN 'Marzo'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 4
                                                                                                                                     THEN 'Abril'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 5
                                  THEN 'Mayo'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 6
                                                                                                                                     THEN 'Junio'
                                                      WHEN DATEPART(month, @fechaIniCiclo) = 7
                                                                                                                                     THEN 'Julio'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 8
                                                                                                                                     THEN 'Agosto'
                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 9
                                                                                                                                     THEN 'Septiembre'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 10
                                                                                                                                     THEN 'Octubre'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 11
                                                                                                                                     THEN 'Noviembre'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 12
                                                                                                                                     THEN 'Diciembre'
                                                                                                                                 END+' '+CAST(DATEPART(year, @fechaIniCiclo) AS VARCHAR)
                            FROM CO_Contrato c
                                 INNER JOIN CO_AreaContractual ac 
									ON ac.IdAreaContractual = c.IdAreaContractual
									and c.activo = 1
                            WHERE IdContratista = @pIdContratista
                                  AND NOT EXISTS
                            (
                                SELECT 1
                                FROM #tmpRegalias2 TMP
                                WHERE TMP.IdContrato = c.idContrato
                                      AND CONVERT(VARCHAR, TMP.Mes, 112) = CONVERT(VARCHAR, @fechaIniCiclo, 112)
                                      AND TMP.Tipo = 'Regalias en USD'
                            );
                 END;
             IF
             (
                 SELECT COUNT(DISTINCT IdContrato)
                 FROM #tmpRegalias2
                 WHERE Mes = @fechaIniCiclo
                       AND Tipo = 'Cuota Contractual l, Art 23 LISH en MXN'
             ) < @numContratos
                 BEGIN
                     INSERT INTO #tmpRegalias2
                     (IdContrato, 
                      NumeroContrato, 
                      IdAreaContractual, 
                      AreaContractual, 
                      Km, 
                      ValorRegaliaAdicional, 
                      CuotaContractualCC, 
                      CuotaContractualTCC, 
                      Tipo, 
                      Mes, 
                      NombreMes
                     )
                            SELECT IdContrato, 
                                   NumeroContrato, 
     ac.IdAreaContractual, 
                                   NombreAreaContractual, 
                                   ac.SuperficieKm2, 
                                   isnull(c.ValorRegaliaAdicional, 0), 
                                    cast(0.0 as money), 
                                   cast(0.0 as money), 
                                   'Cuota Contractual l, Art 23 LISH en MXN', 
                                   @fechaIniCiclo, 
                                   CAST((DATEPART(year, @fechaIniCiclo) * 100) + DATEPART(month, @fechaIniCiclo) AS VARCHAR)+' '+CASE
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 1
                                                                                                                                     THEN 'Enero'
                                                                    WHEN DATEPART(month, @fechaIniCiclo) = 2
                                                                                                                                     THEN 'Febrero'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 3
                                                                                                                                     THEN 'Marzo'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 4
                                                                                                                                     THEN 'Abril'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 5
                                                                                                                                     THEN 'Mayo'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 6
                                                                                                                                     THEN 'Junio'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 7
                                                                                                                                     THEN 'Julio'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 8
                                                                                                                                     THEN 'Agosto'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 9
                                                                                                                                     THEN 'Septiembre'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 10
                                                                                                                                     THEN 'Octubre'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 11
                                                                          THEN 'Noviembre'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 12
                                                                                                                                     THEN 'Diciembre'
                                                                                        END+' '+CAST(DATEPART(year, @fechaIniCiclo) AS VARCHAR)
                            FROM CO_Contrato c
                                 INNER JOIN CO_AreaContractual ac 
									ON ac.IdAreaContractual = c.IdAreaContractual
									and c.activo = 1
                            WHERE IdContratista = @pIdContratista
                                  AND NOT EXISTS
                            (
                        SELECT 1
                                FROM #tmpRegalias2 TMP
                                WHERE TMP.IdContrato = c.idContrato
                                      AND CONVERT(VARCHAR, TMP.Mes, 112) = CONVERT(VARCHAR, @fechaIniCiclo, 112)
                                      AND TMP.Tipo = 'Cuota Contractual l, Art 23 LISH en MXN'
                            );
                 END;
             IF
             (
                 SELECT ISNULL(COUNT(DISTINCT IdContrato), 0)
                 FROM #tmpRegalias2
                 WHERE Mes = @fechaIniCiclo
                       AND Tipo = 'Impuesto Fase de exploración , Art 55 LISH en MXN'
             ) < @numContratos
                 BEGIN
                     INSERT INTO #tmpRegalias2
                     (IdContrato, 
                      NumeroContrato, 
                      IdAreaContractual, 
                      AreaContractual, 
                      Km, 
                      ValorRegaliaAdicional, 
                      Impuesto, 
                      ImpuestoTotal, 
                      Tipo, 
                      Mes, 
                      NombreMes
                     )
                            SELECT IdContrato, 
                                   NumeroContrato, 
                                   ac.IdAreaContractual, 
                                   NombreAreaContractual, 
                                   ac.SuperficieKm2, 
                                   isnull(c.ValorRegaliaAdicional, 0), 
                                    cast(0.0 as money), 
                                   cast(0.0 as money), 
                                   'Impuesto Fase de exploración , Art 55 LISH en MXN', 
                                   @fechaIniCiclo, 
                                   CAST((DATEPART(year, @fechaIniCiclo) * 100) + DATEPART(month, @fechaIniCiclo) AS VARCHAR)+' '+CASE
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 1
                                                                                                                                     THEN 'Enero'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 2
                                                                                                                                     THEN 'Febrero'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 3
                                                                                                                                     THEN 'Marzo'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 4
                                                                                                            THEN 'Abril'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 5
                                                THEN 'Mayo'
                                                                                        WHEN DATEPART(month, @fechaIniCiclo) = 6
                                                                                                                                     THEN 'Junio'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 7
                                                                                                                                     THEN 'Julio'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 8
                                                                                                                                     THEN 'Agosto'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 9
                                                                                                                                     THEN 'Septiembre'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 10
                                                                                                                                     THEN 'Octubre'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 11
                                                                                                                                     THEN 'Noviembre'
                                                                                                                                     WHEN DATEPART(month, @fechaIniCiclo) = 12
                                                                                                                                     THEN 'Diciembre'
                                                                                                                                 END+' '+CAST(DATEPART(year, @fechaIniCiclo) AS VARCHAR)
                            FROM CO_Contrato c
                                 INNER JOIN CO_AreaContractual ac 
									ON ac.IdAreaContractual = c.IdAreaContractual
									and c.activo = 1
                            WHERE IdContratista = @pIdContratista
                                  AND NOT EXISTS
                            (
                                SELECT 1
                                FROM #tmpRegalias2 TMP
                                WHERE TMP.IdContrato = c.idContrato
                                      AND CONVERT(VARCHAR, TMP.Mes, 112) = CONVERT(VARCHAR, @fechaIniCiclo, 112)
                                      AND TMP.Tipo = 'Impuesto Fase de exploración , Art 55 LISH en MXN'
                            );
                 END;
             SELECT @fechaIniCiclo = DATEADD(month, 1, @fechaIniCiclo);
         END;

     /**/

     SELECT R.IdContrato, 
            R.NumeroContrato, 
            R.IdAreaContractual, 
            R.AreaContractual, 
            R.Km, 
            ISNULL(R.ValorRegaliaAdicional, 0) AS ValorRegaliaAdicional, 
            ISNULL(R.CuotaContractualCC, 0) AS CuotaContractualCC, 
            ISNULL(R.CuotaContractualTCC, 0) AS CuotaContractualTCC, 
			ISNULL(R.Impuesto, 0) AS Impuesto, 
            ISNULL(R.ImpuestoTotal, 0) AS ImpuestoTotal, 
			ISNULL(R.RegaliaBase, 0) AS RegaliaBase, 
            ISNULL(R.RegaliaAdicional, 0) AS RegaliaAdicional,
            R.Tipo, 
            R.Mes, 
            R.NombreMes, 
            ISNULL(DE.RegaliaBase, 0) AS PenalizacionRegaliaBase, 
            ISNULL(DE.RegaliaAdicional, 0) AS PenalizacionRegaliaAdicional, 
            ISNULL(DE.CuotaContractual, 0) AS PenalizacionCuotaContractual
     FROM #tmpRegalias2 R
          LEFT JOIN dbo.CP_DiferenciaEconomica DE ON DE.IdContrato = R.IdContrato
                                                     AND DE.Mes = R.Mes
     ORDER BY mES, 
              Tipo;
