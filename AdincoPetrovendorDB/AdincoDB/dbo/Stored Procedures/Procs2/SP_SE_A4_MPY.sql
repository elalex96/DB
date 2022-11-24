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
-- Create date:		13 de Abril del 2022
-- Description:		se Actualiza el stored procedure para mostrar el nuevo catalogo 
--					de mano de obra y para tomar en cuenta gastos con PCN >=0 (issue 1890 adinco)
-- ============================================

CREATE PROCEDURE [dbo].[SP_SE_A4_MPY]--10039,10109,10205,'20210101','20211201',10209,'Exploración'
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
	CREATE TABLE #Sueldos(SueldosSalarios DECIMAL(20, 2), SueldosSalariosNacional DECIMAL(20, 2), Catalogo VARCHAR(25), CatalogoId INT);
    CREATE TABLE #FacturasAdinco
    (
        IdFactura INT,
        UUID VARCHAR(500),
        RFC VARCHAR(50),
		EncontradoPetrovendor INT
    );

	CREATE TABLE #DATOS -- Sumarizado final
        (
			SueldosSalarios DECIMAL(20, 2),
            SueldosSalariosNacional DECIMAL(20, 2),
            IdCatManoObra INT
        );

	CREATE TABLE #SueldosDatos -- Datos entre Petrovendor/adinco
        (
			SueldosSalarios DECIMAL(20, 2),
            SueldosSalariosNacional DECIMAL(20, 2),
            IdCatManoObra INT,
			IdFactura INT NULL
        );

	DECLARE @CatalogoOtrosId int=0;
	SELECT  @CatalogoOtrosId = ID FROM CO_CAT_ManoDeObra

	INSERT INTO #Sueldos(SueldosSalarios, SueldosSalariosNacional, Catalogo, CatalogoId)
	SELECT 0,0,Nombre, Id FROM CO_CAT_ManoDeObra

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


  -- Extrae datos de procura petrovendor
   INSERT INTO #SueldosDatos (SueldosSalarios, SueldosSalariosNacional, IdCatManoObra,IdFactura)
		SELECT SUM(  
					ISNULL(PV.ValorFactura, 0)
              ) AS SueldosSalarios,
           SUM(   ISNULL(PV.ValorFactura, 0) * CAST(PCN AS DECIMAL(20, 3))
              ) AS SueldosSalariosNacional,
           @CatalogoOtrosId AS IdCatManoObra,
		   Fa.IdFactura
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
		LEFT JOIN Petrovendor.dbo.MM_BS_Actividad AS BSA
            ON BSA.IdActividad = PV.IdCatalogoHidrocarburos
		LEFT JOIN Petrovendor.dbo.S_Proveedor AS PR  (NOLOCK)
			ON AP.IdSubContratista  = PR.RFC  
			AND PR.Activo = 1-->CTE
		LEFT JOIN dbo.CO_SAPVendor AS SV  (NOLOCK)
			ON AP.IdSubContratista = SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS 
		WHERE  APD.ClasificacionCN = 1
		GROUP BY FA.IdFactura; --MANO DE OBRA

	--Se verifica que facturas ya fueron encontradas en procura, para ahora buscar las facturas faltantes en adinco
	UPDATE FA
		 SET FA.EncontradoPetrovendor = 1
		FROM
		#FacturasAdinco FA
		JOIN
			#SueldosDatos D
			ON	FA.IdFactura = D.IdFactura;

	--Extrae datos de facturas en adinco, las cuales no fueron encontradas en procura
	INSERT INTO #SueldosDatos (SueldosSalarios, SueldosSalariosNacional, IdCatManoObra)
	SELECT SUM(   CASE
						WHEN f.IdMoneda <> 1 then
							CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro, f.Fecha) AS DECIMAL(20, 2))
						ELSE
							ISNULL(R.MontoRegistro, 0)
					END
				) AS SueldosSalarios,
			SUM(   CASE
						WHEN f.IdMoneda <> 1 then
							CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro, f.Fecha) AS DECIMAL(20, 2))
						ELSE
							ISNULL(R.MontoRegistro, 0)
					END * CAST(PCN AS DECIMAL(20, 3))
				) AS SueldosSalariosNacional,
			ISNULL(R.IdCatManoObra,@CatalogoOtrosId) AS IdCatManoObra
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
			ON R.IdPrograma = L.IdLineaPresupuestoMes
		JOIN #Presupuestos PP
			ON L.IdPresupuesto = PP.IdPresupuesto
		JOIN dbo.CO_Presupuesto P (NOLOCK)
			ON PP.IdPresupuesto = P.IdPresupuesto
		JOIN dbo.CO_ProgramaActividad PA (NOLOCK)
			ON P.IdProgramaActividad = PA.IdProgramaActividad
		JOIN dbo.CO_TipoProgramaActividad TPA (NOLOCK)
			ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
	WHERE  R.IdGastoRubro = 1
			AND S.RFC NOT IN (
								SELECT RFC FROM #RFC
							)
			AND F.IdContrato = @IdContrato
			AND ISNULL(R.PCN, 0) >= 0
			AND F.IdMoneda IN ( 1, 2 )
			AND FA.IdFactura IN (SELECT IdFactura FROM #FacturasAdinco WHERE EncontradoPetrovendor = 0)
	GROUP BY R.IdCatManoObra


	--SE SUMAN LOS VALORES DE ADINCO/PROCURA DE ACUERDO AL CATALOGO DE MANO DE OBRA
	INSERT INTO #DATOS (SueldosSalarios, SueldosSalariosNacional, IdCatManoObra)
	SELECT  SUM( SueldosSalarios ) AS SueldosSalarios,
			SUM( SueldosSalariosNacional) AS SueldosSalariosNacional,
			IdCatManoObra
			FROM #SueldosDatos
	GROUP BY IdCatManoObra
	
	--Se asignan a la tabla que debe retornar, de acuerdo al nombre de la subclasificación de catalogo mano de obra (Para formar el recuadro  de información)
	UPDATE S
	SET S.SueldosSalarios = D.SueldosSalarios,
	S.SueldosSalariosNacional = D.SueldosSalariosNacional
	FROM 
		#SUELDOS S
	JOIN
		#DATOS D
		ON	S.CatalogoId	=	D.IdCatManoObra
		
	
	SELECT SueldosSalarios,SueldosSalariosNacional, Catalogo FROM #SUELDOS
END;

