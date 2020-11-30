CREATE PROCEDURE SP_ObtenerReciboAdinco @IdFactura INT
AS
BEGIN

	CREATE TABLE #DOCUMENTO (
	PDF NVARCHAR(MAX),
	AWSPDFId INT,
	Bucket NVARCHAR(MAX),
	Folder  NVARCHAR(MAX),
	UUIDAmazon  NVARCHAR(MAX),
	NombreArchivo  NVARCHAR(MAX),
	Meta  NVARCHAR(MAX))
    
	INSERT INTO #DOCUMENTO	
    SELECT ISNULL(transf.PDF,'') AS PDF,
	ISNULL(AWSPDFId,0) AS AWSPDFId,
	aws.Bucket,
	aws.Folder,
	UPPER(aws.UUIDAmazon) AS UUIDAmazon,
	aws.NombreArchivo,
	aws.Meta
    FROM Adinco.dbo.FI_TransferFactura transFac
        LEFT JOIN Adinco.dbo.FI_Transfer transf
            ON transf.IdTransferencia = transFac.IdTransfer
		LEFT JOIN Adinco.dbo.AWS_Documentos aws ON aws.AWSDocumentoId = transf.AWSPDFId
    WHERE transFac.IdFactura = @IdFactura
	AND ISNULL(AWSPDFId,0) IS NOT NULL
	
	DECLARE @Result INT = 0

	SELECT @Result =COUNT(AWSPDFId) FROM #DOCUMENTO
	 
	IF @Result=0
	BEGIN 
	  INSERT INTO  #DOCUMENTO
	  SELECT 
	  ISNULL(TR.PDF,'') AS PDF,
		ISNULL(AWSPDFId,0) AS AWSPDFId,
		aws.Bucket,
		aws.Folder,
		UPPER(aws.UUIDAmazon) AS UUIDAmazon,
		aws.NombreArchivo,
		aws.Meta
	  FROM Adinco..FI_Factura FA
	  LEFT JOIN Adinco.dbo.FI_CPDocRelacionado dr ON dr.IdDocumento = FA.UUID
      JOIN Adinco.dbo.FI_ComplementoDePago cp ON cp.IdComplementoDePago = dr.IdComplementoDePago
      LEFT JOIN Adinco.dbo.FI_TransferFactura AS TRF ON TRF.IdFactura = cp.IdFactura
      LEFT JOIN Adinco.dbo.FI_Transfer AS TR ON TR.IdTransferencia = TRF.IdTransfer
	  LEFT JOIN Adinco.dbo.AWS_Documentos aws ON aws.AWSDocumentoId = TR.AWSPDFId
	  WHERE FA.IdFactura=@IdFactura
	  AND ISNULL(AWSPDFId,0) IS NOT NULL

	  SELECT 
		PDF,
		AWSPDFId,
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta
		FROM #DOCUMENTO
	END 
	ELSE 
	BEGIN 
		SELECT 
		PDF,
		AWSPDFId,
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta
		FROM #DOCUMENTO
	END 

	
END

