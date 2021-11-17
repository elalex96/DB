create proc p_CO_SAP_PO_Enable
@pIdContratista int,
@pPO varchar(20)
as

	update CO_SAPPO
	set POActivo = 1,
		CancaladoPor = null,
		CancaladoEl = null
	from CO_SAPPO po
	inner join CO_Contrato c on c.IdContrato = po.IdContrato
	where c.IdContratista = @pIdContratista and
	po.SAPPONumber = @pPO