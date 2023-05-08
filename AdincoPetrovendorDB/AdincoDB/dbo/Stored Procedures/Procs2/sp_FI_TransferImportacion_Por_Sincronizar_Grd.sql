
create proc sp_FI_TransferImportacion_Por_Sincronizar_Grd
(
	@pIdContratista		int
)
as
begin
	select		t.ID
	from		[FI_TransferImportacion]	t
	inner join	CO_Contrato					c 
	on			c.IdContrato				=	t.IdContrato
	left join	FI_TransferFactura			tf	
	on			t.IdTransferFactura			=	tf.IdTransferFactura
	where		Sincronizar					=	1 
	and			c.IdContratista				=	@pIdContratista
	group by	ID
end

