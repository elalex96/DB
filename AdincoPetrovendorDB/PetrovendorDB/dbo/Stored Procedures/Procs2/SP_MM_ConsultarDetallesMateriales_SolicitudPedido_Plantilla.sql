-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <21/11/2019>
-- Description:	<consultar los detalles de los materiales de una plantilla de solicitud de pedido>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarDetallesMateriales_SolicitudPedido_Plantilla]
	-- Add the parameters for the stored procedure here
	@IdPlantillaSolicitudPedidoDetalle INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		SPD.IdLineaPresupuesto,
		SPD.IdCentroCosto,
		SPD.IdInstalacion,
		SPD.IdLineaPresupuesto
	FROM dbo.MM_Plantilla_SolicitudPedidoDetalle AS SPD
	WHERE SPD.IdPlantillaSolicitudPedidoDetalle = @IdPlantillaSolicitudPedidoDetalle;
END
