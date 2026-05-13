CREATE PROCEDURE [dbo].[sp_JOA_ObtenHistorialPorId]--10061,3,310236
    @idUsuario INT,
	@idContrato INT,
	@idinstanciaEntregable	INT
AS
BEGIN
    SET NOCOUNT ON;

	SELECT 
	E.Consecutivo,
	e.idEntregable,
	ce.idContratoEntregable,
	ie.idinstanciaEntregable,
	C.NombreClasificacion AS Category,
	Apartado ,
	Inciso AS Clause,
	DocumentoEntregable,
	Articulo,
	FrecuenciaEntregable  ,
	IE.FechaCalculadaEntregaReg,
	Observaciones,
	NombreArea ,
	Accountable AS Accountable,
	AccountableCompliance,
	US.Nombre AS Responsible,
	CA.NombreContratista,
	HALT.CreadoEn AS FechaConfirmacion,
	ISNULL(CASE
			WHEN HALT.CreadoEn IS NOT NULL
			THEN 1
			ELSE 
				0
			END,0) AS Confirmado,
	ML.IdMarcoLegal,
	ML.MarcoLegal,
	CS.UrlDoc,
	HALT.Comentario,
	HALT.URLRepositorio
	FROM 
		EN_InstanciasEntregable	IE
	JOIN
		EN_ContratoEntregable	CE
		ON IE.IdContratoEntregable	=	CE.IdContratoEntregable
		AND	IE.idInstanciaEntregable	=	@idinstanciaEntregable
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

		 
END



