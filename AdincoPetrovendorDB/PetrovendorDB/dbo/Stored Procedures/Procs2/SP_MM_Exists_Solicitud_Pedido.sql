-- =============================================
-- Author:		Daniel AC
-- Create date: 15-09-2017 
-- Description:	Consultar una existencia de una solicitud de pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Exists_Solicitud_Pedido]
	-- Add the parameters for the stored procedure here
	@IdProveedor int,	
	@IdSolicitudPedido int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CONTADOR_SOLPED INT
    -- Insert statements for procedure here

	  SET @CONTADOR_SOLPED = (SELECT COUNT(IdSolicitudPedido) FROM dbo.MM_SolicitudPedido 
							  WHERE IdProveedor= @IdProveedor 
							  AND IdSolicitudPedido= @IdSolicitudPedido)
	 
	 SELECT ISNULL(@CONTADOR_SOLPED,0) 


END



