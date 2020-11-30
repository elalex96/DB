-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21/12/2018
-- Description:	Consulta de datos para descargar un documento de factura de pedido
-- =============================================
CREATE procedure [dbo].[SP_MPY_DatosDocFacturaPedido]
	-- Add the parameters for the stored procedure here
	@IdDoc INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		NombreDoc,
		Extension,
		Mime,
		Identificador,
		Carpeta
	FROM dbo.MPY_FI_RelacionPedimentoComprobantePedido
	WHERE IdRelacionPedimentoComprobante = @IdDoc
END
