CREATE PROCEDURE [dbo].[p_CO_SAP_InsActGREncabezado]
@pIdContrato int,
@pIdUsuario int,
@pSAPPONumber varchar(50),
@pDocumentDate varchar(50),
@pUOM varchar(50),
@pDocPostingDate varchar(15),
@pPlant varchar(15),
@pReferenceNumber varchar(20),
@pMoneda varchar(50),
@pAccountAssignment varchar(1),
@IdSAPGR INT OUT,
@pMatDocN varchar(15)
as
begin 
	declare @IdSAPPO varchar(50) = (select IdSAPData from CO_SAPPOData where SAPPONumber = @pSAPPONumber and IdContrato = @pIdContrato)
	IF EXISTS(select 1 from CO_SAPGRData where IdSAPPO = @IdSAPPO and DocumentDate = @pDocumentDate AND MatDocN = @pMatDocN)
	BEGIN
		SET @IdSAPGR = (SELECT IdSAPGR FROM CO_SAPGRData WHERE IdSAPPO = @IdSAPPO and DocumentDate = @pDocumentDate AND MatDocN = @pMatDocN)
		update CO_SAPGRData
		set 
			UOM=@pUOM,
			DocPostingDate=@pDocPostingDate,
			Plant = @pPlant,
			ReferenceNumber= @pReferenceNumber,
			Moneda = @pMoneda,
			AccountAssignment = @pAccountAssignment,
			ModificadoEl = GETDATE(),
			ModificadoPor = @pIdUsuario
			WHERE IdSAPGR = @IdSAPGR

	END
	else
	begin
		SET @IdSAPGR = (SELECT ISNULL(MAX(IdSAPGR),0) FROM CO_SAPGRData)
		SET @IdSAPGR = @IdSAPGR + 1
		INSERT INTO CO_SAPGRData
		(IdSAPGR,IdSAPPO,DocumentDate,UOM,
		DocPostingDate,Plant,ReferenceNumber,
		Moneda,AccountAssignment,CreadoEl,CreadoPor,MatDocN)
		VALUES
		(@IdSAPGR,@IdSAPPO,@pDocumentDate,@pUOM,
		@pDocPostingDate,@pPlant,@pReferenceNumber,
		@pMoneda,@pAccountAssignment,GETDATE(),@pIdUsuario,@pMatDocN)

	end
end
