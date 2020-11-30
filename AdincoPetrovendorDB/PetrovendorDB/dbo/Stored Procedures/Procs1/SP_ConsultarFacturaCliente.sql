-- =============================================
-- Modificado por:		<Jose Roman>
-- Midificado date: <Create Date,,>
-- Description:	<Se quitan filtros inecesarios para agilisar consulta>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarFacturaCliente]
	@IdProveedor INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT csc.IdRelacion, p.IdProveedor AS IdProveedorFactura, p.RFC, p.RazonSocial,csc.Correo
	FROM PV_ContratistaSubContratista csc
	INNER JOIN S_Proveedor p
	ON csc.IdSubContratista = p.IdProveedor
	WHERE csc.IdContratista = @IdProveedor AND csc.IsActivo = 1

END

