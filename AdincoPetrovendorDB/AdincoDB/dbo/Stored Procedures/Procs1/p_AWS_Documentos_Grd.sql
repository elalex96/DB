
create proc p_AWS_Documentos_Grd
as
begin
	select	AWSDocumentoId,
			Bucket,
			Folder,
			UUIDAmazon,
			NombreArchivo,
			Meta
	from	AWS_Documentos
end
