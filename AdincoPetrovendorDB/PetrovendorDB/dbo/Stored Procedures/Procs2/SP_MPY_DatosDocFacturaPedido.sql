-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21/12/2018
-- Description:	Consulta de datos para descargar un documento de factura de pedido
-- =============================================
-- =============================================
-- Author:	Luis David De La Cruz 
-- Create date: 08/09/2021
-- Description:	Se agrega el bucket en la descarga para la estandarización de descarga amazon s3
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
		Carpeta,
		Isnull(Bucket,'') as Bucket
	FROM dbo.MPY_FI_RelacionPedimentoComprobantePedido
	WHERE IdRelacionPedimentoComprobante = @IdDoc
END
