---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:	Pedro Acuña
-- Create date: 05/03/2019
-- Description:	Se elimina los documentos , actualmente solo los representantes legales
-- =============================================

CREATE PROCEDURE SP_EliminarRepresentanteLegal @IdDocumento INT, @IdTipoDocumento INT
AS
	BEGIN
		UPDATE	S3
		   SET	S3.Activo = 0
		  FROM	dbo.S_Documento_S3 S3
		 WHERE
				IdDocumento = @IdDocumento
				AND IdTipoDocumento = @IdTipoDocumento

		UPDATE	legal
		   SET	legal.IsActivo = 0
		  FROM	dbo.DG_RepresentanteLegal legal
		 WHERE
				IdDocumento = @IdDocumento
				AND @IdTipoDocumento = @IdTipoDocumento
	END