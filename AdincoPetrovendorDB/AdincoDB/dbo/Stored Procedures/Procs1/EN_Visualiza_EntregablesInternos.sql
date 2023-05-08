CREATE PROCEDURE [dbo].[EN_Visualiza_EntregablesInternos]--0,10061,3,0
	@pIdEntregable INT,
    @idUsuario INT,
    @idContrato INT,
	@Activo INT
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 09/04/2018
-- Description:	Visualiza los entregables internos
-- =============================================
    SET NOCOUNT ON;

	IF(@pIdEntregable=0)
	BEGIN
		SELECT 
				FE.FrecuenciaEntregable,
				E.IdEntregable,
				E.DocumentoEntregable,
				E.Descripcion,
				E.IdFrecuenciaEntregable,
				U.Nombre AS CreadoPor,
				E.CreadoEn,
				IsActivo = cast(isnull(E.IsActivo,0) as bit),
				E.Consecutivo,
				R.NombreRegulador,
				R.IdRegulador,
				RE.IdReceptorEntregable,
				Re.ReceptorEntregable,
				CE.IdContratoEntregable,
				ISNULL(E.EsDeProceso,0) AS EsDeProceso,
				ISNULL(E.IdMarcoLegal,0) AS IdMarcoLegal,
				ISNULL(ML.MarcoLegal,'') AS MarcoLegal,
				ISNULL(E.Articulo,'') AS Articulo,
				ISNULL(E.Apartado,'') AS Apartado,
				ISNULL(E.Observaciones,'') AS Observaciones,
				ISNULL(E.TiempoEntrega,'') AS TiempoEntrega,
				ISNULL(E.Actividad,'') AS Actividad,
				E.IdResponsableGenerador,
				RG.ResponsableGenerador,
				R.Regulador,
				ISNULL(CE.Radar,0) AS Radar
		FROM	EN_Entregable  E

		JOIN	EN_ContratoEntregable CE
			ON	E.IdEntregable	=	CE.IdEntregable
			AND CE.IdContrato	=	@idContrato
			AND	E.BitInterno	=	1 
			AND CE.IdContrato	=	@idContrato
			AND E.IsActivo	=	@Activo
			AND E.BITJOA = 0

		JOIN	AP_Usuario U 
			ON E.CreadoPor	=	U.UsuarioID

		LEFT JOIN	EN_FrecuenciaEntregable FE
			ON	E.IdFrecuenciaEntregable	=	FE.IdFrecuenciaEntregable

		LEFT JOIN	CO_Regulador R 
			ON	E.IdRegulador	=	R.IdRegulador

		LEFT JOIN EN_ReceptorEntregable RE
			ON	E.IdReceptorEntregable	=	RE.IdReceptorEntregable

		LEFT JOIN EN_MarcoLegal ML
			ON	E.IdMarcoLegal	=	ML.IdMarcoLegal

		LEFT JOIN EN_ResponsableGenerador RG
			ON E.IdResponsableGenerador	= RG.IdResponsableGenerador
		ORDER BY IdEntregable DESC
    END
	ELSE
	BEGIN
		SELECT 
			FE.FrecuenciaEntregable,
			E.IdEntregable,
			E.DocumentoEntregable,
			E.Descripcion,
			E.IdFrecuenciaEntregable,
			U.Nombre AS CreadoPor,
			E.CreadoEn,
			IsActivo = cast(isnull(E.IsActivo,0) as bit),
			E.Consecutivo,
			R.NombreRegulador,
			R.IdRegulador,
			RE.IdReceptorEntregable,
			Re.ReceptorEntregable,
			CE.IdContratoEntregable,
			ISNULL(E.EsDeProceso,0) AS EsDeProceso,
			ISNULL(E.IdMarcoLegal,0) AS IdMarcoLegal,
			ISNULL(ML.MarcoLegal,'') AS MarcoLegal,
			ISNULL(E.Articulo,'') AS Articulo,
			ISNULL(E.Apartado,'') AS Apartado,
			ISNULL(E.Observaciones,'') AS Observaciones,
			ISNULL(E.TiempoEntrega,'') AS TiempoEntrega,
			ISNULL(E.Actividad,'') AS Actividad,
			E.IdResponsableGenerador,
			ISNULL(CE.Radar,0) AS Radar
	FROM	EN_Entregable  E

	JOIN	EN_ContratoEntregable CE
		ON	E.IdEntregable	=	CE.IdEntregable
		AND CE.IdContrato	=	@idContrato
		AND	E.IdEntregable	=	@pIdEntregable
		AND E.BITJOA = 0
		 
	JOIN	AP_Usuario U 
		ON E.CreadoPor	=	U.UsuarioID

	LEFT JOIN	EN_FrecuenciaEntregable FE
		ON	E.IdFrecuenciaEntregable	=	FE.IdFrecuenciaEntregable

	LEFT JOIN	CO_Regulador R 
		ON	E.IdRegulador	=	R.IdRegulador

	LEFT JOIN EN_ReceptorEntregable RE
		ON	E.IdReceptorEntregable	=	RE.IdReceptorEntregable

	LEFT JOIN EN_MarcoLegal ML
		ON	E.IdMarcoLegal	=	ML.IdMarcoLegal


	END
END;