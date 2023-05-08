Create Proc sp_CO_EliminarCOPADE
@pIdCopade int
as

	delete CO_COPADE
	where IdCopade=@pIdCopade