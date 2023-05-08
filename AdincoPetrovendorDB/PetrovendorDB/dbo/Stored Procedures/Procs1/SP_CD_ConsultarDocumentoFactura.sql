-- =============================================
-- Author:		Daniel AC
-- Create date: 16/11/2017
-- Description: 
-- =============================================
CREATE PROCEDURE [dbo].[SP_CD_ConsultarDocumentoFactura]
	-- Add the parameters for the stored procedure here
	@IdFactura INT, 
	@Tipo NVARCHAR(MAX)
	 
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 IF @Tipo='PDF'
	 BEGIN
	 		
		SELECT ISNULL([ArchivoPDF],''), 'Factura_'+CAST(@IdFactura AS NVARCHAR(300)),ComprobantePDFByte
		FROM [dbo].[FI_Factura]
		WHERE [IdFactura]=@IdFactura


	 END

	 IF @Tipo='XML'
	 BEGIN
		SELECT ISNULL([XML],''), 'Factura_'+CAST(@IdFactura AS NVARCHAR(300))
		FROM [dbo].[FI_Factura]
		WHERE [IdFactura]=@IdFactura
	 END
	 

	 
END


