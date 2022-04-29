USE Adinco;
GO
CREATE PROCEDURE [dbo].[SP_SE_A6_MPY]-- 10039,10109,10205,'20210101','20211201',10209,'Exploración'
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
	  /*Facturas de Adinco*/
    CREATE TABLE #FacturasAdinco
    (
        IdFactura INT,
        UUID VARCHAR(500),
        RFC VARCHAR(50),
		EncontradoPetrovendor INT
    );
	CREATE TABLE #DATOS
        (
            Descripcion VARCHAR(50),
            SubTotal FLOAT,
            IdFactura INT
        )
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

      INSERT INTO #DATOS
        (
           
            Descripcion,
            SubTotal,
            IdFactura
        )

		SELECT  
               ISNULL(APD.DESCRIPCIONCORTA, '') AS Descripcion,
               PV.ValorFactura AS SubTotal,
               FA.IdFactura
		FROM #FacturasAdinco FA
		JOIN   Petrovendor.dbo.FI_Factura FP
			on FA.UUID = FP.UUID collate SQL_Latin1_General_CP1_CI_AS 
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
		WHERE  APD.ClasificacionCN = 5--Transferencia de Tecnologia
	

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
            Descripcion,
            SubTotal,
            IdFactura
        )
	    SELECT R.Comentarios AS Descripcion,
           SUM(   CASE
                      WHEN F.IdMoneda = 1 THEN
                          CAST(ROUND((ISNULL(R.MontoRegistro, 0)), 2) AS DECIMAL(20, 2))
                      ELSE
                          CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro, F.Fecha) AS DECIMAL(20, 2))
                  END
              ) AS SubTotal,
			  FA.IdFactura
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
    WHERE  R.IdGastoRubro = 5
          AND S.RFC NOT IN (
                               SELECT RFC FROM #RFC
                           )
		    AND ISNULL(R.PCN, 0) >= 0
          AND F.IdMoneda IN ( 1, 2 )
		  AND FA.IdFactura IN (SELECT IdFactura FROM #FacturasAdinco WHERE EncontradoPetrovendor = 0)
    GROUP BY R.Comentarios, FA.IdFactura;
	
    /*SELECT FINAL*/
    SELECT ROW_NUMBER() OVER (ORDER BY Descripcion) AS NoGasto,
           Descripcion,
           SUM(SubTotal) AS SubTotal
    FROM #DATOS
           GROUP BY   Descripcion;
  
		END