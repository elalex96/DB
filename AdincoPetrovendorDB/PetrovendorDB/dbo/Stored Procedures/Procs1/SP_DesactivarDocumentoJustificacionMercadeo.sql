-- =============================================
-- Author:	Pedro Acuña
-- Create date: 04-07-2018
-- Description:	SP para desactivar (eliminar) el documento adjunto del mercadeo
-- =============================================

CREATE PROCEDURE SP_DesactivarDocumentoJustificacionMercadeo @Id INT
AS
	BEGIN
		UPDATE	MM_PeticionOfertaMercadeoAdjunto
		SET		Activo = 0
		WHERE	Id = @Id
	END