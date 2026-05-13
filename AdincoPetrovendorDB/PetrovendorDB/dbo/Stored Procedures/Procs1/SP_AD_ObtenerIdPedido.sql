
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ObtenerIdPedido]
	-- Add the parameters for the stored procedure here
	@IdSolPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT IdPedido FROM dbo.MM_Pedido WHERE IdSolicitudPedido = @IdSolPedido
END

