
-- =============================================
CREATE PROCEDURE SP_DEA_CambiarEstatusRequisicion
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario INT,
	@IdRequisicion INT,
	@IdOperacion INT 	
AS
BEGIN
	
	 UPDATE dbo.TA_Operacion
	 SET IdEstatusOperacion=11 -->SELECT * FROM dbo.TA_Estatus WHERE IdEstatus = 11
	 WHERE IdDocumento=@IdRequisicion
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
	 (   N'La aprobación pasará a Aprobada sin Documento, para permitir la carga de la PR en la Requisición No. '+ ISNULL(CAST(ISNULL(@IdRequisicion,'') AS NVARCHAR(MAX)),0),       -- Descripcion - nvarchar(max)
	     @IdOperacion,         -- IdOperacion - int
	     GETDATE(), -- Fecha - datetime
	     11          -- IdEstadoFlujo - int
	     )
	 
	 SELECT 'SUCCESS'

END

