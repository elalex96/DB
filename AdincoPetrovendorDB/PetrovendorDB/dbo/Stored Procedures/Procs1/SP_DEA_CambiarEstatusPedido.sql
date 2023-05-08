
-- =============================================
CREATE PROCEDURE SP_DEA_CambiarEstatusPedido
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario INT,
	@IdSolicitudPedido INT,
	@IdOperacion INT,
	@NoVersion INT 	
AS
BEGIN
	
	 UPDATE dbo.TA_Operacion
	 SET IdEstatusOperacion=11 -->SELECT * FROM dbo.TA_Estatus WHERE IdEstatus = 11  --> APROBADO SIN DOCUMENTO
	 WHERE IdDocumento=@IdSolicitudPedido   --> NO DE SOLICITUD DE PEDIDO
	 AND IdOperacion=@IdOperacion --> NO DE LA OPERACION
	 AND NoVersion=@NoVersion --> VERSION DEL PEDIDO
	 AND IdTipoOperacion=9 ---> APROBACION DE PEDIDO

	 -- REGRESAR LA FECHA DE ENVIO DEL PEDIDO A NULL 

	 UPDATE MM_Pedido SET FechaEnvioPedido =NULL
	 WHERE IdSolicitudPedido = @IdSolicitudPedido AND Version =@NoVersion
 				
	
	-- Actualizar fecha de vigencia de Recepción de pedido VOLVERLAS A REGRESAR A NULL POR QUE EL ESTATUS CAMBIA A APROBADA SIN DOCUMENTO 
	UPDATE HV SET FechaVigencia  = NULL ---> DATEADD(HOUR, ISNULL(HV.HorasVigencia,0) , GETDATE())
	FROM MM_HorasVigenciaPedido AS HV
	INNER JOIN MM_Pedido AS P ON P.IdPedido =  HV.IdPedido
	WHERE  P.IdSolicitudPedido = @IdSolicitudPedido AND P.Version =@NoVersion
	 

	 SELECT 'SUCCESS', IdDocumento ---> IdSolicitudPedido	
	 FROM dbo.TA_Operacion
	 WHERE IdDocumento=@IdSolicitudPedido
	 AND IdOperacion=@IdOperacion
	 AND NoVersion=@NoVersion
	 AND IdTipoOperacion=9 
	  

END
