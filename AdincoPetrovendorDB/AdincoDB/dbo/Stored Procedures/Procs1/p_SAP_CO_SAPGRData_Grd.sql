
create proc p_SAP_CO_SAPGRData_Grd
(
	@pIdContrato	int
)
as
begin
	select		sgr.IdSAPGR,
				sgr.IdSAPPO,
				sgr.DocumentDate,
				sgr.UOM,
				sgr.DocPostingDate,
				sgr.Plant,
				sgr.ReferenceNumber,
				sgr.Moneda,
				sgr.AccountAssignment,
				sgr.MatDocN,

				sgrd.IdSAPGRDetalle,
				sgrd.IdSAPGR,
				sgrd.POLineNumber,
				sgrd.Quantity,
				sgrd.UnitPrice,
				sgrd.Importe,
				sgrd.CostObject,
				sgrd.MaterialGroup,
				sgrd.MaterialGroupDesc2,
				sgrd.MaterialNumber,
				sgrd.MaterialDescShort,
				sgrd.MatDocN,
				sgrd.MatDocItem,
				sgrd.DocumentDate
	from		CO_SAPGRData		sgr
	inner join	CO_SAPGRDataDetalle	sgrd
	on			sgr.IdSAPGR			=		sgrd.IdSAPGR
	inner join	CO_SAPPOData		sp
	on			sgr.IdSAPPO			=		sp.IdSAPData
	where		sp.IdContrato		=	@pIdContrato

end

