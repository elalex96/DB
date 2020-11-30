CREATE PROC [dbo].[p_ReporteGastosProv] @pIdContrato       INT,
                                       @pIdSubcontratista INT,
                                       @pMesIni           DATETIME,
                                       @pMesFin           DATETIME
AS
BEGIN
	CREATE TABLE #Conceptos
	(
		IdFactura INT,
		Comentarios VARCHAR(500)
	)

	CREATE TABLE #ConceptosFactura
	(
		IdFactura INT,
		Comentarios VARCHAR(500),
		PRIMARY KEY (IdFactura)
	)

     DECLARE @anioMesIni INT, @anioMesFin INT, @porcentajePCM DECIMAL(5, 2)= 0, @porcentajePEMEX DECIMAL(5, 2)= 0
	 DECLARE @FecFin DATETIME

	 SELECT @FecFin = EOMONTH(@pMesFin)

     SELECT @anioMesIni = (DATEPART(year, @pMesIni) * 100) + DATEPART(month, @pMesIni),
            --@anioMesFin = (DATEPART(year, @pMesFin) * 100) + DATEPART(month, @pMesFin);
			@anioMesFin = (DATEPART(year, @FecFin) * 100) + DATEPART(month, @FecFin);

     SELECT @porcentajePCM = PorcentajePCM,
            @porcentajePEMEX = PorcentajePemex
     FROM CO_ConfiguracionReportes
     WHERE IdContrato = @pIdContrato;

	INSERT INTO #Conceptos
	(
		IdFactura,
		Comentarios
	)
	SELECT
		fac.IdFactura,
		RTRIM(LTRIM(reg.Comentarios))
	FROM
		CO_Registro reg
		JOIN FI_Factura fac ON fac.IdFactura = reg.idFactura
		JOIN dbo.FI_TransferFactura	TR
		ON	fac.IdFactura	=	TR.IdFactura
		JOIN
			dbo.FI_Transfer	T
			ON	TR.IdTransfer	=	T.IdTransferencia
	WHERE
		fac.idContrato = @pidContrato
--		  AND (DATEPART(year, TR.CreadoEn) * 100) + DATEPART(month, TR.CreadoEn) BETWEEN @anioMesIni AND @anioMesFin
		  --AND (DATEPART(year, T.FechaPago) * 100) + DATEPART(month, T.FechaPago) BETWEEN @anioMesIni AND @anioMesFin
		AND T.FechaPago BETWEEN @pMesIni AND @FecFin

	GROUP BY
		fac.IdFactura,
		RTRIM(LTRIM(reg.Comentarios))

	INSERT INTO #ConceptosFactura
	(
	    IdFactura,
	    Comentarios
	)
	SELECT
		IdFactura,
		STUFF(( SELECT  ', '+ Comentarios FROM #Conceptos A
			WHERE B.IdFactura = A.IdFactura FOR XML PATH('')),1 ,1, '') 
	FROM
		#Conceptos B
	GROUP BY
		IdFactura
		

     --select @anioMesIni,@anioMesFin

     SELECT Beneficiario = subC.RazonSocial,
            subC.idSubcontratista,
            --subC.RazonSocial,
   --         Fecha = CONVERT( VARCHAR, reg.FecMovto, 103),
			--Mes = DATEPART(month, reg.FecMovto),
			Fecha = CONVERT( VARCHAR, T.FechaPago, 103),
            Mes = DATEPART(month, T.FechaPago),
            --Concepto = CAST(reg.Comentarios AS   VARCHAR(500)),
			Concepto = CAST(CF.Comentarios AS  VARCHAR(500)),
            ExpensesMXN = SUM (
						CASE
                              WHEN T.IdMoneda = 1	--fac.IdMoneda = 1
                              --THEN reg.MontoRegistro
							  THEN TR.MontoPagado
                              ELSE 0
                          END),
            ExpensesUSD = SUM(
						CASE
                              WHEN T.IdMoneda = 2	--fac.IdMoneda = 2
                              --THEN reg.MontoRegistro
							  THEN TR.MontoPagado
                              ELSE 0
                          END),
            TipoCambio = tc.TipoCambio,
            TotalExpenses = SUM(--ISNULL(TR.MontoPagado,0) / tc.TipoCambio),
							CASE
                                WHEN T.IdMoneda = 1	--fac.IdMoneda = 1
                                THEN CASE
                                         WHEN isnull(tc.TipoCambio, 0) > 0
                                         --THEN reg.MontoRegistro / tc.TipoCambio
										 THEN ISNULL(TR.MontoPagado,0) / tc.TipoCambio
                                         ELSE 0
                                     END
                                --ELSE reg.MontoRegistro
								ELSE TR.MontoPagado
                            END),
            SumaPCM = CAST(0 AS          DECIMAL(18, 4)),
            SumaPemex = CAST(0 AS        DECIMAL(18, 4)),
            --fac.IdFactura,
            --Totales
            ExpensesMXNTot = CAST(0 AS   DECIMAL(18, 4)),
            ExpensesUSDTot = CAST(0 AS   DECIMAL(18, 4)),
            TotalExpensesTot = CAST(0 AS DECIMAL(18, 4)),
            SumaPCMTot = CAST(0 AS       DECIMAL(18, 4)),
            SumaPemexTot = CAST(0 AS     DECIMAL(18, 4))
            --reg.IdPrograma
     INTO #tmpResult
     FROM --CO_Registro reg
          --JOIN
		  FI_Factura fac --ON fac.IdFactura = reg.idFactura
          JOIN PV_Subcontratista subC ON subC.IdSubcontratista = fac.idSubcontratista
		  JOIN dbo.FI_TransferFactura	TR
			ON	fac.IdFactura	=	TR.IdFactura
		JOIN dbo.FI_Transfer	T
			ON	TR.IdTransfer	=	T.IdTransferencia
		  JOIN
			#ConceptosFactura	CF
			ON	fac.IdFactura	=	CF.IdFactura
          LEFT JOIN [dbo].[CO_TipoCambioDiario] tc ON tc.IdMoneda = T.idmoneda		--tc.IdMoneda = fac.idmoneda
                                                   --AND CONVERT( VARCHAR, fac.Fecha, 112) = CONVERT(VARCHAR, tc.Fecha, 112)
												   AND CONVERT( VARCHAR, t.FechaPago, 112) = CONVERT(VARCHAR, tc.Fecha, 112)
        --  INNER JOIN PV_Subcontratista emisor ON emisor.RFC = fac.Emisor
     WHERE fac.idContrato = @pidContrato
           AND --@pIdSubcontratista in (fac.idSubcontratista,0) and
           --(DATEPART(year, reg.FecMovto) * 100) + DATEPART(month, reg.FecMovto) BETWEEN @anioMesIni AND @anioMesFin
		   --(DATEPART(year, T.FechaPago) * 100) + DATEPART(month, T.FechaPago) BETWEEN @anioMesIni AND @anioMesFin
		   T.FechaPago BETWEEN @pMesIni AND @FecFin
		   --T.FechaPago BETWEEN @pMesIni AND @FecFin
	GROUP BY
		subC.RazonSocial,
        subC.idSubcontratista,
        subC.RazonSocial,
		CONVERT( VARCHAR, T.FechaPago, 103),
        DATEPART(month, T.FechaPago),
        --CAST(reg.Comentarios AS   VARCHAR(500)),
		CAST(CF.Comentarios AS   VARCHAR(500)),
        tc.TipoCambio
        --fac.IdFactura,
        --reg.IdPrograma


     UPDATE #tmpResult
       SET
           SumaPCM = TotalExpenses * (@porcentajePCM / 100),
           SumaPemex = TotalExpenses * (@porcentajePEMEX / 100);

     UPDATE #tmpResult
       SET
           ExpensesMXNTot =
     (
         SELECT SUM(ExpensesMXN)
         FROM #tmpResult
     ),
           ExpensesUSDTot =
     (
         SELECT SUM(ExpensesUSD)
         FROM #tmpResult
     ),
           TotalExpensesTot =
     (
         SELECT SUM(TotalExpenses)
         FROM #tmpResult
     ),
           SumaPCMTot =
     (
         SELECT SUM(SumaPCM)
         FROM #tmpResult
     ),
           SumaPemexTot =
     (
         SELECT SUM(SumaPemex)
         FROM #tmpResult
     )

     SELECT *
     FROM #tmpResult
	 ORDER BY
	 Beneficiario,
	 Mes,
	 Concepto

END

