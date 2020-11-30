CREATE PROCEDURE p_EN_ValidacionCantidadDocsShell
@IdInstanciaEntregable Int = NULL,
@IdContratoEntregable Int = NULL -- IdContratoEntregable 
as
BEGIN
	SELECT  ID	= DocumentoEntregableId,
			IDPadre = ISNULL(REL.DocumentoEntregablePadreId,0),
			DOC.NombreArchivo,
			Archivo = '',
			DOC.CreadoEl,
			U.Nombre,
			DOC.FechaRealEvidencia,
			DOC.Comentario
	  FROM	EN_EntregableDocumento DOC

	  JOIN	EN_ContratoEntregable CE
			ON DOC.idContratoEntregable  =	CE.IdContratoEntregable

	  LEFT JOIN	EN_EntregableRelacion	REL
			ON	DOC.DocumentoEntregableId	=	REL.DocumentoEntregableHijoId
	
	  LEFT JOIN AP_Usuario U
			ON DOC.CreadoPor	=	U.UsuarioID

	 WHERE     
				DOC.Activo	=	1
	   AND      DOC.idTipoArchivo	=	10000
	   AND      DOC.idInstanciaEntregable	=	@IdInstanciaEntregable;
END

