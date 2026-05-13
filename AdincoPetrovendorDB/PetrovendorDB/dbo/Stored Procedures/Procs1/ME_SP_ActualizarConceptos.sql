
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <07-03-2018>
-- Description:	<Actualizar conceptos>
-- =============================================

CREATE procedure ME_SP_ActualizarConceptos
	@IdConcepto INT,
	@Concepto VARCHAR(200),
	@IdModulo INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	UPDATE dbo.ME_EG_Conceptos
	SET Concepto = @Concepto,
		IdModulo = @IdModulo
	WHERE IdConcepto = @IdConcepto
END
