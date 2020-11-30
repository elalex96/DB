CREATE VIEW [dbo].[ConsultReportMurphy]
AS

    

  
  

  

    
      
   
    

    
      SELECT DISTINCT
    PO.SAPPONumber,
    PO.CreadoEl AS POUploadDate,
    V.VendorName AS Proveedor,
    PO.Currency AS CurrencyPO,
    SUM(PO.Total) AS TotalPO,
    ISNULL(CAST(SES.SESNumber AS NVARCHAR(100)), 'Whitout SES register') AS SESNumber,
    ISNULL(SES.SESReferenceNumber, 'Whitout SES register') AS ReferenceNumber,
    ISNULL(SES.Currency, 'Whitout SES register') AS CurrencySES,
    ISNULL(CAST(SUM(SES.Importe) AS NVARCHAR(100)), 'Whitout SES register') AS TotalSES,
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
    AC.NombreAreaContractual AS ContractArea
FROM Adinco.dbo.CO_SAPSES AS SES
    LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES
        ON PSES.SAPPONumber = SES.PO_SAPNumer 
            AND PSES.SAPSESNumber = SES.SESReferenceNumber
    JOIN Adinco.dbo.CO_SAPPO AS PO
        ON PO.SAPPONumber = SES.PO_SAPNumer AND PO.IdContrato = SES.IdContrato
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
        ON CO.IdContrato = SES.IdContrato
    LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC
        ON AC.IdAreaContractual = CO.IdAreaContractual
GROUP BY ISNULL(CAST(SES.SESNumber AS NVARCHAR(100)), 'Whitout SES register'),
         ISNULL(SES.SESReferenceNumber, 'Whitout SES register'),
         ISNULL(SES.Currency, 'Whitout SES register'),
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
         PO.Currency,
         CO.NumeroContrato,
         AC.NombreAreaContractual