
create proc p_SC_Presupuesto_Del
(
	@pIdSubContrato	int
)
as
begin
	begin try
		delete 
		from	SC_Presupuesto 
		where	IdSubContrato	=	 @pIdSubContrato

		select Error = cast(1 as bit)

	end try
	begin catch
		select Error = cast(0 as bit)
	end catch
end