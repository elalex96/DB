CREATE PROCEDURE [dbo].[Mobile_ArchivosEntregales]
@Idusuario int =0,
@idInstanciaEntregable int 
as
begin
	declare @MaxVersion int;
	set @MaxVersion =(Select MAX(N_version)
	from EN_DocumentoVersion DV
	Join EN_EntregableDocumento ED on Dv.DocumentoEntregableId=ED.DocumentoEntregableId
	Join EN_TipoArchivo T on T.idTipoArchivo=ED.idTipoArchivo
	where DV.idInstanciaEntregable=@idInstanciaEntregable);
	Select 
		N_version,
		Dv.DocumentoEntregableId,
		Concat(ED.NombreArchivo, ' / Subido el ', Convert(varchar,ED.CreadoEl,106)) as NombreArchivo,
		T.NombreArchivo as TipoArchivo,
		CASE WHEN CHARINDEX( '.pdf', ED.NombreArchivo) > 0 THEN 'https://store-images.s-microsoft.com/image/apps.34961.13510798887621962.47b62c4c-a0c6-4e3c-87bb-509317d9c364.a6354b48-c68a-47fa-b69e-4cb592d42ffc?mode=scale&q=90&h=300&w=300' 
		WHEN CHARINDEX( '.png', ED.NombreArchivo) > 0 or CHARINDEX( '.jpg', ED.NombreArchivo) > 0 or CHARINDEX( '.jpeg', ED.NombreArchivo) > 0 or CHARINDEX( '.svg', ED.NombreArchivo) > 0 THEN 'https://static.thenounproject.com/png/212328-200.png' 
		WHEN CHARINDEX( '.html', ED.NombreArchivo) > 0 THEN 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRw_vJXHHcC89gxMbwNYt5rwmFm6wIj-IS3zlmFU2r68hXrbHa' 
		WHEN CHARINDEX( '.pptx', ED.NombreArchivo) > 0 THEN 'https://cdn1.iconfinder.com/data/icons/file-formats-1-1/502/Untitled-31-512.png' 
		WHEN CHARINDEX( '.zip', ED.NombreArchivo) > 0 THEN 'https://cdn2.iconfinder.com/data/icons/file-format-colorful/100/rar-512.png' 
		WHEN CHARINDEX( '.xml', ED.NombreArchivo) > 0 THEN 'https://cdn0.iconfinder.com/data/icons/file-formats-7-2/100/Pack_blue_7_14-512.png' 
		WHEN CHARINDEX( '.txt', ED.NombreArchivo) > 0 THEN 'https://cdn3.iconfinder.com/data/icons/file-format-2/512/txt_.txt_file_file_format_document_extension_text_format_-512.png' 
		WHEN CHARINDEX( '.xls', ED.NombreArchivo) > 0 or CHARINDEX( '.xlsx ', ED.NombreArchivo) > 0 THEN 'https://cdn2.iconfinder.com/data/icons/file-formats-3-1/100/file_formats3_xls-512.png' 
		WHEN CHARINDEX( '.doc', ED.NombreArchivo) > 0 THEN 'https://cdn2.iconfinder.com/data/icons/picons-basic-1/57/basic1-047_file_word_doc-512.png' 
		WHEN CHARINDEX( '.sql', ED.NombreArchivo) > 0 THEN 'https://cdn2.iconfinder.com/data/icons/line-design-database-set-3/21/document-sql-512.png' 
		ELSE 'https://cdn0.iconfinder.com/data/icons/handdrawn-ui-elements/512/Question_Mark-512.png' END AS [Icon]
	from EN_DocumentoVersion DV
	Join EN_EntregableDocumento ED on Dv.DocumentoEntregableId=ED.DocumentoEntregableId
	Join EN_TipoArchivo T on T.idTipoArchivo=ED.idTipoArchivo
	where DV.idInstanciaEntregable= @idInstanciaEntregable--179742
	and N_version = @MaxVersion
end