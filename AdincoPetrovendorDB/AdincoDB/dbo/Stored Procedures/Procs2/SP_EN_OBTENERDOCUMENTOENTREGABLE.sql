create procedure [dbo].[SP_EN_OBTENERDOCUMENTOENTREGABLE]
@DocumentoEntregableId int
AS
BEGIN 

select 
		IdLineamientoDocumento,
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta,
		CreadoPor,
		CreadoEl,
		ModificadoPor,
		ModificadoEl
	from EN_LineamientoDocumento doc
	where IdLineamientoDocumento = @DocumentoEntregableId
END