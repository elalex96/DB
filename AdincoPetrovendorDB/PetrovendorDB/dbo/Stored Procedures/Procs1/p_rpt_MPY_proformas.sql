

Create proc p_rpt_MPY_proformas
as

/**************PCN******************************/

CREATE TABLE #tablePCN(
VendorName NVARCHAR(100),
TaxID NVARCHAR(100),
ReferenceNumber NVARCHAR(100),
Subtotal MONEY,
Currency NVARCHAR(10),
ValorFactrua MONEY,
CN FLOAT,
ProformaTotal MONEY,
PO varchar(20)
);

INSERT INTO #tablePCN
SELECT
	SV.VendorName,
	SV.TaxID AS VendorNumber,
	AP.ReferenceNumber AS InvoiceNumber,
	F.SubTotal AS InvoiceAmount,
	MN.TipoMonedaCorto AS Currency,
	SUM(VP.ValorFactura),
	SUM(VP.ValorFactura * ISNULL(APD.PCN,0)) AS NacionalContent,
	PSES.MontoTotalPrefactura,
	PSES.SAPPONumber
FROM dbo.MPY_MM_AceptacionCartaPCN AS ACN
JOIN 
	dbo.MPY_MM_AceptacionPedido AS AP 
	ON AP.IdAceptacionPedido = ACN.IdAceptacionPedido
JOIN 
	dbo.MPY_MM_AceptacionPedidoDetalle AS APD 
	ON APD.IdAceptacionPedido = AP.IdAceptacionPedido 
JOIN 
	dbo.MPY_MM_PCN_ValoresPesos AS VP 
	ON VP.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
JOIN 
	Adinco.dbo.CO_SAPVendor AS SV 
	ON SV.VendorIDSAP COLLATE Modern_Spanish_CI_AS = AP.IdSubContratista COLLATE Modern_Spanish_CI_AS
LEFT JOIN 
	Adinco.dbo.CO_SAPPRESES AS PSES 
	ON PSES.SAPPONumber COLLATE Modern_Spanish_CI_AS = AP.IdPedido COLLATE Modern_Spanish_CI_AS 
	AND PSES.SAPSESNumber COLLATE Modern_Spanish_CI_AS = AP.ReferenceNumber COLLATE Modern_Spanish_CI_AS
LEFT JOIN 
	dbo.MPY_MM_AceptacionFactura AS AF 
	ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
LEFT JOIN 
	dbo.FI_Factura AS F 
	ON F.IdFactura = AF.IdFactura
LEFT JOIN 
	dbo.PV_TipoMoneda AS MN 
	ON MN.IdMoneda = F.IdMoneda
WHERE 
	ACN.IdAceptacionCartaPCN IS NOT NULL
GROUP BY SV.VendorName,
         SV.TaxID,
         AP.ReferenceNumber,
         MN.TipoMonedaCorto,
         F.SubTotal,
		 PSES.MontoTotalPrefactura,
		 PSES.SAPPONumber


SELECT
	VendorName,
    TaxID,
    ReferenceNumber,
	ProformaTotal AS ProformaAmount,
    Subtotal AS InvoiceAmount,
    Currency,
    SUM(CN) / SUM(ValorFactrua) AS NationalContent,
	PO
INTO
#tmpPCNFinal
	FROM #tablePCN
GROUP BY VendorName,
         TaxID,
         ReferenceNumber,
         Subtotal,
         Currency,
		 ProformaTotal,
		 PO

/*************************************************************/

CREATE TABLE #Complementos
(UUID           VARCHAR(MAX),
 FechaRecepcion DATETIME
);
	INSERT INTO 
	#Complementos
       SELECT cpdr.IdDocumento,
              f.FechaRecepcion
       FROM 
			dbo.FI_Factura f 
	   JOIN 
			dbo.FI_ComplementoDePago cp 
			ON cp.IdFactura = f.IdFactura
			AND IdContrato IN (10039, 10053)
       JOIN dbo.FI_CPDocRelacionado cpdr 
			ON cpdr.IdComplementoDePago = cp.IdComplementoDePago
       WHERE TipoComprobante = 'P'
       AND 
				IdContrato IN(10039, 10053)

SELECT 
		Company = ctista.NombreContratista,
		SAPV.VendorName AS [Vendor Name],
       SAPV.VendorIDSAP AS [Vendor Number],
	   CASE 
		WHEN prov.IdNacionalidad = 1 
			THEN 'Mexican' 
			ELSE 'Foreign'  
		END AS [Company Registration],
       PO.SAPPONumber AS PO#,
       PSES.IdPRESES AS [Vendor Proforma #],
       CASE
           WHEN GR.PO_SAPNumber IS NOT NULL
                AND SES.PO_SAPNumer IS NOT NULL
           THEN 'Both'
           WHEN GR.PO_SAPNumber IS NOT NULL
                AND SES.PO_SAPNumer IS NULL
           THEN 'Materials'
           WHEN GR.PO_SAPNumber IS NULL
                AND SES.PO_SAPNumer IS NOT NULL
           THEN 'Service'
           ELSE 'Undefined'
       END AS [Item category],
       PSES.SAPSESNumber AS [Reference Number],
	   PSES.SESN AS [SES Number],
       PO.Currency,
       PSES.MontoTotalPrefactura AS [Proforma Total Amount],
	   isnull(max(pcn.NationalContent),0) AS PCN,
 
       /**INICIO Current Step**/
       CASE
           WHEN PSES.IdEstatus IS NULL
           THEN 'No proforma uploaded'
           WHEN PSES.IdEstatus = 1
           THEN 'Proforma on approval'
           WHEN PSES.IdEstatus = 3
           THEN 'Proforma rejected'
           WHEN PSES.IdEstatus = 2
           THEN
 
                                    /**Aprobacion de Carta CN**/
 
                                    CASE
                                        WHEN ACN.IdEstatus IS NULL
                                             AND PSES.IdEstatus = 2
                                        THEN 'Proforma approved / No NC letter uploaded'
                                        WHEN ACN.IdEstatus = 1
                                             AND PSES.IdEstatus = 2
                                        THEN 'Proforma approved / NC Letter on approval'
                                        WHEN ACN.IdEstatus = 3
                                             AND PSES.IdEstatus = 2
                                        THEN 'Proforma approved/ CN letter rejected'
                                        WHEN ACN.IdEstatus = 2
                                             AND PSES.IdEstatus = 2
                                        THEN
 
                                    /**Aprobacion de factura**/
 
                                    CASE
                                        WHEN ACN.IdEstatus = 2
                                             AND PSES.IdEstatus = 2
                                             AND AF.IdEstatus = 1
                                        THEN 'Proforma approved/ CN letter approved / Invoice on approval'
                                        WHEN ACN.IdEstatus = 2
                                             AND PSES.IdEstatus = 2
                                             AND AF.IdEstatus IS NULL
                                        THEN 'Proforma approved/ CN letter approved / No invoice uploaded'
                                        WHEN ACN.IdEstatus = 2
                                             AND PSES.IdEstatus = 2
                                             AND AF.IdEstatus = 1003
                                        THEN 'Proforma approved/ CN letter approved / No invoice uploaded'
                                        WHEN ACN.IdEstatus = 2
                                             AND PSES.IdEstatus = 2
                                             AND AF.IdEstatus = 3
                                        THEN 'Proforma approved/ CN letter approved / Invoice rejected'
                                        WHEN ACN.IdEstatus = 2
                                             AND PSES.IdEstatus = 2
                                             AND AF.IdEstatus = 2
                                        THEN 'Proforma approved/ CN letter approved / Invoice approved / Payment'
                                        WHEN ACN.IdEstatus = 2
                                             AND PSES.IdEstatus = 2
                                             AND AF.IdEstatus = 4
                                        THEN 'Proforma approved/ CN letter approved / Invoice rejected-E'
                                    END
                                    END
           ELSE 'NO proforma register'
       END AS [Current Step],
 
       /**FIN Current Step**/
       /**INICIO Days in Current Status**/
 
       CASE
 
              /**Dias en aprobacion de Proforma**/
 
           WHEN PSES.IdEstatus IS NULL
           THEN
 
              /**No tiene registro de proforma**/
 
              NULL
           WHEN PSES.IdEstatus = 1
           THEN
 
              /**Dias en aprobacion proforma**/
 
              DATEDIFF(DAY, PSES.CreadoEl, GETDATE())
           WHEN PSES.IdEstatus = 3
           THEN 0
 
              /**Rechazada'**/
 
           WHEN PSES.IdEstatus = 2
           THEN
 
              /**Dias en Aprobacion de Carta CN**/
 
              CASE
                  WHEN ACN.IdEstatus IS NULL
                       AND PSES.IdEstatus = 2
                  THEN
 
              /**No tiene registro de Carta CN**/
 
              NULL
                  WHEN ACN.IdEstatus = 1
                       AND PSES.IdEstatus = 2
                  THEN
 
              /**Dias en aprobacion Contenido Nacional**/
 
              DATEDIFF(DAY, ACN.CreadoEl, GETDATE())
                  WHEN ACN.IdEstatus = 3
                       AND PSES.IdEstatus = 2
                  THEN 0
 
              /**Rechazada'**/
 
                  WHEN ACN.IdEstatus = 2
                       AND PSES.IdEstatus = 2
                  THEN
 
              /**Dias en Aprobacion de factura**/
 
              CASE
                  WHEN ACN.IdEstatus = 2
                       AND PSES.IdEstatus = 2
                       AND AF.IdEstatus IS NULL
                  THEN
 
              /**No tiene registro de Factura**/
 
              NULL
                  WHEN ACN.IdEstatus = 2
                       AND PSES.IdEstatus = 2
                       AND AF.IdEstatus = 1003
                  THEN
 
              /**Se cargo la factura pero no ha sido enviada a aprobacion por el Proveedor **/
 
              NULL
                  WHEN ACN.IdEstatus = 2
                       AND PSES.IdEstatus = 2
                       AND AF.IdEstatus = 3
                  THEN 0
 
              /**Rejected'**/
 
                  WHEN ACN.IdEstatus = 2
                       AND PSES.IdEstatus = 2
                       AND AF.IdEstatus = 2
                  THEN 0
 
              /**'Factura aprobada y pendiente de pago'**/
 
              END
              END
           ELSE NULL
       END AS DaysCurrentStep,
 
       /**Days in Current Status**/
 
       PSES.CreadoEl AS [Proforma Uploaded Date],
       CASE
           WHEN PSES.IdEstatus = 3
           THEN PSES.ModificadoEl
           ELSE NULL
       END AS [Proforma Rejected Date],
       CASE
           WHEN PSES.IdEstatus = 3
           THEN PSES.Justificacion
           ELSE NULL
       END AS [Reason for rejection],
       --SES created Date from SAP
       CASE
           WHEN PSES.IdEstatus = 2
           THEN PSES.ModificadoEl
           ELSE NULL
       END AS [Approve proforma date],
       ACN.CreadoEl AS [National Content letter submitted],
       CASE
           WHEN ACN.IdEstatus = 2
           THEN ACN.FechaEvaluacion
           ELSE NULL
       END AS [National Content letter approved],
       AF.FechaCargaXML AS [Final invoice Uploaded to ADINCO],
       CASE
           WHEN(AF.IdEstatusXML = 3
                OR AF.IdEstatusXML = 4)
           THEN AF.FechaAprobacion
           ELSE NULL
       END AS [AP Rejects invoice Date],
       CASE
           WHEN AF.IdEstatusXML = 2
           THEN AF.FechaAprobacion
           ELSE NULL
       END AS [AP Approves Final Invoice],
       T.CreadoEn AS [Date TMF uploads PDF of Payment confirmation to ADINCO],
       c.FechaRecepcion AS [Upload Complento de Pago (CDP)]
	FROM 
		Adinco.dbo.CO_SAPPO AS PO
     LEFT JOIN 
			Adinco.dbo.CO_SAPPRESES AS PSES 
			ON PSES.SAPPONumber = PO.SAPPONumber
     LEFT JOIN 
			dbo.MPY_MM_AceptacionPedido AS AP 
			ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS
			AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS
     LEFT JOIN 
			dbo.MPY_MM_AceptacionFactura AS AF 
			ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
     LEFT JOIN 
			dbo.MPY_MM_AceptacionCartaPCN AS ACN 
			ON ACN.IdAceptacionPedido = AP.IdAceptacionPedido
     LEFT JOIN 
			Adinco.dbo.CO_SAPVendor SAPV 
			ON SAPV.VendorIDSAP = PO.SAPVendorNumber
	 LEFT JOIN 
			Petrovendor.dbo.S_Proveedor prov 
			ON prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = SAPV.TaxID COLLATE SQL_Latin1_General_CP1_CI_AS
     LEFT JOIN 
			Adinco.dbo.CO_SAPGR GR 
			ON GR.PO_SAPNumber = PO.SAPPONumber
     LEFT JOIN 
			Adinco.dbo.CO_SAPSES SES 
			ON SES.PO_SAPNumer = PO.SAPPONumber
     LEFT JOIN 
			dbo.FI_Factura FP 
			ON FP.IdFactura = AF.IdFactura
     LEFT JOIN 
			Adinco.dbo.FI_Factura FA 
			ON FA.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = FP.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
     LEFT JOIN 
			Adinco.dbo.FI_TransferFactura TF 
			ON TF.IdFactura = FA.IdFactura
     LEFT JOIN 
			Adinco.dbo.FI_Transfer T 
			ON T.IdTransferencia = TF.IdTransfer
    LEFT JOIN 
			#Complementos c 
			ON fa.UUID = c.UUID
	LEFT JOIN 
			Adinco.[dbo].[CO_SAPContratista_Planta] planta 
			ON planta.planta = po.plant
	LEFT JOIN
			Adinco..CO_Contratista ctista 
			ON  ctista.IdContratista = planta.IdContratista
	LEFT JOIN 
			#tmpPCNFinal pcn 
			ON pcn.PO = PSES.SAPPONumber 
			and pcn.ReferenceNumber = PSES.SAPSESNumber
GROUP BY 
		prov.IdNacionalidad,
		ctista.NombreContratista,
		CASE
             WHEN PSES.IdEstatus = 3
             THEN PSES.ModificadoEl
             ELSE NULL
         END,
         CASE
             WHEN PSES.IdEstatus = 3
             THEN PSES.Justificacion
             ELSE NULL
         END,
         CASE
             WHEN PSES.IdEstatus = 2
             THEN PSES.ModificadoEl
             ELSE NULL
         END,
         CASE
             WHEN ACN.IdAceptacionCartaPCN IS NOT NULL
             THEN 'CN letter uploaded'
             ELSE 'No CN letter uploaded'
         END,
         CASE
             WHEN ACN.IdEstatus = 2
             THEN ACN.FechaEvaluacion
             ELSE NULL
         END,
         CASE
             WHEN ACN.IdEstatus = 3
             THEN ACN.FechaEvaluacion
             ELSE NULL
         END,
         CASE
             WHEN(AF.IdEstatusXML = 3
                  OR AF.IdEstatusXML = 4)
             THEN AF.FechaAprobacion
             ELSE NULL
         END,
         CASE
             WHEN AF.IdEstatusXML = 2
             THEN AF.FechaAprobacion
             ELSE NULL
         END,
         CASE
             WHEN GR.PO_SAPNumber IS NOT NULL
                  AND SES.PO_SAPNumer IS NOT NULL
             THEN 'Both'
             WHEN GR.PO_SAPNumber IS NOT NULL
                  AND SES.PO_SAPNumer IS NULL
             THEN 'Materials'
             WHEN GR.PO_SAPNumber IS NULL
                  AND SES.PO_SAPNumer IS NOT NULL
             THEN 'Service'
             ELSE 'Undefined'
         END,
         PO.SAPPONumber,
         PSES.IdPRESES,
         PSES.MontoTotalPrefactura,
         PSES.CreadoEl,
         ACN.CreadoEl,
         AF.FechaCargaXML,
         SAPV.VendorName,
         SAPV.VendorIDSAP,
         ACN.IdEstatus,
         PSES.SAPSESNumber,
         PO.Currency,
         PSES.IdEstatus,
         AF.IdEstatus,
         T.CreadoEn,
         c.FechaRecepcion,
		  PSES.SESN

DROP TABLE #Complementos;
DROP TABLE #tablePCN;
DROP TABLE #tmpPCNFinal;
GO
