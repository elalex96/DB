CREATE PROC p_CO_ConstantesRemuneracionCIEP_INS
@IdConstantesRemuneracionCIEP	int,
@IdContrato	int,
@Anio	int,
@ConstanteST240kbls	float,
@IPPj	float,
@IPP0	float,
@Tarifa	float,
@TasaDescuento	float,
@ConstanteST	float,
@CreadoPor	int
AS

	INSERT INTO CO_ConstantesRemuneracionCIEP(
		
		IdContrato,
		Anio,
		ConstanteST240kbls,
		IPPj,
		IPP0,
		Tarifa,
		TasaDescuento,
		ConstanteST,
		CreadoPor,
		CreadoEn
	)
	VALUES(
		
		@IdContrato,
		@Anio,
		@ConstanteST240kbls,
		@IPPj,
		@IPP0,
		@Tarifa,
		@TasaDescuento,
		@ConstanteST,
		@CreadoPor,
		GETDATE()
	)