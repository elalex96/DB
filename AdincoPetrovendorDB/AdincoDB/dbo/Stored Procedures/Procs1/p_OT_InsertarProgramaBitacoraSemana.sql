Create proc p_OT_InsertarProgramaBitacoraSemana
@pIdOTProgramaBitacoraSemana	int,
@pIdOTSolicitud	int,
@pSemanaID	varchar(21),
@pFechaRegistro	datetime,
@pComentarios	varchar(500),
@pCreadoPor	varchar(50),
@pTipoUsuario tinyint --1.Operador 2.Subcontratista
as

	declare @pUsuarioPetrovendorID	int,
			@UsuarioAdincoID int

	select @pIdOTProgramaBitacoraSemana = isnull(max(IdOTProgramaBitacoraSemana),0) + 1
	from 	[OT_ProgramaBitacoraSemana]

	if(@pTipousuario = 1)
	begin
		select @UsuarioAdincoID = UsuarioID
		from AP_Usuario
		where Usuario = @pCreadoPor		
	end
	

	if(@pTipousuario = 2)
	begin
		select @pUsuarioPetrovendorID = IdUsuario
		from Petrovendor.dbo.S_Usuario
		where Correo = @pCreadoPor
	end
	
	

	insert into	[dbo].[OT_ProgramaBitacoraSemana](
		IdOTProgramaBitacoraSemana,		IdOTSolicitud,		SemanaID,				FechaRegistro,
		Comentarios,					CreadoPor,			UsuarioPetrovendorID,	
		UsuarioAdincoID,				TipoUsuario
	)
	values(
		@pIdOTProgramaBitacoraSemana,		@pIdOTSolicitud,		@pSemanaID,		getdate(),
		@pComentarios,						@pCreadoPor,			@pUsuarioPetrovendorID,
		@UsuarioAdincoID,								@pTipousuario
	)
