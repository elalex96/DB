
-- spCO_SAPPRESES_cmb '4500097817'
create proc spCO_SAPPRESES_cmb
(
	@pSAPPONumber	varchar(50)
)
as
begin
	select		sap.IdPRESES,
				sap.SAPPONumber,
				sap.SAPVendorNumber,
				sap.SAPSESNumber,
				sap.MontoTotalPrefactura,
				sap.SESN,
				sap.CreadoPor,
				sap.CreadoEl,
				sap.IdEstatus,
				sap.ItemNumber,
				sap.Justificacion,
				sap.ModificadoEl,
				sap.ModificadoPor,			
				sap.Plant,
				sap.ComentarioInterno,
				ven.VendorName
	from		CO_SAPPRESES			sap
	inner join	CO_SAPVendor			ven 
	on			ven.VendorIDSAP			=	sap.SAPVendorNumber
	where		sap.IdEstatus			=	1
	and			sap.SAPPONumber			=	@pSAPPONumber
end


