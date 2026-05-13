CREATE PROCEDURE [dbo].[sp_EN_PendientesElaboracionAplicacion] --10109
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @HOY DATE = GETDATE();

	CREATE TABLE #Contratos(IdContrato INT)
	CREATE TABLE #Contratistas(IdContratista INT)
	CREATE TABLE #GrupoUsuario
    (
        id INT PRIMARY KEY IDENTITY(1, 1),
        IdUsuarioGrupo int
    );
	CREATE TABLE #TempInstancias
	(
		id INT PRIMARY KEY IDENTITY(1, 1),
		idInstanciaEntregable	INT,
		IdContratoEntregable	INT
	);
	
	INSERT INTO #Contratistas (IdContratista)
	SELECT	CA.IdContratista
	FROM 
		AP_PerfilUsuario	PU (NOLOCK)
	JOIN
		AP_Perfil	P (NOLOCK)
		ON PU.PerfilID	=	P.IdPerfil
	JOIN
		CO_Contrato	C (NOLOCK)
		ON	P.IdContrato	=	C.IdContrato
	JOIN
		CO_Contratista	CA (NOLOCK)
		ON	C.IdContratista	=	CA.IdContratista
	WHERE 
		UsuarioID	=	@idUsuario
	GROUP BY CA.IdContratista

	INSERT INTO #Contratos(IdContrato)
	SELECT 
		IdContrato
	FROM 
		CO_Contrato	C (NOLOCK)
	JOIN
		#Contratistas	CA
		ON	C.IdContratista	=	CA.IdContratista


	INSERT INTO	#GrupoUsuario	(IdUsuarioGrupo)
	SELECT	IdGrupo	
	FROM	
		EN_GruposUsuarios GU (NOLOCK)
	JOIN
		#Contratos	C
		ON	GU.IdContrato	=	C.IdContrato
	WHERE	IdUsuario	=	@idUsuario
		AND	Activo	=	1
	UNION 
	SELECT @idUsuario
	 
    INSERT  INTO    #TempInstancias (idInstanciaEntregable,IdContratoEntregable)
    SELECT  
		idInstanciaEntregable,ie.IdContratoEntregable
   FROM 
		EN_InstanciasEntregable IE (NOLOCK)
    JOIN    
		EN_ContratoEntregable   CE  (NOLOCK)
        ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
		AND	CE.Activo	=	1
        AND	IE.Activo	=	1
		AND	IE.FechaInicioElaboracion	<=  DATEADD(YEAR,1,@HOY)
	JOIN
		#Contratos	CT
		ON	CE.IdContrato	=	CT.IdContrato
    JOIN    
		dbo.EN_Actividad    A (NOLOCK)
        ON  IE.ActividadID  =   A.ActividadID
    LEFT JOIN   
		dbo.EN_ExcepcionesActividad EXAR (NOLOCK)
        ON  A.ActividadID   =   EXAR.ActividadIDExcepcion 
        AND IE.idInstanciaEntregable    =   EXAR.IdInstanciasEntregables 

	WHERE (	    A.idUsuario	IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	@idUsuario
              AND	EXAR.IdInstanciasEntregables	IS NULL
			  AND	A.EstadoID	=	10000
          )
          OR (
				EXAR.idUsuario		IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	=	@idUsuario 
            AND	EXAR.IdInstanciasEntregables	IS NOT NULL
            AND	EXAR.EstadoID	=	10000	) 
			
    SELECT 
		IE.idInstanciaEntregable AS  idInstanciaEntregable,
        CE.IdEntregable  AS IdEntregable,
		ES.EstadoID,
		CITA.IdContratista,
	    C.IdContrato,
		CITA.NombreContratista,
		'http://procura.adinco.mx/assets/00/img/SMPS_Logo.png' as ImageContratistaRuta,
		C.NumeroContrato,
		IE.FechaCalculadaEntregaReg  AS  FechaEntregaRegulador,
        DocumentoEntregable,
        ISNULL(R.Regulador,'')   AS  Regulador,
		ISNULL(R.LogoRegulador,'') AS ImageReguladorRuta,
        ISNULL( M.MarcoLegal,'') AS  MarcoLegal,
        ISNULL(F.FrecuenciaEntregable,'')    AS FrecuenciaEntregable,
		ISNULL(ET.Etapa,'')  AS  Etapa,
        EN.Consecutivo,
        ISNULL(EN.Articulo,'') AS Articulo,
		EN.Descripcion,
		ISNULL(TR.TiempoRespuesta,'') AS TiempoRespuesta,
		ISNULL(RG.ResponsableGenerador,'') AS ResponsableGenerador,
		CASE
			WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN '#e03531'
			WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN '#e03531'
			WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN '#ffdd99'
			WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN '#8cd98c'
		END	AS ColorEstatus,
		CASE
			WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 THEN 'Delayed'
			WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN '0-40% of time remaining'
			WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN '40-70% of time remaining'
			WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN 'More than 70% of time remaining'
		END	AS DefinicionColor,
		ES.NombreEstado
    FROM    
		#TempInstancias TI
    JOIN    
		EN_InstanciasEntregable	IE  (NOLOCK)
		ON  TI.idInstanciaEntregable  =   IE.idInstanciaEntregable
    JOIN    
		EN_ContratoEntregable   CE (NOLOCK)
		ON  IE.IdContratoEntregable =   CE.IdContratoEntregable
	JOIN
		CO_Contrato	C (NOLOCK)
		ON	CE.IdContrato	=	C.IdContrato
	JOIN
		CO_Contratista	CITA (NOLOCK)
		ON C.IdContratista	=	CITA.IdContratista
	JOIN   
		EN_Entregable EN (NOLOCK)
		ON CE.IdEntregable  =   EN.IdEntregable
		AND EN.BITJOA = 0
	JOIN
		EN_Estado	ES (NOLOCK)
		on	ES.EstadoID	=	10000
    LEFT    JOIN    
		dbo.CO_Regulador R (NOLOCK)
		ON EN.IdRegulador   =   R.IdRegulador
    LEFT    JOIN    
		dbo.EN_FrecuenciaEntregable F (NOLOCK)
		ON EN.IdFrecuenciaEntregable    =   F.IdFrecuenciaEntregable
    LEFT    JOIN    
		EN_Etapa ET (NOLOCK)
		ON EN.IdEtapa   =   ET.IdEtapa
    LEFT    JOIN    
		dbo.EN_MarcoLegal M (NOLOCK)
		ON EN.IdMarcoLegal  =   M.IdMarcoLegal
	LEFT	JOIN
		EN_TiempoRespuesta	TR (NOLOCK)
		ON	EN.IdTiempoRespuesta	=	TR.IdTiempoRespuesta
	LEFT	JOIN
		EN_ResponsableGenerador	RG (NOLOCK)
		ON	EN.IdResponsableGenerador	=	RG.IdResponsableGenerador
	WHERE
		EN.IsActivo	=	1;

END