-- p_PR_ProdDiaria_Gen '20190501',1051,10038
CREATE PROC p_PR_ProdDiaria_Gen
@pIdValoresConciliadosProducion INT,
@pUsuarioId INT,
@pError VARCHAR(250) OUT
as
BEGIN

	BEGIN TRY

	DECLARE @pMes DATE,
			@pPuntoEntregaId INT,
			@pContratoId INT,
			-------------------
			@BloqueId INT,
			@PozoId INT,
			@IdValoresConciliadosProducion INT,
			@Id INT

	SELECT @pMes = Mes,
		@pPuntoEntregaId = PuntoEntregaID,
		@pContratoId = IdContrato
	FROM CO_ValoresConciliadosProducion
	WHERE IdValoresConciliadosProducion = @pIdValoresConciliadosProducion

	SELECT @BloqueId = Id
	from PR_Bloque
	WHERE IdContrato = @pContratoId

	SELECT @PozoId = Id 
	FROM PR_Pozo
	WHERE PuntoEntregaID = @pPuntoEntregaId


	SELECT IdValoresConciliadosProducion,
		PuntoEntregaID,
		Mes,
		Aceite,
		Gas,
		Agua,
		IdContrato,		
		Activo
	INTO #tmpValoresConciliadosProducion
	FROM CO_ValoresConciliadosProducion
	WHERE PuntoEntregaID = @pPuntoEntregaId AND
	Mes = @pMes AND
	Activo = 1

	IF not exists( SELECT 1 FROM #tmpValoresConciliadosProducion)
	BEGIN
		SET @pError = 'ALERTA: No hay información de Valores Conciliados de Producción, no es posible continuar '
		RETURN
	END

	select P.*,
		pozo.PuntoEntregaID
	INTO #tmpProdDiariaPozo_Previo
	from PR_ProdDiariaPozo_Previo  p
	INNER JOIN PR_Pozo pozo on pozo.id = p.Pozo
	where pozo.PuntoEntregaID = @pPuntoEntregaId AND
	Year(Fecha) = Year(@pMes) AND
	MONTH(Fecha) = MONTH(@pMes) 
	ORDER BY P.Fecha  DESC


	IF NOT EXISTS( SELECT 1 FROM #tmpProdDiariaPozo_Previo)
	BEGIN
		SET @pError = 'ALERTA: No hay información de producción previa para los pozos relacionados al punto de entrega, no es posible continuar '
		return
	END

	SELECT PuntoEntregaID,
			ProdAceiteNeto = SUM(ProdAceiteNeto),
			GastoGas = SUM(GastoGas),
			Agua = SUM(Agua),
			Fecha = MAX(Fecha)			
	INTO #tmpProdDiariaPozo_Totales
	FROM #tmpProdDiariaPozo_Previo
	GROUP BY PuntoEntregaID,CONVERT(VARCHAR,Fecha,112)

	
	
	select  Agua = CASE WHEN isnull(tot.Agua,0) = 0 THEN 0 ELSE (isnull(pd.Agua,0) / isnull(tot.Agua,0)) * isnull(cp.Agua,0) END,
			GastoGas =  CASE WHEN isnull(tot.GastoGas,0) = 0 THEN 0 ELSE (isnull(pd.GastoGas,0) / isnull(tot.GastoGas,0)) * cp.Gas END,
			ProdAceiteNeto = CASE WHEN isnull(tot.ProdAceiteNeto,0) = 0 THEN 0 ELSE (isnull(pd.ProdAceiteNeto,0) / isnull(tot.ProdAceiteNeto,0)) * isnull(cp.Aceite,0) END,
			pd.Fecha,
			pd.PuntoEntregaID,
			pd.Pozo
	INTO #tmpProdDiariaPozo_Proporcion
	FROM #tmpProdDiariaPozo_Previo pd
	inner join #tmpProdDiariaPozo_Totales tot on tot.PuntoEntregaID = pd.PuntoEntregaID AND
									convert(varchar,tot.Fecha,112) = convert(varchar,pd.Fecha,112) 
									
	inner join #tmpValoresConciliadosProducion cp on cp.PuntoEntregaID = pd.PuntoEntregaID
	


	SELECT 
	ProdDiariaId = e.Id,
	pd.Id,
	AceiteOld = CAST(ISNULL(pd.ProduccionControl,0) AS VARCHAR), 
	GasOld = CAST(ISNULL(pd.ProduccionRealGasM3,0) AS VARCHAR),
	AguaOld = CAST(ISNULL(pd.PctAguaAlocada,0) AS VARCHAR),
	f.* ,
	Bloque = @BloqueId
	INTO #tmpFinal
	FROM #tmpProdDiariaPozo_Proporcion f
	LEFT JOIN PR_ProdDiariaPozo pd on pd.Pozo = f.Pozo AND
									pd.Fecha = f.Fecha
	LEFT JOIN PR_ProdDiaria e on e.Bloque = @BloqueId AND
							e.Fecha = f.Fecha
	SELECT  @IdValoresConciliadosProducion = IdValoresConciliadosProducion
	FROM  #tmpValoresConciliadosProducion

	BEGIN TRY

		BEGIN TRAN

		--Generar Produccion Diaria ENC
		INSERT INTO PR_ProdDiaria(
								Bloque,					Fecha,					VolumenBombeado,			
			VolumenMedido,		VolumenReportado,		DiferenciaVolumenBM,	DiferenciaVolumenMR,	
			FechaModificacion,	UsuarioModificacion,	Estatus,				Algoritmo,
			TemperaturaGas,		TemperaturaPetroleo
		)
		SELECT 					Bloque=Bloque,			Fecha=Fecha,			VolumenBombeado=0,			
			VolumenMedido=0,	VolumenReportado=0,		DiferenciaVolumenBM=0,	DiferenciaVolumenMR=0,	
			FechaModificacion=getdate(),	UsuarioModificacion=@pUsuarioId,	Estatus=1,				
			Algoritmo=0,		TemperaturaGas=0,		TemperaturaPetroleo=0
		FROM #tmpFinal 
		WHERE ISNULL(ProdDiariaId,0) = 0
		GROUP BY Fecha,Bloque


		--Generar información bitácora
		INSERT INTO CO_ValoresConciliadosProducionBitacora(IdValoresConciliadosProducion,Detalle,Tipo,UsuarioID,Fecha)
		SELECT @IdValoresConciliadosProducion,
				'PuntoEntregaID=' + CAST(@pPuntoEntregaId AS VARCHAR) + ','+
				'IdProduccionDiaria='+CAST(ISNULL(Id,0) AS VARCHAR) + ','+
				'IdPozo='+CAST(ISNULL(Pozo,0) AS VARCHAR) + ','+
				'Fecha='+CONVERT(VARCHAR,FECHA,103) + ',' +
				'AceiteOld='+CAST(ISNULL(AceiteOld,0) AS VARCHAR) + ','+
				'GasOld='+CAST(ISNULL(GasOld,0) AS VARCHAR) + ','+
				'AguaOld='+CAST(ISNULL(AguaOld,0) AS VARCHAR) + ','+
				'AceiteNew='+CAST(ISNULL(ProdAceiteNeto,0) AS VARCHAR) + ','+
				'GasNew='+CAST(ISNULL(GastoGas,0) AS VARCHAR) + ','+
				'AguaNew='+CAST(ISNULL(Agua,0) AS VARCHAR) ,
				'Backallocation',
				@pUsuarioId,
				getdate()
		FROM #tmpFinal
	
			
		--INSERTAR NUEVOS REGISTROS
		INSERT INTO PR_ProdDiariaPozo(
							ProdDiaria,			Fecha,				Estacion,
			Pozo,				TiempoOperando,		TiempoParo,			ProduccionControl,	
			PctAguaControl,		ProduccionTeorica,	ProduccionDiferida,	ProduccionReal,
			ProduccionAlocadaBruta,ProduccionAlocadaNeta,				PctAguaAlocada,
			TipoSAP,			LDD,				Estado,				Subestado,
			TipoProduccion,		ActrividadIncremental,ControlUtilizado,	ProduccionRealGasM3,
			ProduccionRealCondensado,GradosAPI,		ContenidoAzufre,	ContenidoSal,
			MMPCM	)
		SELECT	ProdDiaria = pd.Id,		Fecha = F.Fecha,		Estacion=0,
			Pozo = Pozo,		TiempoOperando=0,	TiempoParo=0,		ProduccionControl=0,	
			PctAguaControl=Agua,ProduccionTeorica=0,ProduccionDiferida=0,ProduccionReal=f.ProdAceiteNeto,
			ProduccionAlocadaBruta=0,ProduccionAlocadaNeta=0,				PctAguaAlocada=0,
			TipoSAP=0,			LDD=0,				Estado=0,				Subestado=0,
			TipoProduccion=0,	ActrividadIncremental=0,ControlUtilizado=0,	ProduccionRealGasM3=GastoGas,
			ProduccionRealCondensado=0,GradosAPI=0,		ContenidoAzufre=0,	ContenidoSal=0,
			MMPCM	=0		
		FROM #tmpFinal F
		INNER JOIN PR_ProdDiaria PD ON PD.Bloque = F.Bloque AND
								PD.Fecha = F.Fecha
		where ISNULL(F.Id,0) = 0

		UPDATE PR_ProdDiariaPozo
		SET ProduccionReal = F.ProdAceiteNeto,
			PctAguaControl = F.Agua,
			ProduccionRealGasM3 = F.GastoGas
		FROM PR_ProdDiariaPozo PD
		INNER JOIN #tmpFinal F on F.Id = PD.Id
		WHERE ISNULL(F.Id,0) > 0


		
		COMMIT TRAN

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @pError = 'ERROR:'+ ERROR_MESSAGE() + ' LINEA:'+CAST(ERROR_LINE() AS VARCHAR)
		RETURN
	END CATCH
	

	END TRY
	BEGIN CATCH
		SET @pError = 'ERROR:'+ ERROR_MESSAGE() + ' LINEA:'+CAST(ERROR_LINE() AS VARCHAR)
	END CATCH


END