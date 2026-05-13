
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <07-03-2018>
-- Description:	<Consulta del detalle de los conceptos>
-- =============================================

CREATE procedure ME_SP_ConsultaConceptosDetalle
	@IdConcepto INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT IdConceptoDetalle, Detalle, Puntos
	FROM dbo.ME_EG_ConceptosDetalle
	WHERE IdConcepto = @IdConcepto
END

