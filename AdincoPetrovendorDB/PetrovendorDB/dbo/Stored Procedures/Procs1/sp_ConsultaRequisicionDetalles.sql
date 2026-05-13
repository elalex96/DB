-- =============================================
-- Author:		Alexander G
-- Create date: 27-06-17
-- Description:	Consultar Detalles de flujo tarea especifico 
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConsultaRequisicionDetalles]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	SELECT 
	IdMaterial, Cantidad, observaciones
	 FROM MM_SolicitudPedidoDetalle
	 WHERE IdSolicitudPedido = @IdSolicitudPedido

END

