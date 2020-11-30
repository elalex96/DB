CREATE PROC p_PR_ImportarPuntoEntregaDiario
@pContrato varchar(250),
@pBloque varchar(250),
@pPuntoMedicion varchar(250),
@pFecha DATETIME,
@pPresion decimal(12,4),
@pTemperatura decimal(12,4),
@pDato varchar(250),
@pNominal varchar(500),
@pInstantaneo varchar(250),
@pCreadoPor int,
@pIdContratoSession int,
@pPuntoEntregaID int out,
@pUnidadMedidaPresion tinyint, --1 psi, 2 kg/cm2
@pError varchar(250) out
as

	declare 
		@IdContrato int

	select @IdContrato = IdContrato
	from CO_Contrato
	where replace(ltrim(RTRIM(numerocontrato)),'Á','A') = replace(ltrim(RTRIM(@pContrato)),'Á','A') 

	select @pPuntoEntregaID  =pe.PuntoEntregaID
	from CO_PuntosdeEntrega pe
	inner join [dbo].[CO_PuntosdeEntregaContrato] pec on pec.PuntoEntregaID = pe.PuntoEntregaID
	where replace(ltrim(RTRIM(nombre)),'','') = ltrim(rtrim(@pPuntoMedicion)) and
	pec.IdContrato = @IdContrato


	--Convertir presión
	if(@pUnidadMedidaPresion = 1)--convertir a kg/cm2
	begin
		set @pPresion = @pPresion * 0.07031
	end


	if(@pIdContratoSession <> @IdContrato)
	begin
		set @pError = 'El contrato de la sesión no coincide con el contrato del archivo a importar'
	end

	if(
	isnull(@pPuntoEntregaID,0) = 0
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
		from PR_PuntoEntregaDiario
		where PuntoEntregaID = @pPuntoEntregaID and
		convert(varchar,Fecha,112) = convert(varchar,@pFecha,112)
	)
	begin
		insert into PR_PuntoEntregaDiario(
			PuntoEntregaID,		Fecha,		Presion,		Temperatura,
			Eventos,			Dato,		Nominal,		Instantaneo,
			CreadoPor,			CreadoEl,	ModificadoPor,	ModificadoEl
		)
		values(
			@pPuntoEntregaID,@pFecha,		@pPresion,		@pTemperatura,
			null,			@pDato,		@pNominal,		@pInstantaneo,
			@pCreadoPor,		getdate(),	null,			null
	)
	end
	Else
	Begin
		update PR_PuntoEntregaDiario
		set Presion = @pPresion,
			Temperatura = @pTemperatura,			
			Dato = @pDato,
			Nominal = @pNominal,
			Instantaneo = @pInstantaneo,
			ModificadoPor = @pCreadoPor,
			ModificadoEl = getdate()
		where PuntoEntregaID = @pPuntoEntregaID and
		convert(varchar,Fecha,112) = convert(varchar,@pFecha,112)
	End
