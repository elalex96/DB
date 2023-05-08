CREATE PROCEDURE [dbo].[sp_JOA_ObtenListadoContrato]--10061,3
    @idUsuario INT,
	@idContrato INT
AS
BEGIN
    SET NOCOUNT ON;

	SELECT 
	e.idEntregable,
	ce.idContratoEntregable,
	C.NombreClasificacion AS Category,
	Apartado ,
	Inciso AS Clause,
	DocumentoEntregable,
	Articulo,
	FrecuenciaIngles AS FrecuenciaEntregable  ,
	ce.FechaLimiteEntregaRegulador,
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

	US.Nombre AS Responsible,
	e.Consecutivo,
	e.IsActivo,
	ISNULL(CE.ContieneInformacionSensible,0)AS ContieneInformacionSensible,
	ML.IdMarcoLegal,
	ML.MarcoLegal,
	CS.UrlDoc,
	CA.NombreContratista
	FROM
		EN_ContratoEntregable	CE
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
		CO_ContratoSocio	CS
		ON CE.IdContrato	=	CS.IdContrato
	JOIN 
		CO_Contratista	CA
		ON CS.IdContratistaSocio	=	CA.IdContratista
	LEFT JOIN
		EN_Area	A
		ON CE.IdArea	=	A.idArea
		AND A.idContrato	= @idContrato
	LEFT JOIN
		EN_ACTIVIDAD	AC
		ON CE.IdContratoEntregable	=	AC.IdContratoEntregable
		AND	AC.EstadoID	=	10000
	LEFT JOIN
		AP_USUARIO	US
		ON	AC.idUsuario	= US.UsuarioID
	LEFT	JOIN
		EN_MarcoLegal	ML
		ON E.IdMarcoLegal	=	ML.IdMarcoLegal
	LEFT JOIN
        AP_USUARIO ACC             
        ON     CE.Accountable      =      ACC.Usuario
	LEFT JOIN
        AP_USUARIO ACCC             
        ON     CE.AccountableCompliance      =      ACCC.Usuario
		 
END




