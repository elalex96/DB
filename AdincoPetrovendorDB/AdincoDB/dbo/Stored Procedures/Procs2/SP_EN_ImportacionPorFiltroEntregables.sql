-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <01/06/2021>
-- Description:	<Consulta de entregables para importacion>
-- =============================================
-- Author:		<Luis David De La Cruz>
-- Create date: <26/08/2021>
-- Description:	<Formato para Shell>
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
		--REPSOL
		IF @IdContrato IN (10093,10108,10110,10119,10120,10122)
		BEGIN
			SELECT	DISTINCT 
			--TOP 20
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
				AND ((ML.IdMarcoLegal = CAST(@DATO AS INT)) or CAST(@DATO AS INT) = -1)
				 --AND C.DescripcionContrato LIKE '%REPSOL%'
				and ce.activo = 1
			ORDER BY
				ML.MarcoLegal,
				E.Consecutivo
		END

		--Eni. Equinor, Murphy, Carso, Smart (México)
		IF @IdContrato IN (3,10039,10047,10048,10049,10050,10054,10055,10056,10057,10058)
		BEGIN
		
			SELECT	DISTINCT 
			--TOP 20
				CE.IdContratoEntregable,
				E.CONSECUTIVO, 
				E.DOCUMENTOENTREGABLE,
				isnull(ML.MarcoLegal,'') as MarcoLegal,
				FE.FrecuenciaEntregable, 
				ISNULL(RE.ReceptorEntregable,'') AS Receptor,
				ISNULL(A.NombreArea,'') AS AreaResponsable,
				ISNULL(CE.DiasAlerta,'') AS 'Dias Alerta Previa',
				ISNULL(CE.DiasElaboracion,'') AS 'Dias para elaborar/Days to elaborate ',
				ISNULL(CE.DiasRevision,'') AS 'Dias para Revisar/Days to review', 
				ISNULL(CE.DiasAprobacion,'') AS 'Dias para Aprobar/Days to Approve', 
				CASE WHEN ISNULL(CE.ACTIVO,0) = 1 THEN 'SI' ELSE 'NO' END AS 'Activo',
				ISNULL(UELAB.NOMBRE,'') AS 'Elaborador/Doer',
				dbo.fnGetRevisoresEntregable (CE.IdContratoEntregable)	AS 'Revisor(es)/Reviewer',
				ISNULL(UAPRO.NOMBRE,'') AS 'Aprobador/Approver',
				ISNULL(CE.ReceptorAlerta,'') AS 'Receptor Alerta'
				FROM 
					CO_Contrato	C (NOLOCK)
				JOIN
					EN_ContratoEntregable	CE (NOLOCK)
					ON C.IdContrato	=	CE.IdContrato
					AND	C.IdContrato  = @IdContrato
				JOIN
					EN_Entregable	E (NOLOCK)
					ON	CE.IDENTREGABLE = E.IDENTREGABLE
					and isnull(e.IsActivo,0) = 1
				JOIN
					EN_EntregableRonda	ER (NOLOCK)
					ON	E.IdEntregable	=	ER.idEntregable
					AND	C.IdRonda	=	ER.idRonda
				LEFT JOIN
					EN_FrecuenciaEntregable	FE (NOLOCK)
					ON	E.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
				LEFT JOIN
					EN_MarcoLegal	ML (NOLOCK)
					ON	E.IdMarcoLegal = ML.IdMarcoLegal
				LEFT JOIN EN_RESPONSABLEGENERADOR RG	(NOLOCK)
					ON E.IdResponsableGenerador = RG.IdResponsableGenerador
				LEFT JOIN
					EN_RecepTorEntregable RE	(NOLOCK)
					ON E.IDRECEPTORENTREGABLE = RE.IDRECEPTORENTREGABLE
				LEFT JOIN
					CO_Regulador	R (NOLOCK)
					ON	E.IdRegulador	=	R.IdRegulador
				LEFT JOIN
					EN_Actividad	ELAB (NOLOCK)
					ON	CE.IdContratoEntregable	=	ELAB.IdContratoEntregable
					AND ELAB.EstadoID	=	10000
					and elab.Activo = 1
				LEFT JOIN
					AP_Usuario	UELAB (NOLOCK)
					ON	ELAB.idUsuario	=	UELAB.UsuarioID
				LEFT JOIN
					EN_Actividad	REVI (NOLOCK)
					ON	CE.IdContratoEntregable	=	REVI.IdContratoEntregable
					AND REVI.EstadoID	=	10001
				LEFT JOIN
					AP_Usuario	UREVI (NOLOCK)
					ON	REVI.idUsuario	=	UREVI.UsuarioID
				LEFT JOIN
					EN_Actividad	APRO (NOLOCK)
					ON	CE.IdContratoEntregable	=	APRO.IdContratoEntregable
					AND APRO.EstadoID	=	10002
				LEFT JOIN
					AP_Usuario	UAPRO (NOLOCK)
					ON	APRO.idUsuario	=	UAPRO.UsuarioID
				LEFT JOIN
					EN_Area	A (NOLOCK)
					ON	CE.IdContrato = A.idContrato
					AND CE.IdArea	=	A.idArea
				LEFT JOIN 
					EN_ETAPA ET (NOLOCK)
					ON E.IdEtapa = ET.IdEtapa
				WHERE	isnull(e.IsActivo,0) = 1 
				AND		((ML.IdMarcoLegal = CAST(@DATO AS INT)) or CAST(@DATO AS INT) = -1)
				ORDER BY
					CE.IdContratoEntregable DESC

		END

		-- SHELL
		IF @IdContrato IN (10101,10103,10104,10106,10107,10112,10113,10115,10118,10131, 10151, 10152) 
		BEGIN
			SELECT	DISTINCT 
			--TOP 20
			CE.IDCONTRATOENTREGABLE,
			E.CONSECUTIVO, 
			E.DOCUMENTOENTREGABLE, 
			isnull(ML.MarcoLegal,'') as MarcoLegal,
			FE.FrecuenciaEntregable as Frecuencia , --
			RE.ReceptorEntregable,
			ISNULL(A.NombreArea,'') AS Funcion, 
			ISNULL(CE.Subfuncion,'') AS Subfuncion,
			ISNULL(CE.DiasAlerta,'') AS 'Dias Alerta',
			ISNULL(CE.DiasElaboracion,'') AS 'Dias Elaboracion', 
			CASE WHEN CE.ACTIVO = 1 THEN 'SI' ELSE 'NO' END AS 'Activo',
			ISNULL(UELAB.NOMBRE,'') AS 'Elaborador', 
			ISNULL(CE.FocalPoint,'') AS FocalPoint,
			ISNULL(CE.Accountable,'') as Accountable,
			ISNULL(CE.AccountableCompliance,'') as AccountableCompliance
			FROM EN_ContratoEntregable	CE	(NOLOCK)
			JOIN EN_Entregable	E	(NOLOCK)
				ON	CE.IDENTREGABLE = E.IDENTREGABLE
				AND ISNULL(E.BitJOA,0) = 0
				AND E.IsActivo = 1
				AND CE.Activo = 1
			JOIN
				CO_Contrato	C	(NOLOCK)
				ON CE.IdContrato	=	C.IdContrato
				AND ( C.DescripcionContrato LIKE '%SHELL%' OR C.DescripcionContrato = 'Seguimiento Planes de Acción' OR C.DescripcionContrato = 'Purple Angel' )
			JOIN
				EN_EntregableRonda	ER	(NOLOCK)
				ON	E.IdEntregable	=	ER.idEntregable
				AND	C.IdRonda	=	ER.idRonda
			LEFT JOIN
				EN_FrecuenciaEntregable	FE	(NOLOCK)
				ON	E.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
			LEFT JOIN
				EN_MarcoLegal	ML	(NOLOCK)
				ON	E.IdMarcoLegal = ML.IdMarcoLegal
			LEFT JOIN
				CO_Regulador	R	(NOLOCK)
				ON	E.IdRegulador	=	R.IdRegulador
			LEFT JOIN
				EN_AREA	A	(NOLOCK)
				ON	CE.IDAREA = A.IDAREA
			LEFT JOIN
				EN_Actividad	ELAB
				ON	CE.IdContratoEntregable	=	ELAB.IdContratoEntregable
				AND ELAB.EstadoID	=	10000
			LEFT JOIN
				AP_Usuario	UELAB
				ON	ELAB.idUsuario	=	UELAB.UsuarioID
			LEFT JOIN
				EN_RecepTorEntregable RE	(NOLOCK)
				ON E.IDRECEPTORENTREGABLE = RE.IDRECEPTORENTREGABLE
			WHERE
			ISNULL(e.IsActivo,0) = 1 
			AND ((ML.IdMarcoLegal = CAST(@DATO AS INT)) or CAST(@DATO AS INT) = -1)
			AND CE.IdContrato = @IdContrato
			GROUP BY
			CE.IDCONTRATOENTREGABLE,
				FE.FrecuenciaEntregable, R.Regulador, ML.MarcoLegal, replace(replace(E.ARTICULO,char(3),''), CHAR(10),''), E.DOCUMENTOENTREGABLE, E.CONSECUTIVO, 
			CASE WHEN CE.ACTIVO = 1 THEN 'SI' ELSE 'NO' END,
			ISNULL(A.NombreArea,''), 
			ISNULL(CE.Subfuncion,''),
			ISNULL(UELAB.NOMBRE,''), 
			ISNULL(CE.Accountable,''),
			ISNULL(CE.FocalPoint,''),
			ISNULL(CE.AccountableCompliance,''),
			ISNULL(CE.DiasElaboracion,''), 
			ISNULL(CE.DiasAlerta,''),
			E.TiempoEntrega, 
			ISNULL(CE.ReceptorAlerta,''),
			RE.ReceptorEntregable
			--ORDER BY
			--	ML.MarcoLegal,
			--	E.Consecutivo,
			--	ISNULL(A.NombreArea,'')
		END
	END

	IF @FILTRO = 'AR'
	BEGIN

		IF @IdContrato IN (3,10039,10047,10048,10049,10050,10054,10055,10056,10057,10058)--Eni. Equinor, Murphy, Carso, Smart (México)
		BEGIN

			SELECT	DISTINCT 
			--TOP 20
				CE.IdContratoEntregable,
				E.CONSECUTIVO, 
				E.DOCUMENTOENTREGABLE,
				isnull(ML.MarcoLegal,'') as MarcoLegal,
				FE.FrecuenciaEntregable, 
				ISNULL(RE.ReceptorEntregable,'') AS Receptor,
				ISNULL(A.NombreArea,'') AS AreaResponsable,
				ISNULL(CE.DiasAlerta,'') AS 'Dias Alerta Previa',
				ISNULL(CE.DiasElaboracion,'') AS 'Dias para elaborar/Days to elaborate ',
				ISNULL(CE.DiasRevision,'') AS 'Dias para Revisar/Days to review', 
				ISNULL(CE.DiasAprobacion,'') AS 'Dias para Aprobar/Days to Approve', 
				CASE WHEN ISNULL(CE.ACTIVO,0) = 1 THEN 'SI' ELSE 'NO' END AS 'Activo',
				ISNULL(UELAB.NOMBRE,'') AS 'Elaborador/Doer',
				dbo.fnGetRevisoresEntregable (CE.IdContratoEntregable)	AS 'Revisor(es)/Reviewer',
				ISNULL(UAPRO.NOMBRE,'') AS 'Aprobador/Approver',
				ISNULL(CE.ReceptorAlerta,'') AS 'Receptor Alerta'
				FROM 
					CO_Contrato	C (NOLOCK)
				JOIN
					EN_ContratoEntregable	CE (NOLOCK)
					ON C.IdContrato	=	CE.IdContrato
					AND	C.IdContrato  = @IdContrato
				JOIN
					EN_Entregable	E (NOLOCK)
					ON	CE.IDENTREGABLE = E.IDENTREGABLE
					and isnull(e.IsActivo,0) = 1
				JOIN
					EN_EntregableRonda	ER (NOLOCK)
					ON	E.IdEntregable	=	ER.idEntregable
					AND	C.IdRonda	=	ER.idRonda
				LEFT JOIN
					EN_FrecuenciaEntregable	FE (NOLOCK)
					ON	E.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
				LEFT JOIN
					EN_MarcoLegal	ML (NOLOCK)
					ON	E.IdMarcoLegal = ML.IdMarcoLegal
				LEFT JOIN EN_RESPONSABLEGENERADOR RG	(NOLOCK)
					ON E.IdResponsableGenerador = RG.IdResponsableGenerador
				LEFT JOIN
					EN_RecepTorEntregable RE	(NOLOCK)
					ON E.IDRECEPTORENTREGABLE = RE.IDRECEPTORENTREGABLE
				LEFT JOIN
					CO_Regulador	R (NOLOCK)
					ON	E.IdRegulador	=	R.IdRegulador
				LEFT JOIN
					EN_Actividad	ELAB (NOLOCK)
					ON	CE.IdContratoEntregable	=	ELAB.IdContratoEntregable
					AND ELAB.EstadoID	=	10000
					and elab.Activo = 1
				LEFT JOIN
					AP_Usuario	UELAB (NOLOCK)
					ON	ELAB.idUsuario	=	UELAB.UsuarioID
				LEFT JOIN
					EN_Actividad	REVI (NOLOCK)
					ON	CE.IdContratoEntregable	=	REVI.IdContratoEntregable
					AND REVI.EstadoID	=	10001
				LEFT JOIN
					AP_Usuario	UREVI (NOLOCK)
					ON	REVI.idUsuario	=	UREVI.UsuarioID
				LEFT JOIN
					EN_Actividad	APRO (NOLOCK)
					ON	CE.IdContratoEntregable	=	APRO.IdContratoEntregable
					AND APRO.EstadoID	=	10002
				LEFT JOIN
					AP_Usuario	UAPRO (NOLOCK)
					ON	APRO.idUsuario	=	UAPRO.UsuarioID
				LEFT JOIN
					EN_Area	A (NOLOCK)
					ON	CE.IdContrato = A.idContrato
					AND CE.IdArea	=	A.idArea
				LEFT JOIN 
					EN_ETAPA ET (NOLOCK)
					ON E.IdEtapa = ET.IdEtapa
				WHERE
					isnull(e.IsActivo,0) = 1
					AND ((A.idArea = CAST(@DATO AS INT)) or CAST(@DATO AS INT) = -1)
				ORDER BY
					CE.IdContratoEntregable DESC

		END

		IF @IdContrato IN (10093,10108,10110,10119,10120,10122)--REPSOL
		BEGIN
		
		SELECT	DISTINCT 
		--TOP 20
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
				AND ((A.idArea = CAST(@DATO AS INT)) or CAST(@DATO AS INT) = -1)
				 --AND C.DescripcionContrato LIKE '%REPSOL%'
				and ce.activo = 1
			ORDER BY
				ML.MarcoLegal,
				E.Consecutivo
			END

		-- SHELL
		IF @IdContrato IN (10101,10103,10104,10106,10107,10112,10113,10115,10118,10131,10151, 10152) 
		BEGIN
			SELECT	DISTINCT 
			--TOP 20
			CE.IDCONTRATOENTREGABLE,
			E.CONSECUTIVO, 
			E.DOCUMENTOENTREGABLE, 
			isnull(ML.MarcoLegal,'') as MarcoLegal,
			FE.FrecuenciaEntregable as Frecuencia , --
			RE.ReceptorEntregable,
			ISNULL(A.NombreArea,'') AS Funcion, 
			ISNULL(CE.Subfuncion,'') AS Subfuncion,
			ISNULL(CE.DiasAlerta,'') AS 'Dias Alerta',
			ISNULL(CE.DiasElaboracion,'') AS 'Dias Elaboracion', 
			CASE WHEN CE.ACTIVO = 1 THEN 'SI' ELSE 'NO' END AS 'Activo',
			ISNULL(UELAB.NOMBRE,'') AS 'Elaborador', 
			ISNULL(CE.FocalPoint,'') AS FocalPoint,
			ISNULL(CE.Accountable,'') as Accountable,
			ISNULL(CE.AccountableCompliance,'') as AccountableCompliance
			FROM EN_ContratoEntregable	CE	(NOLOCK)
			JOIN EN_Entregable	E	(NOLOCK)
				ON	CE.IDENTREGABLE = E.IDENTREGABLE
				AND ISNULL(E.BitJOA,0) = 0
				AND E.IsActivo = 1
				AND CE.Activo = 1
			JOIN
				CO_Contrato	C	(NOLOCK)
				ON CE.IdContrato	=	C.IdContrato
				AND ( C.DescripcionContrato LIKE '%SHELL%' OR C.DescripcionContrato = 'Seguimiento Planes de Acción' OR C.DescripcionContrato = 'Purple Angel')
			JOIN
				EN_EntregableRonda	ER	(NOLOCK)
				ON	E.IdEntregable	=	ER.idEntregable
				AND	C.IdRonda	=	ER.idRonda
			LEFT JOIN
				EN_FrecuenciaEntregable	FE	(NOLOCK)
				ON	E.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
			LEFT JOIN
				EN_MarcoLegal	ML	(NOLOCK)
				ON	E.IdMarcoLegal = ML.IdMarcoLegal
			LEFT JOIN
				CO_Regulador	R	(NOLOCK)
				ON	E.IdRegulador	=	R.IdRegulador
			LEFT JOIN
				EN_AREA	A	(NOLOCK)
				ON	CE.IDAREA = A.IDAREA
			LEFT JOIN
				EN_Actividad	ELAB
				ON	CE.IdContratoEntregable	=	ELAB.IdContratoEntregable
				AND ELAB.EstadoID	=	10000
			LEFT JOIN
				AP_Usuario	UELAB
				ON	ELAB.idUsuario	=	UELAB.UsuarioID
			LEFT JOIN
				EN_RecepTorEntregable RE	(NOLOCK)
				ON E.IDRECEPTORENTREGABLE = RE.IDRECEPTORENTREGABLE
			WHERE
			isnull(e.IsActivo,0) = 1
				AND CE.IdContrato = @IdContrato
				AND ((A.idArea = CAST(@DATO AS INT)) or CAST(@DATO AS INT) = -1)
				and ce.activo = 1
			GROUP BY
			CE.IDCONTRATOENTREGABLE,
				FE.FrecuenciaEntregable, R.Regulador, ML.MarcoLegal, replace(replace(E.ARTICULO,char(3),''), CHAR(10),''), E.DOCUMENTOENTREGABLE, E.CONSECUTIVO, 
			CASE WHEN CE.ACTIVO = 1 THEN 'SI' ELSE 'NO' END,
			ISNULL(A.NombreArea,''), 
			ISNULL(CE.Subfuncion,''),
			ISNULL(UELAB.NOMBRE,''), 
			ISNULL(CE.Accountable,''),
			ISNULL(CE.FocalPoint,''),
			ISNULL(CE.AccountableCompliance,''),
			ISNULL(CE.DiasElaboracion,''), 
			ISNULL(CE.DiasAlerta,''),
			E.TiempoEntrega, 
			ISNULL(CE.ReceptorAlerta,''),
			RE.ReceptorEntregable
			--ORDER BY
			--	ML.MarcoLegal,
			--	E.Consecutivo,
			--	ISNULL(A.NombreArea,'')
		END
	END

	IF @FILTRO = 'E'
	BEGIN

		IF @IdContrato IN (3,10039,10047,10048,10049,10050,10054,10055,10056,10057,10058)--Eni. Equinor, Murphy, Carso, Smart (México)
		BEGIN

			SELECT	DISTINCT 
			--TOP 20
				CE.IdContratoEntregable,
				E.CONSECUTIVO, 
				E.DOCUMENTOENTREGABLE,
				isnull(ML.MarcoLegal,'') as MarcoLegal,
				FE.FrecuenciaEntregable, 
				ISNULL(RE.ReceptorEntregable,'') AS Receptor,
				ISNULL(A.NombreArea,'') AS AreaResponsable,
				ISNULL(CE.DiasAlerta,'') AS 'Dias Alerta Previa',
				ISNULL(CE.DiasElaboracion,'') AS 'Dias para elaborar/Days to elaborate ',
				ISNULL(CE.DiasRevision,'') AS 'Dias para Revisar/Days to review', 
				ISNULL(CE.DiasAprobacion,'') AS 'Dias para Aprobar/Days to Approve', 
				CASE WHEN ISNULL(CE.ACTIVO,0) = 1 THEN 'SI' ELSE 'NO' END AS 'Activo',
				ISNULL(UELAB.NOMBRE,'') AS 'Elaborador/Doer',
				dbo.fnGetRevisoresEntregable (CE.IdContratoEntregable)	AS 'Revisor(es)/Reviewer',
				ISNULL(UAPRO.NOMBRE,'') AS 'Aprobador/Approver',
				ISNULL(CE.ReceptorAlerta,'') AS 'Receptor Alerta'
				FROM 
					CO_Contrato	C (NOLOCK)
				JOIN
					EN_ContratoEntregable	CE (NOLOCK)
					ON C.IdContrato	=	CE.IdContrato
					AND	C.IdContrato  = @IdContrato
				JOIN
					EN_Entregable	E (NOLOCK)
					ON	CE.IDENTREGABLE = E.IDENTREGABLE
					and isnull(e.IsActivo,0) = 1
				JOIN
					EN_EntregableRonda	ER (NOLOCK)
					ON	E.IdEntregable	=	ER.idEntregable
					AND	C.IdRonda	=	ER.idRonda
				LEFT JOIN
					EN_FrecuenciaEntregable	FE (NOLOCK)
					ON	E.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
				LEFT JOIN
					EN_MarcoLegal	ML (NOLOCK)
					ON	E.IdMarcoLegal = ML.IdMarcoLegal
				LEFT JOIN EN_RESPONSABLEGENERADOR RG	(NOLOCK)
					ON E.IdResponsableGenerador = RG.IdResponsableGenerador
				LEFT JOIN
					EN_RecepTorEntregable RE	(NOLOCK)
					ON E.IDRECEPTORENTREGABLE = RE.IDRECEPTORENTREGABLE
				LEFT JOIN
					CO_Regulador	R (NOLOCK)
					ON	E.IdRegulador	=	R.IdRegulador
				LEFT JOIN
					EN_Actividad	ELAB (NOLOCK)
					ON	CE.IdContratoEntregable	=	ELAB.IdContratoEntregable
					AND ELAB.EstadoID	=	10000
					and elab.Activo = 1
				LEFT JOIN
					AP_Usuario	UELAB (NOLOCK)
					ON	ELAB.idUsuario	=	UELAB.UsuarioID
				LEFT JOIN
					EN_Actividad	REVI (NOLOCK)
					ON	CE.IdContratoEntregable	=	REVI.IdContratoEntregable
					AND REVI.EstadoID	=	10001
				LEFT JOIN
					AP_Usuario	UREVI (NOLOCK)
					ON	REVI.idUsuario	=	UREVI.UsuarioID
				LEFT JOIN
					EN_Actividad	APRO (NOLOCK)
					ON	CE.IdContratoEntregable	=	APRO.IdContratoEntregable
					AND APRO.EstadoID	=	10002
				LEFT JOIN
					AP_Usuario	UAPRO (NOLOCK)
					ON	APRO.idUsuario	=	UAPRO.UsuarioID
				LEFT JOIN
					EN_Area	A (NOLOCK)
					ON	CE.IdContrato = A.idContrato
					AND CE.IdArea	=	A.idArea
				LEFT JOIN 
					EN_ETAPA ET (NOLOCK)
					ON E.IdEtapa = ET.IdEtapa
				WHERE
					isnull(e.IsActivo,0) = 1
					AND ((UELAB.UsuarioID = CAST(@DATO AS INT)) or CAST(@DATO AS INT) = -1)
				ORDER BY
					CE.IdContratoEntregable DESC

		END


		IF @IdContrato IN (10093,10108,10110,10119,10120,10122)--REPSOL
		BEGIN
		SELECT	DISTINCT 
		--TOP 20
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
				AND ((UELAB.UsuarioID = CAST(@DATO AS INT)) or CAST(@DATO AS INT) = -1 )
				 --AND C.DescripcionContrato LIKE '%REPSOL%'
				and ce.activo = 1
			ORDER BY
				ML.MarcoLegal,
				E.Consecutivo
			END

		-- SHELL
		IF @IdContrato IN (10101,10103,10104,10106,10107,10112,10113,10115,10118,10131,10151, 10152) 
		BEGIN
			SELECT	DISTINCT 
			--TOP 20
			CE.IDCONTRATOENTREGABLE,
			E.CONSECUTIVO, 
			E.DOCUMENTOENTREGABLE, 
			isnull(ML.MarcoLegal,'') as MarcoLegal,
			FE.FrecuenciaEntregable as Frecuencia , --
			RE.ReceptorEntregable,
			ISNULL(A.NombreArea,'') AS Funcion, 
			ISNULL(CE.Subfuncion,'') AS Subfuncion,
			ISNULL(CE.DiasAlerta,'') AS 'Dias Alerta',
			ISNULL(CE.DiasElaboracion,'') AS 'Dias Elaboracion', 
			CASE WHEN CE.ACTIVO = 1 THEN 'SI' ELSE 'NO' END AS 'Activo',
			ISNULL(UELAB.NOMBRE,'') AS 'Elaborador', 
			ISNULL(CE.FocalPoint,'') AS FocalPoint,
			ISNULL(CE.Accountable,'') as Accountable,
			ISNULL(CE.AccountableCompliance,'') as AccountableCompliance
			FROM EN_ContratoEntregable	CE	(NOLOCK)
			JOIN EN_Entregable	E	(NOLOCK)
				ON	CE.IDENTREGABLE = E.IDENTREGABLE
				AND ISNULL(E.BitJOA,0) = 0
				AND E.IsActivo = 1
				AND CE.Activo = 1
			JOIN
				CO_Contrato	C	(NOLOCK)
				ON CE.IdContrato	=	C.IdContrato
				AND ( C.DescripcionContrato LIKE '%SHELL%' OR C.DescripcionContrato = 'Seguimiento Planes de Acción' OR C.DescripcionContrato = 'Purple Angel')
			JOIN
				EN_EntregableRonda	ER	(NOLOCK)
				ON	E.IdEntregable	=	ER.idEntregable
				AND	C.IdRonda	=	ER.idRonda
			LEFT JOIN
				EN_FrecuenciaEntregable	FE	(NOLOCK)
				ON	E.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
			LEFT JOIN
				EN_MarcoLegal	ML	(NOLOCK)
				ON	E.IdMarcoLegal = ML.IdMarcoLegal
			LEFT JOIN
				CO_Regulador	R	(NOLOCK)
				ON	E.IdRegulador	=	R.IdRegulador
			LEFT JOIN
				EN_AREA	A	(NOLOCK)
				ON	CE.IDAREA = A.IDAREA
			LEFT JOIN
				EN_Actividad	ELAB
				ON	CE.IdContratoEntregable	=	ELAB.IdContratoEntregable
				AND ELAB.EstadoID	=	10000
			LEFT JOIN
				AP_Usuario	UELAB
				ON	ELAB.idUsuario	=	UELAB.UsuarioID
			LEFT JOIN
				EN_RecepTorEntregable RE	(NOLOCK)
				ON E.IDRECEPTORENTREGABLE = RE.IDRECEPTORENTREGABLE
			WHERE
			isnull(e.IsActivo,0) = 1
				AND CE.IdContrato = @IdContrato
				AND ((UELAB.UsuarioID = CAST(@DATO AS INT)) or CAST(@DATO AS INT) = -1 )
				and ce.activo = 1
			GROUP BY
			CE.IDCONTRATOENTREGABLE,
				FE.FrecuenciaEntregable, R.Regulador, ML.MarcoLegal, replace(replace(E.ARTICULO,char(3),''), CHAR(10),''), E.DOCUMENTOENTREGABLE, E.CONSECUTIVO, 
			CASE WHEN CE.ACTIVO = 1 THEN 'SI' ELSE 'NO' END,
			ISNULL(A.NombreArea,''), 
			ISNULL(CE.Subfuncion,''),
			ISNULL(UELAB.NOMBRE,''), 
			ISNULL(CE.Accountable,''),
			ISNULL(CE.FocalPoint,''),
			ISNULL(CE.AccountableCompliance,''),
			ISNULL(CE.DiasElaboracion,''), 
			ISNULL(CE.DiasAlerta,''),
			E.TiempoEntrega, 
			ISNULL(CE.ReceptorAlerta,''),
			RE.ReceptorEntregable
		END
	END
END
