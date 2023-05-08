
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <31-07-2018>
-- Description:	<Se consulta los conceptos por modulo para su modificacion>
-- =============================================

CREATE PROCEDURE AD_EI_ConsultaConceptosPorModulo	
	@IdModulo INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT IdConcepto,
			Concepto,
			IdConceptoURL
	FROM dbo.EI_Conceptos
	WHERE IdModulo = @IdModulo
END

