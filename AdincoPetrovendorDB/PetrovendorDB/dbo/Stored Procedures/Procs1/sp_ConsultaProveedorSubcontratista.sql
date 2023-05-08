CREATE PROCEDURE [dbo].[sp_ConsultaProveedorSubcontratista](@IdProveedor INT)
AS
BEGIN
    SELECT relProvSub.IdRelacion,
           relProvSub.IdSubContratista
    FROM dbo.PV_RelacionProveedorSubcotratista relProvSub
        INNER JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = relProvSub.IdProveedor
		WHERE prov.IdProveedor = @IdProveedor --Viene de la sesion
END
