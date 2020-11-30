Create Proc p_CO_ActualizarCertificadoLaboratorio
@pID int,
@pFolio nvarchar(510),
@pFechaAnalisis datetime,
@pArchivo nvarchar(510),
@pPozo nvarchar(510),
@pIdContrato float,
@pDocumento image=null
as

	
	update certilabAmatitlan
	set
		
		Folio= @pFolio,
		FechaAnalisis = @pFechaAnalisis,
		Archivo = @pArchivo,
		Pozo = @pPozo,
		--idContrato = @pIdContrato,
		Documento = @pDocumento
	where [Id Folio] = @pID
