
CREATE Proc [dbo].[p_CO_InsUpdSAPMaterial]
@pIdContrato	int,
@pSAPMaterialNumber	varchar(20),
@pMaterialDescription	varchar(150),
@pMaterialLongText	varchar(500),
@pUnit	varchar(50),
@pCreadoPor	int,
@pPlant varchar(15),
@pKeyLastImport varchar(50)
as

	if not exists (
		select 1
		from [CO_SAPMaterial]
		where IdContrato = @pIdContrato and
		SAPMaterialNumber = @pSAPMaterialNumber
	)
	begin

		insert into [dbo].[CO_SAPMaterial](
			IdContrato,SAPMaterialNumber,MaterialDescription,MaterialLongText,
			Unit,CreadoEl,CreadoPor,Plant,Activo,KeyLastImport
		)
		values(
			@pIdContrato,@pSAPMaterialNumber,@pMaterialDescription,@pMaterialLongText,
			@pUnit,getdate(),@pCreadoPor,@pPlant,1,@pKeyLastImport
		)
	end
	else
	begin
		update [CO_SAPMaterial]
		set MaterialDescription = @pMaterialDescription,
			MaterialLongText = @pMaterialLongText,
			Unit = @pUnit,
			Plant = @pPlant,
			Activo = 1,
			KeyLastImport = @pKeyLastImport
		where IdContrato = @pIdContrato and
		SAPMaterialNumber = @pSAPMaterialNumber
	end

