IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_SEL_FI_TransferContrato_NoLigadas]') AND type IN (N'P'))
    DROP PROCEDURE [dbo].[USP_SEL_FI_TransferContrato_NoLigadas];
GO

CREATE PROCEDURE [dbo].[USP_SEL_FI_TransferContrato_NoLigadas]
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;

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
    );

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
    SELECT 
        T.IdTransferencia,
        '', '', '', '', '', '',
        T.CreadoEn,
        T.ModificadoEn,
        T.IdCuentaDestino,
        T.IdCuentaOrigen,
        NULL,
        T.CreadoPor,
        T.ModificadoPor,
        CAST(MP.MetodoPago AS VARCHAR(50)),
        CAST(TM.TipoMonedaCorto AS VARCHAR(50))
    FROM FI_Transfer T WITH (NOLOCK)
    JOIN PV_TipoMoneda TM WITH (NOLOCK)
        ON T.IdContrato = @IdContrato AND T.IdMoneda = TM.IdMoneda
    JOIN PV_MetodoPago MP WITH (NOLOCK)
        ON T.IdMetodoPago = MP.IdMetodoPago;

    -- Eliminar transferencias que ya están ligadas
    DELETE TT
    FROM #TablaTransferContratoNoLigadas TT
    JOIN FI_TransferFactura TF WITH (NOLOCK)
        ON TT.IdTransferencia = TF.IdTransfer;

    -- Consolidar los updates relacionados
    UPDATE TT
    SET 
        TT.CuentaClaveOrigen = ISNULL(CB1.CuentaClave, ''),
        TT.CuentaClaveDestino = ISNULL(CB2.CuentaClave, ''),
        TT.IdProveedor = CB2.IdProveedor
    FROM #TablaTransferContratoNoLigadas TT
    LEFT JOIN PV_CuentaBancaria CB1 WITH (NOLOCK)
        ON TT.IdCuentaOrigen = CB1.DatoBancarioID
    LEFT JOIN PV_CuentaBancaria CB2 WITH (NOLOCK)
        ON TT.IdCuentaDestino = CB2.DatoBancarioID;

    UPDATE TT
    SET 
        TT.RazonSocial = ISNULL(S.RazonSocial, ''),
        TT.RFC = ISNULL(S.RFC, '')
    FROM #TablaTransferContratoNoLigadas TT
    LEFT JOIN PV_Subcontratista S WITH (NOLOCK)
        ON TT.IdProveedor = S.IdSubcontratista;

    UPDATE TT
    SET TT.CreadoPor = U.Nombre
    FROM #TablaTransferContratoNoLigadas TT
    JOIN AP_Usuario U WITH (NOLOCK)
        ON TT.CreadoPorId = U.UsuarioID;

    UPDATE TT
    SET TT.ModificadoPor = U.Nombre
    FROM #TablaTransferContratoNoLigadas TT
    JOIN AP_Usuario U WITH (NOLOCK)
        ON TT.ModificadoPorId = U.UsuarioID;

    -- Resultado final
    SELECT DISTINCT
        TT.IdTransferencia,
        TT.CuentaClaveOrigen AS CuentaOrigen,
        TT.CuentaClaveDestino AS CuentaDestino,
        TT.RazonSocial,
        TT.RFC,
        ISNULL(T.ReferenciaBancaria, '') AS ReferenciaBancaria,
        T.FechaPago,
        YEAR(T.FechaPago) AS Anio,
        CONCAT(
            RIGHT('00' + CAST(MONTH(T.FechaPago) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, T.FechaPago)
        ) AS Mes,
        T.MontoPagado,
        T.Intereses,
        TT.MetodoPago,
        TT.TipoMonedaCorto AS TipoMoneda,
        T.Concepto,
        T.NumeroPolizaContable,
        CASE
            WHEN (T.PDF IS NULL OR T.PDF = '') AND T.AWSPDFId IS NULL THEN '¡PDF NO CARGADO!'
            ELSE 'Pdf Cargado'
        END AS ComprobanteDePago,
        TT.CreadoPor,
        T.CreadoEn AS FechaRegistro,
        TT.ModificadoPor,
        T.ModificadoEn AS FechaModificado
    FROM #TablaTransferContratoNoLigadas TT
    JOIN FI_Transfer T WITH (NOLOCK)
        ON TT.IdTransferencia = T.IdTransferencia
    ORDER BY TT.IdTransferencia DESC;
END;
GO
