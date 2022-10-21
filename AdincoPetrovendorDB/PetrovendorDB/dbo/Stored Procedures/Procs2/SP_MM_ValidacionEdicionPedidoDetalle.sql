USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ValidacionEdicionPedidoDetalle]    Script Date: 21/10/2022 10:22:31 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 13/10/2022
-- Description:	validacion de los detalles del pedido
-- =============================================
ALTER PROCEDURE [dbo].[SP_MM_ValidacionEdicionPedidoDetalle]
	-- Add the parameters for the stored procedure here
	@IdPedidoDetalle INT,
	@Cantidad FLOAT,
	@PrecioUnitario FLOAT,
	@IdUsuario INT,
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CANTIDAD_NUEVA FLOAT = @Cantidad;
	DECLARE @CANTIDAD_OCUPADA FLOAT = 0;
	DECLARE @NOMBRE_PARTIDA NVARCHAR(MAX);
	DECLARE @CANTIDAD_ACTUAL FLOAT;
	DECLARE @PRECIO_ACTUAL FLOAT;
	DECLARE @MENSAJE_BITACORA NVARCHAR(MAX);
	DECLARE @PROCESOS_EN_CURSO INT = 0;
	DECLARE @ID_PEDIDO INT;

	--ACEPTACIONES REALIZADAS
	DECLARE @SAS_APROBADAS FLOAT = (SELECT SUM(Cantidad) 
									FROM MM_AceptacionPedidoDetalle AS APD
										JOIN MM_AceptacionPedido AS AP
											ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
									WHERE APD.IdPedidoDetalle = @IdPedidoDetalle 
										AND ISNULL(AP.IdEliminado,0) = 0);--SE DESCARTAN LAS ACEPTACIONES ELIMINADAS

	--SOLICTUDES DE ACEPTACION
	DECLARE @SAS_PENDIENTES FLOAT = (SELECT SUM(SAPD.Cantidad) 
										FROM MM_SolicitudAceptacionPedidoDetalle as SAPD
											JOIN MM_SolicitudAceptacionPedido AS SAP
												ON SAPD.IdSolicitudAceptacionPedido = SAP.IdSolicitudAceptacionPedido
											JOIN TA_Operacion AS OP
												ON SAP.IdSolicitudAceptacionPedido = OP.IdDocumento
												AND OP.IdEstatusOperacion = 1 --PENDIENTES DE APROBACION
												AND OP.IdTipoOperacion = 20
												AND SAP.IdProveedorVenta = OP.IdProveedor
										WHERE IdPedidoDetalle = @IdPedidoDetalle);

	SET @CANTIDAD_OCUPADA = (ISNULL(@SAS_APROBADAS,0) + ISNULL(@SAS_PENDIENTES,0));

	SELECT 
		@CANTIDAD_ACTUAL = PD.Cantidad,
		@PRECIO_ACTUAL = PD.PrecioUnitario,
		@NOMBRE_PARTIDA = POD.MaterialCotizadoTextoC,
		@ID_PEDIDO = IdPedido
	FROM MM_PedidoDetalle AS PD
		JOIN MM_PeticionOfertaDetalle AS POD
            ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	WHERE PD.IdPedidoDetalle = @IdPedidoDetalle;

	--SE OBTIENEN LA CANTIDAD DE CARTAS CN RELACIONADAS AL PEDIDO
	DECLARE @CN INT = (SELECT
							COUNT(ACN.IdAceptacionCartaPCN)
						FROM MM_AceptacionCartaPCN AS ACN
							JOIN MM_AceptacionPedido AS AP
								ON ACN.IdAceptacionPedido = AP.IdAceptacionPedido
							JOIN MM_Pedido AS P
								ON AP.IdPedido = P.IdPedido
						WHERE P.IdPedido = @ID_PEDIDO
						GROUP BY ACN.IdAceptacionCartaPCN);

	--SE OBTIENE LA CANTIDAD DE FACTURAS ASOCIADAS AL PEDIDO
	DECLARE @FACTURAS INT = (SELECT
								COUNT(AF.IdAceptacionFactura)
							FROM MM_AceptacionFactura AS AF
								JOIN MM_AceptacionPedido AS AP
									ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
								JOIN MM_Pedido AS P
									ON AP.IdPedido = P.IdPedido
							WHERE P.IdPedido = @ID_PEDIDO
							GROUP BY AF.IdAceptacionFactura);

	--SE OBTIENE LA CANTIDAD DE COMPROBANTES EXTRANJEROS
	DECLARE @COMPROBANTES INT = (SELECT
								COUNT(AF.IdAceptacionPedidoPedimentoComprobante)
							FROM FI_AceptacionPedido_PedimentoComprobante AS AF
								JOIN MM_AceptacionPedido AS AP
									ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
								JOIN MM_Pedido AS P
									ON AP.IdPedido = P.IdPedido
							WHERE P.IdPedido = @ID_PEDIDO
							GROUP BY AF.IdAceptacionPedidoPedimentoComprobante);

	SET @PROCESOS_EN_CURSO = ISNULL(@CN,0) + ISNULL(@FACTURAS,0) + ISNULL(@COMPROBANTES,0);



	IF @CANTIDAD_NUEVA < @CANTIDAD_OCUPADA
	BEGIN

		SELECT 'La cantidad que quiere cambiar no es válida, ya que este pedido tiene aceptaciones realizadas o solicitudes pendientes, debe ser mayor o igual a ' + CAST(@CANTIDAD_OCUPADA AS nvarchar) AS Error;

	END
	ELSE
	BEGIN

		IF @PROCESOS_EN_CURSO > 0
		BEGIN

			SELECT 'Este pedido ya no es editable, recarga la pantalla.' AS Error

		END
		ELSE
		BEGIN

			SELECT 'EDITADO' AS Error

		END

	END

END
