
create proc p_SC_Presupuesto_Ins
(
	@pIdSubContrato	int,
	@pIdPresupuesto	int,
	@pCreadoPor		int
)
as
begin
	begin try

	declare @IdSubContratoPresupuesto int
	select @IdSubContratoPresupuesto = isnull(max(IdSubContratoPresupuesto),0)+1 from SC_Presupuesto

	insert	into	SC_Presupuesto 
			values	(
						@IdSubContratoPresupuesto,
						@pIdSubContrato,
						@pIdPresupuesto,
						@pCreadoPor,
						getdate()
					)

		select Error = cast(1 as bit)

	end try
	begin catch
		select Error = cast(0 as bit)
	end catch

end