USE Adinco;
GO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-10-02
-- Description:	
-- =============================================
-- Modificado Por:	Neri del Angel
-- Create date:		01 de Abril del 2022
-- Description:	    Se agrega F.Fecha factura 
--					faltante en group by, 
--					se ajusta caso al final 
--					de la consulta de si 
--					subtotal = 0 se regrese 0
-- =============================================
-- Modificado Por:	Neri del Angel
-- Create date:		04 de Abril del 2022
-- Description:		Se agrega filtrado de todos
--					los presupuestos del periodo
--					seleccionado
-- =============================================
-- Modificado Por:	Reyna 
-- Create date:		12 de Abril del 2022
-- Description:		se Actualiza el stored procedure 
--                  para tomar en cuenta gastos con PCN >=0 (issue 1890 adinco)
-- ============================================
CREATE PROCEDURE [dbo].[SP_SE_A3]
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
    IF (@FFin <= '2018-12-01')
    BEGIN
        SELECT ISNULL(A.Codigo, 'SinClasificar') AS Codigo,
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
               ISNULL(R.PCN, 0) AS PCN,
               CASE
                   WHEN F.IdMoneda = 1 THEN
                       SUM(CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0)), 2) AS DECIMAL(20, 2)))
                   ELSE
                       CAST([dbo].[FN_DolaresPesosTipoCambio](
                                                                 SUM(CAST(ROUND(
                                                                                   (ISNULL(
                                                                                              (ISNULL(R.PCN, 0)
                                                                                               * R.MontoRegistro
                                                                                              ),
                                                                                              0
                                                                                          )
                                                                                   ),
                                                                                   2
                                                                               ) AS DECIMAL(20, 2))
                                                                    ),
                                                                 F.Fecha
                                                             ) AS DECIMAL(20, 2))
               END AS CN,
               ROW_NUMBER() OVER (ORDER BY F.IdFactura) AS ID,
               ROW_NUMBER() OVER (PARTITION BY F.IdFactura, S.RFC ORDER BY R.Comentarios) AS Repetido,
               F.IdFactura
        FROM dbo.CO_Registro R (NOLOCK)
            JOIN dbo.CO_LineaPresupuestoMes L (NOLOCK)
                ON L.IdLineaPresupuestoMes = R.IdPrograma
            JOIN #Presupuestos PP
                ON L.IdPresupuesto = PP.IdPresupuesto
            JOIN dbo.CO_Presupuesto P (NOLOCK)
                ON P.IdPresupuesto = PP.IdPresupuesto
            JOIN dbo.CO_ProgramaActividad PA (NOLOCK)
                ON PA.IdProgramaActividad = P.IdProgramaActividad
            JOIN dbo.CO_TipoProgramaActividad TPA (NOLOCK)
                ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
            LEFT JOIN dbo.CO_PCNPorPeriodos PPP (NOLOCK)
                ON PPP.IdTipoPgrogramaActividad = TPA.IdTipoProgramaActividad
            LEFT JOIN dbo.FI_Factura F (NOLOCK)
                ON F.IdFactura = R.IdFactura
            LEFT JOIN dbo.PV_Subcontratista S (NOLOCK)
                ON S.IdSubcontratista = F.IdSubcontratista
            LEFT JOIN dbo.MM_BS_Actividad A (NOLOCK)
                ON R.IdCBSISH = A.IdActividad
            LEFT JOIN dbo.CO_Servicio SE (NOLOCK)
                ON SE.IdServicio = L.IdServicio
        WHERE (
                  CAST(F.Fecha AS DATE) >= @FInicio
                  AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin)
              )
              AND R.IdGastoRubro = 3
              AND S.RFC NOT IN (
                                   SELECT RFC FROM #RFC
                               )
              AND F.IdContrato = @IdContrato
              AND ISNULL(R.PCN, 0) >= 0
              AND PPP.IdContrato = @IdContrato
        GROUP BY ISNULL(A.Codigo, 'SinClasificar'),
                 R.Comentarios,
                 S.RazonSocial,
                 S.RFC,
                 ISNULL(R.PCN, 0), 
                 F.IdFactura,
                 F.IdMoneda,
                 F.Fecha
        ORDER BY S.RFC;
    END;
    ELSE
    BEGIN
        CREATE TABLE #DATOS
        (
            IdRegistro INT,
            Codigo VARCHAR(50),
            Descripcion VARCHAR(300),
            RazonSocial VARCHAR(300),
            RFC VARCHAR(100),
            SubTotal FLOAT,
            SubTotalOriginal FLOAT,
            PCN FLOAT,
            IdFactura INT,
            IdAceptacionPedidoDetalle INT
        )
        INSERT INTO #DATOS
        (
            IdRegistro,
            Codigo,
            Descripcion,
            RazonSocial,
            RFC,
            SubTotal,
            SubTotalOriginal,
            PCN,
            IdFactura,
            IdAceptacionPedidoDetalle
        )
        SELECT r.IdRegistro,
               ISNULL(A.Codigo, 'SinClasificar') AS Codigo,
               ISNULL(A.Nombre, 'SinClasificar') AS Descripcion,
               S.RazonSocial AS RazonSocial,
               S.RFC AS RFC,
               CASE
                   WHEN F.IdMoneda = 1 THEN
                       CAST(R.MontoRegistro AS DECIMAL(20, 2))
                   ELSE
                       CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro, F.Fecha) AS DECIMAL(20, 2))
               END AS SubTotal,
               F.SubTotal AS SubTotalOriginal,
               R.PCN AS PCN,
               F.IdFactura,
               R.IdAceptacionPedidoDetalle
        FROM dbo.CO_Registro R (NOLOCK)
            JOIN dbo.FI_Factura F (NOLOCK)
                ON R.IdFactura = F.IdFactura
            JOIN dbo.PV_Subcontratista S (NOLOCK)
                ON F.IdSubcontratista = S.IdSubcontratista
                   AND S.TipoPersonaFiscalID = 2
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
            LEFT JOIN dbo.MM_BS_Actividad A (NOLOCK)
                ON R.IdCBSISH = A.IdActividad
        WHERE (
                  CAST(F.Fecha AS DATE) >= @FInicio
                  AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin)
              )
              AND R.IdGastoRubro = 3
              AND S.RFC NOT IN (
                                   SELECT RFC FROM #RFC
                               )
              AND F.IdContrato = @IdContrato
              AND ISNULL(R.PCN, 0) >= 0
              AND F.IdMoneda IN ( 1, 2 )
        --  
        UNION
        --  
        SELECT r.IdRegistro,
               ISNULL(A.Codigo, 'SinClasificar') AS Codigo,
               ISNULL(A.Nombre, 'SinClasificar') AS Descripcion,
               S.RazonSocial AS RazonSocial,
               S.RFC AS RFC,
               CASE
                   WHEN f.IdMoneda <> 1 then
                       CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro, f.Fecha) AS DECIMAL(20, 2))
                   ELSE
                       ISNULL(R.MontoRegistro, 0)
               END AS SubTotal,
               F.SubTotal AS SubTotalOriginal,
               R.PCN AS PCN,
               F.IdFactura,
               R.IdAceptacionPedidoDetalle
        FROM dbo.CO_Registro R (NOLOCK)
            JOIN dbo.FI_Factura F (NOLOCK)
                ON R.IdFactura = F.IdFactura
            JOIN dbo.PV_Subcontratista S (NOLOCK)
                ON F.IdSubcontratista = S.IdSubcontratista
                   AND S.TipoPersonaFiscalID = 1
            JOIN dbo.CO_LineaPresupuestoMes L (NOLOCK)
                ON R.IdPrograma = L.IdLineaPresupuestoMeS
            JOIN #Presupuestos PP (NOLOCK)
                ON L.IdPresupuesto = PP.IdPresupuesto
            JOIN dbo.CO_Presupuesto P (NOLOCK)
                ON PP.IdPresupuesto = P.IdPresupuesto
            JOIN dbo.CO_ProgramaActividad PA (NOLOCK)
                ON P.IdProgramaActividad = PA.IdProgramaActividad
            JOIN dbo.CO_TipoProgramaActividad TPA (NOLOCK)
                ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
            LEFT JOIN dbo.MM_BS_Actividad A (NOLOCK)
                ON R.IdCBSISH = A.IdActividad
        WHERE (
                  CAST(F.Fecha AS DATE) >= @FInicio
                  AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin)
              )
              AND R.IdGastoRubro = 3
              AND S.RFC NOT IN (
                                   SELECT RFC FROM #RFC
                               )
              AND F.IdContrato = @IdContrato
			    AND ISNULL(R.PCN, 0) >= 0
              AND F.IdMoneda IN ( 1, 2 )
        ORDER BY ISNULL(A.Nombre, 'SinClasificar');
        /*SELECT FINAL*/
        SELECT Codigo,
               Descripcion,
               RazonSocial,
               RFC,
               SUM(SubTotal) AS SubTotal,
               SUM(SubTotal * PCN) AS PCN,
               IdFactura
        INTO #FINAL
        FROM #DATOS
        GROUP BY Codigo,
                 Descripcion,
                 RazonSocial,
                 RFC,
                 IdFactura;
        /**/
        SELECT Codigo,
               Descripcion,
               RazonSocial,
               RFC,
               ISNULL(SUM(SubTotal), 0) AS SubTotal,
               CASE
                   WHEN SUM(SubTotal) = 0 THEN
                       0
                   ELSE
                       ISNULL(
                                 CAST(SUBSTRING(
                                                   LTRIM(SUM(PCN) / SUM(SubTotal)),
                                                   1,
                                                   CHARINDEX('.', LTRIM(SUM(PCN) / SUM(SubTotal))) + 3
                                               ) AS FLOAT),
                                 0
                             )
               END AS PCN,
               CASE
                   WHEN SUM(SubTotal) = 0 THEN
                       0
                   ELSE
                       ISNULL(
                                 (SUM(SubTotal)
                                  * CAST(SUBSTRING(
                                                      LTRIM(SUM(PCN) / SUM(SubTotal)),
                                                      1,
                                                      CHARINDEX('.', LTRIM(SUM(PCN) / SUM(SubTotal))) + 3
                                                  ) AS FLOAT)
                                 ),
                                 0
                             )
               END AS CN,
               IdFactura
        FROM #FINAL
      GROUP BY Codigo,
                 Descripcion,
                 RazonSocial,
                 RFC,
                 IdFactura
        ORDER BY RazonSocial,
                 Descripcion,
                 IdFactura
    END;
END;

