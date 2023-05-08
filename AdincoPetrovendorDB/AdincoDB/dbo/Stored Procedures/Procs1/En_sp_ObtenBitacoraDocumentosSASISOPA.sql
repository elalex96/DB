CREATE PROCEDURE [dbo].[En_sp_ObtenBitacoraDocumentosSASISOPA]
@IdContrato int,
@IdUsuario int = NULL
AS
BEGIN
	SELECT 
	U.Nombre,
	BS.FechaInicial,
	BS.FechaFinal,
	BS.FechaCreacion,
	D.Bucket,
	D.Folder,
	D.UUIDAmazon,
	CASE  
		WHEN D.Bucket IS NULL THEN 'Preparando su archivo...'
		WHEN D.Bucket IS NOT NULL THEN 'Listo para descargar'
	END AS Estatus,
	CASE  
		WHEN D.Bucket IS NULL THEN 'label label-warning'
		WHEN D.Bucket IS NOT NULL THEN 'label label-success'
	END AS span,
	ISNULL((UPPER(D.UUIDAmazon)+'.zip'),SR.NombreDocumento) AS NombreDocumento
	FROM 
	EN_Documentos_BitacoraReporteSASISOPA AS BS
	LEFT JOIN EN_DocumentosSASISOPA_Relacion AS SR
		ON BS.Id = SR.IdBitacoraReporte
	LEFT JOIN AWS_Documentos AS D
		ON SR.IdDocumento = D.AWSDocumentoId
	JOIN AP_Usuario U (NOLOCK)
		ON BS.IdUsuario = U.UsuarioID
	WHERE BS.IdContrato = @IdContrato
	ORDER BY BS.FechaCreacion DESC
END

