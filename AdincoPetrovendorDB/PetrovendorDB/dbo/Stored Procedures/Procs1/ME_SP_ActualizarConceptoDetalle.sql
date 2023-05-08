
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <07-03-2018>
-- Description:	<Actualizacion del detalle de conceptos>
-- =============================================

CREATE procedure ME_SP_ActualizarConceptoDetalle
	@IdConceptoDetalle INT,
	@Detalle VARCHAR(200),
	@Puntos FLOAT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	UPDATE dbo.ME_EG_ConceptosDetalle
	SET Detalle = @Detalle,
		Puntos = @Puntos
	WHERE IdConceptoDetalle = @IdConceptoDetalle
END
