-- =============================================
-- Author:		Alexander
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Pedido  
-- =============================================
CREATE PROCEDURE [dbo].[SP_ContarRequisiciones]
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	SELECT 
	COUNT(CASE SP.IdEstado WHEN 1 THEN 1 ELSE NULL END) AS ReqPendientes,
	COUNT(CASE SP.IdEstado WHEN 2 THEN 1 ELSE NULL END) AS ReqAprobados,
	COUNT(CASE SP.IdEstado WHEN 3 THEN 1 ELSE NULL END) AS ReqRechazada
	FROM MM_SolicitudPedido AS SP
	WHERE 
	SP.IdUsuarioSolicitante = @IdUsuario AND 
	SP.IdProveedor = @IdProveedor

END

