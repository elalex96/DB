CREATE PROCEDURE [dbo].[sp_EN_NotificacionProcesosGenerados] --3,10061,12790,11451
    @IdContrato INT,
    @IdUsuario INT,
	@IdProceso INT,
	@IdInstanciaProceso INT
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 
-- Description:	
-- =============================================
SET NOCOUNT ON


CREATE TABLE #INSTANCIAS(Id INT IDENTITY(1,1), IdInstanciaEntregable INT, ActividadID INT, IdContratoEntregable INT, NombreInstanciaProceso varchar(MAX))
CREATE TABLE #CORREOS(Id INT IDENTITY(1,1), IdInstanciaEntregable int,	Usuario VARCHAR(300),tabla varchar(max), NombreInstanciaProceso VARCHAR(MAX));


INSERT INTO #INSTANCIAS(IdInstanciaEntregable, ActividadID, IdContratoEntregable, NombreInstanciaProceso)
SELECT IE.idInstanciaEntregable, IE.ActividadID, IE.IdContratoEntregable, IPF.Descripcion
FROM
	dbo.EN_InstanciasEntregable IE  (NOLOCK)
JOIN 
	EN_InstanciasEntregables_InstanciaActividad	IEIA
	ON IE.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
JOIN
	EN_InstanciasActividades	IA
	ON	IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
	AND IA.IdInstanciasProcesos	=	@IdInstanciaProceso
JOIN
	EN_InstanciasProcesosFecha	IPF
	ON IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
	AND IPF.IdProceso	=	@IdProceso
WHERE  IE.Activo=1;


DECLARE @Hoy DATETIME=GETDATE(), @error varchar(max) ='';


INSERT INTO #CORREOS (IdInstanciaEntregable,Usuario,tabla, NombreInstanciaProceso)
SELECT ie.idInstanciaEntregable,
        CASE	ISNULL(EXA.ActividadIDExcepcion,0)
			WHEN 0
				THEN U1.Usuario
			ELSE EXAU.Usuario
		END AS Usuario,
        '<tr><td>' + LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
        '<td'+
        CASE
        WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
        WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN ' style="background-color:Tomato;">0-40% of time remaining'
        WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN ' style="background-color:#ffdd99;">40-70% of time remaining'
        WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN ' style="background-color:#8cd98c;">More than 70% of time remaining'
        END  + '</td>'+
        '<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>'  + 
        '<td>'+ CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
            ELSE ISNULL(ACC.Nombre,'')  -- ACCOUNTABLE
        END + '</td>'  + 
        '<td>'+   CASE	ISNULL(EXA.ActividadIDExcepcion,0)
			WHEN 0
				THEN U1.Nombre
			ELSE EXAU.Nombre
		END + '</td>' +   -- RESPONSIBLE
        '<td>'+ CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
            ELSE ISNULL(FP.Nombre,'')   -- FOCALPOINT
        END     + '</td>'  + 
        '<td>'+ CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
            ELSE ISNULL(AC.Nombre,'')   -- ACCOUNTABLE COMPLIANCE
        END     + '</td>'  + 
        '<td>'+C.NumeroContrato+ '</td>'    AS Tabla,
		IEP.NombreInstanciaProceso
    FROM	
		#INSTANCIAS IEP
		JOIN 
			EN_InstanciasEntregable IE
			ON	IEP.IdInstanciaEntregable	=	IE.idInstanciaEntregable
        JOIN
            dbo.EN_Actividad            A   (NOLOCK)
            ON IE.ActividadID   =   A.ActividadID
        JOIN
            dbo.EN_ContratoEntregable   CE  (NOLOCK)
            ON IE.IdContratoEntregable= CE.IdContratoEntregable
            AND CE.IDCONTRATO   =   @IdContrato
        JOIN
            dbo.EN_Entregable           E   (NOLOCK)
            ON CE.IdEntregable  = E.IdEntregable 
        JOIN
            CO_Contrato C   (NOLOCK)
            ON CE.IdContrato    =   C.IdContrato
        JOIN
            dbo.AP_Usuario              U1  (NOLOCK)
            ON A.idUsuario = U1.UsuarioID
        LEFT JOIN
            AP_USUARIO FP       -- OBTENER NOMBRE DEL FOCAL POINT
            ON  CE.FocalPoint   =   FP.Usuario
        LEFT JOIN
            AP_USUARIO AC       -- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
            ON  CE.AccountableCompliance    =   AC.Usuario
        LEFT JOIN
            AP_USUARIO ACC      -- OBTENER EL NOMBRE DEL ACCOUNTABLE
            ON  CE.Accountable  =   ACC.Usuario
		LEFT JOIN 
			EN_ExcepcionesActividad EXA	(NOLOCK)
			ON A.ActividadID	=	EXA.ActividadIDExcepcion
			AND IE.idInstanciaEntregable	=	EXA.IdInstanciasEntregables
		 LEFT JOIN
            dbo.AP_Usuario              EXAU  (NOLOCK)
            ON EXA.idUsuario = EXAU.UsuarioID
    WHERE
        CE.Activo=1 
		AND E.IsActivo	=	1
		AND	((EXAU.UsuarioID IS NOT NULL AND ISNULL(EXAU.IsGrupo,0)<>1) 
			OR (EXAU.UsuarioID IS NULL AND ISNULL(U1.IsGrupo,0)<>1))
UNION

--############ GRUPOS #############
	SELECT ie.idInstanciaEntregable,
        CASE	ISNULL(EXA.ActividadIDExcepcion,0)
			WHEN 0
				THEN UG.Usuario
			ELSE UGEX.Usuario
		END AS Usuario,
    
        '<tr><td>' + LTRIM(RTRIM(E.DocumentoEntregable)) + '</td>'+
        '<td'+
        CASE
        WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN ' style="background-color:Tomato;">Delayed'
        WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN ' style="background-color:Tomato;">0-40% of time remaining'
        WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN ' style="background-color:#ffdd99;">40-70% of time remaining'
        WHEN (CONVERT(FLOAT,DATEDIFF(DAY,@HOY,IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN ' style="background-color:#8cd98c;">More than 70% of time remaining'
        END  + '</td>'+

        '<td>'+ CONVERT(VARCHAR(10),IE.FechaCalculadaEntregaReg,111) + '</td>'  + 

        '<td>'+ CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
            ELSE ISNULL(ACC.Nombre,'')  -- ACCOUNTABLE
        END + '</td>'  + 

        '<td>'+  
		CASE	ISNULL(EXA.ActividadIDExcepcion,0)
			WHEN 0
				THEN UG.Nombre
			ELSE UGEX.Nombre
		END
		 + '</td>' +   -- RESPONSIBLE

        '<td>'+ CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
            ELSE ISNULL(FP.Nombre,'')   -- FOCALPOINT
        END     + '</td>'  +
		 
        '<td>'+ CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
            ELSE ISNULL(AC.Nombre,'')   -- ACCOUNTABLE COMPLIANCE
        END     + '</td>'  + 

        '<td>'+C.NumeroContrato+ '</td>'    AS Tabla,
		IEP.NombreInstanciaProceso
    FROM	
		#INSTANCIAS IEP
	JOIN 
		EN_InstanciasEntregable IE
		ON	IEP.IdInstanciaEntregable	=	IE.idInstanciaEntregable
	JOIN
		dbo.EN_Actividad            A   (NOLOCK)
		ON IE.ActividadID   =   A.ActividadID
	JOIN
		dbo.EN_ContratoEntregable   CE  (NOLOCK)
		ON IE.IdContratoEntregable= CE.IdContratoEntregable
		AND CE.IDCONTRATO   =   @IdContrato
	JOIN
		dbo.EN_Entregable           E   (NOLOCK)
		ON CE.IdEntregable  = E.IdEntregable 
	JOIN
		CO_Contrato C   (NOLOCK)
		ON CE.IdContrato    =   C.IdContrato
	JOIN
		dbo.AP_Usuario              U1  (NOLOCK)
		ON A.idUsuario = U1.UsuarioID
	LEFT JOIN
		EN_GruposUsuarios G	
		ON A.idUsuario	=	G.IdGrupo
		AND G.IdContrato	=	@IdContrato
	LEFT JOIN 
		AP_USUARIO UG
		ON G.IdUsuario	=	UG.UsuarioID
	LEFT JOIN
		AP_USUARIO FP       -- OBTENER NOMBRE DEL FOCAL POINT
		ON  CE.FocalPoint   =   FP.Usuario
	LEFT JOIN
		AP_USUARIO AC       -- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
		ON  CE.AccountableCompliance    =   AC.Usuario
	LEFT JOIN
		AP_USUARIO ACC      -- OBTENER EL NOMBRE DEL ACCOUNTABLE
		ON  CE.Accountable  =   ACC.Usuario
	LEFT JOIN 
		EN_ExcepcionesActividad EXA	(NOLOCK)
		ON A.ActividadID	=	EXA.ActividadIDExcepcion
		AND IE.idInstanciaEntregable	=	EXA.IdInstanciasEntregables
	LEFT JOIN
		dbo.AP_Usuario              EXAU  (NOLOCK)
		ON EXA.idUsuario = EXAU.UsuarioID
	LEFT JOIN
		EN_GruposUsuarios GEX
		ON EXAU.UsuarioID	=	GEX.IdGrupo
		AND GEX.IdContrato	=	@IdContrato
	LEFT JOIN 
		AP_USUARIO UGEX
		ON GEX.IdUsuario	=	UGEX.UsuarioID
    WHERE
        CE.Activo=1 
		AND E.IsActivo	=	1
		AND	((ISNULL(EXAU.IsGrupo,0)=1) OR (ISNULL(U1.IsGrupo,0)=1))




		SELECT DISTINCT
		USUARIO,
		REPLACE( REPLACE(STUFF((
			SELECT ' '  + tabla
			FROM	#Correos C
			WHERE	C.Usuario	=	CO.Usuario
			FOR XML PATH('')),
			1, 1, ''),'&lt;','<'),'&gt;','>')
			AS	TABLA,
			 'Notificación de Proceso Generado'   AS tipoCorreo,
			'https://'+ruta.Ruta+'/2/Entregables/SubeEntregables.aspx' AS RutaPendiente
			FROM	
				#Correos CO
			JOIN 
				CO_Contrato	 C
				ON C.IdContrato	=	@IdContrato
			JOIN
				dbo.CO_Contratista cita (NOLOCK)
				ON  c.IdContratista =   cita.IdContratista
			JOIN
				dbo.AP_Rutas ruta   (NOLOCK)
				ON cita.IdRuta=ruta.idRuta


--select * from #Correos;



--select @error as error;
END