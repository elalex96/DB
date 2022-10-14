USE PETROVENDOR
GO
DROP PROC IF EXISTS WDEA_ActualizarCorreoProcesado
GO
CREATE PROC WDEA_ActualizarCorreoProcesado
@IdCorreoPendiente int 
AS
BEGIN
	UPDATE WDEA_PedidosPendientesCorreosConfirmacion
	set Procesado = 1,
	ProcesadoEl = getdate()
	where Id = @IdCorreoPendiente
END
