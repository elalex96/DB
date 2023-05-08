
-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 03-04-2017
-- Description:	 Consultar el documento de la operacion
-- =============================================

CREATE PROCEDURE [dbo].[SP_PC_ConsultarComprobantePDF] 
	-- Add the parameters for the stored procedure here
	

	@IdPedimentoComprobante INT,
	@IdUsuario INT, 
	@IdProveedor INT,
	@IdContrato INT 


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT IdDocumento, DocumentoByte,NombreExtensionArchivo
	FROM dbo.FI_Documento
	WHERE IdPedimentoComprobante=@IdPedimentoComprobante
	AND IsEliminado =0 
	

 END


