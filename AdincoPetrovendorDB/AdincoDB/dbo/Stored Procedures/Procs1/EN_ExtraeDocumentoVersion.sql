-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20/05/28
-- Description:	Extrae los documentos que fueron enviados de acuerdo a la version
-- =============================================
CREATE PROCEDURE [dbo].[EN_ExtraeDocumentoVersion]
	@idVersion int,
	@InstanciaEntregableId int,
	@idUsuario int=0,
	@idContrato int=0,
	@idTipoArchivo INT
AS
BEGIN
	SET NOCOUNT ON;

  If (@idtipoArchivo=0)
  BEGIN

	SELECT  
		Dv.DocumentoEntregableId,ED.NombreArchivo,T.NombreArchivo as TipoArchivo,u.Nombre as ArchivoImportadoPor
	FROM
		EN_DocumentoVersion	DV
	JOIN 
		EN_EntregableDocumento	ED (NOLOCK)
		ON	Dv.DocumentoEntregableId	=	ED.DocumentoEntregableId
	JOIN 
		EN_TipoArchivo	T (NOLOCK)
		ON	T.idTipoArchivo	=	ED.idTipoArchivo
	JOIN 
		AP_Usuario	u (NOLOCK)
		ON	ed.CreadoPor	=	u.UsuarioID
	WHERE 
		DV.idInstanciaEntregable	=	@InstanciaEntregableId
		AND DV.Activo	=	1
		AND	N_version	=	@idVersion 
   END
   ELSE
   BEGIN 

	SELECT 
		Dv.DocumentoEntregableId,ED.NombreArchivo,T.NombreArchivo,u.Nombre as ArchivoImportadoPor
	FROM 
		EN_DocumentoVersion	DV
	JOIN 
		EN_EntregableDocumento	ED  (NOLOCK)
		ON	Dv.DocumentoEntregableId	=	ED.DocumentoEntregableId
	JOIN 
		EN_TipoArchivo	T (NOLOCK)
		ON	T.idTipoArchivo	=	ED.idTipoArchivo
	JOIN 
		AP_Usuario	u (NOLOCK)
		ON	ed.CreadoPor	=	u.UsuarioID
	WHERE 
		DV.idInstanciaEntregable	=	@InstanciaEntregableId 
		AND DV.Activo	=	1
		AND	N_version	=	@idVersion
		AND	ED.idTipoArchivo	=	@idTipoArchivo
END
END