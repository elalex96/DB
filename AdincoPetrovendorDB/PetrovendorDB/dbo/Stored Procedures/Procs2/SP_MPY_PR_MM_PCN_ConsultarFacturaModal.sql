-- =============================================
-- Author:		Alexander Gomez
-- Create date: 20-06-2018
-- Description:	Consulta Aceptaciones que tengan una carta de contenido nacional aprobada para adjuntarle una factura
-- =============================================
CREATE procedure [dbo].[SP_MPY_PR_MM_PCN_ConsultarFacturaModal] --427,168,17
	-- Add the parameters for the stored procedure here
@IdProveedor int ,
@IdAceptacionPedido int,
@IdDocumento int  
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		DECLARE @Archivo NVARCHAR(300)
		DECLARE @IdArchivo int
		--DECLARE @IdAceptacionPedido int = 48
		--DECLARE @IdDocumento int = 18
		DECLARE @IdFactura INT = (SELECT IdFactura 
										FROM MPY_MM_AceptacionFactura 
										WHERE IdAceptacionPedido = @IdAceptacionPedido)
	
	DECLARE @IsFactura NVARCHAR(MAX)
	IF ISNULL(@IdFactura,0) > 0

	BEGIN 
	 
	  IF @IdDocumento = 17 
		 BEGIN 

			SET @IsFactura =(
			   SELECT ArchivoPDF FROM FI_FACTURA WHERE IdFactura = @IdFactura)

			   IF @IsFactura IS NULL 
					SET @IsFactura =(
						SELECT CASE WHEN [ComprobantePDFByte] IS NOT NULL
						THEN 'SI HAY FACTURA PDF' END 
						FROM FI_FACTURA WHERE IdFactura = @IdFactura)


			   IF @IsFactura IS NOT  NULL 
			   BEGIN 
				   SET @IdArchivo = @IdDocumento
				   SET @Archivo = 'Factura PDF'
				    SELECT @IdArchivo AS IdDocumento, @Archivo AS Documento
			   END 
		  END 
	    IF @IdDocumento = 18 
			BEGIN

				SET @IsFactura =(
			   SELECT XML FROM FI_FACTURA WHERE IdFactura = @IdFactura)

			   IF @IsFactura IS  NULL
					SET @IsFactura =(
						SELECT CASE WHEN [ComprobanteXMLByte] IS NOT NULL 
						THEN 'SI HAY ARCHIVO XML'
						END 
					 FROM FI_FACTURA WHERE IdFactura = @IdFactura)
				
			   IF @IsFactura IS NOT NULL  
			   BEGIN 
				 SET @IdArchivo = @IdDocumento
				  SET @Archivo ='Factura XML' 
				   SELECT @IdArchivo AS IdDocumento, @Archivo AS Documento
			   END 

				
			END 
	END 
	  
		 ---APC.IdEstatus=2 EStatus Aprobado 
  END;

  
