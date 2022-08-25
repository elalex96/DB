USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_Migracion_EntregablesInstancias'
)
    DROP PROCEDURE SP_Migracion_EntregablesInstancias;
GO 
/****** Object:  StoredProcedure [dbo].[SP_Migracion_EntregablesInstancias]    Script Date: 24/08/2022 12:58:48 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
		 -- OBTENER TODAS LAS INSTANCIAS DEL CONTRATO APROBADAS INTERNAMENTE
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



