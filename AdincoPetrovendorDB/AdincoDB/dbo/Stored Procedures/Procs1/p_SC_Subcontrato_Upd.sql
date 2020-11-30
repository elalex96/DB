-- p_SC_Subcontrato_Upd 78,10813,'FS10012019','100000133',338,10013,2,'OT-00001'
create proc p_SC_Subcontrato_Upd
(
	@pIdSubContrato		int,
	@pIdSubContratista	int,
	@pNumeroSubContrato	varchar(20),
	@pObjeto			varchar(300),
	@pIdCentroCosto		int,
	@pIdContratista		int,
	@pIdMoneda			int,
	@pPrefijoOT			varchar(13)
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
		select	Error = 'Hay mas de un registro con ese Numero de Subcontrato'
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
		select Error = 'Este número de Sub Contrato esta siendo utilizado en otro contrato activo, es necesario modificar'
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
	select Error = ''
	select * from SC_SubContrato where IdSubContrato		=	@pIdSubContrato


end

