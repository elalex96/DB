

-- p_SESGR_ProformasConflicto_Sel 10014
CREATE proc p_SESGR_ProformasConflicto_Sel
(
	@pIdContratista int
)
as
begin

	select		ses.IdContrato,
				SESNumber							=	ses.SESNumber,
				PO									=	PO_SAPNumer,
				Fecha								=	max(ses.CreadoEl),
				ReferenceNumber						=	ses.SESReferenceNumber,
				VendorName
	from		CO_SAPSES							ses
	inner join	CO_SAPPO							po 
	on			po.SAPPONumber						=	ses.PO_SAPNumer 
	and			po.Plant							=	ses.Plant
	inner join	[dbo].[CO_SAPContratista_Planta]	cp 	
	on			cp.Planta							=	ses.Plant
	inner join	CO_SAPVendor ven on ven.VendorIDSAP	=	po.SAPVendorNumber
	INNER join	[dbo].[CO_SAPPRESES]				pre 
	on			
				pre.SAPPONumber						=	ses.PO_SAPNumer
	and			pre.IdEstatus							=	1
	and			pre.SAPSESNumber					<>  ses.SESReferenceNumber
	
	where		cp.IdContratista					=	@pIdContratista	
	and		NOT EXISTS (
			select 1
			from [CO_SAPPRESES] s1
			where s1.idestatus = 2 AND
			s1.SESN = SES.SESNumber
	)	
	
	group by 	ses.IdContrato,
				 ses.SESNumber,
				 PO_SAPNumer,		
				 ses.SESReferenceNumber,
				 VendorName
	ORDER BY ses.IdContrato,
				 ses.SESNumber,
				 PO_SAPNumer,		
				 ses.SESReferenceNumber,
				 VendorName
end






	
	

