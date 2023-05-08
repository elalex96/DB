-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Pedido  
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaSigReciclada]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido int 
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	SELECT IdSolPedNueva
	FROM TA_RecicajeSolPed 
	WHERE IdSolPedAnterior = @IdSolicitudPedido

END

