USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'EN_SHELL_ObtenerDetalleDocumentosEntregables'
)
    DROP PROCEDURE EN_SHELL_ObtenerDetalleDocumentosEntregables;
GO 
/****** Object:  StoredProcedure [dbo].[p_EN_ObtenerArchivoEntregable]    Script Date: 12/03/2021 03:57:58 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[dbo].[EN_SHELL_ObtenerDetalleDocumentosEntregables] '','1,2,3,4,5'
CREATE PROCEDURE [dbo].[EN_SHELL_ObtenerDetalleDocumentosEntregables] 
@DctosEntregablesIdsContatenados NVARCHAR(MAX),
@DctosGeneralesIdsContatenados NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Documentos AS TABLE
    (
        IdRow INT IDENTITY(1, 1),
        DocumentoId INT
    );

	 DECLARE @DocumentosG AS TABLE
    (
        IdRow INT IDENTITY(1, 1),
        DocumentoId INT
    );
	
    INSERT INTO @Documentos
    (
        DocumentoId
    )    
	SELECT splitdata
	FROM dbo.fnSplitString(@DctosEntregablesIdsContatenados,',')

	INSERT INTO @DocumentosG
    (
        DocumentoId
    )    
	SELECT splitdata
	FROM dbo.fnSplitString(@DctosGeneralesIdsContatenados,',')
	
	SELECT
		DocumentoEntregableId,
		idContratoEntregable,
		idInstanciaEntregable,
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta,
		CreadoPor,
		CreadoEl,
		ModificadoPor,
		ModificadoEl
	FROM EN_EntregableDocumento DOC
	JOIN @Documentos D
	ON DOC.DocumentoEntregableId=D.DocumentoId


	UNION ALL 

	 SELECT   
	  DOC.DocumentoId AS DocumentoEntregableId,  
	  0 AS idContratoEntregable,  
	  0 AS idInstanciaEntregable,  
	  Bucket,  
	  Folder,  
	  UUIDAmazon,  
	  NombreArchivo,  
	  Meta,  
	  CreadoPor,  
	  CreadoEl,  
	  ModificadoPor,  
	  ModificadoEl  
	 FROM EN_DocumentoGeneral DOC  
	 JOIN @DocumentosG D
	  ON DOC.DocumentoId=D.DocumentoId
	  	
	
END

