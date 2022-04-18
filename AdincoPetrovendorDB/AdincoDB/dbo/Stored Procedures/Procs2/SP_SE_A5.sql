USE Adinco;
GO
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-10-02
-- Description:	
-- =============================================
-- Modificado Por:	Neri del Angel
-- Create date:		04 de Abril del 2022
-- Description:		Se agrega filtrado de todos
--					los presupuestos del periodo
--					seleccionado
-- ============================================
-- Modificado Por:	Reyna 
-- Create date:		12 de Abril del 2022
-- Description:		se Actualiza el stored procedure  
--					para tomar en cuenta gastos con PCN >=0 (issue 1890 adinco)
-- ============================================
ALTER PROCEDURE [dbo].[SP_SE_A5]
    @IdContrato INT,
    @IdUsuario INT,
    @IdPresupuesto INT,
    @FInicio DATE,
    @FFin DATE,
    @IdPeriodo INT,
    @Etapa VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    CREATE TABLE #Presupuestos (IdPresupuesto INT);
    CREATE TABLE #RFC (RFC VARCHAR(25));
    /*Se valida si el presupuesto viene en 0 para obtener todos los presupuestos del perido.*/
    IF (@IdPresupuesto = 0)
    BEGIN
        INSERT INTO #Presupuestos
        (
            IdPresupuesto
        )
        SELECT CP.IdPresupuesto
        FROM CO_ProgramaActividad CPA (NOLOCK)
            INNER JOIN CO_PeriodoContrato CPC (NOLOCK)
                ON CPA.IdPeriodoContrato = CPC.IdPeriodo
            INNER JOIN CO_Presupuesto CP (NOLOCK)
                ON CPA.IdProgramaActividad = CP.IdProgramaActividad
        WHERE CPC.IdPeriodo = @IdPeriodo
              AND CP.Activo = 1
        IF 1 =
        (
            SELECT COUNT(1)
            FROM #Presupuestos T
                JOIN dbo.CO_Presupuesto P (NOLOCK)
                    ON T.IdPresupuesto = P.IdPresupuesto
                JOIN dbo.CO_AnioContractual AC (NOLOCK)
                    ON P.IdAnioContractual = AC.IdAnioContractual
                JOIN dbo.CO_Contrato C (NOLOCK)
                    ON AC.IdContrato = C.IdContrato
            WHERE P.nombre LIKE '%exploración%'
                  AND C.IdContratista IN ( 10005, 10006 )
        )
        BEGIN
            DELETE FROM #Presupuestos
            INSERT INTO #Presupuestos
            (
                IdPresupuesto
            )
            SELECT P.IdPresupuesto
            FROM dbo.CO_Presupuesto P (NOLOCK)
                JOIN dbo.CO_AnioContractual AC (NOLOCK)
                    ON P.IdAnioContractual = AC.IdAnioContractual
                JOIN dbo.CO_Contrato C (NOLOCK)
                    ON AC.IdContrato = C.IdContrato
            WHERE C.IdContrato = @IdContrato
                  AND P.nombre LIKE '%exploración%'
                  AND C.IdContratista IN ( 10005, 10006 );
        END;
    END
    ELSE
    BEGIN
        IF 1 =
        (
            SELECT COUNT(1)
            FROM dbo.CO_Presupuesto P (NOLOCK)
                JOIN dbo.CO_AnioContractual AC (NOLOCK)
                    ON P.IdAnioContractual = AC.IdAnioContractual
                JOIN dbo.CO_Contrato C (NOLOCK)
                    ON AC.IdContrato = C.IdContrato
            WHERE P.IdPresupuesto = @IdPresupuesto
                  AND P.Nombre LIKE '%exploración%'
                  AND C.IdContratista IN ( 10005, 10006 )
        )
        BEGIN
            INSERT INTO #Presupuestos
            (
                IdPresupuesto
            )
            SELECT P.IdPresupuesto
            FROM dbo.CO_Presupuesto P (NOLOCK)
                JOIN dbo.CO_AnioContractual AC (NOLOCK)
                    ON P.IdAnioContractual = AC.IdAnioContractual
                JOIN dbo.CO_Contrato C (NOLOCK)
                    ON AC.IdContrato = C.IdContrato
            WHERE C.IdContrato = @IdContrato
                  AND P.Nombre LIKE '%exploración%'
                  AND C.IdContratista IN ( 10005, 10006 );
        END;
        ELSE
        BEGIN
            INSERT INTO #Presupuestos
            (
                IdPresupuesto
            )
            SELECT @IdPresupuesto;
        END;
    END
    /*RFC*/
    INSERT INTO #RFC
    (
        RFC
    )
    SELECT 'FMP140930MW3'
    UNION
    SELECT 'SAT970701NN3';
    IF 1 =
    (
        SELECT COUNT(1)
    FROM dbo.CO_Presupuesto P (NOLOCK)
            JOIN dbo.CO_AnioContractual AC (NOLOCK)
                ON P.IdAnioContractual = AC.IdAnioContractual
            JOIN dbo.CO_Contrato C (NOLOCK)
                ON AC.IdContrato = C.IdContrato
        WHERE P.idpresupuesto = @IdPresupuesto
              AND C.IdContratista IN ( 10005, 10006 )
    )
    BEGIN
        INSERT INTO #RFC
        (
            RFC
        )
        SELECT 'FMO930803PB1'
        UNION
        SELECT 'GMS971110BTA';
    END;
    /*Consulta final*/
    SELECT ROW_NUMBER() OVER (ORDER BY R.Comentarios) AS NoCapacitacion,
           R.Comentarios AS Descripcion,
           S.RazonSocial AS RazonSocial,
           S.RFC AS RFC,
           SUM(   CASE
                      WHEN F.IdMoneda = 1 THEN
                          CAST(ROUND((ISNULL(R.MontoRegistro, 0)), 2) AS DECIMAL(20, 2))
                      ELSE
                          CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro, F.Fecha) AS DECIMAL(20, 2))
                  END
              ) AS SubTotal,
           R.PCN AS PCN,
           F.IdFactura,
           R.IdAceptacionPedidoDetalle
    INTO #DATOS
    FROM dbo.CO_Registro R (NOLOCK)
        JOIN dbo.FI_Factura F (NOLOCK)
            ON R.IdFactura = F.IdFactura
        JOIN dbo.PV_Subcontratista S (NOLOCK)
            ON F.IdSubcontratista = S.IdSubcontratista
        JOIN dbo.CO_LineaPresupuestoMes L (NOLOCK)
            ON R.IdPrograma = L.IdLineaPresupuestoMeS
        JOIN #Presupuestos PP
            ON L.IdPresupuesto = PP.IdPresupuesto
        JOIN dbo.CO_Presupuesto P (NOLOCK)
            ON PP.IdPresupuesto = P.IdPresupuesto
        JOIN dbo.CO_ProgramaActividad PA (NOLOCK)
            ON P.IdProgramaActividad = PA.IdProgramaActividad
        JOIN dbo.CO_TipoProgramaActividad TPA (NOLOCK)
            ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
    WHERE (
              CAST(F.Fecha AS DATE) >= @FInicio
              AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin)
          )
          AND R.IdGastoRubro = 4
          AND S.RFC NOT IN (
                               SELECT RFC FROM #RFC
                           )
          AND F.IdContrato = @IdContrato
		    AND ISNULL(R.PCN, 0) >= 0
          AND F.IdMoneda IN ( 1, 2 )
    GROUP BY R.Comentarios,
             S.RazonSocial,
             S.RFC,
             R.PCN,
             F.IdFactura,
             R.IdAceptacionPedidoDetalle
    ORDER BY F.IdFactura;
    /*SELECT FINAL*/
    SELECT NoCapacitacion,
           Descripcion,
           RazonSocial,
           RFC,
           ISNULL(CAST(SUM(SubTotal) AS DECIMAL(20, 2)), 0) AS SubTotal,
           ISNULL(CAST(SUM(PCN) / COUNT(IdFactura) AS DECIMAL(20, 3)), 0) AS PCN,
           ISNULL(
                     CAST(CAST(SUM(SubTotal) AS DECIMAL(20, 2)) * CAST(SUM(PCN) / COUNT(IdFactura) AS DECIMAL(20, 3)) AS DECIMAL(20, 2)),
                     0
                 ) AS CN,
           IdFactura
    FROM #DATOS
    GROUP BY NoCapacitacion,
             Descripcion,
             RazonSocial,
             RFC,
             IdFactura;
END;

