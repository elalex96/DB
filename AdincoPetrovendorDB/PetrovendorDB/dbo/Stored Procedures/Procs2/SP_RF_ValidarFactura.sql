-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <28/05/18>
-- Description:	<Valida la factura cargada>
-- =============================================
CREATE PROCEDURE [dbo].[SP_RF_ValidarFactura]
@IdProveedor INT,
@Correo NVARCHAR(MAX) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

     SELECT IdReferenciaComercial FROM PV_ReferenciasComerciales
	 WHERE 
	 Proveedor = @IdProveedor AND 
	 Correo = @Correo AND
	 ReferenciaActiva = 1

END
