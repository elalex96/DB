CREATE PROC p_CO_ConstantesRemuneracionCIEP_GRD
@IdContrato int
as

	SELECT	
		IdConstantesRemuneracionCIEP,
		IdContrato,
		Anio,
		ConstanteST240kbls,
		IPPj,
		IPP0,
		Tarifa,
		TasaDescuento,
		ConstanteST,
		CreadoPor,
		CreadoEn,
		ModificadoPor,
		ModificadoEn
	FROM CO_ConstantesRemuneracionCIEP
	WHERE IdContrato = @IdContrato