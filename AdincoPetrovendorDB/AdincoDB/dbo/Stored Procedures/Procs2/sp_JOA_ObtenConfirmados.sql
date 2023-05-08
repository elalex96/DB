CREATE PROCEDURE [dbo].[sp_JOA_ObtenConfirmados]--10061,3
    @idUsuario INT,
	@idContrato INT
AS
BEGIN
    SET NOCOUNT ON;

	SELECT 
	e.idEntregable,
	ce.idContratoEntregable,
	ie.idinstanciaEntregable,
	C.NombreClasificacion ,
	Apartado ,
	Inciso ,
	DocumentoEntregable,
	Articulo,
	FrecuenciaEntregable  ,
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
	US.Nombre AS Responsible,
	CA.NombreContratista,
	HALT.CreadoEn AS FechaConfirmacion,
	HALT.Comentario ,
	ML.IdMarcoLegal,
	ML.MarcoLegal,
	CS.UrlDoc

	FROM 
		EN_InstanciasEntregable	IE
	JOIN
		EN_ContratoEntregable	CE
		ON IE.IdContratoEntregable	=	CE.IdContratoEntregable
	JOIN
		EN_Actividad	ACI
		ON	IE.ActividadID	=	ACI.ActividadID
		AND ACI.EstadoID	=	10003
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
		AND	AC.EstadoID	=	10000
		AND	AC.idUsuario	=	@idUsuario
	JOIN
		AP_USUARIO	US
		ON	AC.idUsuario	=	US.UsuarioID
	JOIN
		CO_ContratoSocio	CS
		ON CE.IdContrato	=	CS.IdContrato
	JOIN 
		CO_Contratista	CA
		ON CS.IdContratistaSocio	=	CA.IdContratista
	JOIN
		EN_HistorialAprobacionesLineaTiempo	HALT
		ON	IE.idInstanciaEntregable	=	HALT.idInstanciaEntregable
		AND	HALT.idTipoOperacion	=	2
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
		IE.FechaCalculadaEntregaReg	ASC
END



