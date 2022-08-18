--╔═════════════════════════════════════════════╗
--║Uso de SP solo en Sistema de ADINCO          ║
--║En PETROVENDOR se encuetra uno llamado       ║
--║de igual forma pero adaptado para PETROVENDOR║
--╚═════════════════════════════════════════════╝
-- =============================================
-- Author:		Manuel CD
-- Create date: 18-06-2018
-- Description:	
-- =============================================
-- Author:		Marcos Garcia
-- Create date: 16-12-2019
-- Description:	* Agregar Columnas Año y Mes 
--				* Agregar SET LANGUAGE spanish
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			16 de Agosto del 2022
-- Descripción:		Eliminación de código comentado, agregado de (NOLOCK), ajustado de orden en los join, se quitan lefts joins
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_TransferContratoNoLigadas]
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    --
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
    --
    CREATE TABLE #TablaTransferContratoNoLigadas
    (
        IdTransferencia INT,
        CuentaClaveOrigen VARCHAR(1000),
        CuentaClaveDestino VARCHAR(1000),
        RazonSocial VARCHAR(500),
        RFC VARCHAR(100),
        CreadoPor VARCHAR(100),
        ModificadoPor VARCHAR(100),
        CreadoEn DATETIME,
        ModificadoEn DATETIME,
        IdCuentaDestino INT,
        IdCuentaOrigen INT,
        IdProveedor INT,
        CreadoPorId INT,
        ModificadoPorId INT,
        MetodoPago VARCHAR(50),
        TipoMonedaCorto VARCHAR(50)
    )
	--
    INSERT INTO #TablaTransferContratoNoLigadas
    (
        IdTransferencia,
        CuentaClaveOrigen,
        CuentaClaveDestino,
        RazonSocial,
        RFC,
        CreadoPor,
        ModificadoPor,
        CreadoEn,
        ModificadoEn,
        IdCuentaDestino,
        IdCuentaOrigen,
        IdProveedor,
        CreadoPorId,
        ModificadoPorId,
        MetodoPago,
        TipoMonedaCorto
    )
    SELECT FI_Transfer.IdTransferencia INT,
           '',
           '',
           '',
           '',
           '',
           '',
           FI_Transfer.CreadoEn,
           FI_Transfer.ModificadoEn,
           FI_Transfer.IdCuentaDestino,
           FI_Transfer.IdCuentaOrigen,
           NULL,
           FI_Transfer.CreadoPor,
           FI_Transfer.ModificadoPor,
           CAST(PV_MetodoPago.MetodoPago AS VARCHAR(50)),
           CAST(PV_TipoMoneda.TipoMonedaCorto AS VARCHAR(50))
    FROM FI_Transfer  (NOLOCK)
        JOIN PV_TipoMoneda  (NOLOCK)
            ON FI_Transfer.IdContrato = @IdContrato
               AND FI_Transfer.IdMoneda = PV_TipoMoneda.IdMoneda
        JOIN PV_MetodoPago  (NOLOCK)
            ON FI_Transfer.IdMetodoPago = PV_MetodoPago.idMetodoPago
	/*Solo se dejan las que no tienen una transferencia registrada*/
    DELETE #TablaTransferContratoNoLigadas
    FROM #TablaTransferContratoNoLigadas
        JOIN FI_TransferFactura (NOLOCK)
            ON #TablaTransferContratoNoLigadas.IdTransferencia = FI_TransferFactura.IdTransfer
	/*Se actualizan los campos sin left*/
    UPDATE #TablaTransferContratoNoLigadas
    SET #TablaTransferContratoNoLigadas.CuentaClaveOrigen = CAST(PV_CuentaBancaria.CuentaClave AS VARCHAR(1000))
    FROM #TablaTransferContratoNoLigadas
        JOIN PV_CuentaBancaria (NOLOCK)
            ON #TablaTransferContratoNoLigadas.IdCuentaOrigen = PV_CuentaBancaria.DatoBancarioID

    UPDATE #TablaTransferContratoNoLigadas
    SET #TablaTransferContratoNoLigadas.CuentaClaveDestino = CAST(PV_CuentaBancaria.CuentaClave AS VARCHAR(1000)),
        #TablaTransferContratoNoLigadas.IdProveedor = PV_CuentaBancaria.IdProveedor
    FROM #TablaTransferContratoNoLigadas
        JOIN PV_CuentaBancaria (NOLOCK)
            ON #TablaTransferContratoNoLigadas.IdCuentaDestino = PV_CuentaBancaria.DatoBancarioID

    UPDATE #TablaTransferContratoNoLigadas
    SET #TablaTransferContratoNoLigadas.RazonSocial = CAST(PV_Subcontratista.RazonSocial AS VARCHAR(500)),
        #TablaTransferContratoNoLigadas.RFC = CAST(PV_Subcontratista.RFC AS VARCHAR(100))
    FROM #TablaTransferContratoNoLigadas
        JOIN PV_Subcontratista (NOLOCK)
            ON #TablaTransferContratoNoLigadas.IdProveedor = PV_Subcontratista.IdSubcontratista

    UPDATE #TablaTransferContratoNoLigadas
    SET #TablaTransferContratoNoLigadas.CreadoPor = CAST(AP_Usuario.Nombre AS VARCHAR(100))
    FROM #TablaTransferContratoNoLigadas
        JOIN AP_Usuario (NOLOCK)
            ON #TablaTransferContratoNoLigadas.CreadoPorId = AP_Usuario.UsuarioID

    UPDATE #TablaTransferContratoNoLigadas
    SET #TablaTransferContratoNoLigadas.ModificadoPor = CAST(AP_Usuario.Nombre AS VARCHAR(100))
    FROM #TablaTransferContratoNoLigadas
        JOIN AP_Usuario (NOLOCK)
            ON #TablaTransferContratoNoLigadas.ModificadoPorId = AP_Usuario.UsuarioID
	/*Selección final*/
    SELECT #TablaTransferContratoNoLigadas.IdTransferencia,
           #TablaTransferContratoNoLigadas.CuentaClaveOrigen AS 'Cuenta Origen',
           #TablaTransferContratoNoLigadas.CuentaClaveDestino AS 'Cuenta Destino',
           #TablaTransferContratoNoLigadas.RazonSocial,
           #TablaTransferContratoNoLigadas.RFC,
           ISNULL(FI_Transfer.ReferenciaBancaria, '') AS ReferenciaBancaria,
           FI_Transfer.FechaPago,
           YEAR(FI_Transfer.FechaPago) AS Año,
           CONCAT(
                     RIGHT('00' + CAST(MONTH(FI_Transfer.FechaPago) AS VARCHAR(2)), 2),
                     ' ',
                     DATENAME(MONTH, FI_Transfer.FechaPago)
                 ) AS Mes,
           FI_Transfer.MontoPagado,
           FI_Transfer.Intereses,
           #TablaTransferContratoNoLigadas.MetodoPago,
           #TablaTransferContratoNoLigadas.TipoMonedaCorto AS TipoMoneda,
           FI_Transfer.Concepto,
           FI_Transfer.NumeroPolizaContable,
           CASE
               WHEN (
                        FI_Transfer.PDF LIKE ''
                        OR FI_Transfer.PDF IS NULL
                    )
                    AND FI_Transfer.AWSPDFId IS NULL THEN
                   '¡PDF NO CARGADO!'
               ELSE
                   'Pdf Cargado'
           END AS 'Comprobante de Pago',
           #TablaTransferContratoNoLigadas.CreadoPor AS CreadoPor,
           FI_Transfer.CreadoEn AS 'Fecha Registro',
           #TablaTransferContratoNoLigadas.ModificadoPor AS ModificadoPor,
           FI_Transfer.ModificadoEn AS 'Fecha Modificado'
    FROM #TablaTransferContratoNoLigadas
        JOIN FI_Transfer (NOLOCK)
            ON #TablaTransferContratoNoLigadas.IdTransferencia = FI_Transfer.IdTransferencia
    GROUP BY #TablaTransferContratoNoLigadas.IdTransferencia,
             YEAR(FI_Transfer.FechaPago),
             CONCAT(
                       RIGHT('00' + CAST(MONTH(FI_Transfer.FechaPago) AS VARCHAR(2)), 2),
                       ' ',
                       DATENAME(MONTH, FI_Transfer.FechaPago)
                   ),
             CASE
                 WHEN (
                          FI_Transfer.PDF LIKE ''
                          OR FI_Transfer.PDF IS NULL
                      )
                      AND FI_Transfer.AWSPDFId IS NULL THEN
                     '¡PDF NO CARGADO!'
                 ELSE
                     'Pdf Cargado'
             END,
             FI_Transfer.IdTransferencia,
             #TablaTransferContratoNoLigadas.CuentaClaveOrigen,
             #TablaTransferContratoNoLigadas.CuentaClaveDestino,
             #TablaTransferContratoNoLigadas.RazonSocial,
             #TablaTransferContratoNoLigadas.RFC,
             FI_Transfer.ReferenciaBancaria,
             FI_Transfer.FechaPago,
             FI_Transfer.MontoPagado,
             FI_Transfer.Intereses,
             #TablaTransferContratoNoLigadas.MetodoPago,
             #TablaTransferContratoNoLigadas.TipoMonedaCorto,
             FI_Transfer.Concepto,
             FI_Transfer.NumeroPolizaContable,
             #TablaTransferContratoNoLigadas.CreadoPor,
             FI_Transfer.CreadoEn,
             #TablaTransferContratoNoLigadas.ModificadoPor,
             FI_Transfer.ModificadoEn
    ORDER BY #TablaTransferContratoNoLigadas.IdTransferencia DESC;
END;