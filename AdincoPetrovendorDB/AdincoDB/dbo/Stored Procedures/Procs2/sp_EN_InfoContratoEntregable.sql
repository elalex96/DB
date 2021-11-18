
DROP PROCEDURE IF EXISTS sp_EN_InfoContratoEntregable
GO
create PROCEDURE [dbo].[sp_EN_InfoContratoEntregable] --3,10641,10061 -- 10146, 20513,10082
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
-- =============================================
-- Author:      Luis David
-- Create date: 17/11/2021
-- Description: Se agrega el bitawareness para issue Adinco/adinco-entregables/issues/473
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
				idArea						=	CE.idArea,
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
				UsuarioElaborador			=	Ae.idUsuario,
				UsuarioAprobador			=	AP.idUsuario,
				BitInterno					=	EN.BitInterno,
				Subfuncion,
				FocalPoint,
				AccountableCompliance,
				Accountable,
				ContieneInformacionSensible							=		ISNULL(ContieneInformacionSensible,0),
				BitAwareness				=	ISNULL(EN.BitAwareness,0)
	FROM		EN_ContratoEntregable								CE
	JOIN		EN_Entregable										EN
	ON			CE.IdEntregable										=		EN.IdEntregable  
	AND			CE.IdContrato										=		@IdContrato
	AND			EN.BITJOA											=		0
	LEFT JOIN	dbo.EN_Actividad									AE
	ON			CE.IdContratoEntregable								=		AE.IdContratoEntregable 
	AND			AE.EstadoID											=		10000
	LEFT JOIN	dbo.EN_Actividad									AP 
	ON			CE.IdContratoEntregable								=		AP.IdContratoEntregable  
	AND			AP.EstadoID											=		10002
	LEFT JOIN	[EN_FrecuenciaEntregable]							FE
	ON			EN.IdFrecuenciaEntregable							=		FE.IdFrecuenciaEntregable
	LEFT JOIN	EN_MarcoLegal										ML
	ON			EN.IdMarcoLegal										=		ML.IdMarcoLegal
	left join	EN_ContratoEntregableProgramaImplementaAcciones		cepia
	on			cepia.IdContratoEntregable							=		ce.IdContratoEntregable
	left join	CO_Contrato											c
	on			c.IdContrato										=		ce.IdContrato
	left join	CO_Contratista										co
	on			co.IdContratista									=		c.IdContratista
	and			co.NombreContratista								like	'%Shell%'
	WHERE		CE.IdContratoEntregable								=		@idContratoEntregable
END;
