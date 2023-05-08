
Create Proc sp_CO_ActualizarCOPADE
@pIdCopade int,
@pIdContrato  int,
@pNumeroCOPADE int,
@pFechaEmision datetime,
@pArchivo  nvarchar(510),
@pAdjunto image
As


	update CO_COPADE
	set NumeroCOPADE = @pNumeroCOPADE,
		FechaEmision = @pFechaEmision,
		Archivo = @pArchivo,
		Adjunto = case  when @pAdjunto is null then Adjunto else @pAdjunto end
	where IdCopade = @pIdCopade