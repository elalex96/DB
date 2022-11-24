
CREATE PROCEDURE [dbo].[p_EN_ObtenerDocumentosEntregables] --3,10061,12294,10184
    @pIdContrato INT,
    @UsuarioId INT,
    @idEntregable INT,
    @idInstancia INT,
    @idTipoArchivo INT
AS
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
	   AND      DOC.idTipoArchivo	=	@idTipoArchivo
	   AND      DOC.idInstanciaEntregable	=	@idInstancia;


   END

   --select * from EN_EntregableDocumento











   --exec [p_EN_ObtenerDocumentosEntregables] @pIdContrato=10038,@UsuarioId=10244,@idTipoArchivo=10000,@idEntregable=11505,@idinstancia=433419