CREATE PROCEDURE [dbo].[sp_CP_CalculaPrecioContractualPetroleo]
    @IdContrato INT = 0,
    @Mes        DATE,
	@IdUsuario	INT = 1
AS
BEGIN
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2017
-- Description:	Calculo Contraprestaciones Licencia Petroleo
-- =============================================
-- 20190308	BAAC	Se modifica para cambiar la formula del precio del petroleo de acuerdo a los grados API
-- 20190308	BAAC	Se modifica para tomar solo el porcentaje de pep para el calculo del precio, cuando sea consultado por un usuario de pemex
-- =============================================
SET NOCOUNT ON

DECLARE
	@VolumenPetroleoEntregado INT,
	@VolumenComercializadoBaseReglasMercado INT,
	@PrecioContractualPetroleo MONEY,
	@PrecioObservadoPetroleo MONEY,
	--@GradosAPI FLOAT,
	@VolumenComercializado int = 0,
	@An FLOAT,
	@Bn FLOAT,
	@Regalia DECIMAL(9,6),
	@UrlImgRegalia NVARCHAR (MAX),
	--@ParamS                DECIMAL (5, 3),
	@SumValor              MONEY,
	@VolumenProduccionT1T2 INT,
	@Metodo                VARCHAR (1),
	@MensajeError          VARCHAR (255), -- Mensaje de Error
	@NumError              INT, -- Número de Error
	@IdMetodoCalculo       INT,
	--@TipoContrato		INT,
	@GasNoAsociado		 BIT,
	--@FechaFirma		 DATE,
	@IdFormula			INT,
	@UsuarioPEP			BIT,
	@EsConsorcio		BIT
	--@IdUsuario INT
	--@SumaValorLLS float,
	--@SumaValorBrent float,
	--@SumaValorS float;

SELECT
	@GasNoAsociado = GasNoAsociado,
	--@AñoContrato = RIGHT(NumeroContrato,4)
	--@FechaFirma	=	FechaFirma
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

--IF @IdContrato = 10014
--BEGIN
--	SELECT @GasNoAsociado = 0
--END

IF @GasNoAsociado <> 1
BEGIN
    -- Volumen Producido en el Periodo
    SELECT
        @VolumenPetroleoEntregado = CASE WHEN @UsuarioPEP = 1 AND @EsConsorcio = 1 THEN ROUND(ROUND(ISNULL(VPP.VolumenPetroleoPuntoMedicion,0),0) * (PC.PorcentajePemex/100),0)
										ELSE ROUND(ISNULL(VPP.VolumenPetroleoPuntoMedicion,0),0)
									END
        --@GradosAPI                = ISNULL(GradosAPI,0),
        --@ParamS                   = ISNULL(ContenidoAzufre,0)
    FROM
        PR_VolumenMensualProduccionPetroleo	VPP
	LEFT JOIN
		dbo.CO_PorcentajesContrato	PC
		ON	VPP.IdContrato	=	PC.idContrato
    WHERE
        VPP.IdContrato    = @IdContrato
        AND VPP.MesReporte = @Mes

	---- Traer valores a multiplicar, para las formulas 
	--SELECT 
	--	@SumaValorLLS =SumaValorLLS,
	--	@SumaValorBrent=SumaValorBrent,
	--	@SumaValorS = SumaValorS
	--FROM dbo.CO_FormulaContratoAnual
	--WHERE 
	--	@GradosAPI BETWEEN RangoIni AND RangoFIn
	--	AND Año = @AñoContrato

	-- Traer valores a multiplicar, para las formulas 
    SELECT
        @Metodo          = 'A',
        @IdMetodoCalculo = 1

    -- Volumen Comercializado en Base a Reglas de Mercado
    SELECT
        @VolumenComercializadoBaseReglasMercado = ISNULL( SUM( ROUND( VolumenVendido, 0 )), 0 )
	FROM
        COM_OperacionComercializacion OP
    JOIN
        CO_TipoHidrocarburo           TH
        ON OP.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
    WHERE
        TH.TipoHidrocarburo              = 1
        AND OP.MesReporte                 = @Mes
        AND OP.IdContrato                 = @IdContrato
        AND OP.OperacionBajoReglasMercado = 1

 --   SELECT
 --       @TipoContrato = IdTipoContrato
	--FROM
 --       CO_Contrato
 --   WHERE
 --       IdContrato = @IdContrato
    -- Verificamos que no haya ocurrido ningun Error
    SELECT
        @NumError = @@ERROR
    IF @NumError <> 0
    BEGIN
        SELECT
            @MensajeError
            = 'Error al obtener el Volumen Comercializado'
       + 'En el Stored Procedure: dbo.sp_CP_CalculaPrecioContractualPetroleo '
                + 'Núm. Error en SQL Server:' + CHAR( 9 ) + LTRIM( STR( @NumError, 10, 0 ))
        GOTO ERROR
    END -- IF @NumError <> 0
	--IF @VolumenComercializadoBaseReglasMercado =0
	--BEGIN
	--select 'No existe volumen comercializado bajo las reglas del mercado'
	----GOTO FIN;
	--END
    IF @VolumenPetroleoEntregado = 0 AND @VolumenComercializadoBaseReglasMercado > 0
    BEGIN
        GOTO INCISOA
    END

	IF @VolumenPetroleoEntregado = 0 AND @VolumenComercializadoBaseReglasMercado = 0
	BEGIN
		GOTO FIN
	END
	
    -- Inciso a) Si al menos el 50% de la comercializacion fue en Base Reglas de Mercado
    IF (((@VolumenComercializadoBaseReglasMercado * 100) / @VolumenPetroleoEntregado) >= 50)
    BEGIN
        INCISOA:

        SELECT
            @PrecioContractualPetroleo
            = SUM((PrecioVentaUnitario - CostoUnitarioComercializacion)
                    * (ROUND( VolumenVendido, 0 ) / @VolumenComercializadoBaseReglasMercado) )
        FROM
            COM_OperacionComercializacion OP
        JOIN
            CO_TipoHidrocarburo           TH
            ON OP.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
        WHERE
            TH.TipoHidrocarburo              = 1
            AND OP.MesReporte                 = @Mes
            AND OP.IdContrato                 = @IdContrato
            AND OP.OperacionBajoReglasMercado = 1
        -- DETERMINAR SI NO ES EL PRIMER MES DEL CONTRATO -- SI NO ES EL PRIMER MES SE VALIDA COMO FUE EL CALCULO DE LOS MESES ANTERIORES
        IF 0 =
        (  SELECT    COUNT( 1 )
           FROM
                CO_Contrato
           WHERE
                IdContrato                 = @IdContrato
                AND YEAR( InicioVigencia )  = YEAR( @Mes )
                AND MONTH( InicioVigencia ) = MONTH( @Mes )
        )
        BEGIN
            IF 0 <
            (   SELECT COUNT( 1 )
                FROM
                    CP_MetodoCalculoHidrocarburoMes
                WHERE
                    IdContrato            = @IdContrato
                    AND YEAR( Mes )        = YEAR( DATEADD( MONTH, -1, @Mes ))
                    AND MONTH( Mes )       = MONTH( DATEADD( MONTH, -1, @Mes ))
                    AND IdTipoHidrocarburo = 1
                    AND IdMetodo IN ( 2, 3 )
            )
            OR
            (   0 <
            (
                SELECT COUNT( 1 )
                FROM
                    CP_MetodoCalculoHidrocarburoMes
                WHERE
                    IdContrato            = @IdContrato
                    AND YEAR( Mes )        = YEAR( DATEADD( MONTH, -1, @Mes ))
                    AND MONTH( Mes )       = MONTH( DATEADD( MONTH, -1, @Mes ))
                    AND IdTipoHidrocarburo = 1
                    AND IdMetodo IN ( 2, 3 )
            )
            AND   0 <
            (   SELECT COUNT( 1 )
                FROM
                    CP_MetodoCalculoHidrocarburoMes
                WHERE
                    IdContrato            = @IdContrato
                    AND YEAR( Mes )        = YEAR( DATEADD( MONTH, -2, @Mes ))
                    AND MONTH( Mes )       = MONTH( DATEADD( MONTH, -2, @Mes ))
                    AND IdTipoHidrocarburo = 1
                    AND IdMetodo IN ( 2, 3 )
            )
            )
            BEGIN
                -- C)
                SELECT
                    @Metodo          = 'C',
                    @IdMetodoCalculo = 4

                -- Sumatoria del Volumen de produccion
                IF 1 =
                (   SELECT COUNT( 1 )
                    FROM
                        CP_MetodoCalculoHidrocarburoMes
                    WHERE
                        IdContrato            = @IdContrato
                        AND YEAR( Mes )        = YEAR( DATEADD( MONTH, -2, @Mes ))
                        AND MONTH( Mes )       = MONTH( DATEADD( MONTH, -2, @Mes ))
                        AND IdTipoHidrocarburo = 1
                        AND IdMetodo IN ( 2, 3 )
                )
                BEGIN
                    -- Volumen produccion del petrole en el punto en los periodos t, t-1 y t-2
                    SELECT
                        @VolumenProduccionT1T2 = SUM( VolumenPetroleoPuntoMedicion )
                    FROM
                        PR_VolumenMensualProduccionPetroleo
                    WHERE
                        IdContrato = @IdContrato
                        AND MesReporte BETWEEN DATEADD( MONTH, -2, @Mes ) AND @Mes
					SELECT
						@SumValor = SUM( VMP.VolumenPetroleoPuntoMedicion * MCH.Precio )
                    FROM
                        CP_MetodoCalculoHidrocarburoMes     MCH
                    JOIN
                        PR_VolumenMensualProduccionPetroleo VMP
               ON MCH.IdContrato = VMP.IdContrato
                        AND MCH.Mes        = VMP.MesReporte
                    WHERE
                        MCH.IdContrato            = @IdContrato
                        AND MCH.Mes BETWEEN DATEADD( MONTH, -2, @Mes ) AND DATEADD(MONTH, -1, @Mes )
                        AND MCH.IdTipoHidrocarburo = 1
                END
                ELSE
                BEGIN
                    -- Volumen produccion del petrole en el punto en los periodos t, t-1
                    SELECT
                        @VolumenProduccionT1T2 = SUM( VolumenPetroleoPuntoMedicion )
					FROM
                        PR_VolumenMensualProduccionPetroleo
                    WHERE
                        IdContrato = @IdContrato
                        AND MesReporte BETWEEN DATEADD( MONTH, -1, @Mes ) AND @Mes
              SELECT
                        @SumValor = (VMP.VolumenPetroleoPuntoMedicion * MCH.Precio)
                    FROM
                        CP_MetodoCalculoHidrocarburoMes     MCH
                    JOIN
                        PR_VolumenMensualProduccionPetroleo VMP
                        ON MCH.IdContrato = VMP.IdContrato
                        AND MCH.Mes        = VMP.MesReporte
                    WHERE
                        MCH.IdContrato            = @IdContrato
                        AND MCH.Mes                = DATEADD( MONTH, -1, @Mes )
                        AND MCH.IdTipoHidrocarburo = 1
                END
                -- Guardamos el precio observado para validar la diferencia con el calculado
                SELECT
                    @PrecioObservadoPetroleo = @PrecioContractualPetroleo

                -- ( PRECIO COMERCIALIZACION * SUM VP - SUM VC ) / VP
                SELECT
                    @PrecioContractualPetroleo
                    = ((@PrecioContractualPetroleo * @VolumenProduccionT1T2) - @SumValor)
                        / @VolumenPetroleoEntregado

                -- VALIDAR DIFERENCIA ENTRE EL PRECIO ESTIMADO POR LA FORMULA Y EL PRECIO OBSERVADO, SI LA DIFERENCIA ES MAYOR AL 50% DEL PRECIO OBSERVADO
                IF (   SELECT ABS( @PrecioContractualPetroleo - @PrecioObservadoPetroleo )
                ) > (0.5 * @PrecioObservadoPetroleo)
                BEGIN
                    -- SI EL PRECIO ESTIMADO ES MAYOR AL OBSERVADO
                    IF (@PrecioContractualPetroleo > @PrecioObservadoPetroleo)
                    BEGIN
                        SELECT
                            @PrecioContractualPetroleo = @PrecioObservadoPetroleo * 1.5,
                            @Metodo                    = 'i',
                            @IdMetodoCalculo           = 5
                    END
                    -- SI EL PRECIO ESTIMADO ES MENOR AL OBSERVADO
                    IF (@PrecioContractualPetroleo < @PrecioObservadoPetroleo)
                    BEGIN
                        SELECT
                            @PrecioContractualPetroleo = @PrecioObservadoPetroleo * 0.5,
  @Metodo                    = '2',
                            @IdMetodoCalculo           = 6
                    END
                END
            END
        END
        SELECT
            CASE
                    WHEN @Metodo = 'A' THEN 'a) Promedio Ponderado'
                    WHEN @Metodo = 'C' THEN 'C) Penalizacion'
                    WHEN @Metodo = 'i' THEN 'C) Penalizacion i'
                    WHEN @Metodo = '2' THEN 'C) Penalizacion ii'
            END                                                                         AS Metodo,
            @VolumenPetroleoEntregado                                                   AS VolumenEntregado,
            @VolumenComercializadoBaseReglasMercado                                     AS VolumenComercializadoBaseReglasMercado,
            CASE WHEN @VolumenPetroleoEntregado = 0 THEN 0
				ELSE (@VolumenComercializadoBaseReglasMercado * 100) / @VolumenPetroleoEntregado
			END				AS PorcentajeComercializado,
            @PrecioContractualPetroleo                                                  AS PrecioContractualPetroleo
    END
    ELSE
    BEGIN
        IF 0 <
        (  SELECT	COUNT( 1 )
            FROM	CP_PrecioPetroleoEquivalenteFOB
            WHERE	IdContrato = @IdContrato
				AND Mes     = @Mes
        )
        BEGIN
            SELECT
                @PrecioContractualPetroleo = PrecioFreeOnBoard
			FROM
                CP_PrecioPetroleoEquivalenteFOB
            WHERE
                IdContrato = @IdContrato
                AND Mes     = @Mes
            SELECT
                @IdMetodoCalculo = 2
            SELECT
                'b) Precio referencia'                                                      AS Metodo,
                @VolumenPetroleoEntregado                                                   AS VolumenEntregado,
                @VolumenComercializadoBaseReglasMercado                                     AS VolumenComercializadoBaseReglasMercado,
                (@VolumenComercializadoBaseReglasMercado * 100) / @VolumenPetroleoEntregado AS PorcentajeComercializado,
                @PrecioContractualPetroleo                                                  AS PrecioContractualPetroleo
        END
        ELSE
        BEGIN
            -- FALTA CALCULAR EL VALOR DEL PARAMETRO S-- actualmente es el valor ContenidoAzufre de la tabla PR_VolumenMensualProduccionPetroleo
            -- Volumen Comercializado en Base a Reglas de Mercado
            SELECT
                @VolumenComercializado = SUM(ROUND( ISNULL (VolumenVendido,0), 0 ))
			FROM
                COM_OperacionComercializacion OP
            JOIN
				CO_TipoHidrocarburo           TH
                ON OP.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
            WHERE
                TH.TipoHidrocarburo       = 1
                AND MONTH( OP.MesReporte ) = MONTH( @Mes )
                AND YEAR( OP.MesReporte )  = YEAR( @Mes )
                AND OP.IdContrato          = @IdContrato
				--AND OP.OperacionBajoReglasMercado = 0

				-- VolumenVendido cambiar por volumen producido
--Inciso B)
-- En caso de que no se haya comercializado pero si se haya producido se hará con las siguientes formulas
			IF(@VolumenComercializado IS NULL )
			BEGIN
				-- SE VALIDA QUE EXISTE PRECIO DEL MARCADOR
				IF 0 = (SELECT COUNT(1) FROM CO_PrecioMarcadorMensual WHERE IdContrato  = @IdContrato AND Mes = @Mes AND IdMarcador = 10002)
				BEGIN
						SELECT  @MensajeError 	= 'No se encontro precio del Marcador Brent para el mes: ' + LTRIM(@Mes)
					GOTO ERROR
				END

				----------------------------------CALCULO SEGÚN LAS FORMULAS INCISO B) APARTADO II(2)------------------------------------------------
				SELECT
					@PrecioContractualPetroleo	=	FD.Constante + (FD.Constante_LLS * LLS.Precio) + (FD.Constante_Brent * Brent.Precio) + (FD.Constante1_API * ROUND(OC.GradosAPI,1)) -  (FD.Constante2_API * POWER(ROUND(OC.GradosAPI,1),FD.Elevacion_API)) - (FD.Constante_S *


 OC.ContenidoAzufre)
				FROM
					PR_VolumenMensualProduccionPetroleo OC
				JOIN
					CO_PrecioMarcadorMensual      Brent
					ON OC.IdContrato         = Brent.IdContrato
					AND OC.MesReporte         = Brent.Mes
					AND Brent.IdMarcador      = 10002
				JOIN
					CO_Formulas_Detalle	FD
					ON	FD.IdFormula	=	@IdFormula
					AND	ROUND(OC.GradosAPI,1)	BETWEEN FD.API_RangoIni	AND FD.API_RangoFIn
					AND FD.IdTipoHidrocarburo	=	10000	-- PETROLEO
				LEFT JOIN
					CO_PrecioMarcadorMensual      LLS
					ON OC.IdContrato         = LLS.IdContrato
					AND OC.MesReporte         = LLS.Mes
					AND LLS.IdMarcador        = 10001
				WHERE
					OC.IdContrato          = @IdContrato
					AND OC.MesReporte       = @Mes
				-------------------------------------------------
				SELECT
					@IdMetodoCalculo = 3
				SELECT
					'b) apartado II'                                                                AS Metodo,
					@VolumenPetroleoEntregado                                                   AS VolumenEntregado,
					@VolumenComercializadoBaseReglasMercado                                     AS VolumenComercializadoBaseReglasMercado,
					(@VolumenComercializadoBaseReglasMercado * 100) / @VolumenPetroleoEntregado AS PorcentajeComercializado,
					@PrecioContractualPetroleo													 AS PrecioContractualPetroleo
		          
			END --termina el if del volumen comercializado
                --IF (@VolumenComercializado IS NULL)
                --    BEGIN
                --        SELECT
                --            @MensajeError
                --            = 'No se encontro valor vigente para el Volumen Comercializado'
                --                + CHAR( 13 )
                --                + 'En el Stored Procedure: dbo.sp_CP_CalculaPrecioContractualPetroleo'
                --        GOTO ERROR
                --    END
		END
	END
-------------------------------------------------------------------------------------------------------------
----------------------------------CALCULO SEGÚN LAS FORMULAS ------------------------------------------------
-------------------------------------------------------------------------------------------------------------

    -- SE INSERTA EL VALOR FINAL CALCULADO, SI YA EXISTE SOLO SE ACTUALIZA
    IF 0 = 
    (   SELECT COUNT( 1 )
        FROM
            CP_MetodoCalculoHidrocarburoMes
        WHERE
            IdContrato            = @IdContrato
            AND Mes                = @Mes
            AND IdTipoHidrocarburo = 1
    )
    BEGIN
        SELECT
            @UrlImgRegalia = CASE
                    WHEN @PrecioContractualPetroleo < @An THEN '~/assets/images/reg-pet-i.png'
                    ELSE '~/assets/images/reg-pet-ii.png'
                END
        SELECT
            @An = An,
            @Bn = Bn
        FROM
            CP_ParametroRegalia
        WHERE
            Anio = YEAR( @Mes )
        SELECT
            @Regalia = CASE
                            WHEN @PrecioContractualPetroleo < @An THEN 7.5
                            ELSE (@Bn * ROUND(@PrecioContractualPetroleo,2)) + 1.5
                        END

        INSERT INTO CP_MetodoCalculoHidrocarburoMes
        (
            IdContrato,
            IdTipoHidrocarburo,
            IdMetodo,
            Mes,
            Precio,
            Volumen,
            TasaRegalia,
            UrlImgRegalia,
            Valor,
			FechaCreacion,
			CreadoPor
        )
        SELECT
            @IdContrato,
            1,
            @IdMetodoCalculo,
            @Mes,
            @PrecioContractualPetroleo,
            @VolumenPetroleoEntregado,
            @Regalia,
            @UrlImgRegalia,
            @PrecioContractualPetroleo * @VolumenPetroleoEntregado,
			GETDATE(),
			@IdUsuario
    END
  ELSE
    BEGIN
        SELECT
            @An = An,
            @Bn = Bn
		FROM
            CP_ParametroRegalia
        WHERE
   Anio = YEAR( @Mes )
        SELECT
            @Regalia = CASE
                            WHEN @PrecioContractualPetroleo < @An THEN 7.5
                            ELSE (@Bn * ROUND(@PrecioContractualPetroleo,2)) + 1.5
                        END
        SELECT
            @UrlImgRegalia
            = CASE
                    WHEN @PrecioContractualPetroleo < @An THEN '~/assets/images/reg-pet-i.png'
                    ELSE '~/assets/images/reg-pet-ii.png'
                END

		UPDATE
            CP_MetodoCalculoHidrocarburoMes
            SET
            IdMetodo = @IdMetodoCalculo,
            Precio = @PrecioContractualPetroleo,
            Volumen = @VolumenPetroleoEntregado,
            TasaRegalia = @Regalia,
            UrlImgRegalia = @UrlImgRegalia,
            Valor = @PrecioContractualPetroleo * @VolumenPetroleoEntregado,
			FechaModificacion = GETDATE(),
			ModificadoPor = @IdUsuario
		WHERE
            IdContrato            = @IdContrato
            AND Mes                = @Mes
            AND IdTipoHidrocarburo = 1
    END
    -- Valores utilizados en el calculo
    GOTO FIN
    -- -----------------------------------------------------------------------------------------
    ERROR:
    -- -----------------------------------------------------------------------------------------
    RAISERROR(@MensajeError, 16, 1)
    --SELECT @MensajeError
    RETURN 1 -- Error
    -- -----------------------------------------------------------------------------------------
    FIN:
-- -----------------------------------------------------------------------------------------
END
RETURN 0
END