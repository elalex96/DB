Create Proc p_PR_EliminarPozo
@pId int
as

	delete PR_Pozo
	where Id = @pId