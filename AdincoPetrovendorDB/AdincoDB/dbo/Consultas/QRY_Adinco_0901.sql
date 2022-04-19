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
	 
		--
    CREATE TABLE #Gastos --gastos del presupuesto 
    (IdRegistro      INT, 
    IdFactura       INT, 
	IdPrograma INT,
	IdPedimentoComprobante INT,
    MontoRegistro   FLOAT, 
    CvTipoDocFacturacion INT,
	IdContrato INT
	 ); 

    CREATE TABLE #Facturas --facturas
    (
	IdFactura       INT, 
	UUID            NVARCHAR(500), 
	TipoComprobante NVARCHAR(50),
	MontoRegistroTotal FLOAT,
	MontoPagadoTotal FLOAT,
	MontoPendientePago FLOAT,
	SubTotalFactura FLOAT,
	MontoTotalIvaFactura FLOAT,
    RC2122USD          FLOAT, 
	MetodoPago      NVARCHAR(50), 
    Fecha           DATETIME,
	IdMoneda        INT
    );

    CREATE TABLE #PedimentosComprobantes 
    (
    IdPedimentoComprobante       INT, 
    MontoRegistroTotal   FLOAT, 
	MontoPagadoTotal FLOAT,
	MontoPendientePago FLOAT,
    RC2122USD          FLOAT, 
    IdMoneda        INT
    );

	CREATE TABLE #FacturasPagadas 
    (
    	IdFactura       INT, 
		MontoPagado   FLOAT
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
	 IdContrato)
	 SELECT		R.IdRegistro, 
                R.MontoRegistro,
				R.IdPrograma,
				R.IdFactura,
				R.IdPedimentoComprobante,
				R.CvTipoDocFacturacion,
				AC.IdContrato
        FROM dbo.CO_Registro R WITH(NOLOCK)
                JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
				JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON LPM.IdPresupuesto = P.IdPresupuesto
				JOIN CO_AnioContractual	AC ON P.IdAnioContractual = AC.IdAnioContractual
                JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio
                                                    AND AC.IdContrato  = S.IdContrato
        WHERE AC.IdContrato = 10036
                AND R.IdEstado = 10004
				AND P.Nombre ='Desarrollo Cárdenas-Mora 2022'; --2018 (tiene un guion "provisional"),2019,2020,2021,2022

				

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
	MontoTotalIvaFactura 
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
				F.MontoConIva
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
		IdMoneda)
			SELECT 
				P.IdPedimentoComprobante, 
				SUM(R.MontoRegistro),
				SUM(CASE
						WHEN ISNULL(R.MontoRegistro, 0) <> 0
						THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCDP.TipoCambio), 2) AS DECIMAL(15, 2))
						ELSE 0
					END) ,
				P.IdMoneda
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

-- FACTURAS PAGADAS, SI SE NECESITA REALIZAR UNA DIFERENCIA DE CUANTO SE HA PAGADO DE UNA FACTURA
	INSERT INTO #FacturasPagadas (
		MontoPagado,
    	IdFactura)
	SELECT SUM(ImpPagado), FT.IdFactura
	FROM 
		#Facturas FT	WITH (NOLOCK) 
	JOIN
		FI_Factura FCPDR	WITH(NOLOCK)
		ON	FT.IdFactura = FCPDR.IdFactura
	JOIN 
		FI_CPDocRelacionado CPDR WITH(NOLOCK) 
		ON FCPDR.UUID = CPDR.IdDocumento
	JOIN		
		dbo.FI_ComplementoDePago CP WITH(NOLOCK) 
		ON CPDR.IdComplementoDePago = CP.IdComplementoDePago 
    JOIN 
		dbo.FI_TransferFactura TF WITH(NOLOCK) 
		ON CP.IdFactura = TF.IdFactura
	WHERE FT.MetodoPago = 'PPD' 
	GROUP BY FT.IdFactura
	
	UNION

	SELECT	SUM(TF.MontoPagado), FT.IdFactura
	FROM 
			#Facturas FT
	JOIN 
		dbo.FI_TransferFactura TF WITH(NOLOCK) 
		ON FT.IdFactura = TF.IdFactura
    WHERE 
		FT.MetodoPago IN ('PUE','PPD')
	GROUP BY FT.IdFactura
	ORDER BY IdFactura ASC

	INSERT INTO #PedimentosPagados(MontoPagado,IdPedimentoComprobante)
	SELECT	SUM(TF.MontoPagado), PD.IdPedimentoComprobante
	FROM 
		#PedimentosComprobantes PD	WITH (NOLOCK) 
	JOIN 
		dbo.FI_TransferFactura TF WITH(NOLOCK) 
		ON PD.IdPedimentoComprobante = TF.IdPedimentoComprobante
	GROUP BY PD.IdPedimentoComprobante
	ORDER BY IdPedimentoComprobante ASC
	
--Facturas PUE

	UPDATE F
	SET F.MontoPagadoTotal = ISNULL(FP.MontoPagado,0)
	FROM 
		#Facturas	F	WITH (NOLOCK) 
	LEFT JOIN 
		#FacturasPagadas	FP	WITH (NOLOCK) 
		ON	F.IdFactura	=	FP.IdFactura

	
	UPDATE P
	SET P.MontoPagadoTotal = ISNULL(PD.MontoPagado,0)
	FROM 
		#PedimentosComprobantes	P WITH (NOLOCK) 
	LEFT JOIN 
		#PedimentosPagados	PD WITH (NOLOCK) 
		ON	P.IdPedimentoComprobante	=	PD.IdPedimentoComprobante

	
	UPDATE F
	SET F.MontoPendientePago = ISNULL(F.MontoTotalIvaFactura,0) - ISNULL(F.MontoPagadoTotal,0)
	FROM 
		#Facturas	F	WITH (NOLOCK) 
	LEFT JOIN 
		#FacturasPagadas	FP	WITH (NOLOCK) 
		ON	F.IdFactura	=	FP.IdFactura

	
	UPDATE P
	SET P.MontoPendientePago = ISNULL(P.MontoRegistroTotal,0) - ISNULL(P.MontoPagadoTotal,0)
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

				CASE 
						WHEN R.CvTipoDocFacturacion = 1 
						THEN CAST(SUM(CASE WHEN ISNULL(R.MontoRegistro, 0) <> 0 THEN ISNULL(R.MontoRegistro, 0) / TCDF.TipoCambio ELSE 0 END) AS DECIMAL(20, 2))
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						THEN CAST(SUM(CASE WHEN ISNULL(R.MontoRegistro, 0) <> 0 THEN ISNULL(R.MontoRegistro, 0) / TCDPC.TipoCambio ELSE 0 END) AS DECIMAL(20, 2))
				END AS MontoRegistroUSD, 

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
						THEN CAST(FT.MontoPagadoTotal AS DECIMAL(20, 2))
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						THEN CAST(PCT.MontoPagadoTotal AS DECIMAL(20, 2))
				END AS MontoTransferencia,  
				CASE 
						WHEN R.CvTipoDocFacturacion = 1 
						THEN CAST(FT.MontoPendientePago AS DECIMAL(20, 2))
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						THEN CAST(PCT.MontoPendientePago AS DECIMAL(20, 2))
				END AS MontoPendiente,  
				CASE 
						WHEN R.CvTipoDocFacturacion = 1 
						THEN CAST(SUM(CASE WHEN ISNULL(FT.MontoPendientePago, 0) <> 0 THEN ISNULL(FT.MontoPendientePago, 0) / TCDF.TipoCambio ELSE 0 END) AS DECIMAL(20, 2))
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						THEN CAST(SUM(CASE WHEN ISNULL(PCT.MontoPendientePago, 0) <> 0 THEN ISNULL(PCT.MontoPendientePago, 0) / TCDPC.TipoCambio ELSE 0 END) AS DECIMAL(20, 2))
				END AS MontoPendienteUSD,
				CASE 
						WHEN R.CvTipoDocFacturacion = 1 
						then TCDF.TipoCambio
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						then TCDPC.TipoCambio 
				END AS 'TipoCambioFactura/Comprobante',
					ISNULL(TP.id_Tarea, '') AS Id_Tarea, 
					ISNULL(GR.Descripcion, '') AS RubroCN, 
					R.PCN, 
					CAST(ISNULL(F.MontoConIva, '')AS DECIMAL(20, 2)) AS MontoFacturaConIVA, 
					ISNULL(F.Moneda, '') AS MonedaFactura, 
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
					F.Fecha
				
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
						dbo.CO_TipoCambioDiario AS TCDF WITH (NOLOCK) 
						ON TCDF.IdMoneda = TMF.IdMoneda 
						AND DAY(TCDF.Fecha) = DAY(F.Fecha) 
						AND MONTH(TCDF.Fecha) = MONTH(F.Fecha) 
						AND YEAR(TCDF.Fecha) = YEAR(F.Fecha) 
				LEFT JOIN
					dbo.PV_TipoMoneda AS TMPC WITH (NOLOCK) 
					ON  PC.IdMoneda	=	TMPC.IdMoneda
				LEFT JOIN
					dbo.CO_TipoCambioDiario AS TCDPC WITH (NOLOCK) 
					ON TCDPC.IdMoneda = TMPC.IdMoneda 
					AND DAY(TCDPC.Fecha) = DAY(PC.FechaPago) 
					AND MONTH(TCDPC.Fecha) = MONTH(PC.FechaPago) 
					AND YEAR(TCDPC.Fecha) = YEAR(PC.FechaPago) 
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
				WHERE
				FT.MontoPagadoTotal = 0
				--(R.CvTipoDocFacturacion = 1 AND (CAST(ISNULL(FT.MontoPagadoTotal,0)AS DECIMAL(20, 2)) <  CAST(ISNULL(FT.MontoTotalIvaFactura,0) AS DECIMAL(20, 2))))
				--OR  (R.CvTipoDocFacturacion IN (2, 3)  AND ( CAST(ISNULL(PCT.MontoPagadoTotal,0)AS DECIMAL(20, 2)) < CAST(ISNULL(PCT.MontoRegistroTotal,0) AS DECIMAL(20, 2))))
				
				 
			GROUP BY	C.NumeroContrato, ACC.NombreAreaContractual, PC.NumeroPedimento, S.NombreServicio, I.NombreInstalacion, LPM.AC_FEC_INI, LPM.AC_FEC_FIN, F.Fecha, LTRIM(RTRIM(F.Serie + ' ' + F.Folio)), SF.RazonSocial, 
					IR.NombreInstalacion, R.InicioEjecucion, R.FinEjecucion, F.Fecha, U.Nombre, R.MontoRegistro, TMF.TipoMonedaCorto, R.MesPresentacion, 
					CASE WHEN P.ciep = 1 THEN TS .NombreTipoServicio ELSE ACNH.DescripcionActividadPetrolera END, CASE WHEN P.ciep = 1 THEN ACIEP.NombreActividad ELSE SAP.SubactividadPetrolera END, 
					CASE WHEN P.ciep = 1 THEN RI.NombreRubro ELSE TP.TareaPetrolera END, R.IdRegistro, ER.NombreEstado, A.NombreArea, R.Comentarios, CA.ClasificacionAnexo4, F.IdFactura, PC.IdPedimentoComprobante, IR.CUIP, 
					IR.WelIID, LPM.IdLineaPresupuestoMes, IR.IdInstalacion, P.Nombre, R.CvTipoDocFacturacion, PC.FechaPago, PC.IdMoneda, R.IdRegistro, PC.FolioComprobante, SPC.RazonSocial, TMPC.TipoMonedaCorto,
					CASE 
							WHEN R.CvTipoDocFacturacion = 1 
						THEN CAST(FT.MontoPagadoTotal AS DECIMAL(20, 2))
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						THEN CAST(PCT.MontoPagadoTotal AS DECIMAL(20, 2))
				END, ISNULL(TP.id_Tarea, ''), ISNULL(GR.Descripcion, ''), R.PCN, ISNULL(F.MontoConIva, ''), ISNULL(F.Moneda, ''), ISNULL(F.UUID, ''), ISNULL(F.SubTotal, ''), CASE WHEN FP.IdFactura IS NOT NULL AND 
					ACP.IdEstatus = 2 AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1 THEN 'Si tiene carta' WHEN DADA.IdDocAdinco IS NOT NULL THEN 'Si tiene carta' ELSE 'NO TIENE CARTA' END, CCSH.Nivel3, CCSH.Descripcion, F.Fecha,--, IdTransfer
				CASE 
						WHEN R.CvTipoDocFacturacion = 1 
						THEN CAST(FT.MontoPendientePago AS DECIMAL(20, 2))
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						THEN CAST(PCT.MontoPendientePago AS DECIMAL(20, 2))
				END,
				CASE 
						WHEN R.CvTipoDocFacturacion = 1 
						then TCDF.TipoCambio
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						then TCDPC.TipoCambio 
				END
				ORDER BY
				CASE 
				WHEN R.CvTipoDocFacturacion = 1 
						THEN CAST(FT.MontoPagadoTotal AS DECIMAL(20, 2))
						WHEN R.CvTipoDocFacturacion IN (2, 3) 
						THEN CAST(PCT.MontoPagadoTotal AS DECIMAL(20, 2))
				END ASC 