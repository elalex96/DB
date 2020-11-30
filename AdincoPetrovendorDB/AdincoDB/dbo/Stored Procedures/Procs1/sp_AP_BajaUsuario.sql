Create Proc sp_AP_BajaUsuario
@pUsuarioID int,
@pModificadoPor int
As


	update ap_usuario
	set isActivo = 0,
		IsEliminado = 1,
		ModificadoPor = @pModificadoPor,
		ModificadoEl = getdate()
	where UsuarioID = @pUsuarioID