CREATE PROC p_CO_ConstantesRemuneracionCIEP_UPD
@IdConstantesRemuneracionCIEP	int,
@IdContrato	int,
@Anio	int,
@ConstanteST240kbls	float,
@IPPj	float,
@IPP0	float,
@Tarifa	float,
@TasaDescuento	float,
@ConstanteST	float,
@ModificadoPor	int
AS


	UPDATE CO_ConstantesRemuneracionCIEP
		SET Anio=@Anio,
		ConstanteST240kbls=@ConstanteST240kbls,
		IPPj=@IPPj,
		IPP0=@IPP0,
		Tarifa=@Tarifa,
		TasaDescuento=@TasaDescuento,
		ConstanteST=@ConstanteST,
		ModificadoPor=@ModificadoPor,
		ModificadoEn=GETDATE()
	WHERE IdConstantesRemuneracionCIEP = @IdConstantesRemuneracionCIEP

