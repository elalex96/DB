CREATE PROc p_PR_ImportarExcelConciliadoProdDiariaPozo_Previo
@pId int out,
@pIdProdDiaria int out,
@pContrato varchar(250),
@pBloque varchar(250),
@pFecha DateTime,
@pPozo varchar(250),
@pNombreEstacion	varchar(200),
@pMedidor	smallint,
@pNominal	varchar(100),
@pFuente	varchar(100),
@pOperando	bit,
@pEst_64Plg	float,
@pCabeza	float,
@pLinea	float,
@pTemperatura	float,
@pGastoGas	float,
@pProdCondensadoNeto	float,
@pProdAceiteNeto	float,
@pProdPetroleoBruto	float,
@pAgua	float,
@pComentarios	varchar(250),
@pCreadoPor int,
@pError varchar(500) out,
@pIdContratoSession int,
@pTemperaturaArchivo float
as

	declare @pIdBloque int,
			@pIdPozo int,
				@IdContrato int

	set @pError = ''



	select @pidBloque =Id
	from PR_Bloque
	where replace(ltrim(RTRIM(Descripcion)),'','') = RTRIM(@pBloque)

	select @IdContrato = IdContrato
	from CO_Contrato
	where replace(ltrim(RTRIM(numerocontrato)),'Á','A') = rtrim(ltrim(@pContrato))


	SELECT @pIdPozo = Id
	FROM PR_Pozo p
	inner join CO_Contrato c on c.IdContrato = @IdContrato
		inner join [dbo].[CO_AreaContractual] ac on ac.IdAreaContractual = c.IdAreaContractual
		inner join CO_Instalacion i on i.IdAreaContractual = ac.IdAreaContractual and
								i.WelIID = p.Id
	where replace(ltrim(RTRIM(p.Nombre)),'','') = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(rtrim(@pPozo)),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U')

	set @pIdProdDiaria = 0

	SELECT @pIdProdDiaria  =isnull(Id,0)
	FROM [PR_ProdDiaria_Previo]
	WHERE Bloque = @pidBloque and
	convert(varchar,Fecha,112) = convert(varchar,@pFecha,112)

	if not exists (
		select 1
		from ap_usuario u
		inner join ap_perfilusuario pu on pu.UsuarioID =  u.UsuarioID
		inner join ap_perfil p on p.IdPerfil = pu.PerfilID 
		inner join CO_Contrato con on con.IdContrato = p.IdContrato and
							replace(ltrim(RTRIM(con.NumeroContrato)),'Á','A') = rtrim(ltrim(@pContrato))
		where u.UsuarioID = @pCreadoPor
	)
	begin
		set @pError = 'El usuario no está viculado con el contrato que se desea procesar' 
		
	end

	if(@pIdContratoSession <> @IdContrato)
	begin
		set @pError = 'El contrato de la sesión no coincide con el contrato del archivo a importar'
	end



	if(isnull(@pidBloque,0) =0)
		set @pError = 'No fue posible encontrar el bloque para : '+@pBloque

	if(isnull(@pIdPozo,0) = 0)
		set @pError = 'No fue posible encontrar el pozo para : '+@pPozo

	if @pError <> ''
		return

	begin tran

	

	if(isnull(@pIdProdDiaria,0) = 0)
	begin

		insert into [dbo].[PR_ProdDiaria_Previo](
				Bloque,		Fecha,		VolumenBombeado,		VolumenMedido,		VolumenReportado,
				DiferenciaVolumenBM,	DiferenciaVolumenMR,	FechaModificacion,	UsuarioModificacion,
				Estatus,   Algoritmo,	Temperatura
		)
		select @pidBloque,@pFecha,0,0,0,
		0,							0,					getdate(),			@pCreadoPor,
		1,					0,			@pTemperaturaArchivo


		SELECT @pIdProdDiaria = SCOPE_IDENTITY()

		if @@error <> 0
		begin 
			rollback tran
			goto fin
		end

	end
	Else
	Begin

		update [PR_ProdDiaria_Previo]
		set Temperatura = @pTemperaturaArchivo
		where Id = isnull(@pIdProdDiaria,0) 
	End

	if not exists(
		select 1
		from PR_ProdDiariaPozo_Previo
		where ProdDiaria = @pIdProdDiaria and
		Pozo = @pIdPozo and
		convert(varchar,Fecha,112) = convert(varchar,@pFecha,112)		
	)
	begin

	
		INSERT INTO PR_ProdDiariaPozo_Previo(
							ProdDiaria,		Fecha,					Estacion,				Pozo,
							NombreEstacion,	Medidor,				Nominal,				Fuente,
							Operando,		Est_64Plg,				Cabeza,					Linea,
							Temperatura,	GastoGas,				ProdCondensadoNeto,		ProdAceiteNeto,
							ProdPetroleoBruto,Agua,					Comentarios
			
		)
		SELECT				@pIdProdDiaria,	@pFecha,				0,						@pIdPozo,
							@pNombreEstacion,	@pMedidor,				@pNominal,				@pFuente,
							@pOperando,		@pEst_64Plg,				@pCabeza,					@pLinea,
							@pTemperatura,	@pGastoGas,				@pProdCondensadoNeto,		@pProdAceiteNeto,
							@pProdPetroleoBruto,@pAgua,					@pComentarios
		


		if @@error <> 0
		begin 
			rollback tran
			goto fin
		end

	END
	ELSE
	Begin

		update PR_ProdDiariaPozo_Previo
		set 
			NombreEstacion = @pNombreEstacion,
			Medidor = @pMedidor,
			Nominal = @pNominal,
			Fuente = @pFuente,
			Operando = @pOperando,
			Est_64Plg=@pEst_64Plg,
			Cabeza = @pCabeza,
			Linea = @pLinea,
			Temperatura = @pTemperatura,
			GastoGas = @pGastoGas,
			ProdCondensadoNeto=@pProdCondensadoNeto,
			ProdAceiteNeto = @pProdAceiteNeto,
			ProdPetroleoBruto = @pProdPetroleoBruto,
			Agua = @pAgua,
			Comentarios = @pComentarios
		where ProdDiaria = @pIdProdDiaria and
		Pozo = @pIdPozo and
		convert(varchar,Fecha,112) = convert(varchar,@pFecha,112)	
		
		if @@error <> 0
		begin 
			rollback tran
			goto fin
		end	
	END

	commit tran

	fin:

