-- [dbo].[SP_MPY_PF_PreFacturasVendor] 'HEM110203F26', 0
CREATE PROCEDURE [dbo].[SP_MPY_PF_PreFacturasVendor] --'HEM110203F26', 4
       -- Add the parameters for the stored procedure here
       @RFCProveedor VARCHAR(20),
       @IdEstatus INT
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

    -- Insert statements for procedure her


             IF @IdEstatus = 1
             BEGIN
             SELECT
                    V.VendorName,
                    ISNULL(PO.SAPPONumber,'No Apply') AS SAPPONumber,                  
                    PO.SAPPONumber,
                    PSES.SAPSESNumber,
                    PSES.IdPRESES,
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
                    ISNULL(CO.NombreContratista,COA.NombreContratista) AS NombreContratista,
                    ISNULL(PSES.SESN,0) AS SESNumber
             FROM Adinco.dbo.CO_SAPPRESES AS PSES--PRESES
                    LEFT JOIN Adinco.dbo.CO_SAPVendor AS V ON V.VendorIDSAP = PSES.SAPVendorNumber
                    LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber = PSES.SAPPONumber AND PO.SAPVendorNumber = PSES.SAPVendorNumber--PO
                    LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS CSP ON CSP.Planta = PO.Plant
                    LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = CSP.IdContratista
                    LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS SNA ON SNA.Planta = PSES.Plant
                    LEFT JOIN Adinco.dbo.CO_Contratista AS COA ON COA.IdContratista = SNA.IdContratista
                    LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PO.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber---SES
             WHERE V.TaxID = @RFCProveedor
                    AND PSES.IdPRESES IS NOT NULL
                    --AND PSES.SAPPONumber != '0'
                    AND PSES.IdEstatus = 1
             GROUP BY V.VendorName,
                           PO.SAPPONumber,
                           PSES.SAPSESNumber,
                           PSES.IdPRESES,
                           COA.NombreContratista,
                           PO.Plant,
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
                           CO.NombreContratista,
                           PSES.CreadoEl,
                           PSES.SESN
                           ORDER BY PSES.CreadoEl DESC
             END

             IF @IdEstatus = 2
             BEGIN
             SELECT
                    V.VendorName,
                    ISNULL(PO.SAPPONumber,'No Apply') AS SAPPONumber,                  
                    PO.SAPPONumber,
                    PSES.SAPSESNumber,
                    PSES.IdPRESES,
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
                    ISNULL(CO.NombreContratista,COA.NombreContratista) AS NombreContratista,
                    ISNULL(PSES.SESN,0) AS SESNumber
             FROM Adinco.dbo.CO_SAPPRESES AS PSES
                    LEFT JOIN Adinco.dbo.CO_SAPVendor AS V ON V.VendorIDSAP = PSES.SAPVendorNumber
                    LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber = PSES.SAPPONumber
                    LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS CSP ON CSP.Planta = PO.Plant
                    LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = CSP.IdContratista
                    LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS SNA ON SNA.Planta = PSES.Plant
                    LEFT JOIN Adinco.dbo.CO_Contratista AS COA ON COA.IdContratista = SNA.IdContratista
                    LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PO.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber AND SES.SESNumber = PSES.SESN
             WHERE V.TaxID = @RFCProveedor
                    AND PSES.IdPRESES IS NOT NULL
                    AND PSES.IdEstatus = 2
             GROUP BY V.VendorName,
                           PO.SAPPONumber,
                           PSES.SAPSESNumber,
                           PSES.IdPRESES,
                           COA.NombreContratista,
                           PO.Plant,
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
                           CO.NombreContratista,
                           PSES.CreadoEl,
                           PSES.SESN
                           ORDER BY PSES.CreadoEl DESC
             END
             IF @IdEstatus = 3
             BEGIN
             SELECT
                    V.VendorName,
                    ISNULL(PO.SAPPONumber,'No Apply') AS SAPPONumber,                  
                    PO.SAPPONumber,
                    PSES.SAPSESNumber,
                    PSES.IdPRESES,
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
                    ISNULL(CO.NombreContratista,COA.NombreContratista) AS NombreContratista,
                    ISNULL(PSES.SESN,0) AS SESNumber
             FROM Adinco.dbo.CO_SAPPRESES AS PSES
                    LEFT JOIN Adinco.dbo.CO_SAPVendor AS V ON V.VendorIDSAP = PSES.SAPVendorNumber
                    LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber = PSES.SAPPONumber
                    LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS CSP ON CSP.Planta = PO.Plant
                    LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = CSP.IdContratista
                    LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS SNA ON SNA.Planta = PSES.Plant
                    LEFT JOIN Adinco.dbo.CO_Contratista AS COA ON COA.IdContratista = SNA.IdContratista
                    LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PO.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber AND SES.SESNumber = PSES.SESN
             WHERE V.TaxID = @RFCProveedor
                    AND PSES.IdPRESES IS NOT NULL
                    AND PSES.IdEstatus = 3
             GROUP BY V.VendorName,
                           PO.SAPPONumber,
                           PSES.SAPSESNumber,
                           PSES.IdPRESES,
                           PO.Plant,
                           COA.NombreContratista,
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
                           CO.NombreContratista,
                           PSES.CreadoEl,
                           PSES.SESN
                           ORDER BY PSES.CreadoEl DESC
             END

             IF @IdEstatus = 0 
             BEGIN
             SELECT
                    V.VendorName,
                    PO.SAPPONumber,
                    PO.Currency,
                    0 AS IdPRESES,
                    0 AS Total,
                    CO.RazonSocial AS NombreContratista,
                    SESNumber = 0--ISNULL(SES.SESNumber,0) AS SESNumber
             FROM Adinco.dbo.CO_SAPPO AS PO
                    LEFT JOIN Adinco.dbo.CO_SAPVendor AS V ON V.VendorIDSAP = PO.SAPVendorNumber
                    LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS CSP ON CSP.Planta = PO.Plant
                    LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = CSP.IdContratista
                    LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PO.SAPPONumber
             WHERE V.TaxID = @RFCProveedor and 
			 isnull(PO.POActivo,0) = 1 --Solo PO Activas
             GROUP BY V.VendorName,
                           PO.SAPPONumber,
                           PO.Currency,
                           CO.RazonSocial,
                           SES.SESNumber
             
             END
             IF @IdEstatus = 4
             BEGIN
             SELECT
                    V.VendorName,
                    ISNULL(PO.SAPPONumber,'No Apply') AS SAPPONumber,
                    PSES.SAPSESNumber,
                    PSES.IdPRESES,
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
                    ISNULL(CO.NombreContratista,COA.NombreContratista) AS NombreContratista,
                    ISNULL(PSES.SESN,0) AS SESNumber
             FROM Adinco.dbo.CO_SAPPRESES AS PSES--PSES
                    LEFT JOIN Adinco.dbo.CO_SAPVendor AS V ON V.VendorIDSAP = PSES.SAPVendorNumber
                    LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber = PSES.SAPPONumber--PO
                    LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS CSP ON CSP.Planta = PO.Plant
                    LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS SNA ON SNA.Planta = PSES.Plant
                    LEFT JOIN Adinco.dbo.CO_Contratista AS COA ON COA.IdContratista = SNA.IdContratista
                    LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = CSP.IdContratista
                    LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PO.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber AND SES.SESNumber = PSES.SESN
             WHERE V.TaxID = @RFCProveedor
                    AND PSES.IdPRESES IS NOT NULL
             GROUP BY V.VendorName,
                           PO.SAPPONumber,
                           PSES.SAPSESNumber,
                           PSES.IdPRESES,
                           PO.Plant,
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
                           CO.NombreContratista,
                           COA.NombreContratista,
                           PSES.CreadoEl,
                           PSES.SESN
                           ORDER BY PSES.CreadoEl DESC
             END

END



