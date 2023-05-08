Create Proc p_CO_EliminarLaboratorio
@pID int
as

	delete certilabAmatitlan
	WHERE [Id Folio] = @pID 
