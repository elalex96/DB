CREATE PROCEDURE [dbo].[sp_CalculaMecanismoAjuste] 
-- =============================================
-- Author:		Miguel Gomez
-- Create date:	2017-05-24
-- Description:	CALCULO MECANISMOS DE AJUSTES
-- =============================================
@IdContrato INT,
@Mes        DATETIME
AS
     BEGIN
         SET NOCOUNT ON; 
-- =============================================
--EXEC sp_CalculaMecanismoAjuste 10010,'2017-05-01'

         DECLARE @ValorContracHidro DECIMAL(16, 3), @IngresoAdicional MONEY, @PorcRecuperacion DECIMAL(5, 3), @CostosPrevios MONEY, @CostosElegibles MONEY, @CostosRecuperables MONEY, @LimRecuperacionCto MONEY, @CtoReconocidoRecuperado MONEY, @PrecioContracPetro MONEY, @PrecioContracConden MONEY, @PrecioContracGas MONEY, @ValorContracPetro MONEY, @ValorContracConden MONEY, @ValorContracGas MONEY, @RegaliaPetroleo DECIMAL(5, 3), @RegaliaCondensados DECIMAL(5, 3), @RegaliaGas DECIMAL(5, 3), @MontoRegaliaPetroleo DECIMAL(16, 3), @MontoRegaliaCondensados MONEY, @MontoRegaliaGas MONEY, @MontoTotalRegalias DECIMAL(16, 3), @UtilidadOperativa MONEY, @U1 DECIMAL(5, 3), @U2 DECIMAL(5, 3), @SC1 DECIMAL(5, 3), @SC2 DECIMAL(5, 4), @MontoContraUtilidadOperEdo MONEY, @MontoContraUtilidadOperContratista MONEY, @ValorActivos MONEY, @ResulOperativoContratista MONEY, @IndiceMetrica DECIMAL(5, 4), @MRO DECIMAL(7, 4), @ProduccionPetroleo DECIMAL(16, 3), @ProduccionCondesados DECIMAL(16, 3), @ProduccionGas DECIMAL(16, 3), @PagoRegaliasEdoPetroleo DECIMAL(16, 3), @PagoRegaliasEdoCondensado DECIMAL(16, 3), @PagoRegaliasEdoGas DECIMAL(16, 3), @PagoUtilidadOperEdoPetroleo DECIMAL(16, 3), @PagoUtilidadOperEdoCondensado DECIMAL(16, 3), @PagoUtilidadOperEdoGas DECIMAL(16, 3), @PagoTotalEstadoPetroleo DECIMAL(16, 3), @PagoTotalEstadoCondensado DECIMAL(16, 3), @PagoTotalEstadoGas DECIMAL(16, 3), @PagoCtoElegibleContratistaPetroleo DECIMAL(16, 3), @PagoCtoElegibleContratistaCondensado DECIMAL(16, 3), @PagoCtoElegibleContratistaGas DECIMAL(16, 3), @PagoUtilidadOperContratistaPetroleo DECIMAL(16, 3), @PagoUtilidadOperContratistaCondensado DECIMAL(16, 3), @PagoUtilidadOperContratistaGas DECIMAL(16, 3), @CargoIngresosAdicionalesPetroleo DECIMAL(16, 3), @CargoIngresosAdicionalesCondensado DECIMAL(16, 3), @CargoIngresosAdicionalesGas DECIMAL(16, 3), @PagoTotalContratistaPetroleo DECIMAL(16, 3), @PagoTotalContratistaCondensado DECIMAL(16, 3), @PagoTotalContratistaGas DECIMAL(16, 3), @ComprobacionPetroleo DECIMAL(7, 4), @ComprobacionCondensado DECIMAL(7, 4), @ComprobacionGas DECIMAL(7, 4), @PorcContraUtilidadOperContratista DECIMAL(5, 3), @PorcContraUtilidadOperEdo DECIMAL(5, 3);

-- VALOR CONTRACTUAL DE LOS HIDROCARBUROS

         SELECT @ValorContracHidro = SUM(ISNULL(Valor, 0))
         FROM CP_MetodoCalculoHidrocarburoMes
         WHERE IdContrato = @IdContrato
               AND Mes = @Mes;

-- VALOR Y PRECIO CONTRACTUAL DEL PETROLEO

         SELECT @PrecioContracPetro = Precio,
                @ValorContracPetro = Valor
         FROM CP_MetodoCalculoHidrocarburoMes
         WHERE IdContrato = @IdContrato
               AND Mes = @Mes
               AND IdTipoHidrocarburo = 1;	    -- PETROLEO

-- VALOR Y PRECIO CONTRACTUAL CONDENSADOS

         SELECT @PrecioContracConden = Precio,
                @ValorContracConden = Valor
         FROM CP_MetodoCalculoHidrocarburoMes
         WHERE IdContrato = @IdContrato
               AND Mes = @Mes
               AND IdTipoHidrocarburo = 2;	    -- CONDENSADO

-- VALOR Y PRECIO CONTRACTUAL GAS

         SELECT @PrecioContracGas = SUM(ISNULL(Precio, 0)),
                @ValorContracGas = SUM(ISNULL(Valor, 0))
         FROM CP_MetodoCalculoHidrocarburoMes
         WHERE IdContrato = @IdContrato
               AND Mes = @Mes
               AND IdTipoHidrocarburo IN(3, 4, 5, 6);	-- GAS

-- INGRESOS ADICIONALES, COSTOS

         SELECT @IngresoAdicional = Ingreso,
                @CostosPrevios = CostosPrevios,
                @CostosElegibles = CostosElegibles,
                @CostosRecuperables = CostosRecuperables
         FROM COM_IngresoAdicional
         WHERE IdContrato = @IdContrato
               AND MesReporte = @Mes;

-- %RECUPERACION

         SELECT @PorcRecuperacion = PorcentajeRecuperacion
         FROM CO_CONTRATO
         WHERE IdContrato = @IdContrato;

-- LIMITE DE RECUPERACION DE COSTOS:
-- (VALOR CONTRACTUAL DE LOS HIDROCARBUROS + INGRESOS ADICIONALES) * %RECUPERACION

         SELECT @LimRecuperacionCto = (@ValorContracHidro + @IngresoAdicional) * @PorcRecuperacion;

-- COSTOS RECUPERABLES = COSTOS ELEGIBLES + COSTOS PREVIOS

         SELECT @CostosRecuperables = ISNULL(@CostosRecuperables, 0) + @CostosElegibles + @CostosPrevios;

-- COSTOS RECONOCIDOS COMO RECUPERADOS (CR) : MIN ENTRE COSTOS RECUPERABLES Y LIMITE DE RECUPERACION DE COSTOS
         IF @CostosRecuperables < @LimRecuperacionCto
             BEGIN
                 SELECT @CtoReconocidoRecuperado = @CostosRecuperables;
         END;
             ELSE
             BEGIN
                 SELECT @CtoReconocidoRecuperado = @LimRecuperacionCto;
         END;

-- REGALIAS (TASA) PETROLEO
-- SI PRECIO CONTRACTUAL PETROLEO < 48	:   0.075
-- ELSE : (0.125 * PRECIO CONTRACTUAL PETROLEO + 1.5 ) * 0.01
         IF @PrecioContracPetro < 48
             BEGIN
                 SELECT @RegaliaPetroleo = 0.075;
         END;
             ELSE
             BEGIN
                 SELECT @RegaliaPetroleo = (0.125 * @PrecioContracPetro + 1.5) * 0.01;
         END;

-- REGALIAS (TASA) CONDENSADOS
-- SI PRECIO CONTRACTUAL CONDENSADOS < 60	:   0.05
-- ELSE : ( 0.125 * PRECIO CONTRACTUAL CONDENSADOS - 2.5) * 0.01 )

         SELECT @RegaliaCondensados = CASE
                                          WHEN @PrecioContracConden < 60
                                          THEN 0.05
                                          ELSE(0.125 * @PrecioContracConden - 2.5) * 0.01
                                      END;

-- REGALIAS (TASA) GAS

         SELECT @RegaliaGas = @PrecioContracGas / 100;

-- REGALIAS (MONTO)	PETROLEO: VALOR CONTRACTUAL PETROLEO * REGALIA PETROLEO (TASA)

         SELECT @MontoRegaliaPetroleo = @ValorContracPetro * @RegaliaPetroleo;

-- REGALIAS (MONTO)	CONDENSADOS: VALOR CONTRACTUAL CONDENSADOS * REGALIA CONDENSADOS (TASA)

         SELECT @MontoRegaliaCondensados = @ValorContracConden * @RegaliaCondensados;

-- REGALIAS (MONTO)	GAS: VALOR CONTRACTUAL GAS * REGALIA GAS (TASA)

         SELECT @MontoRegaliaGas = @ValorContracGas * @RegaliaGas;

-- MONTO TOTAL DE REGALIAS

         SELECT @MontoTotalRegalias = ISNULL(@MontoRegaliaPetroleo, 0) + ISNULL(@MontoRegaliaCondensados, 0) + ISNULL(@MontoRegaliaGas, 0);

-- UTILIDAD OPERATIVA = VALOR HIDROCARBUROS + INGRESOS ADICIONALES - COSTOS RECONOCIDOS RECUPERADOS - MONTO TOTAL REGALIAS

         SELECT @UtilidadOperativa = @ValorContracHidro + @IngresoAdicional - @CtoReconocidoRecuperado - @MontoTotalRegalias;

/* VALORES FIJOS QUE MAS ADELANTE SE ALMACENARAN EN LA TABLA DEL CONTRATO */

-- MECANISMO DE AJUSTE	

         SELECT @U1 = .25;
         SELECT @U2 = .40;
         SELECT @SC1 = .295;
         SELECT @SC2 = @SC1 * 0.25;

--Contraprestación como % de utilidad operativa
--Estado = 1- Contratista
-- Contratista (SCA) = SC1

         SELECT @PorcContraUtilidadOperContratista = @SC1;
         SELECT @PorcContraUtilidadOperEdo = 1 - @PorcContraUtilidadOperContratista;

--Contraprestación como % de Utilidad Operativa (Monto)
--Estado = Utilidad Operativa * (% Estado = 1- Contratista)

         SELECT @MontoContraUtilidadOperEdo = @UtilidadOperativa * (1 - @SC1);

--Contraprestación como % de Utilidad Operativa (Monto)
--Contratista = Utilidad Operativa * (% Contratista)

         SELECT @MontoContraUtilidadOperContratista = @UtilidadOperativa * @SC1;

/* VALORES FIJOS QUE MAS ADELANTE SE ALMACENARAN EN LA TABLA DEL CONTRATO */

-- VALOR DE LOS ACTIVOS

         SELECT @ValorActivos = 737756985; 

-- Resultado Operativo Contratista (ROC)
-- CONTRAPESTACION UTILIDAD OPERATIVA CONTRATISTA (MONTO) + COSTOS RECONOCIDOS RECUPERADOS - COSTOS ELEGIBLES - VALOR DE LOS ACTIVOS

         SELECT @ResulOperativoContratista = @MontoContraUtilidadOperContratista + @CtoReconocidoRecuperado - @CostosElegibles - @ValorActivos;

-- CALCULAR TASA INTERNA DE RETORNO
-- ÍNDICE DE MÉTRICA (R)

         SELECT @IndiceMetrica = dbo.ufn_IRR(@ResulOperativoContratista, 0);

-- MÉTRICA DE RESULTADO OPERATIVO (MRO) = (1+ ÍNDICE DE MÉTRICA) ^ 12 - 1

         SELECT @MRO = POWER(1 + @IndiceMetrica, 12) - 1;

-- VOLUMEN PRODUCIDO EN EL PERIODO

         SELECT @ProduccionPetroleo = VolumenPetroleoPuntoMedicion,
                @ProduccionCondesados = VolumenCondensadoPuntoMedicion,
                @ProduccionGas = MetanoC1 + EtanoC2 + PropanoC3 + ButanoC4
         FROM PR_VolumenMensualProduccionPetroleo
         WHERE IdContrato = @IdContrato
               AND MesReporte = @Mes;

-- PAGO DE CONTRAPRESTACIONES AL ESTADO : REGALIAS
-- PETROLEO = MONTO TOTAL REGALIAS / VALOR CONTRACTUAL DE LOS HIDROCARBUROS * PRODUCCION DEL PETROLEO

         SELECT @PagoRegaliasEdoPetroleo = @MontoTotalRegalias / @ValorContracHidro * @ProduccionPetroleo;
-- CONDENSADOS = MONTO TOTAL REGALIAS / VALOR CONTRACTUAL DE LOS HIDROCARBUROS * PRODUCCION DE CONDENSADOS

         SELECT @PagoRegaliasEdoCondensado = @MontoTotalRegalias / @ValorContracHidro * @ProduccionCondesados;
-- GAS = MONTO TOTAL REGALIAS / VALOR CONTRACTUAL DE LOS HIDROCARBUROS * PRODUCCION DE GAS

         SELECT @PagoRegaliasEdoGas = @MontoTotalRegalias / @ValorContracHidro * @ProduccionGas;

-- PAGO DE CONTRAPRESTACIONES AL ESTADO : UTILIDAD OPERATIVA
-- PETROLEO = MONTO CONTRAPRESTACION UTILIDAD OPERATIVA DEL ESTADO / VALOR CONTRACTUAL DE LOS HIDROCARBUROS * PRODUCCION DEL PETROLEO

         SELECT @PagoUtilidadOperEdoPetroleo = @MontoContraUtilidadOperEdo / @ValorContracHidro * @ProduccionPetroleo;
-- CONDENSADOS = MONTO CONTRAPRESTACION UTILIDAD OPERATIVA DEL ESTADO / VALOR CONTRACTUAL DE LOS HIDROCARBUROS * PRODUCCION DE CONDENSADOS

         SELECT @PagoUtilidadOperEdoCondensado = @MontoContraUtilidadOperEdo / @ValorContracHidro * @ProduccionCondesados;
-- GAS = MONTO CONTRAPRESTACION UTILIDAD OPERATIVA DEL ESTADO / VALOR CONTRACTUAL DE LOS HIDROCARBUROS * PRODUCCION DE GAS

         SELECT @PagoUtilidadOperEdoGas = @MontoContraUtilidadOperEdo / @ValorContracHidro * @ProduccionGas;

-- PAGO TOTAL DE CONTRAPRESTACIONES AL ESTADO
-- PETROLEO = PAGO DE REGALIAS AL ESTADO  + PAGO DE UTILIDAD OPERATIVA AL ESTADO

         SELECT @PagoTotalEstadoPetroleo = @PagoRegaliasEdoPetroleo + @PagoUtilidadOperEdoPetroleo;
-- CONDENSADOS = PAGO DE REGALIAS AL ESTADO  + PAGO DE UTILIDAD OPERATIVA AL ESTADO

         SELECT @PagoTotalEstadoCondensado = @PagoRegaliasEdoCondensado + @PagoUtilidadOperEdoCondensado;
-- GAS = PAGO DE REGALIAS AL ESTADO  + PAGO DE UTILIDAD OPERATIVA AL ESTADO

         SELECT @PagoTotalEstadoGas = @PagoRegaliasEdoGas + @PagoUtilidadOperEdoGas;


-- PAGO DE CONTRAPRESTACIONES AL CONTRATISTA
-- RECUPERACIÓN DE COSTOS ELEGIBLES
-- PETRÓLEO = COSTOS RECONOCIDOS COMO RECUPERADOS / VALOR CONTRACTUAL DE LOS HIDROCARBUROS * PRODUCCION PETROLEO

         SELECT @PagoCtoElegibleContratistaPetroleo = @CtoReconocidoRecuperado / @ValorContracHidro * @ProduccionPetroleo;
-- CONDENSADOS = COSTOS RECONOCIDOS COMO RECUPERADOS / VALOR CONTRACTUAL DE LOS HIDROCARBUROS * PRODUCCION CONDENSADOS

         SELECT @PagoCtoElegibleContratistaCondensado = @CtoReconocidoRecuperado / @ValorContracHidro * @ProduccionCondesados;
-- GAS = COSTOS RECONOCIDOS COMO RECUPERADOS / VALOR CONTRACTUAL DE LOS HIDROCARBUROS * PRODUCCION GAS

         SELECT @PagoCtoElegibleContratistaGas = @CtoReconocidoRecuperado / @ValorContracHidro * @ProduccionGas;

-- UTILIDAD OPERATIVA
-- PETROLEO = MONTO CONTRAPRESTACION UTILIDAD OPERATIVA CONTRATISTA / VALOR CONTRACTUAL DE LOS HIDROCARBUROS * PRODUCCION PETROLEO

         SELECT @PagoUtilidadOperContratistaPetroleo = @MontoContraUtilidadOperContratista / @ValorContracHidro * @ProduccionPetroleo;
-- CONDENSADOS = MONTO CONTRAPRESTACION UTILIDAD OPERATIVA CONTRATISTA / VALOR CONTRACTUAL DE LOS HIDROCARBUROS * PRODUCCION PETROLEO

         SELECT @PagoUtilidadOperContratistaCondensado = @MontoContraUtilidadOperContratista / @ValorContracHidro * @ProduccionCondesados;
-- GAS = MONTO CONTRAPRESTACION UTILIDAD OPERATIVA CONTRATISTA / VALOR CONTRACTUAL DE LOS HIDROCARBUROS * PRODUCCION GAS

         SELECT @PagoUtilidadOperContratistaGas = @MontoContraUtilidadOperContratista / @ValorContracHidro * @ProduccionGas;

-- DESCUENTO POR INGRESOS ADICIONALES
-- PETROLEO = SI LOS INGRESOS ADCIONALES SON MAYORES A CERO ENTONCES INGRESOS ADICIONALES / VALOR CONTRACTUAL HIDROCARBUROS * PRODUCCION PETROLEO  EN OTRO CASO 0

         SELECT @CargoIngresosAdicionalesPetroleo = CASE
                                                        WHEN ISNULL(@IngresoAdicional, 0) > 0
                                                        THEN @IngresoAdicional / @ValorContracHidro * @ProduccionPetroleo
                                                        ELSE 0
                                                    END;
-- CONDENSADOS = SI LOS INGRESOS ADCIONALES SON MAYORES A CERO ENTONCES INGRESOS ADICIONALES / VALOR CONTRACTUAL HIDROCARBUROS * PRODUCCION CONDENSADOS  EN OTRO CASO 0

         SELECT @CargoIngresosAdicionalesCondensado = CASE
                                                          WHEN ISNULL(@IngresoAdicional, 0) > 0
                                                          THEN @IngresoAdicional / @ValorContracHidro * @ProduccionCondesados
                                                          ELSE 0
                                                      END;
-- GAS = SI LOS INGRESOS ADCIONALES SON MAYORES A CERO ENTONCES INGRESOS ADICIONALES / VALOR CONTRACTUAL HIDROCARBUROS * PRODUCCION GAS  EN OTRO CASO 0

         SELECT @CargoIngresosAdicionalesGas = CASE
                                                   WHEN ISNULL(@IngresoAdicional, 0) > 0
                                                   THEN @IngresoAdicional / @ValorContracHidro * @ProduccionGas
                                                   ELSE 0
                                               END;

-- -- PAGO TOTAL DE CONTRAPRESTACIONES AL CONTRATISTA
-- PETROLEO = RECUPERACIÓN DE COSTOS ELEGIBLES PETROLEO + UTILIDAD OPERATIVA PETROLEO - INGRESOS ADICIONALES PETROLEO

         SELECT @PagoTotalContratistaPetroleo = @PagoCtoElegibleContratistaPetroleo + @PagoUtilidadOperContratistaPetroleo - @CargoIngresosAdicionalesPetroleo;
-- CONDENSADOS = RECUPERACIÓN DE COSTOS ELEGIBLES CONDENSADOS + UTILIDAD OPERATIVA CONDENSADOS - INGRESOS ADICIONALES CONDENSADOS

         SELECT @PagoTotalContratistaCondensado = @PagoCtoElegibleContratistaCondensado + @PagoUtilidadOperContratistaCondensado - @CargoIngresosAdicionalesCondensado;
-- GAS = RECUPERACIÓN DE COSTOS ELEGIBLES GAS + UTILIDAD OPERATIVA GAS - INGRESOS ADICIONALES GAS

         SELECT @PagoTotalContratistaGas = @PagoCtoElegibleContratistaGas + @PagoUtilidadOperContratistaGas - @CargoIngresosAdicionalesGas;

-- COMPROBACION
-- PETROLEO = PRODUCCION PETROLEO - PAGO TOTAL CONTRAPRESTACIONES AL ESTADO PETROLEO - PAGO TOTAL CONTRAPRESTACIONES AL CONTRATISTA PETROLEO

         SELECT @ComprobacionPetroleo = @ProduccionPetroleo - @PagoTotalEstadoPetroleo - @PagoTotalContratistaPetroleo;
-- CONDENSADOS = PRODUCCION CONDENSADOS - PAGO TOTAL CONTRAPRESTACIONES AL ESTADO CONDENSADOS - PAGO TOTAL CONTRAPRESTACIONES AL CONTRATISTA CONDENSADOS

         SELECT @ComprobacionCondensado = @ProduccionCondesados - @PagoTotalEstadoCondensado - @PagoTotalContratistaCondensado;
-- GAS = PRODUCCION GAS - PAGO TOTAL CONTRAPRESTACIONES AL ESTADO GAS - PAGO TOTAL CONTRAPRESTACIONES AL CONTRATISTA GAS

         SELECT @ComprobacionGas = @ProduccionGas - @PagoTotalEstadoGas - @PagoTotalContratistaGas;

-- Llena Reporte	    

         SELECT @ValorContracHidro AS [ValorContracHidro],
                @IngresoAdicional AS [IngresosAdicionales],
                @LimRecuperacionCto AS [LimRecuperacionCto],
                @CostosPrevios AS [CostosPrevios],
                @CostosElegibles AS [CostosElegibles],
                @CostosRecuperables AS [CostosRecuperables],
                @CtoReconocidoRecuperado AS [ContraprestacionRecuperacionCostos],
                @CtoReconocidoRecuperado AS [CtoReconocidoRecuperado],
                @RegaliaPetroleo AS [RegaliaPetroleo],
                @RegaliaCondensados AS [RegaliaCondensados],
                @RegaliaGas AS [RegaliaGas],
                @MontoRegaliaPetroleo AS [MontoRegaliaPetroleo],
                @MontoRegaliaCondensados AS [MontoRegaliaCondensados],
                @MontoRegaliaGas AS [MontoRegaliaGas],
                @MontoTotalRegalias AS [MontoTotalRegalias],
                @UtilidadOperativa AS [UtilidadOperativa],
                @ValorActivos AS [ValorActivos],
                @MontoContraUtilidadOperEdo AS [MontoContraUtilidadOperEdo],
                @MontoContraUtilidadOperContratista AS [MontoContraUtilidadOperContratista],
                @ResulOperativoContratista AS [ResulOperativoContratista],
                @IndiceMetrica AS [IndiceMetrica],
                @MRO AS [MRO],
                @U1 AS [U1],
                @U2 AS [U2],
                @SC1 AS [SC1],
                @SC2 AS [SC2],
                @PorcContraUtilidadOperEdo AS [PorcContraUtilidadOperEdo],
                @PorcContraUtilidadOperContratista AS [PorcContraUtilidadOperContratista],
                @PagoRegaliasEdoPetroleo AS [PagoRegaliasEdoPetroleo],
                @PagoRegaliasEdoCondensado AS [PagoRegaliasEdoCondensado],
                @PagoRegaliasEdoGas AS [PagoRegaliasEdoGas],
                @PagoUtilidadOperEdoPetroleo AS [PagoUtilidadOperEdoPetroleo],
                @PagoUtilidadOperEdoCondensado AS [PagoUtilidadOperEdoCondensado],
                @PagoUtilidadOperEdoGas AS [PagoUtilidadOperEdoGas],
                @PagoTotalEstadoPetroleo AS [PagoTotalEstadoPetroleo],
                @PagoTotalEstadoCondensado AS [PagoTotalEstadoCondensado],
                @PagoTotalEstadoGas AS [PagoTotalEstadoGas],
                @PagoCtoElegibleContratistaPetroleo AS [PagoCtoElegibleContratistaPetroleo],
                @PagoCtoElegibleContratistaCondensado AS [PagoCtoElegibleContratistaCondensado],
                @PagoCtoElegibleContratistaGas AS [PagoCtoElegibleContratistaGas],
                @PagoUtilidadOperContratistaPetroleo AS [PagoUtilidadOperContratistaPetroleo],
                @PagoUtilidadOperContratistaCondensado AS [PagoUtilidadOperContratistaCondensado],
                @PagoUtilidadOperContratistaGas AS [PagoUtilidadOperContratistaGas],
                @CargoIngresosAdicionalesPetroleo AS [CargoIngresosAdicionalesPetroleo],
                @CargoIngresosAdicionalesCondensado AS [CargoIngresosAdicionalesCondensado],
                @CargoIngresosAdicionalesGas AS [CargoIngresosAdicionalesGas],
                @PagoTotalContratistaPetroleo AS [PagoTotalContratistaPetroleo],
                @PagoTotalContratistaCondensado AS [PagoTotalContratistaCondensado],
                @PagoTotalContratistaGas AS [PagoTotalContratistaGas],
                @ComprobacionPetroleo AS [ComprobacionPetroleo],
                @ComprobacionCondensado AS [ComprobacionCondensado],
                @ComprobacionGas AS [ComprobacionGas];

    --SELECT
	   --@PagoTotalEstadoPetroleo	 AS [PagoTotalEstadoPetroleo],
	   --@PagoTotalEstadoCondensado	 AS [PagoTotalEstadoCondensado],
	   --@PagoTotalEstadoGas		 AS [PagoTotalEstadoGas],
	   --@PagoTotalContratistaPetroleo		   AS [PagoTotalContratistaPetroleo],
	   --@PagoTotalContratistaCondensado		   AS [PagoTotalContratistaCondensado],
	   --@PagoTotalContratistaGas			   AS [PagoTotalContratistaGas]

     END;