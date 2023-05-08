
CREATE PROCEDURE [dbo].[EN_AsignarPozo_Grd]
    @idContrato INT
AS  
BEGIN  
    SET NOCOUNT ON;  
    SET LANGUAGE spanish;  
  
    DECLARE @HoyMasTresAnios DATE;  
    SET @HoyMasTresAnios = DATEADD(YEAR, 2, GETDATE());  

		create table #tmpInstanciasRevisores
		(
			Id							int		identity,
			IdInstanciaEntregable		int,
			IdUsuario					int,
			URNombre					varchar(100),
			UXRNombre					varchar(100)
			constraint					PK_tmpInstanciasRevisores primary key (Id)
		)

		create table #tmpInstanciasRevisoresXML
		(
			Id							int		identity,
			IdInstanciaEntregable		int,
			Nombres						varchar(max)--,
			--Revisores					varchar(max)
			constraint					PK_tmpInstanciasRevisoresXML primary key (Id)
		)

		CREATE TABLE #InstanciasEntregable  
		(  
			ID						INT IDENTITY(1, 1),  
			idInstanciaEntregable	INT,  
			IdContratoEntregable	INT,  
			proceso					VARCHAR(MAX)  
			constraint				PK_InstanciasEntregable_tmp primary key(id)
		)

		CREATE TABLE #ResponsablesInstancias  
		(  
			ID						INT IDENTITY(1, 1),  
			idInstanciaEntregable	INT,  
			IdContratoEntregable	INT,  
			Elaborador				NVARCHAR(250),  
			Revisores				NVARCHAR(250),  
			Aprobadores				NVARCHAR(250),  
			proceso					VARCHAR(MAX)
			constraint				PK_tmpResponsablesInstancias primary key(id)
		);  
		
		INSERT INTO #InstanciasEntregable (idInstanciaEntregable, IdContratoEntregable, proceso)  
		SELECT		I.idInstanciaEntregable,  
					I.IdContratoEntregable,  
					''
		FROM		dbo.EN_MarcoLegal			ml  
		right join	dbo.EN_Entregable			e  
		ON			e.IdMarcoLegal				=		ml.IdMarcoLegal  
		inner join	dbo.EN_ContratoEntregable		CE		
		ON			CE.IdEntregable				=		e.IdEntregable 
		and			IdContrato					=		@idContrato
		and			E.IsActivo					=		1
		and			E.BitJOA					=		0
		inner join	dbo.EN_InstanciasEntregable		I		
		ON			I.IdContratoEntregable		=		CE.IdContratoEntregable  
		and			CE.IdContrato				=		@idContrato  
		and			CE.Activo					=		1   
		where		CE.IdContrato				=		@idContrato 
		and			(  
					  ml.Activo					=		1  
					  OR e.BitInterno			=		1  
					)
		and			ISNULL(CE.BitNA,0)			<>		1
		--group by	ml.IdMarcoLegal		
		ORDER BY	FechasLimiteAprobacion		ASC

		

        
		INSERT INTO #ResponsablesInstancias (idInstanciaEntregable, IdContratoEntregable, Elaborador, Revisores,  
                                         Aprobadores, proceso)  
		SELECT	TI.idInstanciaEntregable,  
				TI.IdContratoEntregable,  
				Elaborador					=	CASE ISNULL(EXAE.idUsuario, '')		WHEN	''	THEN	UE.Nombre  ELSE	UXE.Nombre  END,  
				'',
					aprobadores						=	CASE ISNULL(EXAP.idUsuario, '')		WHEN	''	THEN	UP.Nombre  
																										ELSE	UXP.Nombre  
																							END,  
					TI.proceso  
    FROM			#InstanciasEntregable			TI  
	inner join		dbo.EN_Actividad				AE  
	ON				TI.IdContratoEntregable			=		AE.IdContratoEntregable  
	and				AE.EstadoID						=		10000  
	inner join		dbo.AP_Usuario					UE  
	ON				AE.idUsuario					=		UE.UsuarioID  
	inner join		dbo.EN_Actividad				AR  
	ON				TI.IdContratoEntregable			=		AR.IdContratoEntregable  
	and				AR.EstadoID						=		10001  
	inner join		dbo.AP_Usuario					UR  
	ON				AR.idUsuario					=		UR.UsuarioID  
	inner join		dbo.EN_Actividad				AP  
	ON				TI.IdContratoEntregable			=		AP.IdContratoEntregable  
	and				AP.EstadoID						=		10002  
	inner join		dbo.AP_Usuario					UP  
	ON				AP.idUsuario					=		UP.UsuarioID  
	left join		dbo.EN_ExcepcionesActividad		EXAE  
	ON				AE.ActividadID					=		EXAE.ActividadIDExcepcion  
	and				TI.idInstanciaEntregable		=		EXAE.IdInstanciasEntregables  
	left join		dbo.AP_Usuario					UXE  
	ON				EXAE.idUsuario					=		UXE.UsuarioID  
	left join		dbo.EN_ExcepcionesActividad		EXAR  
	ON				AR.ActividadID					=		EXAR.ActividadIDExcepcion  
	and				TI.idInstanciaEntregable		=		EXAR.IdInstanciasEntregables  
	left join		dbo.AP_Usuario					UXR  
	ON				EXAR.idUsuario					=		UXR.UsuarioID  
	left join		dbo.EN_ExcepcionesActividad		EXAP  
	ON				AP.ActividadID					=		EXAP.ActividadIDExcepcion  
	and				TI.idInstanciaEntregable		=		EXAP.IdInstanciasEntregables  
	left join		dbo.AP_Usuario					UXP  
	ON				EXAP.idUsuario					=		UXP.UsuarioID  
	--inner join		#tmpInstanciasRevisoresXML		t1XML
	--on				t1XML.IdInstanciaEntregable		=		TI.idInstanciaEntregable
    GROUP BY		TI.idInstanciaEntregable,  
					TI.IdContratoEntregable,  
					CASE ISNULL(EXAE.idUsuario, '')		WHEN '' THEN	UE.Nombre  
																ELSE	UXE.Nombre  
														END,  
					CASE ISNULL(EXAP.idUsuario, '')		WHEN '' THEN	UP.Nombre  
																ELSE	UXP.Nombre  
														END,
					TI.proceso--,
					--t1XML.Nombres  
    ORDER BY		TI.idInstanciaEntregable;  

	--select * from #ResponsablesInstancias

	 SELECT DISTINCT 

				idinstanciaEntregable	=	I.idInstanciaEntregable, 
				I.Activo AS ActivoInstancias,
				YEAR(FechaCalculadaEntregaReg) AS anio, 
				REPLICATE('0',2-LEN(MONTH(I.FechaCalculadaEntregaReg))) + LTRIM(MONTH(I.FechaCalculadaEntregaReg)) + '-' +DATENAME(MONTH, I.FechaCalculadaEntregaReg) AS mesEntrega,
				E.DocumentoEntregable  AS DocumentoEntregable,
				ISNULL(P.NombreProceso+' - '+IPF .Descripcion,'')	AS  NombreProgramacionProcesos,
				FechasLimiteAprobacion,
				ISNULL(I.FechaCalculadaEntregaReg, I.FechasLimiteAprobacion) AS FechaCalculadaEntregaReg,
				I.FechaRealEntregaRegulador AS FechaRealEntrega,  
				E.Consecutivo,
				Es.NombreEstado AS Estatus,
				ISNULL(ML.MarcoLegal, '') AS MarcoLegal,
				ActividadPetrolera			=	CASE	WHEN APPozoAlivio						= 1	THEN  'Pozo de alivio'  
														WHEN APCierreDesmantelamientoAbandono	= 1 THEN  'Abandono'  
														WHEN APPerforacion						= 1 THEN  'Perforación'  
														WHEN APTerminacion						= 1 THEN  'Terminación'  
														WHEN APActProduccion					= 1 THEN  'Actividades de Producción'  
														WHEN APEstimulacion						= 1 THEN  'Estimulación'  
														WHEN APPruebaProduccion					= 1 THEN  'Prueba de Producción'  
														WHEN APConstruccionCamino				= 1 THEN  'Construcción de Camino'  
														WHEN APConstruccionLocalizacion			= 1 THEN  'Construcción de Localizacion'  
														WHEN APTomaInformacionSismica			= 1 THEN  'Toma de Información Sísmica'  
														WHEN APCorteNucleos						= 1 THEN  'Corte de Nucleos'  
														WHEN APConstruccionLineaDescarga		= 1 THEN  'Construcción de Lineas de descargas'  
														WHEN APSistemaArtificialProduccion		= 1 THEN  'Sistemas Artificiales de Producción'  
														WHEN APTomaInformacionPozo				= 1 THEN  'Medición de Pozos'  
														WHEN APReparacionMayor					= 1 THEN  'Reparación Mayor'  
														WHEN APReparacionMenor					= 1 THEN  'Reparación Menor'  
														WHEN APTransporteHidrocarburos			= 1 THEN  'Transporte de Hidrocarburos'  
														WHEN APAdministracionContratos			= 1 THEN  'Administración de Contratos'  
														WHEN APQuemaGas							= 1 THEN  'Quema de Gas'  
														WHEN BitInterno							= 1 THEN  'Entregable Interno'  
														ELSE											  'No Especificado'  
														END,
				ISNULL(ET.Etapa, 'No Especificada') AS Etapa,
				ISNULL(E.TituloAnexo, '') AS TituloAnexo,  
				ISNULL(E.Capitulo, '') AS Capitulo,  
				ISNULL(are.NombreArea, '') AS AreaResponsable, 
				ISNULL(EN_FrecuenciaEntregable.FrecuenciaEntregable, '') AS FrecuenciaEntregable, 
				ISNULL(RE.RECEPTORENTREGABLE,'') AS Regulador,
				Elaborador,
				revisores,/******************/
				Aprobadores AS Aprobador,
				REPLICATE('0',2-LEN(MONTH(I.FechaInicioElaboracion))) + LTRIM(MONTH(I.FechaInicioElaboracion)) + '-' + DATENAME(MONTH, I.FechaInicioElaboracion) AS mes,
				ISNULL(I.BitContieneAcuse, 0) AS BitContieneAcuse,
				RG.ResponsableGenerador,
				REE.ReceptorEntregable,
				ISNULL(ECA.Exploracion,0) AS Exploracion,  
				ISNULL(ECA.Evaluacion,0)  AS Evaluacion,  
				ISNULL(ECA.Desarrollo,0)  AS Desarrollo,  
				ISNULL(ECA.Transicion,0)  AS Transicion, 
				E.APPozoAlivio as 'ExploracionEvaluacionAbandono',
				E.APCierreDesmantelamientoAbandono AS 'ExploracionEvaluacionDesarrolloAbandono',
				E.APPerforacion as 'EvaluacionDesarrolloAbandono',
				E.APPruebaProduccion as 'InicioProduccion',
				E.APConstruccionCamino as 'Abandono',
				E.APConstruccionLocalizacion as 'TodaVidaContrato',
				E.APRehabilitacionCamino as 'InicioActividadesExploracion',
				E.APRehabilitacionLocalizacion as 'InicioActividadesDesarrollo',
				E.APTomaInformacionSismica as 'InicioActividadesDesarrolloPerfo',
				E.APCorteNucleos as 'InicioActividadesDesarrolloOperacion',
				ISNULL(ECA.AbandonoArea,0) AS AbandonoArea,  
				ISNULL(ECA.AbandonoPozo,0) AS AbandonoPozo,
				ins.NombreInstalacion


		FROM		#ResponsablesInstancias							TI  
		inner join	dbo.EN_InstanciasEntregable						I	 --EXEC sp_helpindex EN_InstanciasEntregable
		ON			TI.idInstanciaEntregable						=	I.idInstanciaEntregable  
		inner join	dbo.EN_Actividad								A  
		ON			I.ActividadID									=	A.ActividadID  
		inner join	dbo.EN_ContratoEntregable							CE  
		ON			I.IdContratoEntregable							=	CE.IdContratoEntregable  
		and			ce.IdContrato									=	@IdContrato
		inner join	dbo.EN_Entregable									E  
		ON			CE.IdEntregable									=	E.IdEntregable
		AND			E.BitJOA										=	0
		inner join	dbo.EN_Estado									Es  
		ON			A.EstadoID										=	Es.EstadoID  
		left join	dbo.EN_FrecuenciaEntregable  
		ON			E.IdFrecuenciaEntregable						=	EN_FrecuenciaEntregable.IdFrecuenciaEntregable  
		left join	dbo.EN_MarcoLegal									ML  
		ON			E.IdMarcoLegal									=	ML.IdMarcoLegal  
		left join	dbo.EN_ReceptorEntregable							RE
		ON			E.IdReceptorEntregable							=	RE.IdReceptorEntregable
		left join	dbo.EN_Etapa									ET 
		ON			E.IdEtapa										=	ET.IdEtapa  
		left join	dbo.EN_Area										are  
		ON			CE.IdArea										=	are.idArea  
		and			are.IdContrato									=	@IdContrato
		left join	dbo.AP_USUARIO										FP  -- OBTENER NOMBRE DEL FOCAL POINT  
		ON			CE.FocalPoint									=	FP.Usuario  
		left join	dbo.AP_USUARIO										AC  -- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE  
		ON			CE.AccountableCompliance						=	AC.Usuario  
		left join	dbo.AP_USUARIO										ACC  -- OBTENER EL NOMBRE DEL ACCOUNTABLE  
		ON			CE.Accountable									=	ACC.Usuario  
		left join	dbo.EN_ENTREGABLE_CONFIGADICIONAL					ECA  
		ON			CE.IdEntregable									=	ECA.IdEntregable
		left join	dbo.EN_InstanciasEntregables_InstanciaActividad		IEIA
		ON			I.idInstanciaEntregable							=		IEIA.idInstanciaEntregable
		left join	dbo.EN_InstanciasActividades						IA
		ON			IEIA.idInstanciaActividad						=		IA.idInstanciaActividad
		left join	dbo.EN_InstanciasProcesosFecha						IPF
		ON			IA.IdInstanciasProcesos							=		IPF.IdInstanciasProcesos
		and			IPF.IdContrato									=	@IdContrato
		left join	dbo.EN_Procesos										P
		ON			IPF.IdProceso									=		P.IdProceso
		left join	dbo.EN_ResponsableGenerador						RG
		ON			E.IdResponsableGenerador						=		RG.IdResponsableGenerador
		left join	dbo.EN_ReceptorEntregable						REE	
		ON			E.IdReceptorEntregable							=		REE.IdReceptorEntregable
		left join	dbo.CO_Instalacion									ins
		on			ins.IdInstalacion								=		I.IdInstalacion
		WHERE		CE.IdContrato									=		@idContrato 
		AND			E.IsActivo										=		1
		AND			ISNULL(CE.BitNA,0)								<>		1
		and			YEAR(FechaCalculadaEntregaReg)					<=		year(getdate())+3
end