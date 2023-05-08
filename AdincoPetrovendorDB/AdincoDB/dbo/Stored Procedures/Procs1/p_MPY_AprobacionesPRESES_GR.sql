-- p_MPY_AprobacionesPRESES_GR
CREATE proc [dbo].[p_MPY_AprobacionesPRESES_GR]
as
begin
    select --cp.IdContratista,
        ses.IdContrato,
        GRNumber = ses.MatDocN,
        PO = ses.PO_SAPNumber,
        Fecha = max(ses.CreadoEl),
        ReferenceNumber = ses.GRReferenceNumber,
        VendorName,
        IdEstatus = 0,
        ses.MatDocN
    from CO_SAPGR ses
        inner join CO_SAPPO po
            on po.SAPPONumber = ses.PO_SAPNumber
               and po.Plant = ses.Plant
               and ISNULL(SES.GRReferenceNumber, '') <> ''
        inner join [dbo].[CO_SAPContratista_Planta] cp
            on cp.Planta = ses.Plant
        inner join CO_SAPVendor ven
            on ven.VendorIDSAP = po.SAPVendorNumber
        inner join CO_SAPPRESES PRO
            ON PRO.SAPPONumber = ses.PO_SAPNumber
               AND PRO.SAPSESNumber = SES.GRReferenceNumber
               AND PRO.IdEstatus = 1
    WHERE EXISTS
    (
        SELECT 1
        FROM CO_SAPPRESES PRO2
        WHERE PRO2.SAPPONumber = ses.PO_SAPNumber
              AND PRO2.IdEstatus = 1
    )
    group by ses.IdContrato,
             ses.MatDocN,
             ses.PO_SAPNumber,
             ses.GRReferenceNumber,
             VendorName
end