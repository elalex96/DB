
create proc p_SAP_CO_SAPPOData_Grd
(
	@pIdContrato	int
)
as
begin
	select		sp.IdSAPData,				sp.IdContrato,				sp.SAPPONumber,				sp.VersionNumber,				sp.SAPVendorNumber,
				sp.Currency,				sp.Deliveryaddress,			sp.Comments,				sp.CostObject,					sp.Plant,
				spd.IdSAPDataDetalle,		spd.ItemNumber,				spd.SAPMaterialNumber,		spd.Quantity,					spd.UnitPrice,
				spd.Total,					spd.DeliveryDate,			spd.MaterialGroup,			spd.MaterialGroupDescription,	spd.ServiceLineNumber,
				spd.Quantity2,				spd.Price2,					spd.CostObject2,			spd.ServiceGroup,				spd.ShortText,
				spd.ParentLineUOM,			spd.ServiceShortText,		spd.ServicesUOM,			spd.POItemCategory,				spd.IdSAPData
	from		CO_SAPPOData				sp
	inner join	CO_SAPPODataDetalle			spd
	on			sp.IdSAPData				=	spd.IdSAPData
	where		sp.IdContrato				=	@pIdContrato
end

