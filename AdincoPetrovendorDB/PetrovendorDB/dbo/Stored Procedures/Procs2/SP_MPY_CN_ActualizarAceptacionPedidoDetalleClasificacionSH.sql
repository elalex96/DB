-- =============================================
-- Author:		Alexander Gomez
-- Create date: 05/06/2018
-- Description: Actualizacion de los conceptos en el campo de clasificacionSH
-- =============================================
CREATE procedure [dbo].[SP_MPY_CN_ActualizarAceptacionPedidoDetalleClasificacionSH] 
	-- Add the parameters for the stored procedure here
	@IdAceptacionDetalle INT,
	@IdClasificacionCN INT,
	@Rechazado BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	IF @Rechazado = 1
	BEGIN
		UPDATE dbo.MPY_MM_AceptacionPedidoDetalle
			SET ClasificacionCN = NULL
		WHERE IdAceptacionPedido = @IdAceptacionDetalle
	END
	ELSE
	BEGIN
		UPDATE dbo.MPY_MM_AceptacionPedidoDetalle
			SET ClasificacionCN = @IdClasificacionCN
		WHERE IdAceptacionPedidoDetalle = @IdAceptacionDetalle
	END
	
END
