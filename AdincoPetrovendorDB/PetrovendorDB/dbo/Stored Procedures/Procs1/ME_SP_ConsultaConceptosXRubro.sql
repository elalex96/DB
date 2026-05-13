
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <07-03-2018>
-- Description:	<Consulta de los conceptos por rubro>
-- =============================================

CREATE procedure ME_SP_ConsultaConceptosXRubro
	@IdRubro INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT IdConcepto, Concepto, IdModulo
	FROM dbo.ME_EG_Conceptos
	WHERE IdRubro = @IdRubro
END
