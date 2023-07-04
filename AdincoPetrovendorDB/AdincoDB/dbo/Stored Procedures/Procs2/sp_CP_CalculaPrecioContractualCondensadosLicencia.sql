CREATE PROCEDURE [dbo].[sp_CP_CalculaPrecioContractualCondensadosLicencia]
    @IdContrato INT = 0,
    @Mes        DATE,
	@IdUsuario	INT = 1
AS
BEGIN
-- ==========================================================================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2017
-- Description:	Calculo precio Licencia Condensados
-- ==========================================================================================
-- 20190308	BAAC	Se modifica para tomar solo el porcentaje de pep para el calculo del precio, cuando sea consultado por un usuario de pemex
-- ==========================================================================================
SET NOCOUNT ON

CREATE TABLE #OperacionesFueraReglasMdo
(
	IdOperacionComercializacion	INT,
	FechaTransaccion	DATETIME,
	VolumenVendido		INT,
	PrecioVentaUnitario	MONEY,
	CostoUnitarioComercializacion	MONEY, 
	PrecioPuntoMedicion	MONEY,
	PrecioMarcador		MONEY,
	PRIMARY KEY (IdOperacionComercializacion)
)

CREATE TABLE #UltimaFechaMarcador
(
	IdOperacionComercializacion	INT,
	FechaTransaccion	DATETIME,
	FechaMarcador		DATETIME,
	PRIMARY KEY (IdOperacionComercializacion)
)
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- Variables
DECLARE
	@VolumenCondensadoEntregado  FLOAT,
	@VolumenComercializadoBaseReglasMercado  FLOAT,
	@PrecioContractualCondensados  MONEY,
	@PrecioObservadoCondensados  MONEY,
	@VolumenComercializado  FLOAT,
    @ParamS                FLOAT,
    @SumValor              MONEY,
    @VolumenProduccionT1T2 INT,
    @Metodo                VARCHAR (1),
    @MensajeError          VARCHAR (255), -- Mensaje de Error
    @NumError              INT, -- Número de Error
    @IdMetodoCalculo       INT,
	@Gn						FLOAT,
	@Hn						FLOAT,
    @Regalia				DECIMAL(9,6),
	@IdFormula			INT,
	@UsuarioPEP			BIT,
	@EsConsorcio		BIT


SELECT
	@IdFormula		=	F.IdFormula,
	@EsConsorcio	=	ISNULL(C.IsConsorcio,0)
FROM
	dbo.CO_Contrato	C
JOIN
	CO_Formulas	F
	ON	C.FechaFirma	BETWEEN	F.FechaInicial	AND	F.FechaFinal
	AND F.Activo	=	1
WHERE
	C.IdContrato = @IdContrato

SELECT
	@UsuarioPEP	=	CASE WHEN Usuario LIKE '%@pemex.com%' THEN 1
						ELSE 0
					END
FROM
	dbo.AP_Usuario
WHERE
	UsuarioID	=	@IdUsuario

-- Volumen Producido en el Periodo
SELECT
    @VolumenCondensadoEntregado = CASE WHEN @UsuarioPEP = 1 AND @EsConsorcio = 1 THEN ROUND((ROUND(VolumenCondensadoPuntoMedicion,0) + ROUND(ISNULL(VolumenCondensablePuntoMedicion,0),0)) * (PC.PorcentajePemex/100),0)
									ELSE ROUND(VolumenCondensadoPuntoMedicion,0) + ROUND(ISNULL(VolumenCondensablePuntoMedicion,0),0)
								END,
    @ParamS                     = VPP.ContenidoAzufre
FROM
    PR_VolumenMensualProduccionPetroleo	VPP
LEFT JOIN
		dbo.CO_PorcentajesContrato	PC
		ON	VPP.IdContrato	=	PC.idContrato
		AND ISNULL(VPP.Activo,0) = 1
WHERE
    VPP.IdContrato    = @IdContrato
    AND VPP.MesReporte = @Mes
	AND ISNULL(VPP.Activo,0) = 1

SELECT
    @Metodo          = 'A',
    @IdMetodoCalculo = 1
-- Volumen Comercializado en Base a Reglas de Mercado
SELECT
    @VolumenComercializadoBaseReglasMercado = ISNULL(SUM( ROUND( VolumenVendido, 0 )),0)
FROM
    COM_OperacionComercializacion AS OP
JOIN
    CO_TipoHidrocarburo           AS TH
    ON OP.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
WHERE
    TH.TipoHidrocarburo              = 2
    AND OP.MesReporte                 = @Mes
    AND OP.IdContrato                 = @IdContrato
    AND OP.OperacionBajoReglasMercado = 1
-- Verificamos que no haya ocurrido ningun Error
SELECT    @NumError = @@ERROR
IF @NumError <> 0
    BEGIN
        SELECT
            @MensajeError
            = 'Error al obtener el Volumen Comercializado'
                + 'En el Stored Procedure: dbo.sp_CP_CalculaPrecioContractualCondensadosLicencia '
                + 'Núm. Error en SQL Server:' + CHAR( 9 ) + LTRIM( STR( @NumError, 10, 0 ))
        GOTO ERROR
    END -- IF @NumError <> 0

IF @VolumenCondensadoEntregado = 0 AND @VolumenComercializadoBaseReglasMercado > 0
BEGIN
    GOTO INCISOA
END

IF @VolumenCondensadoEntregado > 0 AND @VolumenComercializadoBaseReglasMercado = 0
BEGIN
	GOTO INCISOCi
END

IF @VolumenCondensadoEntregado = 0 AND @VolumenComercializadoBaseReglasMercado = 0
BEGIN
	GOTO FIN
END

-- Inciso a) Si al menos el 50% de la comercializacion fue en Base Reglas de Mercado
IF (@VolumenComercializadoBaseReglasMercado * 100) / @VolumenCondensadoEntregado >= 50
    BEGIN
        INCISOA:
        SELECT
            @PrecioContractualCondensados = SUM((PrecioVentaUnitario - CostoUnitarioComercializacion) * ROUND( VolumenVendido, 0 ) / @VolumenComercializadoBaseReglasMercado  )
		FROM
            COM_OperacionComercializacion AS OP
            JOIN
            CO_TipoHidrocarburo           AS TH
            ON OP.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
        WHERE
            TH.TipoHidrocarburo              = 2
            AND OP.MesReporte                 = @Mes
            AND OP.IdContrato                 = @IdContrato
            AND OP.OperacionBajoReglasMercado = 1
        -- DETERMINAR SI NO ES EL PRIMER MES DEL CONTRATO 
        -- SI NO ES EL PRIMER MES SE VALIDA COMO FUE EL CALCULO DE LOS MESES ANTERIORES
        IF 0 =
        (
            SELECT
                COUNT( 1 )
                FROM
                CO_Contrato
                WHERE
                IdContrato                 = @IdContrato
                AND YEAR( InicioVigencia )  = YEAR( @Mes )
                AND MONTH( InicioVigencia ) = MONTH( @Mes )
        )
            BEGIN
                IF 0 <
                (
                    SELECT
                        COUNT( 1 )
                        FROM
                        CP_MetodoCalculoHidrocarburoMes
                        WHERE
                        IdContrato            = @IdContrato
                        AND YEAR( Mes )        = YEAR( DATEADD( MONTH, -1, @Mes ))
                        AND MONTH( Mes )       = MONTH( DATEADD( MONTH, -1, @Mes ))
                        AND IdTipoHidrocarburo = 2
                        AND IdMetodo IN ( 2, 3 )
                )
                OR 0 <
                (
                    SELECT
                        COUNT( 1 )
                        FROM
                        CP_MetodoCalculoHidrocarburoMes
                        WHERE
                        IdContrato            = @IdContrato
                        AND YEAR( Mes )        = YEAR( DATEADD( MONTH, -1, @Mes ))
                        AND MONTH( Mes )       = MONTH( DATEADD( MONTH, -1, @Mes ))
                        AND IdTipoHidrocarburo = 2
                        AND IdMetodo IN ( 2, 3 )
                )
                AND 0 <
                (   SELECT	COUNT( 1 )
                        FROM
                        CP_MetodoCalculoHidrocarburoMes
                    WHERE
                        IdContrato            = @IdContrato
                        AND YEAR( Mes )        = YEAR( DATEADD( MONTH, -2, @Mes ))
                        AND MONTH( Mes )       = MONTH( DATEADD( MONTH, -2, @Mes ))
                        AND IdTipoHidrocarburo = 2
                        AND IdMetodo IN ( 2, 3 )
                )
                    BEGIN
                        -- C)
                        SELECT
                            @Metodo          = 'C',
                            @IdMetodoCalculo = 4
                        -- Sumatoria del Volumen de produccion
                        IF 1 =
                        (  SELECT	COUNT( 1 )
                                FROM	CP_MetodoCalculoHidrocarburoMes
                                WHERE
                                IdContrato            = @IdContrato
                                AND YEAR( Mes )        = YEAR( DATEADD( MONTH, -2, @Mes ))
                                AND MONTH( Mes )       = MONTH( DATEADD( MONTH, -2, @Mes ))
                                AND IdTipoHidrocarburo = 2
                                AND IdMetodo IN ( 2, 3 )
                        )
                        BEGIN
                            -- Volumen produccion del petrole en el punto en los periodos t, t-1 y t-2
                            SELECT
                                @VolumenProduccionT1T2 = SUM( VolumenCondensadoPuntoMedicion )
                            FROM
                                PR_VolumenMensualProduccionPetroleo
                            WHERE
                                IdContrato = @IdContrato
                                AND MesReporte BETWEEN DATEADD( MONTH, -2, @Mes ) AND @Mes
								AND ISNULL(Activo,0) = 1
                            SELECT
                                @SumValor = SUM( VMP.VolumenCondensadoPuntoMedicion * MCH.Precio )
                            FROM
                                CP_MetodoCalculoHidrocarburoMes     AS MCH
                            JOIN
                                PR_VolumenMensualProduccionPetroleo AS VMP
								ON MCH.IdContrato = VMP.IdContrato
								AND MCH.Mes        = VMP.MesReporte
								AND ISNULL(VMP.Activo,0) = 1
							WHERE
								MCH.IdContrato            = @IdContrato
                                AND	MCH.Mes BETWEEN DATEADD( MONTH, -2, @Mes ) AND DATEADD( MONTH, -1, @Mes )
                                AND MCH.IdTipoHidrocarburo = 2
								AND ISNULL(VMP.Activo,0) = 1
                        END
                        ELSE
                        BEGIN
                            -- Volumen produccion de los condensados en el punto en los periodos t, t-1
                            SELECT
                                @VolumenProduccionT1T2 = SUM( VolumenCondensadoPuntoMedicion )
							FROM
                                PR_VolumenMensualProduccionPetroleo
                            WHERE
                                IdContrato = @IdContrato
                                AND MesReporte BETWEEN DATEADD( MONTH, -1, @Mes ) AND @Mes
								AND ISNULL(Activo,0) = 1
                            SELECT
                                @SumValor = ISNULL(VMP.VolumenCondensadoPuntoMedicion * MCH.Precio,0)
                            FROM
                                CP_MetodoCalculoHidrocarburoMes     AS MCH
                            JOIN
                                PR_VolumenMensualProduccionPetroleo AS VMP
                                ON MCH.IdContrato = VMP.IdContrato
                                AND MCH.Mes        = VMP.MesReporte
								AND ISNULL(VMP.Activo,0) = 1
                            WHERE
                                MCH.IdContrato            = @IdContrato
                                AND MCH.Mes                = DATEADD( MONTH, -1, @Mes )
                                AND MCH.IdTipoHidrocarburo = 2
								AND ISNULL(VMP.Activo,0) = 1
                        END
                        -- GUardamos el precio observado para validar la diferencia con el calculado
                        SELECT  @PrecioObservadoCondensados = @PrecioContractualCondensados
                        -- ( PRECIO COMERCIALIZACION * SUM VP - SUM VC ) / VP
                        SELECT   @PrecioContractualCondensados = (@PrecioContractualCondensados * @VolumenProduccionT1T2 - @SumValor) / @VolumenCondensadoEntregado
                        -- VALIDAR DIFERENCIA ENTRE EL PRECIO ESTIMADO POR LA FORMULA Y EL PRECIO OBSERVADO, SI LA DIFERENCIA ES MAYOR AL 50% DEL PRECIO OBSERVADO
                        IF ( SELECT ABS( @PrecioContractualCondensados - @PrecioObservadoCondensados )) > 0.5 * @PrecioObservadoCondensados
                        BEGIN
                            -- SI EL PRECIO ESTIMADO ES MAYOR AL OBSERVADO
                            IF @PrecioContractualCondensados > @PrecioObservadoCondensados
                            BEGIN
                                SELECT
                                    @PrecioContractualCondensados = @PrecioObservadoCondensados * 1.5,
                                    @Metodo                       = 'i',
   @IdMetodoCalculo = 5
                            END
                            -- SI EL PRECIO ESTIMADO ES MENOR AL OBSERVADO
                            IF @PrecioContractualCondensados < @PrecioObservadoCondensados
                            BEGIN
                                SELECT
                                    @PrecioContractualCondensados = @PrecioObservadoCondensados * 0.5,
                                    @Metodo                       = '2',
                                    @IdMetodoCalculo              = 6
                            END
                        END -- IF ( SELECT ABS( @PrecioContractualCondensados - @PrecioObservadoCondensados )
                    END
            END
        SELECT
            CASE
                    WHEN @Metodo = 'A' THEN 'a) Promedio Ponderado'
                    WHEN @Metodo = 'C' THEN 'C) Penalizacion'
                    WHEN @Metodo = 'i' THEN 'C) Penalizacion i'
              WHEN @Metodo = '2' THEN 'C) Penalizacion ii'
            END                   AS Metodo,
			@VolumenCondensadoEntregado             AS VolumenEntregado,
            @VolumenComercializadoBaseReglasMercado AS VolumenComercializadoBaseReglasMercado,
            CASE
                    WHEN @VolumenCondensadoEntregado = 0 THEN 100
                    ELSE ROUND((@VolumenComercializadoBaseReglasMercado * 100) / @VolumenCondensadoEntregado,2,1)
            END                                     AS PorcentajeComercializado,
            @PrecioContractualCondensados           AS PrecioContractualPetroleo
    END
ELSE
    BEGIN
		-- SI SE COMERCIALIZO MENOS DEL 50% PERO MAS DE 0 CON BASE EN REGLAS DEL MERCADO
		IF	@VolumenComercializadoBaseReglasMercado > 0
		BEGIN
			GOTO INCISOA
		END

		INCISOCi:
        SELECT
            @VolumenComercializado = ISNULL(SUM( ROUND( VolumenVendido, 0 )),0)
		FROM
            COM_OperacionComercializacion AS OP
            JOIN
            CO_TipoHidrocarburo           AS TH
            ON OP.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
		WHERE
            TH.TipoHidrocarburo = 2
            AND OP.MesReporte    = @Mes
            AND OP.IdContrato    = @IdContrato
			AND op.OperacionBajoReglasMercado	=	0
        -- SI NO SE COMERCIALIZO NADA DURANTE EL PERIODO AUN SIN REGLAS DEL MERCADO
        IF ISNULL( @VolumenComercializado, 0 ) = 0
        BEGIN
			-- SE VALIDA QUE EXISTE PRECIO DEL MARCADOR
			IF 0 = (SELECT COUNT(1) FROM CO_PrecioMarcadorMensual WHERE IdContrato  = @IdContrato AND Mes = @Mes AND IdMarcador = 10002)
			BEGIN
			        SELECT  @MensajeError 	= 'No se encontro precio del Marcador Brent'
					+ ' para el mes: ' + LTRIM(@Mes)
				GOTO ERROR
			END

            SELECT
                --SUM( 6.282 + 0.905 * Brent.Precio ) AS PrecioContractual
				@PrecioContractualCondensados	=	FD.Constante + (FD.Constante_Brent * Brent.Precio)
			FROM
                CO_PrecioMarcadorMensual AS Brent
			JOIN
				CO_Formulas_Detalle	FD
				ON	FD.IdFormula	=	@IdFormula
				AND FD.IdTipoHidrocarburo	=	10001	-- CONDENSADO
            WHERE
                Brent.IdContrato    = @IdContrato
                AND Brent.Mes        = @Mes
                AND Brent.IdMarcador = 10002

            SELECT
                @IdMetodoCalculo = 3
            SELECT
                'b) Formula No comercializacion'                                              AS Metodo,
                @VolumenCondensadoEntregado                                                   AS VolumenEntregado,
                @VolumenComercializadoBaseReglasMercado                                       AS VolumenComercializadoBaseReglasMercado,
                0																				 AS PorcentajeComercializado,
                @PrecioContractualCondensados                                                 AS PrecioContractualPetroleo
        END	-- IF ISNULL( @VolumenComercializado, 0 ) = 0
		ELSE	-- SE COMERCIALIZO SIN REGLAS DEL MERCADO
		BEGIN
			-- SE CALCULA EL PROMEDIO DE LOS PRECIOS CALCULADOS MEDIANTE FORMULA (6.282 + 0.905 * Brent_FECHAOPERACION/ULTIMOVALORPUBLICADO) PONDERADO
			--PRIMERO SE BUSCA SI EXISTE PRECIO DEL MERCADOR A LA FECHA DE TRANSACCION SIN REGLAS DE MERCADO
			INSERT INTO #OperacionesFueraReglasMdo
			(
				IdOperacionComercializacion,
				FechaTransaccion,
				VolumenVendido,
				PrecioVentaUnitario,
				CostoUnitarioComercializacion, 
				PrecioPuntoMedicion
			)
			SELECT
				IdOperacionComercializacion,
				FechaTransaccion,
				VolumenVendido,
				PrecioVentaUnitario,
				CostoUnitarioComercializacion, 
				PrecioPuntoMedicion
			FROM
				COM_OperacionComercializacion AS OP
				JOIN
				CO_TipoHidrocarburo           AS TH
				ON OP.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
			WHERE
				TH.TipoHidrocarburo = 2
				AND OP.MesReporte    = @Mes
				AND OP.IdContrato    = @IdContrato
				AND OP.OperacionBajoReglasMercado	=	0

			UPDATE	OFRM
				SET	PrecioMarcador	=	BRENT.[PRECIO (USD/Bbl) BRENT]
			FROM
				#OperacionesFueraReglasMdo	OFRM
			JOIN
				CO_PreciosBrentGas	BRENT
				ON	OFRM.FechaTransaccion	=	BRENT.FECHA

			-- SI NO EXISTE PRECIO DEL MARCADOR PARA LA FECHA DE OPPERACION, SE BUSCA EL ULTIMO PRECIO ANTES DE DICHA FECHA
			IF 0 < (SELECT COUNT(1) FROM #OperacionesFueraReglasMdo WHERE PrecioMarcador IS NULL)
			BEGIN
				INSERT INTO #UltimaFechaMarcador
				(
					IdOperacionComercializacion,
					FechaTransaccion,
					FechaMarcador
				)
				SELECT
					IdOperacionComercializacion,
					FechaTransaccion,
					MAX(BRENT.FECHA)
				FROM
					#OperacionesFueraReglasMdo	OFRM
				JOIN
					CO_PreciosBrentGas	BRENT
					ON	OFRM.FechaTransaccion	>	BRENT.FECHA
				WHERE
					OFRM.PrecioMarcador	IS NULL
				GROUP BY
					IdOperacionComercializacion,
					FechaTransaccion

				UPDATE	OFRM
					SET	PrecioMarcador	=	BRENT.[PRECIO (USD/Bbl) BRENT]
				FROM
					#OperacionesFueraReglasMdo	OFRM
				JOIN
					#UltimaFechaMarcador	UF
					ON	OFRM.IdOperacionComercializacion	=	UF.IdOperacionComercializacion
				JOIN
					CO_PreciosBrentGas	BRENT
					ON	UF.FechaMarcador	=	BRENT.FECHA
			END	--IF 0 < (SELECT COUNT(1) FROM #OperacionesFueraReglasMdo WHERE PrecioMarcador IS NULL)

			SELECT
				@PrecioContractualCondensados = SUM( PrecioMarcador * ROUND( VolumenVendido, 0 ) / @VolumenComercializado  )
			FROM
				#OperacionesFueraReglasMdo

			SELECT
				@IdMetodoCalculo = 3
			SELECT
				'b) Formula No comercializacion'                                              AS Metodo,
				@VolumenCondensadoEntregado                                                   AS VolumenEntregado,
				@VolumenComercializado					                                       AS VolumenComercializadoBaseReglasMercado,
				ROUND((@VolumenComercializadoBaseReglasMercado * 100) / @VolumenCondensadoEntregado,2,1) AS PorcentajeComercializado,
				@PrecioContractualCondensados                                                 AS PrecioContractualPetroleo

		END	-- IF ISNULL( @VolumenComercializado, 0 ) = 0
    END

-- SE OBTIENE EL PORCENTAJE DE REGALIAS
SELECT
    @Gn = Gn,
    @Hn = Hn
FROM
    CP_ParametroRegalia
WHERE
    Anio = YEAR( @Mes )
SELECT
    @Regalia = CASE
                    WHEN @PrecioContractualCondensados < @Gn THEN 5
                    ELSE (@Hn * ROUND(@PrecioContractualCondensados,2)) - 2.5
                END

-- SE INSERTA EL VALOR FINAL CALCULADO, SI YA EXISTE SOLO SE ACTUALIZA
IF 0 = 
(   SELECT  COUNT( 1 )
			FROM   CP_MetodoCalculoHidrocarburoMes
			WHERE  IdContrato            = @IdContrato
			AND Mes                = @Mes
			AND IdTipoHidrocarburo = 2
)
    BEGIN
        INSERT INTO CP_MetodoCalculoHidrocarburoMes
        (
            IdContrato,
            IdTipoHidrocarburo,
            IdMetodo,
            Mes,
            Precio,
            Volumen,
            TasaRegalia,
			Valor,
			FechaCreacion,
			CreadoPor
      ) 
        SELECT
			@IdContrato,
				 2,
            @IdMetodoCalculo,
            @Mes,
            @PrecioContractualCondensados,
            @VolumenCondensadoEntregado,
            @Regalia,
			@PrecioContractualCondensados * @VolumenCondensadoEntregado,
			GETDATE(),
			@IdUsuario
    END
ELSE
    BEGIN

        UPDATE	CP_MetodoCalculoHidrocarburoMes
            SET
            IdMetodo = @IdMetodoCalculo,
            Precio = @PrecioContractualCondensados,
            Volumen = @VolumenCondensadoEntregado,
            TasaRegalia = @Regalia,
			Valor	=	@PrecioContractualCondensados * @VolumenCondensadoEntregado,
			FechaModificacion = GETDATE(),
			ModificadoPor = @IdUsuario
		WHERE
            IdContrato        = @IdContrato
			AND Mes       = @Mes
            AND IdTipoHidrocarburo = 2
    END
-- Valores utilizados en el calculo
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
