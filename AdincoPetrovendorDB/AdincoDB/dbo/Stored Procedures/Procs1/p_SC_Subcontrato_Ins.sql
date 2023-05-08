
CREATE proc p_SC_Subcontrato_Ins
(
	@pIdSubcontrato int out,
	@pIdSubContratista	int,
	@pIdContratista		int,
	@pNumeroSubContrato	varchar(max),
	@pIdContrato		int,
	@pIdUsuario			int,
	@pIdCentroCostos	int,
	@pIdMoneda			int,
	@pPrefijoOT			varchar(13),
	@pObjeto			varchar(300),
	@pFechaInicio		DateTime=null,
	@pFechaFin			DateTime=null,
	@pError				varchar(250)='' out
)
as
begin
	
	select @pIdSubcontrato = isnull(max(IdSubContrato),0)+1 from SC_Subcontrato

	if not exists (
		select * 
		from SC_SubContrato 
		where NumeroSubContrato = @pNumeroSubContrato 
		and IdContratista = @pIdContratista 
		and IsActivo = 1
	)	
	begin
		insert into SC_SubContrato
								(
									IdSubContrato,
									IdSubContratista,
									IdContratista,
									NumeroSubContrato,
									IdContrato,
									CreadoPor,
									CreadoEl,
									IdCentroCosto,
									IsEliminado,
									IsActivo,
									IdMoneda,
									PrefijoOT,
									Objeto,
									FechaInicio,
									FechaFin
								)
							values
								(
									@pIdSubcontrato,
									@pIdSubContratista,
									@pIdContratista,
									@pNumeroSubContrato,
									@pIdContrato,
									@pIdUsuario,
									GETDATE(),
									@pIdCentroCostos,
									0,
									1,
									@pIdMoneda,
									'OT-'+@pPrefijoOT,
									@pObjeto ,
									@pFechaInicio,
									@pFechaFin
								)
	end
	else
	begin
		set @pIdSubcontrato = 0;
		set @pError = '[ALERTA] El número de contrato ya existe'
	end

	

end



