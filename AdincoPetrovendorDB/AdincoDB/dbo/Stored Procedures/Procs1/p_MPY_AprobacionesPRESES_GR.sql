-- p_MPY_AprobacionesPRESES_GR
create proc p_MPY_AprobacionesPRESES_GR 
as
begin

	select		--cp.IdContratista,
				ses.IdContrato,
				GRNumber							=	ses.MatDocN,
				PO									=	ses.PO_SAPNumber,
				Fecha								=	max(ses.CreadoEl),
				ReferenceNumber						=	ses.GRReferenceNumber,
				VendorName,
				pre.IdEstatus
	from		CO_SAPGR							ses
	inner join	CO_SAPPO							po 
	on			po.SAPPONumber						=	ses.PO_SAPNumber 
	and			po.Plant							=	ses.Plant
	inner join	[dbo].[CO_SAPContratista_Planta]	cp 	
	on			cp.Planta							=	ses.Plant
	inner join	CO_SAPVendor						ven 
	on			ven.VendorIDSAP						=	po.SAPVendorNumber
	left join	[dbo].[CO_SAPPRESES]				pre 
	on			--pre.MatDocN							=	ses.MatDocN 
				--and			
				pre.SAPPONumber						=	ses.PO_SAPNumber
	and			pre.IdEstatus						=	1
	and			pre.SAPSESNumber					<>  ses.GRReferenceNumber
	where		--cp.IdContratista					=	10008--@pIdContratista
				--and			
				pre.IdPRESES						is	not	null 	
	group by 	ses.IdContrato,
				ses.MatDocN,
				ses.PO_SAPNumber,		
				ses.GRReferenceNumber,
				VendorName,
				pre.IdEstatus

end

