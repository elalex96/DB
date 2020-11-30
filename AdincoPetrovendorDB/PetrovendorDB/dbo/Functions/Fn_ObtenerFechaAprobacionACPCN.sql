-- =============================================
-- Author: Pedro Acuña
-- Create date: 22/06/2018
-- Description: obtener la fecha de aprobacion de la Carta de contenido nacional
-- =============================================

CREATE FUNCTION Fn_ObtenerFechaAprobacionACPCN
	( @IdProveedor INT ,
	  @IdAceptacionPedido INT ,
	  @IdPeticionOferta INT )
RETURNS DATETIME
AS
	BEGIN
		DECLARE @FechaRetorno DATETIME

		SELECT		@FechaRetorno = MAX ( AC.FechaEvaluacion )
		FROM		[dbo].[MM_AceptacionCartaPCN] AS AC
		INNER JOIN	[dbo].[S_Documento_S3] AS D
			ON D.IdDocumento = AC.IdDocumento
		INNER JOIN	[dbo].[MM_AceptacionPedido] AS AP
			ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
		INNER JOIN	[dbo].[MM_Pedido] AS P
			ON P.IdPedido = AP.IdPedido
		INNER JOIN	[dbo].[S_Proveedor] AS PR
			ON PR.IdProveedor = P.IdSubcontratista
		INNER JOIN	[dbo].[S_TipoValidacionDoc] AS TD
			ON TD.IdTipoValidacionDoc = AC.IdEstatus
		INNER JOIN	MM_Pedidos AS PG
			ON P.IdPedido = PG.IdIdentificador
			   AND	PG.IdProveedorCliente = @IdProveedor
		LEFT JOIN	[dbo].[S_Usuario] AS U
			ON U.IdUsuario = AC.IdUsuarioEvaluador
		LEFT JOIN	dbo.MM_TipoPedido AS TP
			ON TP.IdTipoPedido = PG.IdTipoPedido
		WHERE
					P.IdProveedorCompras = @IdProveedor
					AND AP.IdAceptacionPedido = @IdAceptacionPedido
					AND P.IdPeticionOferta = @IdPeticionOferta
					AND AC.IdEstatus = 2	-- aprobada

		RETURN @FechaRetorno
	END