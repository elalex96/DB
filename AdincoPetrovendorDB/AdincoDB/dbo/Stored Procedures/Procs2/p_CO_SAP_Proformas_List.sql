CREATE PROC p_CO_SAP_Proformas_List
@pIdCotratista INT,
@pEstatus INT
AS
BEGIN

SELECT DISTINCT
    pr.IdPRESES,
    prov.IdProveedor,
    IdUsuarioPetrovendor = PR.CreadoPor,
    UsuarioPetrovendor   = usuP.Correo,
    pr.SAPPONumber,
    pr.SAPVendorNumber,
    pr.IdEstatus,
    pr.ItemNumber,
    pr.Justificacion,
    pr.SAPSESNumber,
    pr.MontoTotalPrefactura,
    pr.Plant,
    Contratista          = CI.RazonSocial
from
    CO_SAPPRESES                 pr (NOLOCK)
    INNER JOIN
        [dbo].[CO_SAPVendor]     ven (NOLOCK)
            on ven.VendorIDSAP = pr.SAPVendorNumber
    INNER JOIN
        Petrovendor..S_Proveedor prov (NOLOCK)
            on prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = ven.TaxID COLLATE SQL_Latin1_General_CP1_CI_AS
    INNER JOIN
        Petrovendor..S_Usuario   usuP (NOLOCK)
            on usuP.IdUsuario = pr.CreadoPor
    INNER JOIN
        CO_SAPPO                 PO (NOLOCK)
            ON PO.SAPPONumber = pr.SAPPONumber
    INNER JOIN
        CO_SAPContratista_Planta CP (NOLOCK)
            ON CP.Planta = PO.Plant
    INNER JOIN
        CO_Contratista           CI (NOLOCK)
            ON CI.IdContratista = CP.IdContratista
    LEFT JOIN
        CO_SAPSES                SES (NOLOCK)
            ON SES.SESReferenceNumber = pr.SAPSESNumber
               AND SES.SESNumber = pr.SESN
where
    pr.IdEstatus = @pEstatus

END

