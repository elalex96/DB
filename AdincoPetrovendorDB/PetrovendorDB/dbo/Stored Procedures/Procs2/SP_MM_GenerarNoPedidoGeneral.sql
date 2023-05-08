-- =============================================
-- Author:		Daniel AC
-- Create date: 06-12-2017
-- Description: Generar un IdPedido General 
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06-11-2020
-- Description: se agrega el campo de dias de credito para compra directa
-- =============================================
CREATE procedure [dbo].[SP_MM_GenerarNoPedidoGeneral] 	  
	 @IdTipoPedido INT, 
	 @IdPrimaryKey INT,  	 
	 @CreadoPor INT,
	 @IdProveedorActual INT,
	 @CuentaBancaria NVARCHAR(500),
	 @DiasCredito INT
	  
AS
BEGIN
	 DECLARE @IdPedidoGeneral INT 
	 DECLARE @CreadoEl DATETIME 

	SET @CreadoEl = GETDATE()
	EXEC dbo.SP_MM_GenerarIdPedidoGeneral @IdTipoPedido = @IdTipoPedido,             -- int
		                                      @IdPrimaryKey =@IdPrimaryKey,              -- int
		                                      @CreadoPor = @CreadoPor,				     -- int
		                                      @CreadoEl =@CreadoEl,         -- datetime
		                                      @IdProveedorActual = @IdProveedorActual ,  -- int
											  @CuentaBancaria = @CuentaBancaria,
											  @DiasCredito = @DiasCredito,
		                                      @IdPedidoGeneral = @IdPedidoGeneral OUTPUT -- int

	SELECT @IdPedidoGeneral
END

