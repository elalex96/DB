-- =============================================
-- Author:		Pedro Acuña
-- Create date: 18/07/2018
-- Description:	ahora la aprobacion es por cada pedido y no una aprobacion para todos los pedidos generados
-- =============================================

CREATE PROCEDURE SP_GuardarDocumentosMinimos @IdTipoRegimen INT, @IdSolPed INT, @IdTipoDocumento INT
AS
	BEGIN
		INSERT INTO dbo.RN_DocumentosMinimosProveedor
			( IdSolicitudPedido, IdTipoRegimen, IdTipoDocumento )
		VALUES
			( @IdSolPed ,		-- IdSolicitudPedido - int
			  @IdTipoRegimen ,	-- IdTipoRegimen - int
			  @IdTipoDocumento	-- IdTipoDocumento - int
			)
	END

