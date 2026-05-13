-- =============================================
-- Author:		<Ronal>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Update date: 10/01/2018 5:36 PM
-- Description:	CAMBIE CONSULTA PARA DETERMINAR CUANTAS COTIZACIONES TIENE PENDIENTES UN PROVEEDOR Y QUE NO ESTEN VENCIDAS 
-- =============================================
CREATE PROCEDURE [dbo].[SP_IndicadorCotizacionesPendiente] 
	-- Add the parameters for the stored procedure here
	@IdProveedor  int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	---SELECT COUNT(*) as 'No Finalizado'  from MM_PeticionOferta where Finalizado=0 and idSubcontratista=@IdProveedor and Activo = NULL
	SELECT COUNT(*) AS 'No Finalizado' 
	FROM MM_PeticionOferta PO
	INNER JOIN TA_Operacion O ON O.IdDocumento = PO.IdSolicitudPedido
	WHERE  PO.IdSubcontratista=@IdProveedor
	AND O.IdTipoOperacion=6 ---COTIZACIÓN
	AND Activo=1 AND (DATEDIFF(MINUTE,O.FechaFinalizacion, GETDATE())  <= 0) ---ESTE VIGENTE LA COTIZACIÓN
	AND NoCotizar IS NULL AND Cotizado IS NULL
END


