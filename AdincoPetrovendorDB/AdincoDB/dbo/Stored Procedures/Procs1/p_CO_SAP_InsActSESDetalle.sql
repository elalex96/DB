CREATE PROCEDURE [dbo].[p_CO_SAP_InsActSESDetalle]
@pIdSAPSES int,
@pSESLine varchar(50),
@pIdUsuario int,
@pQuantity float,
@pUnitPrice float,
@pImporte float,
@pAccountAssignment varchar(50),
@pMaterialGroup	varchar(50),
@pMaterialGroupDesc2 varchar(50),
@pCostObject varchar(50)
as
begin
	IF	EXISTS(select 1 from CO_SAPSESDataDetalle where IdSAPSES=@pIdSAPSES and SESLine=@pSESLine)
	begin
		update CO_SAPSESDataDetalle
		set 
		Quantity=@pQuantity,
		UnitPrice=@pUnitPrice,Importe=@pImporte,
		AccountAssignment=@pAccountAssignment,MaterialGroup=@pMaterialGroup,
		MaterialGroupDesc2=@pMaterialGroupDesc2,
		CostObject=@pCostObject,ModificadoEl=GETDATE(),ModificadoPor=@pIdUsuario
		where IdSAPSES=@pIdSAPSES and SESLine=@pSESLine
	end
	else
	begin
		declare @IdSAPSESDetalle int = (select isnull(MAX(IdSAPSESDetalle),0) from CO_SAPSESDataDetalle)
		set @IdSAPSESDetalle  = @IdSAPSESDetalle +1
		
		INSERT INTO CO_SAPSESDataDetalle(IdSAPSESDetalle,
					IdSAPSES,SESLine,Quantity,
					UnitPrice,Importe,AccountAssignment,
					MaterialGroup,MaterialGroupDesc2,CostObject,
					CreadoEl,CreadoPor) 
					VALUES (@IdSAPSESDetalle,
					@pIdSAPSES,@pSESLine,@pQuantity,
					@pUnitPrice,@pImporte,@pAccountAssignment,
					@pMaterialGroup,@pMaterialGroupDesc2,@pCostObject,
					GETDATE(),@pIdUsuario)
	end
end
