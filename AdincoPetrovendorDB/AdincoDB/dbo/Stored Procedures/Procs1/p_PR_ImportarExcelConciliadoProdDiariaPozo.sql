CREATE Proc p_PR_ImportarExcelConciliadoProdDiariaPozo
@pId int out,
@pIdProdDiaria int out,
@pContrato varchar(250),
@pBloque varchar(250),
@pFecha DateTime,
@pPozo varchar(250),
@pM3 Float,
@pBLS Float,
@pCreadoPor int,
@pError varchar(250) out,
@pIdContratoSession int,
@pEsPetroleo bit,
@pTemperatura float
as

	declare @pIdBloque int,
			@pIdPozo int,
				@IdContrato int,
				@IdPuntoEntrega int,
				@factorConversion decimal(18,12),
				@mmpcm decimal(24,8)

	set @pError = ''

	set @pTemperatura = case when isnull(@pTemperatura,0) = 0 then 20 else @pTemperatura end

	select @pidBloque =Id
	from PR_Bloque
	where Descripcion = RTRIM(@pBloque)

	select @IdContrato = IdContrato
	from CO_Contrato
	where replace(ltrim(RTRIM(numerocontrato)),'Á','A') = replace(rtrim(ltrim(@pContrato)),'Á','A')

	SELECT @pIdPozo = Id,
		@IdPuntoEntrega = PuntoEntregaID
	FROM PR_Pozo p
	inner join CO_Contrato c on c.IdContrato = @IdContrato
		inner join [dbo].[CO_AreaContractual] ac on ac.IdAreaContractual = c.IdAreaContractual
		inner join CO_Instalacion i on i.IdAreaContractual = ac.IdAreaContractual and
								i.WelIID = p.Id
	where p.Nombre = rtrim(@pPozo) 

	set @pIdProdDiaria = 0

	SELECT @pIdProdDiaria  =isnull(Id,0)
	FROM [PR_ProdDiaria]
	WHERE Bloque = @pidBloque and
	convert(varchar,Fecha,112) = convert(varchar,@pFecha,112)

	
	

	if not exists (
		select 1
		from ap_usuario u
		inner join ap_perfilusuario pu on pu.UsuarioID =  u.UsuarioID
		inner join ap_perfil p on p.IdPerfil = pu.PerfilID 
		inner join CO_Contrato con on con.IdContrato = p.IdContrato and
							replace(ltrim(RTRIM(con.numerocontrato)),'Á','A') = replace(rtrim(ltrim(@pContrato)),'Á','A')
		where u.UsuarioID = @pCreadoPor
	)
	begin
		set @pError = 'El usuario no está vinculado con el contrato que se desea procesar'		
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


	if isnull(@IdPuntoEntrega,0) > 0 and @pEsPetroleo = 0
	begin
		select @factorConversion = FactorConversion
		from PR_FactorPuntoEntrega
		where PuntoEntregaID = @IdPuntoEntrega and
		datepart(year,mes) = datepart(year,@pFecha) and
		datepart(month,mes) = datepart(month,@pFecha)

		set @mmpcm = isnull(@factorConversion,0) * isnull(@pM3,0)
	end

	begin tran

	

	if(isnull(@pIdProdDiaria,0) = 0)
	begin

		insert into [dbo].[PR_ProdDiaria](
				Bloque,		Fecha,		VolumenBombeado,		VolumenMedido,		VolumenReportado,
				DiferenciaVolumenBM,	DiferenciaVolumenMR,	FechaModificacion,	UsuarioModificacion,
				Estatus,   Algoritmo,	TemperaturaGas,			TemperaturaPetroleo
		)
		select @pidBloque,@pFecha,0,0,0,
		0,							0,					getdate(),			@pCreadoPor,
		1,					0,			case when @pEsPetroleo = 1 then 0 else @pTemperatura end, case when @pEsPetroleo = 1 then @pTemperatura else 0 end


		SELECT @pIdProdDiaria = SCOPE_IDENTITY()

		if @@error <> 0
		begin 
			rollback tran
			goto fin
		end

	end
	Else
	BEGIN
		update [PR_ProdDiaria]
		set TemperaturaGas = case when @pEsPetroleo = 1 then TemperaturaGas else @pTemperatura end,
			TemperaturaPetroleo = case when @pEsPetroleo = 1 then @pTemperatura else TemperaturaPetroleo end,
			FechaModificacion = getdate()
		where Id = @pIdProdDiaria
	END

	if not exists(
		select 1
		from PR_ProdDiariaPozo
		where ProdDiaria = @pIdProdDiaria and
		Pozo = @pIdPozo and
		convert(varchar,Fecha,112) = convert(varchar,@pFecha,112)		
	)
	begin

	
		INSERT INTO PR_ProdDiariaPozo(
							ProdDiaria,		Fecha,					Estacion,				Pozo,
			TiempoOperando,		TiempoParo,		ProduccionControl,		PctAguaControl,			ProduccionTeorica,
			ProduccionDiferida,	ProduccionReal,	ProduccionAlocadaBruta,	ProduccionAlocadaNeta,
			PctAguaAlocada,		TipoSAP,		LDD,					Estado,					Subestado,
			TipoProduccion,		ActrividadIncremental,ControlUtilizado,	ProduccionRealGasM3,	ProduccionRealCondensado,
			MMPCM
		)
		SELECT					@pIdProdDiaria,	@pFecha,				0,						@pIdPozo,
		0,						0,				0,						0,						0,
			0,					@pBLS,			0,						0,		
			0,					0,				0,						null,						null,
			null,				null,			null,					@pM3,					null,
			@mmpcm


		if @@error <> 0
		begin 
			rollback tran
			goto fin
		end

	END
	ELSE
	Begin

		update PR_ProdDiariaPozo
		set ProduccionRealGasM3 =case when @pEsPetroleo =1 then ProduccionRealGasM3 else @pM3 end,
			ProduccionReal = case when  @pEsPetroleo =1 then @pBLS else ProduccionReal end,
			MMPCM = case when  @pEsPetroleo =1 then MMPCM else @mmpcm end
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
