
CREATE proc p_SC_Subcontrato_Upd
(
	@pIdSubContrato		int,
	@pIdSubContratista	int,
	@pNumeroSubContrato	varchar(20),
	@pObjeto			varchar(300),
	@pIdCentroCosto		int,
	@pIdContratista		int,
	@pIdMoneda			int,
	@pPrefijoOT			varchar(13),
	@pError				varchar(250)='' out
)
as
begin
	
	if(substring(@pPrefijoOT,1,3)<>'OT-')
	begin
		select @pPrefijoOT = 'OT-'+@pPrefijoOT
	end

	if	(	(
					select	count(*	)
					from	SC_SubContrato 
					where	NumeroSubContrato	=	@pNumeroSubContrato 
					and		IdSubContrato	<>	@pIdSubContrato
					and		IdContratista		=	@pIdContratista
					and		IsActivo			=	1
				)>1)
	begin
		select	@pError = '[ALERTA] Hay mas de un registro con ese Numero de Subcontrato'
		return
	end

	if exists (
				
				select	1
				from	SC_SubContrato 
				where	NumeroSubContrato	=	@pNumeroSubContrato 
				and		IdSubContrato		<>	@pIdSubContrato
				and		IdContratista		=	@pIdContratista
				and		IsActivo				=	1
				
	)
	begin
		set @pError = '[ALERTA] Este número de Sub Contrato esta siendo utilizado en otro contrato activo, es necesario modificar'
		return
	end


	update	SC_SubContrato
	set		IdSubContratista	=	@pIdSubContratista,
			NumeroSubContrato	=	@pNumeroSubContrato,
			Objeto				=	@pObjeto,
			IdCentroCosto		=	@pIdCentroCosto,
			IdMoneda			=	@pIdMoneda,
			PrefijoOT			=	@pPrefijoOT
	where	IdSubContrato		=	@pIdSubContrato
	
	


end




