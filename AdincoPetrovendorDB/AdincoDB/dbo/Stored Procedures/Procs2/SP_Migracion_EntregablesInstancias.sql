
CREATE PROCEDURE [dbo].[SP_Migracion_EntregablesInstancias]-- 3,'ADINCO-1086'
@ContratoId DATETIME,
@EntregableIdentificador VARCHAR(MAX)
AS
BEGIN
	  --> REFERENCIA EN_EntregablesHistorial

	 DECLARE @EntregableId INT
	 CREATE TABLE #EntregablesPendientes(ProgramacionId INT,EntregableId INT, Consecutivo NVARCHAR(100),EstadoId INT)	
	 CREATE TABLE #Entregables(EntregableId INT, Consecutivo NVARCHAR(100),TotalEntregables INT, TotalElaboracion INT, TotalAprobacion INT, TotalRevision INT, InstanciasElaboracion NVARCHAR(MAX), InstanciasAprobacion NVARCHAR(MAX), InstanciasRevision NVARCHAR(MAX), Recurrencia NVARCHAR(100), NombreEntregable NVARCHAR(MAX))
	 CREATE TABLE #EntregablesEstatus(EntregableId INT,Total INT, InstanciasConcatenadas NVARCHAR(MAX))	

	 DECLARE @Cantidad INT
	 DECLARE @EntregablesConcatenados NVARCHAR(MAX)

	 IF @EntregableIdentificador = 'OBTENER-INSTANCIAS-POR-CONTRATO'
	 BEGIN 
	    -- OBTENER TODAS LAS INSTANCIAS DEL CONTRATO APROBADAS INTERNAMENTE
		SELECT I.idInstanciaEntregable AS ProgramacionId,  			 
			   E.IdEntregable,
			   E.Consecutivo			  
        FROM 
		EN_InstanciasEntregable	I  
        JOIN 
			EN_ContratoEntregable	CE  
			ON	I.IdContratoEntregable	=	CE.IdContratoEntregable  
			AND	CE.IdContrato	=	@ContratoId
			AND	CE.Activo	=	1
			AND	I.Activo	=	1  
		JOIN
			EN_Actividad	A
			ON	I.ActividadID	=	A.ActividadID
			AND	A.EstadoID	=	10003	-->CTE Aprobado Internamente    
		JOIN 
			EN_Estado Es  
			ON A.EstadoID = Es.EstadoID  
		JOIN 
			dbo.EN_Entregable	e  
			ON	CE.IdEntregable	=	e.IdEntregable  			
			AND	E.IsActivo	=	1
			AND E.BitJOA	=	0
        LEFT JOIN 
			dbo.EN_MarcoLegal ml  
			ON	E.IdMarcoLegal	=	ml.IdMarcoLegal
        WHERE	CE.IdContrato	=	@ContratoId
              AND  
              (  
                  ml.Activo = 1  
                  OR e.BitInterno = 1  
              )  
			  AND  I.FechaCalculadaEntregaReg IS NOT NULL  
	
			
	 END 
	 ELSE IF @EntregableIdentificador = 'OBTENER-INSTANCIAS-PENDIENTES-FINALIZAR-POR-CONTRATO'	  
	 BEGIN
		 -- OBTENER TODAS LAS INSTANCIAS DEL CONTRATO PENDIETES DE FINALIZAR POR CONTRATO 
		INSERT INTO #EntregablesPendientes(ProgramacionId,EntregableId,Consecutivo,EstadoId)
		SELECT I.idInstanciaEntregable AS ProgramacionId,  			 
			   E.IdEntregable,
			   E.Consecutivo,
			   A.EstadoID			  
        FROM 
		EN_InstanciasEntregable	I  
        JOIN 
			EN_ContratoEntregable	CE  
			ON	I.IdContratoEntregable	=	CE.IdContratoEntregable  
			AND	CE.IdContrato	=	@ContratoId
			AND	CE.Activo	=	1
			AND	I.Activo	=	1  
		JOIN
			EN_Actividad	A
			ON	I.ActividadID	=	A.ActividadID
			AND	A.EstadoID	IN	(10000,10001,10002)	-->CTE EN ELABORACIÓN, REVISION, APROBACIÓN    
		JOIN 
			EN_Estado Es  
			ON A.EstadoID = Es.EstadoID  
		JOIN 
			dbo.EN_Entregable	e  
			ON	CE.IdEntregable	=	e.IdEntregable  			
			AND	E.IsActivo	=	1
			AND E.BitJOA	=	0
        LEFT JOIN 
			dbo.EN_MarcoLegal ml  
			ON	e.IdMarcoLegal	=	ml.IdMarcoLegal  
        WHERE	CE.IdContrato	=	@ContratoId
              AND  
              (  
                  ml.Activo = 1  
                  OR e.BitInterno = 1  
              )  
			  AND  I.FechaCalculadaEntregaReg IS NOT NULL  
			
		 INSERT INTO #Entregables(EntregableId,Consecutivo,TotalEntregables, TotalElaboracion, TotalRevision, TotalAprobacion,InstanciasElaboracion, InstanciasAprobacion, InstanciasRevision, Recurrencia, NombreEntregable)
	     SELECT EntregableId,Consecutivo ,COUNT(EntregableId) AS TotalEntregables ,0 AS TotalElaboracion,0 AS TotalRevision,0 AS TotalAprobacion,'' AS InstanciasElaboracion,'' AS InstanciasTotalAprobacion,'' AS InstanciasTotalRevision,'' AS Recurrencia, '' AS NombreEntregable
		 FROM #EntregablesPendientes
		 GROUP BY EntregableId,Consecutivo

		 --> AGRUPACION EN ELABORACIÓN
		 TRUNCATE TABLE #EntregablesEstatus
		 INSERT INTO #EntregablesEstatus(EntregableId,Total,InstanciasConcatenadas)
		  SELECT EntregableId ,COUNT(EntregableId) AS Total, 
		  (SELECT STUFF(
				(SELECT ', ' + CAST(ProgramacionId AS nvarchar(MAX))
				FROM #EntregablesPendientes	EP			
				WHERE EP.EstadoId= E.EstadoId
				AND EP.EntregableId=E.EntregableId
				FOR XML PATH ('')),
			1,2, ''))
		  FROM #EntregablesPendientes E
		  WHERE E.EstadoId=10000  --> CTE ELABORACIÓN
		  GROUP BY E.EntregableId,E.EstadoId

		  UPDATE  E
		  SET E.TotalElaboracion= EE.Total,
		  E.InstanciasElaboracion= EE.InstanciasConcatenadas
		  FROM #Entregables E 
		  JOIN #EntregablesEstatus EE
		  ON E.EntregableId= EE.EntregableId

		  TRUNCATE TABLE #EntregablesEstatus
		   --> AGRUPACION EN REVISIÓN
		 INSERT INTO #EntregablesEstatus(EntregableId,Total,InstanciasConcatenadas)
		  SELECT EntregableId ,COUNT(EntregableId) AS Total, 
		  (SELECT STUFF(
				(SELECT ', ' + CAST(ProgramacionId AS nvarchar(MAX))
				FROM #EntregablesPendientes	EP			
				WHERE EP.EstadoId= E.EstadoId
				AND EP.EntregableId=E.EntregableId
				FOR XML PATH ('')),
			1,2, ''))
		  FROM #EntregablesPendientes E
		  WHERE E.EstadoId=10001  --> CTE REVISION
		  GROUP BY E.EntregableId,E.EstadoId

		  UPDATE  E
		  SET E.TotalRevision= EE.Total,
		  E.InstanciasRevision= EE.InstanciasConcatenadas
		  FROM #Entregables E 
		  JOIN #EntregablesEstatus EE
		  ON E.EntregableId= EE.EntregableId

		TRUNCATE TABLE #EntregablesEstatus
		   --> AGRUPACION EN APROBACIÓN
		 INSERT INTO #EntregablesEstatus(EntregableId,Total,InstanciasConcatenadas)
		  SELECT EntregableId ,COUNT(EntregableId) AS Total, 
		  (SELECT STUFF(
				(SELECT ', ' + CAST(ProgramacionId AS nvarchar(MAX))
				FROM #EntregablesPendientes	EP			
				WHERE EP.EstadoId= E.EstadoId
				AND EP.EntregableId=E.EntregableId
				FOR XML PATH ('')),
			1,2, ''))
		  FROM #EntregablesPendientes E
		  WHERE E.EstadoId=10002 --> CTE APROBACIÓN
		  GROUP BY E.EntregableId,E.EstadoId

		  UPDATE  E
		  SET E.TotalAprobacion= EE.Total,
		  E.InstanciasAprobacion= EE.InstanciasConcatenadas
		  FROM #Entregables E 
		  JOIN #EntregablesEstatus EE
		  ON E.EntregableId= EE.EntregableId

		  UPDATE  E
		  SET E.Recurrencia= RR.FrecuenciaEntregable,
		  E.NombreEntregable = ISNULL(ET.DocumentoEntregable,'')
		  FROM #Entregables E 
		  JOIN EN_Entregable ET
			ON E.EntregableId= ET.IdEntregable
		  LEFT JOIN EN_FrecuenciaEntregable RR
			ON ET.IdFrecuenciaEntregable = RR.IdFrecuenciaEntregable

		  SELECT EntregableId, 
		  Consecutivo,
		  TotalEntregables, 
		  TotalElaboracion, 
		  TotalAprobacion, 
		  TotalRevision, 
		  InstanciasElaboracion, 
		  InstanciasAprobacion, 
		  InstanciasRevision, 
		  Recurrencia, 
		  NombreEntregable
		  FROM #Entregables
	 END
	 ELSE IF @EntregableIdentificador = 'OBTENER-DETALLE-ENTREGABLES-POR-CONTRATO'
	 BEGIN 
	    -- OBTENER TODAS LAS INSTANCIAS DEL CONTRATO APROBADAS INTERNAMENTE
		SELECT 		 
		E.IdEntregable,
		ISNULL(E.Consecutivo,'') AS Consecutivo,
		ISNULL(E.DocumentoEntregable,'') AS NombreEntregable,
		ISNULL(RR.FrecuenciaEntregable,'') AS Recurrencia
        FROM 
		EN_InstanciasEntregable	I  
        JOIN 
			EN_ContratoEntregable	CE  
			ON	I.IdContratoEntregable	=	CE.IdContratoEntregable  
			AND	CE.IdContrato	=	@ContratoId 
			AND	CE.Activo	=	1
			AND	I.Activo	=	1  		
		JOIN 
			dbo.EN_Entregable	e  
			ON	CE.IdEntregable	=	e.IdEntregable  			
			AND	E.IsActivo	=	1
			AND E.BitJOA	=	0
        LEFT JOIN 
			dbo.EN_MarcoLegal ml  
			ON	E.IdMarcoLegal	=	ml.IdMarcoLegal
		LEFT JOIN EN_FrecuenciaEntregable RR
			ON E.IdFrecuenciaEntregable = RR.IdFrecuenciaEntregable		
        WHERE	CE.IdContrato	=	@ContratoId 
              AND  
              (  
                  ml.Activo = 1  
                  OR e.BitInterno = 1  
              )  
			  AND  I.FechaCalculadaEntregaReg IS NOT NULL  
		GROUP BY 
		 E.IdEntregable,
		 E.Consecutivo,
		 E.DocumentoEntregable,
		 RR.FrecuenciaEntregable
	
			
	 END 
	 ELSE IF @EntregableIdentificador = 'OBTENER-DETALLE-ENTREGABLES-POR-CONTRATO-PROGRAMA-SASISOPA'
	 BEGIN 
	    -- OBTENER TODAS LAS INSTANCIAS DEL CONTRATO APROBADAS INTERNAMENTE DE LOS PROGRAMAS SASISOPA
			SET LANGUAGE Spanish;
	
			SELECT DISTINCT
				C.IdContrato,		
				C.NumeroContrato	AS Contrato,	
				CPI.IdProgramaImplementa AS IdPrograma,
				PIT.Descripcion	AS NombrePrograma,	
				CAST(FORMAT(CPI.FechaInicio,'yyyy-MM-dd hh:mm:ss') AS VARCHAR(100)) AS ProgramaFechaInicio,
				CAST(FORMAT(CPI.FechaFin,'yyyy-MM-dd hh:mm:ss') AS VARCHAR(100)) AS ProgramaFechaFin,
				PIP.IdProgramaImplementaPolitica AS IdPolitica,
				LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(PIP.Descripcion,CHAR(9),''),CHAR(13),''),CHAR(34),''),CHAR(39),''))) AS Politica, 
				PIE.IdProgramaImplementaElemento AS IdElemento,
				LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(PIE.Descripcion,CHAR(9),''),CHAR(13),''),CHAR(34),''),CHAR(39),''))) AS Elemento, 
				PIA.IdProgramaImplementaAccion AS IdAccion,
				LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(PIA.Descripcion,CHAR(9),''),CHAR(13),''),CHAR(34),''),CHAR(39),'')))	AS Accion,
				LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(PIA.Anexo3,CHAR(9),''),CHAR(13),''),CHAR(34),''),CHAR(39),''))) AS Anexo3,
				PIA.ElementosNumerales AS ElementosNumerales,
				CAST(FORMAT(PIA.FechaInicioPrimeraAccion,'yyyy-MM-dd hh:mm:ss') AS VARCHAR(100)) AS FechaInicioPrimeraAccion,
				CAST(FORMAT(PIA.FechaFinPrimeraAccion,'yyyy-MM-dd hh:mm:ss') AS VARCHAR(100)) AS FechaFinPrimeraAccion,		
				PIA.Porcentaje,		
				AEC.NombreArea AS AreaAccionEntregable,
				RRE.FrecuenciaEntregable AS RecurrenciaEntregable,
				E.Consecutivo AS ConsecutivoEntAdinco,
				ISNULL(IE.idInstanciaEntregable,0) AS Instancia,
				EDO.NombreEstado,
				CAST(FORMAT(ISNULL(IE.FechaRealEntregaRegulador, IE.FechaCalculadaEntregaReg),'yyyy-MM-dd hh:mm:ss') AS VARCHAR(100))	AS	FechaEntregaRegulador,
				E.IsActivo AS EntregableActivo
			FROM
				CO_ProgramaImplementa	CPI
			JOIN
				CO_Contrato	C	(NOLOCK)
				ON	CPI.IdContrato	=	C.IdContrato
				AND C.IdContrato	=	@ContratoId
			JOIN
				CO_ProgramaImplementacionTipo	PIT
				ON	CPI.IdTipoPrograma = PIT.Id
				AND CPI.Activo	=	1 --> CTE PROGRAMA SASISOPA ACTIVO
				AND CPI.IdContrato	=	PIT.IdContrato
			JOIN
				CO_ProgramaImplementaPoliticas	PIP
				ON	CPI.IdProgramaImplementa	=	PIP.IdProgramaImplementa
			JOIN
				CO_ProgramaImplementaElemento	PIE
				ON	PIP.IdProgramaImplementaPolitica = PIE.IdProgramaImplementaPolitica
			JOIN
				CO_ProgramaImplementaAcciones	PIA
				ON	PIE.IdProgramaImplementaElemento = PIA.IdProgramaImplementaElemento
			JOIN
				EN_ContratoEntregableProgramaImplementaAcciones	ENT_ACC
				ON	PIA.IdProgramaImplementaAccion = ENT_ACC.IdProgramaImplementaAccion
			JOIN CO_ProgramaImplementaDepartamentos PID
				ON PIA.IdProgramaImplementaDepartamento = PID.IdProgramaImplementaDepartamento	
			LEFT JOIN
				EN_ContratoEntregable	CE	(NOLOCK)
				ON	ENT_ACC.IdContratoEntregable	=	CE.IdContratoEntregable
				AND	ISNULL(ENT_ACC.Activo,1)	=	1 --> CTE ACCIONES ACTIVAS
				AND	ISNULL(CE.Activo,1)	=	1 --> CTE ENTREGABLE DEL CONTRATO ACTIVO
			LEFT JOIN EN_Area AEC
				ON CE.IdArea	= AEC.idArea
			LEFT JOIN
				EN_InstanciasEntregable	IE (NOLOCK)
				ON	CE.IdContratoEntregable = IE.IdContratoEntregable
				AND	ISNULL(IE.Activo,1)	=	1	--> CTE ENTREGABLE INSTANCIA ACTIVO
			LEFT JOIN EN_Entregable E
				on CE.IdEntregable	= E.IdEntregable
			LEFT JOIN EN_Actividad EAE
				ON IE.ActividadID = EAE.ActividadID
			LEFT JOIN 
					dbo.EN_Estado EDO  (NOLOCK)
					ON EAE.EstadoID = EDO.EstadoID  
			LEFT JOIN EN_FrecuenciaEntregable RRE
				ON E.IdFrecuenciaEntregable = RRE.IdFrecuenciaEntregable
			WHERE
				PIT.IdContrato	=	@ContratoId	
			ORDER BY
				 PIT.Descripcion
   				,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(PIP.Descripcion,CHAR(9),''),CHAR(13),''),CHAR(34),''),CHAR(39),'')))
				,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(PIE.Descripcion,CHAR(9),''),CHAR(13),''),CHAR(34),''),CHAR(39),'')))
				,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(PIA.Descripcion,CHAR(9),''),CHAR(13),''),CHAR(34),''),CHAR(39),'')))

	 END
	 ELSE
	 BEGIN 
		 -- OBTENER TODAS LAS INSTANCIAS DEL CONTRATO APROBADAS INTERNAMENTE POR ENTREGABLE
		SELECT @EntregableId = IdEntregable FROM EN_Entregable WHERE Consecutivo=@EntregableIdentificador

	    SELECT I.idInstanciaEntregable AS ProgramacionId,  
			   I.FechaCalculadaEntregaReg AS FechaCalculadaEntregaReg,
			   I.FechaRealEntregaRegulador AS FechaRealEntrega,
			   Es.NombreEstado AS NombreEstado,		
			   I.CreadoPor,
			   I.CreadoEn as CreadoEl,
			   I.Activo,
			   ISNULL(I.BitContieneAcuse, 0) AS ContieneAcuse,
			   A.EstadoID,  
			   E.IdEntregable			
        FROM 
		EN_InstanciasEntregable	I  
        JOIN 
			EN_ContratoEntregable	CE  
			ON	I.IdContratoEntregable	=	CE.IdContratoEntregable  
			AND	CE.IdContrato	=	@ContratoId
			AND	CE.Activo	=	1
			AND	I.Activo	=	1  
		JOIN
			EN_Actividad	A
			ON	I.ActividadID	=	A.ActividadID
			AND	A.EstadoID	=	10003	-- CTE Aprobado Internamente    
		JOIN 
			EN_Estado Es  
			ON A.EstadoID = Es.EstadoID  
		JOIN 
			dbo.EN_Entregable	e  
			ON	CE.IdEntregable	=	e.IdEntregable  
			AND E.IdEntregable	= @EntregableId
			AND	E.IsActivo	=	1
			AND E.BitJOA	=	0
        LEFT JOIN 
			dbo.EN_MarcoLegal ml  
			ON	e.IdMarcoLegal	=	ml.IdMarcoLegal  
		LEFT	JOIN
					EN_InstanciasEntregables_InstanciaActividad IEIA
					ON I.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
		LEFT	JOIN
				EN_InstanciasActividades	IA
				ON	IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
		LEFT JOIN 
				EN_InstanciasProcesosFecha	IPF
				ON	IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
		LEFT JOIN 
					EN_Procesos	P
					ON	IPF.IdProceso	=	P.IdProceso
        WHERE	CE.IdContrato	=	@ContratoId 
              AND  
              (  
                  ml.Activo = 1  
                  OR e.BitInterno = 1  
              )  
			  AND  I.FechaCalculadaEntregaReg IS NOT NULL
        ORDER BY FechasLimiteAprobacion ASC; 

		 
	 END 

END;


