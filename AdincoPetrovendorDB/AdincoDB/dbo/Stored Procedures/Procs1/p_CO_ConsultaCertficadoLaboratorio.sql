Create Proc p_CO_ConsultaCertficadoLaboratorio
@pIdContrato int,
@pIdFolio int
as


	select 
		ID=[Id Folio],
		Folio,
		FechaAnalisis,
		Archivo,
		Pozo,
		idContrato,
		Documento 
	from certilabAmatitlan
	WHERE @pIdFolio in(0, [Id Folio]) 
	AND	idContrato = @pIdContrato
