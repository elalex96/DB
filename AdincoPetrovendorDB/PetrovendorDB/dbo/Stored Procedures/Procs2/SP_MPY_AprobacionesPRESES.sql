
-- [SP_MPY_AprobacionesPRESES] 'MSU150922EYA', 0
CREATE PROCEDURE [dbo].[SP_MPY_AprobacionesPRESES] --'OSS1608267811',0
	@RFCProveedor	VARCHAR(50),
	@IdEstatus		INT
AS
BEGIN
	SET NOCOUNT ON;
	CREATE TABLE #PRESE (
	IdPRESES INT,
	SAPPONumber VARCHAR(50),
	VendorName VARCHAR(100),
	SAPSESNumber VARCHAR(50),
	MontoTotalPrefactura MONEY,
	FechaCarga DATETIME,
	Estatus VARCHAR(50),
	Span VARCHAR(50),
	SES NVARCHAR(50),
	ComentarioInterno NVARCHAR(MAX)
	);
	
	--DECLARE @IDCONTRATO INT = (SELECT 
	--									SCP.IdContrato 
	--								FROM Adinco.dbo.CO_Contrato AS SCP
	--									JOIN Adinco.dbo.CO_Contratista AS C ON C.IdContratista = SCP.IdContratista
	--								WHERE C.RFC = @RFCProveedor);

	DECLARE @PLANT NVARCHAR(10) = (SELECT TOP 1 CP.Planta
									FROM Adinco.dbo.CO_SAPContratista_Planta AS CP
									JOIN Adinco.dbo.CO_Contratista AS C ON C.IdContratista = CP.IdContratista
									WHERE C.RFC = @RFCProveedor)


	IF @IdEstatus = 1
	BEGIN
									INSERT INTO #PRESE
									SELECT
										PRS.IdPRESES,
										CASE 
											WHEN PRS.SAPPONumber = '0' THEN 'No Apply'
											ELSE PRS.SAPPONumber
										END,
										VE.VendorName,
										PRS.SAPSESNumber,
										PRS.MontoTotalPrefactura,
										PRS.CreadoEl AS FechaCarga,
										'On Approval' AS Estatus,
										'label label-primary' AS Span,
										case when GR.PO_SAPNumber is not null then 'With GR Associated'
												when max(GR2.PO_SAPNumber) is not null  then 'Without GR Associated'
													when SES.SESNumber is not null then SES.SESNumber
													when SES.SESNumber is null then 'Without SES Associated'
												End AS SESNumber,
										PRS.ComentarioInterno
									FROM Adinco.dbo.CO_SAPPRESES AS PRS
										LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber = PRS.SAPPONumber AND PO.SAPVendorNumber = PRS.SAPVendorNumber
										LEFT JOIN Adinco.dbo.CO_SAPVendor AS VE ON VE.VendorIDSAP = PO.SAPVendorNumber
										LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PRS.SAPPONumber AND 
																			SES.SESReferenceNumber = PRS.SAPSESNumber AND 
																			SES.SESNumber = PRS.SESN AND 
																			PRS.IdEstatus = 2
										LEFT JOIN Adinco.dbo.CO_SAPGR AS GR ON GR.PO_SAPNumber = PRS.SAPPONumber  AND PRS.IdEstatus = 2
									LEFT JOIN Adinco.dbo.CO_SAPGR AS GR2 ON GR2.PO_SAPNumber = PRS.SAPPONumber  AND PRS.IdEstatus <> 2
									
									WHERE PO.Plant = @PLANT
										 AND PRS.IdEstatus = 1
									GROUP BY PRS.IdPRESES,
										CASE 
											WHEN PRS.SAPPONumber = '0' THEN 'No Apply'
											ELSE PRS.SAPPONumber
										END,
										VE.VendorName,
										PRS.SAPSESNumber,
										PRS.MontoTotalPrefactura,
										PRS.CreadoEl,
										--PRS.SESN,
										PRS.ComentarioInterno,
										ISNULL(SES.SESNumber,'Without SES Associated'),
										GR.PO_SAPNumber,
										SES.SESNumber
									ORDER BY PRS.CreadoEl DESC;

									INSERT INTO #PRESE
									SELECT
										PSES.IdPRESES,
										CASE 
											WHEN PSES.SAPPONumber = '0' THEN 'No Apply'
											ELSE PSES.SAPPONumber
										END,
										VE.VendorName,
										PSES.SAPSESNumber,
										PSES.MontoTotalPrefactura,
										PSES.CreadoEl,
										'On Approval' AS Estatus,
										'label label-primary' AS Span,
										case when GR.PO_SAPNumber is not null then 'With GR Associated'
												when max(GR2.PO_SAPNumber) is not null  then 'Without GR Associated'
													when SES.SESNumber is not null then SES.SESNumber
													when SES.SESNumber is null then 'Without SES Associated'
												End AS SESNumber,
										PSES.ComentarioInterno
									FROM Adinco.dbo.CO_SAPPRESES AS PSES
										LEFT JOIN Adinco.dbo.CO_SAPVendor AS VE ON VE.VendorIDSAP = PSES.SAPVendorNumber
										LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber = PSES.SAPPONumber
										LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber AND SES.SESNumber = PSES.SESN AND PSES.IdEstatus = 2
										LEFT JOIN Adinco.dbo.CO_SAPGR AS GR ON GR.PO_SAPNumber = PSES.SAPPONumber  AND PSES.IdEstatus = 2
										LEFT JOIN Adinco.dbo.CO_SAPGR AS GR2 ON GR2.PO_SAPNumber = PSES.SAPPONumber  AND PSES.IdEstatus <> 2
									
									WHERE PSES.SAPPONumber = '0'
										AND PSES.Plant = @PLANT
										AND PSES.IdEstatus = 1
									GROUP BY PSES.IdPRESES,
										CASE 
											WHEN PSES.SAPPONumber = '0' THEN 'No Apply'
											ELSE PSES.SAPPONumber
										END,
										VE.VendorName,
										PSES.SAPSESNumber,
										PSES.MontoTotalPrefactura,
										PSES.CreadoEl,
										--PSES.SESN,
										ISNULL(SES.SESNumber,'Without SES Associated'),
										PSES.SAPSESNumber,
										PSES.ComentarioInterno,
										GR.PO_SAPNumber,
										SES.SESNumber
									
									
			END
			IF @IdEstatus = 2 
			BEGIN
									INSERT INTO #PRESE
									SELECT
										PRS.IdPRESES,
										CASE 
											WHEN PRS.SAPPONumber = '0' THEN 'No Apply'
											ELSE PRS.SAPPONumber
										END,
										VE.VendorName,
										PRS.SAPSESNumber,
										PRS.MontoTotalPrefactura,
										PRS.CreadoEl AS FechaCarga,
										'Approved' AS Estatus,
										'label label-success' AS Span,
										--ISNULL(SES.SESNumber,'Without SES Associated') AS SESN,

										SESN = case when GR.PO_SAPNumber is not null then 'With GR Associated'
													when SES.SESNumber is not null then SES.SESNumber
													when SES.SESNumber is null then 'Without SES Associated'
												End,

										PRS.ComentarioInterno
									FROM Adinco.dbo.CO_SAPPRESES AS PRS
										JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber = PRS.SAPPONumber AND PO.SAPVendorNumber = PRS.SAPVendorNumber
										LEFT JOIN Adinco.dbo.CO_SAPVendor AS VE ON VE.VendorIDSAP = PRS.SAPVendorNumber
										LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PRS.SAPPONumber 
															AND SES.SESReferenceNumber = PRS.SAPSESNumber 
															AND SES.SESNumber = PRS.SESN 
															AND PRS.IdEstatus = 2
										LEFT JOIN Adinco.dbo.CO_SAPGR AS GR ON GR.PO_SAPNumber = PRS.SAPPONumber  AND PRS.IdEstatus = 2
									WHERE PO.Plant = @PLANT
										 AND PRS.IdEstatus = 2
									GROUP BY PRS.IdPRESES,
										CASE 
											WHEN PRS.SAPPONumber = '0' THEN 'No Apply'
											ELSE PRS.SAPPONumber
										END,
										VE.VendorName,
										PRS.SAPSESNumber,
										PRS.MontoTotalPrefactura,
										PRS.CreadoEl,
										--PRS.SESN,
										ISNULL(SES.SESNumber,'Without SES Associated'),
										PRS.SAPSESNumber,
										PRS.ComentarioInterno,
										GR.PO_SAPNumber,
										SES.SESNumber
									ORDER BY PRS.CreadoEl DESC;

									INSERT INTO #PRESE
									SELECT
										PSES.IdPRESES,
										CASE 
											WHEN PSES.SAPPONumber = '0' THEN 'No Apply'
											ELSE PSES.SAPPONumber
										END,
										VE.VendorName,
										PSES.SAPSESNumber,
										PSES.MontoTotalPrefactura,
										PSES.CreadoEl,
										'Approved' AS Estatus,
										'label label-success' AS Span,
										SESN = case when GR.PO_SAPNumber is not null then 'With GR Associated'
													when SES.SESNumber is not null then SES.SESNumber
													when SES.SESNumber is null then 'Without SES Associated'
												End,
										PSES.ComentarioInterno
									FROM Adinco.dbo.CO_SAPPRESES AS PSES
									LEFT JOIN Adinco.dbo.CO_SAPVendor AS VE ON VE.VendorIDSAP = PSES.SAPVendorNumber
									LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber = PSES.SAPPONumber
									LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber 
															AND SES.SESReferenceNumber = PSES.SAPSESNumber 
															AND SES.SESNumber = PSES.SESN  
															AND PSES.IdEstatus = 2
									LEFT JOIN Adinco.dbo.CO_SAPGR AS GR ON GR.PO_SAPNumber = PSES.SAPPONumber  AND PSES.IdEstatus = 2
									WHERE PSES.SAPPONumber = '0'
										AND PSES.Plant = @PLANT
										AND PSES.IdEstatus = 2
									GROUP BY PSES.IdPRESES,
										PSES.SAPPONumber,
										VE.VendorName,
										PSES.SAPSESNumber,
										PSES.MontoTotalPrefactura,
										PSES.CreadoEl,
										--PSES.SESN,
										ISNULL(SES.SESNumber,'Without SES Associated'),
										PSES.SAPSESNumber,
										PSES.ComentarioInterno,
										GR.PO_SAPNumber,
										SES.SESNumber
			END
			IF @IdEstatus = 3
			BEGIN
									INSERT INTO #PRESE
									SELECT
										PRS.IdPRESES,
										CASE 
											WHEN PRS.SAPPONumber = '0' THEN 'No Apply'
											ELSE PRS.SAPPONumber
										END,
										VE.VendorName,
										PRS.SAPSESNumber,
										PRS.MontoTotalPrefactura,
										PRS.CreadoEl AS FechaCarga,
										'Rejected' AS Estatus,
										'label label-danger' AS Span,
										case when GR.PO_SAPNumber is not null then 'With GR Associated'
												when max(GR2.PO_SAPNumber) is not null  then 'Without GR Associated'
													when SES.SESNumber is not null then SES.SESNumber
													when SES.SESNumber is null then 'Without SES Associated'
												End AS SESNumber,
										PRS.ComentarioInterno
									FROM Adinco.dbo.CO_SAPPRESES AS PRS
										JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber = PRS.SAPPONumber AND PO.SAPVendorNumber = PRS.SAPVendorNumber
										LEFT JOIN Adinco.dbo.CO_SAPVendor AS VE ON VE.VendorIDSAP = PRS.SAPVendorNumber
										LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PRS.SAPPONumber AND SES.SESReferenceNumber = PRS.SAPSESNumber AND SES.SESNumber = PRS.SESN  AND PRS.IdEstatus = 2
										LEFT JOIN Adinco.dbo.CO_SAPGR AS GR ON GR.PO_SAPNumber = PRS.SAPPONumber  AND PRS.IdEstatus = 2
									LEFT JOIN Adinco.dbo.CO_SAPGR AS GR2 ON GR2.PO_SAPNumber = PRS.SAPPONumber  AND PRS.IdEstatus <> 2
									
									WHERE PO.Plant = @PLANT
										 AND PRS.IdEstatus = 3
									GROUP BY PRS.IdPRESES,
										CASE 
											WHEN PRS.SAPPONumber = '0' THEN 'No Apply'
											ELSE PRS.SAPPONumber
										END,
										VE.VendorName,
										PRS.CreadoEl,
										PRS.SAPSESNumber,
										PRS.MontoTotalPrefactura,
										SES.SESNumber,
										PRS.SAPSESNumber,
										PRS.ComentarioInterno,
										GR.PO_SAPNumber
									ORDER BY PRS.CreadoEl DESC

									INSERT INTO #PRESE
									SELECT
										PSES.IdPRESES,
										CASE 
											WHEN PSES.SAPPONumber = '0' THEN 'No Apply'
											ELSE PSES.SAPPONumber
										END,
										VE.VendorName,
										PSES.SAPSESNumber,
										PSES.MontoTotalPrefactura,
										PSES.CreadoEl,
										'Rejected' AS Estatus,
										'label label-danger' AS Span,
										case when GR.PO_SAPNumber is not null then 'With GR Associated'
												when max(GR2.PO_SAPNumber) is not null  then 'Without GR Associated'
													when SES.SESNumber is not null then SES.SESNumber
													when SES.SESNumber is null then 'Without SES Associated'
												End AS SESNumber,
										PSES.ComentarioInterno
									FROM Adinco.dbo.CO_SAPPRESES AS PSES
									JOIN Adinco.dbo.CO_SAPVendor AS VE ON VE.VendorIDSAP = PSES.SAPVendorNumber
									LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber = PSES.SAPPONumber
									LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber AND SES.SESNumber = PSES.SESN  AND PSES.IdEstatus = 2
									LEFT JOIN Adinco.dbo.CO_SAPGR AS GR ON GR.PO_SAPNumber = PSES.SAPPONumber  AND PSES.IdEstatus = 2
									LEFT JOIN Adinco.dbo.CO_SAPGR AS GR2 ON GR2.PO_SAPNumber = PSES.SAPPONumber  AND PSES.IdEstatus <> 2
									
									WHERE PSES.SAPPONumber = '0'
										AND PSES.Plant = @PLANT
										AND PSES.IdEstatus = 3
									GROUP BY PSES.IdPRESES,
										CASE 
											WHEN PSES.SAPPONumber = '0' THEN 'No Apply'
											ELSE PSES.SAPPONumber
										END,
										VE.VendorName,
										PSES.SAPSESNumber,
										PSES.MontoTotalPrefactura,
										PSES.CreadoEl,
										SES.SESNumber,
										PSES.SAPSESNumber,
										PSES.ComentarioInterno,
										GR.PO_SAPNumber
									
			END
			IF @IdEstatus = 0 
			BEGIN
									INSERT INTO #PRESE
									SELECT
										PRS.IdPRESES,
										CASE 
											WHEN PRS.SAPPONumber = '0' THEN 'No Apply'
											ELSE PRS.SAPPONumber
										END,
										VE.VendorName,
										PRS.SAPSESNumber,
										PRS.MontoTotalPrefactura,
										PRS.CreadoEl AS FechaCarga,
										CASE
											WHEN PRS.IdEstatus = 2 THEN 'Approved'
											WHEN PRS.IdEstatus = 1 THEN 'On Approval'
											WHEN PRS.IdEstatus = 3 THEN 'Rejected'
										END AS Estatus,
										CASE
											WHEN PRS.IdEstatus = 2 THEN 'label label-success'
											WHEN PRS.IdEstatus = 1 THEN 'label label-primary'
											WHEN PRS.IdEstatus = 3 THEN 'label label-danger'
										END AS Span,
																		
												
												case when GR.PO_SAPNumber is not null  then 'With GR Associated'
													when max(GR2.PO_SAPNumber) is not null  then 'Without GR Associated'
													when SES.SESNumber is not null then SES.SESNumber
													when SES.SESNumber is null then 'Without SES Associated'
												End	 AS SESNumber,
										PRS.ComentarioInterno
									FROM Adinco.dbo.CO_SAPPRESES AS PRS
										JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber = PRS.SAPPONumber --AND PO.SAPVendorNumber = PRS.SAPVendorNumber
										LEFT JOIN Adinco.dbo.CO_SAPVendor AS VE ON VE.VendorIDSAP = PRS.SAPVendorNumber
										LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PRS.SAPPONumber AND SES.SESReferenceNumber = PRS.SAPSESNumber AND SES.SESNumber = PRS.SESN  AND PRS.IdEstatus = 2
										LEFT JOIN Adinco.dbo.CO_SAPGR AS GR ON GR.PO_SAPNumber = PRS.SAPPONumber  AND PRS.IdEstatus = 2
										LEFT JOIN Adinco.dbo.CO_SAPGR AS GR2 ON GR2.PO_SAPNumber = PRS.SAPPONumber  AND PRS.IdEstatus <> 2
									WHERE PO.Plant = @PLANT
									GROUP BY PRS.IdPRESES,
										CASE 
											WHEN PRS.SAPPONumber = '0' THEN 'No Apply'
											ELSE PRS.SAPPONumber
										END,
										VE.VendorName,
										PRS.CreadoEl,
										PRS.SAPSESNumber,
										PRS.SESN,
										PRS.MontoTotalPrefactura,
										CASE
											WHEN PRS.IdEstatus = 2 THEN 'Approved'
											WHEN PRS.IdEstatus = 1 THEN 'On Approval'
											WHEN PRS.IdEstatus = 3 THEN 'Rejected'
										END,
										CASE
											WHEN PRS.IdEstatus = 2 THEN 'label label-success'
											WHEN PRS.IdEstatus = 1 THEN 'label label-primary'
											WHEN PRS.IdEstatus = 3 THEN 'label label-danger'
										END,
										PRS.SAPSESNumber,
										PRS.ComentarioInterno,
										PRS.IdEstatus,
										ISNULL(SES.SESNumber,'Without SES Associated'),
										PRS.SAPPONumber,
										GR.PO_SAPNumber,
										SES.SESNumber
									ORDER BY PRS.CreadoEl DESC;
									
									INSERT INTO #PRESE
									SELECT
										PSES.IdPRESES,
										CASE 
											WHEN PSES.SAPPONumber = '0' THEN 'No Apply'
											ELSE PSES.SAPPONumber
										END,
										VE.VendorName,
										PSES.SAPSESNumber,
										PSES.MontoTotalPrefactura,
										PSES.CreadoEl,
										CASE
											WHEN PSES.IdEstatus = 2 THEN 'Approved'
											WHEN PSES.IdEstatus = 1 THEN 'On Approval'
											WHEN PSES.IdEstatus = 3 THEN 'Rejected'
										END AS Estatus,
										CASE
											WHEN PSES.IdEstatus = 2 THEN 'label label-success'
											WHEN PSES.IdEstatus = 1 THEN 'label label-primary'
											WHEN PSES.IdEstatus = 3 THEN 'label label-danger'
										END AS Span,
										case when GR.PO_SAPNumber is not null then 'With GR Associated'
												when max(GR2.PO_SAPNumber) is not null  then 'Without GR Associated'
													when SES.SESNumber is not null then SES.SESNumber
													when SES.SESNumber is null then 'Without SES Associated'
												End AS SESNumber,
										PSES.ComentarioInterno
									FROM Adinco.dbo.CO_SAPPRESES AS PSES
									LEFT JOIN Adinco.dbo.CO_SAPVendor AS VE ON VE.VendorIDSAP = PSES.SAPVendorNumber
									LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber = PSES.SAPPONumber
									LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber  AND PSES.IdEstatus = 2
									LEFT JOIN Adinco.dbo.CO_SAPGR AS GR ON GR.PO_SAPNumber = PSES.SAPPONumber  AND PSES.IdEstatus = 2
									LEFT JOIN Adinco.dbo.CO_SAPGR AS GR2 ON GR2.PO_SAPNumber = PSES.SAPPONumber  AND PSES.IdEstatus <> 2
									WHERE PSES.SAPPONumber = '0'
										AND PSES.Plant = @PLANT
									GROUP BY PSES.IdPRESES,
										CASE 
											WHEN PSES.SAPPONumber = '0' THEN 'No Apply'
											ELSE PSES.SAPPONumber
										END,
										VE.VendorName,
										PSES.SAPSESNumber,
										PSES.MontoTotalPrefactura,
										PSES.CreadoEl,
										ISNULL(SES.SESNumber,'Without SES Associated'),
										PSES.SAPSESNumber,
										PSES.ComentarioInterno,
										CASE
											WHEN PSES.IdEstatus = 2 THEN 'Approved'
											WHEN PSES.IdEstatus = 1 THEN 'On Approval'
											WHEN PSES.IdEstatus = 3 THEN 'Rejected'
										END,
										CASE
											WHEN PSES.IdEstatus = 2 THEN 'label label-success'
											WHEN PSES.IdEstatus = 1 THEN 'label label-primary'
											WHEN PSES.IdEstatus = 3 THEN 'label label-danger'										
										END,
										GR.PO_SAPNumber,
										SES.SESNumber
	END;

	SELECT * 
	FROM #PRESE
	ORDER BY FechaCarga DESC;
	
END

