CREATE PROCEDURE [dbo].[p_CO_SAP_InsActGRDetalle]
@pIdusuario int,
@pIdSAPGR int,
@pPOLineNumber varchar(50),
@pQuantity float,
@pUnitPrice float,
@pImporte float,
@pCostObject varchar(50),
@pMaterialGroup varchar(50),
@pMaterialGroupDesc2 varchar(50),
@pMaterialNumber varchar(50),
@pMaterialDescShort varchar(150),
@pMatDocN varchar(15),
@pMatDocItem varchar(15),
@DocumentDate varchar(15)
as
begin 
	IF EXISTS(select 1 from CO_SAPGRDataDetalle where IdSAPGR = @pIdSAPGR and POLineNumber =  @pPOLineNumber and MatDocN = @pMatDocN)
	BEGIN
		UPDATE CO_SAPGRDataDetalle
		SET 
			Quantity = @pQuantity,
			UnitPrice = @pUnitPrice,
			Importe = @pImporte,
			CostObject = @pCostObject ,
			MaterialGroup = @pMaterialGroup,
			MaterialGroupDesc2 = @pMaterialGroupDesc2,
			MaterialNumber = @pMaterialNumber, 
			MaterialDescShort = @pMaterialDescShort,
			MatDocN = @pMatDocN,
			MatDocItem = @pMatDocItem,
			ModificadoEl = getdate(),
			ModificadoPor = @pIdusuario
			where IdSAPGR = @pIdSAPGR and POLineNumber =  @pPOLineNumber
	END
	else
	begin
		declare @IdSAPGRDetalle int = (select ISNULL(max(IdSAPGRDetalle),0) from CO_SAPGRDataDetalle)
		set @IdSAPGRDetalle = @IdSAPGRDetalle + 1

		insert into CO_SAPGRDataDetalle(
		IdSAPGRDetalle,IdSAPGR,POLineNumber,
		Quantity,UnitPrice,Importe,
		CostObject,MaterialGroup,MaterialGroupDesc2,
		MaterialNumber,MaterialDescShort,MatDocN,
		MatDocItem,CreadoEl,CreadoPor,DocumentDate) values 
		(@IdSAPGRDetalle,@pIdSAPGR,@pPOLineNumber,
		@pQuantity,@pUnitPrice,@pImporte,
		@pCostObject,@pMaterialGroup,@pMaterialGroupDesc2,
		@pMaterialNumber,@pMaterialDescShort,@pMatDocN,
		@pMatDocItem,GETDATE(),@pIdusuario,@DocumentDate)
	end
end
