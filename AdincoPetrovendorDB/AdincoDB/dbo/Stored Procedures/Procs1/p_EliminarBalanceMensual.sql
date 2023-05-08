Create Proc p_EliminarBalanceMensual
@pIdContrato	int,
@pPuntoEntregaID	int,
@pFecha	date,
@pTipoHidrocarburo	varchar(50)
as


	delete PR_BalanceMensual	
	where IdContrato = @pIdContrato and
	PuntoEntregaID = @pPuntoEntregaID and
	Fecha =@pFecha	and 
	TipoHidrocarburo = @pTipoHidrocarburo