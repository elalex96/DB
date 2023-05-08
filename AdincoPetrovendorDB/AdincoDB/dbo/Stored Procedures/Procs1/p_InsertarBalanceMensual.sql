Create Proc p_InsertarBalanceMensual
@pIdContrato	int,
@pPuntoEntregaID	int,
@pFecha	date,
@pTipoHidrocarburo	varchar(50),
@pInventarioInicial	float,
@pDesempaque	float,
@pAlmacenadoTanques	float,
@pAlmacenadoRecipientes	float,
@pVolOtrasEntradas	float,
@pComentariosEntradas	varchar(500),
@pVolGasVenteado	float,
@pVolGasQuemado	float,
@pVolGasTraspasado	float,
@pVolGasBN	float,
@pVolGasCombustible	float,
@pVolGasYacimientos	float,
@pMermasEvaporacion	float,
@pMermasFugas	float,
@pVolEmpaque	float,
@pVolEncogimientoTransporte	float,
@pFactorEncogimientoTransporte	float,
@pVolEncogimientoImpurezas	float,
@pFactorEncogimientoImpurezas	float,
@pVolEncogimientoEficiencia	float,
@pFactorEncogimientoEficiencia	float,
@pVolEncogimientoLiquidos	float,
@pFactorEncogimientoLiquidos	float,
@pVolTraspaso	float,
@pVolAutoconsumo	float,
@pInventarioFinal	float,
@pVolPerdidasNoIdentificadas	float,
@pVolOtrasSalidas	float,
@pComentariosBalance	varchar(500),
@pError varchar(250) out,
@pVolumenExtraidoHidrocarburo float,
@pVolumenExtraidoAgua float,
@pVolumenIncorporado float, 	
@pVolumenExtraidoImpurezas float,
@pVolumenGasResidual float,
@pVolEntregadoPtoMedicion float
as

	IF  EXISTS (
		SELECT 1
		FROM PR_BalanceMensual where IdContrato = @pIdContrato and
		PuntoEntregaID = @pPuntoEntregaID and
		Fecha =@pFecha	and 
		TipoHidrocarburo = @pTipoHidrocarburo
	)
	BEGIN
		SET @pError = 'Ya existe un registro para la misma clave'
		return
	END

	insert into PR_BalanceMensual(
		IdContrato,			PuntoEntregaID,		Fecha,					TipoHidrocarburo,
		InventarioInicial,	Desempaque,			AlmacenadoTanques,		AlmacenadoRecipientes,
		VolOtrasEntradas,	ComentariosEntradas,VolGasVenteado,			VolGasQuemado,
		VolGasTraspasado,	VolGasBN,			VolGasCombustible,		VolGasYacimientos,
		MermasEvaporacion,	MermasFugas,		VolEmpaque,				VolEncogimientoTransporte,
		FactorEncogimientoTransporte,			VolEncogimientoImpurezas,FactorEncogimientoImpurezas,
		VolEncogimientoEficiencia,FactorEncogimientoEficiencia,VolEncogimientoLiquidos,FactorEncogimientoLiquidos,
		VolTraspaso,		VolAutoconsumo,		InventarioFinal,		VolPerdidasNoIdentificadas,
		VolOtrasSalidas,	ComentariosBalance,	VolumenExtraidoHidrocarburo,VolumenExtraidoAgua,
		VolumenIncorporado,	VolumenExtraidoImpurezas,VolumenGasResidual,VolEntregadoPtoMedicion
	)
	VALUES(
		@pIdContrato,			@pPuntoEntregaID,		@pFecha,					@pTipoHidrocarburo,
		@pInventarioInicial,	@pDesempaque,			@pAlmacenadoTanques,		@pAlmacenadoRecipientes,
		@pVolOtrasEntradas,		@pComentariosEntradas,@pVolGasVenteado,			@pVolGasQuemado,
		@pVolGasTraspasado,		@pVolGasBN,			@pVolGasCombustible,		@pVolGasYacimientos,
		@pMermasEvaporacion,	@pMermasFugas,		@pVolEmpaque,				@pVolEncogimientoTransporte,
		@pFactorEncogimientoTransporte,			@pVolEncogimientoImpurezas,		@pFactorEncogimientoImpurezas,
		@pVolEncogimientoEficiencia,@pFactorEncogimientoEficiencia,@pVolEncogimientoLiquidos,@pFactorEncogimientoLiquidos,
		@pVolTraspaso,		@pVolAutoconsumo,		@pInventarioFinal,		@pVolPerdidasNoIdentificadas,
		@pVolOtrasSalidas,	@pComentariosBalance, @pVolumenExtraidoHidrocarburo,@pVolumenExtraidoAgua,
		@pVolumenIncorporado,	@pVolumenExtraidoImpurezas,@pVolumenGasResidual,@pVolEntregadoPtoMedicion
	)
	--END
	--ELSE
	--BEGIN 

	--	update PR_BalanceMensual
	--	set		
	--		InventarioInicial=@pInventarioInicial,	
	--		Desempaque=@pDesempaque,			AlmacenadoTanques=@pAlmacenadoTanques,		AlmacenadoRecipientes=@pAlmacenadoRecipientes,
	--		VolOtrasEntradas=@pVolOtrasEntradas,	ComentariosEntradas=@pComentariosEntradas,VolGasVenteado=@pVolGasVenteado,			VolGasQuemado=@pVolGasQuemado,
	--		VolGasTraspasado=@pVolGasTraspasado,	VolGasBN=@pVolGasBN,			VolGasCombustible=@pVolGasCombustible,		VolGasYacimientos=@pVolGasYacimientos,
	--		MermasEvaporacion=@pMermasEvaporacion,	MermasFugas=@pMermasFugas,		VolEmpaque=@pVolEmpaque,				VolEncogimientoTransporte=@pVolEncogimientoTransporte,
	--		FactorEncogimientoTransporte=@pFactorEncogimientoTransporte,			VolEncogimientoImpurezas=@pVolEncogimientoImpurezas,FactorEncogimientoImpurezas=@pFactorEncogimientoImpurezas,
	--		VolEncogimientoEficiencia=@pVolEncogimientoEficiencia,FactorEncogimientoEficiencia=@pFactorEncogimientoEficiencia,VolEncogimientoLiquidos=@pVolEncogimientoLiquidos,FactorEncogimientoLiquidos=@pFactorEncogimientoLiquidos,
	--		VolTraspaso=@pVolTraspaso,		VolAutoconsumo=@pVolAutoconsumo,		InventarioFinal=@pInventarioFinal,		VolPerdidasNoIdentificadas=@pVolPerdidasNoIdentificadas,
	--		VolOtrasSalidas=@pVolOtrasSalidas,	ComentariosBalance=@pComentariosBalance
	--	where IdContrato = @pIdContrato and
	--	PuntoEntregaID = @pPuntoEntregaID and
	--	Fecha =@pFecha	and 
	--	TipoHidrocarburo = @pTipoHidrocarburo
	--ENd
