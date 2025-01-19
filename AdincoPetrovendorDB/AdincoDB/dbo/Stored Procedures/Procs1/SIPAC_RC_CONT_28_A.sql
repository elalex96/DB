IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SIPAC_RC_CONT_28_A'
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
			@IDRegFiducidiario = LTRIM(RTRIM(CO_CONTRATO.IDRegFiducidiario)),
			@IDSIPAC = LTRIM(RTRIM(CO_Contratista.IDSIPAC)),
			@NumeroContrato = CO_CONTRATO.NumeroContrato
        FROM
				CO_CONTRATO (NOLOCK)
		JOIN
				dbo.CO_Contratista (NOLOCK) 
				ON  CO_CONTRATO.IdContrato = @Contrato
				AND CO_CONTRATO.IdContratista	=	CO_Contratista.IdContratista
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
                    @IDSIPAC													AS [RF_00],
                    @IDRegFiducidiario											AS [RI_00],
					@NumeroContrato												AS [RC11_01],
                    EPT.IdDocFacturacionSIPAC									AS [RF01_01],
                    ISNULL(F.UUID, 'NA')										AS [RC28_01],
                    REPLACE(CONCAT(F.IdDocFacturacionSIPAC, '.xml'), '-', '_')	AS [RC28_02],
                    MONTH(R.MesPresentacion)									AS [RC28_03],
                    YEAR(R.MesPresentacion)										AS [RC28_04],
                    2															AS [RC28_05],
                    CASE
                        WHEN @IdTipoContrato = 1
                            THEN ISNULL(CO_ActividadCIEP.NombreActividad, '')
                        ELSE
                            ISNULL(CO_SubactividadPetrolera.SubactividadPetrolera, '')
                    END                                                        AS [RC28_07], --Concepto de operación SUBACTIVIDAD
                    SUM(   
						CASE
                            WHEN F.IdMoneda = @USD THEN CAST(ISNULL(R.MontoRegistro, 0) AS DECIMAL(20, 2)) -- Dólar
							WHEN F.IdMoneda = @Peso THEN CAST(R.MontoRegistro * CO_TipoCambioDiario.TipoCambio AS DECIMAL(20, 2)) -- Peso
							ELSE CAST(R.MontoRegistro * ISNULL(otraMoneda.TipoCambio, 1) AS DECIMAL(20, 2)) -- Otras monedas
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
                    SUM(
						CASE
							WHEN F.IdMoneda = 1 -- Pesos (MXN)
								THEN CAST(R.MontoRegistro AS DECIMAL(20, 2)) -- Ya esta en pesos
							WHEN F.IdMoneda = 2 -- Dolar Americano (USD)
								THEN CAST(R.MontoRegistro * ISNULL(CO_TipoCambioDiario.TipoCambio, 1) AS DECIMAL(20, 2)) -- USD a Pesos
							ELSE
								CAST(R.MontoRegistro * ISNULL(otraMoneda.TipoCambio, 1) * ISNULL(CO_TipoCambioDiario.TipoCambio, 1) AS DECIMAL(20, 2)) -- Otras monedas a Pesos (MontoRegistro * TipoCambioMoneda * TipoCambioPesos)
						END
                       )                                                       AS RC28_12,--Colocar el importe en pesos (MXN) de la operacion analizada en el Estudio de Precios de Transferencia
                    ''                                                         AS RC28_13 --Metodología utilizada
                FROM
                    dbo.FI_EstudioPreciosTransfer  EPT (NOLOCK)
                    JOIN
                        dbo.FI_Factura             F
                            ON EPT.IdEstudioPrecioTransfer	=	F.IdEstudioPrecioTransfer 
								AND  EPT.IdContrato = @Contrato
                    JOIN
                        dbo.CO_Registro            R (NOLOCK)
                            ON  F.IdFactura	=	R.IdFactura
                               AND R.IdEstado = @EstadoAprobado
                               AND R.CvTipoDocFacturacion = @CvTipoDocFacturacionFactura
                    JOIN
                        dbo.CO_LineaPresupuestoMes L (NOLOCK)
                            ON R.IdPrograma	=	 L.IdLineaPresupuestoMes
                    JOIN
                        dbo.CO_Presupuesto         P (NOLOCK)
                            ON  L.IdPresupuesto	=	P.IdPresupuesto
                    JOIN
                        dbo.FI_TransferFactura     TF (NOLOCK)
                            ON  F.IdFactura	=	TF.IdFactura
                    JOIN
                        dbo.FI_Transfer            T (NOLOCK)
                            ON  TF.IdTransfer	=	T.IdTransferencia
                               AND F.IdContrato = T.IdContrato
                               AND F.IdDocFacturacionSIPAC IS NOT NULL
                    JOIN
                        CO_AnioContractual (NOLOCK)
                            ON P.IdAnioContractual = CO_AnioContractual.IdAnioContractual
                    LEFT JOIN
                        CO_TipoCambioDiario (NOLOCK)
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
					LEFT JOIN
                        CO_TipoCambioDiario (NOLOCK) otraMoneda
                            ON CONVERT(Date, F.FechaTimbrado) = otraMoneda.Fecha
                               AND F.IdMoneda = otraMoneda.IdMoneda 
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
                    F.FechaTimbrado,
                    CO_TipoCambioDiario.TipoCambio,
                    CO_AnioContractual.Anio,
                    P.CIEP,
                    CO_Rubro.NombreRubro,
                    CO_TareaPetrolera.TareaPetrolera,
					otraMoneda.TipoCambio
                --EPT ligado a Pedimentos de Importación o Complemento de Proveedor Extranjero
                UNION
                --
                SELECT
                    @IDSIPAC							AS [RF_00],
                    @IDRegFiducidiario					AS [RI_00],
					@NumeroContrato						AS [RC11_01],
                    EPT.IdDocFacturacionSIPAC			AS [RF01_01],
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
                    SUM(   
						CASE
							WHEN PC.IdMoneda = @USD THEN CAST(ISNULL(R.MontoRegistro, 0) AS DECIMAL(20, 2)) -- Dólar
							WHEN PC.IdMoneda = @Peso THEN CAST(R.MontoRegistro * CO_TipoCambioDiario.TipoCambio AS DECIMAL(20, 2)) -- Peso
							ELSE CAST(R.MontoRegistro * ISNULL(otraMoneda.TipoCambio, 1) AS DECIMAL(20, 2)) -- Otras monedas
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
                    SUM(
						CASE
							WHEN PC.IdMoneda = 1 -- Pesos (MXN)
								THEN CAST(R.MontoRegistro AS DECIMAL(20, 2)) -- Ya esta en pesos
							WHEN PC.IdMoneda = 2 -- Dolar Americano (USD)
								THEN CAST(R.MontoRegistro * ISNULL(CO_TipoCambioDiario.TipoCambio, 1) AS DECIMAL(20, 2)) -- USD a Pesos
							ELSE
								CAST(R.MontoRegistro * ISNULL(otraMoneda.TipoCambio, 1) * ISNULL(CO_TipoCambioDiario.TipoCambio, 1) AS DECIMAL(20, 2)) -- Otras monedas a Pesos (MontoRegistro * TipoCambioMoneda * TipoCambioPesos)
						END
                       )                              AS RC28_12,	-- Monto en pesos Colocar el importe en pesos (MXN) de la operacion analizada en el Estudio de Precios de Transferencia
                    ''                                AS RC28_13    --Metodología utilizada
                FROM
                    dbo.FI_EstudioPreciosTransfer   EPT (NOLOCK)
                    JOIN
                        dbo.FI_PedimentoComprobante PC (NOLOCK)
                            ON EPT.IdEstudioPrecioTransfer	=	PC.IdEstudioPrecioTransfer 
								AND  EPT.IdContrato = @Contrato
								AND EPT.FechaCargaSIPAC = @Mes
                    JOIN
                        dbo.CO_Registro             R (NOLOCK)
                            ON	PC.IdPedimentoComprobante	=	R.IdPedimentoComprobante 
                               AND R.IdEstado = @EstadoAprobado
                               AND R.CvTipoDocFacturacion IN (
                                                                 @CvTipoDocFacturacionPedimento, @CvTipoDocFacturacionComprobante
                                                             )
                    JOIN
                        dbo.CO_LineaPresupuestoMes  L (NOLOCK)
                            ON R.IdPrograma	=	L.IdLineaPresupuestoMes 
                    JOIN
                        dbo.CO_Presupuesto          P (NOLOCK)
                            ON L.IdPresupuesto	=	P.IdPresupuesto 
                    JOIN
                        dbo.FI_TransferFactura      TF (NOLOCK)
                            ON PC.IdPedimentoComprobante	=	TF.IdPedimentoComprobante 
                    JOIN
                        dbo.FI_Transfer             T (NOLOCK)
                            ON TF.IdTransfer	=	T.IdTransferencia 
                               AND PC.IdContrato = T.IdContrato
                               AND PC.IdDocFacturacionSIPAC IS NOT NULL
                    JOIN
                        CO_AnioContractual (NOLOCK)
                            ON P.IdAnioContractual = CO_AnioContractual.IdAnioContractual
                    LEFT JOIN
                        CO_TipoCambioDiario (NOLOCK)
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
					LEFT JOIN
                        CO_TipoCambioDiario (NOLOCK) otraMoneda
                            ON PC.FechaPago = otraMoneda.Fecha
                               AND PC.IdMoneda = otraMoneda.IdMoneda 
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
                    PC.IdMoneda,
                    PC.FechaPago,
                    CO_TipoCambioDiario.TipoCambio,
                    CO_AnioContractual.anio,
                    P.CIEP,
                    CO_Rubro.NombreRubro,
                    CO_TareaPetrolera.TareaPetrolera,
					otraMoneda.TipoCambio
                --EPT ligado al Complemento de Pago de la factura PPD principal relacionado al gasto
                UNION
                --
                SELECT
                    @IDSIPAC													AS [RF_00],
                    @IDRegFiducidiario											AS [RI_00],
					@NumeroContrato												AS [RC11_01],
                    EPT.IdDocFacturacionSIPAC									AS [RF01_01],
                    ISNULL(F.UUID, 'NA')										AS [RC28_01],
                    REPLACE(CONCAT(F.IdDocFacturacionSIPAC, '.xml'), '-', '_')	AS [RC28_02],
                    MONTH(R.MesPresentacion)									AS [RC28_03],
                    YEAR(R.MesPresentacion)										AS [RC28_04],
                    2															AS [RC28_05],
                    CASE
                        WHEN @IdTipoContrato = 1
                            THEN ISNULL(CO_ActividadCIEP.NombreActividad, '')
                        ELSE
                            ISNULL(CO_SubactividadPetrolera.SubactividadPetrolera, '')
                    END                                                        AS [RC28_07], --Concepto de operación SUBACTIVIDAD
                    SUM(
						CASE
							WHEN FDR.IdMoneda = 1 -- Pesos (MXN)
								THEN CAST(R.MontoRegistro / CO_TipoCambioDiario.TipoCambio AS DECIMAL(20, 2)) -- Pesos a USD
							WHEN FDR.IdMoneda = 2 -- Dolar Americano (USD)
								THEN CAST(R.MontoRegistro AS DECIMAL(20, 2)) -- Ya esta en dolares
							ELSE
								CAST(R.MontoRegistro * otraMoneda.TipoCambio AS DECIMAL(20, 2)) -- Otras monedas a USD
						END
					)														   AS RC28_08,    --Importe en factura (CFDI o Invoice),USD
                    CO_TipoCambioDiario.TipoCambio                             AS RC28_09,   --Tipo de cambio (pesos por USD)
                    CO_AnioContractual.Anio                                    AS RC28_10,   --Año del Estudio de Precios de Transferencia
                    CASE
                        WHEN P.CIEP = @EsCiep
                            THEN ISNULL(CO_Rubro.NombreRubro, '')
                        ELSE
                            ISNULL(CO_TareaPetrolera.TareaPetrolera, '')
                    END                                                        AS RC28_11,   --" Tipo de operación conforme al Estudio de Precios de Transferencia"
                    SUM(
						CASE
							WHEN FDR.IdMoneda = 1 -- Pesos (MXN)
								THEN CAST(R.MontoRegistro AS DECIMAL(20, 2)) -- Ya esta en pesos
							WHEN FDR.IdMoneda = 2 -- Dolar Americano (USD)
								THEN CAST(R.MontoRegistro * ISNULL(CO_TipoCambioDiario.TipoCambio, 1) AS DECIMAL(20, 2)) -- USD a Pesos
							ELSE
								CAST(R.MontoRegistro * ISNULL(otraMoneda.TipoCambio, 1) * ISNULL(CO_TipoCambioDiario.TipoCambio, 1) AS DECIMAL(20, 2)) -- Otras monedas a Pesos (MontoRegistro * TipoCambioMoneda * TipoCambioPesos)
						END
					)														   AS RC28_12,   -- Monto en pesos Colocar el importe en pesos (MXN) de la operacion analizada en el Estudio de Precios de Transferencia
                    ''                                                         AS RC28_13    -- Metodología utilizada
                FROM
                    dbo.FI_EstudioPreciosTransfer  EPT (NOLOCK)
                    JOIN
                        dbo.FI_Factura             F (NOLOCK)
                            ON  EPT.IdEstudioPrecioTransfer	=	F.IdEstudioPrecioTransfer
							AND  EPT.IdContrato = @Contrato
							 AND EPT.FechaCargaSIPAC = @Mes
                    JOIN
                        dbo.FI_ComplementoDePago   CP (NOLOCK)
                            ON CP.IdFactura = F.IdFactura
                    JOIN
                        dbo.FI_CPDocRelacionado    DR (NOLOCK)
                            ON CP.IdComplementoDePago = DR.IdComplementoDePago
                    JOIN
                        dbo.FI_Factura             FDR (NOLOCK)
                            ON FDR.UUID = DR.IdDocumento
                   
                    JOIN
                        dbo.CO_Registro            R (NOLOCK)
                            ON R.IdFactura = FDR.IdFactura
                               AND R.IdEstado = @EstadoAprobado
                               AND R.CvTipoDocFacturacion = @CvTipoDocFacturacionFactura
                    JOIN
                        dbo.CO_LineaPresupuestoMes L (NOLOCK)
                            ON L.IdLineaPresupuestoMes = R.IdPrograma
                    JOIN
                        dbo.CO_Presupuesto         P (NOLOCK)
                            ON P.IdPresupuesto = L.IdPresupuesto
                    JOIN
                        dbo.FI_TransferFactura     TF (NOLOCK)
                            ON TF.IdFactura = F.IdFactura
                    JOIN
                        dbo.FI_Transfer            T (NOLOCK)
                            ON T.IdTransferencia = TF.IdTransfer
                               AND F.IdContrato = T.IdContrato
                               AND F.IdDocFacturacionSIPAC IS NOT NULL
                    JOIN
                        CO_AnioContractual (NOLOCK)
                            ON P.IdAnioContractual = CO_AnioContractual.IdAnioContractual
                    LEFT JOIN
                        CO_TipoCambioDiario	(NOLOCK)
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
					LEFT JOIN
                        CO_TipoCambioDiario (NOLOCK) otraMoneda
                            ON convert(Date, FDR.FechaTimbrado) = otraMoneda.Fecha
                               AND FDR.IdMoneda = otraMoneda.IdMoneda
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
                    CO_TareaPetrolera.TareaPetrolera,
					otraMoneda.TipoCambio
            ) AS ResultUnion
        ORDER BY
            ResultUnion.RC28_03;
    END;