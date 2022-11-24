--[dbo].[EN_SHELL_ObtenerDetalleDocumentosEntregables] '','1,2,3,4,5'
CREATE PROCEDURE [dbo].[EN_SHELL_ObtenerDetalleDocumentosEntregables] 
@DctosEntregablesIdsContatenados NVARCHAR(MAX),
@DctosGeneralesIdsContatenados NVARCHAR(MAX),
@DctosPersonalizadosIdsContatenados NVARCHAR(MAX)
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

	DECLARE @DocumentosP AS TABLE
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

	INSERT INTO @DocumentosP
    (
        DocumentoId
    )    
	SELECT splitdata
	FROM dbo.fnSplitString(@DctosPersonalizadosIdsContatenados,',')
	
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

	UNION ALL 

	SELECT   
	  DOC.ID AS DocumentoEntregableId,  
	  0 AS idContratoEntregable,  
	  0 AS idInstanciaEntregable,  
	  DOC.Bucket,  
	  DOC.Folder,  
	  DOC.UUIDAmazon,  
	  DOC.NombreArchivo,  
	  DOC.Meta,  
	  DOC.CargadoPor,  
	  DOC.FechaCarga,  
	  NULL,  
	  NULL  
	 FROM CarpetasDocumentosEntregables DOC  
	 JOIN @DocumentosP D
	  ON DOC.ID=D.DocumentoId
	  	
	
END