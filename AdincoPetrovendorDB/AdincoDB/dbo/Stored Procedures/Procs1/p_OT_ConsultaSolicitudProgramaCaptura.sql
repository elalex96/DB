-----------------------------------------------------------------------------------------------------------------------------------
-- Modificado por Pedro Acuna 29-Jun-2022 por el issue 2088 Adinco
-- p_OT_ConsultaSolicitudProgramaCaptura 22,'20200309-20200315',0  
CREATE PROC p_OT_ConsultaSolicitudProgramaCaptura  
 @pIdOTSolicitud INT,  
 @pSemana VARCHAR(21),  
 @pSoloVoBo BIT = 0  
AS  
BEGIN  
  
  DECLARE	@fechaIniFiltro DATETIME=NULL,  
			@fechaFinFiltro DATETIME=NULL,  
			@semanaCerrada	BIT = 0 
   
   CREATE TABLE #tmpResult(IdOTSolicitudMaterial INT,Material NVARCHAR(MAX), IdOTSolicitud INT, Folio VARCHAR(30), 
   LunesCaptura DECIMAL(14, 5),MartesCaptura DECIMAL(14, 5), MiercolesCaptura DECIMAL(14, 5), JuevesCaptura DECIMAL(14, 5), ViernesCaptura DECIMAL(14, 5),SabadoCaptura DECIMAL(14, 5),  DomingoCaptura DECIMAL(14, 5), IdEstatus INT, 
   LunesVoBoC BIT, MartesVoBoC BIT, MiercolesVoBoC BIT, JuevesVoBoC BIT, ViernesVoBoC BIT, SabadoVoBoC BIT, DomingoVoBoC BIT, 
   LunesVoBoSC BIT, MartesVoBoSC BIT, MiercolesVoBoSC BIT, JuevesVoBoSC BIT, ViernesVoBoSC BIT,  SabadoVoBoSC BIT, DomingoVoBoSC BIT,
   LunesCerrado BIT, MartesCerrado BIT, MiercolesCerrado BIT, JuevesCerrado BIT, ViernesCerrado BIT, SabadoCerrado BIT, DomingoCerrado BIT)

   CREATE TABLE #tmpSemana(Fecha VARCHAR(10)) 
   
   CREATE TABLE #tmpArchivos (Id INT, IdOTSolicitudMaterial INT)

   CREATE TABLE #tmpDisponibles(IdOTSolicitudMaterial INT, Cantidad DECIMAL(14, 5), Disponible DECIMAL(14, 5))

  IF(@pSemana <> '')  
	  BEGIN  
		   INSERT INTO #tmpSemana  
		   SELECT splitdata  
		   FROM [dbo].[fnSplitString](@pSemana,'-')  
	  END  
  ELSE  
	  BEGIN  
		   INSERT INTO #tmpSemana  
		   SELECT CONVERT(VARCHAR,OT_SolicitudProgramaCaptura.Fecha,112)  
		   FROM OT_Solicitud (NOLOCK)
		   INNER JOIN [dbo].[OT_SolicitudMaterial] (NOLOCK) 
				ON OT_SolicitudMaterial.IdOTSolicitud = OT_Solicitud.idOTSolicitud  
		   INNER JOIN [dbo].[OT_SolicitudProgramaCaptura] (NOLOCK) 
				ON OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial = OT_SolicitudMaterial.IdOTSolicitudMaterial  
		   WHERE OT_Solicitud.IdOTSolicitud = @pIdOTSolicitud  
		   GROUP BY CONVERT(VARCHAR,OT_SolicitudProgramaCaptura.Fecha,112)  
	  END
  
	  IF EXISTS( SELECT 1 FROM #tmpSemana)  
	  BEGIN   
	   SELECT	@fechaIniFiltro = MIN(Fecha),  
				@fechaFinFiltro = MAX(fecha)  
		FROM #tmpSemana  
	  END  

	  INSERT INTO #tmpDisponibles   
	  SELECT OT_SolicitudPrograma.IdOTSolicitudMaterial,  
	   Cantidad = SUM(OT_SolicitudPrograma.Cantidad),  
	   Disponible = SUM(OT_SolicitudPrograma.Cantidad) - ( SELECT ISNULL(  
																 SUM(  
																  CASE WHEN OT_ProgramaSemanaCerrada.IdOTSolicitud IS NOT NULL AND   
																	 OT_SolicitudProgramaCaptura.VoBoSubcontratista = 1 AND  
																	 OT_SolicitudProgramaCaptura.VoBoContratista = 1  
																	THEN  OT_SolicitudProgramaCaptura.Captura  
																WHEN  OT_ProgramaSemanaCerrada.IdOTSolicitud IS NULL  
																	THEN  OT_SolicitudProgramaCaptura.Captura  
																	ELSE 0  
																  END), 0)  
															FROM dbo.OT_SolicitudProgramaCaptura (NOLOCK) 
															LEFT JOIN [dbo].[OT_ProgramaSemanaCerrada] (NOLOCK) 
																ON OT_ProgramaSemanaCerrada.IdOTSolicitud = @pIdOTSolicitud
																	AND OT_ProgramaSemanaCerrada.IdOTSolicitud = OT_SolicitudMaterial.IdOTSolicitud 
																	AND OT_SolicitudProgramaCaptura.Fecha BETWEEN OT_ProgramaSemanaCerrada.FechaSemanaIni 
																											AND OT_ProgramaSemanaCerrada.FechaSemanaFin 
																	AND OT_ProgramaSemanaCerrada.isActivo = 1  
															WHERE OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial = OT_SolicitudPrograma.IdOTSolicitudMaterial  
														   )  
	  FROM dbo.OT_SolicitudPrograma  (NOLOCK)
	  INNER JOIN dbo.OT_SolicitudMaterial (NOLOCK) 
		ON OT_SolicitudMaterial.IdOTSolicitudMaterial = OT_SolicitudPrograma.IdOTSolicitudMaterial  
	  WHERE OT_SolicitudMaterial.IdOTSolicitud = @pIdOTSolicitud  
	  GROUP BY	OT_SolicitudPrograma.IdOTSolicitudMaterial,
				OT_SolicitudMaterial.IdOTSolicitud  

	  SELECT @semanaCerrada = 1  
	  FROM OT_ProgramaSemanaCerrada (NOLOCK) 
	  WHERE IdOTSolicitud = @pIdOTSolicitud 
		AND SemanaID = @pSemana 
		AND isactivo = 1
  
	  --LUNES  
	  INSERT INTO #tmpResult(IdOTSolicitudMaterial, Material, IdOTSolicitud, Folio, 
	  LunesCaptura, MartesCaptura, MiercolesCaptura, JuevesCaptura, ViernesCaptura, SabadoCaptura, DomingoCaptura, IdEstatus,
	  LunesVoBoC, MartesVoBoC, MiercolesVoBoC, JuevesVoBoC, ViernesVoBoC, SabadoVoBoC, DomingoVoBoC,
	  LunesVoBoSC, MartesVoBoSC, MiercolesVoBoSC, JuevesVoBoSC, ViernesVoBoSC, SabadoVoBoSC, DomingoVoBoSC,
	  LunesCerrado, MartesCerrado, MiercolesCerrado, JuevesCerrado, ViernesCerrado, SabadoCerrado, DomingoCerrado)
	  SELECT				OT_SolicitudMaterial.IdOTSolicitudMaterial,  
	   Material =			'['+SC_Materiales.Concepto + ']' + SC_Materiales.Descripcion ,  
	   OT_Solicitud.IdOTSolicitud,  
	   Folio = OT_Solicitud.Folio,  
	   LunesCaptura =		CASE WHEN DATEPART(WEEKDAY,OT_SolicitudProgramaCaptura.Fecha) = 2 THEN OT_SolicitudProgramaCaptura.Captura ELSE NULL END,  
	   MartesCaptura =		CASE WHEN DATEPART(WEEKDAY,OT_SolicitudProgramaCaptura.Fecha) = 3 THEN OT_SolicitudProgramaCaptura.Captura ELSE NULL END, 
	   MiercolesCaptura =	CASE WHEN DATEPART(WEEKDAY,OT_SolicitudProgramaCaptura.Fecha) = 4 THEN OT_SolicitudProgramaCaptura.Captura ELSE NULL END,  
	   JuevesCaptura =		CASE WHEN DATEPART(WEEKDAY,OT_SolicitudProgramaCaptura.Fecha) = 5 THEN OT_SolicitudProgramaCaptura.Captura ELSE NULL END, 
	   ViernesCaptura=		CASE WHEN DATEPART(WEEKDAY,OT_SolicitudProgramaCaptura.Fecha) = 6 THEN OT_SolicitudProgramaCaptura.Captura ELSE NULL END,  
	   SabadoCaptura =		CASE WHEN DATEPART(WEEKDAY,OT_SolicitudProgramaCaptura.Fecha) = 7 THEN OT_SolicitudProgramaCaptura.Captura ELSE NULL END,  
	   DomingoCaptura =		CASE WHEN DATEPART(WEEKDAY,OT_SolicitudProgramaCaptura.Fecha) = 1 THEN OT_SolicitudProgramaCaptura.Captura ELSE NULL END,  
	   OT_SolicitudPrograma.IdEstatus,  
	   -----------------------------  
	   LunesVoBoC=			CASE WHEN DATEPART(WEEKDAY,OT_SolicitudProgramaCaptura.Fecha) = 2 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoContratista AS INT)) AS BIT) ELSE NULL END,  
	   MartesVoBoC =		CASE WHEN DATEPART(WEEKDAY,OT_SolicitudProgramaCaptura.Fecha) = 3 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoContratista AS INT)) AS BIT) ELSE NULL END,  
	   MiercolesVoBoC =		CASE WHEN DATEPART(WEEKDAY,OT_SolicitudProgramaCaptura.Fecha) = 4 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoContratista AS INT)) AS BIT) ELSE NULL END,  
	   JuevesVoBoC =		CASE WHEN DATEPART(WEEKDAY,OT_SolicitudProgramaCaptura.Fecha) = 5 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoContratista AS INT)) AS BIT) ELSE NULL END,  
	   ViernesVoBoC =		CASE WHEN DATEPART(WEEKDAY,OT_SolicitudProgramaCaptura.Fecha) = 6 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoContratista AS INT)) AS BIT) ELSE NULL END,  
	   SabadoVoBoC =		CASE WHEN DATEPART(WEEKDAY,OT_SolicitudProgramaCaptura.Fecha) = 7 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoContratista AS INT)) AS BIT) ELSE NULL END,  
	   DomingoVoBoC =		CASE WHEN DATEPART(WEEKDAY,OT_SolicitudProgramaCaptura.Fecha) = 1 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoContratista AS INT)) AS BIT) ELSE NULL END,  
	   ---------------------------------  
	   LunesVoBoSC=			CASE WHEN DATEPART(weekday,OT_SolicitudProgramaCaptura.Fecha) = 2 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoSubcontratista AS INT)) AS BIT) ELSE NULL END,  
	   MartesVoBoSC =		CASE WHEN DATEPART(weekday,OT_SolicitudProgramaCaptura.Fecha) = 3 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoSubcontratista AS INT)) AS BIT) ELSE NULL END,   
	   MiercolesVoBoSC =	CASE WHEN DATEPART(weekday,OT_SolicitudProgramaCaptura.Fecha) = 4 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoSubcontratista AS INT)) AS BIT) ELSE NULL END,   
	   JuevesVoBoSC =		CASE WHEN DATEPART(weekday,OT_SolicitudProgramaCaptura.Fecha) = 5 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoSubcontratista AS INT)) AS BIT) ELSE NULL END,   
	   ViernesVoBoSC =		CASE WHEN DATEPART(weekday,OT_SolicitudProgramaCaptura.Fecha) = 6 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoSubcontratista AS INT)) AS BIT) ELSE NULL END,   
	   SabadoVoBoSC =		CASE WHEN DATEPART(weekday,OT_SolicitudProgramaCaptura.Fecha) = 7 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoSubcontratista AS INT)) AS BIT) ELSE NULL END,   
	   DomingoVoBoSC =		CASE WHEN DATEPART(weekday,OT_SolicitudProgramaCaptura.Fecha) = 1 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.VoBoSubcontratista AS INT)) AS BIT) ELSE NULL END,   
	   ----------------------------------  
	   LunesCerrado=		CASE WHEN DATEPART(weekday,OT_SolicitudProgramaCaptura.Fecha) = 2 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.Cerrado AS INT)) AS BIT) ELSE NULL END,  
	   MartesCerrado =		CASE WHEN DATEPART(weekday,OT_SolicitudProgramaCaptura.Fecha) = 3 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.Cerrado AS INT)) AS BIT) ELSE NULL END,    
	   MiercolesCerrado =	CASE WHEN DATEPART(weekday,OT_SolicitudProgramaCaptura.Fecha) = 4 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.Cerrado AS INT)) AS BIT) ELSE NULL END,    
	   JuevesCerrado =		CASE WHEN DATEPART(weekday,OT_SolicitudProgramaCaptura.Fecha) = 5 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.Cerrado AS INT)) AS BIT) ELSE NULL END,    
	   ViernesCerrado =		CASE WHEN DATEPART(weekday,OT_SolicitudProgramaCaptura.Fecha) = 6 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.Cerrado AS INT)) AS BIT) ELSE NULL END,    
	   SabadoCerrado =		CASE WHEN DATEPART(weekday,OT_SolicitudProgramaCaptura.Fecha) = 7 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.Cerrado AS INT)) AS BIT) ELSE NULL END,    
	   DomingoCerrado =		CASE WHEN DATEPART(weekday,OT_SolicitudProgramaCaptura.Fecha) = 1 THEN CAST(MAX(CAST(OT_SolicitudProgramaCaptura.Cerrado AS INT)) AS BIT) ELSE NULL END      
	  FROM dbo.OT_SolicitudMaterial (NOLOCK)
	  INNER JOIN dbo.SC_Materiales (NOLOCK) 
		ON SC_Materiales.IdSCMaterial = OT_SolicitudMaterial.IdSCMaterial  
		AND ISNULL(OT_SolicitudMaterial.Cantidad,0) > 0  
	  INNER JOIN Petrovendor.dbo.MM_Material (NOLOCK) 
		ON MM_Material.IdMaterial = SC_Materiales.IdMaestro  
	  INNER JOIN dbo.OT_Solicitud (NOLOCK) 
		ON OT_Solicitud.IdOTSolicitud = OT_SolicitudMaterial.IdOTSolicitud  
	  LEFT JOIN dbo.OT_SolicitudPrograma (NOLOCK) 
		ON OT_SolicitudPrograma.IdOTSolicitudMaterial = OT_SolicitudMaterial.IdOTSolicitudMaterial  
	  LEFT JOIN dbo.OT_SolicitudProgramaCaptura (NOLOCK) 
		ON OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial = OT_SolicitudMaterial.IdOTSolicitudMaterial 
		AND OT_SolicitudProgramaCaptura.Fecha BETWEEN @fechaIniFiltro 
												AND @fechaFinFiltro 
		AND ((@pSoloVoBo = 1 
				AND VoBoSubcontratista = 1 
				AND VoBoContratista = 1 )
						 OR @pSoloVoBo = 0 )  
	  WHERE OT_Solicitud.IdOTSolicitud = @pIdOTSolicitud   
	  GROUP BY	OT_SolicitudMaterial.IdOTSolicitudMaterial,   
				OT_Solicitud.IdOTSolicitud,  
				OT_Solicitud.Folio,  
				OT_SolicitudProgramaCaptura.Captura,  
				OT_SolicitudPrograma.IdEstatus,  
				SC_Materiales.Concepto ,  
				SC_Materiales.Descripcion,
				OT_SolicitudProgramaCaptura.Fecha
 

		INSERT INTO #tmpArchivos(Id, IdOTSolicitudMaterial)
		  SELECT	OT_ProgramaAdjuntoSemana.ID,  
					OT_ProgramaAdjuntoSemana.IdOTSolicitudMaterial  
		  FROM  OT_ProgramaAdjuntoSemana     
		  INNER JOIN AWS_Documentos        
			ON   OT_ProgramaAdjuntoSemana.AWSDocumentoId      = AWS_Documentos.AWSDocumentoId  
		  WHERE CONVERT(varchar,FechaInicioSemana,112) = CONVERT(VARCHAR,substring(@pSemana,0,9),112)   
		  AND   CONVERT(VARCHAR,FechaFinSemana,112)  = CONVERT(VARCHAR,substring(@pSemana,10,16),112)   


	  SELECT				#tmpResult.IdOTSolicitudMaterial,  
	   Material =			CAST( Material as varchar(200)),  
	   IdOTSolicitud,  
	   Folio,  
	   Disponible =			ISNULL(#tmpDisponibles.Disponible,0),  
	   LunesCaptura =		MAX(LunesCaptura),  
	   MartesCaptura =		MAX(MartesCaptura),  
	   MiercolesCaptura =	MAX(MiercolesCaptura),  
	   JuevesCaptura =		MAX(JuevesCaptura),  
	   ViernesCaptura=		MAX(ViernesCaptura),  
	   SabadoCaptura =		MAX(SabadoCaptura),  
	   DomingoCaptura =		MAX(DomingoCaptura),  
	   TotalSemana =		ISNULL(MAX(LunesCaptura),0) +   
										ISNULL(MAX(MartesCaptura),0) +   
										ISNULL(MAX(MiercolesCaptura),0) +   
										ISNULL(MAX(JuevesCaptura),0) +  
										ISNULL(MAX(ViernesCaptura),0)+  
										ISNULL(MAX(SabadoCaptura),0) +  
										ISNULL(MAX(DomingoCaptura),0),  
	   IdEstatus =		ISNULL(#tmpResult.IdEstatus,0),  
	   LunesVoBoC=		(SELECT CAST(ISNULL(MAX(CAST(LunesVoBoC AS INT)),0) AS BIT) FROM #tmpResult),  
	   MartesVoBoC =	(SELECT CAST(ISNULL(MAX(CAST(MartesVoBoC AS INT)),0) AS BIT) FROM #tmpResult),  
	   MiercolesVoBoC =	(SELECT CAST(ISNULL(MAX(CAST(MiercolesVoBoC AS INT)),0) AS BIT) FROM #tmpResult),  
	   JuevesVoBoC =	(SELECT CAST(ISNULL(MAX(CAST(JuevesVoBoC AS INT)),0) AS BIT) FROM #tmpResult),  
	   ViernesVoBoC =	(SELECT CAST(ISNULL(MAX(CAST(ViernesVoBoC AS INT)),0) AS BIT) FROM #tmpResult),  
	   SabadoVoBoC =	(SELECT CAST(ISNULL(MAX(CAST(SabadoVoBoC AS INT)),0) AS BIT) FROM #tmpResult),  
	   DomingoVoBoC =	(SELECT CAST(ISNULL(MAX(CAST(DomingoVoBoC AS INT)),0) AS BIT) FROM #tmpResult),  
	   ---------------------------------  
	   LunesVoBoSC=			(SELECT CAST(ISNULL(MAX(CAST(LunesVoBoSC AS INT)),0) AS BIT) FROM #tmpResult),  
	   MartesVoBoSC =		(SELECT CAST(ISNULL(MAX(CAST(MartesVoBoSC AS INT)),0) AS BIT) FROM #tmpResult),  
	   MiercolesVoBoSC =	(SELECT CAST(ISNULL(MAX(CAST(MiercolesVoBoSC AS INT)),0) AS BIT) FROM #tmpResult),  
	   JuevesVoBoSC =		(SELECT CAST(ISNULL(MAX(CAST(JuevesVoBoSC AS INT)),0) AS BIT) FROM #tmpResult),  
	   ViernesVoBoSC =		(SELECT CAST(ISNULL(MAX(CAST(ViernesVoBoSC AS INT)),0) AS BIT) FROM #tmpResult),  
	   SabadoVoBoSC =		(SELECT CAST(ISNULL(MAX(CAST(SabadoVoBoSC AS INT)),0) AS BIT) FROM #tmpResult),  
	   DomingoVoBoSC =		(SELECT CAST(ISNULL(MAX(CAST(DomingoVoBoSC AS INT)),0) AS BIT) FROM #tmpResult),  
	   --------------------------------    
	   LunesCerrado=		@semanaCerrada,
	   MartesCerrado =		@semanaCerrada,
	   MiercolesCerrado =	@semanaCerrada,  
	   JuevesCerrado =		@semanaCerrada, 
	   ViernesCerrado =		@semanaCerrada,
	   SabadoCerrado =		@semanaCerrada,
	   DomingoCerrado =		@semanaCerrada, 
	   UploadFile = '',  
	   TieneArchivos      = CASE WHEN #tmpArchivos.IdOTSolicitudMaterial > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END  
	  FROM  #tmpResult  
	  LEFT JOIN #tmpDisponibles      
		ON   #tmpDisponibles.IdOTSolicitudMaterial = #tmpResult.IdOTSolicitudMaterial  
	  LEFT JOIN #tmpArchivos   
		ON   #tmpDisponibles.IdOTSolicitudMaterial = #tmpArchivos.IdOTSolicitudMaterial  
	  GROUP BY	 #tmpResult.IdOTSolicitudMaterial,  
				 Material ,  
				 IdOTSolicitud,  
				 Folio,  
				 #tmpDisponibles.Disponible,  
				 #tmpResult.IdEstatus,  
				 #tmpArchivos.IdOTSolicitudMaterial  
END