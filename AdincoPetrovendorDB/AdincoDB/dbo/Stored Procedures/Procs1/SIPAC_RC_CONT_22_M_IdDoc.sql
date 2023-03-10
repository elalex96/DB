-- =============================================
-- Author: Manuel Cruz
-- Create date: 2017-04-10
-- Description:
-- Modificado: Manuel Cruz
-- Fecha Modificado: 2019-07-01
-- Description: Cambio de update para procesar el nombre de los PUE PPD y Complementos de Pago
-- Modificado:       Neri Del Angel
-- Fecha Modificado: 2020-01-13
-- Description:     *Agregar Validacion de @IdPresupuesto = 0
--                  *Agregar WITH (NOLOCK) en las tablas 
-- Modificado:       Neri Del Angel
-- Fecha Modificado: 2022-02-25
-- Description:     *Se ajusta para no traer los xml de los E
-- =============================================
-- Modificado:       Reyna Olvera
-- Fecha Modificado: 2022-08-18
-- Description:      SE MODIFICA LA CONSULTA POR DEUDA TECNICA, SE MODIFICA LOS JOINS Y LEFT JOIS DE UBICACIÓN, SE QUITAN ALGUNOS ALIAS
-- =============================================

CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_22_M_IdDoc]
    @Contrato      INT,
    @Mes           DATE,
    @IdPresupuesto INT = 0
AS
    BEGIN
        SET NOCOUNT ON;

        IF OBJECT_ID('tempdb..#FI_Factura', 'U') IS NOT NULL
            DROP TABLE #FI_Factura;

        IF OBJECT_ID('tempdb..#uuidNoReportar', 'U') IS NOT NULL
            DROP TABLE #uuidNoReportar;

        CREATE TABLE #uuidNoReportar (UUID VARCHAR(2000));

        CREATE TABLE #FI_Factura
            (
                [IdFactura]  [INT],
                [IdContrato] [INT],
                [SIPAC]      [INT]
            );

        /*Verificar día de consulta*/

        DECLARE @DiaReporte INT;
        DECLARE @DiaActual INT;
        --
        SELECT
            @DiaReporte = Dia
        FROM
            dbo.AP_Calendario
        WHERE
            YEAR(@Mes) = Anio
            AND MONTH(@Mes) = Mes
            AND Descripcion = 'Recepción de Información para el cálculo de contraprestaciones';
        --
        SELECT
            @DiaActual = DAY(GETDATE());
        /**/

        IF (@Mes = '20190801')
            BEGIN
                INSERT INTO #uuidNoReportar
                    (
                        UUID
                    )
                VALUES
                    (
                        '091A3242-EF0F-444A-A5C1-3D7D50247D3B'
                    ),
                    (
                        '775E782A-9493-3D40-9B24-E1604A865A0F'
                    ),
                    (
                        '78BB3869-8091-B049-98B4-1238E15E7BDA'
                    ),
                    (
                        'A6344C73-4C5A-EA4A-B2F8-3378CDA24C17'
                    );
            END;
        IF (@Mes <> '20190901')
            BEGIN
                INSERT INTO #uuidNoReportar
                    (
                        UUID
                    )
                VALUES
                    (
                        '9A159442-52BC-1E49-8190-D020953CE967'
                    );
            END;
        IF (@Mes <> '20200101')
            BEGIN
                INSERT INTO #uuidNoReportar
                    (
                        UUID
                    )
                VALUES
                    (
                        '78CA2E37-22C0-408C-8E94-105C7388A704'
                    ),
                    (
                        '30EFEC90-471E-434A-87CF-EFFEEE7C48C1'
                    );
            END;
        IF (@Mes = '20200501')
            BEGIN
                INSERT INTO #uuidNoReportar
                    (
                        UUID
                    )
                VALUES
                    (
                        'D515F4A9-244C-422E-A2B1-11B234039715'
                    ),
                    (
                        '1091E714-CC8E-46B8-8421-37470C285BAC'
                    ),
                    (
                        '95AB6B55-C312-4CAF-9A9E-BD7E7A2124AB'
                    ),
                    (
                        '10FDC8FB-DEBB-4BD5-8C10-6B51E61B5FE6'
                    );
            END;

        /*Actualizar o no nombre archivos*/

        INSERT INTO #FI_Factura
            (
                IdFactura,
                IdContrato,
                SIPAC
            )
                    SELECT
                        FI_Factura.IdFactura,
                        FI_Factura.IdContrato,
                        ROW_NUMBER() OVER (ORDER BY
                                               FI_Factura.Fecha,
                                               FI_Factura.IdSubcontratista
                                          ) AS SIPAC
                    FROM
                        dbo.FI_Transfer WITH (NOLOCK)
                        JOIN
                            dbo.FI_TransferFactura WITH (NOLOCK)
                                ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
								AND FI_Transfer.IdContrato = @Contrato
                        JOIN
                            dbo.FI_Factura WITH (NOLOCK)
                                ON FI_TransferFactura.IdFactura = FI_Factura.IdFactura
                        JOIN
                            dbo.CO_Registro WITH (NOLOCK)
                                ON FI_Factura.IdFactura = CO_Registro.IdFactura
                                   AND CO_Registro.IdEstado = 10004
                        JOIN
                            dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
                                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                        JOIN
                            dbo.CO_Presupuesto WITH (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
                        JOIN
                            dbo.CO_AnioContractual WITH (NOLOCK)
                                ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual
                        JOIN
                            dbo.CO_Contrato WITH (NOLOCK)
                                ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
                                   AND CO_Contrato.IdContrato = @Contrato
                        JOIN
                            dbo.CO_Servicio WITH (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                                   AND CO_Servicio.IdContrato = CO_Contrato.IdContrato
                    WHERE
                        CO_Contrato.IdContrato = @Contrato
                        AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes
                        AND CO_Registro.IdEstado = 10004
                        AND ISNULL(CONVERT(INT, FI_Factura.ProcesadoSIPAC), 0) = 0
                        AND CO_Presupuesto.IdPresupuesto = CASE
                                                               WHEN @IdPresupuesto = 0
                                                                   THEN CO_LineaPresupuestoMes.IdPresupuesto
                                                               ELSE
                                                                   @IdPresupuesto
                                                           END
                        AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
                        AND FI_Factura.TipoComprobante NOT LIKE '%egreso%'
                        AND FI_Factura.TipoComprobante NOT LIKE 'E%'
                        AND (
                                FI_Factura.MetodoPago LIKE '%exhibi%'
                                OR FI_Factura.MetodoPago LIKE '%PUE%'
                                OR FI_Factura.FormaPago LIKE '%exhibi%'
                                OR FI_Factura.FormaPago LIKE '%PUE%'
                            )
                    GROUP BY
                        FI_Factura.IdFactura,
                        FI_Factura.IdContrato,
                        FI_Factura.Fecha,
                        FI_Factura.IdSubcontratista;

        --
        DECLARE @maxid INT = 0;
        SELECT
            @maxid = MAX(SIPAC)
        FROM
            #FI_Factura;
        --

        INSERT INTO #FI_Factura
            (
                IdFactura,
                IdContrato,
                SIPAC
            )
                    SELECT
                        FCPDR.IdFactura,
                        FCPDR.IdContrato,
                        ROW_NUMBER() OVER (ORDER BY
                                               FCPDR.Fecha,
                                               FCPDR.IdSubcontratista
                                          ) + ISNULL(@maxid, 0) AS SIPAC
                    FROM
                        dbo.FI_Transfer WITH (NOLOCK)
                        JOIN
                            dbo.FI_TransferFactura WITH (NOLOCK)
                                ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
								AND FI_Transfer.IdContrato = @Contrato
                        JOIN
                            dbo.FI_ComplementoDePago WITH (NOLOCK)
                                ON FI_TransferFactura.IdFactura = FI_ComplementoDePago.IdFactura
                        JOIN
                            dbo.FI_CPDocRelacionado CPDR WITH (NOLOCK)
                                ON FI_ComplementoDePago.IdComplementoDePago = CPDR.IdComplementoDePago
                        JOIN
                            dbo.FI_Factura          FCP WITH (NOLOCK)
                                ON FI_ComplementoDePago.IdFactura = FCP.IdFactura
                        JOIN
                            dbo.FI_Factura          FCPDR WITH (NOLOCK)
                                ON CPDR.IdDocumento = FCPDR.UUID
                        JOIN
                            dbo.CO_Registro WITH (NOLOCK)
                                ON FCPDR.IdFactura = CO_Registro.IdFactura
                                   AND CO_Registro.IdEstado = 10004
                        JOIN
                            dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
                                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                        JOIN
                            dbo.CO_Presupuesto WITH (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
                        JOIN
                            dbo.CO_AnioContractual WITH (NOLOCK)
                                ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual
                        JOIN
                            dbo.CO_Contrato WITH (NOLOCK)
                                ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
                                   AND CO_Contrato.IdContrato = @Contrato
                        JOIN
                            dbo.CO_Servicio WITH (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                                   AND CO_Servicio.IdContrato = CO_Contrato.IdContrato
                    WHERE
                        CO_Contrato.IdContrato = @Contrato
                        AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes
                        AND CO_Registro.IdEstado = 10004
                        AND ISNULL(CONVERT(INT, FCP.ProcesadoSIPAC), 0) = 0
                        AND CO_Presupuesto.IdPresupuesto = CASE
                                                               WHEN @IdPresupuesto = 0
                                                                   THEN CO_LineaPresupuestoMes.IdPresupuesto
                                                               ELSE
                                                                   @IdPresupuesto
                                                           END
                        AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
                    GROUP BY
                        FCPDR.IdFactura,
                        FCPDR.IdContrato,
                        FCPDR.Fecha,
                        FCPDR.IdSubcontratista;
        --
        SELECT
            @maxid = MAX(SIPAC)
        FROM
            #FI_Factura;
        --

        INSERT INTO #FI_Factura
            (
                IdFactura,
                IdContrato,
                SIPAC
            )
                    SELECT
                        FCP.IdFactura,
                        FCP.IdContrato,
                        ROW_NUMBER() OVER (ORDER BY
                                               FCP.Fecha,
                                               FCP.IdSubcontratista
                                          ) + ISNULL(@maxid, 0) AS SIPAC
                    FROM
                        dbo.FI_Transfer WITH (NOLOCK)
                        JOIN
                            dbo.FI_TransferFactura WITH (NOLOCK)
                                ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
								AND FI_Transfer.IdContrato = @Contrato
                        JOIN
                            dbo.FI_ComplementoDePago WITH (NOLOCK)
                                ON FI_TransferFactura.IdFactura = FI_ComplementoDePago.IdFactura
                        JOIN
                            dbo.FI_CPDocRelacionado CPDR WITH (NOLOCK)
                                ON FI_ComplementoDePago.IdComplementoDePago = CPDR.IdComplementoDePago
                        JOIN
                            dbo.FI_Factura          FCP WITH (NOLOCK)
                                ON FI_ComplementoDePago.IdFactura = FCP.IdFactura
                        JOIN
                            dbo.FI_Factura          FCPDR WITH (NOLOCK)
                                ON CPDR.IdDocumento = FCPDR.UUID
                        JOIN
                            dbo.CO_Registro WITH (NOLOCK)
                                ON FCPDR.IdFactura = CO_Registro.IdFactura
                                   AND CO_Registro.IdEstado = 10004
                        JOIN
                            dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
                                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                        JOIN
                            dbo.CO_Presupuesto WITH (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
                        JOIN
                            dbo.CO_AnioContractual WITH (NOLOCK)
                                ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual
                        JOIN
                            dbo.CO_Contrato WITH (NOLOCK)
                                ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
                                   AND CO_Contrato.IdContrato = @Contrato
                        JOIN
                            dbo.CO_Servicio WITH (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                                   AND CO_Servicio.IdContrato = CO_Contrato.IdContrato
                    WHERE
                        CO_Contrato.IdContrato = @Contrato
                        AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes
                        AND CO_Registro.IdEstado = 10004
                        AND ISNULL(CONVERT(INT, FCP.ProcesadoSIPAC), 0) = 0
                        AND CO_Presupuesto.IdPresupuesto = CASE
                                                               WHEN @IdPresupuesto = 0
                                                                   THEN CO_LineaPresupuestoMes.IdPresupuesto
                                                               ELSE
                                                                   @IdPresupuesto
                                                           END
                        AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
                    GROUP BY
                        FCP.IdFactura,
                        FCP.IdContrato,
                        FCP.Fecha,
                        FCP.IdSubcontratista;
        --

        UPDATE
            FI_Factura
        SET
            IdDocFacturacionSIPAC = CASE
                                        WHEN FI_Factura.TipoComprobante <> 'P'
                                            THEN 'CF-' + LTRIM(REPLICATE('0', 2 - LEN(MONTH(@Mes))))
                                                 + LTRIM(MONTH(@Mes)) + LTRIM(YEAR(@Mes)) + '-'
                                                 + RIGHT('000000' + CAST(#FI_Factura.SIPAC AS VARCHAR(6)), 6)
                                        ELSE
                                            'CFP-' + LTRIM(REPLICATE('0', 2 - LEN(MONTH(@Mes)))) + LTRIM(MONTH(@Mes))
                                            + LTRIM(YEAR(@Mes)) + '-'
                                            + RIGHT('000000' + CAST(#FI_Factura.SIPAC AS VARCHAR(6)), 6)
                                    END,
            ArchivoXML = CASE
                             WHEN FI_Factura.TipoComprobante <> 'P'
                                 THEN 'CF_' + LTRIM(REPLICATE('0', 2 - LEN(MONTH(@Mes)))) + LTRIM(MONTH(@Mes))
                                      + LTRIM(YEAR(@Mes)) + '_'
                                      + RIGHT('000000' + CAST(#FI_Factura.SIPAC AS VARCHAR(6)), 6) + '.xml'
                             ELSE
                                 'CFP_' + LTRIM(REPLICATE('0', 2 - LEN(MONTH(@Mes)))) + LTRIM(MONTH(@Mes))
                                 + LTRIM(YEAR(@Mes)) + '_' + RIGHT('000000' + CAST(#FI_Factura.SIPAC AS VARCHAR(6)), 6)
                                 + '.xml'
                         END
        FROM
            #FI_Factura
            JOIN
                dbo.FI_Factura WITH (NOLOCK)
                    ON FI_Factura.IdFactura = #FI_Factura.IdFactura
        WHERE
            #FI_Factura.IdFactura = FI_Factura.IdFactura
            AND FI_Factura.UUID NOT IN (
                                           SELECT
                                               RPT.UUID
                                           FROM
                                               #uuidNoReportar RPT
                                       )
            AND FI_Factura.UUID NOT IN (
                                           SELECT
                                               ControlF.UUID
                                           FROM
                                               dbo.FI_ControlPPDComplementos ControlF WITH (NOLOCK)
                                           WHERE
                                               ControlF.IdContrato = @Contrato
                                       );



    END;

