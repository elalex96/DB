CREATE PROC WDEA_ActualizarCorreoProcesado
@IdCorreoPendiente int 
AS
BEGIN
	DECLARE @IdOperacion int = (SELECT IdOperacion FROM WDEA_PedidosPendientesCorreosConfirmacion WHERE Id= @IdCorreoPendiente)
	UPDATE WDEA_PedidosPendientesCorreosConfirmacion
	set Procesado = 1,
	ProcesadoEl = getdate()
	where Id = @IdCorreoPendiente

	UPDATE TA_Operacion
	SET IdEstatusOperacion = 2
	WHERE IdOperacion = @IdOperacion

	

	INSERT INTO WDEA_Bitacora_AdincoSAP
			(
				Fecha,
				Mensaje,
				NoConsecutivoProcesamiento,
				IdBitacoraLectura
			)
			VALUES
			(
				GETDATE(),
				CONCAT('Se actualizó el destatus de la la operación No.',@IdOperacion,' de "Aprobada sin Documento" a "Aprobada"'),
				NULL,
				NULL
			);
END