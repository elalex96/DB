-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <07-09-2018>
-- Description:	<relacionar los documentos segun el nombre del archivo para facilitar la carga>
-- =============================================

CREATE PROCEDURE ADM_ConsultarDocumentosS3AdjDirecta @NombreDocumento NVARCHAR(200)
AS
	BEGIN
		SELECT	TOP 1
				IdPeticionOferta, IdSolicitudPedido
		FROM	dbo.MM_PeticionOfertaADAdjunto
		WHERE
				UPPER ( NombreDocumento ) LIKE UPPER ( @NombreDocumento )
	END
