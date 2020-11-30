-- =============================================
-- Author:	DANIEL AC 
-- modificado date:  03/10/2019
-- Description:	Se actualizan los dias de credito en los que la operadora se compromete a pagar por pedido detalle 
-- =============================================
CREATE PROCEDURE SP_MM_ActualizarDiasDeCredito
    @DiasCredito INT,
    @IdSolicitudPedido INT,
    @Version INT,
    @IdMoneda INT,  
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME,
	@IdPeticionOfertaDetalle INT =NULL,
	@IdCondicionPago INT =NULL,
	@IdPeticionOferta INT = NULL 
AS
BEGIN


    --UPDATE p
    --SET p.DiasCredito = @DiasCredito
    --FROM dbo.MM_Pedido p
    --WHERE p.IdSolicitudPedido = @IdSolicitudPedido
    --      AND p.Version = @Version
    --      AND p.IdMoneda = @IdMoneda
		 

	IF @IdPeticionOfertaDetalle IS NOT NULL
	BEGIN 
	
		UPDATE pd
		SET pd.DiasCredito = @DiasCredito,
		pd.IdCondicionPago=@IdCondicionPago
		FROM dbo.MM_PedidoDetalle pd
		INNER JOIN dbo.MM_Pedido p ON p.IdPedido=pd.IdPedido
		WHERE p.IdSolicitudPedido = @IdSolicitudPedido
			  AND p.Version = @Version
			  AND p.IdMoneda = @IdMoneda
			  AND p.IdPeticionOferta=@IdPeticionOferta
			  AND pd.IdPeticionOfertaDetalle=@IdPeticionOfertaDetalle

	END 
END;
