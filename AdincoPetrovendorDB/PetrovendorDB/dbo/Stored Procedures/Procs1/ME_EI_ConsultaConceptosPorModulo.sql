-- =============================================
-- Author:		<Jose Roman>
-- Create date: <30-07-2018>
-- Description:	<Se consultan los conceptos por modulo>
-- =============================================

CREATE PROCEDURE ME_EI_ConsultaConceptosPorModulo
	@IdModulo INT,	
	@IdProveedor INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT c.IdConcepto,
			c.Concepto,
			m.URL_MODULO AS ConceptoURL
	FROM dbo.EI_Conceptos c
		INNER JOIN dbo.Modulo m ON m.IdModulo = c.IdConceptoURL
	WHERE c.IdModulo = @IdModulo
END