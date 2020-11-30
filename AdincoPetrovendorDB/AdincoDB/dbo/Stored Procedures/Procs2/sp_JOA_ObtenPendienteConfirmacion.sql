CREATE PROCEDURE [dbo].[sp_JOA_ObtenPendienteConfirmacion]--10061,3
    @idUsuario INT,
	@idContrato INT
AS
BEGIN
    SET NOCOUNT ON;

	
    CREATE TABLE #TempInstancias
    (
        Id INT PRIMARY KEY IDENTITY(1, 1),
        FechasLimiteElaboracion DATE,
        IdEntregable INT
    );

	INSERT INTO	#TempInstancias(FechasLimiteElaboracion,IdEntregable)
	SELECT	
		MIN(IE.FechasLimiteElaboracion),	CE.IdEntregable
	FROM 
		EN_InstanciasEntregable	IE
	JOIN
		EN_ContratoEntregable	CE
		ON IE.IdContratoEntregable	=	IE.IdContratoEntregable
	JOIN
		EN_Entregable	E
		ON	CE.IdEntregable	=	E.IdEntregable
		AND CE.IdContrato	=	@idContrato
		AND E.BitJOA	=	1
	JOIN
		EN_ACTIVIDAD	AC
		ON CE.IdContratoEntregable	=	AC.IdContratoEntregable
		AND IE.ActividadID	=	AC.ActividadID
		AND AC.EstadoID	=	10000
		AND	AC.idUsuario	=	@idUsuario
	GROUP BY CE.IdEntregable

	SELECT 
	e.idEntregable,
	ce.idContratoEntregable,
	ie.idinstanciaEntregable,
	C.NombreClasificacion ,
	Apartado ,
	Inciso,
	DocumentoEntregable,
	Articulo,
	FrecuenciaIngles AS FrecuenciaEntregable  ,
	IE.FechaCalculadaEntregaReg,
	Observaciones,
	NombreArea ,
	CASE 
		WHEN ACC.Nombre IS NULL 
	THEN 
		ISNULL(CE.Accountable,'')
     ELSE 
		ISNULL(ACC.Nombre,'')
	 END AS Accountable,

	CASE 
		WHEN ACCC.Nombre IS NULL 
	THEN 
		ISNULL(CE.AccountableCompliance,'')
     ELSE 
		ISNULL(ACCC.Nombre,'')
	 END AS AccountableCompliance,
	CA.NombreContratista,
	ISNULL(CE.ContieneInformacionSensible,0) AS ContieneInformacionSensible,
	ML.IdMarcoLegal,
	ML.MarcoLegal,
	CS.UrlDoc,
	CE.ContieneInformacionSensible
	FROM	
		#TempInstancias	TI
    JOIN	
		EN_InstanciasEntregable	IE 
		ON TI.FechasLimiteElaboracion	=	IE.FechasLimiteElaboracion
	JOIN
		EN_ContratoEntregable	CE
		ON  TI.idEntregable	=	CE.IdEntregable
		AND	IE.IdContratoEntregable	=	CE.IdContratoEntregable
	JOIN
		EN_Entregable	E
		ON	CE.IdEntregable	=	E.IdEntregable
		AND CE.IdContrato	=	@idContrato
		AND E.BitJOA	=	1
	JOIN
		En_Clasificacion	C
		ON E.IdClasificacion	=	C.IdClasificacion
	JOIN
		EN_FrecuenciaEntregable	FE
		ON	E.IdFrecuenciaEntregable	=	FE.IdFrecuenciaEntregable
	JOIN
		EN_Area	A
		ON CE.IdArea	=	A.idArea
		AND A.idContrato	= @idContrato
	JOIN
		EN_ACTIVIDAD	AC
		ON CE.IdContratoEntregable	=	AC.IdContratoEntregable
		AND IE.ActividadID	=	AC.ActividadID
		AND AC.EstadoID	=	10000
		AND	AC.idUsuario	=	@idUsuario
	
	JOIN
		CO_ContratoSocio	CS
		ON CE.IdContrato	=	CS.IdContrato
	JOIN 
		CO_Contratista	CA
		ON CS.IdContratistaSocio	=	CA.IdContratista
	LEFT	JOIN
		EN_MarcoLegal	ML
		ON E.IdMarcoLegal	=	ML.IdMarcoLegal
	LEFT JOIN
        AP_USUARIO ACC             
        ON     CE.Accountable      =      ACC.Usuario
	LEFT JOIN
        AP_USUARIO ACCC             
        ON     CE.AccountableCompliance      =      ACCC.Usuario
	ORDER BY 
		IE.FechaCalculadaEntregaReg
END




