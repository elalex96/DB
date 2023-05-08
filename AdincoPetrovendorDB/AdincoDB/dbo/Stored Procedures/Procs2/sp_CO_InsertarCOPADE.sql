
Create Proc sp_CO_InsertarCOPADE
@pIdCopade	int,
@pIdContrato	int,
@pNumeroCOPADE	int,
@pFechaEmision	date,
@pArchivo	nvarchar(510),
@pAdjunto	image
as

	insert into CO_COPADE(
		/*IdCopade,*/IdContrato,NumeroCOPADE,FechaEmision,Archivo,Adjunto
	)
	values(
	/*@pIdCopade,*/@pIdContrato,@pNumeroCOPADE,@pFechaEmision,@pArchivo,@pAdjunto
	)