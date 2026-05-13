CREATE PROCEDURE [dbo].[sp_JOA_ObtenHistorial]--10061,3
    @idUsuario INT,
	@idContrato INT
AS
BEGIN
    SET NOCOUNT ON;

	SELECT 
	e.idEntregable,
	ce.idContratoEntregable,
	ie.idinstanciaEntregable,
	C.NombreClasificacion AS Category,
	Apartado ,
	Inciso AS Clause,
	DocumentoEntregable,
	Articulo,
	FrecuenciaIngles AS FrecuenciaEntregable  ,
	IE.FechaCalculadaEntregaReg,
	Observaciones,
	NombreArea ,
	US.Nombre AS Responsible,
	CA.NombreContratista,
	HALT.CreadoEn AS FechaConfirmacion,
	HALT.Comentario,
	ISNULL(CASE
			WHEN HALT.CreadoEn IS NOT NULL
			THEN 1
			ELSE 
				0
			END,0) AS Confirmado,
	ML.IdMarcoLegal,
	ML.MarcoLegal,
	CS.UrlDoc,
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
	 END AS AccountableCompliance

	FROM 
		EN_InstanciasEntregable	IE
	JOIN
		EN_ContratoEntregable	CE
		ON IE.IdContratoEntregable	=	CE.IdContratoEntregable

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
	JOIN
		AP_USUARIO	US
		ON	AC.idUsuario	=	US.UsuarioID
	JOIN
		CO_ContratoSocio	CS
		ON CE.IdContrato	=	CS.IdContrato
	JOIN 
		CO_Contratista	CA
		ON CS.IdContratistaSocio	=	CA.IdContratista
	LEFT	JOIN
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
	ORDER BY IE.FechaCalculadaEntregaReg ASC
END




