CREATE PROCEDURE RetornarRfcCarso
AS
BEGIN
    SELECT prov.RFC
    FROM dbo.AX_ComparativaEmpresa comp
        INNER JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = comp.IdProveedor
			AND prov.Activo = 1
END





