CREATE PROCEDURE [dbo].[p_CO_SAP_InsActDetalle]
@ItemNumber tinyint,
@SAPMaterialNumber varchar(50),
@Quantity float,
@UnitPrice float,
@Total float,
@DeliveryDate varchar(8),
@MaterialGroup varchar(50),
@MaterialGroupDescription varchar(250),
@ServiceLineNumber varchar(250),
@Quantity2 float,
@Price2 float,
@CostObject2 varchar(20),
@ServiceGroup varchar(50),
@ShortText varchar(100),
@ParentLineUOM varchar(50),
@ServiceShortText varchar(50),
@ServicesUOM varchar(50),
@POItemCategory tinyint,
@CreadoPor int,
@IdSAPData int 
as
begin 
declare @IdSAPDataDetalle int

	IF	EXISTS(select 1 from 
			   co_sappodatadetalle 
			   where 
			   ItemNumber = @ItemNumber and 
			   SAPMaterialNumber = @SAPMaterialNumber and 
			   IdSAPData =@IdSAPData and
			   ServiceLineNumber = @ServiceLineNumber)
	begin

	set @IdSAPDataDetalle = (select IdSAPDataDetalle 
							from co_sappodatadetalle where 
							ItemNumber = @ItemNumber and 
							SAPMaterialNumber = @SAPMaterialNumber and 
							IdSAPData =@IdSAPData
							and ServiceLineNumber = @ServiceLineNumber)
		update co_sappodatadetalle
		set ItemNumber = @ItemNumber, SAPMaterialNumber = @SAPMaterialNumber, Quantity = @Quantity,
			UnitPrice = @UnitPrice, Total = @Total, DeliveryDate= @DeliveryDate, MaterialGroup = @MaterialGroup,
			MaterialGroupDescription = @MaterialGroupDescription, ServiceLineNumber = @ServiceLineNumber, Quantity2 = @Quantity2,
			Price2 = @Price2, CostObject2 = @CostObject2, ServiceGroup = @ServiceGroup, ShortText = @ShortText, ParentLineUOM = @ParentLineUOM,
			ServiceShortText = @ServiceShortText,ServicesUOM= @ServicesUOM,POItemCategory = @POItemCategory,
			CreadoPor = @CreadoPor, ModificadoEl= GETDATE()
			where IdSAPDataDetalle = @IdSAPDataDetalle
	end
	else
	begin
		set @IdSAPDataDetalle = (select isnull(max(IdSAPDataDetalle),0) from co_sappodatadetalle)
		set @IdSAPDataDetalle = (@IdSAPDataDetalle + 1)

		insert into co_sappodatadetalle
		(IdSAPDataDetalle,ItemNumber,SAPMaterialNumber,Quantity,
		UnitPrice,Total,DeliveryDate,MaterialGroup,MaterialGroupDescription,
		ServiceLineNumber,Quantity2,Price2,CostObject2,ServiceGroup,ShortText,
		ParentLineUOM,ServiceShortText,ServicesUOM,POItemCategory,
		CreadoEl,CreadoPor,IdSAPData) 
		values
		(@IdSAPDataDetalle,@ItemNumber,@SAPMaterialNumber,@Quantity,
		@UnitPrice,@Total,@DeliveryDate,@MaterialGroup,@MaterialGroupDescription,
		@ServiceLineNumber,@Quantity2,@Price2,@CostObject2,@ServiceGroup,@ShortText,
		@ParentLineUOM,@ServiceShortText,@ServicesUOM,@POItemCategory,
		GETDATE(),@CreadoPor,@IdSAPData)
	end
	

end 
