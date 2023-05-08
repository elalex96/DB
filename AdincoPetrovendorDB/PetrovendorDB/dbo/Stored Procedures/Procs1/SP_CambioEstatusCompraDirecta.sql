
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <27-03-2018>
-- Description:	<Sp para actualizar el estatus y fecha de vencimiento de una orden de compra directa>
-- =============================================

CREATE procedure SP_CambioEstatusCompraDirecta --10260, 1,  '20180330'
	@IdPedidoGeneral INT,
	@Estatus INT,
	@NuevaFechaVencimiento SMALLDATETIME,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	UPDATE t
		SET t.IdEstatus = @Estatus
	FROM dbo.MM_Pedidos p
		INNER JOIN dbo.TA_Operacion o ON o.IdDocumento = p.IdIdentificador
		INNER JOIN dbo.TA_Tarea t ON t.IdOperacion = o.IdOperacion
	WHERE p.IdPedido = @IdPedidoGeneral

	UPDATE v
		SET v.DiaVencimiento = DATEDIFF(DAY, o.FechaRegistro, @NuevaFechaVencimiento)
	FROM dbo.MM_Pedidos p
		INNER JOIN dbo.TA_Operacion o ON o.IdDocumento = p.IdIdentificador
		INNER JOIN dbo.TA_Vencimiento v ON o.IdVigencia = v.IdVencimiento
	WHERE p.IdPedido = @IdPedidoGeneral
END
