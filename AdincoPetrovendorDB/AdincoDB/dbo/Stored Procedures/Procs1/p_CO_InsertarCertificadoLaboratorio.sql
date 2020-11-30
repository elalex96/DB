Create Proc p_CO_InsertarCertificadoLaboratorio
@pID int,
@pFolio nvarchar(510),
@pFechaAnalisis datetime,
@pArchivo nvarchar(510),
@pPozo nvarchar(510),
@pIdContrato float,
@pDocumento image=null
as

	select @pID = isnull(max([Id Folio]),0) + 1
	from certilabAmatitlan
	
	insert into certilabAmatitlan(
		[Id Folio],
		Folio,
		FechaAnalisis,
		Archivo,
		Pozo,
		idContrato,
		Documento
	)
	values(
		@pID,@pFolio,@pFechaAnalisis,@pArchivo,@pPozo,@pIdContrato,@pDocumento
	)

