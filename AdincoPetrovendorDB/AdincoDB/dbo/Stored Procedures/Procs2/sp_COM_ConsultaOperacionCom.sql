-- =============================================
-- Author:		Miguel Gomez
-- Create date: 2017-01-01
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_COM_ConsultaOperacionCom] 
	-- Add the parameters for the stored procedure here
	@IdOperacionComercailizacion int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT        IdOperacionComercializacion, IdContrato, MesReporte, FechaTransaccion, IdTipoHidrocarburo, VolumenVendido, PrecioVentaUnitario, CostoUnitarioComercializacion, PrecioPuntoMedicion, IdFactura, 
                         NumeroFolioPedimento, EPT, OperacionBajoReglasMercado, ClasificacionDocumentoSoporte
FROM            COM_OperacionComercializacion

where IdOperacionComercializacion = @IdOperacionComercailizacion
END
