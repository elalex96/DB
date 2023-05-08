-- =============================================
-- Author:		<Jose Roman>
-- Create date: <08/05/2018>
-- Description:	<Se crea consulta para los documentos adjuntos por oficio>
-- =============================================

create PROCEDURE OF_SP_ConsultaDocAdjuntosPorOficio
	@IdDocumentoOficio INT
AS
BEGIN
	SELECT IdDocAdjuntosXOficio,
			NomDocumento,
			Comentario,
			CONCAT(Folder, UUIDAmazon) AS UUIDAmazon,
			Bucket
	FROM dbo.OF_DocAdjuntosXOficio
	WHERE IdDocumentoOficio = @IdDocumentoOficio
END