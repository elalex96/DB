
Create Proc p_GuardarEntregableRonda
@pIdEntregable int,
@pIdRonda int,
@pMarcarSiNO bit
as

	if(
		@pMarcarSiNO = 0
	)
	begin
		delete [dbo].[EN_EntregableRonda]
		where idRonda =  @pIdRonda
		and IdEntregable = @pIdEntregable
	end
	else
	begin
		if not exists (
			select 1
			from [EN_EntregableRonda]
			where idRonda =  @pIdRonda
			and IdEntregable = @pIdEntregable
		)
		begin
			insert into [EN_EntregableRonda](	
				idEntregable,idRonda
			)
			values(@pIdEntregable,@pIdRonda)
		end
	end