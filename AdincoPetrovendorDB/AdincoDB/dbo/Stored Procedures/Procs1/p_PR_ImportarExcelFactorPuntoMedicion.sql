CREATE  proc [dbo].[p_PR_ImportarExcelFactorPuntoMedicion]
@pContrato varchar(250),
@pBloque varchar(250),
@pPuntoMedicion varchar(250),
@pFecha DateTime,
@pValor Float,
@pCreadoPor int,
@pIdPuntoMedicion int out,
@pIdContratoSession int,
@pError varchar(250) out
as

	declare @mes int,		
		@IdContrato int
	set @pError = ''


	select @mes = datepart(month,@pFecha)

	select @IdContrato = IdContrato
	from CO_Contrato
	where replace(ltrim(RTRIM(numerocontrato)),'Á','A') = replace(ltrim(RTRIM(@pContrato)),'Á','A') 

	select @pIdPuntoMedicion  =pe.PuntoEntregaID
	from CO_PuntosdeEntrega pe
	inner join [dbo].[CO_PuntosdeEntregaContrato] pec on pec.PuntoEntregaID = pe.PuntoEntregaID
	where RTRIM(nombre) = rtrim(@pPuntoMedicion) and
	pec.IdContrato = @IdContrato

	if(@pIdContratoSession <> @IdContrato)
	begin
		set @pError = 'El contrato de la sesión no coincide con el contrato del archivo a importar'
	end

	if(
	isnull(@pIdPuntoMedicion,0) = 0
	)
	begin
		set @pError = 'No fue posible encontrar el punto de medición: '+@pPuntoMedicion + 'Contrato:'+cast(@IdContrato as varchar)
	end

	if not exists (
		select 1
		from ap_usuario u
		inner join ap_perfilusuario pu on pu.UsuarioID =  u.UsuarioID
		inner join ap_perfil p on p.IdPerfil = pu.PerfilID and
						p.IdContrato = @IdContrato
		where u.UsuarioID = @pCreadoPor
	)
	begin
		set @pError = 'El usuario no está viculado con el contrato que se desea procesar'
		
	end

	if(@pError <> '')
		return

	

	if not exists (
		select 1
		from PR_FactorPuntoEntrega
		where PuntoEntregaID = @pIdPuntoMedicion and
		Mes = @pFecha
	)
	begin

		insert into PR_FactorPuntoEntrega (
			PuntoEntregaID,Mes,FactorConversion,ModificadoPor,ModificadoEn
		)
		select @pIdPuntoMedicion,@pFecha,@pValor,null,null
	end
	Else
	Begin
		update PR_FactorPuntoEntrega
		set FactorConversion = @pValor,
			ModificadoPor = @pCreadoPor,
			ModificadoEn = getdate()
		where PuntoEntregaID = @pIdPuntoMedicion and
		Mes = @pFecha
	End
