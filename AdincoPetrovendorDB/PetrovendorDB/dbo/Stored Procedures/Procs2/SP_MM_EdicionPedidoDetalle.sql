USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_EdicionPedidoDetalle]    Script Date: 20/10/2022 05:20:08 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 13/10/2022
-- Description:	actualizacion de los detalles del pedido
-- =============================================
ALTER PROCEDURE [dbo].[SP_MM_EdicionPedidoDetalle]
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
	DECLARE @CANTIDAD_NUEVA FLOAT = @Cantidad;
	DECLARE @CANTIDAD_OCUPADA FLOAT = 0;
	DECLARE @NOMBRE_PARTIDA NVARCHAR(MAX);
	DECLARE @CANTIDAD_ACTUAL FLOAT;
	DECLARE @PRECIO_ACTUAL MONEY;
	DECLARE @PRECIO_NUEVO MONEY = @PrecioUnitario;
	DECLARE @MENSAJE_BITACORA NVARCHAR(MAX);
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
		@ID_PEDIDO = PD.IdPedido
	FROM MM_PedidoDetalle AS PD
		JOIN MM_PeticionOfertaDetalle AS POD
            ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	WHERE PD.IdPedidoDetalle = @IdPedidoDetalle;

	IF @CANTIDAD_NUEVA < @CANTIDAD_OCUPADA
	BEGIN

		IF @PRECIO_ACTUAL <> @PrecioUnitario
		BEGIN 
			
			UPDATE MM_PedidoDetalle
			SET PrecioUnitario = @PRECIO_NUEVO,
				Subtotal = (Cantidad * @CANTIDAD_NUEVA)
			WHERE IdPedidoDetalle = @IdPedidoDetalle;

			SET @MENSAJE_BITACORA = 'Se actualizó el precio unitario de la partida "' + @NOMBRE_PARTIDA +'" de $' + CAST(@PRECIO_ACTUAL AS nvarchar) + ' al ' + CAST(@PRECIO_NUEVO AS nvarchar)  + '.'; 
		
		END

	END
	ELSE
	BEGIN

		UPDATE MM_PedidoDetalle
		SET Cantidad = @CANTIDAD_NUEVA,
			PrecioUnitario = @PrecioUnitario,
			Subtotal = (@PrecioUnitario * @CANTIDAD_NUEVA)
		WHERE IdPedidoDetalle = @IdPedidoDetalle;

		IF @PRECIO_ACTUAL <> @PrecioUnitario
		BEGIN 
			
			SET @MENSAJE_BITACORA = 'Se actualizó el precio unitario de la partida "' + ISNULL(@NOMBRE_PARTIDA,'') +'" de $' + CAST(@PRECIO_ACTUAL AS nvarchar) + ' a $' + CAST(@PRECIO_NUEVO AS nvarchar)  + '.'; 
		
		END

		IF @CANTIDAD_ACTUAL <> @CANTIDAD_NUEVA
		BEGIN 
			
			SET @MENSAJE_BITACORA = ISNULL(@MENSAJE_BITACORA,'') + 'Se actualizó la cantidad de la partida "' + ISNULL(@NOMBRE_PARTIDA,'') + '" de ' + CAST(@CANTIDAD_ACTUAL AS nvarchar) + ' a ' + CAST(@CANTIDAD_NUEVA AS nvarchar) + '.';

		END

		SELECT 'EDITADO' AS Error

	END

	INSERT INTO TA_HistorialEdicionPedidoDetalle
	(	
		Descripcion,
		IdPedido,
		IdUsuario,
		IdContrato,
		Fecha
	)
	VALUES
	(
		@MENSAJE_BITACORA,
		@ID_PEDIDO,
		@IdUsuario,
		@IdContrato,
		GETDATE()
	);
END
