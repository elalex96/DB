
CREATE PROCEDURE dbo.SP_FIProveedores
AS
BEGIN 
-- =============================================
-- Author:		Oscar Mtz
-- Create date: 04/08/2017
-- Description:	Devuelve el listado de la tabla PV_Subcontratista (Proveedores) para la asignación de Transferencias a facturas.
-- =============================================
SELECT		
		A.idSubcontratista,
		A.RazonSocial Proveedor,
		concat(C.RazonSocial, ' (', Isnull(A.NombreComercial, 'S/N'), ') ', ' - ', Isnull(B.NumeroCuenta, B.CuentaClave), ' - ', tm.TipoMonedaCorto) AS Cuenta
FROM 
		PV_CuentaBancaria B
		INNER JOIN PV_Subcontratista A ON B.IdProveedor = A.IdSubcontratista
		INNER JOIN PV_Banco C ON B.BancoID = C.BancoID
		JOIN PV_TipoMoneda tm ON b.TipoMonedaID = tm.idmoneda
ORDER BY B.DatoBancarioID DESC;
END