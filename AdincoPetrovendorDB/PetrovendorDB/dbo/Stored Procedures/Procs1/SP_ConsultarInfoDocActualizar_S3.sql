-- =============================================
-- Author:		DANIEL AC
-- Create date: 26/04/2018
-- Description:	CONSULTAR EL DI DEL MATERIAL A ACTUALIZAR
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarInfoDocActualizar_S3]
@IdDocumento INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT 
	  IdTipoDocumento,
      IdTipoValidacionDocumento
	FROM dbo.S_Documento_S3
	WHERE IdDocumento = @IdDocumento
END