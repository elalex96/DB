----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Daniel AC
-- Create date: 06-12-2017
-- Description: Generar un IdPedido General 
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 07/07/2020
-- Description: Se agrego el campo de cuenta bancaria(en nulo porque solo se usa en compra directa)
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 04/11/2020
-- Description: Se agrego el campo de dias de credito(en nulo porque solo se usa en compra directa)
-- =============================================
CREATE procedure [dbo].[SP_MM_GenerarIdPedidoGeneral] 	  
	 @IdTipoPedido INT, 
	 @IdPrimaryKey INT,  
	 @CreadoPor INT,  
	 @CreadoEl DATETIME,
	 @IdProveedorActual INT,
	 @CuentaBancaria NVARCHAR(500) = NULL,
	 @DiasCredito INT = NULL,
	 @IdPedidoGeneral INT OUTPUT	  
AS
BEGIN
	 DECLARE @NoPedidoSecuencia INT
	 DECLARE @IsRegistrado INT 
	 
	

	 SET @IsRegistrado = (SELECT (COUNT(IdPedido)) FROM dbo.MM_Pedidos WHERE IdProveedorCliente= @IdProveedorActual AND IdIdentificador= @IdPrimaryKey AND IdTipoPedido=@IdTipoPedido)

	 
	 IF @IsRegistrado = 0
	 BEGIN 
		 SET  @NoPedidoSecuencia = (SELECT MAX(ISNULL(IdPedido,10000)) FROM dbo.MM_Pedidos WHERE IdProveedorCliente= @IdProveedorActual)
		 SET  @NoPedidoSecuencia = (ISNULL(@NoPedidoSecuencia,10000) +1)

			INSERT INTO dbo.MM_PEDIDOS
			(
				IdPedido,
				IdTipoPedido,
				IdIdentificador,
				IdCreadoPor,
				CreadorEl,
				IdProveedorCliente,
				CuentaBancaria,
				DiasCredito
			)
			VALUES
			(   @NoPedidoSecuencia, -- IdPedido - int
				@IdTipoPedido, -- IdTipoPedido - int
				@IdPrimaryKey, -- IdIdentificador - int
				@CreadoPor, -- IdCreadoPor - int
				@CreadoEl, -- CreadorEl - Datetime
				@IdProveedorActual,  -- IdProveedorCliente - int
				@CuentaBancaria,
				@DiasCredito
				);

	   SET @IdPedidoGeneral = @NoPedidoSecuencia
	END 
	ELSE 
	BEGIN 
		SET @IdPedidoGeneral = (SELECT IdPedido FROM dbo.MM_Pedidos WHERE IdProveedorCliente=@IdProveedorActual AND IdIdentificador= @IdPrimaryKey AND IdTipoPedido=@IdTipoPedido)
	END 

	return @IdPedidoGeneral
END


