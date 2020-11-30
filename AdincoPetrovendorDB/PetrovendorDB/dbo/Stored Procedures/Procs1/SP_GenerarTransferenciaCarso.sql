CREATE PROCEDURE [dbo].[SP_GenerarTransferenciaCarso] @IdPago INT
AS
BEGIN

    /**IMPORTANTE      
--Cambiar solo en productivo, ya que el formato que envia AX difiere entre los ambientes de QA y PROD.      
               --SUBSTRING(FechaPago, 7, 4) + '/' + SUBSTRING(FechaPago, 4, 2) + '/' + SUBSTRING(FechaPago, 1, 2) AS FechaPago,      
      
    t.FechaPago =  p.FechaPago,      
       -- t.FechaPago = SUBSTRING(p.FechaPago, 7, 4) + '/' + SUBSTRING(p.FechaPago, 4, 2) + '/' + SUBSTRING(p.FechaPago, 1, 2),      
**/

    DECLARE @RFCCarso TABLE (RFCCarso NVARCHAR(1000))

    INSERT INTO @RFCCarso (RFCCarso)
    SELECT p.RFC
    FROM dbo.AX_ComparativaEmpresa e
        INNER JOIN dbo.S_Proveedor p
            ON p.IdProveedor = e.IdProveedor
    WHERE e.Activo = 1
          AND p.Activo = 1

    DECLARE @AX_Pagos TABLE
    (
        IdPago INT,
        FormaPago VARCHAR(MAX),
        CuentaOrigen VARCHAR(MAX),
        BancoOrigen VARCHAR(MAX),
        TitularOrigen VARCHAR(MAX),
        CuentaDestino VARCHAR(MAX),
        BancoDestino VARCHAR(MAX),
        TitularDestino VARCHAR(MAX),
        ReferenciaPago VARCHAR(MAX),
        FechaPago VARCHAR(MAX),
        MontoPagado MONEY,
        Interes MONEY,
        Moneda VARCHAR(MAX),
        Concepto VARCHAR(MAX),
        NoPolizaContable VARCHAR(MAX),
        UUIDFacturaPagada VARCHAR(MAX),
        MontoPagadoFactura MONEY,
        ComplementoPagoUUID VARCHAR(MAX),
        RECID VARCHAR(MAX),
        IdContrato INT,
        IdCuentaOrigen INT,
        IdCuentaDestino INT,
        IdMoneda INT,
        RFC_Emisor NVARCHAR(1000),
        IdSubcontratista INT,
        RazonSocialSubcontratista NVARCHAR(MAX),
        BancoIdOrigen INT,
        BancoIdDestino INT,
        BuscarEnClaveLen18Origen BIT,
        BuscarEnClaveLen18Destino BIT,
        IdFacturaAdincoPrincipal INT,
        IdFacturaAdincoComplemento INT,
        TieneError BIT,
        Editado BIT,
        IdTransfer INT
    )
    DECLARE @AX_PagosIntermedia TABLE
    (
        Id INT IDENTITY,
        IdPago INT,
        FormaPago VARCHAR(MAX),
        CuentaOrigen VARCHAR(MAX),
        BancoOrigen VARCHAR(MAX),
        TitularOrigen VARCHAR(MAX),
        CuentaDestino VARCHAR(MAX),
        BancoDestino VARCHAR(MAX),
        TitularDestino VARCHAR(MAX),
        ReferenciaPago VARCHAR(MAX),
        FechaPago VARCHAR(MAX),
        MontoPagado MONEY,
        Interes MONEY,
        Moneda VARCHAR(MAX),
        Concepto VARCHAR(MAX),
        NoPolizaContable VARCHAR(MAX),
        UUIDFacturaPagada VARCHAR(MAX),
        MontoPagadoFactura MONEY,
        ComplementoPagoUUID VARCHAR(MAX),
        RECID VARCHAR(MAX),
        IdContrato INT,
        IdCuentaOrigen INT,
        IdCuentaDestino INT,
        IdMoneda INT,
        RFC_Emisor NVARCHAR(1000),
        IdSubcontratista INT,
        RazonSocialSubcontratista NVARCHAR(MAX),
        BancoIdOrigen INT,
        BancoIdDestino INT,
        BuscarEnClaveLen18Origen BIT,
        BuscarEnClaveLen18Destino BIT,
        IdFacturaAdincoPrincipal INT,
        IdFacturaAdincoComplemento INT,
        TieneError BIT,
        Editado BIT,
        IdTransfer INT,
        IdFormaPago INT,
        IdFormaPagoVistoCliente INT
    )
    DECLARE @TablaNoExisteCuenta TABLE
    (
        Cuenta NVARCHAR(1000),
        BancoClave NVARCHAR(300),
        Tipo NVARCHAR(300),
        Len18 BIT,
        Titular NVARCHAR(MAX),
        IdMoneda INT,
        IdProveedor INT,
        BancoID NVARCHAR(1000),
        RFCEmisor NVARCHAR(1000),
        TieneError BIT
    )
    DECLARE @TablaBancoNoExiste TABLE (Clave NVARCHAR(1000), Banco NVARCHAR(1000), RazonSocial NVARCHAR(MAX))

    DECLARE @TablaSubcontratistaInexistente TABLE (RFC NVARCHAR(1000), RazonSocial NVARCHAR(MAX))
    DROP TABLE IF EXISTS dbo.##TablaFactura
    CREATE TABLE ##TablaFactura
    (
        IdFactura INT,
        RFC_Emisor NVARCHAR(1000),
        IdContrato INT,
        UUID NVARCHAR(1000)
    )


    INSERT INTO @AX_Pagos
    (
        IdPago,
        FormaPago,
        CuentaOrigen,
        BancoOrigen,
        TitularOrigen,
        CuentaDestino,
        BancoDestino,
        TitularDestino,
        ReferenciaPago,
        FechaPago,
        MontoPagado,
        Interes,
        Moneda,
        Concepto,
        NoPolizaContable,
        UUIDFacturaPagada,
        MontoPagadoFactura,
        ComplementoPagoUUID,
        RECID,
        IdTransfer,
        Editado
    )
    SELECT IdPago,
           FormaPago,
           CuentaOrigen,
           BancoOrigen,
           TitularOrigen,
           CuentaDestino,
           BancoDestino,
           TitularDestino,
           ReferenciaPago,
           FechaPago,
           MontoPagado,
           Interes,
           Moneda,
           Concepto,
           NoPolizaContable,
           UUIDFacturaPagada,
           MontoPagadoFactura,
           ComplementoPagoUUID,
           RECID,
           IdTransferencia,
           Editado
    FROM dbo.AX_Pagos
    WHERE IdTransferencia IS NULL
          OR ISNULL(Editado, 0) = 1
             AND IdPago = @IdPago

    -- se obtiene el contrato ya que este se registra en fi_transfer y con esto se sabe si existe el uuid en procura      
    UPDATE p
    SET p.IdContrato = f.IdContrato
    FROM @AX_Pagos p
        INNER JOIN dbo.FI_Factura f
            ON f.UUID = p.UUIDFacturaPagada
    WHERE f.Receptor IN ( SELECT RFCCarso FROM @RFCCarso )

    --se insertan todas las facturas a una tabla intermedia para indexarlas ya que la busqueda estaba tardando demasiado      
    INSERT INTO ##TablaFactura (IdFactura, IdContrato, UUID, RFC_Emisor)
    SELECT IdFactura,
           IdContrato,
           UUID,
           Emisor
    FROM Adinco.dbo.FI_Factura
        INNER JOIN @RFCCarso carso
            ON UPPER(Receptor) COLLATE DATABASE_DEFAULT = UPPER(carso.RFCCarso)
    WHERE (   UUID COLLATE DATABASE_DEFAULT IN ( SELECT UUIDFacturaPagada FROM dbo.AX_Pagos )
              OR UUID COLLATE DATABASE_DEFAULT IN ( SELECT ComplementoPagoUUID FROM dbo.AX_Pagos ))

    -- se obtiene la factura de adinco y con esto se sabe si existe el uuid en adinco      
    UPDATE ax
    SET ax.IdFacturaAdincoPrincipal = f.IdFactura,
        ax.RFC_Emisor = f.RFC_Emisor
    FROM @AX_Pagos ax
        INNER JOIN ##TablaFactura f
            ON f.UUID COLLATE DATABASE_DEFAULT = ax.UUIDFacturaPagada


    -- se obtiene el idfactura del complemento      
    UPDATE ax
    SET ax.IdFacturaAdincoComplemento = f.IdFactura,
        ax.RFC_Emisor = f.RFC_Emisor
    FROM @AX_Pagos ax
        INNER JOIN ##TablaFactura f
            ON f.UUID COLLATE DATABASE_DEFAULT = ax.ComplementoPagoUUID

    -- el idproveedor se refiere al contratista y se obtiene del rfc del emisor      
    UPDATE p
    SET p.RazonSocialSubcontratista = prov.RazonSocial
    FROM @AX_Pagos p
        INNER JOIN dbo.S_Proveedor prov
            ON p.RFC_Emisor = prov.RFC

    --ahora hay que setear el idsubcontratista ya que tengo su rfc      
    INSERT INTO @TablaSubcontratistaInexistente (RFC, RazonSocial)
    SELECT p.RFC_Emisor,
           p.RazonSocialSubcontratista
    FROM @AX_Pagos p
        LEFT JOIN Adinco.dbo.PV_Subcontratista s
            ON p.RFC_Emisor COLLATE DATABASE_DEFAULT = s.RFC
    WHERE s.IdSubcontratista IS NULL
          AND p.RFC_Emisor IS NOT NULL

    UPDATE p
    SET p.IdSubcontratista = s.IdSubcontratista
    FROM @AX_Pagos p
        INNER JOIN Adinco.dbo.PV_Subcontratista s
            ON p.RFC_Emisor COLLATE DATABASE_DEFAULT = s.RFC

    UPDATE p
    SET p.RazonSocialSubcontratista = s.RazonSocial
    FROM @AX_Pagos p
        INNER JOIN Adinco.dbo.PV_Subcontratista s
            ON p.RFC_Emisor COLLATE DATABASE_DEFAULT = s.RFC
    WHERE p.RazonSocialSubcontratista IS NULL


    --buscar cuenta de origen en  Adinco.dbo.PV_CuentaBancaria que no exista en numerocuenta ni en cuentaclave      
    -- se actualiza para saber cuales tienen longitud de  18 entonces se debe de tomar de la cuenta clave      
    UPDATE p
    SET p.BuscarEnClaveLen18Origen = 1
    FROM @AX_Pagos p
    WHERE LEN(p.CuentaOrigen) = 18

    UPDATE p
    SET p.BuscarEnClaveLen18Destino = 1
    FROM @AX_Pagos p
    WHERE LEN(p.CuentaDestino) = 18

    UPDATE p
    SET p.IdCuentaOrigen = c.DatoBancarioID
    FROM @AX_Pagos p
        INNER JOIN Adinco.dbo.PV_CuentaBancaria c
            ON p.CuentaOrigen COLLATE DATABASE_DEFAULT = c.NumeroCuenta
               AND ISNULL(p.BuscarEnClaveLen18Origen, 0) = 0
               AND ISNULL(p.TieneError, 0) = 0


    UPDATE p
    SET p.IdCuentaOrigen = c.DatoBancarioID
    FROM @AX_Pagos p
        INNER JOIN Adinco.dbo.PV_CuentaBancaria c
            ON p.CuentaOrigen COLLATE DATABASE_DEFAULT = c.CuentaClave
               AND ISNULL(p.BuscarEnClaveLen18Origen, 0) = 1
               AND ISNULL(p.TieneError, 0) = 0


    UPDATE p
    SET p.IdCuentaDestino = c.DatoBancarioID
    FROM @AX_Pagos p
        INNER JOIN Adinco.dbo.PV_CuentaBancaria c
            ON p.CuentaDestino COLLATE DATABASE_DEFAULT = c.NumeroCuenta
               AND ISNULL(p.BuscarEnClaveLen18Origen, 0) = 0
               AND ISNULL(p.TieneError, 0) = 0

    UPDATE p
    SET p.IdCuentaDestino = c.DatoBancarioID
    FROM @AX_Pagos p
        INNER JOIN Adinco.dbo.PV_CuentaBancaria c
            ON p.CuentaDestino COLLATE DATABASE_DEFAULT = c.CuentaClave
               AND ISNULL(p.BuscarEnClaveLen18Origen, 0) = 1
               AND ISNULL(p.TieneError, 0) = 0



    -- se asigna el idmoneda      
    UPDATE p
    SET p.IdMoneda = CASE
                         WHEN Moneda = 'MXP' THEN
                             1
                         WHEN Moneda = 'USD' THEN
                             2
                         ELSE
                             NULL
                     END
    FROM @AX_Pagos p

    -- se buscan los bancos que no estan dados de alta      
    INSERT INTO @TablaBancoNoExiste (Clave)
    SELECT p.BancoOrigen
    FROM @AX_Pagos p
        LEFT JOIN Adinco.dbo.PV_Banco b
            ON p.BancoOrigen COLLATE DATABASE_DEFAULT = b.Clave
    WHERE b.BancoID IS NULL
    GROUP BY p.BancoOrigen

    INSERT INTO @TablaBancoNoExiste (Clave)
    SELECT p.BancoDestino
    FROM @AX_Pagos p
        LEFT JOIN Adinco.dbo.PV_Banco b
            ON p.BancoDestino COLLATE DATABASE_DEFAULT = b.Clave
    WHERE b.BancoID IS NULL
    GROUP BY p.BancoDestino


    UPDATE t
    SET t.Banco = c.NombreCorto,
        t.RazonSocial = c.RazonSocial
    FROM @TablaBancoNoExiste t
        INNER JOIN Adinco.dbo.PV_BancosCARSO c
            ON t.Clave COLLATE DATABASE_DEFAULT = c.Clave

    INSERT INTO Adinco.dbo.PV_Banco (Banco, Clave, RazonSocial, Nacional)
    SELECT Banco,
           Clave,
           RazonSocial,
           1
    FROM @TablaBancoNoExiste
    WHERE Banco IS NOT NULL
    GROUP BY Banco,
             Clave,
             RazonSocial


    UPDATE p
    SET p.BancoIdOrigen = b.BancoID
    FROM @AX_Pagos p
        LEFT JOIN Adinco.dbo.PV_Banco b
            ON p.BancoOrigen COLLATE DATABASE_DEFAULT = b.Clave

    UPDATE p
    SET p.BancoIdDestino = b.BancoID
    FROM @AX_Pagos p
        LEFT JOIN Adinco.dbo.PV_Banco b
            ON p.BancoDestino COLLATE DATABASE_DEFAULT = b.Clave


    -- validacion de campos      
    UPDATE p
    SET p.TieneError = 1
    FROM @AX_Pagos p
    WHERE p.IdContrato IS NULL
          OR p.IdMoneda IS NULL
          OR p.BancoIdOrigen IS NULL
          OR BancoIdDestino IS NULL
          OR p.IdSubcontratista IS NULL
          OR (p.IdFacturaAdincoPrincipal IS NULL AND IdFacturaAdincoComplemento IS NULL)


    -- se obtienen las cuentas que no estan registradas en Adinco.dbo.PV_CuentaBancaria      
    -- cuando su longitud sea de 18 caracteres pertenece a CuentaClave los demas a NumeroCuenta      
    INSERT INTO @TablaNoExisteCuenta
    (
        Cuenta,
        BancoClave,
        Tipo,
        Len18,
        Titular,
        IdMoneda,
        BancoID,
        IdProveedor,
        TieneError,
        RFCEmisor
    )
    SELECT CuentaOrigen,
           BancoOrigen,
           'origen',
           CASE
               WHEN LEN(CuentaOrigen) = 18 THEN
                   1
               ELSE
                   0
           END,
           TitularOrigen,
           IdMoneda,
           BancoIdOrigen,
           IdSubcontratista,
           TieneError,
           RFC_Emisor
    FROM @AX_Pagos
    WHERE IdCuentaOrigen IS NULL
    GROUP BY CuentaOrigen,
             BancoOrigen,
             CuentaOrigen,
             TitularOrigen,
             IdMoneda,
             BancoIdOrigen,
             IdSubcontratista,
             TieneError,
             RFC_Emisor

    INSERT INTO @TablaNoExisteCuenta
    (
        Cuenta,
        BancoClave,
        Tipo,
        Len18,
        Titular,
        IdMoneda,
        BancoID,
        IdProveedor,
        TieneError,
        RFCEmisor
    )
    SELECT CuentaDestino,
           BancoDestino,
           'destino',
           CASE
               WHEN LEN(CuentaDestino) = 18 THEN
                   1
               ELSE
                   0
           END,
           TitularDestino,
           IdMoneda,
           BancoIdDestino,
           IdSubcontratista,
           TieneError,
           RFC_Emisor
    FROM @AX_Pagos
    WHERE IdCuentaDestino IS NULL
          AND ISNULL(TieneError, 0) = 0
    GROUP BY CuentaDestino,
             BancoDestino,
             CuentaDestino,
             TitularDestino,
             IdMoneda,
             BancoIdDestino,
             IdSubcontratista,
             TieneError,
             RFC_Emisor

    -- se Insertan las cuentas que no existian      
    INSERT INTO Adinco.dbo.PV_CuentaBancaria
    (
        BancoID,
        Titular,
        Sucursal,
        NumeroCuenta,
        CuentaClave,
        NumeroTarjeta,
        TipoMonedaID,
        IdProveedor,
        Predeterminado,
        IdTipoCuenta,
        TipoCuentaTemp,
        Codigo,
        claveBanco,
        RFC,
        Activa,
        CreadoPor,
        CreadoEn
    )
    SELECT BancoID,
           Titular,
           NULL,
           CASE
               WHEN Len18 = 1 THEN
                   NULL
               ELSE
                   Cuenta
           END,
           CASE
               WHEN Len18 = 1 THEN
                   Cuenta
               ELSE
                   NULL
           END,
           NULL,
           IdMoneda,
           IdProveedor,
           0,
           NULL,
           NULL,
           NULL,
           BancoClave,
           RFCEmisor,
           1,
           1,
           GETDATE()
    FROM @TablaNoExisteCuenta
    WHERE ISNULL(TieneError, 0) = 0

    -- ya que se insertaron las cuentas entonces hay que actualizar a que id les toco      
    UPDATE p
    SET p.IdCuentaOrigen = c.DatoBancarioID
    FROM @AX_Pagos p
        INNER JOIN Adinco.dbo.PV_CuentaBancaria c
            ON p.CuentaOrigen COLLATE DATABASE_DEFAULT = c.NumeroCuenta
               AND ISNULL(p.BuscarEnClaveLen18Origen, 0) = 0
               AND ISNULL(p.TieneError, 0) = 0


    UPDATE p
    SET p.IdCuentaOrigen = c.DatoBancarioID
    FROM @AX_Pagos p
        INNER JOIN Adinco.dbo.PV_CuentaBancaria c
            ON p.CuentaOrigen COLLATE DATABASE_DEFAULT = c.CuentaClave
               AND ISNULL(p.BuscarEnClaveLen18Origen, 0) = 1
               AND ISNULL(p.TieneError, 0) = 0


    UPDATE p
    SET p.IdCuentaDestino = c.DatoBancarioID
    FROM @AX_Pagos p
        INNER JOIN Adinco.dbo.PV_CuentaBancaria c
            ON p.CuentaDestino COLLATE DATABASE_DEFAULT = c.NumeroCuenta
               AND ISNULL(p.BuscarEnClaveLen18Origen, 0) = 0
               AND ISNULL(p.TieneError, 0) = 0

    UPDATE p
    SET p.IdCuentaDestino = c.DatoBancarioID
    FROM @AX_Pagos p
        INNER JOIN Adinco.dbo.PV_CuentaBancaria c
            ON p.CuentaDestino COLLATE DATABASE_DEFAULT = c.CuentaClave
               AND ISNULL(p.BuscarEnClaveLen18Origen, 0) = 1
               AND ISNULL(p.TieneError, 0) = 0

    -- en caso de no haber insertado la cuenta por algun caso   
    UPDATE p
    SET p.TieneError = 1
    FROM @AX_Pagos p
    WHERE p.IdCuentaOrigen IS NULL
          OR p.IdCuentaDestino IS NULL

    DECLARE @Contador INT = 1,
            @cantidadReg INT,
            @IdTransfer INT

    INSERT INTO @AX_PagosIntermedia
    (
        IdPago,
        FormaPago,
        CuentaOrigen,
        BancoOrigen,
        TitularOrigen,
        CuentaDestino,
        BancoDestino,
        TitularDestino,
        ReferenciaPago,
        FechaPago,
        MontoPagado,
        Interes,
        Moneda,
        Concepto,
        NoPolizaContable,
        UUIDFacturaPagada,
        MontoPagadoFactura,
        ComplementoPagoUUID,
        RECID,
        IdContrato,
        IdCuentaOrigen,
        IdCuentaDestino,
        IdMoneda,
        RFC_Emisor,
        IdSubcontratista,
        RazonSocialSubcontratista,
        BancoIdOrigen,
        BancoIdDestino,
        BuscarEnClaveLen18Origen,
        BuscarEnClaveLen18Destino,
        IdFacturaAdincoPrincipal,
        IdFacturaAdincoComplemento,
        TieneError,
        Editado,
        IdTransfer
    )
    SELECT IdPago,
           FormaPago,
           CuentaOrigen,
           BancoOrigen,
           TitularOrigen,
           CuentaDestino,
           BancoDestino,
           TitularDestino,
           ReferenciaPago,
           FechaPago,
           MontoPagado,
           Interes,
           Moneda,
           Concepto,
           NoPolizaContable,
           UUIDFacturaPagada,
           MontoPagadoFactura,
           ComplementoPagoUUID,
           RECID,
           IdContrato,
           IdCuentaOrigen,
           IdCuentaDestino,
           IdMoneda,
           RFC_Emisor,
           IdSubcontratista,
           RazonSocialSubcontratista,
           BancoIdOrigen,
           BancoIdDestino,
           BuscarEnClaveLen18Origen,
           BuscarEnClaveLen18Destino,
           IdFacturaAdincoPrincipal,
           IdFacturaAdincoComplemento,
           TieneError,
           Editado,
           IdTransfer
    FROM @AX_Pagos
    WHERE ISNULL(TieneError, 0) = 0


    --(1) Buscar Documento relacionado, para saber cual es el uuid del complemento en caso de que no me lo manden y ya haya sido registrado en la BD      
    UPDATE inter
    SET inter.ComplementoPagoUUID = f.UUID
    FROM @AX_PagosIntermedia inter
        LEFT JOIN Adinco.dbo.FI_CPDocRelacionado rel
            ON rel.IdDocumento COLLATE DATABASE_DEFAULT = inter.UUIDFacturaPagada
        INNER JOIN Adinco.dbo.FI_ComplementoDePago complemento
            ON complemento.IdComplementoDePago = rel.IdComplementoDePago
        INNER JOIN Adinco.dbo.FI_Factura f
            ON f.IdFactura = complemento.IdFactura
    WHERE inter.ComplementoPagoUUID IS NULL


    SELECT @cantidadReg = COUNT(1)
    FROM @AX_PagosIntermedia

    -- IdFormaPago 1 = PUE, 2 = PPD      
    -- este es el tratamiento que se le dara a la factura, pero el mostrado al cliente es otro      
    UPDATE p
    SET p.IdFormaPago = CASE
                            WHEN ISNULL(p.ComplementoPagoUUID, '') = '' THEN
                                1
                            ELSE
                                2
                        END
    FROM @AX_PagosIntermedia p

    -- este es el idformapago que se le mostrara al cliente ya sea pue o ppd segun el registrado en la factura      
    UPDATE p
    SET p.IdFormaPagoVistoCliente = CASE
                                        WHEN UPPER(f.MetodoPago) LIKE UPPER('PPD') THEN
                                            2
                                        ELSE
                                            1
                                    END
    FROM @AX_PagosIntermedia p
        INNER JOIN dbo.FI_Factura f
            ON p.UUIDFacturaPagada = f.UUID

    --SELECT 'quitarlo',* FROM @AX_Pagos WHERE RECID = '1234'  
    --   SELECT 'quitarlo',* FROM @AX_PagosIntermedia WHERE RECID = '1234'  

    WHILE (@cantidadReg >= @Contador)
    BEGIN
        INSERT INTO Adinco.dbo.FI_Transfer
        (
            IdContrato,
            ReferenciaBancaria,
            FechaPago,
            IdCuentaOrigen,
            IdCuentaDestino,
            MontoPagado,
            IdMoneda,
            Concepto,
            IdMetodoPago,
            ProcesadoSIPAC,
            NumeroPolizaContable,
            Intereses,
            CreadoPor,
            CreadoEn,
            IdFacturaPago, -- me comunico manuel que ya no se ocupaba      
            IdFormaPago
        )
        SELECT IdContrato,
               ReferenciaPago,
                     --Cambiar solo en productivo      
                     --       SUBSTRING(FechaPago, 7, 4) + '/' + SUBSTRING(FechaPago, 4, 2) + '/' + SUBSTRING(FechaPago, 1, 2) AS FechaPago,      
               FechaPago,
               IdCuentaOrigen,
               IdCuentaDestino,
               MontoPagado,
               IdMoneda,
               Concepto,
               4,
               0,    --Default 0      
               NoPolizaContable,
               Interes,
               1,
               GETDATE(),
               NULL, -- me comunico manuel que ya no se ocupaba      
               IdFormaPagoVistoCliente
        FROM @AX_PagosIntermedia
        WHERE Id = @Contador


        SELECT @IdTransfer = SCOPE_IDENTITY()

        UPDATE p
        SET p.IdTransferencia = @IdTransfer
        FROM dbo.AX_Pagos p
            INNER JOIN @AX_PagosIntermedia i
                ON i.IdPago = p.IdPago
        WHERE i.Id = @Contador


        INSERT INTO Adinco.dbo.FI_TransferFactura
        (
            IdTransfer,
            IdFactura,
            IdPedimentoComprobante,
            MontoPagado,
            CvTipoDocFacturacion,
            CreadoPor,
            CreadoEn
        )
        SELECT @IdTransfer,
               CASE
                   WHEN IdFormaPago = 1 THEN
                       IdFacturaAdincoPrincipal
                   ELSE
                       IdFacturaAdincoComplemento
               END,
               NULL,
               MontoPagado,
               CASE
                   WHEN IdFormaPago = 1 THEN
                       1
                   ELSE
                       6
               END, --1 si es PUE, 6 si es Complemento de Pago       
               1,
               GETDATE()
        FROM @AX_PagosIntermedia
        WHERE Id = @Contador


        UPDATE cr
        SET cr.MesPresentacion = CONVERT(
                                 DATE, CONCAT(YEAR(i.FechaPago), '-', MONTH(GETDATE()), '-', '01'))
        FROM Adinco.dbo.CO_Registro cr
            INNER JOIN @AX_PagosIntermedia i
                ON i.IdFacturaAdincoPrincipal = cr.IdFactura
        WHERE i.IdFormaPago = 1
              AND ISNULL(i.TieneError, 0) = 0

        UPDATE cr
        SET cr.MesPresentacion = CONVERT(
                                 DATE, CONCAT(YEAR(i.FechaPago), '-', MONTH(GETDATE()), '-', '01'))
        FROM Adinco.dbo.CO_Registro cr
            INNER JOIN @AX_PagosIntermedia i
                ON i.IdFacturaAdincoComplemento = cr.IdFactura
        WHERE ISNULL(i.IdFormaPago, 0) = 0
              AND ISNULL(i.TieneError, 0) = 0

        SET @Contador += 1
    END


    --se cambia la bandera de editado para que pueda seguir el proceso   
    UPDATE p
    SET p.Editado = 0
    FROM dbo.AX_Pagos p
        INNER JOIN @AX_Pagos ap
            ON ap.IdPago = p.IdPago
    WHERE ISNULL(ap.Editado, 0) = 1



    SELECT CASE
               WHEN IdContrato IS NULL
                    OR IdMoneda IS NULL
                    OR BancoIdOrigen IS NULL
                    OR BancoIdDestino IS NULL
                    OR IdSubcontratista IS NULL
                    OR (IdFacturaAdincoPrincipal IS NULL AND IdFacturaAdincoComplemento IS NULL)
                    OR IdCuentaOrigen IS NULL THEN
                   IdPago
           END AS IdPago,
           CASE
               WHEN IdContrato IS NULL
                    OR IdMoneda IS NULL
                    OR BancoIdOrigen IS NULL
                    OR BancoIdDestino IS NULL
                    OR IdSubcontratista IS NULL
                    OR (IdFacturaAdincoPrincipal IS NULL AND IdFacturaAdincoComplemento IS NULL)
                    OR IdCuentaOrigen IS NULL THEN
                   UUIDFacturaPagada
           END AS UUID,
           CASE
               WHEN IdContrato IS NULL
                    OR IdMoneda IS NULL
                    OR BancoIdOrigen IS NULL
                    OR BancoIdDestino IS NULL
                    OR IdSubcontratista IS NULL
                    OR (IdFacturaAdincoPrincipal IS NULL AND IdFacturaAdincoComplemento IS NULL)
                    OR IdCuentaOrigen IS NULL THEN
                   RECID
           END AS RECID,
           CONCAT(
           CASE
               WHEN IdContrato IS NULL THEN
                   ' No se tienen registro de la factura con ese UUID en Finanzas'
               ELSE
                   ''
           END,
           CASE
               WHEN IdMoneda IS NULL THEN
                   CONCAT(' No se reconoce la Moneda: ', Moneda)
               ELSE
                   ''
           END,
           CASE
               WHEN BancoIdOrigen IS NULL THEN
                   CONCAT(' El banco Origen no existe en el catalogo de Carso: ', BancoOrigen)
               ELSE
                   ''
           END,
           CASE
               WHEN BancoIdDestino IS NULL THEN
                   CONCAT(' El banco Destino no existe en el catalogo de Carso: ', BancoDestino)
               ELSE
                   ''
           END,
           CASE
               WHEN IdSubcontratista IS NULL THEN
                   CONCAT(
                   ' El Subcontratista no fue encontrado con el contrato de la factura: ',
                   RFC_Emisor)
               ELSE
                   ''
           END,
           CASE
               WHEN (IdFacturaAdincoPrincipal IS NULL AND IdFacturaAdincoComplemento IS NULL) THEN
                   ' No se tienen registro del UUID en Procura ni de la factura principal, ni del complemento '
               ELSE
                   ''
           END,
           CASE
               WHEN IdCuentaOrigen IS NULL THEN
                   ' Cuenta Origen no encontrada '
               ELSE
                   ''
           END,
           CASE
               WHEN IdCuentaDestino IS NULL THEN
                   ' Cuenta Destino no encontrada '
               ELSE
                   ''
           END) AS Motivo
    FROM @AX_Pagos
    WHERE TieneError = 1

END



