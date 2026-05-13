
CREATE PROCEDURE [dbo].[SP_Migracion_EntregablesInstanciasDocumentos] 
@ContratoId DATETIME,
@ProgramacionId  INT
AS
BEGIN

   -- EXEC SP_Migracion_EntregablesInstanciasDocumentos 3,316209
   -- EXEC SP_Migracion_EntregablesInstanciasDocumentos 3,316682
   	SELECT  	
		ROW_NUMBER() OVER(ORDER BY DV.DocumentoEntregableId) AS RowNumber,
		ED.DocumentoEntregableId,
		ED.NombreArchivo,
		T.NombreArchivo as TipoArchivo,
		DV.CreadoPor ArchivoImportadoPor,
		DV.CreadoEl CreadoEl,
		DV.N_version AS Version,
		ED.TextoDocumentoEntregble AS TextoDocumentoEntregable,
		ED.Activo,
		ED.UUIDAmazon as Identificador,
		ED.Meta as Mime,
		ED.Comentario AS Comentario
	FROM
		EN_DocumentoVersion	DV
	JOIN 
		EN_EntregableDocumento	ED 
		ON	Dv.DocumentoEntregableId	=	ED.DocumentoEntregableId
	JOIN 
		EN_TipoArchivo	T 
		ON	T.idTipoArchivo	=	ED.idTipoArchivo
	JOIN 
		AP_Usuario	u 
		ON	ed.CreadoPor =	u.UsuarioID
	WHERE 
		DV.idInstanciaEntregable	=@ProgramacionId
		AND DV.Activo	=	1	

END;
