-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <13-12-2018>
-- Description:	<obtener el pedido y version filtrando por el provedor y el pedido gral>
-- =============================================

CREATE PROCEDURE SP_ConsultaPedidoVersion @IdPedido INT, @IdProveedor INT ,
											/*--------------------parametros contrato  --------------------*/
										  @IdContrato INT = NULL, @IdUsuario INT = NULL, @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
	BEGIN
		SELECT		p.IdPedido, p.Version
		FROM		dbo.MM_Pedidos ps
		INNER JOIN	dbo.MM_Pedido p
			ON ps.IdIdentificador = p.IdPedido
		WHERE
					p.IdPedido = @IdPedido
					AND ps.IdProveedorCliente = @IdProveedor
	END
