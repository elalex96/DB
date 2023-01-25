--==============================================
-- Creado Por:	Pedro Pouchoulen
-- Fecha:		25-Enero-2023
-- Detalle:		Se Valida que el monto no exceda el monto del comprobante
-- Url:			donde se ocupa /2/RegistroCostos/RegistrarGasto.aspx
--==============================================
CREATE PROCEDURE VAL_MontoComprobanteExtranjero
    @MontoRegistro Money,
	@IdPedimentoComprobante INT
AS
BEGIN
	DECLARE @MontoComprobante Money,
			@MontoRegistroActual Money,
			@MontoTotal Money

	SELECT @MontoComprobante = ISNULL(SUM(ImporteTotal), 0) 
	FROM FI_PedimentoComprobanteDetalle WHERE IdPedimentoComprobante = @IdPedimentoComprobante

	SELECT @MontoRegistroActual = ISNULL(SUM(MontoRegistro), 0) 
	FROM CO_Registro WHERE IdPedimentoComprobante = @IdPedimentoComprobante

	SELECT  @MontoTotal = ISNULL(@MontoRegistro, 0) + ISNULL(@MontoRegistroActual, 0)
	
	IF(@MontoTotal > @MontoComprobante)
	BEGIN
		SELECT 'No es posible registrar el gasto ya que se excedería el total del comprobante extranjero. Solo se puede capturar hasta $ ' + 
					CAST((ISNULL(@MontoComprobante, 0) - ISNULL(@MontoRegistroActual, 0)) AS VARCHAR) + ' en el monto'
	END

	SELECT ''
END



