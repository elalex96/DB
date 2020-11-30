CREATE VIEW [dbo].[ConsultaReportMurphy]
AS

SELECT DISTINCT
	CASE
		WHEN 
				PSES.IdPRESES IS NULL
			AND CN.IdAceptacionCartaPCN IS NULL
			AND AF.IdAceptacionFactura IS NULL
				THEN '01 Proforma pending upload'
		WHEN
				PSES.IdPRESES IS NOT NULL 
			AND PSES.IdEstatus = 1
			AND CN.IdAceptacionCartaPCN IS NULL
			AND AF.IdAceptacionFactura IS NULL
				THEN '02 Proforma in approval process'
		WHEN
				PSES.IdPRESES IS NOT NULL 
			AND PSES.IdEstatus = 2
			AND CN.IdAceptacionCartaPCN IS NULL
			AND AF.IdAceptacionFactura IS NULL
				THEN '03 National content letter pending upload'
		WHEN
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 3
				THEN '04 Pending loading of national content letter(previous the national content letter rejected)'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 1
			AND AF.IdAceptacionFactura IS NULL
				THEN '05 National content letter in approval process'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NULL
				THEN '06 Invoice pending loading'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NOT NULL
			AND AF.IdEstatus = 3
				THEN '08 Invoice in approval process (previous invoice rejected)'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NOT NULL
			AND (AF.IdEstatusXML = 4 OR  AF.IdEstatusXML = 1003 OR AF.IdEstatusXML = 1)
			AND (AF.IdEstatusPDF = 4 OR AF.IdEstatusPDF = 1003 OR AF.IdEstatusPDF = 1)
			AND AF.IdEstatus = 1
				THEN '07 Invoice in approval process'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NOT NULL
			AND AF.IdEstatusXML = 2
			AND AF.IdEstatusPDF = 2
			AND AF.IdEstatus = 2
				THEN '09 Accepted Invoice'
ELSE ''
	END AS CurrentStaus,
	CASE
		WHEN 
				PSES.IdPRESES IS NULL
			AND CN.IdAceptacionCartaPCN IS NULL
			AND AF.IdAceptacionFactura IS NULL
				THEN  'Vendor'
		WHEN
				PSES.IdPRESES IS NOT NULL 
			AND PSES.IdEstatus = 1
			AND CN.IdAceptacionCartaPCN IS NULL
			AND AF.IdAceptacionFactura IS NULL
				THEN 'Operator'
		WHEN
				PSES.IdPRESES IS NOT NULL 
			AND PSES.IdEstatus = 2
			AND CN.IdAceptacionCartaPCN IS NULL
			AND AF.IdAceptacionFactura IS NULL
				THEN 'Vendor'
		WHEN
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 3
				THEN 'Vendor'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 1
			AND AF.IdAceptacionFactura IS NULL
				THEN 'Operator'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NULL
				THEN 'Vendor'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NOT NULL
			AND AF.IdEstatus = 3
				THEN 'Vendor'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			CN.IdAceptacionCartaPCN IS NOT NULL
			AND CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NOT NULL
			AND (AF.IdEstatusXML = 4 OR  AF.IdEstatusXML = 1003 OR AF.IdEstatusXML = 1)
			AND (AF.IdEstatusPDF = 4 OR AF.IdEstatusPDF = 1003 OR AF.IdEstatusPDF = 1)
			AND AF.IdEstatus = 1
				THEN 'Operator'
		WHEN
			--	PSES.IdPRESES IS NOT NULL 
			--AND PSES.IdEstatus = 2
			--AND CN.IdAceptacionCartaPCN IS NOT NULL
			CN.IdEstatus = 2
			AND AF.IdAceptacionFactura IS NOT NULL
			AND AF.IdEstatusXML = 2
			AND AF.IdEstatusPDF = 2
			AND AF.IdEstatus = 2
				THEN 'Operator'
	END AS CurrentUser,
	PO.SAPPONumber,
	PO.CreadoEl AS POUploadDate,
	V.VendorName AS Vendor,
	V.TaxID,
	PO.Currency AS POCurrency,
	--SUM(PO.Total) AS TotalPO,
	ISNULL(CAST(SES.SESNumber AS NVARCHAR(100)), 'Whitout SES register') AS SESNumber,
	ISNULL(SES.SESReferenceNumber, 'Whitout SES register') AS ReferenceNumber,
	ISNULL(SES.Currency, 'Whitout SES register') AS SESCurrency,

	--ISNULL(CAST(SUM(SES.Importe) AS NVARCHAR(100)), 'Whitout SES register') AS TotalSES,
	ISNULL(CAST(AP.IdAceptacionPedido AS NVARCHAR(100)),'Whitout Acceptance PO  register') AS AcceptancePO,
	ISNULL(CAST(PSES.IdPRESES AS NVARCHAR(100)), 'Whitout Proforma register') AS ProformaID,
	ISNULL(CAST(PSES.CreadoEl AS NVARCHAR(100)), 'Whitout Proforma register') AS ProformaUploadDate,
	ISNULL(CAST(PSES.MontoTotalPrefactura AS NVARCHAR(100)), 'Whitout Proforma register') AS ProformaTotal,
	ISNULL(EF.Name, 'Whitout Proforma register') AS ProformaStatus,
	ISNULL(CAST(CN.IdAceptacionCartaPCN AS NVARCHAR(100)), 'Whitout CN register') AS NationalContentID,
	ISNULL(CAST(CN.CreadoEl AS NVARCHAR(100)), 'Whitout CN register') AS NCUploadDate,
	ISNULL(TPSES.Name, 'Whitout CN register') AS NCStatus,
	ISNULL(CAST(AF.IdAceptacionFactura AS NVARCHAR(100)), 'Whitout Invoice register') AS InvoiceID,
	ISNULL(CAST(AF.CreadoEl AS NVARCHAR(100)), 'Whitout Invoice register') AS InvoiceUploadDate,
	ISNULL(EPR.Name, 'Whitout Invoice register') AS InvoiceStatus,
	CO.NumeroContrato AS ContractNumber,
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