USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[p_EN_ObtenerDocumentosEntregables]    Script Date: 11/11/2021 03:37:05 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_EN_ObtenerDocumentosEntregables] --3,10061,22897,504696,10000
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
	-- 11/11/2021 MC Ocultar entregables marcados como NA issue 468 entregables  
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
	   AND      DOC.idInstanciaEntregable	=	@idInstancia
	   AND ISNULL(CE.BitNA,0) <> 1

   END