
DROP PROCEDURE IF EXISTS PR_MM_SP_ConsultarTerminosyCondiciones
GO
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <26-07-2019>
-- Description:	<Se agrego la funcion de mostrar los TC cuando se crea la operacion>
-- =============================================
-- Author:		<LUIS DAVID>
-- Create date: <01/11/2021>
-- Description:	<OPTIMIZACIÓN SP>
-- =============================================
CREATE PROCEDURE [dbo].[PR_MM_SP_ConsultarTerminosyCondiciones]
	@IdDocumento int
AS
BEGIN
	
	--SELECT Nombre,Documento
	--	FROM dbo.TC_TerminosYCondicionesDocV2
	--	WHERE IdTerminosYCondiciones=  @IdDocumento;
		
	SELECT
		TC.Nombre,
		ISNULL(TCO.TerminosCondicionesTexto,TC.Documento)
	FROM dbo.TA_TerminosCondicionesOperacion AS TCO
	LEFT JOIN dbo.TC_TerminosYCondicionesDocV2 AS TC 
		ON TCO.IdTerminosYCondiciones = TC.IdTerminosYCondiciones
	WHERE TCO.IdOperacion = @IdDocumento;	
	
END
