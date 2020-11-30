
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <15/04/2020>
-- Description:	<Consulta de lineas de presupuesto por aceptacion detalle>
-- =============================================
CREATE PROCEDURE [dbo].[SP_APR_ConsultaLineasPresupuestoAceptacionDetalle] --2950
	-- Add the parameters for the stored procedure here
	@IdAceptacionPedidoDetalle INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IDPRESUPUESTO INT;
    -- Insert statements for procedure here
	SET @IDPRESUPUESTO = ( SELECT TOP 1
							SP.IdPresupuesto
						FROM dbo.MM_AceptacionPedidoDetalle AS APD
							LEFT JOIN dbo.MM_PedidoDetalle AS PD
								ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
							LEFT JOIN dbo.MM_PeticionOfertaDetalle AS POD
								ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
							LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
								ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
							LEFT JOIN dbo.MM_SolicitudPedido AS SP
								ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido
						WHERE APD.IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle
						GROUP BY SP.IdPresupuesto);




	EXEC Adinco.dbo.CO_SP_ConsultaLineaPresupuestoMesv2_Reclasificacion_APD @presupuesto = @IDPRESUPUESTO;



END
