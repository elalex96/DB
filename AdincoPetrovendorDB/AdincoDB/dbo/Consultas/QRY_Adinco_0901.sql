	USE Adinco;
	GO
--
    IF OBJECT_ID('tempdb..#Facturas', 'U') IS NOT NULL
        DROP TABLE #Facturas;

	IF OBJECT_ID('tempdb..#PedimentosComprobantes', 'U') IS NOT NULL
        DROP TABLE #PedimentosComprobantes;

	IF OBJECT_ID('tempdb..#Gastos', 'U') IS NOT NULL
     DROP TABLE #Gastos;
	
	IF OBJECT_ID('tempdb..#FacturasPagadas', 'U') IS NOT NULL
     DROP TABLE #FacturasPagadas;
	 	
	IF OBJECT_ID('tempdb..#PedimentosPagados', 'U') IS NOT NULL
     DROP TABLE #PedimentosPagados;

	 IF OBJECT_ID('tempdb..#temp', 'U') IS NOT NULL
     DROP TABLE #temp;
	  declare @NombrePresupuesto varchar (150) = 'Provisional Cárdenas-Mora 2018-';
		--
    CREATE TABLE #Gastos --gastos del presupuesto 
    (IdRegistro      INT, 
    IdFactura       INT, 
	IdPrograma INT,
	IdPedimentoComprobante INT,
    MontoRegistro   FLOAT, 
	MontoRegistroUSD FLOAT,
    CvTipoDocFacturacion INT,
	IdContrato INT
	 ); 

    CREATE TABLE #Facturas --facturas
    (
	IdFactura       INT, 
	UUID            NVARCHAR(500), 
	TipoComprobante NVARCHAR(50),
	MontoRegistroTotal FLOAT,
	MontoPagadoTotalUSD FLOAT,
	MontoPagadoTotalPESOS FLOAT,
	MontoPendientePago FLOAT,
	SubTotalFactura FLOAT,
	MontoTotalIvaFactura FLOAT,
    RC2122USD          FLOAT, 
	MetodoPago      NVARCHAR(50), 
    Fecha           DATETIME,
	IdMoneda        INT,
	CantidadGastos INT
    );

    CREATE TABLE #PedimentosComprobantes 
    (
    IdPedimentoComprobante       INT, 
    MontoRegistroTotal   FLOAT, 
	MontoPagadoTotalUSD FLOAT,
	MontoPendientePago FLOAT,
    RC2122USD          FLOAT, 
    IdMoneda        INT,
	CantidadGastos INT
    );

	CREATE TABLE #FacturasPagadas 
    (
    	IdFactura       INT, 
		MontoPagadoUSD   FLOAT,
		MontoPagadoPESOS   FLOAT
    );

	CREATE TABLE #PedimentosPagados 
    (
    	IdPedimentoComprobante       INT, 
		MontoPagado   FLOAT
    );

	INSERT INTO  #Gastos
    (IdRegistro, 
     MontoRegistro,
	 IdPrograma,
	 IdFactura, 
	 IdPedimentoComprobante,
     CvTipoDocFacturacion,
	 IdContrato,
	 MontoRegistroUSD)
	 SELECT		R.IdRegistro, 
                R.MontoRegistro,
				R.IdPrograma,
				R.IdFactura,
				R.IdPedimentoComprobante,
				R.CvTipoDocFacturacion,
				AC.IdContrato,
				CASE
                        WHEN ISNULL(R.MontoRegistro, 0) <> 0
                        THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        ELSE 0
                    END
        FROM dbo.CO_Registro R WITH(NOLOCK)
				LEFT JOIN
						dbo.FI_Factura AS F WITH (NOLOCK) 
						ON  R.IdFactura	=	F.IdFactura
                LEFT JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
				LEFT JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON LPM.IdPresupuesto = P.IdPresupuesto
				LEFT JOIN CO_AnioContractual	AC ON P.IdAnioContractual = AC.IdAnioContractual
                LEFT JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio
                                                    AND AC.IdContrato  = S.IdContrato
				LEFT JOIN 
					dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) 
					ON TCD.IdMoneda = F.IdMoneda
					AND DAY(TCD.Fecha) = DAY(F.Fecha)
					AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
					AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
        WHERE P.Nombre =@NombrePresupuesto --2018 (tiene un guion "provisional"),2019,2020,2021,2022
		AND	AC.IdContrato = 10036
		 AND R.CvTipoDocFacturacion = 1--		AND	F.IdFactura IS NOT NULL AND	F.IdFactura >0;


			INSERT INTO  #Gastos
    (IdRegistro, 
     MontoRegistro,
	 IdPrograma,
	 IdFactura, 
	 IdPedimentoComprobante,
     CvTipoDocFacturacion,
	 IdContrato,
	 MontoRegistroUSD)
	 SELECT		R.IdRegistro, 
                R.MontoRegistro,
				R.IdPrograma,
				R.IdFactura,
				R.IdPedimentoComprobante,
				R.CvTipoDocFacturacion,
				AC.IdContrato,
					CASE
                        WHEN ISNULL(R.MontoRegistro, 0) <> 0
                        THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCDPC.TipoCambio), 2) AS DECIMAL(15, 2))
                        ELSE 0
                    END
        FROM dbo.CO_Registro R WITH(NOLOCK)
                LEFT JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
				LEFT JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON LPM.IdPresupuesto = P.IdPresupuesto
				LEFT JOIN CO_AnioContractual	AC ON P.IdAnioContractual = AC.IdAnioContractual
                LEFT JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio
                                                    AND AC.IdContrato  = S.IdContrato
				LEFT JOIN
						dbo.FI_PedimentoComprobante AS PC WITH (NOLOCK) 
						ON R.IdPedimentoComprobante	=	PC.IdPedimentoComprobante 
				LEFT JOIN
					dbo.CO_TipoCambioDiario AS TCDPC WITH (NOLOCK) 
					ON TCDPC.IdMoneda = PC.IdMoneda 
					AND DAY(TCDPC.Fecha) = DAY(PC.FechaPago) 
					AND MONTH(TCDPC.Fecha) = MONTH(PC.FechaPago) 
					AND YEAR(TCDPC.Fecha) = YEAR(PC.FechaPago) 
        WHERE P.Nombre =@NombrePresupuesto
			AND	AC.IdContrato = 10036
			AND	R.IdPedimentoComprobante IS NOT NULL AND	R.IdPedimentoComprobante >0 
			AND R.CvTipoDocFacturacion IN (2, 3) 
	  --SELECT SUM(MontoRegistroUSD) FROM #Gastos 
				/*
				Provisional Cárdenas-Mora 2018-
Desarrollo Cárdenas-Mora 2019
Desarrollo Cárdenas-Mora 2020
Desarrollo Cárdenas-Mora 2021
				*/


	-- FACTURAS DE LOS GASTOS
    INSERT INTO #Facturas
    (IdFactura,
     UUID, 
    TipoComprobante, 
	MontoRegistroTotal,
    RC2122USD, 
    MetodoPago, 
    Fecha, 
    IdMoneda,
	SubTotalFactura,
	MontoTotalIvaFactura,
	CantidadGastos
    )
        SELECT  F.IdFactura, 
                ISNULL(F.UUID, 'NÚMERO NO REGISTRADO') AS UUID, 
                CASE
                    WHEN F.TipoComprobante LIKE '%ingreso%'
                        OR F.TipoComprobante LIKE 'I%'
                    THEN 'I'
                    WHEN(F.TipoComprobante) LIKE '%egreso%'
                        OR F.TipoComprobante LIKE 'E%'
                    THEN 'E'
                    WHEN(F.TipoComprobante) LIKE '%traslado%'
                        OR F.TipoComprobante LIKE 'T%'
                    THEN 'T'
                    WHEN(F.TipoComprobante) LIKE '%nómina%'
                        OR F.TipoComprobante LIKE 'N%'
                    THEN 'N'
                    WHEN(F.TipoComprobante) LIKE '%pago%'
                        OR F.TipoComprobante LIKE 'P%'
                    THEN 'P'
                    ELSE 'NA'
                END AS TipoComprobante,
				SUM(R.MontoRegistro),
                SUM(CASE
                        WHEN ISNULL(R.MontoRegistro, 0) <> 0
                        THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        ELSE 0
                    END) AS [RC21_22],
                CASE
                    WHEN F.MetodoPago LIKE '%exhibi%'
                        OR F.MetodoPago LIKE '%PUE%'
                        OR F.FormaPago LIKE '%exhibi%'
                        OR F.FormaPago LIKE '%PUE%'
                    THEN 'PUE'
                    WHEN F.MetodoPago LIKE '%parcia%'
                        OR F.MetodoPago LIKE '%dife%'
                        OR F.MetodoPago LIKE '%PPD%'
                        OR F.FormaPago LIKE '%parcia%'
                        OR F.FormaPago LIKE '%dife%'
                        OR F.FormaPago LIKE '%PPD%'
                    THEN 'PPD'
                    WHEN F.TipoComprobante = 'P'
                    THEN 'PPD'
                END AS MetodoPago, 
                F.Fecha, 
                F.IdMoneda,
				F.SubTotal,
				F.MontoConIva,
				COUNT(R.IdRegistro)
       FROM	#Gastos R	WITH (NOLOCK) 
	   JOIN
			FI_Factura	F	WITH (NOLOCK) 
			ON	R.IdFactura	=	F.IdFactura
       LEFT JOIN 
			dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) 
			ON TCD.IdMoneda = F.IdMoneda
            AND DAY(TCD.Fecha) = DAY(F.Fecha)
            AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
            AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
        WHERE R.CvTipoDocFacturacion = 1
        GROUP BY 
                    ISNULL(F.UUID, 'NÚMERO NO REGISTRADO'), 
                    F.IdFactura,
                    CASE
                        WHEN F.TipoComprobante LIKE '%ingreso%'
                            OR F.TipoComprobante LIKE 'I%'
                        THEN 'I'
                        WHEN(F.TipoComprobante) LIKE '%egreso%'
                            OR F.TipoComprobante LIKE 'E%'
                        THEN 'E'
                        WHEN(F.TipoComprobante) LIKE '%traslado%'
                            OR F.TipoComprobante LIKE 'T%'
                        THEN 'T'
                        WHEN(F.TipoComprobante) LIKE '%nómina%'
                            OR F.TipoComprobante LIKE 'N%'
                        THEN 'N'
                        WHEN(F.TipoComprobante) LIKE '%pago%'
                            OR F.TipoComprobante LIKE 'P%'
                        THEN 'P'
                        ELSE 'NA'
                    END,
                    CASE
                        WHEN F.MetodoPago LIKE '%exhibi%'
                            OR F.MetodoPago LIKE '%PUE%'
                            OR F.FormaPago LIKE '%exhibi%'
                            OR F.FormaPago LIKE '%PUE%'
                        THEN 'PUE'
                        WHEN F.MetodoPago LIKE '%parcia%'
                            OR F.MetodoPago LIKE '%dife%'
                            OR F.MetodoPago LIKE '%PPD%'
                            OR F.FormaPago LIKE '%parcia%'
                            OR F.FormaPago LIKE '%dife%'
                            OR F.FormaPago LIKE '%PPD%'
                        THEN 'PPD'
                        WHEN F.TipoComprobante = 'P'
                        THEN 'PPD'
                    END, 
                    F.Fecha, 
                    F.IdMoneda,	
					F.SubTotal,
					F.MontoConIva;

	
	INSERT INTO #PedimentosComprobantes
		( 
		IdPedimentoComprobante       , 
		MontoRegistroTotal, 
		RC2122USD, 
		IdMoneda,
		CantidadGastos)
			SELECT 
				P.IdPedimentoComprobante, 
				SUM(R.MontoRegistro),
				SUM(CASE
						WHEN ISNULL(R.MontoRegistro, 0) <> 0
						THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCDP.TipoCambio), 2) AS DECIMAL(15, 2))
						ELSE 0
					END) ,
				P.IdMoneda,
				COUNT(R.IdRegistro)
        FROM 
				#Gastos R	WITH (NOLOCK) 
			JOIN
				FI_PedimentoComprobante P	WITH (NOLOCK) 
				ON	 R.IdPedimentoComprobante	=	P.IdPedimentoComprobante
            LEFT JOIN 
				dbo.FI_TransferFactura TF WITH(NOLOCK) 
				ON TF.IdPedimentoComprobante = P.IdPedimentoComprobante
            LEFT JOIN 
				dbo.FI_Transfer T WITH(NOLOCK) 
				ON T.IdTransferencia = TF.IdTransfer
            LEFT JOIN 
				dbo.CO_TipoCambioDiario TCDP WITH(NOLOCK) 
				ON TCDP.IdMoneda = P.IdMoneda
                AND DAY(TCDP.Fecha) = DAY(T.FechaPago)
                AND MONTH(TCDP.Fecha) = MONTH(T.FechaPago)
                AND YEAR(TCDP.Fecha) = YEAR(T.FechaPago)
        WHERE R.CvTipoDocFacturacion IN(2, 3)
        GROUP BY P.IdPedimentoComprobante,  P.IdMoneda;
		
		

	--	SELECT * FROM #GASTOS;
	--	SELECT * FROM #Facturas
	--	SELECT * FROM #PedimentosComprobantes



-- B8B30268-7B92-4E8E-933C-65E85005C745	 TR EN 

     INSERT INTO #FacturasPagadas (
		MontoPagadoPESOS,
		MontoPagadoUSD,
    	IdFactura)
                SELECT
                       ISNULL(CAST(SUM(CPDR.ImpPagado) AS DECIMAL(15, 2)),0) AS MontoPesos, 
                       CAST(SUM(CASE
                                    WHEN TM.IdMoneda = 1
                                    THEN CPDR.ImpPagado / TCD.TipoCambio
                                    ELSE CPDR.ImpPagado
                                END) AS DECIMAL(15, 2)) AS MontoDolares, 
                    
					    FCPDR.IdFactura
                FROM dbo.FI_Transfer T WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
                     JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON CP.IdFactura = F.IdFactura
                     JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
                     JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
                                                               AND F.IdContrato = FCPDR.IdContrato
                                                               AND F.IdContrato = T.IdContrato
                     JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto
                     JOIN #Facturas FT ON FT.Idfactura = FCPDR.IdFactura
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                           AND TCD.IdMoneda = FCPDR.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                WHERE FT.MetodoPago = 'PPD'
                      AND TF.CvTipoDocFacturacion = 6
                      AND TCD.IdMoneda = FCPDR.IdMoneda
                GROUP BY 
						  FCPDR.IdFactura
                UNION
                SELECT
                       ISNULL(CAST((SUM(CPDR.ImpPagado * TCD.TipoCambio)) AS DECIMAL(15, 2)),0) AS MontoPesos, 
                       CAST((SUM(CASE
                                     WHEN TM.IdMoneda = 2
                                     THEN CPDR.ImpPagado / TCD.TipoCambio
                                     ELSE CPDR.ImpPagado
                                 END)) AS DECIMAL(15, 2)) AS MontoDolares, 
					    FCPDR.IdFactura
                FROM dbo.FI_Transfer T WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
                     JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON CP.IdFactura = F.IdFactura
                     JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
                     JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
                                                               AND F.IdContrato = FCPDR.IdContrato
                                                               AND F.IdContrato = T.IdContrato
                     JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto
                     JOIN #Facturas ON #Facturas.Idfactura = FCPDR.IdFactura
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                           AND TCD.IdMoneda <> FCPDR.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                WHERE #Facturas.MetodoPago = 'PPD'
                      AND TF.CvTipoDocFacturacion = 6
					  AND T.IdMoneda <> TM.IdMoneda
                      AND TM.IdMoneda = FCPDR.IdMoneda
                GROUP BY 
						  FCPDR.IdFactura
				UNION
				--Se agrego para los casos donde el complemento es igual a la moneda de la transferencia (USD = USD)
				--y la factura ppd es igual a la moneada del documento relacionado (MXN = MXN)
				SELECT 
						ISNULL(CAST((SUM(
										CASE 
										WHEN TM.IdMoneda = 2
											AND FCPDR.IdMoneda = 1 
										THEN CPDR.ImpPagado * 1 --TCD.TipoCambio
										END
										)
										
										) AS DECIMAL(15, 2)),0) AS MontoPesos,
										 
						CAST((SUM(CASE
										WHEN TM.IdMoneda = 2 AND FCPDR.IdMoneda = 1
										THEN CPDR.ImpPagado / TCDUSDAUSD.TipoCambio
										WHEN TM.IdMoneda =1 AND FCPDR.IdMoneda = 2 AND TMCPDR.IdMoneda = 1
										THEN CPDR.ImpPagado / TCDMXAUSD.TipoCambio
										ELSE CPDR.ImpPagado
									END)) AS DECIMAL(15, 2)) AS MontoDolares, 
						
						 FCPDR.IdFactura
						--, TM.IdMoneda AS TM, TMCPDR.IdMoneda as TMCPDR,FCPDR.IdMoneda as FCPDR,T.IdMoneda AS T,F.IdMoneda AS F, CPDR.MonedaDR, CP.MonedaP, TCDUSDAUSD.TipoCambio, TCDUSDAUSD.IdMoneda,TCDUSDAUSD.Fecha,TCDMXAUSD.TipoCambio, TCDMXAUSD.IdMoneda,TCDMXAUSD.Fecha, FCPDR.UUID,CPDR.ImpPagado 
				FROM dbo.FI_Transfer T WITH(NOLOCK)
						JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
						JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
						JOIN dbo.FI_Factura F WITH(NOLOCK) ON CP.IdFactura = F.IdFactura
						JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
						JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
																AND F.IdContrato = FCPDR.IdContrato
																AND F.IdContrato = T.IdContrato
						JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto
						JOIN dbo.PV_TipoMoneda TMCPDR WITH(NOLOCK) ON CPDR.MonedaDR = TMCPDR.TipoMonedaCorto
						JOIN #Facturas ON #Facturas.Idfactura = FCPDR.IdFactura
						LEFT JOIN dbo.CO_TipoCambioDiario TCDUSDAUSD WITH(NOLOCK) ON  DAY(TCDUSDAUSD.Fecha) = DAY(T.FechaPago)
																			AND MONTH(TCDUSDAUSD.Fecha) = MONTH(T.FechaPago)
																			AND YEAR(TCDUSDAUSD.Fecha) = YEAR(T.FechaPago)
																			AND TCDUSDAUSD.IdMoneda	=	2 
						LEFT JOIN dbo.CO_TipoCambioDiario TCDMXAUSD WITH(NOLOCK) ON 
																			 DAY(TCDMXAUSD.Fecha) = DAY(T.FechaPago)
																			AND MONTH(TCDMXAUSD.Fecha) = MONTH(T.FechaPago)
																			AND YEAR(TCDMXAUSD.Fecha) = YEAR(T.FechaPago)
																			AND TCDMXAUSD.IdMoneda	=	1
				WHERE #Facturas.MetodoPago = 'PPD'
						AND TF.CvTipoDocFacturacion = 6
						AND T.IdMoneda = TM.IdMoneda
						AND TM.IdMoneda <> FCPDR.IdMoneda
				GROUP BY 
							 FCPDR.IdFactura
							 --,TM.IdMoneda,T.IdMoneda,F.IdMoneda, FCPDR.IdMoneda, CPDR.MonedaDR,FCPDR.IdMoneda, CP.MonedaP, TCDUSDAUSD.TipoCambio, TCDUSDAUSD.IdMoneda,TCDUSDAUSD.Fecha,TCDMXAUSD.TipoCambio, TCDMXAUSD.IdMoneda,TCDMXAUSD.Fecha,FCPDR.UUID,CPDR.ImpPagado, TMCPDR.IdMoneda
								-- select * from FI_ComplementoDePago where IdFactura=120528	
								 --select * from FI_CPDocRelacionado where IdComplementoDePago = 13280
								--select * from CO_TipoCambioDiario where Fecha ='2019-06-28'
								--4CE18EA5-9671-4693-8E91-A69CEE58FCB3   --ya quedo 
								--D4C92642-1C63-4E1F-ABD9-3B5F8A91ECBF   -- no quedo el doc relacionado dice que es en pesos
								--247D2616-60DE-4C55-876D-566153BFFE84 --ya quedo



	IF OBJECT_ID('tempdb..#SumaDePagosDolares', 'U') IS NOT NULL
DROP TABLE #SumaDePagosDolares;
--
         SELECT Con.UUID, 
                Con.Idfactura, 
               Con.TipoComprobante, 
                SUM(Con.MontoDolares) AS MontoDolares, 
               Con.MetodoPago, 
                MAX(Con.TipoCambio) AS TipoCambio, 
               MAX(Con.Fecha) AS Fecha, 
                Con.IdMoneda
         INTO #SumaDePagosDolares
         FROM
         (
             SELECT DISTINCT 
                    MCF.UUID, 
                    MCF.Idfactura, 
                    MCF.TipoComprobante,
                    CASE
                        WHEN ISNULL(TF.MontoPagado, 0) <> 0
                        THEN CAST(ROUND((ISNULL(TF.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        ELSE 0
                    END AS MontoDolares, 
                    MCF.MetodoPago, 
                    TCD.TipoCambio AS TipoCambio, 
                    TCD.Fecha, 
                    MCF.IdMoneda, 
                    T.IdMoneda AS MonedaTran, 
                    T.IdTransferencia
             FROM dbo.FI_Transfer T WITH(NOLOCK)
                  JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON T.IdTransferencia = TF.IdTransfer
                  JOIN #Facturas MCF ON TF.IdFactura = MCF.Idfactura
                  LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = MCF.IdMoneda
                                                                        AND TCD.IdMoneda = T.IdMoneda
                                                                        AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                        AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                        AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
             WHERE MCF.MetodoPago IN ('PUE','PPD')
                   AND TCD.IdMoneda = MCF.IdMoneda 
				   
             --
             UNION
             --
             SELECT DISTINCT 
                    MCF.UUID, 
                    MCF.Idfactura, 
                    MCF.TipoComprobante,
                    CASE
                        WHEN T.IdMoneda = 1
                             AND F.IdMoneda = 2
                        THEN CAST(ROUND((ISNULL(TF.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        WHEN T.IdMoneda = 2
                             AND F.IdMoneda = 1
                        THEN TF.MontoPagado
                    END AS MontoDolares, 
                    MCF.MetodoPago,
                    CASE
                        WHEN T.IdMoneda = 1
                             AND F.IdMoneda = 2
                        THEN 1
                        WHEN T.IdMoneda = 2
                             AND F.IdMoneda = 1
                        THEN TCD.TipoCambio
                    END AS TipoCambio, 
                    TCD.Fecha, 
                    MCF.IdMoneda, 
                    T.IdMoneda AS MonedaTran, 
                    T.IdTransferencia
             FROM dbo.FI_Transfer T WITH(NOLOCK)
                  JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON T.IdTransferencia = TF.IdTransfer
                  JOIN #Facturas MCF ON TF.IdFactura = MCF.Idfactura
                  JOIN dbo.FI_Factura F WITH(NOLOCK) ON MCF.Idfactura = F.IdFactura
                  LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = T.IdMoneda
                                                                        AND TCD.IdMoneda <> F.IdMoneda
                                                                        AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                        AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                        AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
             WHERE MCF.MetodoPago IN ('PUE','PPD')
                   AND TCD.IdMoneda <> F.IdMoneda
				
         ) AS Con
         GROUP BY Con.UUID, 
                  Con.Idfactura, 
                  Con.TipoComprobante, 
                  Con.MetodoPago, 
                  Con.IdMoneda;

		INSERT INTO #FacturasPagadas (MontoPagadoPESOS,IdFactura,MontoPagadoUSD)
		SELECT DISTINCT 
		0,
        MCF.Idfactura, 
        SPD.MontoDolares--, 
FROM #Facturas MCF
        JOIN #SumaDePagosDolares SPD ON MCF.Idfactura = SPD.Idfactura
WHERE MCF.MetodoPago IN ('PUE','PPD') 
			
--Facturas PUE
	INSERT INTO #PedimentosPagados(IdPedimentoComprobante,MontoPagado)
	 SELECT			  
                       P.IdPedimentoComprobante, 
                       SUM(CASE
                               WHEN ISNULL(G.MontoRegistro, 0) <> 0
                               THEN CAST(ROUND((ISNULL(G.MontoRegistro, 0) / TCDP.TipoCambio), 2) AS DECIMAL(15, 2))
                               ELSE 0
                           END) AS [RC21_22]
                FROM #Gastos G WITH(NOLOCK)
                     JOIN dbo.FI_PedimentoComprobante P WITH(NOLOCK) ON G.IdPedimentoComprobante =  P.IdPedimentoComprobante
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdPedimentoComprobante = P.IdPedimentoComprobante
                     JOIN dbo.FI_Transfer T WITH(NOLOCK) ON T.IdTransferencia = TF.IdTransfer
                     LEFT JOIN dbo.CO_TipoCambioDiario TCDP WITH(NOLOCK) ON TCDP.IdMoneda = P.IdMoneda
                                                                            AND DAY(TCDP.Fecha) = DAY(T.FechaPago)
                                                                            AND MONTH(TCDP.Fecha) = MONTH(T.FechaPago)
                                                                            AND YEAR(TCDP.Fecha) = YEAR(T.FechaPago)
                GROUP BY P.IdPedimentoComprobante




	UPDATE F
	SET F.MontoPagadoTotalUSD = ISNULL(FP.MontoPagadoUSD,0)
	FROM 
		#Facturas	F	WITH (NOLOCK) 
	LEFT JOIN 
		#FacturasPagadas	FP	WITH (NOLOCK) 
		ON	F.IdFactura	=	FP.IdFactura

	
	UPDATE P
	SET P.MontoPagadoTotalUSD = ISNULL(PD.MontoPagado,0)
	FROM 
		#PedimentosComprobantes	P WITH (NOLOCK) 
	LEFT JOIN 
		#PedimentosPagados	PD WITH (NOLOCK) 
		ON	P.IdPedimentoComprobante	=	PD.IdPedimentoComprobante

	
	UPDATE F
	SET F.MontoPendientePago = ISNULL(F.RC2122USD,0) - ISNULL(F.MontoPagadoTotalUSD,0)
	FROM 
		#Facturas	F	WITH (NOLOCK) 
	LEFT JOIN 
		#FacturasPagadas	FP	WITH (NOLOCK) 
		ON	F.IdFactura	=	FP.IdFactura

	
	UPDATE P
	SET P.MontoPendientePago = ISNULL(P.RC2122USD,0) - ISNULL(P.MontoPagadoTotalUSD,0)
	FROM 
		#PedimentosComprobantes	P WITH (NOLOCK) 
	LEFT JOIN 
		#PedimentosPagados	PD WITH (NOLOCK) 
		ON	P.IdPedimentoComprobante	=	PD.IdPedimentoComprobante;

	
	SELECT      C.NumeroContrato, 
				ACC.NombreAreaContractual, 
				R.IdRegistro, 
				S.NombreServicio AS Servicio, 
				I.NombreInstalacion AS InstalacionPresupuestada, 
				LPM.AC_FEC_INI AS FechaInicio, 
				LPM.AC_FEC_FIN AS FechaFin, 
				CASE 
					WHEN R.CvTipoDocFacturacion = 1 
					THEN 'CF' 
					WHEN R.CvTipoDocFacturacion = 2 
					THEN 'PI' 
					WHEN R.CvTipoDocFacturacion = 3 THEN 'PE' 
				END AS TipoDocumento,
						  
				CASE 
					WHEN R.CvTipoDocFacturacion = 1 
						THEN LTRIM(RTRIM(F.Serie + ' ' + F.Folio)) 
					WHEN R.CvTipoDocFacturacion = 2 
						THEN PC.NumeroPedimento
					WHEN R.CvTipoDocFacturacion = 3 
						THEN PC.FolioComprobante 
				END AS Numero, 
				CASE 
					WHEN R.CvTipoDocFacturacion = 1 
					THEN F.Fecha 
					WHEN R.CvTipoDocFacturacion IN (2, 3) 
					THEN PC.FechaPago 
				END AS FechaDocumento, 

				 G.MontoRegistroUSD AS MontoRegistroUSD, 

					CASE 
						WHEN R.CvTipoDocFacturacion = 1 
						THEN SF.RazonSocial 
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						THEN SPC.RazonSocial 
					END AS Subcontratista, 

					IR.NombreInstalacion AS InstalacionRegistro, 
					R.InicioEjecucion, 
					R.FinEjecucion, U.Nombre AS CreadoPor, 
					R.MontoRegistro, 
					CASE 
						WHEN R.CvTipoDocFacturacion = 1 
						THEN TMF.TipoMonedaCorto 
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						THEN TMPC.TipoMonedaCorto 
					END AS Moneda, 
					R.MesPresentacion, 
					CASE 
						WHEN P.ciep = 1 
						THEN TS .NombreTipoServicio 
						ELSE ACNH.DescripcionActividadPetrolera 
					END AS TipoDeServicio, 
					CASE 
						WHEN P.ciep = 1 
						THEN ACIEP.NombreActividad 
						ELSE SAP.SubactividadPetrolera 
					END AS Actividad, 
					CASE 
						WHEN P.ciep = 1 
						THEN RI.NombreRubro 
						ELSE TP.TareaPetrolera 
					END AS SubActividad, 
					ER.NombreEstado AS EstadoValidacion,
					A.NombreArea AS Area, 
					R.Comentarios, 
					CA.ClasificacionAnexo4 AS Anexo4,
					CASE 
					WHEN R.CvTipoDocFacturacion = 1 
					THEN F.IdFactura 
					WHEN R.CvTipoDocFacturacion IN (2, 3) 
					THEN PC.IdPedimentoComprobante 
				END AS Identificador, 
					LPM.IdLineaPresupuestoMes AS LineaPresupuesto,
					P.Nombre AS Presupuesto, 
				CASE 
						WHEN R.CvTipoDocFacturacion = 1 
						THEN CAST(SUM(FT.MontoPagadoTotalUSD) AS DECIMAL(20, 2))
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						THEN CAST(SUM(PCT.MontoPagadoTotalUSD) AS DECIMAL(20, 2))
				END AS MontoTransferenciaUSD,  
				CASE 
						WHEN R.CvTipoDocFacturacion = 1 
						THEN CAST(FT.MontoPendientePago AS DECIMAL(20, 2))
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						THEN CAST(PCT.MontoPendientePago AS DECIMAL(20, 2))
				END AS MontoPendienteUSD,  
			
					ISNULL(TP.id_Tarea, '') AS Id_Tarea, 
					ISNULL(GR.Descripcion, '') AS RubroCN, 
					R.PCN, 
					CAST(ISNULL(F.MontoConIva, '')AS DECIMAL(20, 2)) AS MontoFacturaConIVA, 
					CASE 
							WHEN R.CvTipoDocFacturacion = 1 
							THEN ISNULL(F.Moneda, '')
							WHEN R.CvTipoDocFacturacion IN (2, 3) 
							THEN ISNULL(TMPC.TipoMonedaCorto, '')
					END
					 AS MonedaFactura, 
					ISNULL(F.UUID, '') 
					AS UUID, CAST(ISNULL(F.SubTotal, '')AS DECIMAL(20, 2)) AS SubtotalFactura, 
					CASE 
						WHEN FP.IdFactura IS NOT NULL AND ACP.IdEstatus = 2 AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1 
						THEN 'Si tiene carta' 
						WHEN DADA.IdDocAdinco IS NOT NULL 
						THEN 'Si tiene carta' 
						ELSE 'NO TIENE CARTA' 
					END AS CartaContenidoNacional,
					CCSH.Nivel3, 
					CCSH.Descripcion, 
					F.Fecha,
					CASE 
							WHEN R.CvTipoDocFacturacion = 1 
							THEN CAST((SUM(FT.MontoPendientePago) /FT.CantidadGastos) AS DECIMAL(20, 2))
							WHEN R.CvTipoDocFacturacion IN (2, 3) 
							THEN CAST((SUM(PCT.MontoPendientePago) /PCT.CantidadGastos) AS DECIMAL(20, 2))
					END AS MontoPendienteProrrateoUSD,
						CASE 
							WHEN R.CvTipoDocFacturacion = 1 
							THEN CAST((SUM(FT.MontoPagadoTotalUSD) /FT.CantidadGastos) AS DECIMAL(20, 2))
							WHEN R.CvTipoDocFacturacion IN (2, 3) 
							THEN CAST((SUM(PCT.MontoPagadoTotalUSD)/PCT.CantidadGastos) AS DECIMAL(20, 2))
					END AS MontoPAGADOProrrateoUSD,
				    CASE 
							WHEN R.CvTipoDocFacturacion = 1 
							THEN FT.CantidadGastos
							WHEN R.CvTipoDocFacturacion IN (2, 3) 
							THEN 	PCT.CantidadGastos
					END AS CantidadGastos
					into #temp
				FROM 
				        
					#Gastos   G
				JOIN
						dbo.CO_Registro AS R WITH (NOLOCK) 
						ON	G.IdRegistro	=	R.IdRegistro
				JOIN
					CO_LineaPresupuestoMes	LPM
					ON	G.IdPrograma	=	LPM.IdLineaPresupuestoMes
				LEFT JOIN
					dbo.CO_Servicio AS S WITH (NOLOCK) 
					ON LPM.IdServicio = S.IdServicio 
				LEFT JOIN
						dbo.CO_Instalacion AS I WITH (NOLOCK) 
						ON LPM.IdInstalacion = I.IdInstalacion  
				LEFT JOIN
						dbo.CO_GastosRubro AS GR WITH (NOLOCK) 
						ON R.IdGastoRubro = GR.IdGastoRubro 
				LEFT JOIN
						#Facturas AS FT WITH (NOLOCK) 
						ON G.IdFactura = FT.IdFactura 
				LEFT JOIN
						dbo.FI_Factura AS F WITH (NOLOCK) 
						ON  R.IdFactura	=	F.IdFactura
				LEFT JOIN
						#PedimentosComprobantes AS PCT WITH (NOLOCK) 
						ON G.IdPedimentoComprobante = PCT.IdPedimentoComprobante 
				LEFT JOIN
						dbo.FI_PedimentoComprobante AS PC WITH (NOLOCK) 
						ON R.IdPedimentoComprobante	=	PC.IdPedimentoComprobante 
				LEFT  JOIN
						dbo.PV_Subcontratista AS SF WITH (NOLOCK) 
						ON F.IdSubcontratista = SF.IdSubcontratista 
				LEFT JOIN
						dbo.PV_Subcontratista AS SPC WITH (NOLOCK) 
						ON  PC.IdSubcontratistaExportador	=	SPC.IdSubcontratista
				LEFT JOIN
						dbo.CO_Instalacion AS IR WITH (NOLOCK) 
						ON R.IdInstalacion = IR.IdInstalacion 
				LEFT JOIN
						dbo.AP_Usuario AS U WITH (NOLOCK) 
						ON R.IdUsuarioCreadoPor = U.UsuarioID 
				LEFT JOIN
						dbo.CO_TipoServicio AS TS WITH (NOLOCK) 
						ON LPM.IdTipoServicio = TS.IdTipoServicio 
				LEFT JOIN
						dbo.CO_ActividadCIEP AS ACIEP WITH (NOLOCK) 
						ON LPM.IdActividad = ACIEP.IdActividad 
				LEFT JOIN
						dbo.CO_SubactividadCIEP AS SCIEP WITH (NOLOCK) 
						ON LPM.IdSubactividad = SCIEP.IdSubactividad 
				LEFT JOIN
						dbo.CO_EstadoRegistro AS ER WITH (NOLOCK) 
						ON R.IdEstado = ER.IdEstadoRegistro 
				LEFT JOIN
					dbo.CO_Area AS A WITH (NOLOCK) 
					ON  LPM.IdArea =	A.IdArea
				LEFT JOIN
						dbo.PV_TipoMoneda AS TMF WITH (NOLOCK) 
						ON F.IdMoneda	=	TMF.IdMoneda
				LEFT JOIN
					dbo.PV_TipoMoneda AS TMPC WITH (NOLOCK) 
					ON  PC.IdMoneda	=	TMPC.IdMoneda
				LEFT JOIN
						dbo.CO_ClasificacionAnexo4 AS CA WITH (NOLOCK) 
						ON LPM.IdAnexo4 = CA.IdAnexo4 
				LEFT JOIN
						dbo.CO_Presupuesto AS P WITH (NOLOCK) 
						ON LPM.IdPresupuesto = P.IdPresupuesto 
				LEFT JOIN
						dbo.CO_ActividadPetroleraCNH AS ACNH WITH (NOLOCK) 
						ON LPM.IdActividadPetrolera = ACNH.IdActividadPetrolera 
				LEFT JOIN
						dbo.CO_SubactividadPetrolera AS SAP WITH (NOLOCK) 
						ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera 
				LEFT JOIN
						dbo.CO_RubroInterno AS RI WITH (NOLOCK) 
						ON LPM.IdRubroInterno = RI.IdRubroInterno 
				LEFT JOIN
						dbo.CO_TareaPetrolera AS TP WITH (NOLOCK) 
						ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera 
				LEFT JOIN
						dbo.CO_Contrato AS C WITH (NOLOCK) 
						ON	G.IdContrato	=	C.IdContrato
				LEFT JOIN
						dbo.CO_Contratista AS CC WITH (NOLOCK) 
						ON	C.IdContratista		=	CC.IdContratista
				LEFT JOIN
						dbo.CO_AreaContractual AS ACC WITH (NOLOCK) 
						ON  C.IdAreaContractual	=	ACC.IdAreaContractual
				LEFT JOIN
						Petrovendor.dbo.FI_Factura AS FP WITH (NOLOCK) 
						ON F.UUID = FP.UUID COLLATE DATABASE_DEFAULT 
						AND FP.UUID IS NOT NULL 
						AND FP.Activa = 1 
						AND FP.IsEliminado = 0 
				LEFT JOIN
						Petrovendor.dbo.MM_AceptacionFactura AS AF WITH (NOLOCK) 
						ON AF.IdFactura = FP.IdFactura 
				LEFT JOIN
						Petrovendor.dbo.MM_AceptacionPedido AS AP WITH (NOLOCK) 
						ON AP.IdAceptacionPedido = AF.IdAceptacionPedido 
				LEFT JOIN
						Petrovendor.dbo.MM_Pedido AS PP WITH (NOLOCK) 
						ON PP.IdPedido = AP.IdPedido AND PP.IdContrato IN (10036) 
				LEFT JOIN
						Petrovendor.dbo.MM_AceptacionCartaPCN AS ACP WITH (NOLOCK) 
						ON ACP.IdAceptacionPedido = AP.IdAceptacionPedido AND ACP.IdEstatus = 2 AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1 
				LEFT JOIN
						dbo.CO_CatalogoCuentaSH AS CCSH WITH (NOLOCK) 
						ON CCSH.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH 
				LEFT  JOIN
						dbo.AWS_DocAwsDocAdinco AS DADA 
						ON F.IdFactura = DADA.IdDocAdinco
				
				
			GROUP BY	C.NumeroContrato, ACC.NombreAreaContractual, PC.NumeroPedimento, S.NombreServicio, I.NombreInstalacion, LPM.AC_FEC_INI, LPM.AC_FEC_FIN, F.Fecha, LTRIM(RTRIM(F.Serie + ' ' + F.Folio)), SF.RazonSocial, 
					IR.NombreInstalacion, R.InicioEjecucion, R.FinEjecucion, U.Nombre, R.MontoRegistro, TMF.TipoMonedaCorto, R.MesPresentacion, 
					CASE WHEN P.ciep = 1 THEN TS .NombreTipoServicio ELSE ACNH.DescripcionActividadPetrolera END, CASE WHEN P.ciep = 1 THEN ACIEP.NombreActividad ELSE SAP.SubactividadPetrolera END, 
					CASE WHEN P.ciep = 1 THEN RI.NombreRubro ELSE TP.TareaPetrolera END, R.IdRegistro, ER.NombreEstado, A.NombreArea, R.Comentarios, CA.ClasificacionAnexo4, F.IdFactura, PC.IdPedimentoComprobante, IR.CUIP, 
					IR.WelIID, LPM.IdLineaPresupuestoMes, IR.IdInstalacion, P.Nombre, R.CvTipoDocFacturacion, PC.FechaPago, PC.IdMoneda, R.IdRegistro, PC.FolioComprobante, SPC.RazonSocial, TMPC.TipoMonedaCorto,
				 ISNULL(TP.id_Tarea, ''), ISNULL(GR.Descripcion, ''), R.PCN, ISNULL(F.MontoConIva, ''), ISNULL(F.Moneda, ''), ISNULL(F.UUID, ''), ISNULL(F.SubTotal, ''), CASE WHEN FP.IdFactura IS NOT NULL AND 
					ACP.IdEstatus = 2 AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1 THEN 'Si tiene carta' WHEN DADA.IdDocAdinco IS NOT NULL THEN 'Si tiene carta' ELSE 'NO TIENE CARTA' END, CCSH.Nivel3, CCSH.Descripcion, G.MontoRegistroUSD , --, IdTransfer
				CASE 
						WHEN R.CvTipoDocFacturacion = 1 
						THEN CAST(FT.MontoPendientePago AS DECIMAL(20, 2))
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						THEN CAST(PCT.MontoPendientePago AS DECIMAL(20, 2))
				END,
				
				FT.CantidadGastos,PCT.CantidadGastos,	CASE 
				WHEN R.CvTipoDocFacturacion = 1 
						THEN CAST(FT.MontoPagadoTotalUSD AS DECIMAL(20, 2))
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						THEN CAST(PCT.MontoPagadoTotalUSD AS DECIMAL(20, 2))
				END,
					CASE 
							WHEN R.CvTipoDocFacturacion = 1 
							THEN FT.CantidadGastos
							WHEN R.CvTipoDocFacturacion IN (2, 3) 
							THEN 	PCT.CantidadGastos
					END
				ORDER BY
				CASE 
				WHEN R.CvTipoDocFacturacion = 1 
						THEN CAST(FT.MontoPagadoTotalUSD AS DECIMAL(20, 2))
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						THEN CAST(PCT.MontoPagadoTotalUSD AS DECIMAL(20, 2))
				END ASC 
