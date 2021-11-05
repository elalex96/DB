CREATE PROCEDURE [dbo].[p_EN_ObtenerDocumentosEntregables] --3,10061,22897,504696,10000
    @pIdContrato INT,
    @UsuarioId INT,
    @idEntregable INT,
    @idInstancia INT,
    @idTipoArchivo INT
AS
BEGIN
    -- =============================================
    -- Author:  Daniel AC
    -- Create date: 2020-05-11
    -- Description: Referencias al objero dbo
    -- =============================================
	SELECT  ID	= DocumentoEntregableId,
			IDPadre = ISNULL(REL.DocumentoEntregablePadreId,0),
			DOC.NombreArchivo,
			Archivo = '',
			DOC.CreadoEl,
			U.Nombre,
			DOC.FechaRealEvidencia,
			DOC.Comentario
	  FROM	dbo.EN_EntregableDocumento DOC
	  JOIN	dbo.EN_ContratoEntregable CE
			ON DOC.idContratoEntregable  =	CE.IdContratoEntregable

	  LEFT JOIN	dbo.EN_EntregableRelacion	REL
			ON	DOC.DocumentoEntregableId	=	REL.DocumentoEntregableHijoId
	
	  LEFT JOIN dbo.AP_Usuario U
			ON DOC.CreadoPor	=	U.UsuarioID

	 WHERE     
				DOC.Activo	=	1
	   AND      DOC.idTipoArchivo	=	@idTipoArchivo
	   AND      DOC.idInstanciaEntregable	=	@idInstancia;


   END