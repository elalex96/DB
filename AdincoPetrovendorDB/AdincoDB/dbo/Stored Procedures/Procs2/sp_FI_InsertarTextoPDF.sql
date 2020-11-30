Create Proc sp_FI_InsertarTextoPDF
@pIdFactura int,
@pTextoPDF text,
@pNumeroDocumento varchar(20),
@pPuestoExpedicion varchar(100),
@pIdConfig int
as


	if not exists (
		select 1
		from [FI_TextoPDF]
		where idfactura = @pIdFactura
	)
	begin
		insert into [dbo].[FI_TextoPDF](IdFactura,TextoPDF,NumeroDocumento,PuestoExpedicion,IdConfig)
		select @pIdFactura,@pTextoPDF,@pNumeroDocumento,@pPuestoExpedicion,@pIdConfig
	end
	else
	begin
		update [FI_TextoPDF]
		set TextoPDF = @pTextoPDF,
			NumeroDocumento = @pNumeroDocumento,
			PuestoExpedicion = @pPuestoExpedicion,
			IdConfig = @pIdConfig
		where idfactura = @pIdFactura
	end
