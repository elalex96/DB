-- =============================================
-- Author:		Alexander
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Pedido  
-- =============================================
CREATE PROCEDURE [dbo].[SP_ContarPedidos]
	-- Add the parameters for the stored procedure here
	@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	SELECT 
	COUNT(CASE P.Aprobado WHEN 1 THEN 1 ELSE NULL END) AS PedidosAprobados,
	COUNT(CASE P.Aprobado WHEN 0 THEN 1 ELSE NULL END) AS PedidosPendientes
	FROM MM_Pedido AS P
	WHERE  
	P.IdSubcontratista = @IdProveedor

END

