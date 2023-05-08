Create Proc p_ActualizarBalanceMensual
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
@pVolumenExtraidoHidrocarburo float,
@pVolumenExtraidoAgua float,
@pVolumenIncorporado float, 	
@pVolumenExtraidoImpurezas float,
@pVolumenGasResidual float,
@pVolEntregadoPtoMedicion float
as


	update PR_BalanceMensual
	set		
		InventarioInicial=@pInventarioInicial,	
		Desempaque=@pDesempaque,			AlmacenadoTanques=@pAlmacenadoTanques,		AlmacenadoRecipientes=@pAlmacenadoRecipientes,
		VolOtrasEntradas=@pVolOtrasEntradas,	ComentariosEntradas=@pComentariosEntradas,VolGasVenteado=@pVolGasVenteado,			VolGasQuemado=@pVolGasQuemado,
		VolGasTraspasado=@pVolGasTraspasado,	VolGasBN=@pVolGasBN,			VolGasCombustible=@pVolGasCombustible,		VolGasYacimientos=@pVolGasYacimientos,
		MermasEvaporacion=@pMermasEvaporacion,	MermasFugas=@pMermasFugas,		VolEmpaque=@pVolEmpaque,				VolEncogimientoTransporte=@pVolEncogimientoTransporte,
		FactorEncogimientoTransporte=@pFactorEncogimientoTransporte,			VolEncogimientoImpurezas=@pVolEncogimientoImpurezas,FactorEncogimientoImpurezas=@pFactorEncogimientoImpurezas,
		VolEncogimientoEficiencia=@pVolEncogimientoEficiencia,FactorEncogimientoEficiencia=@pFactorEncogimientoEficiencia,VolEncogimientoLiquidos=@pVolEncogimientoLiquidos,FactorEncogimientoLiquidos=@pFactorEncogimientoLiquidos,
		VolTraspaso=@pVolTraspaso,		VolAutoconsumo=@pVolAutoconsumo,		InventarioFinal=@pInventarioFinal,		VolPerdidasNoIdentificadas=@pVolPerdidasNoIdentificadas,
		VolOtrasSalidas=@pVolOtrasSalidas,	ComentariosBalance=@pComentariosBalance,
		VolumenExtraidoHidrocarburo = @pVolumenExtraidoHidrocarburo,
		VolumenExtraidoAgua = @pVolumenExtraidoAgua,
		VolumenIncorporado = @pVolumenIncorporado,
		VolumenExtraidoImpurezas = @pVolumenExtraidoImpurezas,
		VolumenGasResidual = @pVolumenGasResidual,
		VolEntregadoPtoMedicion = @pVolEntregadoPtoMedicion
	where IdContrato = @pIdContrato and
	PuntoEntregaID = @pPuntoEntregaID and
	Fecha =@pFecha	and 
	TipoHidrocarburo = @pTipoHidrocarburo
