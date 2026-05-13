 
CREATE VIEW [dbo].[ConsultaReporteMurphy]
AS

SELECT DISTINCT
	CASE
		WHEN 
				PSES.IdPRESES IS NULL
			AND CN.IdAceptacionCartaPCN IS NULL
			AND AF.IdAceptacionFactura IS NULL
				THEN 'Pending loading of the proforma'
		WHEN
				PSES.IdPRESES IS NOT NULL 
			AND PSES.IdEstatus = 1
			AND CN.IdAceptacionCartaPCN IS NULL
			AND AF.IdAceptacionFactura IS NULL
				THEN 'Pending evaluated the proforma'
		WHEN
				PSES.IdPRESES IS NOT NULL 
			AND PSES.IdEstatus = 2
			AND CN.IdAceptacionCartaPCN IS NULL
			AND AF.IdAceptacionFactura IS NULL
				THEN 'Pending loading of the national content letter'
		WHEN
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 3
				THEN 'Pending loading of national content letter(previous the national content letter rejected)'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 1
			AND AF.IdAceptacionFactura IS NULL
				THEN 'Pending evaluated the national content letter'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NULL
				THEN 'Pending loading of the invoice'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NOT NULL
			AND AF.IdEstatus = 3
				THEN 'Pending evaluated of the invoice (previous invoice rejected)'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NOT NULL
			AND (AF.IdEstatusXML = 4 OR  AF.IdEstatusXML = 1003 OR AF.IdEstatusXML = 1)
			AND (AF.IdEstatusPDF = 4 OR AF.IdEstatusPDF = 1003 OR AF.IdEstatusPDF = 1)
			AND AF.IdEstatus = 1
				THEN 'Pending evaluated of the invoice'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NOT NULL
			AND AF.IdEstatusXML = 2
			AND AF.IdEstatusPDF = 2
			AND AF.IdEstatus = 2
				THEN 'ACCEPTED INVOICE'
	END AS CurrentStaus,
	CASE
		WHEN 
				PSES.IdPRESES IS NULL
			AND CN.IdAceptacionCartaPCN IS NULL
			AND AF.IdAceptacionFactura IS NULL
				THEN  'PROVIDER'
		WHEN
				PSES.IdPRESES IS NOT NULL 
			AND PSES.IdEstatus = 1
			AND CN.IdAceptacionCartaPCN IS NULL
			AND AF.IdAceptacionFactura IS NULL
				THEN 'OPERATOR'
		WHEN
				PSES.IdPRESES IS NOT NULL 
			AND PSES.IdEstatus = 2
			AND CN.IdAceptacionCartaPCN IS NULL
			AND AF.IdAceptacionFactura IS NULL
				THEN 'PROVIDER'
		WHEN
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 3
				THEN 'PROVIDER'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 1
			AND AF.IdAceptacionFactura IS NULL
				THEN 'OPERATOR'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NULL
				THEN 'PROVIDER'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NOT NULL
			AND AF.IdEstatus = 3
				THEN 'PROVIDER'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NOT NULL
			AND (AF.IdEstatusXML = 4 OR  AF.IdEstatusXML = 1003 OR AF.IdEstatusXML = 1)
			AND (AF.IdEstatusPDF = 4 OR AF.IdEstatusPDF = 1003 OR AF.IdEstatusPDF = 1)
			AND AF.IdEstatus = 1
				THEN 'OPERATOR'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			--AND CN.IdAceptacionCartaPCN IS NOT NULL
			CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NOT NULL
			AND AF.IdEstatusXML = 2
			AND AF.IdEstatusPDF = 2
			AND AF.IdEstatus = 2
				THEN 'OPERATOR'
	END AS CurrentUser,
	PO.SAPPONumber,
	PO.CreadoEl AS POUploadDate,
	V.VendorName AS Proveedor,
	V.TaxID,
	PO.Currency AS CurrencyPO,
	--SUM(PO.Total) AS TotalPO,
	ISNULL(CAST(SES.SESNumber AS NVARCHAR(100)), 'Whitout SES register') AS SESNumber,
	ISNULL(SES.SESReferenceNumber, 'Whitout SES register') AS ReferenceNumber,
	ISNULL(SES.Currency, 'Whitout SES register') AS CurrencySES,
	--ISNULL(CAST(SUM(SES.Importe) AS NVARCHAR(100)), 'Whitout SES register') AS TotalSES,
	ISNULL(CAST(AP.IdAceptacionPedido AS NVARCHAR(100)),'Whitout Acceptance PO  register') AS AcceptancePO,
	ISNULL(CAST(PSES.IdPRESES AS NVARCHAR(100)), 'Whitout Proforma register') AS NoIdProforma,
	ISNULL(CAST(PSES.CreadoEl AS NVARCHAR(100)), 'Whitout Proforma register') AS ProformaUploadDate,
	ISNULL(CAST(PSES.MontoTotalPrefactura AS NVARCHAR(100)), 'Whitout Proforma register') AS TotalPrefactura,
	ISNULL(EF.Name, 'Whitout Proforma register') AS StatusProforma,
	ISNULL(CAST(CN.IdAceptacionCartaPCN AS NVARCHAR(100)), 'Whitout CN register') AS NoNationalContent,
	ISNULL(CAST(CN.CreadoEl AS NVARCHAR(100)), 'Whitout CN register') AS UploadNationalContent,
	ISNULL(TPSES.Name, 'Whitout CN register') AS StatusNationalContent,
	ISNULL(CAST(AF.IdAceptacionFactura AS NVARCHAR(100)), 'Whitout Invoice register') AS NoInvoice,
	ISNULL(CAST(AF.CreadoEl AS NVARCHAR(100)), 'Whitout Invoice register') AS UpladInvoice,
	ISNULL(EPR.Name, 'Whitout Invoice register') AS StatusInvoice,
	CO.NumeroContrato AS Contract,
	AC.NombreAreaContractual AS ContractArea,
	CON.RazonSocial AS Operator
FROM Adinco.dbo.CO_SAPPO AS PO
	LEFT JOIN Adinco.dbo.CO_SAPSES AS SES
		ON SES.PO_SAPNumer = PO.SAPPONumber AND PO.IdContrato = SES.IdContrato
	LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES
		ON PSES.SAPPONumber = SES.PO_SAPNumer 
			AND PSES.SAPSESNumber = SES.SESReferenceNumber
	LEFT JOIN Adinco.dbo.CO_SAPVendor AS V
		ON V.VendorIDSAP = PO.SAPVendorNumber
	LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP
		ON AP.IdPedido COLLATE Modern_Spanish_CI_AS = SES.PO_SAPNumer COLLATE Modern_Spanish_CI_AS
			AND AP.ReferenceNumber COLLATE Modern_Spanish_CI_AS = SES.SESReferenceNumber COLLATE Modern_Spanish_CI_AS
	LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS CN
		ON CN.IdAceptacionPedido = AP.IdAceptacionPedido
	LEFT JOIN dbo.MPY_MM_AceptacionFactura AS AF
		ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
	LEFT JOIN dbo.TA_Estatus AS TPSES
		ON TPSES.IdEstatus = CN.IdEstatus
	LEFT JOIN dbo.TA_Estatus AS EF
		ON EF.IdEstatus = PSES.IdEstatus
	LEFT JOIN dbo.TA_Estatus AS EPR
		ON EPR.IdEstatus = AF.IdEstatus
	LEFT JOIN Adinco.dbo.CO_Contrato AS CO 
		ON CO.IdContrato = CAST(AP.IdContrato AS INT)
	LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC
		ON AC.IdAreaContractual = CO.IdAreaContractual
	LEFT JOIN Adinco.dbo.CO_Contratista AS CON
		ON CON.IdContratista = CO.IdContratista
GROUP BY PSES.IdPRESES,
         PSES.IdEstatus,
         CN.IdAceptacionCartaPCN,
         CN.IdEstatus,
         AF.IdAceptacionFactura,
         AF.IdEstatusXML,
         AF.IdEstatusPDF,
         AF.IdEstatus,
         ISNULL(CAST(SES.SESNumber AS NVARCHAR(100)), 'Whitout SES register'),
         ISNULL(SES.SESReferenceNumber, 'Whitout SES register'),
         ISNULL(SES.Currency, 'Whitout SES register'),
         ISNULL(CAST(AP.IdAceptacionPedido AS NVARCHAR(100)), 'Whitout Acceptance PO  register'),
         ISNULL(CAST(PSES.IdPRESES AS NVARCHAR(100)), 'Whitout Proforma register'),
         ISNULL(CAST(PSES.CreadoEl AS NVARCHAR(100)), 'Whitout Proforma register'),
         ISNULL(CAST(PSES.MontoTotalPrefactura AS NVARCHAR(100)), 'Whitout Proforma register'),
         ISNULL(EF.Name, 'Whitout Proforma register'),
         ISNULL(CAST(CN.IdAceptacionCartaPCN AS NVARCHAR(100)), 'Whitout CN register'),
         ISNULL(CAST(CN.CreadoEl AS NVARCHAR(100)), 'Whitout CN register'),
         ISNULL(TPSES.Name, 'Whitout CN register'),
         ISNULL(CAST(AF.IdAceptacionFactura AS NVARCHAR(100)), 'Whitout Invoice register'),
         ISNULL(CAST(AF.CreadoEl AS NVARCHAR(100)), 'Whitout Invoice register'),
         ISNULL(EPR.Name, 'Whitout Invoice register'),
         PO.SAPPONumber,
         PO.CreadoEl,
         V.VendorName,
         V.TaxID,
         PO.Currency,
         CO.NumeroContrato,
         AC.NombreAreaContractual,
         CON.RazonSocial
