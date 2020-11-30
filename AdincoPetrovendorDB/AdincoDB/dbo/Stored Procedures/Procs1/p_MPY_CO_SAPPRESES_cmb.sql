
-- p_MPY_CO_SAPPRESES_cmb '4500095093','5000407919'
create proc  p_MPY_CO_SAPPRESES_cmb
(
	@pSAPPONumber	varchar(50),
	@pMatDoc varchar(30)
)
as
begin
	select		distinct
				sap.IdPRESES,
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
				ven.VendorName,
				sapgr.MatDocN
	from		CO_SAPPRESES			sap
	inner join	CO_SAPVendor			ven 
	on			ven.VendorIDSAP			=		sap.SAPVendorNumber
	inner join	CO_SAPGR				sapgr
	on			sapgr.PO_SAPNumber		=		sap.SAPPONumber and
				sapgr.MatDocN =		@pMatDoc	
	where		sap.IdEstatus			=		1
	and			sap.SAPPONumber			=		@pSAPPONumber
end

