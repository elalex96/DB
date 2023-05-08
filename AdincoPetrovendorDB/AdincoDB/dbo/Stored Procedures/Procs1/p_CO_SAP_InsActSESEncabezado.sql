CREATE PROCEDURE [dbo].[p_CO_SAP_InsActSESEncabezado]
@pIdContrato int,
@pSESNumber varchar(50),
@pIdUsuario int ,
@pCurrency varchar(50),
@pUOM varchar(50),
@pSESPostingDate varchar(15),
@pSESServiceStart varchar(15),
@pSESServiceEnd varchar(15),
@pPlant varchar(20),
@pSESReferenceNumber varchar(20),
@pSAPPONumber varchar(50),
@pIdSAPSES int out
as
begin
	declare @IdSAPData int;
	IF	EXISTS(SELECT 1 FROM CO_SAPSESData WHERE IdContrato=@pIdContrato and SESNumber = @pSESNumber)
	begin
		set @IdSAPData = (select IdSAPData from CO_SAPPOData where SAPPONumber = @pSAPPONumber and IdContrato = @pIdContrato)
		set @pIdSAPSES = (SELECT IdSAPSES FROM CO_SAPSESData WHERE IdContrato=@pIdContrato and SESNumber = @pSESNumber)
			update CO_SAPSESData
			set 
			Currency = @pCurrency,
			UOM=@pUOM,
			SESPostingDate = @pSESPostingDate,
			SESServiceStart = @pSESServiceStart,
			SESServiceEnd=@pSESServiceEnd,
			Plant = @pPlant,
			SESReferenceNumber = @pSESReferenceNumber,
			ModificadoEl = GETDATE(),
			ModificadoPor=@pIdUsuario
			WHERE IdContrato=@pIdContrato and SESNumber = @pSESNumber
	end
	else
	begin
		set @pIdSAPSES = (select IsNull(Max(IdSAPSES),0) from CO_SAPSESData )
		set @pIdSAPSES = @pIdSAPSES + 1
		set @IdSAPData = (select IdSAPData from CO_SAPPOData where SAPPONumber = @pSAPPONumber and IdContrato = @pIdContrato)
		insert into CO_SAPSESData
		(IdSAPSES,IdContrato,SESNumber,IdSAPPO,
		Currency,UOM,SESPostingDate,SESServiceStart,
		SESServiceEnd,Plant,SESReferenceNumber,
		CreadoEl,CreadoPor) values 
		(@pIdSAPSES, @pIdContrato,@pSESNumber,@IdSAPData ,
		 @pCurrency,@pUOM,@pSESPostingDate,@pSESServiceStart,
		 @pSESServiceEnd,@pPlant,@pSESReferenceNumber,
		 GETDATE(), @pIdUsuario)
	end
end
