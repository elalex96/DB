
create proc p_SC_Subcontrato_Ins
(
	@pIdSubContratista	int,
	@pIdContratista		int,
	@pNumeroSubContrato	varchar(max),
	@pIdContrato		int,
	@pIdUsuario			int,
	@pIdCentroCostos	int,
	@pIdMoneda			int,
	@pPrefijoOT			varchar(13),
	@pObjeto			varchar(300)
)
as
begin
	declare @IdSubContrato int
	select @IdSubContrato = isnull(max(IdSubContrato),0)+1 from SC_Subcontrato

	if not exists (select * from SC_SubContrato where NumeroSubContrato = @pNumeroSubContrato and IdContratista = @pIdContratista)
	--select @IdSubContrato 
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
									Objeto
								)
							values
								(
									@IdSubContrato,
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
									@pObjeto 
								)
	end
	else
	begin
		select @IdSubContrato = 1
	end

	select IdSubContrato = @IdSubContrato

end