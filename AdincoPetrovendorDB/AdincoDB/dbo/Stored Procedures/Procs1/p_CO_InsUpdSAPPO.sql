
CREATE Proc [dbo].[p_CO_InsUpdSAPPO]
@pIdContrato	int,
@pSAPPONumber	varchar(20),
@pItemNumber	smallint,
@pVersionNumber	tinyint,
@pSAPVendorNumber	varchar(20),
@pSAPMaterialNumber	varchar(50),
@pQuantity	float,
@pUnitPrice	float,
@pCurrency	varchar(50),
@pTotal	float,
@pDeliveryaddress	varchar(250),
@pDeliveryDate	varchar(8),
@pComments	varchar(250),
@pCostObject	varchar(20),
@pMaterialGroup	varchar(50),
@pMaterialGroupDescription	varchar(250),
@pServiceLineNumber	varchar(50),
@pQuantity2	float,
@pPrice2	float,
@pCostObject2	varchar(20),
@pServiceGroup	varchar(50),
@pCreadoPor	int,
--
@pShortText varchar(100)='NA',
@pParentLineUOM varchar(50)='NA',
@pServiceShortText varchar(50)='NA',
@pServicesUOM varchar(50)='NA',
@pPlant varchar(15),
@pPOItemCategory tinyint,
@pNuevo bit out
as

	if not exists(
		select 1
		from [CO_SAPPO]
		where --@pIdContrato = IdContrato and
		SAPPONumber = @pSAPPONumber and
		ItemNumber = @pItemNumber

	)
	begin

		set @pNuevo = 1

		insert into [dbo].[CO_SAPPO](
			IdContrato,SAPPONumber,ItemNumber,VersionNumber,SAPVendorNumber,
		SAPMaterialNumber,Quantity,UnitPrice,Currency,Total,
		Deliveryaddress,DeliveryDate,Comments,CostObject,MaterialGroup,
		MaterialGroupDescription,ServiceLineNumber,Quantity2,Price2,CostObject2,
		ServiceGroup,CreadoEl,CreadoPor,ModificadoEl,
		--
		ShortText,ParentLineUOM,ServiceShortText,ServicesUOM,
		--
		Plant,
		--
		POItemCategory,
		POActivo

		)
		values(
		@pIdContrato,@pSAPPONumber,@pItemNumber,@pVersionNumber,@pSAPVendorNumber,
		@pSAPMaterialNumber,@pQuantity,@pUnitPrice,@pCurrency,@pTotal,
		@pDeliveryaddress,@pDeliveryDate,@pComments,@pCostObject,@pMaterialGroup,
		@pMaterialGroupDescription,@pServiceLineNumber,@pQuantity2,@pPrice2,@pCostObject2,
		@pServiceGroup,getdate(),@pCreadoPor,null,
		@pShortText,@pParentLineUOM,@pServiceShortText,@pServicesUOM,
		--
		@pPlant,
		--
		@pPOItemCategory,
		1
		)
	end
	else
	begin

		set @pNuevo = 0

		update [CO_SAPPO]
		set VersionNumber = @pVersionNumber,
		SAPVendorNumber = @pSAPVendorNumber,
		SAPMaterialNumber = @pSAPMaterialNumber,
		Quantity = @pQuantity,
		UnitPrice=@pUnitPrice,
		Currency = @pCurrency,
		Total = @pTotal,
		Deliveryaddress = @pDeliveryaddress,
		DeliveryDate = @pDeliveryDate,
		Comments = @pComments,
		CostObject = @pCostObject,
		MaterialGroup = @pMaterialGroup,
		MaterialGroupDescription = @pMaterialGroupDescription,
		ServiceLineNumber = @pServiceLineNumber,
		Quantity2 = @pQuantity2,
		Price2 = @pPrice2,
		CostObject2 = @pCostObject2,
		ServiceGroup = @pServiceGroup,
		ModificadoEl = getdate(),
		ShortText = @pShortText,
		ParentLineUOM=@pParentLineUOM,
		ServiceShortText=@pServiceShortText,
		ServicesUOM = @pServicesUOM,
		Plant = @pPlant,
		POItemCategory = @pPOItemCategory,
		POActivo = case when POActivo is not null then POActivo
						when POActivo is null then 1
				  End
		where @pIdContrato = IdContrato and
		SAPPONumber = @pSAPPONumber and
		ItemNumber = @pItemNumber
	end




