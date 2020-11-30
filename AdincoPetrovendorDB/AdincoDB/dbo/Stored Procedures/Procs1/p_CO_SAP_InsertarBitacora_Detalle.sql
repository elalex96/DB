create proc [dbo].[p_CO_SAP_InsertarBitacora_Detalle]
@pIdImportBitacora int,
@pNombreArchivo varchar(100),
@pTieneError bit,
@pError varchar(250),
@pCreadoPor int
as


	declare @id int

	select @id = isnull(max(Id),0) + 1
	from [CO_SAP_ImportBitacora_Detalle]

	begin tran

	insert into [dbo].[CO_SAP_ImportBitacora_Detalle](
		Id,			IdImportBitacora,		NombreArchivo,	Error,
		TieneError,	CreadoEl
	)
	select @id,		@pIdImportBitacora,		@pNombreArchivo,@pError,
	@pTieneError,	getdate()

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	update CO_SAP_ImportBitacora
	set Fin = getdate(),
		TieneError = case when (
								select count(1) 
								from [CO_SAP_ImportBitacora_Detalle]
								where IdImportBitacora = @pIdImportBitacora and
								TieneError = 1
								) > 0 then 1
							else 0
						End
	where id = @pIdImportBitacora

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end


	commit tran

	fin:
