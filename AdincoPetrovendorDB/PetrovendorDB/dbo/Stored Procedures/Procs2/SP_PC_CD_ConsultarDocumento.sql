-- =============================================
-- Author:	DANIEL AC 
-- Create date: 19/04/2018
-- Description:	Consultar documento comprobante extranjero
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_CD_ConsultarDocumento]

@IdDocumento INT,
@IdContrato INT,
@IdProveedor INT
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 SELECT IdDocumento,DocumentoByte, NombreExtensionArchivo
	 FROM dbo.FI_Documento
	 WHERE IdDocumento=@IdDocumento

END
