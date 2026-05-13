-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <26-07-2019>
-- Description:	<Se agrego la funcion de mostrar los TC cuando se crea la operacion>
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[PR_MM_SP_ConsultarTerminosyCondiciones]
	@IdDocumento int
AS
BEGIN
			
	SELECT
		TC.Nombre,
		ISNULL(TCO.TerminosCondicionesTexto,TC.Documento)
	FROM dbo.TA_TerminosCondicionesOperacion AS TCO (NOLOCK)
	LEFT JOIN dbo.TC_TerminosYCondicionesDocV2 AS TC  (NOLOCK)
		ON TCO.IdTerminosYCondiciones = TC.IdTerminosYCondiciones
	WHERE TCO.IdOperacion = @IdDocumento;	
	
END