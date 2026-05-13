-- =============================================
-- Author:		Daniel A Cruz
-- Create date:24/09/2019
-- Description:	Agregar IdLector de la factura y el ErrorSAT si existe 
-- =============================================
CREATE PROCEDURE  [dbo].[SP_FI_AgregarErrorSATws] 
	-- Add the parameters for the stored procedure here

@IdFactura int, 
@IdLectorFinal int,
@EstatusSAT NVARCHAR(MAX)

 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	UPDATE dbo.FI_Factura
	SET ErroSAT=@EstatusSAT,
	IdLectorXMLSAT=@IdLectorFinal
	WHERE IdFactura=@IdFactura
	

END
 
