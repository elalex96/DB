-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20/05/28
-- Description:	Extrae los documentos que fueron enviados de acuerdo a la version
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeEdicionDocumentoVersion]--225,306594,3,10061
	@IdLineaTiempo int,
	@InstanciaEntregableId int,
	@idUsuario int,
	@idContrato int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Dv.DocumentoEntregableId,
		ED.NombreArchivo,
		T.NombreArchivo as TipoArchivo,
		u.Nombre as ArchivoImportadoPor,
		ED.CreadoEl as ImportadoEl,
		ED.IdTipoArchivo,
		N_version as IdLineaTiempo,
		DV.IdInstanciaEntregable,
		DV.Activo
	FROM 
		EN_DocumentoVersion	DV (NOLOCK)
	JOIN 
		EN_EntregableDocumento	ED
		ON	Dv.DocumentoEntregableId	=	ED.DocumentoEntregableId
	JOIN 
		EN_TipoArchivo	T (NOLOCK)
		ON	ED.idTipoArchivo	=	T.idTipoArchivo
	JOIN 
		AP_Usuario	u (NOLOCK)
		ON	ed.CreadoPor	=	u.UsuarioID
	WHERE 
		DV.idInstanciaEntregable	=	@InstanciaEntregableId 
		AND DV.Activo	=	1
		AND	N_version	=	@IdLineaTiempo

END