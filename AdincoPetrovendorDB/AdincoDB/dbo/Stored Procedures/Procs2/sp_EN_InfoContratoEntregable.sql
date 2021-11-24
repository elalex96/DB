CREATE PROCEDURE [dbo].[sp_EN_InfoContratoEntregable] --3,10641,10061 -- 10146, 20513,10082
(
    @IdContrato				INT,
	@idContratoEntregable	INT,
    @IdUsuario				INT
)
AS
BEGIN
-- =============================================
-- Author:      Reyna Olvera
-- Create date: 
-- Description: 
-- ----------------------------------------------
-- 20211123	BAAC	Se ponen isnull en algunos campos que estaban marcando error en la pantalla
-- =============================================
	SET NOCOUNT ON;
	SELECT
				IsSasisopa					=	case when cepia.IdContratoEntregable is not null then cast(1 as bit) else cast(0 as bit) end,
				IsShell						=	case when co.NombreContratista like '%shell%' then cast(1 as bit) else cast(0 as bit) end,
				CE.IdContratoEntregable,
				CE.IdContrato,
				Frecuencia					=	ISNULL(FE.FrecuenciaEntregable, ''),
				Consecutivo					=	ISNULL(EN.Consecutivo, ''),
				MarcoLegal					=	ISNULL(ML.MarcoLegal, ''),
				CE.IdEntregable,
				idArea						=	ISNULL(CE.idArea,0),
				FechaLimiteEntrega			=	CE.FechaLimiteEntrega,
				DiasElaboracion				=	ISNULL(CE.DiasElaboracion, 0),
				DiasRevision				=	ISNULL(CE.DiasRevision, 0),
				DiasAprobacion				=	ISNULL(CE.DiasAprobacion, 0),
				DiasAlerta					=	ISNULL(CE.DiasAlerta, 0),
				ReceptorAlerta				=	ISNULL(CE.ReceptorAlerta, ''),
				CE.CreadoPor,
				CE.CreadoEl,
				CE.ModificadoPor,
				CE.ModificadoEl,
				CE.Activo,
				FechaLimiteEntregaRegulador	=	ISNULL(CE.FechaLimiteEntregaRegulador,CE.FechaLimiteEntrega),
				DocumentoEntregable			=	EN.DocumentoEntregable,
				UsuarioElaborador			=	ISNULL(Ae.idUsuario,0),
				UsuarioAprobador			=	ISNULL(AP.idUsuario,0),
				BitInterno					=	EN.BitInterno,
				Subfuncion,
				FocalPoint,
				AccountableCompliance,
				Accountable,
				ContieneInformacionSensible					=		ISNULL(ContieneInformacionSensible,0)
				BitAwareness			=	ISNULL(EN.BitAwareness,0)
	FROM
		EN_ContratoEntregable								CE	(NOLOCK)
	JOIN
		EN_Entregable										EN	(NOLOCK)
		ON			CE.IdEntregable							=		EN.IdEntregable  
		AND			CE.IdContrato							=		@IdContrato
		AND			EN.BITJOA								=		0
		AND			CE.IdContratoEntregable					=		@idContratoEntregable
	JOIN
		CO_Contrato											c	(NOLOCK)
		on			c.IdContrato							=		ce.IdContrato
	LEFT JOIN
		dbo.EN_Actividad									AE	(NOLOCK)
		ON			CE.IdContratoEntregable					=		AE.IdContratoEntregable 
		AND			AE.EstadoID								=		10000
	LEFT JOIN
		dbo.EN_Actividad									AP	(NOLOCK)
		ON			CE.IdContratoEntregable					=		AP.IdContratoEntregable  
		AND			AP.EstadoID								=		10002
	LEFT JOIN
		[EN_FrecuenciaEntregable]							FE	(NOLOCK)
		ON			EN.IdFrecuenciaEntregable				=		FE.IdFrecuenciaEntregable
	LEFT JOIN
		EN_MarcoLegal										ML	(NOLOCK)
		ON			EN.IdMarcoLegal							=		ML.IdMarcoLegal
	LEFT JOIN
		EN_ContratoEntregableProgramaImplementaAcciones		cepia	(NOLOCK)
		on			cepia.IdContratoEntregable				=		ce.IdContratoEntregable
	LEFT JOIN
		CO_Contratista										co		(NOLOCK)
		ON			co.IdContratista						=		c.IdContratista
		AND			co.NombreContratista					like	'%Shell%'
	WHERE		CE.IdContratoEntregable						=		@idContratoEntregable
END;
