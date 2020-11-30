Create Proc p_IN_AL_GuardarUsuarioAlmacen
@pIdUsuarioAdinco int,
@pIdAlmacenes varchar(300)
as

	declare @idUsuarioPetrovendor int

	select @idUsuarioPetrovendor = up.Idusuario
	from AP_Usuario ua
	inner join Petrovendor.dbo.S_Usuario up on up.Correo COLLATE SQL_Latin1_General_CP1_CI_AS = ua.usuario COLLATE SQL_Latin1_General_CP1_CI_AS
	where ua.UsuarioID = @pIdUsuarioAdinco

	select IdAlmacen= splitdata
	into #tmpAlmacenes
	from [dbo].[fnSplitString](@pIdAlmacenes,',')

	begin tran

	delete Petrovendor.dbo.S_UsuarioAlmacen
	where IdUsuario = @idUsuarioPetrovendor

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	insert into Petrovendor.dbo.S_UsuarioAlmacen(
		IdUsuario,IdAlmacen,CreadoPor,CreadoEl
	)
	select @idUsuarioPetrovendor,IdAlmacen,@idUsuarioPetrovendor,getdate()
	from #tmpAlmacenes

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin:

	
