IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SIPAC_RC_CONT_28_A'
    )
    DROP PROCEDURE SIPAC_RC_CONT_28_A;
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

		CREATE TABLE #TempResultado(
			Identificador INT PRIMARY KEY IDENTITY(1,1),
			RF_00 VARCHAR(500),
            RI_00  VARCHAR(500),
            RC11_01  VARCHAR(500),
            RF01_01 VARCHAR(500),
            RC28_01 VARCHAR(500),
            RC28_02 VARCHAR(500),
            RC28_03 INT,
            RC28_04 INT,
            RC28_05 INT,
            RC28_07 VARCHAR(5000),
            RC28_08  DECIMAL(20, 2),
            RC28_09 DECIMAL,
            RC28_10 INT,
            RC28_11 VARCHAR(5000) ,
            RC28_12 DECIMAL(20, 2),
            RC28_13 VARCHAR(500),
			IdPresupuesto INT);

			CREATE TABLE #TempConsecutivos(
			Identificador INT ,
			Consecutivo INT )

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


INSERT INTO #TempResultado (
    RF_00,
    RI_00,
    RC11_01,
    RF01_01,
    RC28_01,
    RC28_02,
    RC28_03,
    RC28_04,
    RC28_05,
    RC28_07,
    RC28_08,
    RC28_09,
    RC28_10,
    RC28_11,
    RC28_12,
    RC28_13,
	IdPresupuesto
)
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
							WHEN F.IdMoneda = @Peso THEN CAST(R.MontoRegistro / CO_TipoCambioDiario.TipoCambio AS DECIMAL(20, 2)) -- Peso
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
                    ''                                                         AS RC28_13, --Metodología utilizada
					P.IdPresupuesto
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
					-- Validar existencia en FI_TransferFactura
					AND EXISTS (
						SELECT 1
						FROM dbo.FI_TransferFactura TF (NOLOCK)
						WHERE F.IdFactura = TF.IdFactura
					)
					-- Validar existencia en FI_Transfer
					AND EXISTS (
						SELECT 1
						FROM dbo.FI_Transfer T (NOLOCK)
						WHERE T.IdTransferencia = (
							SELECT TOP 1 TF2.IdTransfer
							FROM dbo.FI_TransferFactura TF2 (NOLOCK)
							WHERE TF2.IdFactura = F.IdFactura
						)
						  AND T.IdContrato = F.IdContrato
						  AND F.IdDocFacturacionSIPAC IS NOT NULL
					)
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
					otraMoneda.TipoCambio,
					P.IdPresupuesto
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
							WHEN PC.IdMoneda = @Peso THEN CAST(R.MontoRegistro / CO_TipoCambioDiario.TipoCambio AS DECIMAL(20, 2)) -- Peso
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
                    ''                                AS RC28_13,    --Metodología utilizada
					P.IdPresupuesto
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
					-- Validar la existencia en FI_TransferFactura
					AND EXISTS (
						SELECT 1
						FROM dbo.FI_TransferFactura TF (NOLOCK)
						WHERE PC.IdPedimentoComprobante = TF.IdPedimentoComprobante
					)
					-- Validar la existencia en FI_Transfer
					AND EXISTS (
						SELECT 1
						FROM dbo.FI_Transfer T (NOLOCK)
						WHERE T.IdTransferencia = (
							SELECT TOP 1 TF2.IdTransfer
							FROM dbo.FI_TransferFactura TF2 (NOLOCK)
							WHERE TF2.IdPedimentoComprobante = PC.IdPedimentoComprobante
						)
						  AND T.IdContrato = PC.IdContrato
						  AND PC.IdDocFacturacionSIPAC IS NOT NULL
					)
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
					otraMoneda.TipoCambio,
					P.IdPresupuesto
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
                    CO_AnioContractual.Anio                    AS RC28_10,   --Año del Estudio de Precios de Transferencia
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
                    ''                                                         AS RC28_13 ,   -- Metodología utilizada
					P.IdPresupuesto
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
					-- Validar existencia en FI_TransferFactura
					AND EXISTS (
						SELECT 1
						FROM dbo.FI_TransferFactura TF (NOLOCK)
						WHERE TF.IdFactura = F.IdFactura
					)
					-- Validar existencia en FI_Transfer
					AND EXISTS (
						SELECT 1
						FROM dbo.FI_Transfer T (NOLOCK)
						WHERE T.IdTransferencia = (
							SELECT TOP 1 TF2.IdTransfer
							FROM dbo.FI_TransferFactura TF2 (NOLOCK)
							WHERE TF2.IdFactura = F.IdFactura
						)
						  AND T.IdContrato = F.IdContrato
						  AND F.IdDocFacturacionSIPAC IS NOT NULL
					)
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
					otraMoneda.TipoCambio,
					P.IdPresupuesto;
INSERT INTO 
#TempConsecutivos(
			Identificador  ,
			Consecutivo  )
    SELECT 
        Identificador,
        ROW_NUMBER() OVER (
            PARTITION BY RC28_07, RC28_02, RC28_04, RC28_05,RC28_10, IdPresupuesto
            ORDER BY (SELECT NULL)
        ) AS Consecutivo
    FROM #TempResultado;

UPDATE t
SET RC28_07 = CONCAT(RC28_07,' ',  c.Consecutivo)
FROM #TempResultado t
JOIN #TempConsecutivos c ON t.Identificador = c.Identificador
WHERE  c.Consecutivo > 1; 
	
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
        FROM #TempResultado AS ResultUnion
        ORDER BY
            ResultUnion.RC28_03;
    END;

