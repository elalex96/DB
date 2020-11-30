
create proc p_SAP_CO_SAPSESData_Grd
(
	@pIdContrato	int
)
as
begin

	select		sd.IdSAPSES,
				sd.IdContrato,
				sd.SESNumber,
				sd.IdSAPPO,
				sd.Currency,
				sd.UOM,
				sd.SESPostingDate,
				sd.SESServiceStart,
				sd.SESServiceEnd,
				sd.Plant,
				sd.SESReferenceNumber,
				sdd.IdSAPSESDetalle,
				sdd.IdSAPSES,
				sdd.SESLine,
				sdd.Quantity,
				sdd.UnitPrice,
				sdd.Importe,
				sdd.AccountAssignment,
				sdd.MaterialGroup,
				sdd.MaterialGroupDesc2,
				sdd.CostObject
	from		CO_SAPSESData			sd
	inner join	CO_SAPSESDataDetalle	sdd
	on			sdd.IdSAPSES			=	sd.IdSAPSES
	where		sd.IdContrato		=	@pIdContrato
end


