
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <26-07-2019>
-- Description:	<Se agrego la funcion de mostrar los TC cuando se crea la operacion>
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
		ON TC.IdTerminosYCondiciones = TCO.IdTerminosYCondiciones
	WHERE TCO.IdOperacion = @IdDocumento;	
	
END
