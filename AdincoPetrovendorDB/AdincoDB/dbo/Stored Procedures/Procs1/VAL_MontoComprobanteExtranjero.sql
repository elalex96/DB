--==============================================
-- Creado Por:	Pedro Pouchoulen
-- Fecha:		25-Enero-2023
-- Detalle:		Se Valida que el monto no exceda el monto del comprobante
-- Url:			donde se ocupa /2/RegistroCostos/RegistrarGasto.aspx
--==============================================
-- Creado Por:	Marcos Neri
-- Fecha:		21 de Marzo del 2023
-- Detalle:		Se agrega que valide el monto de el PE o PI,
-- de acuerdo al registro manejado durante la edición 
--============================================== 
CREATE PROCEDURE [dbo].[VAL_MontoComprobanteExtranjero] 
	@MontoRegistro MONEY,
	@IdPedimentoComprobante INT,
	@IdRegistro INT
AS
BEGIN
	DECLARE @MontoComprobante MONEY,
		@MontoTotalRegistros MONEY,
		@MontoRegistroActual MONEY,
		@MontoTotal MONEY

	SELECT @MontoComprobante = ISNULL(SUM(PrecioUnitario), 0)
	FROM FI_PedimentoComprobanteDetalle WITH (NOLOCK)
	WHERE IdPedimentoComprobante = @IdPedimentoComprobante

	SELECT @MontoTotalRegistros = ISNULL(SUM(MontoRegistro), 0)
	FROM CO_Registro WITH (NOLOCK)
	WHERE IdPedimentoComprobante = @IdPedimentoComprobante

	SELECT @MontoRegistroActual = ISNULL(SUM(MontoRegistro), 0)
	FROM CO_Registro WITH (NOLOCK)
	WHERE IdRegistro = @IdRegistro

	SELECT @MontoTotalRegistros = ISNULL(@MontoTotalRegistros, 0) - ISNULL(@MontoRegistroActual, 0)

	SELECT @MontoTotal = ISNULL(@MontoTotalRegistros, 0) + ISNULL(@MontoRegistro, 0)

	IF (@MontoTotal > @MontoComprobante)
	BEGIN
		SELECT 'No es posible registrar el gasto ya que se excedería el total del comprobante extranjero. Solo se puede capturar hasta $ ' + CAST((ISNULL(@MontoComprobante, 0) - ISNULL(@MontoTotalRegistros, 0)) AS VARCHAR) + ' en el monto'
	END

	SELECT ''
END