-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarIdPedidoPorOperacion]
@IdOperacion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT AP.IdPedido
	FROM dbo.MM_AceptacionFactura AF
	INNER JOIN dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
	INNER JOIN dbo.TA_Operacion TAO ON TAO.IdDocumento = AF.IdAceptacionFactura
	WHERE  TAO.IdOperacion = @IdOperacion


END
