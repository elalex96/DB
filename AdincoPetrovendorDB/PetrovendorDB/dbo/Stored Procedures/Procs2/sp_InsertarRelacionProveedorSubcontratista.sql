CREATE PROCEDURE [dbo].[sp_InsertarRelacionProveedorSubcontratista]
(
    @IdProveedor INT,
    @IdSubContratista INT
)
AS
BEGIN
    INSERT INTO dbo.PV_RelacionProveedorSubcotratista
    (
        IdProveedor,
        IdSubcontratista
    )
    VALUES
    (   @IdProveedor, -- IdProveedor - int
        @IdSubContratista  -- IdSubcontratista - int
    )
END
