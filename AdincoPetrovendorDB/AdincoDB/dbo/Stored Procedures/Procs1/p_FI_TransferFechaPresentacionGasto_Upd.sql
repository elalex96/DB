
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK, Nombrado de Tablas en select, eliminado de codigo comentado, se minimizan los lefts
-- =============================================
CREATE PROC [dbo].[p_FI_TransferFechaPresentacionGasto_Upd]
    --
    @pIdTransferencia INT,
    @IdContrato INT,
    @IdUsuario INT
--
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MesPresentacionCGI DATE,
            @FechaPago DATE,
            @FechaMayor DATE;
    --
    DECLARE @pGastosActualizados INT;
    --
    CREATE TABLE #Fechas
    (
        Fecha DATE,
        Tipo INT
    );
    --
    CREATE TABLE #tmpTemp
    (
        IdRegistro INT,
        MesPresentacionCGI DATE,
        IdTransferencia INT,
        IdContrato INT,
        RegistroMesPresentacion DATE
    );
    /**/
    SELECT @MesPresentacionCGI = '1999-01-01',
           @FechaPago = DATEFROMPARTS(YEAR(dbo.FI_Transfer.FechaPago), MONTH(dbo.FI_Transfer.FechaPago), 1)
    FROM dbo.CO_Contrato (NOLOCK)
        JOIN dbo.FI_Transfer (NOLOCK)
            ON dbo.CO_Contrato.IdContrato = dbo.FI_Transfer.IdContrato
    WHERE dbo.CO_Contrato.IdContrato = @IdContrato
          AND dbo.FI_Transfer.IdTransferencia = @pIdTransferencia;
    --
    INSERT INTO #Fechas
    (
        Fecha,
        Tipo
    )
    VALUES
    (@MesPresentacionCGI, 1),
    (@FechaPago, 2);
    --
    SELECT @FechaMayor = MAX(Fecha)
    FROM #Fechas;
    /**/
    INSERT INTO #tmpTemp
    (
        IdRegistro,
        MesPresentacionCGI,
        IdTransferencia,
        IdContrato,
        RegistroMesPresentacion
    )
    SELECT dbo.CO_Registro.IdRegistro,
           MesPresentacion = dbo.CO_Contrato.MesPresentacionCGI,
           dbo.FI_Transfer.IdTransferencia,
           dbo.FI_Transfer.IdContrato,
           MesPresentacionActual = dbo.CO_Registro.MesPresentacion
    FROM dbo.FI_Transfer (NOLOCK)
        JOIN dbo.FI_TransferFactura (NOLOCK)
            ON dbo.FI_Transfer.IdTransferencia = dbo.FI_TransferFactura.IdTransfer
        JOIN dbo.FI_Factura (NOLOCK)
            ON dbo.FI_TransferFactura.IdFactura = dbo.FI_Factura.IdFactura
        JOIN dbo.CO_Registro (NOLOCK)
            ON dbo.FI_Factura.IdFactura = dbo.CO_Registro.IdFactura
        LEFT JOIN dbo.CO_Contrato (NOLOCK)
            ON dbo.FI_Transfer.IdContrato = dbo.CO_Contrato.IdContrato
    WHERE dbo.FI_Transfer.IdTransferencia = @pIdTransferencia
          AND dbo.CO_Contrato.MesPresentacionCGI IS NOT NULL
          AND dbo.FI_Transfer.IdContrato = @IdContrato
    --
    INSERT INTO #tmpTemp
    (
        IdRegistro,
        MesPresentacionCGI,
        IdTransferencia,
        IdContrato,
        RegistroMesPresentacion
    )
    SELECT dbo.CO_Registro.IdRegistro,
           MesPresentacion = dbo.CO_Contrato.MesPresentacionCGI,
           dbo.FI_Transfer.IdTransferencia,
           dbo.FI_Transfer.IdContrato,
           MesPresentacionActual = dbo.CO_Registro.MesPresentacion
    FROM dbo.FI_Transfer (NOLOCK)
        JOIN dbo.FI_TransferFactura (NOLOCK)
            ON dbo.FI_Transfer.IdTransferencia = dbo.FI_TransferFactura.IdTransfer
        JOIN dbo.FI_PedimentoComprobante (NOLOCK)
            ON dbo.FI_TransferFactura.IdPedimentoComprobante = dbo.FI_PedimentoComprobante.IdPedimentoComprobante
        JOIN dbo.CO_Registro (NOLOCK)
            ON dbo.FI_PedimentoComprobante.IdPedimentoComprobante = dbo.CO_Registro.IdPedimentoComprobante
        LEFT JOIN dbo.CO_Contrato (NOLOCK)
            ON dbo.FI_Transfer.IdContrato = dbo.CO_Contrato.IdContrato
    WHERE dbo.FI_Transfer.IdTransferencia = @pIdTransferencia
          AND dbo.CO_Contrato.MesPresentacionCGI IS NOT NULL
          AND dbo.FI_Transfer.IdContrato = @IdContrato
    --
    INSERT INTO #tmpTemp
    (
        IdRegistro,
        MesPresentacionCGI,
        IdTransferencia,
        IdContrato,
        RegistroMesPresentacion
    )
    SELECT dbo.CO_Registro.IdRegistro,
           MesPresentacion = dbo.CO_Contrato.MesPresentacionCGI,
           dbo.FI_Transfer.IdTransferencia,
           dbo.FI_Transfer.IdContrato,
           MesPresentacionActual = dbo.CO_Registro.MesPresentacion
    FROM dbo.FI_Transfer (NOLOCK)
        JOIN dbo.FI_Factura (NOLOCK)
            ON dbo.FI_Transfer.IdFacturaPago = dbo.FI_Factura.IdFactura
        JOIN dbo.CO_Registro (NOLOCK)
            ON dbo.FI_Factura.IdFactura = dbo.CO_Registro.IdFactura
        LEFT JOIN dbo.CO_Contrato (NOLOCK)
            ON dbo.FI_Transfer.IdContrato = dbo.CO_Contrato.IdContrato
    WHERE dbo.FI_Transfer.IdTransferencia = @pIdTransferencia
          AND dbo.CO_Contrato.MesPresentacionCGI IS NOT NULL
          AND dbo.FI_Transfer.IdContrato = @IdContrato;
    /**/
    SELECT @pGastosActualizados = COUNT(DISTINCT IdRegistro)
    FROM #tmpTemp;

    /**/
    UPDATE CO_Registro
    SET CO_Registro.MesPresentacion = @FechaMayor
    FROM CO_Registro (NOLOCK)
        JOIN #tmpTemp
            ON #tmpTemp.IdRegistro = CO_Registro.IdRegistro
    WHERE #tmpTemp.IdRegistro = CO_Registro.IdRegistro;
    /**/
    SELECT @pGastosActualizados,
           CONVERT(VARCHAR, @FechaMayor, 111);

END;