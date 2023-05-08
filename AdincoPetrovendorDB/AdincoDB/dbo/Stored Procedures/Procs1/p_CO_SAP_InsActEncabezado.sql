CREATE PROCEDURE [dbo].[p_CO_SAP_InsActEncabezado]
@IdContrato int,
@SAPPONumber varchar(20),
@VersionNumber tinyint,
@SAPVendorNumber varchar(20), 
@Currency varchar(50),
@Deliveryaddress varchar(250),
@Comments varchar(250),
@CostObject varchar(20),
@Plant varchar(15),
@CreadoPor int,
@IdSAPData int out
as
begin
	IF	EXISTS(select 1 from co_sappodata where SAPPONumber = @SAPPONumber)
	BEGIN
		set @IdSAPData = (select IdSAPData from co_sappodata where SAPPONumber = @SAPPONumber)

		update CO_SAPPOData 
		set IdContrato = @IdContrato, SAPPONumber = @SAPPONumber, VersionNumber= @VersionNumber, SAPVendorNumber=@SAPVendorNumber,
			Currency = @Currency,  Deliveryaddress= @Deliveryaddress, Comments=@Comments, CostObject = @CostObject,Plant=@Plant,
			CreadoPor = @CreadoPor, ModificadoEl = getdate()
			where SAPPONumber = @SAPPONumber and IdSAPData = @IdSAPData
	end
	else	
	begin
		set @IdSAPData = (select isnull(max(IdSAPData),0) from co_sappodata)
		set @IdSAPData = @IdSAPData + 1

		insert into CO_SAPPOData 
		(IdSAPData,IdContrato,SAPPONumber,VersionNumber,
		SAPVendorNumber,Currency,Deliveryaddress,Comments,
		CostObject,Plant,CreadoEl,CreadoPor)
		values
		(@IdSAPData,@IdContrato,@SAPPONumber,@VersionNumber,
		@SAPVendorNumber,@Currency,@Deliveryaddress,@Comments,
		@CostObject,@Plant,GETDATE(),@CreadoPor)
	end
end

