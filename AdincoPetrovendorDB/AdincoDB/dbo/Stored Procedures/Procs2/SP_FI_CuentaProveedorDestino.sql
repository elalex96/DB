-- =============================================  
-- Author:  Manuel CD  
-- Create date: 25-08-17  
-- Description:   
-- =============================================  
--20/07/201 Solo muestre las cuentas activas
-- ============================================= 
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK, Nombrado de Tablas en select, ajustes de lefts joins y eliminación de codigo comentado
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_CuentaProveedorDestino] @IdSubcontratista INT
AS
BEGIN
    SET NOCOUNT ON;
    --
    CREATE TABLE #TablaCuentaProveedorDestino
    (
        DatoBancarioID INT,
        RazonSocial VARCHAR(200),
        NumeroCuenta VARCHAR(200),
        CuentaClave VARCHAR(200),
        TipoMonedaCorto VARCHAR(200),
        Predeterminado BIT,
        TipoMonedaID INT,
        NombreComercial VARCHAR(200),
        IdProveedor INT
    )
    INSERT INTO #TablaCuentaProveedorDestino
    (
        DatoBancarioID,
        RazonSocial,
        NumeroCuenta,
        CuentaClave,
        TipoMonedaCorto,
        Predeterminado,
        TipoMonedaID,
        NombreComercial,
        IdProveedor
    )
    SELECT PV_CuentaBancaria.DatoBancarioID,
           PV_Banco.RazonSocial,
           PV_CuentaBancaria.NumeroCuenta,
           PV_CuentaBancaria.CuentaClave,
           PV_TipoMoneda.TipoMonedaCorto,
           PV_CuentaBancaria.Predeterminado,
           PV_CuentaBancaria.TipoMonedaID,
           'S/N',
           PV_CuentaBancaria.IdProveedor
    FROM PV_CuentaBancaria (NOLOCK)
        INNER JOIN PV_Banco (NOLOCK)
            ON PV_CuentaBancaria.BancoID = PV_Banco.BancoID
        JOIN PV_TipoMoneda (NOLOCK)
            ON PV_CuentaBancaria.TipoMonedaID = PV_TipoMoneda.idmoneda
    WHERE PV_CuentaBancaria.Activa = 1
          AND PV_CuentaBancaria.IdProveedor = @IdSubcontratista

    UPDATE #TablaCuentaProveedorDestino
    SET #TablaCuentaProveedorDestino.NombreComercial = ISNULL(PV_Subcontratista.NombreComercial, 'S/N')
    FROM #TablaCuentaProveedorDestino
        JOIN PV_Subcontratista (NOLOCK)
            ON #TablaCuentaProveedorDestino.IdProveedor = PV_Subcontratista.IdSubcontratista

    SELECT #TablaCuentaProveedorDestino.DatoBancarioID,
           CONCAT(
                     #TablaCuentaProveedorDestino.RazonSocial,
                     ' (',
                     ISNULL(#TablaCuentaProveedorDestino.NombreComercial, 'S/N'),
                     ') ',
                     ' - ',
                     ISNULL(#TablaCuentaProveedorDestino.NumeroCuenta, #TablaCuentaProveedorDestino.CuentaClave),
                     ' - ',
                     #TablaCuentaProveedorDestino.TipoMonedaCorto
                 ) AS Cuenta,
           #TablaCuentaProveedorDestino.Predeterminado,
           #TablaCuentaProveedorDestino.TipoMonedaID
    FROM #TablaCuentaProveedorDestino
END;