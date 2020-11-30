-- =============================================
-- Author:		Daniel AC
-- Create date: 27/04/2018
-- Description:	CONSULTAR LOS DOCUMENTOS DE LA TABLA x 
CREATE PROCEDURE [dbo].[SP_AD_S3_ConsultarDocumentosTabla] 
	-- Add the parameters for the stored procedure here	

AS
	
BEGIN				
 
  DECLARE @MM_SolPedArchivoAdjuntoMaterial_ISNULL INT  =0 
  DECLARE @MM_SolPedArchivoAdjuntoMaterial_ALL INT  =0 
 DECLARE @MM_SolPedArchivoAdjuntoMaterial INT  =0 

  SELECT @MM_SolPedArchivoAdjuntoMaterial_ALL =COUNT(IdSolPedMaterialDocumentoAdj)  
  FROM dbo.MM_SolPedArchivoAdjuntoMaterial
	
  SELECT @MM_SolPedArchivoAdjuntoMaterial_ISNULL =COUNT(IdSolPedMaterialDocumentoAdj)  
  FROM dbo.MM_SolPedArchivoAdjuntoMaterial
  WHERE Identificador IS NOT NULL

  SELECT @MM_SolPedArchivoAdjuntoMaterial =COUNT(IdSolPedMaterialDocumentoAdj)  
  FROM dbo.MM_SolPedArchivoAdjuntoMaterial
 

  DECLARE @MM_DocumentosSolPed_ALL INT  =0 
  DECLARE @MM_DocumentosSolPed_ISNULL INT  =0 
  DECLARE @MM_DocumentosSolPed INT =0

  SELECT @MM_DocumentosSolPed_ALL = COUNT(IdDocumento) FROM dbo.MM_DocumentosSolPed
  SELECT @MM_DocumentosSolPed_ISNULL = COUNT(IdDocumento) FROM dbo.MM_DocumentosSolPed 
  WHERE Identificador IS NOT NULL
  SELECT @MM_DocumentosSolPed = COUNT(IdDocumento) FROM dbo.MM_DocumentosSolPed 
 

   /*PARA VER SI YA SE PASARON TODOS LOS DOCUMENTOS DE S_DOCUMENTO A S_DOCUMENTO_S3*/
    CREATE TABLE #S_DOCUMENTO_ALTER( IdTipoDocumento INT , NombreTipoDocumento NVARCHAR(max), cantidad INT , cantidadS3 INT) 
    CREATE TABLE #S_DOCUMENTOS3_ALTER( IdTipoDocumento INT , NombreTipoDocumento NVARCHAR(max), cantidad INT) 

    INSERT INTO #S_DOCUMENTO_ALTER(IdTipoDocumento,NombreTipoDocumento,cantidad,cantidadS3) 
	SELECT T1.IdTipoDocumento,T1.NombreTipoDocumento+ '  (Tabla S_Documento --> S_Documento_S3)', COUNT(D.IdDocumento),0
	FROM dbo.S_TipoDocumento  T1
	INNER JOIN dbo.S_Documento D ON T1.IdTipoDocumento = D.IdTipoDocumento	
	---WHERE D.IdDocumentoS3 IS NULL /*SI ES  NULL ENTONCES NO HA SIDO ENVIADO A S_DOCUMENTO_S3*/
	GROUP BY T1.IdTipoDocumento,T1.NombreTipoDocumento
	ORDER BY T1.NombreTipoDocumento

	INSERT INTO #S_DOCUMENTOS3_ALTER (IdTipoDocumento,NombreTipoDocumento, cantidad)  
	SELECT T1.IdTipoDocumento,T1.NombreTipoDocumento+'/S_DOCUMENTO_S3', COUNT(D.IdDocumento)
	FROM dbo.S_TipoDocumento  T1
	INNER JOIN dbo.S_Documento_S3 D ON T1.IdTipoDocumento = D.IdTipoDocumento	
	WHERE D.Duplicado IS NOT NULL  /*SI ES DIFERENTE DE NULL ENTONCES YA FUE ENVIADO DE S_DOCUMENTO*/
	GROUP BY T1.IdTipoDocumento,T1.NombreTipoDocumento
	ORDER BY T1.NombreTipoDocumento

	UPDATE D
	SET D.cantidadS3=D3.cantidad 
	FROM #S_DOCUMENTO_ALTER D
	INNER JOIN #S_DOCUMENTOS3_ALTER D3 ON D3.IdTipoDocumento=D.IdTipoDocumento


	/*TOTAL DE S_DOCUMENTOS A S_DOCUMENTOS_S3*/
	DECLARE @S_Documento_ALL INT  =0 
    DECLARE @S_Documento_S3_ISNULL INT  =0 
	DECLARE @S_Documento INT  =0 
	DECLARE @S_Documento_s3 INT  =0 


	SELECT @S_Documento_ALL =COUNT(IdDocumento),@S_Documento=COUNT(IdDocumento) FROM dbo.S_Documento
	SELECT  @S_Documento_S3_ISNULL=COUNT(s.IdDocumentoS3) 
	FROM dbo.S_Documento s
	LEFT JOIN dbo.S_Documento_S3 s3 ON CAST(s.IdDocumento AS NVARCHAR(MAX))=s3.Duplicado	
	WHERE s3.Identificador IS NOT NULL AND  s3.Duplicado IS NOT NULL 
	--SELECT @S_Documento_S3_ISNULL= COUNT(IdDocumento) 
	--FROM dbo.S_Documento_S3 WHERE Identificador IS NOT NULL AND  Duplicado IS NOT NULL 
	SELECT @S_Documento_s3 =COUNT(IdDocumento) FROM dbo.S_Documento_S3

	/*TOTALES DE TA_DocFianzaOperacion*/
	DECLARE @TA_DocFianzaOperacion_ALL INT  =0 
    DECLARE @TA_DocFianzaOperacion_ISNULL INT  =0 
	DECLARE @TA_DocFianzaOperacion INT  =0 
	
	SELECT @TA_DocFianzaOperacion_ALL = COUNT(IdDocFianza) FROM TA_DocFianzaOperacion WHERE LEN(Documento)>0
	SELECT @TA_DocFianzaOperacion_ISNULL=COUNT(IdDocFianza) FROM TA_DocFianzaOperacion WHERE Identificador IS NOT NULL AND AMS3=1 AND  LEN(Documento)>0
	SELECT @TA_DocFianzaOperacion = COUNT(IdDocFianza) FROM TA_DocFianzaOperacion 

	/*TOTALES DE TA_DocFianzaOperacion*/
	DECLARE @TA_DocBasesOperacion_ALL INT  =0 
    DECLARE @TA_DocBasesOperacion_ISNULL INT  =0 
	DECLARE @TA_DocBasesOperacion INT  =0 

	SELECT @TA_DocBasesOperacion_ALL = COUNT(IdDocBases) FROM TA_DocBasesOperacion WHERE  LEN(Documento)>0 
	SELECT @TA_DocBasesOperacion_ISNULL=COUNT(IdDocBases) FROM TA_DocBasesOperacion WHERE Identificador IS NOT NULL AND AMS3=1 AND LEN(Documento)>0 
    SELECT @TA_DocBasesOperacion = COUNT(IdDocBases) FROM TA_DocBasesOperacion 

	/*TOTALES DE  MM_DocumentosAnexos --> DE COTIZACIÓN POR DETALLE DEL MATERIAL */
	DECLARE @MM_DocumentosAnexos_ALL INT  =0 
    DECLARE @MM_DocumentosAnexos_ISNULL INT  =0 
	DECLARE @MM_DocumentosAnexos INT  =0 

	SELECT @MM_DocumentosAnexos_ALL = COUNT(IdDocumentoAnexo) FROM MM_DocumentosAnexos WHERE  LEN(Documento)>0 
	SELECT @MM_DocumentosAnexos_ISNULL  =COUNT(IdDocumentoAnexo) FROM MM_DocumentosAnexos WHERE Identificador IS NOT NULL AND AMS3=1 AND LEN(Documento)>0 
	SELECT @MM_DocumentosAnexos = COUNT(IdDocumentoAnexo) FROM MM_DocumentosAnexos 

	/*TOTALES DE  MM_DocumentosAnexos --> DE COTIZACIÓN POR DETALLE DEL MATERIAL */
	DECLARE @MM_DocAnexosPeticionOferta_ALL INT  =0 
    DECLARE @MM_DocAnexosPeticionOferta_ISNULL INT  =0 
    DECLARE @MM_DocAnexosPeticionOferta INT  =0 

	SELECT @MM_DocAnexosPeticionOferta_ALL =COUNT(IdDocAnexoPeticionOferta) FROM MM_DocAnexosPeticionOferta WHERE  LEN(Documento)>0 
	SELECT @MM_DocAnexosPeticionOferta_ISNULL     =COUNT(IdDocAnexoPeticionOferta) FROM MM_DocAnexosPeticionOferta WHERE Identificador IS NOT NULL AND AMS3=1 AND LEN(Documento)>0 
	SELECT @MM_DocAnexosPeticionOferta =COUNT(IdDocAnexoPeticionOferta) FROM MM_DocAnexosPeticionOferta  

	/*TOTALES DE  MM_DocSoporteRecepcionFactura --> DE RECEPCION FACTURA SOPORTES */
	DECLARE @MM_DocSoporteRecepcionFactura_ALL INT  =0 
    DECLARE @MM_DocSoporteRecepcionFactura_ISNULL INT  =0 
    DECLARE @MM_DocSoporteRecepcionFactura INT  =0 

	SELECT @MM_DocSoporteRecepcionFactura_ALL =COUNT(IdDocSoporteRecepcionFactura) FROM MM_DocSoporteRecepcionFactura WHERE LEN(Documento)>0
	SELECT @MM_DocSoporteRecepcionFactura_ISNULL     =COUNT(IdDocSoporteRecepcionFactura) FROM MM_DocSoporteRecepcionFactura WHERE Identificador IS NOT NULL AND AMS3=1  AND LEN(Documento)>0
	SELECT @MM_DocSoporteRecepcionFactura =COUNT(IdDocSoporteRecepcionFactura) FROM MM_DocSoporteRecepcionFactura 

	/*TOTALES DE  MM_PeticionOferta --> DE ANEXOS DE ADJUDICACION UNICA */
	DECLARE @MM_PeticionOferta_ALL INT  =0 
    DECLARE @MM_PeticionOferta_ISNULL INT  =0 
	DECLARE @MM_PeticionOferta INT  =0 

	SELECT @MM_PeticionOferta_ALL =COUNT(IdPeticionOferta) FROM dbo.MM_PeticionOferta WHERE  LEN(DocAdjudicacionDirecta)>0 
	SELECT @MM_PeticionOferta_ISNULL     = COUNT(IdPeticionOferta) FROM dbo.MM_PeticionOferta WHERE   AMS3=1 AND  LEN(DocAdjudicacionDirecta)>0 
	SELECT @MM_PeticionOferta =COUNT(IdPeticionOferta) FROM dbo.MM_PeticionOferta 

	/*TOTALES DE CF_EdoCuentaDocumentos */
	DECLARE @CF_EdoCuentaDocumentos_ISNULL INT  =0 
    DECLARE @CF_EdoCuentaDocumentos_ALL INT  =0 
    DECLARE @CF_EdoCuentaDocumentos INT  =0 

	SELECT @CF_EdoCuentaDocumentos_ALL =COUNT(IdEdoCuenta) FROM dbo.CF_EdoCuentaDocumentos WHERE  LEN(EdoCuenta)>0 
	SELECT  @CF_EdoCuentaDocumentos_ISNULL  = COUNT(IdEdoCuenta) FROM dbo.CF_EdoCuentaDocumentos WHERE    AMS3=1 AND LEN(EdoCuenta)>0 
	SELECT @CF_EdoCuentaDocumentos =COUNT(IdEdoCuenta) FROM dbo.CF_EdoCuentaDocumentos 
	
	/*TOTALES DE Pv_DocSoporte_CompraDirecta */
	DECLARE @Pv_DocSoporte_CompraDirecta_ISNULL INT  =0 
    DECLARE @Pv_DocSoporte_CompraDirecta_ALL INT  =0 
	DECLARE @Pv_DocSoporte_CompraDirecta INT  =0 

	SELECT @Pv_DocSoporte_CompraDirecta_ALL  =COUNT(id) FROM dbo.Pv_DocSoporte_CompraDirecta WHERE  LEN(documento)>0 
	SELECT @Pv_DocSoporte_CompraDirecta_ISNULL = COUNT(id) FROM dbo.Pv_DocSoporte_CompraDirecta WHERE  AMS3=1 AND LEN(documento)>0 
	SELECT @Pv_DocSoporte_CompraDirecta  =COUNT(id) FROM dbo.Pv_DocSoporte_CompraDirecta 
	
	/*PV_SistemaGestion*/
	DECLARE @PV_SistemaGestion_ISNULL INT  =0 
    DECLARE @PV_SistemaGestion_ALL INT  =0 
	DECLARE @PV_SistemaGestion INT  =0 

	SELECT @PV_SistemaGestion_ALL  =COUNT(IdSistemaGestion) FROM dbo.PV_SistemaGestion WHERE  LEN(Documento)>0 
	SELECT @PV_SistemaGestion_ISNULL = COUNT(IdSistemaGestion) FROM dbo.PV_SistemaGestion WHERE   AMS3=1 AND LEN(Documento)>0  
	SELECT @PV_SistemaGestion  =COUNT(IdSistemaGestion) FROM dbo.PV_SistemaGestion 


	SELECT CONCAT(@MM_SolPedArchivoAdjuntoMaterial_ISNULL,'/',@MM_SolPedArchivoAdjuntoMaterial_ALL,'/',@MM_SolPedArchivoAdjuntoMaterial) AS Estatus, 'Tabla MM_SolPedArchivoAdjuntoMaterial' AS Tabla
	UNION ALL 
	SELECT CONCAT(@MM_DocumentosSolPed_ISNULL,'/',@MM_DocumentosSolPed_ALL,'/',@MM_DocumentosSolPed) AS Estatus, 'Tabla MM_DocumentosSolPed' AS Tabla 
	UNION ALL
	SELECT CONCAT(@S_Documento_S3_ISNULL, '/' , @S_Documento_ALL,'/',@S_Documento,'-->S_Documento_S3: ',@S_Documento_s3) AS Estatus, 'Tabla S_Documento --> S_Documento_S3' AS Tabla	
	UNION ALL
	SELECT CONCAT(@TA_DocFianzaOperacion_ISNULL,'/',@TA_DocFianzaOperacion_ALL,'/',@TA_DocFianzaOperacion) AS Estatus, 'Tabla TA_DocFianzaOperacion' AS Tabla 
	UNION ALL
	SELECT CONCAT(@TA_DocBasesOperacion_ISNULL,'/',@TA_DocBasesOperacion_ALL,'/',@TA_DocBasesOperacion) AS Estatus, 'Tabla TA_DocBasesOperacion' AS Tabla 
	UNION ALL
	SELECT CONCAT(@MM_DocumentosAnexos_ISNULL,'/',@MM_DocumentosAnexos_ALL,'/',@MM_DocumentosAnexos) AS Estatus, 'Tabla MM_DocumentosAnexos' AS Tabla 
	UNION ALL
	SELECT CONCAT(@MM_DocAnexosPeticionOferta_ISNULL,'/',@MM_DocAnexosPeticionOferta_ALL,'/',@MM_DocAnexosPeticionOferta) AS Estatus, 'Tabla MM_DocAnexosPeticionOferta' AS Tabla 
	UNION ALL
	SELECT CONCAT(@MM_DocSoporteRecepcionFactura_ISNULL,'/',@MM_DocSoporteRecepcionFactura_ALL,'/',@MM_DocSoporteRecepcionFactura) AS Estatus, 'Tabla MM_DocSoporteRecepcionFactura' AS Tabla 
	UNION ALL 
	SELECT CONCAT(@MM_PeticionOferta_ISNULL,'/',@MM_PeticionOferta_ALL,'/',@MM_PeticionOferta) AS Estatus, 'Tabla MM_PeticionOferta --> MM_PeticionOfertaADAdjunto' AS Tabla 
	UNION ALL 
	SELECT CONCAT(@CF_EdoCuentaDocumentos_ISNULL,'/',@CF_EdoCuentaDocumentos_ALL,'/',@CF_EdoCuentaDocumentos,' (NUEVA)') AS Estatus, '(NUEVA) Tabla CF_EdoCuentaDocumentos  --> (Se actualizan referencias al S3)' AS Tabla 
	UNION ALL 
	SELECT CONCAT(@Pv_DocSoporte_CompraDirecta_ISNULL,'/',@Pv_DocSoporte_CompraDirecta_ALL,'/',@Pv_DocSoporte_CompraDirecta,' (NUEVA)') AS Estatus, ' (NUEVA)  Tabla Pv_DocSoporte_CompraDirecta--> (Se actualizan referencias al S3)' AS Tabla 
	UNION ALL 
	SELECT CONCAT(@PV_SistemaGestion_ISNULL,'/',@PV_SistemaGestion_ALL,'/',@PV_SistemaGestion,' (NUEVA)') AS Estatus, '(NUEVA) Tabla PV_SistemaGestion  --> (Se actualizan referencias al S3)' AS Tabla 

	
	/*SUBTABLA DE S_DOCUMENTOS*/
	
	UNION ALL 
	SELECT CONCAT('-->',D.cantidadS3,'/',D.cantidad) AS Estatus, '-->'+D.NombreTipoDocumento AS Tabla FROM  #S_DOCUMENTO_ALTER	D  
END


