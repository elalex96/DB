CREATE PROCEDURE [dbo].[SP_Registro_EPT_ImportacionLayoutDetallePresupuestos] 
    @IdContrato INT,
    @IdUsuario INT,
    @IdRegistroFiduciario VARCHAR(150),
    @Presupuesto VARCHAR(150),
    @IdentificadorUUID VARCHAR(150),
    @IdentificadorPedimento VARCHAR(150),
    @IdentificadorComprobante VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    /*Variables de Apoyo*/
    DECLARE @ImportacionLayoutDetalleId INT = 0,
            @DocumentoFacturacionId INT = 0,
            @CreadoEn DATETIME = GETDATE(),
            @CountFacturas INT = 0,
            @CountPedimentosComprobantes INT = 0,
            @CountDetalleFacturas INT = 0,
            @CountDetallePedimentoComprobante INT = 0,
            @GenerarPresupuestos BIT = 1,
            @PresupuestoPersonalizado BIT = 0,
            @IdPresupuesto INT = 0;
    /*Tablas de Apoyo*/
    CREATE TABLE #EPT_ImportacionLayoutDetalle
    (
        Id INT,
        Presupuesto VARCHAR(150)
    )

    CREATE TABLE #Presupuesto
    (
        PresupuestoId INT,
        Presupuesto VARCHAR(150)
    )
    CREATE TABLE #EPT_ImportacionLayoutDetallePresupuestos
    (
        ImportacionLayoutDetalleId INT,
        DocumentoFacturacionId INT,
        Presupuesto VARCHAR(100),
        PresupuestoId INT,
        Activo BIT,
        CreadoEn DATETIME,
        CreadoPor INT
    )

    IF (
           @IdentificadorUUID = 'NA'
           AND @IdentificadorPedimento = 'NA'
           AND @IdentificadorComprobante = 'NA'
       )
    BEGIN
        SELECT '' AS Mensaje
        RETURN
    END

    IF (@IdentificadorUUID != 'NA')
    BEGIN
        INSERT INTO #EPT_ImportacionLayoutDetalle
        (
            Id,
            Presupuesto
        )
        SELECT EPT_ImportacionLayoutDetalle.Id,
               @Presupuesto
        FROM EPT_ImportacionLayout
            JOIN EPT_ImportacionLayoutDetalle
                ON EPT_ImportacionLayout.Id = EPT_ImportacionLayoutDetalle.ImportacionLayoutId
                   AND EPT_ImportacionLayout.ContratoId = @IdContrato
        WHERE EPT_ImportacionLayout.ContratoId = @IdContrato
              AND EPT_ImportacionLayoutDetalle.Contrato = @IdRegistroFiduciario
              AND EPT_ImportacionLayoutDetalle.IdentificadorDocumento = @IdentificadorUUID
        SELECT @CountDetalleFacturas = COUNT(1)
        FROM #EPT_ImportacionLayoutDetalle
    END
    IF (@IdentificadorPedimento != 'NA')
    BEGIN
        INSERT INTO #EPT_ImportacionLayoutDetalle
        (
            Id,
            Presupuesto
        )
        SELECT EPT_ImportacionLayoutDetalle.Id,
               @Presupuesto
        FROM EPT_ImportacionLayout
            JOIN EPT_ImportacionLayoutDetalle
                ON EPT_ImportacionLayout.Id = EPT_ImportacionLayoutDetalle.ImportacionLayoutId
                   AND EPT_ImportacionLayout.ContratoId = @IdContrato
        WHERE EPT_ImportacionLayout.ContratoId = @IdContrato
              AND EPT_ImportacionLayoutDetalle.Contrato = @IdRegistroFiduciario
              AND EPT_ImportacionLayoutDetalle.IdentificadorDocumento = @IdentificadorPedimento
        SELECT @CountDetallePedimentoComprobante = COUNT(1)
        FROM #EPT_ImportacionLayoutDetalle
    END
    IF (@IdentificadorComprobante != 'NA')
    BEGIN
        INSERT INTO #EPT_ImportacionLayoutDetalle
        (
            Id,
            Presupuesto
        )
        SELECT EPT_ImportacionLayoutDetalle.Id,
               @Presupuesto
        FROM EPT_ImportacionLayout
            JOIN EPT_ImportacionLayoutDetalle
                ON EPT_ImportacionLayout.Id = EPT_ImportacionLayoutDetalle.ImportacionLayoutId
                   AND EPT_ImportacionLayout.ContratoId = @IdContrato
        WHERE EPT_ImportacionLayout.ContratoId = @IdContrato
              AND EPT_ImportacionLayoutDetalle.Contrato = @IdRegistroFiduciario
              AND EPT_ImportacionLayoutDetalle.IdentificadorDocumento = @IdentificadorComprobante
        SELECT @CountDetallePedimentoComprobante = COUNT(1)
        FROM #EPT_ImportacionLayoutDetalle
    END

    /*----------------------Agregado de Presupuestos----------------------------*/
    IF (@CountDetalleFacturas = 0 AND @CountDetallePedimentoComprobante = 0)
    BEGIN

        SELECT '' AS Mensaje
        RETURN
    END


    DELETE #EPT_ImportacionLayoutDetalle
    FROM #EPT_ImportacionLayoutDetalle
        INNER JOIN EPT_ImportacionLayoutDetallePresupuestos
            ON #EPT_ImportacionLayoutDetalle.Id = EPT_ImportacionLayoutDetallePresupuestos.ImportacionLayoutDetalleId
    WHERE EPT_ImportacionLayoutDetallePresupuestos.Presupuesto = @Presupuesto


    IF (@CountDetalleFacturas >= 1)
    BEGIN
        SELECT @CountFacturas = COUNT(1)
        FROM FI_Factura
        WHERE UUID = @IdentificadorUUID
              AND IdContrato = @IdContrato
    END
    ELSE
    BEGIN
        IF (@CountDetallePedimentoComprobante >= 1)
        BEGIN
            IF (@IdentificadorComprobante = 'NA')
            BEGIN
                SELECT @CountPedimentosComprobantes = COUNT(1)
                FROM FI_PedimentoComprobante
                WHERE IdDocFacturacionSIPAC = @IdentificadorPedimento
                      AND IdContrato = @IdContrato
            END
            ELSE
            BEGIN
                SELECT @CountPedimentosComprobantes = COUNT(1)
                FROM FI_PedimentoComprobante
                WHERE IdDocFacturacionSIPAC = @IdentificadorComprobante
                      AND IdContrato = @IdContrato
            END

        END
    END
    --
    IF (@CountFacturas = 0 AND @CountPedimentosComprobantes = 0)
        SET @GenerarPresupuestos = 0

    IF (@GenerarPresupuestos = 1)
    BEGIN
        -- Facturas
        IF (@CountFacturas > 1)
        BEGIN
            SELECT 'El Identificador del documento [' + @IdentificadorUUID + '] se encuentra repetido ('
                   + CONVERT(VARCHAR(10), @CountFacturas)
                   + ') por lo que no es posible asignar el o los presupuestos correspondientes' AS Mensaje
            RETURN
        END
        ELSE
        BEGIN
            SELECT TOP 1
                @DocumentoFacturacionId = ISNULL(IdFactura, 0)
            FROM FI_Factura
            WHERE UUID = @IdentificadorUUID
                  AND IdContrato = @IdContrato
        END

        IF (@CountPedimentosComprobantes > 1)
        BEGIN
            IF (@IdentificadorComprobante = 'NA')
            BEGIN
                SELECT 'El Identificador del documento [' + @IdentificadorPedimento + '] se encuentra repetido ('
                       + CONVERT(VARCHAR(10), @CountPedimentosComprobantes)
                       + ') por lo que no es posible asignar el o los presupuestos correspondientes' AS Mensaje
                RETURN
            END
            ELSE
            BEGIN
                SELECT 'El Identificador del documento [' + @IdentificadorComprobante + '] se encuentra repetido ('
                       + CONVERT(VARCHAR(10), @CountPedimentosComprobantes)
                       + ') por lo que no es posible asignar el o los presupuestos correspondientes' AS Mensaje
                RETURN
            END

        END
        ELSE
        BEGIN
            IF (@IdentificadorComprobante = 'NA')
            BEGIN
                SELECT TOP 1
                    @DocumentoFacturacionId = ISNULL(IdPedimentoComprobante, 0)
                FROM FI_PedimentoComprobante
                WHERE IdDocFacturacionSIPAC = @IdentificadorPedimento
                      AND IdContrato = @IdContrato
            END
            ELSE
            BEGIN
                SELECT TOP 1
                    @DocumentoFacturacionId = ISNULL(IdPedimentoComprobante, 0)
                FROM FI_PedimentoComprobante
                WHERE IdDocFacturacionSIPAC = @IdentificadorComprobante
                      AND IdContrato = @IdContrato
            END
        END
        /*-------------------- Obtención de Datos para localizar presupuesto(s) específicos o generales ------------------------------*/
        /*CNH-A3.CÁRDENAS-MORA/2018*/
        IF (@IdContrato = 10036)
        BEGIN
            IF (@Presupuesto = 'PI2019-01')
            BEGIN
                SET @IdPresupuesto = 10061;
                SET @PresupuestoPersonalizado = 1;
            END
            IF (@Presupuesto = 'PI2019-02')
            BEGIN
                SET @IdPresupuesto = 10101;
                SET @PresupuestoPersonalizado = 1;
            END
            IF (@Presupuesto = 'PI2021-01')
            BEGIN
                SET @IdPresupuesto = 10183;
                SET @PresupuestoPersonalizado = 1;
            END
        END
        /*CNH-R02-L03-CS-04/2017*/
        IF (@IdContrato = 10047)
        BEGIN
            IF (@Presupuesto = 'PI2020-02')
            BEGIN
                SET @IdPresupuesto = 10125;
                SET @PresupuestoPersonalizado = 1;
            END
        END
        /*CNH-R02-L03-CS-05/2017*/
        IF (@IdContrato = 10048)
        BEGIN
            IF (@Presupuesto = 'PI2020-02')
            BEGIN
                SET @IdPresupuesto = 10126;
                SET @PresupuestoPersonalizado = 1;
            END
        END
        IF (@PresupuestoPersonalizado = 1)
        BEGIN
            INSERT INTO #Presupuesto
            (
                PresupuestoId,
                Presupuesto
            )
            VALUES
            (@IdPresupuesto, @Presupuesto)
        END
        ELSE
        BEGIN
            INSERT INTO #Presupuesto
            (
                PresupuestoId,
                Presupuesto
            )
            SELECT DISTINCT
                CO_Presupuesto.IdPresupuesto,
                @Presupuesto
            FROM CO_ProgramaActividad
                INNER JOIN CO_PeriodoContrato
                    ON CO_PeriodoContrato.IdContrato = @IdContrato
                       AND CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
                INNER JOIN CO_Presupuesto
                    ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
            WHERE SUBSTRING(CO_Presupuesto.IdPresupuestoCNH, 22, 10) = @Presupuesto
        END

        INSERT INTO #EPT_ImportacionLayoutDetallePresupuestos
        (
            ImportacionLayoutDetalleId,
            DocumentoFacturacionId,
            Presupuesto,
            PresupuestoId,
            Activo,
            CreadoEn,
            CreadoPor
        )
        SELECT #EPT_ImportacionLayoutDetalle.Id,
               @DocumentoFacturacionId,
               @Presupuesto,
               #Presupuesto.PresupuestoId,
               1,
               @CreadoEn,
               @IdUsuario
        FROM #EPT_ImportacionLayoutDetalle
            JOIN #Presupuesto
                ON #EPT_ImportacionLayoutDetalle.Presupuesto = #Presupuesto.Presupuesto

        /*------------------------Inserción en tabla EPT_ImportacionLayoutDetallePresupuestos--------------------------*/
        IF (
           (
               SELECT COUNT(1)
               FROM EPT_ImportacionLayoutDetallePresupuestos
               WHERE EPT_ImportacionLayoutDetallePresupuestos.ImportacionLayoutDetalleId = @ImportacionLayoutDetalleId
           ) >= 1
           )
        BEGIN
            /*Eliminacion de Registros ya agregados*/
            DELETE #EPT_ImportacionLayoutDetallePresupuestos
            FROM #EPT_ImportacionLayoutDetallePresupuestos
                INNER JOIN EPT_ImportacionLayoutDetallePresupuestos
                    ON #EPT_ImportacionLayoutDetallePresupuestos.ImportacionLayoutDetalleId = EPT_ImportacionLayoutDetallePresupuestos.ImportacionLayoutDetalleId
            WHERE #EPT_ImportacionLayoutDetallePresupuestos.DocumentoFacturacionId = EPT_ImportacionLayoutDetallePresupuestos.DocumentoFacturacionId
                  AND #EPT_ImportacionLayoutDetallePresupuestos.PresupuestoId = EPT_ImportacionLayoutDetallePresupuestos.PresupuestoId
        END
        /*Inserción de nuevos registros aun no agregados*/
        INSERT INTO EPT_ImportacionLayoutDetallePresupuestos
        (
            ImportacionLayoutDetalleId,
            DocumentoFacturacionId,
            Presupuesto,
            PresupuestoId,
            Activo,
            CreadoEn,
            CreadoPor
        )
        SELECT ImportacionLayoutDetalleId,
               DocumentoFacturacionId,
               Presupuesto,
               PresupuestoId,
               Activo,
               CreadoEn,
               CreadoPor
        FROM #EPT_ImportacionLayoutDetallePresupuestos;
    END;
    SELECT '' AS Mensaje
END;