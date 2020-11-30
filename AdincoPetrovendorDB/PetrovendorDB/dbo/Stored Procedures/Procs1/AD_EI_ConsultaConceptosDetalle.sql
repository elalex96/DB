
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <31-07-2018>
-- Description:	<Se consulta los detalles de los conceptos>
-- =============================================

CREATE PROCEDURE AD_EI_ConsultaConceptosDetalle	
	@IdConcepto INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT IdConceptoDetalle,
		 Detalle,
         Puntos,
         SoloMoral
	FROM dbo.EI_ConceptosDetalle
	WHERE IdConcepto = @IdConcepto
END