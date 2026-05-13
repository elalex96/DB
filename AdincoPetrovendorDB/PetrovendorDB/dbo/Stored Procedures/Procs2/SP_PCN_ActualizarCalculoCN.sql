-- =============================================
-- Author:		DANIEL AC
-- Create date: 15/11/2017
-- Description:CALCULO PCN
-- =============================================
CREATE PROCEDURE [dbo].[SP_PCN_ActualizarCalculoCN]

@IdValoresEnPesosPedidoDetalle int,
@IdAceptacionPedidoDetalle int,
@IdAceptacionPedido int,
@VNMO_SueldoNacional decimal,
@VMO_Sueldo decimal,
@CreadoPor int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @PCNMjxVMj DECIMAL(18,2)
	DECLARE @VNMOi DECIMAL(18,2)
	DECLARE @VMOi DECIMAL(18,2)
	DECLARE @VMjxVMOi DECIMAL(18,2)
	DECLARE @VMj DECIMAL(18,2)
	DECLARE @PCN_MaterialFinal DECIMAL(18,2)
	DECLARE @PCN_PedidoDetalleAll INT
	DECLARE @PCN_PedidoDetalleAdd INT
	
	
	UPDATE MM_PCN_ValoresPesos
	SET VNMO_SueldoNacional = @VNMO_SueldoNacional,
	VMO_Sueldo= @VMO_Sueldo,
	EditadoEl=GETDATE(),
	EditadoPor=@CreadoPor
	WHERE IdValoresEnPesosPedidoDetalle	= @IdValoresEnPesosPedidoDetalle

	--#Calcular Contenido Nacional
  

	SET @PCNMjxVMj =(SELECT SUM(MU.PCNM_Utilizado * MU.VM_ValorFactura) AS PCNMixVMi
				FROM MM_PCN_MaterialesUtilizados MU				
				WHERE MU.IdValoresEnPesosPedidoDetalle = @IdValoresEnPesosPedidoDetalle 
				AND ISNULL(MU.IsEliminado,0) = 0)

	SET @VMj =(SELECT SUM(MU.VM_ValorFactura) AS VMi
				FROM MM_PCN_MaterialesUtilizados MU				
				WHERE MU.IdValoresEnPesosPedidoDetalle = @IdValoresEnPesosPedidoDetalle 
				AND ISNULL(MU.IsEliminado,0) = 0)

	SET @VNMOi = (SELECT ISNULL(VNMO_SueldoNacional,0) FROM MM_PCN_ValoresPesos WHERE IdValoresEnPesosPedidoDetalle = @IdValoresEnPesosPedidoDetalle)
	SET @VMOi = (SELECT ISNULL(VMO_Sueldo,0) FROM MM_PCN_ValoresPesos WHERE IdValoresEnPesosPedidoDetalle = @IdValoresEnPesosPedidoDetalle)

	SET @VMjxVMOi = (@VMj+@VMOi)

	SET @PCN_MaterialFinal= (((@PCNMjxVMj)+@VNMOi)/@VMjxVMOi)

	SELECT @PCN_MaterialFinal

	--#Actualizar Contenido Nacional General del Material Final
	UPDATE MM_AceptacionPedidoDetalle
	SET [PCN] = @PCN_MaterialFinal,
	PCN_Agregado=1,
	EditadoEl=GETDATE(),
	EditadoPor=@CreadoPor
	WHERE IdAceptacionPedidoDetalle= @IdAceptacionPedidoDetalle	

	--#Actualizar Estatus de AddPCN en 

	SET @PCN_PedidoDetalleAll = (SELECT COUNT(APD.IdAceptacionPedidoDetalle) 
								 FROM MM_AceptacionPedidoDetalle APD
								 INNER JOIN MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido 
								 WHERE AP.IdAceptacionPedido = @IdAceptacionPedido)

	SET @PCN_PedidoDetalleAdd = (SELECT COUNT(APD.IdAceptacionPedidoDetalle) 
								 FROM MM_AceptacionPedidoDetalle APD
								 INNER JOIN MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido 
								 WHERE AP.IdAceptacionPedido = @IdAceptacionPedido AND APD.PCN_Agregado=1)

	IF @PCN_PedidoDetalleAll = @PCN_PedidoDetalleAdd
	BEGIN
		UPDATE MM_AceptacionPedido
		SET PCN_Agregado=1,
		Modificado=GETDATE(),
		ModificadoPor=@CreadoPor
		WHERE IdAceptacionPedido= @IdAceptacionPedido	
	END 

	SELECT 'SUCESSS'
	 
END