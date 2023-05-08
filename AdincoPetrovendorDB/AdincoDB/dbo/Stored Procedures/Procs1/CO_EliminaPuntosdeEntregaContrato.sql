-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07/03/18
-- Description: Elimina los puntos de entrega-contrato
-- =============================================
CREATE PROCEDURE CO_EliminaPuntosdeEntregaContrato
	-- Add the parameters for the stored procedure here
	@PuntoEntregaContratoID int,
	@idContrato int=0,
	@idUsuario int=0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM CO_PuntosdeEntregaContrato
		 WHERE (PuntoEntregaContratoID = @PuntoEntregaContratoID)
END

