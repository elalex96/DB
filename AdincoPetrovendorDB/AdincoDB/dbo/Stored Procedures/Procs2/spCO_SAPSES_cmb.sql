
create proc spCO_SAPSES_cmb
(
	@pPO_SAPNumber	varchar(50)
)
as
begin
	select	sap.IdContrato,
			sap.SESNumber,
			sap.SESLine,
			sap.PO_SAPNumer,
			sap.POLineNumber,
			sap.Quantity,
			sap.UnitPrice,
			sap.Currency,
			sap.Importe,
			sap.AccountAssignment,
			sap.CostObject,
			sap.MaterialGroup,
			sap.MaterialGroupDesc2,
			sap.UOM,
			sap.SESPostingDate,
			sap.SESServiceStart,
			sap.SESServiceEnd,
			sap.Plant,
			sap.SESReferenceNumber 
	from	CO_SAPSES				sap
	where	sap.PO_SAPNumer			=	@pPO_SAPNumber
end