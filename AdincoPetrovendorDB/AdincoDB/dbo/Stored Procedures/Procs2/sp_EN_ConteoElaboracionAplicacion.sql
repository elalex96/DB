CREATE PROCEDURE [dbo].[sp_EN_ConteoElaboracionAplicacion] --10109
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
	/*DROP TABLE #Contratos;
	DROP TABLE #Contratistas;
	DROP TABLE #GrupoUsuario;
	DROP TABLE #TempInstancias;*/
	--declare @idUsuario int = 10090
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

	WHERE (	    A.idUsuario	IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)
              AND	EXAR.IdInstanciasEntregables	IS NULL
			  AND	A.EstadoID	=	10000
          )
          OR (
				EXAR.idUsuario		IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	=	@idUsuario 
            AND	EXAR.IdInstanciasEntregables	IS NOT NULL
            AND	EXAR.EstadoID	=	10000	) 

	SELECT 
		COUNT(1) AS Cantidad,
		'Delayed' AS DefinicionColor,
		'Pendientes Elaboración'AS Estado
	FROM    
		#TempInstancias TI
	JOIN    
		EN_InstanciasEntregable	IE (NOLOCK) 
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

