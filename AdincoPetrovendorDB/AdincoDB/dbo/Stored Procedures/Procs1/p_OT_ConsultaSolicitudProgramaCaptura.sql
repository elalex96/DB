
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_OT_ConsultaSolicitudProgramaCaptura 22,'20200309-20200315',0
CREATE PROC p_OT_ConsultaSolicitudProgramaCaptura
	@pIdOTSolicitud INT,
	@pSemana VARCHAR(21),
	@pSoloVoBo bit = 0
AS
begin

		--insert into tmp select cast(@pIdOTSolicitud as varchar(max))+','+cast(@pSemana as varchar(max))+','+cast(@pSoloVoBo as varchar(1))

		DECLARE @fechaIniFiltro DATETIME=null,
			@fechaFinFiltro DATETIME=NULL,
			@semanaCerrada BIT = 0
        
		CREATE TABLE #tmpSemana(
			Fecha VARCHAR(10)
		)

		if(@pSemana <> '')
		begin
			INSERT INTO #tmpSemana
			SELECT *
			FROM [dbo].[fnSplitString](@pSemana,'-')
		End
		Else
		begin
			INSERT INTO #tmpSemana
			select convert(varchar,spc.Fecha,112)
			from OT_Solicitud ot
			inner join [dbo].[OT_SolicitudMaterial] otm on otm.IdOTSolicitud = ot.idOTSolicitud
			inner join [dbo].[OT_SolicitudProgramaCaptura] spc on spc.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
			where ot.IdOTSolicitud = @pIdOTSolicitud
			group by convert(varchar,spc.Fecha,112)
		End


		IF exists(
			SELECT 1
			FROM #tmpSemana
		)
		BEGIN 
			SELECT @fechaIniFiltro = MIN(Fecha),
				@fechaFinFiltro = MAX(fecha)
				FROM #tmpSemana
		END

		

		--Obtener 
		SELECT SP.IdOTSolicitudMaterial,
			Cantidad = SUM(SP.Cantidad),
			Disponible = SUM(SP.Cantidad) - (
				SELECT ISNULL(
									SUM(
										case when cerrada.IdOTSolicitud is not null and 
													u.VoBoSubcontratista = 1 and
													u.VoBoContratista = 1
											 then 	Captura
											 when  cerrada.IdOTSolicitud is null
											 then 	Captura
											 else 0
										End

									)
							 ,0)
				FROM dbo.OT_SolicitudProgramaCaptura u
				left join [dbo].[OT_ProgramaSemanaCerrada] cerrada on cerrada.IdOTSolicitud = sm.IdOTSolicitud and
																	 u.Fecha between cerrada.FechaSemanaIni and cerrada.FechaSemanaFin and
																	 cerrada.isActivo = 1

				WHERE u.IdOTSolicitudMaterial = sp.IdOTSolicitudMaterial
			)
		INTO #tmpDisponibles
		FROM dbo.OT_SolicitudPrograma sp
		INNER JOIN dbo.OT_SolicitudMaterial sm ON sm.IdOTSolicitudMaterial = sp.IdOTSolicitudMaterial
		WHERE sm.IdOTSolicitud = @pIdOTSolicitud
		GROUP BY SP.IdOTSolicitudMaterial,sm.IdOTSolicitud


		SELECT @semanaCerrada = 1
		FROM OT_ProgramaSemanaCerrada
		WHERE IdOTSolicitud = @pIdOTSolicitud AND
		SemanaID = @pSemana and
		isactivo = 1

		
	
		--LUNES
		SELECT SM.IdOTSolicitudMaterial,
			Material ='['+scMat.Concepto + ']' + scMat.Descripcion ,
			sol.IdOTSolicitud,
			Folio = sol.Folio,
			LunesCaptura = captura.Captura,
			MartesCaptura = null,
			MiercolesCaptura = null,
			JuevesCaptura = null,
			ViernesCaptura=null,
			SabadoCaptura = null,
			DomingoCaptura = NULL,
			prog.IdEstatus,
			-----------------------------
			LunesVoBoC= CAST(MAX(CAST(captura.VoBoContratista as int)) AS bit),
			MartesVoBoC = NULL,
			MiercolesVoBoC = NULL,
			JuevesVoBoC = NULL,
			ViernesVoBoC = NULL,
			SabadoVoBoC = NULL,
			DomingoVoBoC = NULL,
			---------------------------------
			LunesVoBoSC= CAST(MAX(CAST(captura.VoBoSubcontratista as int)) AS bit),
			MartesVoBoSC = NULL,
			MiercolesVoBoSC = NULL,
			JuevesVoBoSC = NULL,
			ViernesVoBoSC = NULL,
			SabadoVoBoSC = NULL,
			DomingoVoBoSC = NULL,
			----------------------------------
			LunesCerrado= CAST(MAX(CAST(captura.Cerrado as int)) AS bit),
			MartesCerrado = NULL,
			MiercolesCerrado = NULL,
			JuevesCerrado = NULL,
			ViernesCerrado = NULL,
			SabadoCerrado = NULL,
			DomingoCerrado = NULL
		INTO #tmpResult        
		FROM dbo.OT_SolicitudMaterial SM 
		INNER JOIN dbo.SC_Materiales scMat ON scMat.IdSCMaterial = SM.IdSCMaterial  and isnull(sm.Cantidad,0) > 0
		INNER JOIN Petrovendor.dbo.MM_Material mat ON mat.IdMaterial = scMat.IdMaestro
		INNER JOIN dbo.OT_Solicitud sol ON sol.IdOTSolicitud = sm.IdOTSolicitud
		left JOIN dbo.OT_SolicitudPrograma prog ON prog.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial
		LEFT JOIN dbo.OT_SolicitudProgramaCaptura captura ON captura.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial AND
															captura.Fecha BETWEEN @fechaIniFiltro AND @fechaFinFiltro AND
															DATEPART(weekday,captura.Fecha) = 2 --LUNES and
															and
															(
																(
																	@pSoloVoBo = 1 and
																	VoBoSubcontratista = 1 and
																	VoBoContratista = 1
																)OR
																@pSoloVoBo = 0
															)

		WHERE sol.IdOTSolicitud = @pIdOTSolicitud 
		GROUP BY SM.IdOTSolicitudMaterial,
			MAT.DescripcionCorta ,
			sol.IdOTSolicitud,
			Sol.Folio,
			captura.Captura,
			prog.IdEstatus,
			scMat.Concepto ,
			scMat.Descripcion 

		UNION

		--MARTES
		SELECT 
	
			SM.IdOTSolicitudMaterial,
			'['+scMat.Concepto + ']' + scMat.Descripcion ,
			sol.IdOTSolicitud,
			Folio = sol.Folio,
			LunesCaptura = null,
			MartesCaptura = captura.Captura,
			MiercolesCaptura = null,
			JuevesCaptura = null,
			ViernesCaptura=null,
			SabadoCaptura = null,
			DomingoCaptura = null,
			prog.IdEstatus,
			-----------------------------
			LunesVoBoC= null,
			MartesVoBoC = CAST(MAX(CAST(captura.VoBoContratista as int)) AS bit),
			MiercolesVoBoC = NULL,
			JuevesVoBoC = NULL,
			ViernesVoBoC = NULL,
			SabadoVoBoC = NULL,
			DomingoVoBoC = NULL,
			---------------------------------
			LunesVoBoSC= null,
			MartesVoBoSC = CAST(MAX(CAST(captura.VoBoSubcontratista as int)) AS bit),
			MiercolesVoBoSC = NULL,
			JuevesVoBoSC = NULL,
			ViernesVoBoSC = NULL,
			SabadoVoBoSC = NULL,
			DomingoVoBoSC = NULL,
			----------------------------------
			LunesCerrado= NULL,
			MartesCerrado = CAST(MAX(CAST(captura.Cerrado as int)) AS bit),
			MiercolesCerrado= NULL,
			JuevesCerrado = NULL,
			ViernesCerrado = NULL,
			SabadoCerrado = NULL,
			DomingoCerrado = NULL
		FROM dbo.OT_SolicitudMaterial SM 	
		INNER JOIN dbo.SC_Materiales scMat ON scMat.IdSCMaterial = SM.IdSCMaterial and isnull(sm.Cantidad,0) > 0
		INNER JOIN Petrovendor.dbo.MM_Material mat ON mat.IdMaterial = scMat.IdMaestro
		INNER JOIN dbo.OT_Solicitud sol ON sol.IdOTSolicitud = sm.IdOTSolicitud
		left JOIN dbo.OT_SolicitudPrograma prog ON prog.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial
		LEFT JOIN dbo.OT_SolicitudProgramaCaptura captura ON captura.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial AND
															captura.Fecha BETWEEN @fechaIniFiltro AND @fechaFinFiltro AND
															DATEPART(weekday,captura.Fecha) = 3--MARTES
															and
															(
																(
																	@pSoloVoBo = 1 and
																	VoBoSubcontratista = 1 and
																	VoBoContratista = 1
																)OR
																@pSoloVoBo = 0
															)
		WHERE sol.IdOTSolicitud = @pIdOTSolicitud 
		GROUP BY SM.IdOTSolicitudMaterial,
			MAT.DescripcionCorta ,
			sol.IdOTSolicitud,
			Sol.Folio,
			captura.Captura,
			prog.IdEstatus,
			scMat.Concepto ,
			scMat.Descripcion 


		UNION

		--MIERCOLES
		SELECT SM.IdOTSolicitudMaterial,
			'['+scMat.Concepto + ']' + scMat.Descripcion ,
			sol.IdOTSolicitud,
			Folio = sol.Folio,
			LunesCaptura = null,
			MartesCaptura = null,
			MiercolesCaptura = captura.Captura,
			JuevesCaptura = null,
			ViernesCaptura=null,
			SabadoCaptura = null,
			DomingoCaptura = null,
			prog.IdEstatus,
			-----------------------------
			LunesVoBoC= null,
			MartesVoBoC = NULL,
			MiercolesVoBoC = CAST(MAX(CAST(captura.VoBoContratista as int)) AS bit),
			JuevesVoBoC = NULL,
			ViernesVoBoC = NULL,
			SabadoVoBoC = NULL,
			DomingoVoBoC = NULL,
			---------------------------------
			LunesVoBoSC= null,
			MartesVoBoSC = NULL,
			MiercolesVoBoSC = CAST(MAX(CAST(captura.VoBoSubcontratista as int)) AS bit),
			JuevesVoBoSC = NULL,
			ViernesVoBoSC = NULL,
			SabadoVoBoSC = NULL,
			DomingoVoBoSC = NULL,
			----------------------------------
			LunesCerrado= NULL,
			MartesCerrado = NULL,
			MiercolesCerrado = CAST(MAX(CAST(captura.Cerrado as int)) AS bit),
			JuevesCerrado = NULL,
			ViernesCerrado = NULL,
			SabadoCerrado = NULL,
			DomingoCerrado = NULL
		FROM dbo.OT_SolicitudMaterial SM 
		INNER JOIN dbo.SC_Materiales scMat ON scMat.IdSCMaterial = SM.IdSCMaterial and isnull(sm.Cantidad,0) > 0
		INNER JOIN Petrovendor.dbo.MM_Material mat ON mat.IdMaterial = scMat.IdMaestro
		INNER JOIN dbo.OT_Solicitud sol ON sol.IdOTSolicitud = sm.IdOTSolicitud
		left JOIN dbo.OT_SolicitudPrograma prog ON prog.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial
		LEFT JOIN dbo.OT_SolicitudProgramaCaptura captura ON captura.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial AND
															captura.Fecha BETWEEN @fechaIniFiltro AND @fechaFinFiltro AND
															DATEPART(weekday,captura.Fecha) = 4--MIERCOLES
															and
															(
																(
																	@pSoloVoBo = 1 and
																	VoBoSubcontratista = 1 and
																	VoBoContratista = 1
																)OR
																@pSoloVoBo = 0
															)
		WHERE sol.IdOTSolicitud = @pIdOTSolicitud  
		GROUP BY SM.IdOTSolicitudMaterial,
			MAT.DescripcionCorta ,
			sol.IdOTSolicitud,
			Sol.Folio,
			captura.Captura,
			prog.IdEstatus,
			scMat.Concepto ,
			scMat.Descripcion 


		UNION

		--JUEVES
		SELECT SM.IdOTSolicitudMaterial,
			'['+scMat.Concepto + ']' + scMat.Descripcion ,
			sol.IdOTSolicitud,
			Folio = sol.Folio,
			LunesCaptura = null,
			MartesCaptura = null,
			MiercolesCaptura = null,
			JuevesCaptura = captura.Captura,
			ViernesCaptura=null,
			SabadoCaptura = null,
			DomingoCaptura = null,
			prog.IdEstatus,
			-----------------------------
			LunesVoBoC= null,
			MartesVoBoC = NULL,
			MiercolesVoBoC = NULL,
			JuevesVoBoC = CAST(MAX(CAST(captura.VoBoContratista as int)) AS bit),
			ViernesVoBoC = NULL,
			SabadoVoBoC = NULL,
			DomingoVoBoC = NULL,
			---------------------------------
			LunesVoBoSC= null,
			MartesVoBoSC = NULL,
			MiercolesVoBoSC = NULL,
			JuevesVoBoSC = CAST(MAX(CAST(captura.VoBoSubcontratista as int)) AS bit),
			ViernesVoBoSC = NULL,
			SabadoVoBoSC = NULL,
			DomingoVoBoSC = NULL,
			----------------------------------
			LunesCerrado= NULL,
			MartesCerrado = NULL,
			MiercolesCerrado = NULL,
			JuevesCerrado = CAST(MAX(CAST(captura.Cerrado as int)) AS bit),
			ViernesCerrado = NULL,
			SabadoCerrado = NULL,
			DomingoCerrado = NULL
		FROM dbo.OT_SolicitudMaterial SM 
		INNER JOIN dbo.SC_Materiales scMat ON scMat.IdSCMaterial = SM.IdSCMaterial and isnull(sm.Cantidad,0) > 0
		INNER JOIN Petrovendor.dbo.MM_Material mat ON mat.IdMaterial = scMat.IdMaestro
		INNER JOIN dbo.OT_Solicitud sol ON sol.IdOTSolicitud = sm.IdOTSolicitud
		left JOIN dbo.OT_SolicitudPrograma prog ON prog.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial
		LEFT JOIN dbo.OT_SolicitudProgramaCaptura captura ON captura.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial AND
															captura.Fecha BETWEEN @fechaIniFiltro AND @fechaFinFiltro AND
															DATEPART(weekday,captura.Fecha) = 5--JUEVES
															and
															(
																(
																	@pSoloVoBo = 1 and
																	VoBoSubcontratista = 1 and
																	VoBoContratista = 1
																)OR
																@pSoloVoBo = 0
															)
		WHERE sol.IdOTSolicitud = @pIdOTSolicitud  
	GROUP BY SM.IdOTSolicitudMaterial,
			MAT.DescripcionCorta ,
			sol.IdOTSolicitud,
			Sol.Folio,
			captura.Captura,
			prog.IdEstatus,
			scMat.Concepto ,scMat.Descripcion 


		UNION

		--viernes
		SELECT SM.IdOTSolicitudMaterial,
			'['+scMat.Concepto + ']' + scMat.Descripcion ,
			sol.IdOTSolicitud,
			Folio = sol.Folio,
			LunesCaptura = null,
			MartesCaptura = null,
			MiercolesCaptura = null,
			JuevesCaptura = null,
			ViernesCaptura=captura.Captura,
			SabadoCaptura = null,
			DomingoCaptura = null,
			prog.IdEstatus,
			-----------------------------
			LunesVoBoC= null,
			MartesVoBoC = NULL,
			MiercolesVoBoC = NULL,
			JuevesVoBoC = NULL,
			ViernesVoBoC = CAST(MAX(CAST(captura.VoBoContratista as int)) AS bit),
			SabadoVoBoC = NULL,
			DomingoVoBoC = NULL,
			---------------------------------
			LunesVoBoSC= null,
			MartesVoBoSC = NULL,
			MiercolesVoBoSC = NULL,
			JuevesVoBoSC = NULL,
			ViernesVoBoS = CAST(MAX(CAST(captura.VoBoSubcontratista as int)) AS bit),
			SabadoVoBoSC = NULL,
			DomingoVoBoSC = NULL,
			----------------------------------
			LunesCerrado= NULL,
			MartesCerrado = NULL,
			MiercolesCerradoC = NULL,
			JuevesCerrado = NULL,
			ViernesCerrado = CAST(MAX(CAST(captura.Cerrado as int)) AS bit),
			SabadoCerrado = NULL,
			DomingoCerrado = NULL
		FROM dbo.OT_SolicitudMaterial SM 
		INNER JOIN dbo.SC_Materiales scMat ON scMat.IdSCMaterial = SM.IdSCMaterial and isnull(sm.Cantidad,0) > 0
		INNER JOIN Petrovendor.dbo.MM_Material mat ON mat.IdMaterial = scMat.IdMaestro
		INNER JOIN dbo.OT_Solicitud sol ON sol.IdOTSolicitud = sm.IdOTSolicitud
		left JOIN dbo.OT_SolicitudPrograma prog ON prog.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial
		LEFT JOIN dbo.OT_SolicitudProgramaCaptura captura ON captura.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial AND
															captura.Fecha BETWEEN @fechaIniFiltro AND @fechaFinFiltro AND
															DATEPART(weekday,captura.Fecha) = 6--viernes
															and
															(
																(
																	@pSoloVoBo = 1 and
																	VoBoSubcontratista = 1 and
																	VoBoContratista = 1
																)OR
																@pSoloVoBo = 0
															)
		WHERE sol.IdOTSolicitud = @pIdOTSolicitud  
		GROUP BY SM.IdOTSolicitudMaterial,
			MAT.DescripcionCorta ,
			sol.IdOTSolicitud,
			Sol.Folio,
			captura.Captura,
			prog.IdEstatus,
			scMat.Concepto ,scMat.Descripcion 


		UNION

		--SABADO
		SELECT SM.IdOTSolicitudMaterial,
		'['+scMat.Concepto + ']' + scMat.Descripcion ,
			sol.IdOTSolicitud,
			Folio = sol.Folio,
			LunesCaptura = null,
			MartesCaptura = null,
			MiercolesCaptura = null,
			JuevesCaptura = null,
			ViernesCaptura=null,
			SabadoCaptura = captura.Captura,
			DomingoCaptura = null,
			prog.IdEstatus,
			-----------------------------
			LunesVoBoC= NULL,
			MartesVoBoC = NULL,
			MiercolesVoBoC = NULL,
			JuevesVoBoC = NULL,
			ViernesVoBoC = NULL,
			SabadoVoBoC = CAST(MAX(CAST(captura.VoBoContratista as int)) AS bit),
			DomingoVoBoC = NULL,
			---------------------------------
			LunesVoBoSC= NULL,
			MartesVoBoSC = NULL,
			MiercolesVoBoSC = NULL,
			JuevesVoBoSC = NULL,
			ViernesVoBoSC = NULL,
			SabadoVoBoSC = CAST(MAX(CAST(captura.VoBoSubcontratista as int)) AS bit),
			DomingoVoBoSC = null,
			----------------------------------
			LunesCerrado= NULL,
			MartesCerrado = NULL,
			MiercolesCerrado = NULL,
			JuevesCerrado = NULL,
			ViernesCerrado = NULL,
			SabadoCerrado = CAST(MAX(CAST(captura.Cerrado as int)) AS bit),
			DomingoCerrado = NULL
		FROM dbo.OT_SolicitudMaterial SM 
		INNER JOIN dbo.SC_Materiales scMat ON scMat.IdSCMaterial = SM.IdSCMaterial and isnull(sm.Cantidad,0) > 0
		INNER JOIN Petrovendor.dbo.MM_Material mat ON mat.IdMaterial = scMat.IdMaestro
		INNER JOIN dbo.OT_Solicitud sol ON sol.IdOTSolicitud = sm.IdOTSolicitud
		left JOIN dbo.OT_SolicitudPrograma prog ON prog.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial
		LEFT JOIN dbo.OT_SolicitudProgramaCaptura captura ON captura.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial AND
															captura.Fecha BETWEEN @fechaIniFiltro AND @fechaFinFiltro AND
															DATEPART(weekday,captura.Fecha) = 7--SABADO
															and
															(
																(
																	@pSoloVoBo = 1 and
																	VoBoSubcontratista = 1 and
																	VoBoContratista = 1
																)OR
																@pSoloVoBo = 0
															)
		WHERE sol.IdOTSolicitud = @pIdOTSolicitud  
		GROUP BY SM.IdOTSolicitudMaterial,
			MAT.DescripcionCorta ,
			sol.IdOTSolicitud,
			Sol.Folio,
			captura.Captura,
			prog.IdEstatus,
			scMat.Concepto ,
			scMat.Descripcion 


		UNION

		--dimingo
		SELECT SM.IdOTSolicitudMaterial,
			'['+scMat.Concepto + ']' + scMat.Descripcion ,
			sol.IdOTSolicitud,
			Folio = sol.Folio,
			LunesCaptura = null,
			MartesCaptura = null,
			MiercolesCaptura = null,
			JuevesCaptura = null,
			ViernesCaptura=null,
			SabadoCaptura = null,
			DomingoCaptura = captura.Captura,
			prog.IdEstatus,
			-----------------------------
			LunesVoBoC= NULL,
			MartesVoBoC = NULL,
			MiercolesVoBoC = NULL,
			JuevesVoBoC = NULL,
			ViernesVoBoC = NULL,
			SabadoVoBoC = NULL,
			DomingoVoBoC = CAST(MAX(CAST(captura.VoBoContratista as int)) AS bit),
			---------------------------------
			LunesVoBoSC= NULL,
			MartesVoBoSC = NULL,
			MiercolesVoBoSC = NULL,
			JuevesVoBoSC = NULL,
			ViernesVoBoSC = NULL,
			SabadoVoBoSC = NULL,
			DomingoVoBoSC = CAST(MAX(CAST(captura.VoBoSubcontratista as int)) AS bit),
			----------------------------------
			LunesCerrado= NULL,
			MartesCerrado = NULL,
			MiercolesCerrado = NULL,
			JuevesCerrado = NULL,
			ViernesCerrado = NULL,
			SabadoCerrado = NULL,
			DomingoCerrado = CAST(MAX(CAST(captura.Cerrado as int)) AS bit)
		FROM dbo.OT_SolicitudMaterial SM 
		INNER JOIN dbo.SC_Materiales scMat ON scMat.IdSCMaterial = SM.IdSCMaterial and isnull(sm.Cantidad,0) > 0
			INNER JOIN Petrovendor.dbo.MM_Material mat ON mat.IdMaterial = scMat.IdMaestro
		INNER JOIN dbo.OT_Solicitud sol ON sol.IdOTSolicitud = sm.IdOTSolicitud
		left JOIN dbo.OT_SolicitudPrograma prog ON prog.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial
		LEFT JOIN dbo.OT_SolicitudProgramaCaptura captura ON captura.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial AND
															captura.Fecha BETWEEN @fechaIniFiltro AND @fechaFinFiltro AND
															DATEPART(weekday,captura.Fecha) = 1--dimingo
															and
															(
																(
																	@pSoloVoBo = 1 and
																	VoBoSubcontratista = 1 and
																	VoBoContratista = 1
																)OR
																@pSoloVoBo = 0
															)
		WHERE sol.IdOTSolicitud = @pIdOTSolicitud  
		GROUP BY SM.IdOTSolicitudMaterial,
			MAT.DescripcionCorta ,
			sol.IdOTSolicitud,
			Sol.Folio,
			captura.Captura,
			prog.IdEstatus,scMat.Concepto ,
			scMat.Descripcion 


		--select  substring(@pSemana,0,9)
		--select  substring(@pSemana,10,16)

		
		
		select		ps.ID,
					ps.IdOTSolicitudMaterial--,
					--ps.FechaInicioSemana,
					--ps.FechaFinSemana,
					----ps.Adjunto,
					--NombreArchivo							=	docs.NombreArchivo,
					--ps.CreadoPor,
					--ps.CreadoEl,
					--ps.IdOTSolicitudMaterial,
					--FechaInicioSemana						=	convert(varchar,FechaInicioSemana,112),
					--FechaFinSemana							=	convert(VARCHAR,FechaFinSemana,112)
		into		#tmpArchivos
		from		[OT_ProgramaAdjuntoSemana]				ps 	
		inner join	AWS_Documentos							docs
		on			ps.AWSDocumentoId						=	docs.AWSDocumentoId
		where		--(ps.IdOTSolicitudMaterial				=	@pIdOTSolicitudMaterial 
				convert(varchar,FechaInicioSemana,112)	=	convert(VARCHAR,substring(@pSemana,0,9),112) 
		and			convert(VARCHAR,FechaFinSemana,112)		=	convert(VARCHAR,substring(@pSemana,10,16),112) 
		
		--select * from #tmpArchivos

		SELECT tmp.IdOTSolicitudMaterial,
			Material = cast( Material as varchar(200)),
			IdOTSolicitud,
			Folio,
			Disponible = ISNULL(dis.Disponible,0),
			LunesCaptura = MAX(LunesCaptura),
			MartesCaptura = MAX(MartesCaptura),
			MiercolesCaptura = MAX(MiercolesCaptura),
			JuevesCaptura = MAX(JuevesCaptura),
			ViernesCaptura=MAX(ViernesCaptura),
			SabadoCaptura = MAX(SabadoCaptura),
			DomingoCaptura = MAX(DomingoCaptura),
			TotalSemana = isnull(MAX(LunesCaptura),0) + 
							ISNULL(MAX(MartesCaptura),0) + 
							ISNULL(MAX(MiercolesCaptura),0) + 
							ISNULL(MAX(JuevesCaptura),0) +
							ISNULL(MAX(ViernesCaptura),0)+
							ISNULL(MAX(SabadoCaptura),0) +
							ISNULL(MAX(DomingoCaptura),0),
			IdEstatus = ISNULL(tmp.IdEstatus,0),
			LunesVoBoC= (SELECT CAST(ISNULL(MAX(CAST(LunesVoBoC as int)),0) AS bit) FROM #tmpResult),
			MartesVoBoC = (SELECT CAST(ISNULL(MAX(CAST(MartesVoBoC as int)),0) AS bit) FROM #tmpResult),
			MiercolesVoBoC =  (SELECT CAST(ISNULL(MAX(CAST(MiercolesVoBoC as int)),0) AS bit) FROM #tmpResult),
			JuevesVoBoC = (SELECT CAST(ISNULL(MAX(CAST(JuevesVoBoC as int)),0) AS bit) FROM #tmpResult),
			ViernesVoBoC = (SELECT CAST(ISNULL(MAX(CAST(ViernesVoBoC as int)),0) AS bit) FROM #tmpResult),
			SabadoVoBoC =  (SELECT CAST(ISNULL(MAX(CAST(SabadoVoBoC as int)),0) AS bit) FROM #tmpResult),
			DomingoVoBoC = (SELECT CAST(ISNULL(MAX(CAST(DomingoVoBoC as int)),0) AS bit) FROM #tmpResult),
			---------------------------------
			LunesVoBoSC= (SELECT CAST(ISNULL(MAX(CAST(LunesVoBoSC as int)),0) AS bit) FROM #tmpResult),
			MartesVoBoSC = (SELECT CAST(ISNULL(MAX(CAST(MartesVoBoSC as int)),0) AS bit) FROM #tmpResult),
			MiercolesVoBoSC = (SELECT CAST(ISNULL(MAX(CAST(MiercolesVoBoSC as int)),0) AS bit) FROM #tmpResult),
			JuevesVoBoSC =  (SELECT CAST(ISNULL(MAX(CAST(JuevesVoBoSC as int)),0) AS bit) FROM #tmpResult),
			ViernesVoBoSC = (SELECT CAST(ISNULL(MAX(CAST(ViernesVoBoSC as int)),0) AS bit) FROM #tmpResult),
			SabadoVoBoSC = (SELECT CAST(ISNULL(MAX(CAST(SabadoVoBoSC as int)),0) AS bit) FROM #tmpResult),
			DomingoVoBoSC = (SELECT CAST(ISNULL(MAX(CAST(DomingoVoBoSC as int)),0) AS bit) FROM #tmpResult),
			--------------------------------		
			LunesCerrado=@semanaCerrada,-- (SELECT CAST(ISNULL(MAX(CAST(LunesCerrado as int)),0) AS bit) FROM #tmpResult),
			MartesCerrado =@semanaCerrada,-- (SELECT CAST(ISNULL(MAX(CAST(MartesCerrado as int)),0) AS bit) FROM #tmpResult),
			MiercolesCerrado =@semanaCerrada,-- (SELECT CAST(ISNULL(MAX(CAST(MiercolesCerrado as int)),0) AS bit) FROM #tmpResult),
			JuevesCerrado = @semanaCerrada,-- (SELECT CAST(ISNULL(MAX(CAST(JuevesCerrado as int)),0) AS bit) FROM #tmpResult),
			ViernesCerrado = @semanaCerrada,--(SELECT CAST(ISNULL(MAX(CAST(ViernesCerrado as int)),0) AS bit) FROM #tmpResult),
			SabadoCerrado =@semanaCerrada,-- (SELECT CAST(ISNULL(MAX(CAST(SabadoCerrado as int)),0) AS bit) FROM #tmpResult),
			DomingoCerrado =@semanaCerrada,-- (SELECT CAST(ISNULL(MAX(CAST(DomingoCerrado as int)),0) AS bit) FROM #tmpResult)}
			UploadFile = '',
			TieneArchivos						=	case when ta.IdOTSolicitudMaterial > 0 then cast(1 as bit) else cast(0 as bit) end
		FROM		#tmpResult tmp
		LEFT JOIN	#tmpDisponibles				dis 
		ON			dis.IdOTSolicitudMaterial	=	tmp.IdOTSolicitudMaterial
		left join	#tmpArchivos				ta
		on			dis.IdOTSolicitudMaterial	=	ta.IdOTSolicitudMaterial
		GROUP BY	tmp.IdOTSolicitudMaterial,
					Material ,
					IdOTSolicitud,
					Folio,
					dis.Disponible,
					tmp.IdEstatus,
					ta.IdOTSolicitudMaterial
	
	
		
end



