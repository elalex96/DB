-- =============================================
-- Author: Luis David
-- Create date: 06/09/2022
-- Description: Modificación de optimización Issue #1985 (Petrovendor)
--===============================================
CREATE PROCEDURE RetornarRfcCarso
AS
BEGIN
    SELECT prov.RFC
    FROM dbo.AX_ComparativaEmpresa comp
    INNER JOIN dbo.S_Proveedor (NOLOCK) prov
            ON comp.IdProveedor = prov.IdProveedor
			AND 1 = prov.Activo
END
