CREATE PROCEDURE [dbo].[SP_ObtenerIdDomicilioFiscal]
(
    @IdProveedor INT
)
AS
BEGIN
	SELECT IdDomicilio FROM DG_Domicilio WHERE IdTipoDomicilio = 1 AND Activo = 1 AND IdProveedor = @IdProveedor 
END	
