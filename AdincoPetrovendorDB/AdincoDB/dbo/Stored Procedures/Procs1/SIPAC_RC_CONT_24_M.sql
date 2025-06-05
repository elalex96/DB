IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SIPAC_RC_CONT_24_M'
    )
    DROP PROCEDURE SIPAC_RC_CONT_24_M;
GO
-- =============================================    
-- Author:                            Yazmin Glez    
-- Create date:  2017-11-29    
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
-- Modificado:       Neri del Angel  
-- Fecha Modificado: 16 de Febrero del 2023  
-- Description:      Se agrega la opción obtener el nuevo campo IDSIPAC desde la tabla CO_Contrato, si este viene vacío o nulo se obtendrá desde la tabla que ya se obtenía anteriormente CO_Contratista  
-- ============================================= 
-- Modificado:       Neri del Angel  
-- Fecha Modificado: 13 de Abril del 2023  
-- Description:      Se agregan case cuando el tipocambio de la tabla CO_TipoCambioDiario es 0 o nulo y 
--					 se agrega si este mismo valor es nulo se muestre como 0 para identificar en el reporte que el tipo cambio no se encuentra agregado
-- ============================================= 
-- Modificado:       Neri del Angel  
-- Fecha Modificado: 18 de Abril del 2023  
-- Description:     Se ajusta para que no se multiplique el número de gastos por el número de transferencias
--					Se ajusta para que si se generan n transferencias con distintos métodos de pago se tome en cuenta solo el del mayor monto para no mostrar 2 registros con diferente método de pago
--					Para la columna [RC24_06] se ajusta para que obtenga el monto sumado del gasto de la tabla CO_Registro.MontoRegistro en dólares
--					Para las columnas [RC24_18] y [RC24_19] se ajusta para que se ajusta la obtención del monto de FI_PedimentoComprobanteDetalle.ImporteTotal por FI_PedimentoComprobanteDetalle.PrecioUnitario
--					Para la columna [RC24_07] se ajusta para que obtenga el monto del pago de la tabla FI_TransferFactura.MontoPagado en dólares
-- ============================================= 
CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_24_M]
    @Contrato INT,
    @Mes DATE,
    @IdPresupuesto INT = 0,
    @Plantilla VARCHAR(150) = ''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Aprobado INT = 10004,
            @TipoPedimentoImportacion INT = 2,
            @PESO INT = 1,
            @DOLAR INT = 2

	 CREATE TABLE #PedimentosRelacionados
    (       
		Id_24_M INT,
		IdPedimento INT,
		IdRelacionado INT,
         [RI_00]   VARCHAR(100),  
		 [RC21_00] VARCHAR(100),  
		 [RC21_12] VARCHAR(100),
		 [RI_00_Relacionado]   VARCHAR(100),  
		 [RC21_00_Relacionado] VARCHAR(100),  
		 [RC21_12_Relacionado] VARCHAR(100)
    );

    CREATE TABLE #TEMPORAL_24_M_SP
    (
        Id_24_M INT IDENTITY(11, 1),
		IdPedimento INT,
        IdContratista_RF_00 VARCHAR(2000),
        IdContrato_RI_00 VARCHAR(2000),
        NumeroContrato_RF01_01 VARCHAR(2000),
        MesReporte_RC24_00 INT,
        AnioReporte_RC24_01 INT,
        NomArchivo_PDF_RC24_02 VARCHAR(2000),
        TimbreHASH_PDF_RC24_03 VARCHAR(2000),
        IDPedimentoImportacion_RC24_04 VARCHAR(2000),
        AcuseElecValidacion_RC24_05 VARCHAR(2000),
        ValorDolares_RC24_06 MONEY NULL,
        PrecioPagado_ValorComercial_RC24_07 MONEY,
        ClavePedimento_RC24_08 VARCHAR(2000),
        FormaPago_RC24_09 VARCHAR(2000),
        FechaOriginal_RC24_10 DATE,
        Regimen_RC24_11 VARCHAR(2000),
        RFC_Importador_RC24_12 VARCHAR(13),
        AduanaES_RC24_13 VARCHAR(2000),
        IdFiscal_RC24_14 VARCHAR(30),
        RazonSocialProv_RC24_15 VARCHAR(2000),
        NumFactura_RC24_16 VARCHAR(2000),
        FechaFactura_RC24_17 DATE,
        ValMontFact_RC24_18 MONEY,
        ValDolares_RC24_19 MONEY NULL,
        ClasDocSoporte_RC24_20 INT,
		IdRelacionado INT,
		RC24_21	VARCHAR(2000),
		RC24_22 VARCHAR(2000),
        IdPedimentoComprobante INT,
        ConTransferencia BIT,
        IdMoneda INT,
		Nota VARCHAR(2000)
    );

    CREATE TABLE #TransferenciasMaximas
    (
        IdPedimentoComprobante INT,
        IdTransferencia INT,
        MontoMaximo MONEY,
        FormaPago VARCHAR(2000),
        FechaPago DATE,
        RN INT,
        MontoPagado MONEY
    )

    CREATE TABLE #TransferenciasMaximasSumas
    (
        IdPedimentoComprobante INT,
        SumaMontoPagado MONEY
    )

    INSERT INTO #TEMPORAL_24_M_SP
    (
		IdPedimento,
        IdContratista_RF_00,
        IdContrato_RI_00,
        NumeroContrato_RF01_01,
        MesReporte_RC24_00,
        AnioReporte_RC24_01,
        NomArchivo_PDF_RC24_02,
        TimbreHASH_PDF_RC24_03,
        IDPedimentoImportacion_RC24_04,
        AcuseElecValidacion_RC24_05,
        ValorDolares_RC24_06,
        ClavePedimento_RC24_08,
        Regimen_RC24_11,
        RFC_Importador_RC24_12,
        AduanaES_RC24_13,
        IdFiscal_RC24_14,
        RazonSocialProv_RC24_15,
        NumFactura_RC24_16,
        FechaFactura_RC24_17,
        ValMontFact_RC24_18,
        ValDolares_RC24_19,
        ClasDocSoporte_RC24_20,
		IdRelacionado,
		RC24_21,
		RC24_22,
        IdPedimentoComprobante,
        ConTransferencia,
        IdMoneda, 
		Nota
    )
    SELECT FI_PedimentoComprobante.IdPedimentoComprobante,
			CASE
               WHEN ISNULL(CO_Contrato.IDSIPAC, '') <> '' THEN
                   LTRIM(RTRIM(CO_Contrato.IDSIPAC))
               ELSE
                   LTRIM(RTRIM(CO_Contratista.IDSIPAC))
           END AS [RF_00],
           LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario)) AS [RI_00],
           CO_Contrato.NumeroContrato AS [RF01_01],
           MONTH(CO_Registro.MesPresentacion) AS [RC24_00],
           YEAR(CO_Registro.MesPresentacion) AS [RC24_01],
           CONCAT(REPLACE(FI_PedimentoComprobante.IdDocFacturacionSIPAC, '-', '_'), '.pdf') AS [RC24_02],
           FI_PedimentoComprobante.HashSHA256 AS [RC24_03],
           LTRIM(RTRIM(SUBSTRING(FI_PedimentoComprobante.NumeroPedimento, 0, 20))) AS [RC24_04],
           LTRIM(RTRIM(SUBSTRING(FI_PedimentoComprobante.AcuseElectronico, 0, 12))) AS [RC24_05],
           SUM(ISNULL(CO_Registro.MontoRegistro, 0)) AS [RC24_06],
           LTRIM(RTRIM(SUBSTRING(FI_ClavesPedimento.Clave, 0, 16))) AS [RC24_08],
           FI_PedimentoComprobante.Regimen AS [RC24_11],
           LTRIM(RTRIM(SUBSTRING(PV_Subcontratista.RFC, 0, 13))) AS [RC24_12],
           FI_PedimentoComprobante.AduanaES AS [RC24_13],
           LTRIM(RTRIM(SUBE.RFC)) AS [RC24_14],
           LTRIM(RTRIM(SUBE.RazonSocial)) AS [RC24_15],
           LTRIM(RTRIM(FI_PedimentoComprobante.FolioComprobante)) AS [RC24_16],
           FI_PedimentoComprobante.FechaPago AS [RC24_17],
           ISNULL(FI_PedimentoComprobanteDetalle.PrecioUnitario, 0) AS [RC24_18],
           ISNULL(FI_PedimentoComprobanteDetalle.PrecioUnitario, 0) AS [RC24_19],
           2 AS [RC24_20],
		   RelacionadosNota.IdPedimentoComprobante AS IdRelacionado,
		   CASE WHEN ISNULL(FI_PedimentoComprobante.EsNotaCredito, 0) = 0 THEN 'NA' ELSE 
		   ISNULL(RelacionadosNota.NumeroPedimento, '')
		   END AS RC24_21,
		   CASE WHEN ISNULL(FI_PedimentoComprobante.EsNotaCredito, 0) = 0 THEN 'NA' ELSE
		   ISNULL(RelacionadosNota.HashSHA256, '')
		   END AS RC24_22,
           CO_Registro.IdPedimentoComprobante,
           0,
           PV_TipoMoneda.IdMoneda,
		   ''
    FROM dbo.CO_Registro WITH (NOLOCK)
        JOIN dbo.FI_PedimentoComprobante WITH (NOLOCK)
            ON CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
               AND CO_Registro.CvTipoDocFacturacion = @TipoPedimentoImportacion
               AND CO_Registro.IdEstado = @Aprobado
        JOIN dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
            ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
        JOIN dbo.CO_Presupuesto WITH (NOLOCK)
            ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
        JOIN dbo.CO_AnioContractual WITH (NOLOCK)
            ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual
        JOIN dbo.CO_Contrato WITH (NOLOCK)
            ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
               AND CO_Contrato.IdContrato = @Contrato
        JOIN dbo.CO_Contratista WITH (NOLOCK)
            ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
        JOIN dbo.FI_PedimentoComprobanteDetalle WITH (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante
        JOIN dbo.PV_Subcontratista WITH (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaImportador = PV_Subcontratista.IdSubcontratista
        JOIN dbo.PV_TipoMoneda WITH (NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
        JOIN dbo.PV_Subcontratista SUBE WITH (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaExportador = SUBE.IdSubcontratista
        JOIN dbo.FI_ClavesPedimento WITH (NOLOCK)
            ON FI_PedimentoComprobante.ClavePedimento = FI_ClavesPedimento.IdPedimento
        JOIN dbo.CO_Servicio WITH (NOLOCK)
            ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
		LEFT JOIN FI_NotaCredito_REL_Comprobantes WITH (NOLOCK) ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_NotaCredito_REL_Comprobantes.IdNotaCredito
		LEFT JOIN FI_PedimentoComprobante RelacionadosNota WITH (NOLOCK) ON FI_NotaCredito_REL_Comprobantes.IdComprobanteRelacionado = RelacionadosNota.IdPedimentoComprobante
    WHERE CO_Registro.CvTipoDocFacturacion = @TipoPedimentoImportacion
          AND CO_Contrato.IdContrato = @Contrato
          AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes
          AND CO_Registro.IdEstado = @Aprobado
          AND ISNULL(CONVERT(INT, FI_PedimentoComprobante.ProcesadoSIPAC), 0) = 0
          AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
          AND CO_Presupuesto.IdPresupuesto = CASE
                                                 WHEN @IdPresupuesto = 0 THEN
                                                     CO_LineaPresupuestoMes.IdPresupuesto
                                                 ELSE
                                                     @IdPresupuesto
                                             END
    GROUP BY CASE
                 WHEN ISNULL(CO_Contrato.IDSIPAC, '') <> '' THEN
                     LTRIM(RTRIM(CO_Contrato.IDSIPAC))
                 ELSE
                     LTRIM(RTRIM(CO_Contratista.IDSIPAC))
             END,
             LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario)),
             CO_Contrato.NumeroContrato,
             MONTH(CO_Registro.MesPresentacion),
             YEAR(CO_Registro.MesPresentacion),
             CONCAT(REPLACE(FI_PedimentoComprobante.IdDocFacturacionSIPAC, '-', '_'), '.pdf'),
             FI_PedimentoComprobante.HashSHA256,
             LTRIM(RTRIM(SUBSTRING(FI_PedimentoComprobante.NumeroPedimento, 0, 20))),
             LTRIM(RTRIM(SUBSTRING(FI_PedimentoComprobante.AcuseElectronico, 0, 12))),
             LTRIM(RTRIM(SUBSTRING(FI_ClavesPedimento.Clave, 0, 16))),
             FI_PedimentoComprobante.Regimen,
             LTRIM(RTRIM(SUBSTRING(PV_Subcontratista.RFC, 0, 13))),
             FI_PedimentoComprobante.AduanaES,
             LTRIM(RTRIM(SUBE.RFC)),
             LTRIM(RTRIM(SUBE.RazonSocial)),
             LTRIM(RTRIM(FI_PedimentoComprobante.FolioComprobante)),
             FI_PedimentoComprobante.FechaPago,
             ISNULL(FI_PedimentoComprobanteDetalle.PrecioUnitario, 0),
             CO_Registro.IdPedimentoComprobante,
             PV_TipoMoneda.IdMoneda,
			 FI_PedimentoComprobante.EsNotaCredito,
			 RelacionadosNota.IdPedimentoComprobante,
			 RelacionadosNota.NumeroPedimento,
			 RelacionadosNota.HashSHA256,
			 FI_PedimentoComprobante.IdPedimentoComprobante;

	UPDATE #TEMPORAL_24_M_SP
	SET Nota = '| Número de pedimento asociado (Columna RC24_21) debe ser una cadena alfanumérica de entre 12 y 20 caracteres o NA, y es requerido. '
	WHERE RC24_21 = '' 

	UPDATE #TEMPORAL_24_M_SP
	SET Nota = Nota + '| Timbre Hash asociado (Columna RC24_22) debe ser una cadena alfanumérica de máximo 256 caracteres o NA, y es requerido.'
	WHERE RC24_22 = '' 

    INSERT INTO #TransferenciasMaximas
    (
        IdPedimentoComprobante,
        IdTransferencia,
        MontoMaximo,
        FormaPago,
        FechaPago,
        RN,
        MontoPagado
    )
    SELECT FI_TransferFactura.IdPedimentoComprobante,
           FI_TransferFactura.IdTransfer,
           FI_TransferFactura.MontoPagado,
           ISNULL(PV_MetodoPago.C_FormaPago, ''),
           FI_Transfer.FechaPago,
           ROW_NUMBER() OVER (PARTITION BY FI_TransferFactura.IdPedimentoComprobante
                              ORDER BY FI_TransferFactura.MontoPagado DESC
                             ) AS RN,
           CAST((SUM(   CASE
                            WHEN FI_Transfer.IdMoneda = @DOLAR THEN
                                FI_TransferFactura.MontoPagado
                            WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0 THEN
                                0
                            WHEN FI_Transfer.IdMoneda = @PESO THEN
                                FI_TransferFactura.MontoPagado / CO_TipoCambioDiario.TipoCambio
                            WHEN FI_Transfer.IdMoneda NOT IN ( @PESO, @DOLAR ) THEN
                                FI_TransferFactura.MontoPagado / CO_TipoCambioDiario.TipoCambio
                        END
                    )
                ) AS DECIMAL(15, 2))
    FROM #TEMPORAL_24_M_SP
        JOIN FI_TransferFactura WITH (NOLOCK)
            ON #TEMPORAL_24_M_SP.IdPedimentoComprobante = FI_TransferFactura.IdPedimentoComprobante 
        JOIN FI_Transfer WITH (NOLOCK)
            ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
        JOIN dbo.PV_MetodoPago WITH (NOLOCK)
            ON FI_Transfer.IdMetodoPago = PV_MetodoPago.idMetodoPago
        LEFT JOIN dbo.CO_TipoCambioDiario WITH (NOLOCK)
            ON CO_TipoCambioDiario.IdMoneda = FI_Transfer.IdMoneda
               AND DAY(FI_Transfer.FechaPago) = DAY(CO_TipoCambioDiario.Fecha)
               AND MONTH(FI_Transfer.FechaPago) = MONTH(CO_TipoCambioDiario.Fecha)
               AND YEAR(FI_Transfer.FechaPago) = YEAR(CO_TipoCambioDiario.Fecha)
    GROUP BY FI_TransferFactura.IdPedimentoComprobante,
             FI_TransferFactura.IdTransfer,
             FI_TransferFactura.MontoPagado,
             ISNULL(PV_MetodoPago.C_FormaPago, ''),
             FI_Transfer.FechaPago

    INSERT INTO #TransferenciasMaximasSumas
    (
        IdPedimentoComprobante,
        SumaMontoPagado
    )
    SELECT IdPedimentoComprobante,
           SUM(MontoPagado)
    FROM #TransferenciasMaximas
    GROUP BY IdPedimentoComprobante

    UPDATE #TEMPORAL_24_M_SP
    SET #TEMPORAL_24_M_SP.FormaPago_RC24_09 = #TransferenciasMaximas.FormaPago,
        #TEMPORAL_24_M_SP.FechaOriginal_RC24_10 = #TransferenciasMaximas.FechaPago,
        #TEMPORAL_24_M_SP.ConTransferencia = 1
    FROM #TEMPORAL_24_M_SP
        JOIN #TransferenciasMaximas
            ON #TEMPORAL_24_M_SP.IdPedimentoComprobante = #TransferenciasMaximas.IdPedimentoComprobante
               AND #TransferenciasMaximas.RN = 1

    UPDATE #TEMPORAL_24_M_SP
    SET #TEMPORAL_24_M_SP.ValorDolares_RC24_06 = CASE
                                                     WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0 THEN
                                                         0
                                                     WHEN ISNULL(#TEMPORAL_24_M_SP.ValorDolares_RC24_06, 0) <> 0 THEN
                                                         CAST(ROUND(
                                                                       (ISNULL(
                                                                                  #TEMPORAL_24_M_SP.ValorDolares_RC24_06,
                                                                                  0
                                                                              ) / CO_TipoCambioDiario.TipoCambio
                                                                       ),
                                                                       2
                                                                   ) AS DECIMAL(15, 2))
                                                     ELSE
                                                         0
                                                 END,
        #TEMPORAL_24_M_SP.ValDolares_RC24_19 = CASE
                                                   WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0 THEN
                                                       0
                                                   WHEN ISNULL(#TEMPORAL_24_M_SP.ValDolares_RC24_19, 0) <> 0 THEN
                                                       CAST(ROUND(
                                                                     (ISNULL(#TEMPORAL_24_M_SP.ValDolares_RC24_19, 0)
                                                                      / CO_TipoCambioDiario.TipoCambio
                                                                     ),
              2
                                                                 ) AS DECIMAL(15, 2))
                                                   ELSE
                                                       0
                                               END
    FROM #TEMPORAL_24_M_SP
        LEFT JOIN dbo.CO_TipoCambioDiario WITH (NOLOCK)
            ON #TEMPORAL_24_M_SP.ConTransferencia = 1
               AND #TEMPORAL_24_M_SP.IdMoneda = CO_TipoCambioDiario.IdMoneda
               AND DAY(#TEMPORAL_24_M_SP.FechaOriginal_RC24_10) = DAY(CO_TipoCambioDiario.Fecha)
               AND MONTH(#TEMPORAL_24_M_SP.FechaOriginal_RC24_10) = MONTH(CO_TipoCambioDiario.Fecha)
               AND YEAR(#TEMPORAL_24_M_SP.FechaOriginal_RC24_10) = YEAR(CO_TipoCambioDiario.Fecha)

    UPDATE #TEMPORAL_24_M_SP
    SET #TEMPORAL_24_M_SP.PrecioPagado_ValorComercial_RC24_07 = #TransferenciasMaximasSumas.SumaMontoPagado
    FROM #TEMPORAL_24_M_SP
        JOIN #TransferenciasMaximasSumas
            ON #TEMPORAL_24_M_SP.IdPedimentoComprobante = #TransferenciasMaximasSumas.IdPedimentoComprobante


	INSERT INTO #PedimentosRelacionados (
			Id_24_M,
			IdPedimento,
			IdRelacionado
			,[RI_00]
			,[RC21_00]
			,[RC21_12]
				)
		SELECT #TEMPORAL_24_M_SP.Id_24_M,
		FI_PedimentoComprobante.IdPedimentoComprobante,
		#TEMPORAL_24_M_SP.IdRelacionado
			,LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario))
			,CASE 
				WHEN len(CO_Presupuesto.IdPresupuestoCNH) > 10
					THEN SUBSTRING(CO_Presupuesto.IdPresupuestoCNH, 22, 10)
				ELSE CO_Presupuesto.IdPresupuestoCNH
				END
			,LTRIM(RTRIM(TP.id_Tarea))
		FROM #TEMPORAL_24_M_SP
		JOIN dbo.FI_PedimentoComprobante WITH (NOLOCK)
			ON #TEMPORAL_24_M_SP.IdPedimento = FI_PedimentoComprobante.IdPedimentoComprobante
		JOIN dbo.CO_Registro WITH (NOLOCK)
			ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
				AND CO_Registro.CvTipoDocFacturacion = @TipoPedimentoImportacion
				AND CO_Registro.IdEstado = @Aprobado
		JOIN dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
			ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
		JOIN dbo.CO_Presupuesto WITH (NOLOCK)
			ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
		JOIN dbo.CO_AnioContractual WITH (NOLOCK)
			ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual
		JOIN dbo.CO_Contrato WITH (NOLOCK)
			ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
				AND CO_Contrato.IdContrato = @Contrato
		JOIN dbo.CO_TareaPetrolera TP WITH (NOLOCK)
			ON CO_LineaPresupuestoMes.IdTareaPetrolera = TP.IdTareaPetrolera
		GROUP BY #TEMPORAL_24_M_SP.Id_24_M,FI_PedimentoComprobante.IdPedimentoComprobante, #TEMPORAL_24_M_SP.IdRelacionado
			,LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario))
			,CASE 
				WHEN len(CO_Presupuesto.IdPresupuestoCNH) > 10
					THEN SUBSTRING(CO_Presupuesto.IdPresupuestoCNH, 22, 10)
				ELSE CO_Presupuesto.IdPresupuestoCNH
				END
			,LTRIM(RTRIM(TP.id_Tarea))

			UPDATE #PedimentosRelacionados

			SET 
			[RI_00_Relacionado] = LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario))
			,[RC21_00_Relacionado] = CASE 
				WHEN len(CO_Presupuesto.IdPresupuestoCNH) > 10
					THEN SUBSTRING(CO_Presupuesto.IdPresupuestoCNH, 22, 10)
				ELSE CO_Presupuesto.IdPresupuestoCNH
				END
			,[RC21_12_Relacionado] = LTRIM(RTRIM(TP.id_Tarea))			
		FROM #PedimentosRelacionados		
		JOIN FI_PedimentoComprobante
			ON #PedimentosRelacionados.IdRelacionado = FI_PedimentoComprobante.IdPedimentoComprobante
		JOIN dbo.CO_Registro WITH (NOLOCK)
			ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
				AND CO_Registro.CvTipoDocFacturacion = @TipoPedimentoImportacion
				AND CO_Registro.IdEstado = @Aprobado
		JOIN dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
			ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
		JOIN dbo.CO_Presupuesto WITH (NOLOCK)
			ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
		JOIN dbo.CO_AnioContractual WITH (NOLOCK)
			ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual
		JOIN dbo.CO_Contrato WITH (NOLOCK)
			ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
				AND CO_Contrato.IdContrato = @Contrato
		JOIN dbo.CO_TareaPetrolera TP WITH (NOLOCK)
			ON CO_LineaPresupuestoMes.IdTareaPetrolera = TP.IdTareaPetrolera


		UPDATE #TEMPORAL_24_M_SP
		SET #TEMPORAL_24_M_SP.Nota = #TEMPORAL_24_M_SP.Nota + 
			'| Se detectó una discrepancia entre los datos de la nota de crédito ' + 
			'(Contrato: ' + #PedimentosRelacionados.RI_00 +
			', Presupuesto: ' + #PedimentosRelacionados.RC21_00 + 
			', Tarea: ' + #PedimentosRelacionados.RC21_12 + 
			') y los del documento relacionado ' + 
			'(Contrato: ' + #PedimentosRelacionados.RI_00_Relacionado + 
			', Presupuesto: ' + #PedimentosRelacionados.RC21_00_Relacionado + 
			', Tarea: ' + #PedimentosRelacionados.RC21_12_Relacionado + ').'
		FROM #TEMPORAL_24_M_SP
			JOIN #PedimentosRelacionados ON 
			#TEMPORAL_24_M_SP.Id_24_M = #PedimentosRelacionados.Id_24_M WHERE #PedimentosRelacionados.[RI_00] <> #PedimentosRelacionados.[RI_00_Relacionado] OR #PedimentosRelacionados.[RC21_00] <> #PedimentosRelacionados.[RC21_00_Relacionado] OR #PedimentosRelacionados.[RC21_12] <> #PedimentosRelacionados.[RC21_12_Relacionado]

		UPDATE #TEMPORAL_24_M_SP
			SET Nota = SUBSTRING(Nota, 3, LEN(Nota) - 2)
		WHERE LEN(Nota) >= 2;

    SELECT IdContratista_RF_00,
           IdContrato_RI_00,
           NumeroContrato_RF01_01,
           MesReporte_RC24_00,
           AnioReporte_RC24_01,
           NomArchivo_PDF_RC24_02,
           TimbreHASH_PDF_RC24_03,
           IDPedimentoImportacion_RC24_04,
           AcuseElecValidacion_RC24_05,
           ValorDolares_RC24_06,
           PrecioPagado_ValorComercial_RC24_07,
           ClavePedimento_RC24_08,
           FormaPago_RC24_09,
           FechaOriginal_RC24_10,
           Regimen_RC24_11,
           RFC_Importador_RC24_12,
           AduanaES_RC24_13,
           IdFiscal_RC24_14,
           RazonSocialProv_RC24_15,
           NumFactura_RC24_16,
           FechaFactura_RC24_17,
           ValMontFact_RC24_18,
           ValDolares_RC24_19,
           ClasDocSoporte_RC24_20,
		   RC24_21,
		   RC24_22,
		   Nota
    FROM #TEMPORAL_24_M_SP
    WHERE ConTransferencia = 1
END;
