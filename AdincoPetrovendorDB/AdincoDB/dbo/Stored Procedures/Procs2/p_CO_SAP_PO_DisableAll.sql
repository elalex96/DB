
create proc p_CO_SAP_PO_DisableAll
@pIdContratista int
as

	update CO_SAPPO
	set POActivo = 0,
		CancaladoEl = case when CancaladoEl is null then getdate() else CancaladoEl end
	from CO_SAPPO po
	inner join CO_Contrato c on c.IdContrato = po.IdContrato
	where c.IdContratista = @pIdContratista