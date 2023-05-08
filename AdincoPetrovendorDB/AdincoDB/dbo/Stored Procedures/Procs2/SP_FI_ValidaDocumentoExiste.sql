-- =============================================
-- Author:	Josue Glez
-- Create date: 6-03-17
-- Description:	
-- =============================================
Create PROCEDURE [dbo].[SP_FI_ValidaDocumentoExiste]
	-- Add the parameters for the stored procedure here
	@IdFactura int,
	@IdTipoDocumento int

AS
BEGIN
	SET NOCOUNT ON;

	select count(*) from dbo.fi_documento 
	where idFactura = @IdFactura
	and idTipoDocumento = @IdTipoDocumento
END