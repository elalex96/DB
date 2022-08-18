-- =============================================
-- Author:          josue glez
-- Create date: 24/05/2017
-- Description:     Listado de cuentas bancarias para llenar combobox
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK, Nombrado de Tablas en select, ajustes de lefts joins y eliminación de codigo comentado
-- =============================================
CREATE PROCEDURE [dbo].[SP_FICuentasBancarias] 
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CONTRATISTA INT;
    --	
    CREATE TABLE #TablaCuentasBancarias
    (
        DatoBancarioID INT,
        Alias VARCHAR(200),
        RazonSocial VARCHAR(200),
        NumeroCuenta VARCHAR(200),
        CuentaClave VARCHAR(200),
        TipoMonedaCorto VARCHAR(200),
        NombreComercial VARCHAR(200),
        IdProveedor INT
    )
    --
    SELECT @CONTRATISTA = CO_Contratista.IdContratista
    FROM CO_Contrato (NOLOCK)
        JOIN CO_Contratista (NOLOCK)
            ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
    WHERE CO_Contrato.IdContrato = @IdContrato;

    INSERT INTO #TablaCuentasBancarias
    (
        DatoBancarioID,
        Alias,
        RazonSocial,
        NumeroCuenta,
        CuentaClave,
        TipoMonedaCorto,
        NombreComercial,
        IdProveedor
    )
    SELECT PV_CuentaBancaria.DatoBancarioID,
           ISNULL(PV_CuentaBancaria.alias, ''),
           PV_Banco.RazonSocial,
           PV_CuentaBancaria.NumeroCuenta,
           PV_CuentaBancaria.CuentaClave,
           PV_TipoMoneda.TipoMonedaCorto,
           'S/N',
           PV_CuentaBancaria.IdProveedor
    FROM PV_CuentaBancaria (NOLOCK)
        INNER JOIN PV_Banco (NOLOCK)
            ON PV_CuentaBancaria.BancoID = PV_Banco.BancoID
        JOIN PV_TipoMoneda (NOLOCK)
            ON PV_CuentaBancaria.TipoMonedaID = PV_TipoMoneda.idmoneda
    WHERE PV_CuentaBancaria.IdContratista = @CONTRATISTA
    ORDER BY PV_CuentaBancaria.DatoBancarioID DESC;

    UPDATE #TablaCuentasBancarias
    SET #TablaCuentasBancarias.NombreComercial = ISNULL(PV_Subcontratista.NombreComercial, 'S/N')
    FROM #TablaCuentasBancarias
        JOIN PV_Subcontratista (NOLOCK)
            ON #TablaCuentasBancarias.IdProveedor = PV_Subcontratista.IdSubcontratista

    SELECT #TablaCuentasBancarias.DatoBancarioID,
           CONCAT(
                     ISNULL(#TablaCuentasBancarias.alias, ''),
                     ' ',
                     #TablaCuentasBancarias.RazonSocial,
                     ' (',
                     ISNULL(#TablaCuentasBancarias.NombreComercial, 'S/N'),
                     ') ',
                     ' - ',
                     ISNULL(#TablaCuentasBancarias.NumeroCuenta, #TablaCuentasBancarias.CuentaClave),
                     ' - ',
                     #TablaCuentasBancarias.TipoMonedaCorto
                 ) AS Cuenta
    FROM #TablaCuentasBancarias
    ORDER BY #TablaCuentasBancarias.DatoBancarioID DESC;
END;