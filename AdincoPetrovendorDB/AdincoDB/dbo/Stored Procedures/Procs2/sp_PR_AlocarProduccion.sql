/****** Object:  StoredProcedure [dbo].[AlocarProduccion]    Script Date: 26/03/2017 06:42:54 p. m. ******/
CREATE PROCEDURE [dbo].[sp_PR_AlocarProduccion] 
	@Bloque	 INT,
	@Fecha	datetime,
	@Algoritmo int,
	@Usuario nvarchar(255)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @IdProdDiaria INT
	DECLARE @Bombeado decimal(20,4)
	DECLARE @MedidoBruta decimal(20,4)
	DECLARE @MedidoNeta decimal(20,4)
	DECLARE @MedidoAgua decimal(20,4)
	DECLARE @UltimoControlValidoGuardado int 
	DECLARE @Diferida decimal(20,4)
	DECLARE @UltimaNeta decimal(20,4)
	DECLARE @UltimaBruta decimal(20,4)
	DECLARE @UltimaAgua decimal(20,4)
	DECLARE @FechaCorte datetime
	DECLARE @FechaAnterior datetime
	DECLARE @FechaExistenciaAnterior datetime
	DECLARE @HoraCorte int
	DECLARE @IdPDPozo int
	DECLARE @IdPozo int
	DECLARE @IdUltimoControl int
	SET	@IdProdDiaria = 0
	SET @HoraCorte = 5
	SET	@MedidoBruta = 0
	SET	@MedidoNeta = 0
	SET	@MedidoAgua = 0
	-- Determinamos si la produccion diaria ya fue calculada.
	SELECT  @IdProdDiaria = Id 
	FROM	PR_ProdDiaria
	WHERE	Bloque = @Bloque AND Fecha = @Fecha AND Algoritmo =@Algoritmo 
	-- Si ya fue calculada se elimina su historial.
	IF @IdProdDiaria <> 0
	BEGIN
		DELETE PR_ProdDiariaPozo WHERE ProdDiaria = @IdProdDiaria
		DELETE PR_ProdDiariaEstacion WHERE ProdDiaria = @IdProdDiaria
		DELETE PR_ProdDiaria WHERE Id = @IdProdDiaria
		DELETE PR_ParoDetalle  WHERE ProdDiaria  = @IdProdDiaria
	END
	-- Insertar registro de producción diaria para la fecha a realizar el corte.
	INSERT	PR_ProdDiaria(Bloque, Fecha, VolumenBombeado, VolumenMedido, VolumenReportado,
 			DiferenciaVolumenBM, DiferenciaVolumenMR, FechaModificacion,
			UsuarioModificacion, Estatus, Algoritmo)
	SELECT	@Bloque, @Fecha, 0, 0, 0,
			0, 0, GETDATE(), 
			@Usuario, 0, @Algoritmo
	SET	@IdProdDiaria = @@IDENTITY
    -- Obtener variables de corte de producción
	SET	@FechaCorte = DATEADD(HH,@HoraCorte,@Fecha)
	SET	@FechaAnterior = DATEADD(HH,-24,@FechaCorte)
	SET	@FechaExistenciaAnterior = DATEADD(HH,-24,@FechaAnterior)
	-- Obtener bombeos realizados a la estacion "Punto de entrega" en el corte a calcular.
	SELECT	@Bombeado = isnull(SUM(VolumenBombeado),0)
	FROM	PR_Bombeo 
	WHERE	EstacionDestino = 0
	AND		Fecha between @FechaAnterior and @FechaCorte
	-- Obtener medidas del punto de entrega
	SELECT	@MedidoBruta = Bruta, @MedidoNeta = Neta, @MedidoAgua = Agua_Sedimento
	FROM	PR_PuntoEntrega
	WHERE	Fecha = @Fecha
	-- Actualizar la producción diaria con el total de bombeos realizados al punto de entrega.
	UPDATE	PR_ProdDiaria 
	SET		VolumenBombeado = @Bombeado,
			VolumenMedido = @MedidoBruta,
			DiferenciaVolumenBM = @Bombeado - @MedidoBruta
	WHERE Id = @IdProdDiaria
	-- Se inserta registro inicial de produccion de estaciones
	INSERT	PR_ProdDiariaEstacion(ProdDiaria, Estacion, Fecha, BombeoRealizado, BombeoRecibido, AcarreoRecibido, 
							   ExistenciaAnterior, ExistenciaActual, ProduccionTeorica, ProduccionReal, ProduccionAlocada) 	
	SELECT	@IdProdDiaria, E.Id, @Fecha, 0, 0, 0, 
			0, 0, 0, 0, 0
	FROM	PR_Estacion E 
	WHERE	E.Estatus = 1 AND E.Id <> 0
	-- Se crea tabla de bombeos registrados realizados por una estacion
	SELECT	P.Estacion , isnull(SUM(B.VolumenBombeado),0) as VolumenBombeado
	INTO	#BombeosRealizadosEstacion
	FROM	PR_ProdDiariaEstacion P JOIN PR_Bombeo B ON P.Estacion = B.EstacionOrigen
	WHERE	P.ProdDiaria = @IdProdDiaria
	AND		B.Fecha BETWEEN @FechaAnterior and @FechaCorte
	GROUP	BY P.Estacion 
	-- Se actualiza la tabla de estadisticas de la estacion para reflejar bombeos realizados.
	UPDATE	PR_ProdDiariaEstacion
	SET		BombeoRealizado =   VolumenBombeado
	FROM	PR_ProdDiariaEstacion P JOIN #BombeosRealizadosEstacion B ON P.Estacion = B.Estacion
	WHERE	P.ProdDiaria = @IdProdDiaria
	-- Se crea la tabla de bombeos registrados recibidos en una estacion
	SELECT	P.Estacion , isnull(SUM(B.VolumenBombeado),0) as VolumenBombeado
	INTO	#BombeosRecibidosEstacion
	FROM	PR_ProdDiariaEstacion P JOIN PR_Bombeo B ON P.Estacion = B.EstacionDestino
	WHERE	P.ProdDiaria = @IdProdDiaria
	AND		B.Fecha BETWEEN @FechaAnterior and @FechaCorte
	GROUP	BY P.Estacion 
	-- Se actualiza tabla de estadisticas de la estacion para reflejar bombeos recibidos.
	UPDATE	PR_ProdDiariaEstacion
	SET		BombeoRecibido = VolumenBombeado
	FROM	PR_ProdDiariaEstacion P JOIN #BombeosRecibidosEstacion B ON P.Estacion = B.Estacion
	WHERE	P.ProdDiaria = @IdProdDiaria
	-- Se crea la tabla de existencias previas en estaciones.
	SELECT	P.Estacion , isnull(SUM(isnull(E.Existencia,0)),0) as ExistenciaCA
	INTO	#ExistenciaAnteriorEstacion
	FROM	PR_ProdDiariaEstacion P JOIN PR_Existencia E ON P.Estacion = E.Estacion
	WHERE	P.ProdDiaria = @IdProdDiaria
	AND		E.Fecha BETWEEN @FechaExistenciaAnterior and @FechaAnterior
	GROUP	BY P.Estacion 

	UPDATE	PR_ProdDiariaEstacion
	SET		ExistenciaAnterior = E.ExistenciaCA
	FROM	PR_ProdDiariaEstacion P JOIN #ExistenciaAnteriorEstacion E ON P.Estacion = E.Estacion
	WHERE	P.ProdDiaria = @IdProdDiaria

	SELECT	P.Estacion , isnull(SUM(isnull(E.Existencia,0)),0) as ExistenciaCA
	INTO	#ExistenciaActualEstacion
	FROM	PR_ProdDiariaEstacion P JOIN PR_Existencia E ON P.Estacion = E.Estacion
	WHERE	P.ProdDiaria = @IdProdDiaria
	AND		E.Fecha BETWEEN @FechaAnterior and @FechaCorte
	GROUP	BY P.Estacion 

	UPDATE	PR_ProdDiariaEstacion
	SET		ExistenciaActual = E.ExistenciaCA
	FROM	PR_ProdDiariaEstacion P JOIN #ExistenciaActualEstacion E ON P.Estacion = E.Estacion
	WHERE	P.ProdDiaria = @IdProdDiaria

	INSERT PR_ProdDiariaPozo (ProdDiaria, Fecha, Estacion, Pozo, TiempoOperando, TiempoParo,
						   ProduccionControl, PctAguaControl, ProduccionTeorica, ProduccionDiferida,
						   ProduccionReal, ProduccionAlocadaBruta, ProduccionAlocadaNeta, PctAguaAlocada,
						   TipoSAP, LDD, Estado, Subestado, TipoProduccion, ActrividadIncremental)
	SELECT	@IdProdDiaria, @Fecha, Estacion, Id, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0,
			TipoSistema, LDD, Estatus, SubEstado, TipoProduccion, ActividadIncremental
	FROM	PR_Pozo
	WHERE	Alta < @FechaCorte

    CREATE TABLE #Paros (id int, Pozo int, Duracion float)
    
	-- Paros que iniciaron y terminaron en el dia 
	insert  #Paros
	SELECT	Id , Pozo, DATEDIFF(MI, Inicio,Fin) as Duracion
	FROM    PR_Paro
	WHERE	Fin BETWEEN @FechaAnterior AND @FechaCorte
	AND		Inicio >= @FechaAnterior

	insert  into PR_ParoDetalle 
	SELECT	Id ,Inicio ,Fin ,DATEDIFF(MI, Inicio,Fin) ,0,Finalizado , @IdProdDiaria,0
	FROM    PR_Paro
	WHERE	Fin BETWEEN @FechaAnterior AND @FechaCorte
	AND		Inicio >= @FechaAnterior

	-- Paros que iniciaron antes de la fecha y terminaron en el dia
	INSERT	#Paros
	SELECT	Id, Pozo, DATEDIFF(MI, @FechaAnterior,Fin) as Duracion
	FROM    PR_Paro
	WHERE	Fin BETWEEN @FechaAnterior AND @FechaCorte
	AND		Inicio < @FechaAnterior
	
	INSERT	into PR_ParoDetalle 
	SELECT	Id, @FechaAnterior ,fin , DATEDIFF(MI, @FechaAnterior,Fin) ,0,Finalizado ,@IdProdDiaria,0
	FROM    PR_Paro
	WHERE	Fin BETWEEN @FechaAnterior AND @FechaCorte
	AND		Inicio < @FechaAnterior

	-- Paros que iniciaron antes de la fecha y terminaron despues
	INSERT	#Paros
	SELECT	Id, Pozo, 1440 
	FROM    PR_Paro
	WHERE	Fin > @FechaCorte
	AND		Inicio < @FechaAnterior
	
	INSERT	into PR_ParoDetalle 
	SELECT	Id, @FechaAnterior, @FechaCorte ,   1440, 0 , Finalizado  , @IdProdDiaria,0
	FROM    PR_Paro
	WHERE	Fin > @FechaCorte
	AND		Inicio < @FechaAnterior
	
	-- Paros que iniciaron en la fecha y terminaron despues
	INSERT	#Paros
	SELECT	Id, Pozo, DATEDIFF(MI, Inicio, @FechaCorte) as Duracion
	FROM    PR_Paro
	WHERE	Inicio BETWEEN @FechaAnterior AND @FechaCorte
	AND		Fin > @FechaCorte
	
	INSERT	into PR_ParoDetalle 
	SELECT	Id, inicio , @FechaCorte,  DATEDIFF(MI, Inicio, @FechaCorte) , 0  ,Finalizado , @IdProdDiaria, 0
	FROM    PR_Paro
	WHERE	Inicio BETWEEN @FechaAnterior AND @FechaCorte
	AND		Fin > @FechaCorte

	DELETE	#Paros WHERE Duracion = 0	
	DELETE	PR_ParoDetalle WHERE Duracion = 0	
	
	-- Calculo de totales fuera de operacion por pozo
	SELECT	Pozo, SUM(Duracion) as Duracion
	INTO	#TotalesParos
	FROM	#Paros
	GROUP	BY Pozo

	UPDATE	PR_ProdDiariaPozo
	SET		TiempoOperando = 1440
	WHERE	ProdDiaria = @IdProdDiaria
	
	-- Actualizacion de estadisticas de paros
	UPDATE	PR_ProdDiariaPozo
	SET		TiempoOperando = 1440 - T.Duracion,
			TiempoParo = T.Duracion
	FROM PR_ProdDiariaPozo P 
			JOIN #Paros T ON P.Pozo = T.Pozo
	WHERE	P.ProdDiaria = @IdProdDiaria

	---Todo hasta aqui parece estar bien 
	
	DECLARE	Pozos CURSOR FAST_FORWARD FOR
	SELECT	Id, Pozo 
	FROM PR_ProdDiariaPozo
	WHERE	ProdDiaria = @IdProdDiaria

	OPEN	Pozos

	FETCH	NEXT FROM Pozos
	INTO	@IdPDPozo, @IdPozo

	WHILE	@@FETCH_STATUS = 0
	BEGIN
		SELECT @IdUltimoControl = -1
		SELECT @UltimaNeta = 0
		SELECT @UltimaBruta = 0
		SELECT @UltimaAgua = 0
		SELECT @UltimoControlValidoGuardado = -1
		select @Diferida = -1
		
		--5 Noviembre de 2013 Se deshabilita la parte de la condicion de que el control sea valido a solicitud de Juan Carlos Martinez
		--SELECT	TOP 1 @UltimaNeta =  ProduccionNeta  
		--FROM PR_ControlPozo
		--WHERE	Pozo = @IdPozo AND	Valido = 1
		--AND		FechaValidacion < @FechaCorte
		--AND		Fecha < @FechaCorte
		--order	by Fecha DESC
		
		SELECT	TOP 1 @UltimaNeta =  ProduccionNeta  
		FROM PR_ControlPozo
		WHERE	Pozo = @IdPozo 
		AND		Fecha < @FechaCorte
		order	by Fecha DESC

		--5 Noviembre de 2013 Se deshabilita la parte de la condicion de que el control sea valido a solicitud de Juan Carlos Martinez
		--SELECT	TOP 1 @IdUltimoControl = Id
		--FROM PR_ControlPozo
		--WHERE	Pozo = @IdPozo AND	Valido = 1
		--AND		FechaValidacion < @FechaCorte
		--AND		Fecha < @FechaCorte
		--order	by Fecha DESC

		SELECT	TOP 1 @IdUltimoControl = Id
		FROM PR_ControlPozo
		WHERE	Pozo = @IdPozo 
		AND		HoraFin  < @FechaCorte and Valido = 1
		order	by Fecha DESC
		
		--select @UltimaBruta =  ProduccionBruta  from ControlPozo where ControlPozo .Id = @IdUltimoControl
		--select @UltimaAgua  =  pctAgua   from  ControlPozo where ControlPozo .Id = @IdUltimoControl
		--select @UltimaNeta  =  ProduccionNeta  from ControlPozo where ControlPozo .Id = @IdUltimoControl

		--5 Noviembre de 2013 Se deshabilita la parte de la condicion de que el control sea valido a solicitud de Juan Carlos Martinez
		--SELECT	TOP (1) @UltimaBruta =  ProduccionBruta   
		--FROM PR_ControlPozo
		--WHERE	Pozo = @IdPozo AND	Valido = 1
		--AND		FechaValidacion < @FechaCorte
		--AND		Fecha < @FechaCorte
		--order	by Fecha DESC

		SELECT	TOP (1) @UltimaBruta =  ProduccionBruta   
		FROM PR_ControlPozo
		WHERE	Pozo = @IdPozo 
		AND		Fecha < @FechaCorte
		order	by Fecha DESC

		--5 Noviembre de 2013 Se deshabilita la parte de la condicion de que el control sea valido a solicitud de Juan Carlos Martinez
		--SELECT	TOP (1) @UltimaAgua  =  pctAgua     
		--FROM PR_ControlPozo
		--WHERE	Pozo = @IdPozo AND	Valido = 1
		--AND		FechaValidacion < @FechaCorte
		--AND		Fecha < @FechaCorte
		--order	by Fecha DESC
		
		SELECT	TOP (1) @UltimaAgua  =  pctAgua     
		FROM PR_ControlPozo
		WHERE	Pozo = @IdPozo 	
		AND		Fecha < @FechaCorte
		order	by Fecha DESC

		select @UltimoControlValidoGuardado = UltimoControlValido from PR_Pozo where PR_Pozo.Id = @IdPozo

		select top (1) @Diferida = ProduccionDiferidaB   from     PR_ParoDetalle INNER JOIN
                      PR_Paro ON PR_ParoDetalle.IdParo = PR_Paro.Id and  PR_ParoDetalle.ProdDiaria = @IdProdDiaria --and Paro.Pozo =  @IdPozo 

		if(@IdUltimoControl is not null  )
			begin
				UPDATE	PR_ProdDiariaPozo
				SET		ControlUtilizado = @IdUltimoControl, ProduccionControl = @UltimaBruta , 
					   ProduccionDiferida = @UltimaBruta* ( TiempoParo/1440)  , 
					   ProduccionTeorica = @UltimaBruta - ( @UltimaBruta* ( TiempoParo/1440)),  PctAguaControl = @UltimaAgua
				WHERE	Id = @IdPDPozo and PR_ProdDiariaPozo.ProdDiaria = @IdProdDiaria
				
				--select * from PR_ProdDiariaPozo  WHERE	Id = @IdPDPozo and ProdDiaria = @IdProdDiaria and (TiempoOperando = 0) AND (Estado = 9) AND (ProduccionTeorica > 0)

				if( @IdUltimoControl <>  @UltimoControlValidoGuardado)
				begin
						update PR_Pozo 
							set UltimoControlValido = @IdUltimoControl, 
							ProduccionNeta = @UltimaNeta,  ProduccionBruta  = @UltimaBruta  ,  PorcentajeAgua  = @UltimaAgua  
						where PR_Pozo.Id = @IdPozo and UltimoControlValido <> @IdUltimoControl
				end
			end
		else
			begin
				UPDATE	PR_ProdDiariaPozo
				SET		ControlUtilizado = 4
				WHERE	Id = @IdPDPozo and PR_ProdDiariaPozo.ProdDiaria = @IdProdDiaria
			end	
		FETCH	NEXT FROM Pozos
		INTO	@IdPDPozo, @IdPozo
	END
	CLOSE	Pozos
	DEALLOCATE Pozos
END

