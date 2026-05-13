------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE Function dbo.fn_OT_CalcularEstatusSig(
@pIdOTSolicitud int
)
returns tinyint
as

begin
	declare @IdOTEstatusAct int,
		@IdOTEstatusAnt int,
		@result tinyint

	select @IdOTEstatusAct =IdOTEstatus,
		@IdOTEstatusAnt = IdOTEstatusAnt
	from OT_Solicitud
	where IdOTSolicitud =@pIdOTSolicitud

	if(
		@IdOTEstatusAct = 9 	
	)
	begin
		set @result =11
	end
	else
	begin
		set @result = @IdOTEstatusAnt
	end


	return isnull(@result,@IdOTEstatusAct)

end


