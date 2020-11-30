Create Proc p_DesactivarSistemasMedicion
@pIdSistema	int 
as

	update PR_SistemasMedicion
	set Activo = 0
	where IdSistema = @pIdSistema