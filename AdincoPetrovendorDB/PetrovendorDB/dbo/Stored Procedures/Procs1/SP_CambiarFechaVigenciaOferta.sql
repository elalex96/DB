-- =============================================
-- Author:		Pedro Acuña
-- Create date: 23/01/2018
-- Description:	actualizar flujo de aprobación de Solicitud de pedido
-- =============================================

CREATE PROCEDURE SP_CambiarFechaVigenciaOferta @IdPeticionOfertaDetalle INT, @FechaNueva DATE, @IdUsuario INT
AS
	BEGIN
		UPDATE	MM_PeticionOfertaDetalle
		SET		FechaVigencia = @FechaNueva, ModificadoPor = @IdUsuario, ModificadoEl = GETDATE ()
		WHERE	IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
	END