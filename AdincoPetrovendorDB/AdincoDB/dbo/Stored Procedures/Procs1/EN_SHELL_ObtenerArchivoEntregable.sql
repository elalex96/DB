CREATE PROCEDURE [dbo].[EN_SHELL_ObtenerArchivoEntregable]    
	@ContratoId INT,
	@DocumentoId INT,
	@Origen NVARCHAR(max)

AS
BEGIN
		
	IF @Origen = 'ENTREGABLES'
	BEGIN
	  SELECT   
	  DOC.DocumentoEntregableId,  
	  DOC.idContratoEntregable,  
	  DOC.idInstanciaEntregable,  
	  DOC.Bucket,  
	  DOC.Folder,  
	  DOC.UUIDAmazon,  
	  DOC.NombreArchivo,  
	  DOC.Meta,  
	  DOC.CreadoPor,  
	  DOC.CreadoEl,  
	  DOC.ModificadoPor,  
	  DOC.ModificadoEl  
	 FROM EN_EntregableDocumento DOC  
	 JOIN EN_ContratoEntregable CE
	 ON DOC.IdContratoEntregable = CE.IdContratoEntregable
	 WHERE DOC.DocumentoEntregableId = @DocumentoId
	 AND CE.IdContrato = @ContratoId

	END
	
	IF @Origen = 'GENERAL'
	BEGIN

	  SELECT   
	  DocumentoId AS DocumentoEntregableId,  
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
	 FROM EN_DocumentoGeneral doc  
	 WHERE DocumentoId =@DocumentoId
	 AND ContratoId=@ContratoId

	END

	IF @Origen = 'CARGADO_USUARIO'
	BEGIN

	  SELECT   
	  ID AS DocumentoEntregableId,  
	  0 AS idContratoEntregable,  
	  0 AS idInstanciaEntregable,  
	  Bucket,  
	  Folder,  
	  UUIDAmazon,  
	  NombreArchivo,  
	  Meta,  
	  CargadoPor,  
	  FechaCarga,
	  NULL,
	  NULL
	 FROM CarpetasDocumentosEntregables doc  
	 WHERE ID = @DocumentoId
	 AND IdContrato = @ContratoId

	END



 END