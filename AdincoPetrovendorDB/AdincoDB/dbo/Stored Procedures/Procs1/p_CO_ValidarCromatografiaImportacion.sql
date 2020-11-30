Create Proc p_CO_ValidarCromatografiaImportacion
@pIdContratoSession int,
@pContrato varchar(100),
@pPuntoEntrega varchar(100),
@pAnio smallint,
@pMes tinyint,
@pError varchar(500) out
as
	declare @IdContrato int,			
			@IdPuntoEntregaContrato int,
			@IdCromatografia int
			

	select @IdContrato = co.IdContrato
	from CO_Contrato co
	where co.NumeroContrato = LTRIM(rtrim(@pContrato))
	
	select @IdPuntoEntregaContrato = pec.PuntoEntregaContratoID
	from [dbo].[CO_PuntosdeEntregaContrato] pec
	inner join [dbo].[CO_PuntosdeEntrega] pe on pe.PuntoEntregaID = pec.PuntoEntregaID
	where pec.IdContrato = @IdContrato and
	pe.Nombre = ltrim(rtrim(@pPuntoEntrega))

	select @IdCromatografia = cro.IdCromatografia
	from CO_Cromatografia cro
	where cro.IdContrato = @IdContrato
	and Anio =@pAnio and
	Mes = @pMes 

	if(isnull(@IdContrato,0) = 0)
	begin
		select @pError = 'No fue posible encontrar el contrato especificado:'+@pContrato
	end
	if(isnull(@IdPuntoEntregaContrato,0) = 0)
	begin
		select @pError =@pError+ '<br> No fue posible encontrar el punto de entrega especificado:'+@pPuntoEntrega
	end

	if(
		@IdContrato > 0  
		AND
		@pIdContratoSession <> @IdContrato
	)
	begin
		select @pError =@pError+ '<br> El contrato de la sesión de usuario no coincide con el contrato a importar'
	end

	

	select IdCromatografia = isnull(@IdCromatografia,0),
		IdContrato = isnull(@IdContrato,0),		
		IdPuntoEntregaContrato=isnull(@IdPuntoEntregaContrato,0),
		Error = ''