-- =============================================
-- Author:	Pedro Acuña
-- Create date: 10-09-2018
-- Description:	SP para obtener los nombres e identificador de los documentos
-- =============================================

create PROCEDURE SP_NombresDocumentoJustificacion
AS
	BEGIN
		SELECT	IdDocumento, Identificador, Extension, NombreDocumento, Activo, IdSolicitudPedido
		FROM	MM_PeticionOfertaADAdjunto ORDER BY	IdDocumento
	END
