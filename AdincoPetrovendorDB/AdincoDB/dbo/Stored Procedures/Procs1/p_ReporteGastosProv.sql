-- =============================================
-- Modification Author:	Neri del Angel
-- Modification Date:	01 de Junio del 2022
-- Description:			Se ajusta el campo Comentarios de las tablas temporales de #Conceptos, #ConceptosFactura y 
--						el campo Concepto #tmpResult de VARCHAR(500) a VARCHAR(MAX) para corregir error 
--						[String or binary data would be truncated.  The statement has been terminated.],
--						se declara la creación la tabla #tmpResult correctamente y se elimina código comentado.
-- =============================================
CREATE PROC [dbo].[p_ReporteGastosProv]
    @pIdContrato INT,
    @pIdSubcontratista INT,
    @pMesIni DATETIME,
    @pMesFin DATETIME
AS
BEGIN
    CREATE TABLE #Conceptos
    (
        IdFactura INT,
        Comentarios VARCHAR(MAX)
    )

    CREATE TABLE #ConceptosFactura
    (
        IdFactura INT,
        Comentarios VARCHAR(MAX),
        PRIMARY KEY (IdFactura)
    )

    CREATE TABLE #tmpResult
    (
        Beneficiario VARCHAR(MAX),
        idSubcontratista INT,
        Fecha VARCHAR(MAX),
        Mes INT,
        Concepto VARCHAR(MAX),
        ExpensesMXN DECIMAL(18, 6),
        ExpensesUSD DECIMAL(18, 6),
        TipoCambio DECIMAL(18, 6),
        TotalExpenses DECIMAL(18, 6),
        SumaPCM DECIMAL(18, 4),
        SumaPemex DECIMAL(18, 4),
        ExpensesMXNTot DECIMAL(18, 4),
        ExpensesUSDTot DECIMAL(18, 4),
        TotalExpensesTot DECIMAL(18, 4),
        SumaPCMTot DECIMAL(18, 4),
        SumaPemexTot DECIMAL(18, 4)
    )

    DECLARE @anioMesIni INT,
            @anioMesFin INT,
            @porcentajePCM DECIMAL(5, 2) = 0,
            @porcentajePEMEX DECIMAL(5, 2) = 0
    DECLARE @FecFin DATETIME

    SELECT @FecFin = EOMONTH(@pMesFin)

    SELECT @anioMesIni = (DATEPART(year, @pMesIni) * 100) + DATEPART(month, @pMesIni),
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
    SELECT fac.IdFactura,
           RTRIM(LTRIM(reg.Comentarios))
    FROM CO_Registro reg (NOLOCK)
        JOIN FI_Factura fac (NOLOCK)
            ON fac.IdFactura = reg.idFactura
        JOIN dbo.FI_TransferFactura TR (NOLOCK)
            ON fac.IdFactura = TR.IdFactura
        JOIN dbo.FI_Transfer T (NOLOCK)
            ON TR.IdTransfer = T.IdTransferencia
    WHERE fac.idContrato = @pidContrato
          AND T.FechaPago
          BETWEEN @pMesIni AND @FecFin
    GROUP BY fac.IdFactura,
             RTRIM(LTRIM(reg.Comentarios))

    INSERT INTO #ConceptosFactura
    (
        IdFactura,
        Comentarios
    )
    SELECT IdFactura,
           STUFF(
           (
               SELECT ', ' + Comentarios
               FROM #Conceptos A
               WHERE B.IdFactura = A.IdFactura
               FOR XML PATH('')
           ),
           1,
           1,
           ''
                )
    FROM #Conceptos B
    GROUP BY IdFactura

    INSERT INTO #tmpResult
    (
        Beneficiario,
        idSubcontratista,
        Fecha,
        Mes,
        Concepto,
        ExpensesMXN,
        ExpensesUSD,
        TipoCambio,
        TotalExpenses,
        SumaPCM,
        SumaPemex,
        ExpensesMXNTot,
        ExpensesUSDTot,
        TotalExpensesTot,
        SumaPCMTot,
        SumaPemexTot
    )
    SELECT Beneficiario = subC.RazonSocial,
           subC.idSubcontratista,
           Fecha = CONVERT(VARCHAR, T.FechaPago, 103),
           Mes = DATEPART(month, T.FechaPago),
           Concepto = CAST(CF.Comentarios AS VARCHAR(MAX)),
           ExpensesMXN = SUM(   CASE
                                    WHEN T.IdMoneda = 1 THEN
                                        TR.MontoPagado
                                    ELSE
                                        0
                                END
                            ),
           ExpensesUSD = SUM(   CASE
                                    WHEN T.IdMoneda = 2 THEN
                                        TR.MontoPagado
                                    ELSE
                                        0
                                END
                            ),
           TipoCambio = tc.TipoCambio,
           TotalExpenses = SUM(   CASE
                                      WHEN T.IdMoneda = 1 THEN
                                          CASE
                                              WHEN isnull(tc.TipoCambio, 0) > 0 THEN
                                                  ISNULL(TR.MontoPagado, 0) / tc.TipoCambio
                                              ELSE
                                                  0
                                          END
                                      ELSE
                                          TR.MontoPagado
                                  END
                              ),
           SumaPCM = CAST(0 AS DECIMAL(18, 4)),
           SumaPemex = CAST(0 AS DECIMAL(18, 4)),
           ExpensesMXNTot = CAST(0 AS DECIMAL(18, 4)),
           ExpensesUSDTot = CAST(0 AS DECIMAL(18, 4)),
           TotalExpensesTot = CAST(0 AS DECIMAL(18, 4)),
           SumaPCMTot = CAST(0 AS DECIMAL(18, 4)),
           SumaPemexTot = CAST(0 AS DECIMAL(18, 4))
    FROM FI_Factura fac (NOLOCK)
        JOIN PV_Subcontratista subC (NOLOCK)
            ON subC.IdSubcontratista = fac.idSubcontratista
        JOIN dbo.FI_TransferFactura TR (NOLOCK)
            ON fac.IdFactura = TR.IdFactura
        JOIN dbo.FI_Transfer T (NOLOCK)
            ON TR.IdTransfer = T.IdTransferencia
        JOIN #ConceptosFactura CF (NOLOCK)
            ON fac.IdFactura = CF.IdFactura
        LEFT JOIN [dbo].[CO_TipoCambioDiario] tc (NOLOCK)
            ON tc.IdMoneda = T.idmoneda
               AND CONVERT(VARCHAR, t.FechaPago, 112) = CONVERT(VARCHAR, tc.Fecha, 112)
    WHERE fac.idContrato = @pidContrato
          AND T.FechaPago
          BETWEEN @pMesIni AND @FecFin
    GROUP BY subC.RazonSocial,
             subC.idSubcontratista,
             subC.RazonSocial,
             CONVERT(VARCHAR, T.FechaPago, 103),
             DATEPART(month, T.FechaPago),
             CAST(CF.Comentarios AS VARCHAR(MAX)),
             tc.TipoCambio

    UPDATE #tmpResult
    SET SumaPCM = TotalExpenses * (@porcentajePCM / 100),
        SumaPemex = TotalExpenses * (@porcentajePEMEX / 100);

    UPDATE #tmpResult
    SET ExpensesMXNTot =
        (
            SELECT SUM(ExpensesMXN) FROM #tmpResult
        ),
        ExpensesUSDTot =
        (
            SELECT SUM(ExpensesUSD) FROM #tmpResult
        ),
        TotalExpensesTot =
        (
            SELECT SUM(TotalExpenses) FROM #tmpResult
        ),
        SumaPCMTot =
        (
            SELECT SUM(SumaPCM) FROM #tmpResult
        ),
        SumaPemexTot =
        (
            SELECT SUM(SumaPemex) FROM #tmpResult
        )

    SELECT *
    FROM #tmpResult
    ORDER BY Beneficiario,
             Mes,
             Concepto

END