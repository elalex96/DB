-- =============================================
-- Author:                            Manuel Cruz
-- Create date: 2017-04-11
-- Description:  
-- =============================================
-- Modificado:       Marcos Garcia
-- Fecha Modificado: 2020-01-13
-- Description:     *Agregar Validacion de @IdPresupuesto = 0
--                  *Agregar WITH (NOLOCK) en las tablas 
-- =============================================
-- Modificado:       Reyna Olvera
-- Fecha Modificado: 2022-08-18
-- Description:      SE MODIFICA LA CONSULTA POR DEUDA TECNICA, SE MODIFICA LOS JOINS Y LEFT JOIS DE UBICACIÓN, SE QUITAN ALGUNOS ALIAS
-- =============================================
CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_26_M_IdDocFormaPago]
    @Contrato      INT,
    @Mes           DATE,
    @IdPresupuesto INT = 0
AS
    BEGIN
        SET NOCOUNT ON;
		
        /*Omitir facturas en la hoja 22*/
        IF OBJECT_ID('tempdb..#uuidNoReportar', 'U') IS NOT NULL
            DROP TABLE #uuidNoReportar;

        IF OBJECT_ID('tempdb..#FI_Transfer', 'U') IS NOT NULL
            DROP TABLE #FI_Transfer;

        CREATE TABLE #uuidNoReportar (UUID VARCHAR(2000));
        CREATE TABLE #FI_Transfer
            (
                [IdTransferencia] INT,
                [IdContrato]      INT,
                [IdMetodoPago]    INT,
                SIPAC             INT
            );

			  /*Verificar día de consulta*/
        DECLARE @DiaReporte INT;
        DECLARE @DiaActual INT;
        --
        SELECT
            @DiaReporte = Dia
        FROM
            dbo.AP_Calendario WITH (NOLOCK)
        WHERE
            YEAR(@Mes) = Anio
            AND MONTH(@Mes) = Mes
            AND Descripcion = 'Recepción de Información para el cálculo de contraprestaciones';
        --
        SELECT
            @DiaActual = DAY(GETDATE());
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
        INSERT INTO #FI_Transfer(IdTransferencia,IdContrato,IdMetodoPago,SIPAC)
                    SELECT
                        FI_Transfer.IdTransferencia,
                        FI_Transfer.IdContrato,
                        FI_Transfer.IdMetodoPago,
                        ROW_NUMBER() OVER (ORDER BY
                                               FI_Transfer.FechaPago
                                          ) AS SIPAC
                    FROM
                        dbo.FI_Transfer                 WITH (NOLOCK)
                        JOIN
                            dbo.FI_TransferFactura      WITH (NOLOCK)
                                ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
								AND	FI_Transfer.IdContrato	= @Contrato
                        JOIN
                            dbo.FI_Factura             WITH (NOLOCK)
                                ON FI_TransferFactura.IdFactura = FI_Factura.IdFactura
                                  -- AND FI_Factura.IdContrato = FI_Transfer.IdContrato
                        JOIN
                            dbo.CO_Registro             WITH (NOLOCK)
                                ON  FI_Factura.IdFactura = CO_Registro.IdFactura
								 AND CO_Registro.IdEstado = 10004
                        JOIN
                            dbo.CO_LineaPresupuestoMes  WITH (NOLOCK)
                                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                        JOIN
                            dbo.CO_Presupuesto          WITH (NOLOCK)
                                ON  CO_LineaPresupuestoMes.IdPresupuesto	=	CO_Presupuesto.IdPresupuesto
                        JOIN
                            dbo.CO_AnioContractual     WITH (NOLOCK)
                                ON  CO_Presupuesto.IdAnioContractual	=	CO_AnioContractual.IdAnioContractual 
                        JOIN
                            dbo.CO_Contrato            WITH (NOLOCK)
                                ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
								AND  CO_Contrato.IdContrato = @Contrato
                        JOIN
                            dbo.CO_Servicio            WITH (NOLOCK)
                                ON  CO_LineaPresupuestoMes.IdServicio	=	CO_Servicio.IdServicio
                                   AND CO_Servicio.IdContrato = CO_Contrato.IdContrato
                   
                    WHERE
                        CO_Contrato.IdContrato = @Contrato
                        AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes
                        AND CO_Registro.IdEstado = 10004
                        AND ISNULL(CONVERT(INT, FI_Transfer.ProcesadoSIPAC), 0) = 0
                        AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
                        AND (
                                FI_Factura.MetodoPago LIKE '%exhibi%'
                                OR FI_Factura.MetodoPago LIKE '%PUE%'
                                OR FI_Factura.FormaPago LIKE '%exhibi%'
                                OR FI_Factura.FormaPago LIKE '%PUE%'
                            )
                        AND CO_Presupuesto.IdPresupuesto = CASE
                                                  WHEN @IdPresupuesto = 0
                                                      THEN CO_LineaPresupuestoMes.IdPresupuesto
                                                  ELSE
                                                      @IdPresupuesto
                                              END
                    GROUP BY
                        FI_Transfer.IdTransferencia,
                        FI_Transfer.IdContrato,
                        FI_Transfer.IdMetodoPago,
                        FI_Transfer.FechaPago;

        DECLARE @maxid INT = 0;
        SELECT
            @maxid = MAX(SIPAC)
        FROM
            #FI_Transfer;
        --
        INSERT INTO #FI_Transfer
                    SELECT
                        FI_Transfer.IdTransferencia,
                        FI_Transfer.IdContrato,
                        FI_Transfer.IdMetodoPago,
                        ROW_NUMBER() OVER (ORDER BY
                                               FI_Transfer.FechaPago
                                          ) + ISNULL(@maxid, 0) AS SIPAC
                    FROM
                        dbo.FI_Transfer                WITH (NOLOCK)
                        JOIN
                            dbo.FI_TransferFactura      WITH (NOLOCK)
                                ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
								AND	FI_Transfer.IdContrato	= @Contrato
                        JOIN
                            dbo.FI_ComplementoDePago    WITH (NOLOCK)
                            ON  FI_TransferFactura.IdFactura	=	FI_ComplementoDePago.IdFactura
                        JOIN
                            dbo.FI_CPDocRelacionado     WITH (NOLOCK)
                                ON  FI_ComplementoDePago.IdComplementoDePago	=	FI_CPDocRelacionado.IdComplementoDePago
                        JOIN
                            dbo.FI_Factura             FCP WITH (NOLOCK)
                                ON FI_TransferFactura.IdFactura = FCP.IdFactura
                                 --  AND FI_Transfer.IdContrato = FCP.IdContrato
                        JOIN
                            dbo.FI_Factura             FCPDR WITH (NOLOCK)
                                ON FI_CPDocRelacionado.IdDocumento = FCPDR.UUID
                        JOIN
                            dbo.CO_Registro             WITH (NOLOCK)
                                ON FCPDR.IdFactura = CO_Registro.IdFactura
								AND CO_Registro.IdEstado = 10004
                        JOIN
                            dbo.CO_LineaPresupuestoMes  WITH (NOLOCK)
                                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                        JOIN
                            dbo.CO_Presupuesto         WITH (NOLOCK)
                                ON  CO_LineaPresupuestoMes.IdPresupuesto	=	CO_Presupuesto.IdPresupuesto
                        JOIN
                            dbo.CO_AnioContractual      WITH (NOLOCK)
                                ON CO_Presupuesto.IdAnioContractual	=	 CO_AnioContractual.IdAnioContractual
                        JOIN
                            dbo.CO_Contrato             WITH (NOLOCK)
                                ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
								AND	CO_Contrato.IdContrato = @Contrato
                        JOIN
                            dbo.CO_Servicio             WITH (NOLOCK)
                                ON   CO_LineaPresupuestoMes.IdServicio	=	CO_Servicio.IdServicio
                                   AND CO_Servicio.IdContrato = CO_Contrato.IdContrato
                    WHERE
                        CO_Contrato.IdContrato = @Contrato
                        AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes
                        AND CO_Registro.IdEstado = 10004
                        AND ISNULL(CONVERT(INT, FI_Transfer.ProcesadoSIPAC), 0) = 0
                        AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
                        AND FCP.UUID NOT IN (
                                                SELECT
                                                    RPT.UUID
                                                FROM
                                                    #uuidNoReportar RPT
                                            )
                        AND FCP.UUID NOT IN (
                                                SELECT
                                                    ControlF.UUID
                                                FROM
                                                    dbo.FI_ControlPPDComplementos ControlF
                                                WHERE
                                                    ControlF.IdContrato = @Contrato
                                            )
							AND CO_Presupuesto.IdPresupuesto = CASE
                                                  WHEN @IdPresupuesto = 0
                                                      THEN CO_LineaPresupuestoMes.IdPresupuesto
                                                  ELSE
                                                      @IdPresupuesto
                                              END
                    GROUP BY
                        FI_Transfer.IdTransferencia,
                        FI_Transfer.IdContrato,
                        FI_Transfer.IdMetodoPago,
                        FI_Transfer.FechaPago;
        --
        SELECT
            @maxid = MAX(SIPAC)
        FROM
            #FI_Transfer;
        --
        INSERT INTO #FI_Transfer
                    SELECT
                        FI_Transfer.IdTransferencia,
                        FI_Transfer.IdContrato,
                        FI_Transfer.IdMetodoPago,
                        ROW_NUMBER() OVER (ORDER BY
                                               FI_Transfer.FechaPago
                                          ) + ISNULL(@maxid, 0) AS SIPAC
                    FROM
                        dbo.FI_Transfer                  WITH (NOLOCK)
                        JOIN
                            dbo.FI_TransferFactura       WITH (NOLOCK)
                                ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
								AND	FI_Transfer.IdContrato	= @Contrato
                        JOIN
                            dbo.FI_PedimentoComprobante  WITH (NOLOCK)
                                ON FI_TransferFactura.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
                                  -- AND FI_Transfer.IdContrato = FI_PedimentoComprobante.IdContrato
                        JOIN
                            dbo.CO_Registro              WITH (NOLOCK)
                                ON  FI_PedimentoComprobante.IdPedimentoComprobante	=	CO_Registro.IdPedimentoComprobante
								AND CO_Registro.IdEstado = 10004
                        JOIN
                            dbo.CO_LineaPresupuestoMes   WITH (NOLOCK)
                                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                        JOIN
                            dbo.CO_Presupuesto           WITH (NOLOCK)
                                ON  CO_LineaPresupuestoMes.IdPresupuesto	=	CO_Presupuesto.IdPresupuesto
                        JOIN
                            dbo.CO_AnioContractual       WITH (NOLOCK)
                                ON   CO_Presupuesto.IdAnioContractual	=	CO_AnioContractual.IdAnioContractual
                        JOIN
                            dbo.CO_Contrato              WITH (NOLOCK)
                                ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
								AND	 CO_Contrato.IdContrato = @Contrato
                        JOIN
                            dbo.CO_Servicio              WITH (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdServicio	=	 CO_Servicio.IdServicio
                                   AND CO_Servicio.IdContrato = CO_Contrato.IdContrato
                    WHERE
                        CO_Contrato.IdContrato = @Contrato
                        AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes
                        AND CO_Registro.IdEstado = 10004
                        AND ISNULL(CONVERT(INT, FI_Transfer.ProcesadoSIPAC), 0) = 0
                        AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
                        AND ISNULL(FI_PedimentoComprobante.EsnotaCredito, 0) <> 1
                        AND CO_Presupuesto.IdPresupuesto = CASE
                                                  WHEN @IdPresupuesto = 0
                                                      THEN CO_LineaPresupuestoMes.IdPresupuesto
                                                  ELSE
                                                      @IdPresupuesto
                                              END
                    GROUP BY
                        FI_Transfer.IdTransferencia,
                        FI_Transfer.IdContrato,
                        FI_Transfer.IdMetodoPago,
                        FI_Transfer.FechaPago;

        --
        UPDATE
            FI_Transfer
        SET
            IdComprobantePago = CASE
                                    WHEN FI_Transfer.IdMetodoPago = 1
                                        THEN 'CH-'
                                    WHEN FI_Transfer.IdMetodoPago = 2
                                        THEN 'TC-'
                                    WHEN FI_Transfer.IdMetodoPago = 3
                                        THEN 'TD-'
                                    WHEN FI_Transfer.IdMetodoPago = 4
                                        THEN 'TE-'
                                    WHEN FI_Transfer.IdMetodoPago = 5
                                        THEN 'TS-'
                                    WHEN FI_Transfer.IdMetodoPago = 6
                                        THEN 'EF-'
                                    WHEN FI_Transfer.IdMetodoPago = 7
                                        THEN 'ME-'
                                    WHEN FI_Transfer.IdMetodoPago = 8
                                        THEN 'VD-'
                                    WHEN FI_Transfer.IdMetodoPago = 9
                                        THEN 'PD-'
                                    WHEN FI_Transfer.IdMetodoPago = 10
                                        THEN 'DE-'
                                    WHEN FI_Transfer.IdMetodoPago = 11
                                        THEN 'DP-'
                                    WHEN FI_Transfer.IdMetodoPago = 12
                                        THEN 'PS-'
                                    WHEN FI_Transfer.IdMetodoPago = 13
                                        THEN 'PC-'
                                    WHEN FI_Transfer.IdMetodoPago = 14
                                        THEN 'CD-'
                                    WHEN FI_Transfer.IdMetodoPago = 15
                                        THEN 'CP-'
                                    WHEN FI_Transfer.IdMetodoPago = 16
                                        THEN 'NOV-'
                                    WHEN FI_Transfer.IdMetodoPago = 17
                                        THEN 'CON-'
                                    WHEN FI_Transfer.IdMetodoPago = 18
                                        THEN 'RD-'
                                    WHEN FI_Transfer.IdMetodoPago = 19
                                        THEN 'PRE_CAD-'
                                    WHEN FI_Transfer.IdMetodoPago = 20
                                        THEN 'SA-'
                                    WHEN FI_Transfer.IdMetodoPago = 21
                                        THEN 'AA-'
                                END + LTRIM(REPLICATE('0', 2 - LEN(MONTH(@Mes)))) + LTRIM(MONTH(@Mes))
                                + LTRIM(YEAR(@Mes)) + '-' + RIGHT('000000' + CAST(TRT.SIPAC AS VARCHAR(6)), 6),
            NombreExtencionArchivo = CASE
                                         WHEN FI_Transfer.IdMetodoPago = 1
                                             THEN 'CH_'
                                         WHEN FI_Transfer.IdMetodoPago = 2
                                             THEN 'TC_'
                                         WHEN FI_Transfer.IdMetodoPago = 3
                                             THEN 'TD_'
                                         WHEN FI_Transfer.IdMetodoPago = 4
                                             THEN 'TE_'
                                         WHEN FI_Transfer.IdMetodoPago = 5
                                             THEN 'TS_'
                                         WHEN FI_Transfer.IdMetodoPago = 6
                                             THEN 'EF_'
                                         WHEN FI_Transfer.IdMetodoPago = 7
                                             THEN 'ME_'
                                         WHEN FI_Transfer.IdMetodoPago = 8
                                             THEN 'VD_'
                                         WHEN FI_Transfer.IdMetodoPago = 9
                                             THEN 'PD_'
                                         WHEN FI_Transfer.IdMetodoPago = 10
                                             THEN 'DE_'
                                         WHEN FI_Transfer.IdMetodoPago = 11
                                             THEN 'DP_'
                                         WHEN FI_Transfer.IdMetodoPago = 12
                                             THEN 'PS_'
                                         WHEN FI_Transfer.IdMetodoPago = 13
                                             THEN 'PC_'
                                         WHEN FI_Transfer.IdMetodoPago = 14
                                             THEN 'CD_'
                                         WHEN FI_Transfer.IdMetodoPago = 15
                                             THEN 'CP_'
                                         WHEN FI_Transfer.IdMetodoPago = 16
                                             THEN 'NOV_'
                                         WHEN FI_Transfer.IdMetodoPago = 17
                                             THEN 'CON_'
                                         WHEN FI_Transfer.IdMetodoPago = 18
                                             THEN 'RD_'
                                         WHEN FI_Transfer.IdMetodoPago = 19
                                             THEN 'PRE_CAD_'
                                         WHEN FI_Transfer.IdMetodoPago = 20
                                             THEN 'SA_'
                                         WHEN FI_Transfer.IdMetodoPago = 21
                                             THEN 'AA_'
                                     END + LTRIM(REPLICATE('0', 2 - LEN(MONTH(@Mes)))) + LTRIM(MONTH(@Mes))
                                     + LTRIM(YEAR(@Mes)) + '_' + RIGHT('000000' + CAST(TRT.SIPAC AS VARCHAR(6)), 6)
                                     + '.pdf'
        FROM
            FI_Transfer        WITH (NOLOCK)
            JOIN
                #FI_Transfer TRT
                    ON FI_Transfer.IdTransferencia = TRT.IdTransferencia
        WHERE
            FI_Transfer.IdTransferencia = TRT.IdTransferencia;

    END;

