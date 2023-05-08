-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <02/09/2021>
-- Description:	<Consulta General de entregables internos>
-- =============================================
CREATE PROCEDURE [dbo].[EN_General_EntregablesInternos] --0
	-- Add the parameters for the stored procedure here
	@idUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
				E.IdEntregable,
				CE.IdContratoEntregable,
				E.DocumentoEntregable AS NombreEntregable,
				ISNULL(ML.MarcoLegal,'') AS MarcoLegal,
				E.Consecutivo,
				CON.NumeroContrato + ' - ' + AC.NombreAreaContractual AS Contrato,
				CI.RazonSocial AS Contratista,
				IsActivo = cast(isnull(E.IsActivo,0) as bit),
				AR.NombreArea AS Area,
				U.Nombre AS Elaborador,
				ISNULL(CE.BitMostrarLineaTiempo,0) AS MostrarLineaTiempo,
				ISNULL(CE.BitNA,0) AS NA,
				ISNULL(CE.BitCortoPlazo,0) AS CortoPlazo,
				ISNULL(CE.BitMedianoPlazo,0) AS MedianoPlazo,
				ISNULL(CE.BitLargoPlazo,0) AS LargoPlazo
		FROM	EN_Entregable  E
		JOIN	EN_ContratoEntregable CE
			ON	E.IdEntregable	=	CE.IdEntregable
			--AND CE.IdContrato	=	@idContrato
			--AND	E.BitInterno	=	1 
			--AND CE.IdContrato	=	@idContrato
			AND E.IsActivo	=	1
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
		JOIN CO_Contrato AS CON
			ON CE.IdContrato = CON.IdContrato
		JOIN CO_AreaContractual AS AC
			ON CON.IdAreaContractual = AC.IdAreaContractual
		JOIN CO_Contratista AS CI
			ON CON.IdContratista = CI.IdContratista
		JOIN EN_Area AS AR
			ON CE.IdArea = AR.idArea
		ORDER BY IdEntregable DESC
END