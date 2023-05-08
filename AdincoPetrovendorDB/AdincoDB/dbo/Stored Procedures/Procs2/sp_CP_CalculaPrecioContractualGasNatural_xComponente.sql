CREATE PROCEDURE [dbo].[sp_CP_CalculaPrecioContractualGasNatural_xComponente]
    @IdContrato INT = 0,
    @Mes        DATE,
	@IdUsuario	INT = 1,
	@IdTipoHidrocarburo	INT
AS
BEGIN
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2017
-- Description:	Calculo precio PRODUCCION COMPARTIDA GAS
-- =========================================================================================
-- 20190308	BAAC	Se modifica para tomar solo el porcentaje de pep para el calculo del precio, cuando sea consultado por un usuario de pemex
--					Se calculo el precio por cada componente.
-- ==========================================================================================
SET NOCOUNT ON
-- =============================================

-- Precio Contractual del Gas 
-- Variables
DECLARE
    @SumValor                               MONEY,
    @Metodo                                 VARCHAR (1),
    @MensajeError                           VARCHAR (255), -- Mensaje de Error
    @NumError                               INT, -- Número de Error
    @IdMetodoCalculo                        INT,
    --@VolumenComercializado                  INT,
    @PrecioObservadoGases                   MONEY,
    @PrecioContractualGases                 MONEY,
    @VolumenComercializadoBaseReglasMercado FLOAT,
    @VolumenGasesEntregado                  FLOAT,
	@Cn										FLOAT,
	@Dn										FLOAT,
	@En										FLOAT,
	@Fn										FLOAT,
	@UsuarioPEP								BIT,
	@EsConsorcio							BIT,
	@TipoHidrocarburo						INT,
	@VolumenProduccionT1T2					FLOAT,
	@SumValorContractual					FLOAT,
	@VolumenComercializadoNOReglasMercado	FLOAT,
	@Regalia								FLOAT


SELECT
	@EsConsorcio	=	ISNULL(IsConsorcio,0)
FROM
	dbo.CO_Contrato
WHERE
	IdContrato = @IdContrato


SELECT
	@UsuarioPEP	=	CASE WHEN Usuario LIKE '%@pemex.com%' THEN 1 ELSE 0	END
FROM
	dbo.AP_Usuario
WHERE
	UsuarioID	=	@IdUsuario

SELECT
	@TipoHidrocarburo	=	TipoHidrocarburo
FROM
	dbo.CO_TipoHidrocarburo
WHERE
	IdTipoHidrocarburo	=	@IdTipoHidrocarburo

-- Volumen Producido en el Periodo
SELECT   @VolumenGasesEntregado	= CASE  WHEN @IdTipoHidrocarburo = 10002 AND @EsConsorcio = 0 THEN ROUND(MetanoC1,0)
								WHEN @IdTipoHidrocarburo = 10003 AND @EsConsorcio = 0 THEN ROUND(EtanoC2,0)
								WHEN @IdTipoHidrocarburo = 10004 AND @EsConsorcio = 0 THEN ROUND(PropanoC3,0)
								WHEN @IdTipoHidrocarburo = 10005 AND @EsConsorcio = 0 THEN ROUND(ButanoC4,0)
								WHEN @IdTipoHidrocarburo = 10002 AND @EsConsorcio = 1 AND @UsuarioPEP = 0 THEN ROUND(MetanoC1,0)
								WHEN @IdTipoHidrocarburo = 10003 AND @EsConsorcio = 1 AND @UsuarioPEP = 0 THEN ROUND(EtanoC2,0)
								WHEN @IdTipoHidrocarburo = 10004 AND @EsConsorcio = 1 AND @UsuarioPEP = 0 THEN ROUND(PropanoC3,0)
								WHEN @IdTipoHidrocarburo = 10005 AND @EsConsorcio = 1 AND @UsuarioPEP = 0 THEN ROUND(ButanoC4,0)
								WHEN @IdTipoHidrocarburo = 10002 AND @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND(ROUND(MetanoC1,0) * (PC.PorcentajePemex/100),0)
								WHEN @IdTipoHidrocarburo = 10003 AND @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND(ROUND(EtanoC2,0) * (PC.PorcentajePemex/100),0)
								WHEN @IdTipoHidrocarburo = 10004 AND @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND(ROUND(PropanoC3,0) * (PC.PorcentajePemex/100),0)
								WHEN @IdTipoHidrocarburo = 10005 AND @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND(ROUND(ButanoC4,0) * (PC.PorcentajePemex/100),0)
							END            
FROM
    PR_VolumenMensualProduccionPetroleo	VPP
LEFT JOIN
		dbo.CO_PorcentajesContrato	PC
		ON	VPP.IdContrato	=	PC.idContrato
WHERE
    VPP.IdContrato    = @IdContrato
    AND VPP.MesReporte = @Mes

-- Verificamos que no haya ocurrido ningun Error
SELECT   @NumError = @@ERROR
IF @NumError <> 0
    BEGIN
        SELECT  @MensajeError  = 'Error al obtener el Volumen Entregado' + CHAR(13) +
                + 'En el Stored Procedure: dbo.sp_CP_CalculaPrecioContractualGasNaturalxComponente ' + CHAR(13) +
                + 'Núm. Error en SQL Server:' + CHAR( 9 ) + LTRIM( STR( @NumError, 10, 0 ))
        GOTO ERROR
    END -- IF @NumError <> 0

SELECT
    @Metodo          = 'B',
    @IdMetodoCalculo = 1

-- Volumen Comercializado en Base a Reglas de Mercado
SELECT
	@VolumenComercializadoBaseReglasMercado	=	SUM( ROUND( VolumenVendido, 0 ))
FROM
    COM_OperacionComercializacion
WHERE
	IdContrato             = @IdContrato
    AND MesReporte                 = @Mes
    AND IdTipoHidrocarburo	=	@IdTipoHidrocarburo
    AND OperacionBajoReglasMercado = 1


-- Verificamos que no haya ocurrido ningun Error
SELECT   @NumError = @@ERROR
IF @NumError <> 0
    BEGIN
	    SELECT   @MensajeError   = 'Error al obtener el Volumen Comercializado' + CHAR(13) +
                + 'En el Stored Procedure: dbo.sp_CP_CalculaPrecioContractualGasNaturalxComponente ' + CHAR(13) +
                + 'Núm. Error en SQL Server:' + CHAR( 9 ) + LTRIM( STR( @NumError, 10, 0 ))
        GOTO ERROR
    END -- IF @NumError <> 0


IF @VolumenGasesEntregado = 0 AND @VolumenComercializadoBaseReglasMercado > 0
    GOTO INCISOA

-- Inciso B) Si al menos el 50% de la comercializacion fue en Base Reglas de Mercado
IF (@VolumenComercializadoBaseReglasMercado * 100) / @VolumenGasesEntregado >= 50
    BEGIN
        INCISOA:
        
        SELECT @PrecioContractualGases	=	SUM( CONVERT( DECIMAL (18, 4), (PrecioVentaUnitario - CostoUnitarioComercializacion))* ROUND( VolumenVendido, 0 ) / @VolumenComercializadoBaseReglasMercado)
		FROM
            COM_OperacionComercializacion
        WHERE
            IdContrato              = @IdContrato
            AND MesReporte          = @Mes
            AND IdTipoHidrocarburo	=	@IdTipoHidrocarburo
            AND OperacionBajoReglasMercado = 1

        -- DETERMINAR SI NO ES EL PRIMER MES DEL CONTRATO 
        -- SI NO ES EL PRIMER MES SE VALIDA COMO FUE EL CALCULO DE LOS MESES ANTERIORES
        IF 0 = (SELECT  COUNT( 1 )
                FROM	CO_Contrato
                WHERE    IdContrato                 = @IdContrato
                AND YEAR( InicioVigencia )  = YEAR( @Mes )
                AND MONTH( InicioVigencia ) = MONTH( @Mes )
        )
		BEGIN
            IF 0 < (   SELECT COUNT( 1 )
                    FROM     CP_MetodoCalculoHidrocarburoMes
                    WHERE    IdContrato      = @IdContrato
                    AND YEAR( Mes )  = YEAR( DATEADD( MONTH, -1, @Mes ))
                    AND MONTH( Mes ) = MONTH( DATEADD( MONTH, -1, @Mes ))
                    AND IdTipoHidrocarburo = @TipoHidrocarburo
                    AND IdMetodo IN ( 2, 3 )
            )
            OR 0 < (SELECT  COUNT( 1 )
                    FROM   CP_MetodoCalculoHidrocarburoMes
                    WHERE	IdContrato      = @IdContrato
                    AND YEAR( Mes )  = YEAR( DATEADD( MONTH, -1, @Mes ))
                    AND MONTH( Mes ) = MONTH( DATEADD( MONTH, -1, @Mes ))
                    AND IdTipoHidrocarburo = @TipoHidrocarburo
                    AND IdMetodo IN ( 2, 3 )
            )
            AND 0 < (   SELECT	COUNT( 1 )
                    FROM	CP_MetodoCalculoHidrocarburoMes
					WHERE	IdContrato      = @IdContrato
                    AND YEAR( Mes )  = YEAR( DATEADD( MONTH, -2, @Mes ))
					AND MONTH( Mes ) = MONTH( DATEADD( MONTH, -2, @Mes ))
                    AND IdTipoHidrocarburo = @TipoHidrocarburo
                    AND IdMetodo IN ( 2, 3 )
            )
            BEGIN
                -- C)
                SELECT	@Metodo          = 'D',
                    @IdMetodoCalculo = 4
                -- Sumatoria del Volumen de produccion
                IF 1 = (SELECT	COUNT( 1 )
                        FROM	CP_MetodoCalculoHidrocarburoMes
                        WHERE	IdContrato      = @IdContrato
                        AND YEAR( Mes )  = YEAR( DATEADD( MONTH, -2, @Mes ))
                      AND MONTH( Mes ) = MONTH( DATEADD( MONTH, -2, @Mes ))
                        AND IdTipoHidrocarburo = @TipoHidrocarburo
                        AND IdMetodo IN ( 2, 3 )
                )
                BEGIN
                    -- Volumen produccion del GAS en el punto en los periodos t, t-1 y t-2
                    SELECT
                        @VolumenProduccionT1T2	=	SUM(CASE  WHEN @IdTipoHidrocarburo = 10002 THEN ROUND(MetanoC1,0)
														WHEN @IdTipoHidrocarburo = 10003 THEN ROUND(EtanoC2,0)
														WHEN @IdTipoHidrocarburo = 10004 THEN ROUND(PropanoC3,0)
														WHEN @IdTipoHidrocarburo = 10005 THEN ROUND(ButanoC4,0)	END )
					FROM
                        PR_VolumenMensualProduccionPetroleo
                    WHERE
                        IdContrato = @IdContrato
                        AND MesReporte BETWEEN DATEADD( MONTH, -2, @Mes ) AND @Mes

					SELECT
						@SumValor = SUM( CASE  WHEN @IdTipoHidrocarburo = 10002 THEN ROUND(VMP.MetanoC1,0)
											WHEN @IdTipoHidrocarburo = 10003 THEN ROUND(VMP.EtanoC2,0)
											WHEN @IdTipoHidrocarburo = 10004 THEN ROUND(VMP.PropanoC3,0)
											WHEN @IdTipoHidrocarburo = 10005 THEN ROUND(VMP.ButanoC4,0)	END  * MCH.Precio )
					FROM
						CP_MetodoCalculoHidrocarburoMes     AS MCH
					JOIN
						PR_VolumenMensualProduccionPetroleo AS VMP
						ON MCH.IdContrato = VMP.IdContrato
						AND MCH.Mes        = VMP.MesReporte
					WHERE
						MCH.IdContrato            = @IdContrato
						AND	MCH.Mes BETWEEN DATEADD( MONTH, -2, @Mes ) AND DATEADD( MONTH, -1, @Mes )
						AND MCH.IdTipoHidrocarburo = @TipoHidrocarburo
                END
                ELSE
                BEGIN
                    -- Volumen produccion de los condensados en el punto en los periodos t, t-1
                    SELECT
                        @VolumenProduccionT1T2	=	SUM(CASE  WHEN @IdTipoHidrocarburo = 10002 THEN ROUND(MetanoC1,0)
												WHEN @IdTipoHidrocarburo = 10003 THEN ROUND(EtanoC2,0)
												WHEN @IdTipoHidrocarburo = 10004 THEN ROUND(PropanoC3,0)
												WHEN @IdTipoHidrocarburo = 10005 THEN ROUND(ButanoC4,0)	END )
					FROM
                        PR_VolumenMensualProduccionPetroleo
                    WHERE
                        IdContrato = @IdContrato
                        AND MesReporte BETWEEN DATEADD( MONTH, -1, @Mes ) AND @Mes

					SELECT
						@SumValor = SUM( CASE  WHEN @IdTipoHidrocarburo = 10002 THEN ROUND(VMP.MetanoC1,0)
											WHEN @IdTipoHidrocarburo = 10003 THEN ROUND(VMP.EtanoC2,0)
											WHEN @IdTipoHidrocarburo = 10004 THEN ROUND(VMP.PropanoC3,0)
											WHEN @IdTipoHidrocarburo = 10005 THEN ROUND(VMP.ButanoC4,0)	END  * MCH.Precio )
					FROM
                        CP_MetodoCalculoHidrocarburoMes     AS MCH
                    JOIN
                        PR_VolumenMensualProduccionPetroleo AS VMP
                        ON MCH.IdContrato = VMP.IdContrato
                        AND MCH.Mes        = VMP.MesReporte
                    WHERE
                        MCH.IdContrato            = @IdContrato
                        AND MCH.Mes                = DATEADD( MONTH, -1, @Mes )
                        AND MCH.IdTipoHidrocarburo = @TipoHidrocarburo
                END

                -- Guardamos el precio observado para validar la diferencia con el calculado
				SELECT @PrecioObservadoGases = @PrecioContractualGases

                -- ( PRECIO COMERCIALIZACION * SUM VP - SUM VC ) / VP
				SELECT   @PrecioContractualGases = (@PrecioContractualGases * @VolumenProduccionT1T2 - @SumValor) / @VolumenGasesEntregado

                -- VALIDAR DIFERENCIA ENTRE EL PRECIO ESTIMADO POR LA FORMULA Y EL PRECIO OBSERVADO, SI LA DIFERENCIA ES MAYOR AL 50% DEL PRECIO OBSERVADO
                IF	(	SELECT ABS( @PrecioContractualGases - @PrecioObservadoGases ) ) > 0.5 * @PrecioObservadoGases
                BEGIN
                    -- SI EL PRECIO ESTIMADO ES MAYOR AL OBSERVADO
                    IF @PrecioContractualGases > @PrecioObservadoGases
                    BEGIN
                        SELECT
                            @PrecioContractualGases = @PrecioObservadoGases * 1.5,
                            @Metodo                 = 'i',
                            @IdMetodoCalculo        = 5
                    END	--IF @PrecioContractualGases > @PrecioObservadoGases
                    -- SI EL PRECIO ESTIMADO ES MENOR AL OBSERVADO
                    IF @PrecioContractualGases < @PrecioObservadoGases
                    BEGIN
                        SELECT
                            @PrecioContractualGases = @PrecioObservadoGases * 0.5,
                            @Metodo                 = '2',
                            @IdMetodoCalculo        = 6
                    END	-- IF @PrecioContractualGases < @PrecioObservadoGases
                END
			END
		END
        
		SELECT
			@IdTipoHidrocarburo	AS Hidrocarburo,
            CASE    WHEN @Metodo = 'B' THEN 'a) Promedio Ponderado'
                    WHEN @Metodo = 'C' THEN 'C) Penalizacion'
                    WHEN @Metodo = 'i' THEN 'C) Penalizacion i'
                    WHEN @Metodo = '2' THEN 'C) Penalizacion ii'
            END                                                 AS Metodo,
            @VolumenGasesEntregado								AS VolumenEntregado,
			@VolumenComercializadoBaseReglasMercado				AS VolumenComercializadoBaseReglasMercado,
            CASE WHEN @VolumenGasesEntregado = 0 THEN 0 ELSE (@VolumenComercializadoBaseReglasMercado * 100.00) /@VolumenGasesEntregado END  AS PorcentajeComercializado,
            @PrecioContractualGases                             AS PrecioContractualPetroleo

    END
ELSE
    BEGIN
        -- VALIDAMOS SI EXISTEN COMERCIALIZACIONES DEL GAS
        IF 0 <   @VolumenComercializadoBaseReglasMercado
        BEGIN

            SELECT --@PrecioContractualGases = SUM(PrecioVentaUnitario * CONVERT( DECIMAL(14, 0), VolumenVendido) / @VolumenComercializadoBaseReglasMercado)
                @PrecioContractualGases	=	SUM( (PrecioVentaUnitario - CostoUnitarioComercializacion) * ROUND( VolumenVendido, 0 ) / @VolumenComercializadoBaseReglasMercado)
			FROM
                COM_OperacionComercializacion
			WHERE
                IdContrato                 = @IdContrato
                AND MesReporte                 = @Mes
                AND OperacionBajoReglasMercado = 1
                AND IdTipoHidrocarburo	=	@IdTipoHidrocarburo


            SELECT   @IdMetodoCalculo = 7
            SELECT
				@IdTipoHidrocarburo				AS Hidrocarburo,
                'c) Promedio Ponderado con Comercializacion < 50%'     AS Metodo,
                @VolumenGasesEntregado			AS VolumenEntregado,
                @VolumenComercializadoBaseReglasMercado AS VolumenComercializadoBaseReglasMercado,
                (@VolumenComercializadoBaseReglasMercado * 100.00) / @VolumenGasesEntregado AS PorcentajeComercializado,
                @PrecioContractualGases			AS PrecioContractualPetroleo
		END
        ELSE
        BEGIN
            -- Comercializacion fuera de las reglas del mercado
            SELECT
                @VolumenComercializadoNOReglasMercado	=	SUM(  VolumenVendido)
			FROM
                COM_OperacionComercializacion
			WHERE
				IdContrato                 = @IdContrato
                AND MesReporte                 = @Mes
                AND IdTipoHidrocarburo	=	@IdTipoHidrocarburo
                AND OperacionBajoReglasMercado = 0

     --       -- IF TEMPORAL POR SI NO SE COMERCIALIZO
     --       IF 0 =
     --       (
     --           SELECT COUNT( 1 ) FROM #VolumenComercializado
     --       )
     --       BEGIN
     --           INSERT INTO #VolumenComercializado
     --           (
     --               tipohidrocarburo,
     --               VolumenComercializado
     --           )
     --           SELECT
     --               TH.TipoHidrocarburo,
     --               SUM( ROUND( VolumenVendido, 0 ))
					----SUM( VolumenVendido)
     --               FROM
     --               COM_OperacionComercializacion AS OP
     --               JOIN
     --               CO_TipoHidrocarburo           AS TH
     --               ON OP.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
     --               WHERE
     --               TH.TipoHidrocarburo IN ( 3, 4, 5, 6 )
     --               AND OP.MesReporte                 = @Mes
     --               AND OP.IdContrato                 = @IdContrato
     --               AND OP.OperacionBajoReglasMercado = 1
     --               GROUP BY
     --               TH.TipoHidrocarburo
     --       END

            IF 0 < @VolumenComercializadoNOReglasMercado
			BEGIN
				SELECT
					@PrecioContractualGases	=	SUM(CONVERT(DECIMAL(18, 6), Gases.Precio ) * ROUND(OC.VolumenVendido,0 )/ @VolumenComercializadoNOReglasMercado)
				FROM
					COM_OperacionComercializacion OC
				JOIN
					CO_Marcador                   M
					ON M.TipoHidrocarburo	=	@TipoHidrocarburo
					AND	OC.IdTipoHidrocarburo	=	@IdTipoHidrocarburo
					AND OC.MesReporte		=	@Mes
				JOIN
					CO_PrecioMarcadorDiario       Gases
					ON M.IdMarcador          = Gases.IdMarcador
					AND OC.IdContrato      = Gases.IdContrato
					AND OC.FechaTransaccion	=	Gases.Mes
				WHERE
					OC.IdContrato	=	@IdContrato
					AND OC.MesReporte = @Mes
					AND OC.OperacionBajoReglasMercado	=	0
					AND OC.IdTipoHidrocarburo	=	@IdTipoHidrocarburo

				SELECT @IdMetodoCalculo = 3

				SELECT
					@IdTipoHidrocarburo			AS Hidrocarburo,
					'b) Formula comercializacion < 50%'                    AS Metodo,
					@VolumenGasesEntregado									AS VolumenEntregado,
					@VolumenComercializadoNOReglasMercado                   AS VolumenComercializadoBaseReglasMercado,
					CASE WHEN @VolumenGasesEntregado = 0 THEN 0 ELSE (@VolumenComercializadoNOReglasMercado * 100) / @VolumenGasesEntregado END AS PorcentajeComercializado,
					@PrecioContractualGases                                 AS PrecioContractualPetroleo
			END
		END
    END

SELECT
    @Cn = Cn,
	@Dn = Dn,
	@En	= En,
	@Fn	= Fn
FROM
    CP_ParametroRegalia
WHERE
    Anio = YEAR( @Mes )
-- SE REALIZA EL CALCULO DE LAS REGALIAS
-- si es GAS ASOCIADO:
IF 0 = (SELECT ISNULL(GasNoAsociado,0) FROM CO_CONTRATO WHERE IdContrato = @IdContrato)
BEGIN
	SELECT	@Regalia	=	(ROUND(@PrecioContractualGases,2) / @Cn)*100
END
-- SI ES GAS NO ASOCIADO:
ELSE
BEGIN
	SELECT	@Regalia	=	CASE WHEN @PrecioContractualGases <= @Dn 
							THEN 0
						WHEN @PrecioContractualGases > @Dn AND @PrecioContractualGases < @En
							THEN (((ROUND(@PrecioContractualGases,2) - @Dn) * 60.5)/ROUND(@PrecioContractualGases,2) )
						WHEN @PrecioContractualGases >= @En
							THEN (ROUND(@PrecioContractualGases,2) / @Fn)*100
					END             
END

IF 0 = (   SELECT  COUNT( 1 )
			FROM   CP_MetodoCalculoHidrocarburoMes
			WHERE  IdContrato          = @IdContrato
				AND Mes                = @Mes
				AND IdTipoHidrocarburo = @TipoHidrocarburo)
BEGIN
	-- SE INSERTA LO QUE NO EXISTA EN LA TABLA
	INSERT INTO CP_MetodoCalculoHidrocarburoMes
	(
		IdContrato,
		IdTipoHidrocarburo,
		IdMetodo,
		Mes,
		Precio,
		Volumen,
		Valor,
		TasaRegalia,
		FechaCreacion,
		CreadoPor
	)
	SELECT
		@IdContrato,
		@TipoHidrocarburo,
		@IdMetodoCalculo,
		@Mes AS Mes,
		@PrecioContractualGases,
		@VolumenGasesEntregado,
		@PrecioContractualGases * @VolumenGasesEntregado AS ValorHidrocarburos,
		@Regalia,
		GETDATE(),
		@IdUsuario

END
ELSE
BEGIN
	-- SE ACTUALIZAN LOS VALORES YA EXISTENTES
	UPDATE    CP_MetodoCalculoHidrocarburoMes
		SET
			IdMetodo = @IdMetodoCalculo,
			Precio = @PrecioContractualGases,
			Volumen = @VolumenGasesEntregado,
			Valor	=	@PrecioContractualGases * @VolumenGasesEntregado,
			TasaRegalia	=	@Regalia,
			FechaModificacion = GETDATE(),
			ModificadoPor = @IdUsuario
	WHERE
		IdContrato	=	@IdContrato
		AND		IdTipoHidrocarburo	=	@TipoHidrocarburo
		AND		Mes		=	@Mes
END

GOTO FIN
-- -----------------------------------------------------------------------------------------
ERROR:
-- -----------------------------------------------------------------------------------------
RAISERROR( @MensajeError, 16, 1 )
RETURN 1 -- Error
-- -----------------------------------------------------------------------------------------
FIN:
-- -----------------------------------------------------------------------------------------
RETURN 0
END

