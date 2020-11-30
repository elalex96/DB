CREATE PROCEDURE [dbo].[sp_GridAEliminarDomicilio]
(
    @IdDomicilio INT,
    @IdProveedor INT
)
AS
BEGIN
    UPDATE dbo.DG_Domicilio
    SET Activo = 0
    WHERE IdDomicilio = @IdDomicilio
          AND IdProveedor = @IdProveedor
END
