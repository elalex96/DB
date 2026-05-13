
-- =============================================
CREATE PROCEDURE SP_DEA_CambiarEstatusAprobadaRequisicion
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario INT,
	@IdSolicitudPedido INT,
	@IdOperacion INT 	
AS
BEGIN
	
	 UPDATE dbo.TA_Operacion
	 SET IdEstatusOperacion=2 -->SELECT * FROM dbo.TA_Estatus WHERE IdEstatus = 11
	 WHERE IdDocumento=@IdSolicitudPedido
	 AND IdOperacion=@IdOperacion
	 AND IdTipoOperacion=2 ---> APROBACION DE SOLICITUD DE PEDIDO 
	 
	 INSERT INTO dbo.TA_HistorialFlujoTarea
	 (
	     Descripcion,
	     IdOperacion,
	     Fecha,
	     IdEstadoFlujo
	 )
	 VALUES
	 (   N'Se ha cargado la PR, Aprobación Finalizada',       -- Descripcion - nvarchar(max)
	     @IdOperacion,         -- IdOperacion - int
	     GETDATE(), -- Fecha - datetime
	     7          -- IdEstadoFlujo - int
	  )
		
	 SELECT 'SUCCESS'

END

