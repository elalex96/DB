USE Adinco;
GO
CREATE PROCEDURE [dbo].[SP_SE_A2_MPY]-- 10039,10109,10205,'20210101','20211201',10209,'Exploración'
    @IdContrato INT,
    @IdUsuario INT,
    @IdPresupuesto INT,
    @FInicio DATE,
    @FFin DATE,
    @IdPeriodo INT,
    @Etapa VARCHAR(20)
AS
BEGIN
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
            DELETE FROM #Presupuestos;
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
    /*Facturas de Adinco*/
    CREATE TABLE #FacturasAdinco
    (
        IdFactura INT,
        UUID VARCHAR(500),
        RFC VARCHAR(50),
		EncontradoPetrovendor INT
    );
    INSERT INTO #FacturasAdinco
    (
        IdFactura,
        UUID,
        RFC,
		EncontradoPetrovendor
    )
    SELECT DISTINCT
        F.IdFactura,
        F.UUID,
        S.RFC,
		0
    FROM Adinco.dbo.CO_Registro R (NOLOCK)
        JOIN Adinco.dbo.FI_Factura F (NOLOCK)
            ON F.IdFactura = R.IdFactura
        JOIN Adinco.dbo.PV_Subcontratista S (NOLOCK)
            ON S.IdSubcontratista = F.IdSubcontratista
        JOIN Adinco.dbo.CO_LineaPresupuestoMes L (NOLOCK)
            ON L.IdLineaPresupuestoMes = R.IdPrograma
        JOIN #Presupuestos PP 
            ON L.IdPresupuesto = PP.IdPresupuesto
        JOIN Adinco.dbo.CO_Presupuesto P (NOLOCK)
            ON P.IdPresupuesto = PP.IdPresupuesto
        JOIN Adinco.dbo.CO_ProgramaActividad PA (NOLOCK)
            ON PA.IdProgramaActividad = P.IdProgramaActividad
        JOIN Adinco.dbo.CO_TipoProgramaActividad TPA (NOLOCK)
            ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
        JOIN Adinco.dbo.CO_TipoCambioDiario TCD (NOLOCK)
            ON F.IdMoneda <> TCD.IdMoneda
               AND DAY(TCD.Fecha) = DAY(F.Fecha)
               AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
               AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
        LEFT JOIN Adinco.dbo.MM_BS_Actividad A (NOLOCK)
            ON R.IdCBSISH = A.IdActividad
    WHERE (
              CAST(F.Fecha AS DATE) >= @FInicio
              AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin)
          )
          AND S.RFC NOT IN (
                               SELECT RFC FROM #RFC
                           )
          AND F.IdContrato = @IdContrato
          AND TCD.IdMoneda IN ( 1, 2 ) 
          AND (
                  F.IdFactura IS NOT NULL
                  AND F.UUID IS NOT NULL
                  AND F.UUID <> ''
              );

		  CREATE TABLE #DATOS
        (
			IdRegistro INT NULL,
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

		SELECT ISNULL(BSA.Codigo, 'SinClasificar') AS Codigo,
               ISNULL(BSA.Nombre, 'SinClasificar') AS Descripcion,
               	ISNULL(SV.VendorName,PR.RazonSocial) AS RazonSocial,
				ISNULL(SV.TaxID,PR.RFC)  AS RFC,
               PV.ValorFactura AS SubTotal,
               FP.SubTotal AS SubTotalOriginal,
               APD.PCN AS PCN,
               FA.IdFactura,
               APD.IdAceptacionPedidoDetalle
		FROM #FacturasAdinco FA
		JOIN   Petrovendor.dbo.FI_Factura FP
			on FA.UUID = FP.uuid collate SQL_Latin1_General_CP1_CI_AS 
		JOIN 
			Petrovendor.dbo.MPY_MM_Aceptacionfactura AF on FP.IdFactura = AF.IdFactura 
		JOIN 
			petrovendor.dbo.MPY_MM_AceptacionPedido AP On AF.IdAceptacionPedido = AP.IdAceptacionPedido 
		JOIN 
			Petrovendor.dbo.MPY_MM_AceptacionCartaPCN ACP on AP.IdAceptacionPedido = ACP.IdAceptacionPedido
		JOIN 
			Petrovendor.dbo.MPY_MM_AceptacionPedidoDetalle APD on AP.IdAceptacionPedido = APD.IdAceptacionPedido
		LEFT JOIN
			Petrovendor.dbo.MPY_MM_PCN_ValoresPesos PV ON 
			APD.IdAceptacionPedidoDetalle = PV.IdAceptacionPedidoDetalle
		LEFT JOIN Petrovendor.dbo.MM_BS_Actividad AS BSA
            ON BSA.IdActividad = PV.IdCatalogoHidrocarburos
		LEFT JOIN Petrovendor.dbo.S_Proveedor AS PR  (NOLOCK)
			ON AP.IdSubContratista  = PR.RFC  
			AND PR.Activo = 1-->CTE
		LEFT JOIN dbo.CO_SAPVendor AS SV  (NOLOCK)
			ON AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS = SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS 
		WHERE  APD.ClasificacionCN = 2 --BIENES

		/*APARTADO ADINCO, se obtienen valores de adinco, ya que las facturas no existen en procura*/
		UPDATE FA
		 SET FA.EncontradoPetrovendor = 1
		FROM
		#FacturasAdinco FA
		JOIN
			#DATOS D
			ON	FA.IdFactura = D.IdFactura;

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
			JOIN
				#FacturasAdinco FA
				ON R.IdFactura = FA.IdFactura
				AND FA.EncontradoPetrovendor = 0
            JOIN dbo.FI_Factura F (NOLOCK)
                ON R.IdFactura = F.IdFactura
				AND  FA.IdFactura  = F.IdFactura
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
        WHERE  R.IdGastoRubro = 2 --BIENES
              AND S.RFC NOT IN (
                                   SELECT RFC FROM #RFC
                               )
              AND F.IdContrato = @IdContrato
              AND ISNULL(R.PCN, 0) >= 0
              AND F.IdMoneda IN ( 1, 2 )
			  AND FA.IdFactura IN (SELECT IdFactura FROM #FacturasAdinco WHERE EncontradoPetrovendor = 0)
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
			JOIN
				#FacturasAdinco FA
				ON R.IdFactura = FA.IdFactura
				AND FA.EncontradoPetrovendor = 0
            JOIN dbo.FI_Factura F (NOLOCK)
                ON R.IdFactura = F.IdFactura
				AND  FA.IdFactura  = F.IdFactura
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
        WHERE  R.IdGastoRubro = 2 --BIENES
              AND S.RFC NOT IN (
                                   SELECT RFC FROM #RFC
                               )
              AND F.IdContrato = @IdContrato
			    AND ISNULL(R.PCN, 0) >= 0
              AND F.IdMoneda IN ( 1, 2 )
			  AND FA.IdFactura IN (SELECT IdFactura FROM #FacturasAdinco WHERE EncontradoPetrovendor = 0)
        ORDER BY ISNULL(A.Nombre, 'SinClasificar');


		/****************************/
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
		END