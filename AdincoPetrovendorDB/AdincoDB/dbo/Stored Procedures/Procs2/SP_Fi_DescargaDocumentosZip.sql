CREATE PROCEDURE [dbo].[SP_Fi_DescargaDocumentosZip]
@IdContrato int,
@InitialD date,
@FinalD DATE,
@TipoDoc int=0
AS 
BEGIN 

IF @TipoDoc = 0  
BEGIN
SELECT 
		FI_F.IdFactura,
		FIAX.ArchivoXML as xml,
		CASE WHEN FI_F.UUID IS NULL OR FI_F.UUID = '' THEN '00-0-00' ELSE FI_F.UUID end AS ArchivoXML
    FROM
		FI_Factura	FI_F (NOLOCK)
	JOIN
		FI_ArchivoXml	FIAX (NOLOCK) 
		ON FI_F.IdFactura	=	FIAX.IdFactura
		WHERE FI_F.IdContrato = 3
		and FI_F.FechaTimbrado Between @InitialD and @FinalD
END

IF @TipoDoc = 1
BEGIN

SELECT
  TR.IdTransferencia,
  TR.IdContrato AS IdContrato,
  CASE
    WHEN TR.NombreExtencionArchivo IS NULL OR
      TR.NombreExtencionArchivo = '' THEN CONCAT('PDF-T-', TR.IdTransferencia)
    ELSE TR.NombreExtencionArchivo
  END AS NombreArchivo
FROM dbo.fi_transfer tr
WHERE 
tr.FechaPago Between @InitialD and @FinalD 
AND tr.IdContrato = @IdContrato
END		
end
