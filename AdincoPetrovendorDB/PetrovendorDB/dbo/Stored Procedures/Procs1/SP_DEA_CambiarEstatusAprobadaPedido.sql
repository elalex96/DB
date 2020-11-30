
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_CambiarEstatusAprobadaPedido]
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario INT,
	@IdSolicitudPedido INT,
	@IdOperacion INT,
	@NoVersion INT,
	@IdPedido INT 
AS
BEGIN
	
	 UPDATE dbo.TA_Operacion
	 SET IdEstatusOperacion=2 -->SELECT * FROM dbo.TA_Estatus WHERE IdEstatus =2  PEDIDO REGRESA A APROBADA 
	 WHERE IdDocumento=@IdSolicitudPedido
	 AND IdOperacion=@IdOperacion
	 AND NoVersion=@NoVersion
	 AND IdTipoOperacion=9 ---> APROBACION DE PEDIDO

	 --NUEVA ACTUALIZACIÓN DE ACTUALIZAR TAREAS RELACIONADAS AL PEDIDO APROBACIÓN
			--COMENTADO PARA EVITAR REEMPLAZAR LA INFO DEL APROBADOR 
	 	--UPDATE TA_Tarea 
		--SET  IdEstatus=2 ,	 ---> APROBADA
		--FechaCambioEstatus = GETDATE(),
		--Comentario='Aprobación aprobada con el pedido relacionando Pedido - PO',
		--IdFirma = 'No aplica'
		--WHERE IdOperacion=@IdOperacion
		--AND Activo=1
		

		DECLARE  @DescripcionH NVARCHAR(MAX)= 'Se ha Finalizado la aprobación del pedido, con la relación de Pedido-PO'

		INSERT INTO TA_HistorialFlujoTarea(IdOperacion,Fecha,Descripcion,IdEstadoFlujo)
		VALUES(@IdOperacion,GETDATE(),@DescripcionH,7)

	  -- ACTUALIZAR LA FECHA DE ENVIO DEL PEDIDO A LA FECHA ACTUAL

	 UPDATE MM_Pedido SET FechaEnvioPedido =GETDATE()
	 WHERE IdSolicitudPedido = @IdSolicitudPedido AND Version =@NoVersion
	 AND IdPedido  = @IdPedido
 				
	
	-- Actualizar fecha de vigencia de Recepción de pedido VOLVERLAS A REGRESAR A LA FECHA CORRESPONDIENTE POR QUE EL ESTATUS CAMBIA A APROBADA SIN DOCUMENTO 
	UPDATE HV SET FechaVigencia  =DATEADD(HOUR, ISNULL(HV.HorasVigencia,0) , GETDATE())
	FROM MM_HorasVigenciaPedido AS HV
	INNER JOIN MM_Pedido AS P ON P.IdPedido =  HV.IdPedido
	WHERE  P.IdSolicitudPedido = @IdSolicitudPedido AND P.Version =@NoVersion
	AND HV.IdPedido  = @IdPedido

	 SELECT IdDocumento,---> IdSolicitudPedido
	 IdOperacion,
	 NoVersion 
	 FROM dbo.TA_Operacion
	 WHERE IdDocumento=@IdSolicitudPedido
	 AND IdOperacion=@IdOperacion
	 AND NoVersion=@NoVersion
	 AND IdTipoOperacion=9  ---> APROBACION DE PEDIDO

END

