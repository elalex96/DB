CREATE PROCEDURE [dbo].[sp_EN_ConteoRevAprobAplicacion]--10090
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
	/*DROP TABLE #Contratos;
	DROP TABLE #Contratistas;
	DROP TABLE #GrupoUsuario;
	DROP TABLE #TempInstancias;*/
	--declare @idUsuario int = 10090
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
		IdContratoEntregable	INT,
		EstadoID INT
	);

	INSERT INTO #Contratistas (IdContratista)
	SELECT	CA.IdContratista
	FROM 
		AP_PerfilUsuario	PU
	JOIN
		AP_Perfil	P
		ON PU.PerfilID	=	P.IdPerfil
	JOIN
		CO_Contrato	C
		ON	P.IdContrato	=	C.IdContrato
	JOIN
		CO_Contratista	CA
		ON	C.IdContratista	=	CA.IdContratista
	WHERE 
		UsuarioID	=	@idUsuario
	GROUP BY CA.IdContratista

	INSERT INTO #Contratos(IdContrato)
	SELECT 
		IdContrato
	FROM 
		CO_Contrato	C
	JOIN
		#Contratistas	CA
		ON	C.IdContratista	=	CA.IdContratista

	INSERT INTO	#GrupoUsuario	(IdUsuarioGrupo)
	SELECT	IdGrupo	
	FROM	
		EN_GruposUsuarios GU
	JOIN
		#Contratos	C
		ON	GU.IdContrato	=	C.IdContrato
	WHERE	IdUsuario	=	@idUsuario
		AND	Activo	=	1
	UNION 
	SELECT @idUsuario
	 
    INSERT  INTO    #TempInstancias (idInstanciaEntregable,IdContratoEntregable,EstadoID)
    SELECT  
		idInstanciaEntregable,ie.IdContratoEntregable, A.EstadoID
   FROM 
		EN_InstanciasEntregable IE
    JOIN    
		EN_ContratoEntregable   CE  
        ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
	JOIN
		#Contratos	CT
		ON	CE.IdContrato	=	CT.IdContrato
    JOIN    
		dbo.EN_Actividad    A
        ON  IE.ActividadID  =   A.ActividadID
    LEFT JOIN   
		dbo.EN_ExcepcionesActividad EXAR
        ON  A.ActividadID   =   EXAR.ActividadIDExcepcion 
        AND IE.idInstanciaEntregable    =   EXAR.IdInstanciasEntregables 

	WHERE (	    A.idUsuario	IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	@idUsuario
              AND	EXAR.IdInstanciasEntregables	IS NULL
              AND	A.EstadoID	=	10001
              AND	CE.Activo	=	1
              AND	IE.Activo	=	1
			  
          )
          OR (
				EXAR.idUsuario		IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	=	@idUsuario 

            AND	EXAR.IdInstanciasEntregables	IS NOT NULL
            AND	EXAR.EstadoID	=	10001
            AND	CE.Activo	=	1
            AND	IE.Activo	=	1
				) 
		UNION
	SELECT  
		idInstanciaEntregable,ie.IdContratoEntregable,A.EstadoID
   FROM 
		EN_InstanciasEntregable IE
    JOIN    
		EN_ContratoEntregable   CE  
        ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
	JOIN
		#Contratos	CT
		ON	CE.IdContrato	=	CT.IdContrato
    JOIN    
		dbo.EN_Actividad    A
        ON  IE.ActividadID  =   A.ActividadID
    LEFT JOIN   
		dbo.EN_ExcepcionesActividad EXAR
        ON  A.ActividadID   =   EXAR.ActividadIDExcepcion 
        AND IE.idInstanciaEntregable    =   EXAR.IdInstanciasEntregables 

	WHERE (	    A.idUsuario	IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)
              AND	EXAR.IdInstanciasEntregables	IS NULL
              AND	A.EstadoID	=	10002
              AND	CE.Activo	=	1
              AND	IE.Activo	=	1
			  
          )
          OR (
				EXAR.idUsuario		IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)

            AND	EXAR.IdInstanciasEntregables	IS NOT NULL
            AND	EXAR.EstadoID	=	10002
            AND	CE.Activo	=	1
            AND	IE.Activo	=	1
				) 

			
    SELECT 
		COUNT(1) AS Cantidad,
		'Delayed' AS DefinicionColor,
		'Pendientes Revisión-Aprobación' AS Estado
    FROM    
		#TempInstancias TI
    JOIN    
		EN_InstanciasEntregable	IE  
		ON  TI.idInstanciaEntregable  =   IE.idInstanciaEntregable
    JOIN    
		EN_ContratoEntregable   CE 
		ON  IE.IdContratoEntregable =   CE.IdContratoEntregable
	JOIN   
		EN_Entregable EN 
		ON CE.IdEntregable  =   EN.IdEntregable
		AND EN.IsActivo	=	1
	WHERE
		 DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0  --'Delayed'

END

