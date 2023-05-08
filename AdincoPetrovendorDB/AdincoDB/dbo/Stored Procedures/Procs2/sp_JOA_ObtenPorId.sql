CREATE PROCEDURE [dbo].[sp_JOA_ObtenPorId]--10061,3,42749
    @idUsuario INT,
	@idContrato INT,
	@idEntregable INT 
AS
BEGIN
    SET NOCOUNT ON;

	

	SELECT 
		e.idEntregable,
		ce.idContratoEntregable,
		UsuarioID,
		E.IdClasificacion,
		E.IdFrecuenciaEntregable,
		CE.IdArea,
		C.NombreClasificacion ,
		Apartado ,
		Inciso ,
		DocumentoEntregable,
		Articulo,
		FrecuenciaEntregable  ,
		ce.FechaLimiteEntregaRegulador,
		Observaciones,
		NombreArea ,
		ce.Accountable AS Accountable,
		ce.AccountableCompliance,
		US.Nombre AS Responsible,
		e.Consecutivo,
		CS.IdContratistaSocio,
		ISNULL(CE.ContieneInformacionSensible,0) AS ContieneInformacionSensible,
		ML.IdMarcoLegal,
		ML.MarcoLegal,
		CS.UrlDoc
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
	lEFT JOIN
		CO_ContratoSocio	CS
		ON	CS.IdContrato	=	@idContrato
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
		ON	AC.idUsuario	=	US.UsuarioID
	LEFT	JOIN
		EN_MarcoLegal	ML
		ON E.IdMarcoLegal	=	ML.IdMarcoLegal
	
	WHERE CE.IdEntregable	=	@idEntregable
	
		 
END



