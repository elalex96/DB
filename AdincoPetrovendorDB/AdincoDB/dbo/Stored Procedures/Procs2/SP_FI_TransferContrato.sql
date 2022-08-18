-- =============================================
-- Author:          Manuel CD
-- Create date: 1-09-17
-- Description:     
-- =============================================
-- Author:		Marcos Garcia
-- Create date: 16-12-2019
-- Description:	Agregar Columnas Año y Mes 
--				agregar SET LANGUAGE spanish
-- =============================================
-- Author:		Reyna O.
-- Create date: 04-07-2022
-- Description: Se agrega NOLOCK, se eliminan comentarios y se mueven las creaciones 
-- de la tabla al inicio de procedure
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			16 de Agosto del 2022
-- Descripción:		Ajustado de orden en los join, ajuste en nombre de las tablas, no se realizo ajuste mayo ya que se ajusto en otro issue de deuda tecnica
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_TransferContrato]
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
    --===========================================
    IF OBJECT_ID('tempdb..#Facturas', 'U') IS NOT NULL
        DROP TABLE #Facturas;
    --===========================================
    CREATE TABLE #Facturas
    (
        IdFactura INT,
        Serie VARCHAR(500),
        NumeroContrato NVARCHAR(50),
        Folio VARCHAR(500),
        Fecha DATETIME,
        FormaPago VARCHAR(500),
        SubTotal MONEY,
        Moneda VARCHAR(500),
        MontoConIva MONEY,
        TipoComprobante VARCHAR(500),
        MetodoPago VARCHAR(500),
        LugarExpedicion VARCHAR(1000),
        UUID VARCHAR(500),
        FechaRecepcion DATETIME,
        RazonSocial VARCHAR(1000),
        Emisor VARCHAR(1000)
    );

    CREATE TABLE #UUIDS
    (
        IdTransfer INT,
        UUID VARCHAR(500)
    );

    CREATE TABLE #TransferenciaUUIDS
    (
        IdTransfer INT,
        UUIDS VARCHAR(8000)
    );
    --===========================================
    INSERT INTO #Facturas
    (
        IdFactura,
        Serie,
        NumeroContrato,
        Folio,
        Fecha,
        FormaPago,
        SubTotal,
        Moneda,
        MontoConIva,
        TipoComprobante,
        MetodoPago,
        LugarExpedicion,
        UUID,
        FechaRecepcion,
        RazonSocial,
        Emisor
    )
    SELECT DISTINCT
        FI_Factura.IdFactura,
        FI_Factura.Serie,
        CO_Contrato.NumeroContrato,
        FI_Factura.Folio,
        FI_Factura.Fecha,
        CASE
            WHEN FI_Factura.MetodoPago LIKE '%exhibi%'
                 OR FI_Factura.MetodoPago LIKE '%PUE%'
                 OR FI_Factura.MetodoPago LIKE '%parcia%'
                 OR FI_Factura.MetodoPago LIKE '%dife%'
                 OR FI_Factura.MetodoPago LIKE '%PPD%' THEN
                FI_Factura.FormaPago
            WHEN FI_Factura.FormaPago LIKE '%exhibi%'
                 OR FI_Factura.FormaPago LIKE '%PUE%'
                 OR FI_Factura.FormaPago LIKE '%parcia%'
                 OR FI_Factura.FormaPago LIKE '%dife%'
                 OR FI_Factura.FormaPago LIKE '%PPD%' THEN
                FI_Factura.MetodoPago
            ELSE
                'NA'
        END AS FormaPago,
        ISNULL(FI_Factura.SubTotal, 0) AS SubTotal,
        FI_Factura.Moneda,
        ISNULL(FI_Factura.MontoConIva, 0) AS MontoConIva,
        FI_Factura.TipoComprobante,
        CASE
            WHEN FI_Factura.MetodoPago LIKE '%exhibi%'
                 OR FI_Factura.MetodoPago LIKE '%PUE%'
                 OR FI_Factura.FormaPago LIKE '%exhibi%'
                 OR FI_Factura.FormaPago LIKE '%PUE%' THEN
                'PUE'
            WHEN FI_Factura.MetodoPago LIKE '%parcia%'
                 OR FI_Factura.MetodoPago LIKE '%dife%'
                 OR FI_Factura.MetodoPago LIKE '%PPD%'
                 OR FI_Factura.FormaPago LIKE '%parcia%'
                 OR FI_Factura.FormaPago LIKE '%dife%'
                 OR FI_Factura.FormaPago LIKE '%PPD%' THEN
                'PPD'
            ELSE
                'NA'
        END AS MetodoPago,
        SUBSTRING(FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
        FI_Factura.UUID,
        FI_Factura.FechaRecepcion,
        PV_Subcontratista.RazonSocial,
        FI_Factura.Emisor
    FROM FI_Factura (NOLOCK)
        JOIN PV_Subcontratista (NOLOCK)
            ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
               AND FI_Factura.IdContrato = @IdContrato
        JOIN CO_Contrato (NOLOCK)
            ON FI_Factura.IdContrato = CO_Contrato.IdContrato
    WHERE CO_Contrato.IdContrato = @IdContrato;
    /**/
    INSERT INTO #UUIDS
    (
        #UUIDS.IdTransfer,
        #UUIDS.UUID
    )
    SELECT FI_Transfer.IdTransferencia,
           concat(FI_Factura.TipoComprobante, '-', SUBSTRING(LTRIM(RTRIM(FI_Factura.UUID)), 1, 500))
    FROM FI_Transfer (NOLOCK)
        LEFT JOIN FI_TransferFactura (NOLOCK)
            ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
               AND FI_Transfer.IdContrato = @IdContrato
        LEFT JOIN FI_Factura (NOLOCK)
            ON FI_TransferFactura.IdFactura = FI_Factura.IdFactura
    WHERE FI_Transfer.IdContrato = @IdContrato
          AND FI_TransferFactura.IdTransfer IS NOT NULL
    GROUP BY FI_Transfer.IdTransferencia,
             concat(FI_Factura.TipoComprobante, '-', SUBSTRING(LTRIM(RTRIM(FI_Factura.UUID)), 1, 500));
    /**/
    INSERT INTO #UUIDS
    (
        #UUIDS.IdTransfer,
        #UUIDS.UUID
    )
    SELECT FI_Transfer.IdTransferencia,
           concat('I-', SUBSTRING(LTRIM(RTRIM(FI_CPDocRelacionado.IdDocumento)), 1, 500))
    FROM FI_Transfer (NOLOCK)
        LEFT JOIN FI_TransferFactura (NOLOCK)
            ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
               AND FI_Transfer.IdContrato = @IdContrato
        LEFT JOIN FI_Factura (NOLOCK)
            ON FI_TransferFactura.IdFactura = FI_Factura.IdFactura
        JOIN FI_ComplementoDePago (NOLOCK)
            ON FI_Factura.IdFactura = FI_ComplementoDePago.IdFactura
        JOIN FI_CPDocRelacionado (NOLOCK)
            ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago
    WHERE FI_Transfer.IdContrato = @IdContrato
          AND FI_TransferFactura.IdTransfer IS NOT NULL
    GROUP BY FI_Transfer.IdTransferencia,
             concat('I-', SUBSTRING(LTRIM(RTRIM(FI_CPDocRelacionado.IdDocumento)), 1, 500));
    /**/
    INSERT INTO #TransferenciaUUIDS
    (
        IdTransfer,
        UUIDS
    )
    SELECT DISTINCT
        B.IdTransfer,
        SUBSTRING(STUFF(
                  (
                      SELECT ' | ' + RTRIM(LTRIM(UUID))
                      FROM #UUIDS u
                      WHERE B.IdTransfer = u.IdTransfer
                      FOR XML PATH('')
                  ),
                  1,
                  1,
                  ''
                       ),
                  1,
                  8000
                 )
    FROM #UUIDS B
    GROUP BY IdTransfer;
    /**/
    SELECT DISTINCT
        FI_Transfer.IdTransferencia,
        PV_CuentaBancariaDestino.CuentaClave AS 'Cuenta Origen',
        PV_CuentaBancaria.CuentaClave AS 'Cuenta Destino',
        PV_Subcontratista.RazonSocial,
        PV_Subcontratista.RFC,
        FI_Transfer.ReferenciaBancaria,
        FI_Transfer.FechaPago,
        YEAR(FI_Transfer.FechaPago) AS Año,
        CONCAT(
                  RIGHT('00' + CAST(MONTH(FI_Transfer.FechaPago) AS VARCHAR(2)), 2),
                  ' ',
                  DATENAME(MONTH, FI_Transfer.FechaPago)
              ) AS Mes,
        FI_Transfer.MontoPagado,
        FI_Transfer.Intereses,
        PV_MetodoPago.MetodoPago,
        PV_TipoMoneda.TipoMonedaCorto AS TipoMoneda,
        concat(FI_Transfer.Concepto, ' - UUID ', UPPER(isnull(#TransferenciaUUIDS.UUIDS, ''))) AS Concepto,
        FI_Transfer.NumeroPolizaContable,
        CASE
            WHEN FI_Transfer.AWSPDFId IS NULL THEN
                '¡PDF NO CARGADO!'
            ELSE
                'Pdf Cargado'
        END AS 'Comprobante de Pago',
        AP_Usuario.Nombre AS CreadoPor,
        FI_Transfer.CreadoEn AS 'Fecha Registro',
        AP_UsuarioModificador.Nombre AS ModificadoPor,
        FI_Transfer.ModificadoEn AS 'Fecha Modificado',
        CASE
            WHEN FI_TransferFactura.CvTipoDocFacturacion = 1
                 AND FI_Transfer.IdFormaPago = 1 THEN
                'CF PUE'
            WHEN FI_TransferFactura.CvTipoDocFacturacion = 2 THEN
                'PI'
            WHEN FI_TransferFactura.CvTipoDocFacturacion = 3 THEN
                'PE'
            WHEN FI_TransferFactura.CvTipoDocFacturacion = 6 THEN
                'CF-P'
            WHEN FI_TransferFactura.CvTipoDocFacturacion = 1
                 AND FI_Transfer.IdFormaPago = 2 THEN
                'CF PPD Pendiente de Complemento de Pago'
            WHEN FI_TransferFactura.CvTipoDocFacturacion = 1
                 AND #Facturas.MetodoPago = 'PUE' THEN
                'CF PUE'
            WHEN FI_TransferFactura.CvTipoDocFacturacion = 1
                 AND #Facturas.MetodoPago = 'PPD' THEN
                'CF PPD Pendiente de Complemento de Pago'
            ELSE
                'NA'
        END AS TipoDoc
    FROM FI_Transfer (NOLOCK)
        JOIN PV_CuentaBancaria (NOLOCK)
            ON FI_Transfer.IdCuentaDestino = PV_CuentaBancaria.DatoBancarioID
               AND FI_Transfer.IdContrato = @IdContrato
        JOIN PV_CuentaBancaria PV_CuentaBancariaDestino (NOLOCK)
            ON FI_Transfer.IdCuentaOrigen = PV_CuentaBancariaDestino.DatoBancarioID
        JOIN PV_Subcontratista (NOLOCK)
            ON PV_CuentaBancaria.IdProveedor = PV_Subcontratista.IdSubcontratista
        JOIN PV_TipoMoneda (NOLOCK)
            ON FI_Transfer.IdMoneda = PV_TipoMoneda.IdMoneda
        JOIN PV_MetodoPago (NOLOCK)
            ON FI_Transfer.IdMetodoPago = PV_MetodoPago.idMetodoPago
        LEFT JOIN AP_Usuario (NOLOCK)
            ON FI_Transfer.CreadoPor = AP_Usuario.UsuarioID
        LEFT JOIN AP_Usuario AS AP_UsuarioModificador (NOLOCK)
            ON FI_Transfer.ModificadoPor = AP_UsuarioModificador.UsuarioID
        LEFT JOIN FI_TransferFactura (NOLOCK)
            ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
        LEFT JOIN #TransferenciaUUIDS (NOLOCK)
            ON #TransferenciaUUIDS.IdTransfer = FI_Transfer.IdTransferencia
        LEFT JOIN #Facturas
            ON FI_TransferFactura.IdFactura = #Facturas.IdFactura
    WHERE FI_Transfer.IdContrato = @IdContrato
          AND FI_TransferFactura.IdTransfer IS NOT NULL
    ORDER BY FI_Transfer.IdTransferencia DESC;
END;
