-- =============================================
-- Author:		Daniel AC
-- Create date: 24-06-17
-- Description:	CONSULTA Aceptación Servicio/Material
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaAceptacionServicioMaterial]
	-- Add the parameters for the stored procedure here
	@IdPedidoDetalle int
 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT ISNULL(AceptacionServicio,0) AS AceptacionServicio
	FROM MM_PedidoDetalle
	WHERE IdPedidoDetalle = @IdPedidoDetalle


END

