create proc p_EliminarTanque
@pId	int
as

	delete PR_Tanque
	where Id  = @pId