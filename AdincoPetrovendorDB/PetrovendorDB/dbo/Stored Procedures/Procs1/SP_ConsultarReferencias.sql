
-- =============================================
-- Author:		Alexander G
-- Create date: 29-06-17
-- Description:	Datos Basicos de las Referencias Comerciales por Proveedor
				
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_ConsultarReferencias] 
	-- Add the parameters for the stored procedure here
	 @IdProveedor int 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT IdReferenciaComercial, Empresa, Correo, Telefono, ImporteLineaCredito
	 FROM PV_ReferenciasComerciales
	 WHERE Proveedor = @IdProveedor AND
			ReferenciaActiva = 1
	 --AND IdTipoOperacion = 2
	 --AND (Eliminado IS NULL OR Eliminado = 0)

END

