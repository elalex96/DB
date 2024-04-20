IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SIPAC_RC_CONT_28_A'
    )
    DROP PROCEDURE SIPAC_RC_CONT_28_A
GO
CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_28_A]
    @Contrato      INT,
    @Mes           DATE,
    @IdPresupuesto INT
AS
    BEGIN
        -- =============================================
        -- Author:		Yazmin Gonzalez-Manuel Cruz
        -- Create date: 28-12-17
        -- Description:	
        -- =============================================
        -- Author:		 Reyna Olvera
        -- Create date: 28062022
        -- Description: Se elimina texto comentado
       -- =============================================
        -- Author:		 Reyna Olvera
        -- Create date: 20240418
        -- Description: Se agrega información para las columnas nuevas apartir de la 28_06
        -- =============================================
        SET NOCOUNT ON;
        DECLARE
            @Peso           INT = 1,
            @USD            INT = 2,
            @IdTipoContrato INT = 0,
			@IDRegFiducidiario VARCHAR(300),
			@IDSIPAC VARCHAR(300),
			@NumeroContrato VARCHAR(300),
			@CvTipoDocFacturacionFactura INT	= 1,
			@EsCiep INT = 1,
			@CvTipoDocFacturacionPedimento INT	= 2,
			@CvTipoDocFacturacionComprobante INT	= 3,
			@EstadoAprobado INT	= 10004;

        SELECT
            @IdTipoContrato = CO_CONTRATO.IdTipoContrato,
			@IDRegFiducidiario = CO_CONTRATO.IDRegFiducidiario,
			@IDSIPAC = CO_Contratista.IDSIPAC,
			@NumeroContrato = CO_CONTRATO.NumeroContrato
        FROM
				CO_CONTRATO
		JOIN
				dbo.CO_Contratista 
				ON  CO_CONTRATO.IdContratista	=	CO_Contratista.IdContratista
        WHERE
            CO_CONTRATO.IdContrato = @Contrato;

        SELECT DISTINCT
            ResultUnion.RF_00,
            ResultUnion.RI_00,
            ResultUnion.RC11_01,
            ResultUnion.RF01_01,
            ResultUnion.RC28_01,
            ResultUnion.RC28_02,
            ResultUnion.RC28_03,
            ResultUnion.RC28_04,
            ResultUnion.RC28_05,
            ResultUnion.RC28_07,
            ResultUnion.RC28_08,
            ResultUnion.RC28_09,
            ResultUnion.RC28_10,
            ResultUnion.RC28_11,
            ResultUnion.RC28_12,
            ResultUnion.RC28_13
        FROM
            (
                --EPT ligadas a facturas PUE
                SELECT
                    LTRIM(RTRIM(@IDSIPAC))                                   AS [RF_00],
                    LTRIM(RTRIM(@IDRegFiducidiario))                          AS [RI_00],
                   @NumeroContrato                                           AS [RC11_01],
                    EPT.IdDocFacturacionSIPAC                                  AS [RF01_01],
                    ISNULL(F.UUID, 'NA')                                       AS [RC28_01],
                    REPLACE(CONCAT(F.IdDocFacturacionSIPAC, '.xml'), '-', '_') AS [RC28_02],
                    MONTH(R.MesPresentacion)                                   AS [RC28_03],
                    YEAR(R.MesPresentacion)                                    AS [RC28_04],
                    2                                                          AS [RC28_05],
                    CASE
                        WHEN @IdTipoContrato = 1
                            THEN ISNULL(CO_ActividadCIEP.NombreActividad, '')
                        ELSE
                            ISNULL(CO_SubactividadPetrolera.SubactividadPetrolera, '')
                    END                                                        AS [RC28_07], --Concepto de operación SUBACTIVIDAD
                    SUM(   CASE
                               WHEN f.IdMoneda <> @USD
                                   then CAST(R.MontoRegistro / CO_TipoCambioDiario.TipoCambio AS DECIMAL(20, 2))
                               ELSE
                                   CAST(ISNULL(R.MontoRegistro, 0) AS DECIMAL(20, 2))
                           END
                       )                                                       AS RC28_08,   --Importe en factura (CFDI o Invoice)
                    CO_TipoCambioDiario.TipoCambio                             as RC28_09,   --Tipo de cambio (pesos por USD)
                    CO_AnioContractual.Anio                                    AS RC28_10,   --Año del Estudio de Precios de Transferencia
                    CASE
                        WHEN P.CIEP = @EsCiep
                            THEN ISNULL(CO_Rubro.NombreRubro, '')
                        ELSE
                            ISNULL(CO_TareaPetrolera.TareaPetrolera, '')
                    END                                                        AS RC28_11,   --Tipo de operación conforme al Estudio de Precios de Transferencia
                    SUM(   CASE
                               WHEN f.IdMoneda = @Peso
                                   then CAST(ISNULL(R.MontoRegistro, 0) AS DECIMAL(20, 2))
                               ELSE
                                   CAST(R.MontoRegistro * CO_TipoCambioDiario.TipoCambio AS DECIMAL(20, 2))
                           END
                       )                                                       AS RC28_12,
                    ''                                                         AS RC28_13    --Metodología utilizada
                FROM
                    dbo.FI_EstudioPreciosTransfer  EPT
                    JOIN
                        dbo.FI_Factura             F
                            ON EPT.IdEstudioPrecioTransfer	=	F.IdEstudioPrecioTransfer 
                 AND  EPT.IdContrato = @Contrato
                    JOIN
                        dbo.CO_Registro            R
                            ON  F.IdFactura	=	R.IdFactura
                               AND R.IdEstado = @EstadoAprobado
                               AND R.CvTipoDocFacturacion = @CvTipoDocFacturacionFactura
                    JOIN
                        dbo.CO_LineaPresupuestoMes L
                            ON R.IdPrograma	=	 L.IdLineaPresupuestoMes
                    JOIN
                        dbo.CO_Presupuesto         P
                            ON  L.IdPresupuesto	=	P.IdPresupuesto
                    JOIN
                        dbo.FI_TransferFactura     TF
                            ON  F.IdFactura	=	TF.IdFactura
                    JOIN
                        dbo.FI_Transfer            T
                            ON  TF.IdTransfer	=	T.IdTransferencia
                               AND F.IdContrato = T.IdContrato
                               AND F.IdDocFacturacionSIPAC IS NOT NULL
                    JOIN
                        CO_AnioContractual
                            ON P.IdAnioContractual = CO_AnioContractual.IdAnioContractual
                    LEFT JOIN
                        CO_TipoCambioDiario
                            ON convert(Date, F.FechaTimbrado) = CO_TipoCambioDiario.Fecha
                               AND CO_TipoCambioDiario.IdMoneda = @Peso
                    LEFT JOIN
                        dbo.CO_SubactividadPetrolera (NOLOCK)
                            ON L.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
                    LEFT JOIN
                        CO_Rubro (NOLOCK)
                            ON L.IdRubro = CO_Rubro.IdRubro
                    LEFT JOIN
                        dbo.CO_TareaPetrolera (NOLOCK)
                            ON L.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
                    LEFT JOIN
                        CO_ActividadCIEP (NOLOCK)
                            ON l.IdActividad = CO_ActividadCIEP.IdActividad
                               AND l.IdActividad = CO_ActividadCIEP.IdActividad
                WHERE
                    EPT.IdContrato = @Contrato
                    AND R.IdEstado = @EstadoAprobado
                    AND EPT.FechaCargaSIPAC = @Mes
                    AND R.CvTipoDocFacturacion = @CvTipoDocFacturacionFactura
                    AND ISNULL(CONVERT(INT, EPT.ProcesadoSIPAC), 0) = 0
                GROUP BY
                    EPT.IdDocFacturacionSIPAC,
                    ISNULL(F.UUID, 'NA'),
                    REPLACE(CONCAT(F.IdDocFacturacionSIPAC, '.xml'), '-', '_'),
                    MONTH(R.MesPresentacion),
                    YEAR(R.MesPresentacion),
                    CO_ActividadCIEP.NombreActividad,
                    CO_SubactividadPetrolera.SubactividadPetrolera,
                    F.IdMoneda,
                    f.FechaTimbrado,
                    CO_TipoCambioDiario.TipoCambio,
                    CO_AnioContractual.Anio,
                    P.CIEP,
                    CO_Rubro.NombreRubro,
                    CO_TareaPetrolera.TareaPetrolera
                --EPT ligado a Pedimentos de Importación o Complemento de Proveedor Extranjero
                UNION
                --
                SELECT
                    LTRIM(RTRIM(@IDSIPAC))          AS [RF_00],
                    LTRIM(RTRIM(@IDRegFiducidiario)) AS [RI_00],
                   @NumeroContrato                  AS [RC11_01],
                    EPT.IdDocFacturacionSIPAC         AS [RF01_01],
                    CASE
                        WHEN R.CvTipoDocFacturacion = @CvTipoDocFacturacionPedimento
                            THEN ISNULL(PC.NumeroPedimento, 'NA')
                        WHEN R.CvTipoDocFacturacion = @CvTipoDocFacturacionComprobante
                            THEN ISNULL(PC.IdDocFacturacionSIPAC, 'NA')
                    END                               AS [RC28_01],
                    CASE
                        WHEN R.CvTipoDocFacturacion IN (
                                                           @CvTipoDocFacturacionPedimento, @CvTipoDocFacturacionComprobante
                                                       )
                            THEN REPLACE(CONCAT(PC.IdDocFacturacionSIPAC, '.pdf'), '-', '_')
                    END                               AS [RC28_02],
                    MONTH(R.MesPresentacion)          AS [RC28_03],
                    YEAR(R.MesPresentacion)           AS [RC28_04],
                    2                                 AS [RC28_05],
                    CASE
                        WHEN @IdTipoContrato = 1
                            THEN ISNULL(CO_ActividadCIEP.NombreActividad, '')
                        ELSE
                            ISNULL(CO_SubactividadPetrolera.SubactividadPetrolera, '')
                    END                               AS [RC28_07], --Concepto de operación SUBACTIVIDAD
                    SUM(   CASE
                               WHEN PC.IdMoneda <> @USD
                                   then CAST(R.MontoRegistro / CO_TipoCambioDiario.TipoCambio AS DECIMAL(20, 2))
                               ELSE
                                   CAST(ISNULL(R.MontoRegistro, 0) AS DECIMAL(20, 2))
                           END
                       )                              AS RC28_08,   --Importe en factura (CFDI o Invoice), USD
                    CO_TipoCambioDiario.TipoCambio    as RC28_09,   --Tipo de cambio (pesos por USD)
                    CO_AnioContractual.Anio           AS RC28_10,   --Año del Estudio de Precios de Transferencia
                    CASE
                        WHEN P.CIEP = @EsCiep
                            THEN ISNULL(CO_Rubro.NombreRubro, '')
                        ELSE
                            ISNULL(CO_TareaPetrolera.TareaPetrolera, '')
                    END                               AS RC28_11,   --Tipo de operación conforme al Estudio de Precios de Transferencia
                    SUM(   CASE
                               WHEN PC.IdMoneda = @Peso
                                   then CAST(ISNULL(R.MontoRegistro, 0) AS DECIMAL(20, 2))
                               ELSE
                                   CAST(R.MontoRegistro * CO_TipoCambioDiario.TipoCambio AS DECIMAL(20, 2))
                           END
                       )                              AS RC28_12,
                    ''                                AS RC28_13    --Metodología utilizada
                FROM
                    dbo.FI_EstudioPreciosTransfer   EPT
                    JOIN
                        dbo.FI_PedimentoComprobante PC
                            ON EPT.IdEstudioPrecioTransfer	=	PC.IdEstudioPrecioTransfer 
                    AND  EPT.IdContrato = @Contrato
					AND EPT.FechaCargaSIPAC = @Mes
                    JOIN
                        dbo.CO_Registro             R
                            ON	PC.IdPedimentoComprobante	=	R.IdPedimentoComprobante 
                               AND R.IdEstado = @EstadoAprobado
                               AND R.CvTipoDocFacturacion IN (
                                                                 @CvTipoDocFacturacionPedimento, @CvTipoDocFacturacionComprobante
                                                             )
                    JOIN
                        dbo.CO_LineaPresupuestoMes  L
                            ON R.IdPrograma	=	L.IdLineaPresupuestoMes 
                    JOIN
                        dbo.CO_Presupuesto          P
                            ON L.IdPresupuesto	=	P.IdPresupuesto 
                    JOIN
                        dbo.FI_TransferFactura      TF
                            ON PC.IdPedimentoComprobante	=	TF.IdPedimentoComprobante 
                    JOIN
                        dbo.FI_Transfer             T
                            ON TF.IdTransfer	=	T.IdTransferencia 
                               AND PC.IdContrato = T.IdContrato
                               AND PC.IdDocFacturacionSIPAC IS NOT NULL
                    JOIN
                        CO_AnioContractual
                            ON P.IdAnioContractual = CO_AnioContractual.IdAnioContractual
                    LEFT JOIN
                        CO_TipoCambioDiario
                            ON PC.FechaPago = CO_TipoCambioDiario.Fecha
                               AND CO_TipoCambioDiario.IdMoneda = @Peso
                    LEFT JOIN
                        dbo.CO_SubactividadPetrolera (NOLOCK)
                            ON l.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
                    LEFT JOIN
                        CO_Rubro (NOLOCK)
                            ON l.IdRubro = CO_Rubro.IdRubro
                    LEFT JOIN
                        dbo.CO_TareaPetrolera (NOLOCK)
                            ON l.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
                    LEFT JOIN
                        CO_ActividadCIEP (NOLOCK)
                            ON l.IdActividad = CO_ActividadCIEP.IdActividad
                               AND l.IdActividad = CO_ActividadCIEP.IdActividad
                WHERE
                      EPT.IdContrato = @Contrato
                    AND R.IdEstado = @EstadoAprobado
                    AND EPT.FechaCargaSIPAC = @Mes
                    AND R.CvTipoDocFacturacion IN (
                                                   @CvTipoDocFacturacionPedimento,   @CvTipoDocFacturacionComprobante
                                                  )
                    AND ISNULL(CONVERT(INT, EPT.ProcesadoSIPAC), 0) = 0
                GROUP BY
                    
                    EPT.IdDocFacturacionSIPAC,
                    CASE
                        WHEN R.CvTipoDocFacturacion = @CvTipoDocFacturacionPedimento
                            THEN ISNULL(PC.NumeroPedimento, 'NA')
                        WHEN R.CvTipoDocFacturacion = @CvTipoDocFacturacionComprobante
                            THEN ISNULL(PC.IdDocFacturacionSIPAC, 'NA')
                    END,
                    CASE
                        WHEN R.CvTipoDocFacturacion IN (
                                                           @CvTipoDocFacturacionPedimento, @CvTipoDocFacturacionComprobante
                                                       )
                            THEN REPLACE(CONCAT(PC.IdDocFacturacionSIPAC, '.pdf'), '-', '_')
                    END,
                    MONTH(R.MesPresentacion),
                    YEAR(R.MesPresentacion),
                    CO_ActividadCIEP.NombreActividad,
                    CO_SubactividadPetrolera.SubactividadPetrolera,
                    pc.IdMoneda,
                    PC.FechaPago,
                    CO_TipoCambioDiario.TipoCambio,
                    CO_AnioContractual.anio,
                    P.CIEP,
                    CO_Rubro.NombreRubro,
                    CO_TareaPetrolera.TareaPetrolera

                --EPT ligado al Complemento de Pago de la factura PPD principal relacionado al gasto
                UNION
                --
                SELECT
                    LTRIM(RTRIM(@IDSIPAC))                                   AS [RF_00],
                    LTRIM(RTRIM(@IDRegFiducidiario))                          AS [RI_00],
                   @NumeroContrato                                           AS [RC11_01],
                    EPT.IdDocFacturacionSIPAC                                  AS [RF01_01],
                    ISNULL(F.UUID, 'NA')                                       AS [RC28_01],
                    REPLACE(CONCAT(F.IdDocFacturacionSIPAC, '.xml'), '-', '_') AS [RC28_02],
                    MONTH(R.MesPresentacion)                                   AS [RC28_03],
                    YEAR(R.MesPresentacion)                                    AS [RC28_04],
                    2                                                          AS [RC28_05],
                    CASE
                        WHEN @IdTipoContrato = 1
                            THEN ISNULL(CO_ActividadCIEP.NombreActividad, '')
                        ELSE
                            ISNULL(CO_SubactividadPetrolera.SubactividadPetrolera, '')
                    END                                                        AS [RC28_07], --Concepto de operación SUBACTIVIDAD
                    SUM(   CASE
                               WHEN FDR.IdMoneda <> @USD
                                   then CAST((R.MontoRegistro / CO_TipoCambioDiario.TipoCambio) AS DECIMAL(20, 2))
                               ELSE
                                   CAST(ISNULL(R.MontoRegistro, 0) AS DECIMAL(20, 2))
                           END
                       )                                                       AS RC28_08,   --Importe en factura (CFDI o Invoice),USD
                    CO_TipoCambioDiario.TipoCambio                             as RC28_09,   --Tipo de cambio (pesos por USD)
                    CO_AnioContractual.Anio                                    AS RC28_10,   --Año del Estudio de Precios de Transferencia
                    CASE
                        WHEN P.CIEP = @EsCiep
                            THEN ISNULL(CO_Rubro.NombreRubro, '')
                        ELSE
                            ISNULL(CO_TareaPetrolera.TareaPetrolera, '')
                    END                                                        AS RC28_11,   --" Tipo de operación conforme al Estudio de Precios de Transferencia"
                    SUM(   CASE
                               WHEN FDR.IdMoneda = @Peso
                                   then CAST(ISNULL(R.MontoRegistro, 0) AS DECIMAL(20, 2))
                               ELSE
                                   CAST(R.MontoRegistro * CO_TipoCambioDiario.TipoCambio AS DECIMAL(20, 2))
                           END
                       )                                                       AS RC28_12,
                    ''                                                         AS RC28_13    --Metodología utilizada
                FROM
                    dbo.FI_EstudioPreciosTransfer  EPT
                    JOIN
                        dbo.FI_Factura             F
                            ON  EPT.IdEstudioPrecioTransfer	=	F.IdEstudioPrecioTransfer
							AND  EPT.IdContrato = @Contrato
							 AND EPT.FechaCargaSIPAC = @Mes
                    JOIN
                        dbo.FI_ComplementoDePago   CP
                            ON CP.IdFactura = F.IdFactura
                    JOIN
                        dbo.FI_CPDocRelacionado    DR
                            ON CP.IdComplementoDePago = DR.IdComplementoDePago
                    JOIN
                        dbo.FI_Factura             FDR
                            ON FDR.UUID = DR.IdDocumento
                   
                    JOIN
                        dbo.CO_Registro            R
                            ON R.IdFactura = FDR.IdFactura
                               AND R.IdEstado = @EstadoAprobado
                               AND R.CvTipoDocFacturacion = @CvTipoDocFacturacionFactura
                    JOIN
                        dbo.CO_LineaPresupuestoMes L
                            ON L.IdLineaPresupuestoMes = R.IdPrograma
                    JOIN
                        dbo.CO_Presupuesto         P
                            ON P.IdPresupuesto = L.IdPresupuesto
                    JOIN
                        dbo.FI_TransferFactura     TF
                            ON TF.IdFactura = F.IdFactura
                    JOIN
                        dbo.FI_Transfer            T
                            ON T.IdTransferencia = TF.IdTransfer
                               AND F.IdContrato = T.IdContrato
                               AND F.IdDocFacturacionSIPAC IS NOT NULL
                    JOIN
                        CO_AnioContractual
                            ON P.IdAnioContractual = CO_AnioContractual.IdAnioContractual
                    LEFT JOIN
                        CO_TipoCambioDiario
                            ON convert(Date, FDR.FechaTimbrado) = CO_TipoCambioDiario.Fecha
                               AND CO_TipoCambioDiario.IdMoneda = @Peso
                    LEFT JOIN
                        dbo.CO_SubactividadPetrolera (NOLOCK)
                            ON l.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
                    LEFT JOIN
                        CO_Rubro (NOLOCK)
                            ON l.IdRubro = CO_Rubro.IdRubro
                    LEFT JOIN
                        dbo.CO_TareaPetrolera (NOLOCK)
                            ON l.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
                    LEFT JOIN
                        CO_ActividadCIEP (NOLOCK)
                            ON l.IdActividad = CO_ActividadCIEP.IdActividad
                               AND l.IdActividad = CO_ActividadCIEP.IdActividad
                WHERE
                      EPT.IdContrato = @Contrato
                    AND R.IdEstado = @EstadoAprobado
                    AND EPT.FechaCargaSIPAC = @Mes
                    AND R.CvTipoDocFacturacion = @CvTipoDocFacturacionFactura
                    AND ISNULL(CONVERT(INT, EPT.ProcesadoSIPAC), 0) = 0
                    AND F.IdDocFacturacionSIPAC IS NOT NULL
                    AND F.IdDocFacturacionSIPAC NOT LIKE '%2018%'
                GROUP BY
                    
                    EPT.IdDocFacturacionSIPAC,
                    ISNULL(F.UUID, 'NA'),
                    REPLACE(CONCAT(F.IdDocFacturacionSIPAC, '.xml'), '-', '_'),
                    MONTH(R.MesPresentacion),
                    YEAR(R.MesPresentacion),
                    CO_ActividadCIEP.NombreActividad,
                    CO_SubactividadPetrolera.SubactividadPetrolera,
                    FDR.IdMoneda,
                    convert(Date, FDR.FechaTimbrado),
                    CO_TipoCambioDiario.TipoCambio,
                    CO_AnioContractual.Anio,
                    P.CIEP,
                    CO_Rubro.NombreRubro,
                    CO_TareaPetrolera.TareaPetrolera
            ) AS ResultUnion
        ORDER BY
            ResultUnion.RC28_03;
    END;
