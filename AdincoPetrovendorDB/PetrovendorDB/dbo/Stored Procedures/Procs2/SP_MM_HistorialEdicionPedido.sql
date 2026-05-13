-- =============================================
-- Author:		Alexander Gomez
-- Create date: 17/10/2022
-- Description:	Historial de edicion del pedido
-- =============================================
create PROCEDURE [dbo].[SP_MM_HistorialEdicionPedido]
	-- Add the parameters for the stored procedure here
	@IdPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		HD.IdHistorial,
		HD.Fecha,
		HD.Descripcion,
		US.Nombre
	FROM TA_HistorialEdicionPedidoDetalle AS HD
		JOIN S_Usuario AS US
			ON HD.IdUsuario = US.IdUsuario
	WHERE IdPedido = @IdPedido
	ORDER BY HD.Fecha DESC;

END
