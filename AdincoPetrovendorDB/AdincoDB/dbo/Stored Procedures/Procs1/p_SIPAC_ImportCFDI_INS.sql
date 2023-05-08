create proc p_SIPAC_ImportCFDI_INS
@IdBitacora int,
@IdFactura  int
as

	Insert into [dbo].[SIPAC_ImportCFDI](
		IdBitacora,IdFactura,CreadoEl
	)
	select @IdBitacora,@IdFactura,getdate()