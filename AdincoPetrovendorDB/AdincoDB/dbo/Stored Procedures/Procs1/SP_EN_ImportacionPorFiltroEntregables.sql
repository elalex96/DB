USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_ImportacionPorFiltroEntregables]    Script Date: 12/07/2021 09:42:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <01/06/2021>
-- Description:	<Consulta de entregables para importacion>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ImportacionPorFiltroEntregables] 
	-- Add the parameters for the stored procedure here
	@IdContrato INT, 
	@FILTRO NVARCHAR(10),
	@DATO NVARCHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF @FILTRO = 'ML'
	BEGIN
		
		SELECT	--DISTINCT TOP 20
			CE.IdContratoEntregable,
			E.CONSECUTIVO,
			E.DOCUMENTOENTREGABLE,
			ML.MarcoLegal,
			FE.FrecuenciaEntregable,
			R.Regulador,
			ISNULL(A.NombreArea,'') AS 'Area Responsable',
			ISNULL(CE.DiasAlerta,'') AS 'Dias Alerta Previa',
			ISNULL(CE.DiasElaboracion,'') AS 'Days to elaborate ',
			ISNULL(CE.DiasRevision,'') AS 'Days to review',
			ISNULL(CE.DiasAprobacion,'') AS 'Days to Approve',
			CASE 
				WHEN CE.Activo = 1 THEN 'SI'
				ELSE 'NO'
			END AS Activo,
			ISNULL(UELAB.NOMBRE,'') AS 'Doer',
			ISNULL(CE.ReceptorAlerta,'') AS 'Receptor Alerta',
			ISNULL(CE.AccountableCompliance,'') AS LiderArea,
			ISNULL(CE.FocalPoint,'') AS ElaboradorInterno
		FROM EN_ContratoEntregable	CE (NOLOCK)
			JOIN EN_Entregable	E (NOLOCK)
				ON	CE.IDENTREGABLE = E.IDENTREGABLE
				AND isnull(e.IsActivo,0) = 1
				and ce.activo = 1
			--	AND E.BitInterno <> 1
			JOIN
				CO_Contrato	C (NOLOCK)
				ON CE.IdContrato	=	C.IdContrato
				AND C.DescripcionContrato LIKE '%REPSOL%'
			JOIN
				EN_EntregableRonda	ER (NOLOCK)
				ON	E.IdEntregable	=	ER.idEntregable
				AND	C.IdRonda	=	ER.idRonda
			JOIN
				EN_FrecuenciaEntregable	FE (NOLOCK)
				ON	E.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
			JOIN
				EN_MarcoLegal	ML (NOLOCK)
				ON	E.IdMarcoLegal = ML.IdMarcoLegal
			JOIN
				CO_Regulador	R (NOLOCK)
				ON	E.IdRegulador	=	R.IdRegulador
			LEFT JOIN
				EN_Actividad	ELAB
				ON	CE.IdContratoEntregable	=	ELAB.IdContratoEntregable
				AND ELAB.EstadoID	=	10000
			LEFT JOIN
				AP_Usuario	UELAB
				ON	ELAB.idUsuario	=	UELAB.UsuarioID
			LEFT JOIN
				EN_Area	A
				ON	CE.IdContrato = A.idContrato
				AND CE.IdArea	=	A.idArea
			LEFT JOIN 
				EN_ETAPA ET
				ON E.IdEtapa = ET.IdEtapa
			LEFT JOIN
				dbo.EN_ResponsableGenerador	RG
				ON E.IdResponsableGenerador	=	RG.IdResponsableGenerador
			WHERE
				isnull(e.IsActivo,0) = 1
				AND CE.IdContrato = @IdContrato
				AND ML.IdMarcoLegal = CAST(@DATO AS INT)
				 --AND C.DescripcionContrato LIKE '%REPSOL%'
				and ce.activo = 1
			ORDER BY
				ML.MarcoLegal,
				E.Consecutivo

	END

	IF @FILTRO = 'AR'
	BEGIN
		
		SELECT	DISTINCT TOP 20
			CE.IdContratoEntregable,
			E.CONSECUTIVO,
			E.DOCUMENTOENTREGABLE,
			ML.MarcoLegal,
			FE.FrecuenciaEntregable,
			R.Regulador,
			ISNULL(A.NombreArea,'') AS 'Area Responsable',
			ISNULL(CE.DiasAlerta,'') AS 'Dias Alerta Previa',
			ISNULL(CE.DiasElaboracion,'') AS 'Days to elaborate ',
			ISNULL(CE.DiasRevision,'') AS 'Days to review',
			ISNULL(CE.DiasAprobacion,'') AS 'Days to Approve',
			CASE 
				WHEN CE.Activo = 1 THEN 'SI'
				ELSE 'NO'
			END AS Activo,
			ISNULL(UELAB.NOMBRE,'') AS 'Doer',
			ISNULL(CE.ReceptorAlerta,'') AS 'Receptor Alerta',
			ISNULL(CE.AccountableCompliance,'') AS LiderArea,
			ISNULL(CE.FocalPoint,'') AS ElaboradorInterno
		FROM EN_ContratoEntregable	CE (NOLOCK)
			JOIN EN_Entregable	E (NOLOCK)
				ON	CE.IDENTREGABLE = E.IDENTREGABLE
				AND isnull(e.IsActivo,0) = 1
				and ce.activo = 1
			--	AND E.BitInterno <> 1
			JOIN
				CO_Contrato	C (NOLOCK)
				ON CE.IdContrato	=	C.IdContrato
				AND C.DescripcionContrato LIKE '%REPSOL%'
			JOIN
				EN_EntregableRonda	ER (NOLOCK)
				ON	E.IdEntregable	=	ER.idEntregable
				AND	C.IdRonda	=	ER.idRonda
			JOIN
				EN_FrecuenciaEntregable	FE (NOLOCK)
				ON	E.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
			JOIN
				EN_MarcoLegal	ML (NOLOCK)
				ON	E.IdMarcoLegal = ML.IdMarcoLegal
			JOIN
				CO_Regulador	R (NOLOCK)
				ON	E.IdRegulador	=	R.IdRegulador
			LEFT JOIN
				EN_Actividad	ELAB
				ON	CE.IdContratoEntregable	=	ELAB.IdContratoEntregable
				AND ELAB.EstadoID	=	10000
			LEFT JOIN
				AP_Usuario	UELAB
				ON	ELAB.idUsuario	=	UELAB.UsuarioID
			LEFT JOIN
				EN_Area	A
				ON	CE.IdContrato = A.idContrato
				AND CE.IdArea	=	A.idArea
			LEFT JOIN 
				EN_ETAPA ET
				ON E.IdEtapa = ET.IdEtapa
			LEFT JOIN
				dbo.EN_ResponsableGenerador	RG
				ON E.IdResponsableGenerador	=	RG.IdResponsableGenerador
			WHERE
				isnull(e.IsActivo,0) = 1
				AND CE.IdContrato = @IdContrato
				AND A.idArea = CAST(@DATO AS INT)
				 --AND C.DescripcionContrato LIKE '%REPSOL%'
				and ce.activo = 1
			ORDER BY
				ML.MarcoLegal,
				E.Consecutivo

	END

	IF @FILTRO = 'E'
	BEGIN
		
		SELECT	DISTINCT TOP 20
			CE.IdContratoEntregable,
			E.CONSECUTIVO,
			E.DOCUMENTOENTREGABLE,
			ML.MarcoLegal,
			FE.FrecuenciaEntregable,
			R.Regulador,
			ISNULL(A.NombreArea,'') AS 'Area Responsable',
			ISNULL(CE.DiasAlerta,'') AS 'Dias Alerta Previa',
			ISNULL(CE.DiasElaboracion,'') AS 'Days to elaborate ',
			ISNULL(CE.DiasRevision,'') AS 'Days to review',
			ISNULL(CE.DiasAprobacion,'') AS 'Days to Approve',
			CASE 
				WHEN CE.Activo = 1 THEN 'SI'
				ELSE 'NO'
			END AS Activo,
			ISNULL(UELAB.NOMBRE,'') AS 'Doer',
			ISNULL(CE.ReceptorAlerta,'') AS 'Receptor Alerta',
			ISNULL(CE.AccountableCompliance,'') AS LiderArea,
			ISNULL(CE.FocalPoint,'') AS ElaboradorInterno
		FROM EN_ContratoEntregable	CE (NOLOCK)
			JOIN EN_Entregable	E (NOLOCK)
				ON	CE.IDENTREGABLE = E.IDENTREGABLE
				AND isnull(e.IsActivo,0) = 1
				and ce.activo = 1
			--	AND E.BitInterno <> 1
			JOIN
				CO_Contrato	C (NOLOCK)
				ON CE.IdContrato	=	C.IdContrato
				AND C.DescripcionContrato LIKE '%REPSOL%'
			JOIN
				EN_EntregableRonda	ER (NOLOCK)
				ON	E.IdEntregable	=	ER.idEntregable
				AND	C.IdRonda	=	ER.idRonda
			JOIN
				EN_FrecuenciaEntregable	FE (NOLOCK)
				ON	E.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
			JOIN
				EN_MarcoLegal	ML (NOLOCK)
				ON	E.IdMarcoLegal = ML.IdMarcoLegal
			JOIN
				CO_Regulador	R (NOLOCK)
				ON	E.IdRegulador	=	R.IdRegulador
			LEFT JOIN
				EN_Actividad	ELAB
				ON	CE.IdContratoEntregable	=	ELAB.IdContratoEntregable
				AND ELAB.EstadoID	=	10000
			LEFT JOIN
				AP_Usuario	UELAB
				ON	ELAB.idUsuario	=	UELAB.UsuarioID
			LEFT JOIN
				EN_Area	A
				ON	CE.IdContrato = A.idContrato
				AND CE.IdArea	=	A.idArea
			LEFT JOIN 
				EN_ETAPA ET
				ON E.IdEtapa = ET.IdEtapa
			LEFT JOIN
				dbo.EN_ResponsableGenerador	RG
				ON E.IdResponsableGenerador	=	RG.IdResponsableGenerador
			WHERE
				isnull(e.IsActivo,0) = 1
				AND CE.IdContrato = @IdContrato
				AND UELAB.UsuarioID = CAST(@DATO AS INT)
				 --AND C.DescripcionContrato LIKE '%REPSOL%'
				and ce.activo = 1
			ORDER BY
				ML.MarcoLegal,
				E.Consecutivo

	END
END
