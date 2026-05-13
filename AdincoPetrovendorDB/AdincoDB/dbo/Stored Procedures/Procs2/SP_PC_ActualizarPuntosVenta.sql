-- =============================================
-- Author:		Manuel CD
-- Create date: 27-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ActualizarPuntosVenta] 
	-- Add the parameters for the stored procedure here
	@PuntosVenta INT,
	@IdUsuario   INT,
	@IdContrato  INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--UPDATE PC_PuntoVentaProducto SET Aplica = 0 
		
	UPDATE PC_PuntoVentaProducto SET Aplica = 1 WHERE IdPuntoVentaProducto = @PuntosVenta
END


--select * from PC_PuntoVentaProducto