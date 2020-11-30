CREATE Proc p_InsUpdSistemasMedicion
@pIdContrato int,
@pIdSistema	int out,
@pIdTipoSistema	int,
@pMarca	varchar(300),
@pModelo	varchar(300),
@pNoSerie	varchar(300),
@pTAG	varchar(300),
@pActivo	bit,
@pTipoMedidor	varchar(300)
as

	
	if not exists (
		select 1
		from PR_SistemasMedicion
		where IdSistema = @pIdSistema
	)
	begin
		insert into PR_SistemasMedicion(
					IdTipoSistema,		Marca,		Modelo,
			NoSerie,		TAG,				Activo,		TipoMedidor,
			IdContrato
		)
		values(		@pIdTipoSistema,		@pMarca,		@pModelo,
			@pNoSerie,		@pTAG,				@pActivo,		@pTipoMedidor,
			@pIdContrato) 

		select @pIdSistema = scope_identity()
	end
	Else
	Begin
		update PR_SistemasMedicion
		set IdTipoSistema = @pIdTipoSistema,
			Marca = @pMarca,
			Modelo = @pModelo,
			NoSerie = @pNoSerie,
			TAG = @pTAG,
			Activo = @pActivo,
			TipoMedidor=@pTipoMedidor
		where IdSistema = @pIdSistema and
		IdContrato = @pIdContrato
	End

