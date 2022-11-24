CREATE PROCEDURE dbo.sp_CP_CalculaPrecioContractualGasNaturalLicencia_Validacion
    @IdContrato INT = 0,
    @Mes        DATE
AS
BEGIN
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2017
-- Description:	Calculo precio PRODUCCION COMPARTIDA GAS
-- =============================================
-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
SET NOCOUNT ON
-- Precio Contractual del Gas 
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
CREATE TABLE #VolumenEntregado
(
    tipohidrocarburo INT,
    VolumenEntregado INT,
    PRIMARY KEY (tipohidrocarburo)
)

CREATE TABLE #VolumenComercializado
(
    tipohidrocarburo      INT,
    VolumenComercializado INT,
    PRIMARY KEY (tipohidrocarburo)
)

CREATE TABLE #PrecioContractual
(
    tipohidrocarburo  INT,
    PrecioContractual DECIMAL (9, 4),
	Regalia		DECIMAL (9, 6),
    PRIMARY KEY (tipohidrocarburo)
)

CREATE TABLE #VolumenProduccionT1T2
(
    tipohidrocarburo  INT,
    VolumenProduccion DECIMAL(12,4),
    PRIMARY KEY (tipohidrocarburo)
)

CREATE TABLE #SumValorContractual
(
    tipohidrocarburo    INT,
    SumValorContractual MONEY,
    PRIMARY KEY (tipohidrocarburo)
)

CREATE TABLE #PrecioObservado
(
    tipohidrocarburo INT,
    PrecioObservado  MONEY,
    PRIMARY KEY (tipohidrocarburo)
)

-- Variables
DECLARE
    @SumValor                               MONEY,
    @VolumenProduccionT1T2                  DECIMAL(12,4),
    @Metodo                                 VARCHAR (1),
    @MensajeError                           VARCHAR (255), -- Mensaje de Error
    @NumError                               INT, -- Número de Error
    @IdMetodoCalculo                        INT,
    @VolumenComercializado                  INT,
    @PrecioObservadoGases                   MONEY,
    @PrecioContractualGases                 MONEY,
    @VolumenComercializadoBaseReglasMercado DECIMAL(12,4),
    @VolumenGasesEntregado                  DECIMAL(12,4),
	@Cn										FLOAT,
	@Dn										FLOAT,
	@En										FLOAT,
	@Fn										FLOAT

-- Volumen Producido en el Periodo
INSERT INTO #VolumenEntregado
(
    tipohidrocarburo,
    VolumenEntregado
)
SELECT
    CASE
            WHEN Hidrocarburo = 'MetanoC1' THEN 3
            WHEN Hidrocarburo = 'EtanoC2' THEN 4
            WHEN Hidrocarburo = 'PropanoC3' THEN 5
            WHEN Hidrocarburo = 'ButanoC4' THEN 6
    END,
    ROUND( Volumen, 0 )
	--CONVERT (DECIMAL(14,2), Volumen)
    FROM
    (
        SELECT
            IdContrato,
            MesReporte,
            MetanoC1,
            EtanoC2,
            PropanoC3,
            ButanoC4
		FROM
            PR_VolumenMensualProduccionPetroleo
        WHERE
            IdContrato    = @IdContrato
            AND MesReporte = @Mes
    ) p UNPIVOT(Volumen FOR Hidrocarburo IN(MetanoC1, EtanoC2, PropanoC3, ButanoC4)) AS unpvt

-- Verificamos que no haya ocurrido ningun Error
SELECT
    @NumError = @@ERROR
IF @NumError <> 0
    BEGIN
        SELECT
            @MensajeError
            = 'Error al obtener el Volumen Entregado'
                + 'En el Stored Procedure: dbo.sp_CP_CalculaPrecioContractualGasNaturalLicencia '
                + 'Núm. Error en SQL Server:' + CHAR( 9 ) + LTRIM( STR( @NumError, 10, 0 ))
        GOTO ERROR
    END -- IF @NumError <> 0

SELECT
    @Metodo          = 'B',
    @IdMetodoCalculo = 1

-- Volumen Comercializado en Base a Reglas de Mercado
INSERT INTO #VolumenComercializado
(
    tipohidrocarburo,
    VolumenComercializado
)
SELECT --@VolumenComercializadoBaseReglasMercado = SUM(VolumenVendido)
    TH.TipoHidrocarburo,
    --SUM (VolumenVendido)
	SUM( ROUND( VolumenVendido, 0 ))
FROM
    COM_OperacionComercializacion AS OP
JOIN
    CO_TipoHidrocarburo           AS TH
    ON OP.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
WHERE
    TH.TipoHidrocarburo IN ( 3, 4, 5, 6 )
    AND OP.MesReporte                 = @Mes
    AND OP.IdContrato             = @IdContrato
    AND OP.OperacionBajoReglasMercado = 1
GROUP BY
    TH.TipoHidrocarburo

-- Verificamos que no haya ocurrido ningun Error
SELECT
    @NumError = @@ERROR
IF @NumError <> 0
    BEGIN
        SELECT
            @MensajeError
            = 'Error al obtener el Volumen Comercializado'
                + 'En el Stored Procedure: dbo.sp_CP_CalculaPrecioContractualGasNaturalLicencia '
                + 'Núm. Error en SQL Server:' + CHAR( 9 ) + LTRIM( STR( @NumError, 10, 0 ))
        GOTO ERROR
    END -- IF @NumError <> 0

--OBTENEMOS EL VOLUMEN TOTAL DE TODOS LOS DERIVADOS DEL GAS
SELECT
    @VolumenComercializadoBaseReglasMercado = SUM (VolumenComercializado) --SUM( ROUND( VolumenComercializado, 0 ))
FROM
    #VolumenComercializado

SELECT
    @VolumenGasesEntregado = SUM (VolumenEntregado) --SUM( ROUND( VolumenEntregado, 0 ))
FROM
    #VolumenEntregado

IF @VolumenGasesEntregado = 0 AND @VolumenComercializadoBaseReglasMercado > 0
    GOTO INCISOA

-- Inciso B) Si al menos el 50% de la comercializacion fue en Base Reglas de Mercado
IF (@VolumenComercializadoBaseReglasMercado * 100) / @VolumenGasesEntregado >= 50
    BEGIN
        INCISOA:
        INSERT INTO #PrecioContractual
        (
            tipohidrocarburo,
            PrecioContractual
        )
        SELECT --@PrecioContractualGases = SUM(PrecioVentaUnitario * CONVERT( DECIMAL(14, 0), VolumenVendido) / @VolumenComercializadoBaseReglasMercado)
            TH.TipoHidrocarburo,
            SUM( CONVERT( DECIMAL (18, 4), (OP.PrecioVentaUnitario - OP.CostoUnitarioComercializacion))
                    * ROUND( OP.VolumenVendido, 0 ) / VC.VolumenComercializado
                )
			--SUM( CONVERT( DECIMAL (18, 4), (OP.PrecioVentaUnitario - OP.CostoUnitarioComercializacion))
   --                 * CONVERT( DECIMAL (12, 4), OP.VolumenVendido ) / VC.VolumenComercializado
   --             )
		FROM
            COM_OperacionComercializacion AS OP
        JOIN
            CO_TipoHidrocarburo           AS TH
            ON OP.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
        JOIN
            #VolumenComercializado        VC
            ON TH.TipoHidrocarburo   = VC.tipohidrocarburo
        WHERE
            TH.TipoHidrocarburo IN ( 3, 4, 5, 6 )
            AND OP.MesReporte                 = @Mes
            AND OP.IdContrato                 = @IdContrato
            AND OP.OperacionBajoReglasMercado = 1
        GROUP BY
            TH.TipoHidrocarburo

        SELECT
            @PrecioContractualGases = AVG( PrecioContractual )
		FROM
            #PrecioContractual

        -- DETERMINAR SI NO ES EL PRIMER MES DEL CONTRATO 
        -- SI NO ES EL PRIMER MES SE VALIDA COMO FUE EL CALCULO DE LOS MESES ANTERIORES
        IF 0 = (SELECT  COUNT( 1 )
                FROM	CO_Contrato
                WHERE
                IdContrato                 = @IdContrato
                AND YEAR( InicioVigencia )  = YEAR( @Mes )
                AND MONTH( InicioVigencia ) = MONTH( @Mes )
        )
            BEGIN
                IF 0 < (   SELECT COUNT( 1 )
                        FROM     CP_MetodoCalculoHidrocarburoMes
                        WHERE    IdContrato      = @IdContrato
                        AND YEAR( Mes )  = YEAR( DATEADD( MONTH, -1, @Mes ))
                        AND MONTH( Mes ) = MONTH( DATEADD( MONTH, -1, @Mes ))
                        AND IdTipoHidrocarburo IN ( 3, 4, 5, 6 )
                        AND IdMetodo IN ( 2, 3 )
                )
                OR 0 < (SELECT  COUNT( 1 )
                        FROM   CP_MetodoCalculoHidrocarburoMes
                        WHERE	IdContrato      = @IdContrato
                        AND YEAR( Mes )  = YEAR( DATEADD( MONTH, -1, @Mes ))
                        AND MONTH( Mes ) = MONTH( DATEADD( MONTH, -1, @Mes ))
                        AND IdTipoHidrocarburo IN ( 3, 4, 5, 6 )
                        AND IdMetodo IN ( 2, 3 )
                )
                AND 0 < (   SELECT	COUNT( 1 )
                        FROM	CP_MetodoCalculoHidrocarburoMes
						WHERE	IdContrato      = @IdContrato
                        AND YEAR( Mes )  = YEAR( DATEADD( MONTH, -2, @Mes ))
						AND MONTH( Mes ) = MONTH( DATEADD( MONTH, -2, @Mes ))
                        AND IdTipoHidrocarburo IN ( 3, 4, 5, 6 )
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
                            AND IdTipoHidrocarburo IN ( 3, 4, 5, 6 )
                            AND IdMetodo IN ( 2, 3 )
                    )
                    BEGIN
                        -- Volumen produccion del GAS en el punto en los periodos t, t-1 y t-2
                        INSERT INTO #VolumenProduccionT1T2
                        (
                            tipohidrocarburo,
                            VolumenProduccion
                        )
                        SELECT
                            CASE
                                    WHEN Hidrocarburo = 'MetanoC1' THEN 3
                                    WHEN Hidrocarburo = 'EtanoC2' THEN 4
                                    WHEN Hidrocarburo = 'PropanoC3' THEN 5
                                    WHEN Hidrocarburo = 'ButanoC4' THEN 6
                            END,
                            SUM( ROUND( Volumen, 0 ))
							--SUM( Volumen)
                            FROM
                            (
                                SELECT
                                    IdContrato,
                                    MesReporte,
                                    MetanoC1,
                                    EtanoC2,
                                    PropanoC3,
                                    ButanoC4
								FROM
                                    PR_VolumenMensualProduccionPetroleo
                                WHERE
                                    IdContrato = @IdContrato
                                    AND MesReporte BETWEEN DATEADD( MONTH, -2, @Mes ) AND @Mes
                            ) p UNPIVOT(Volumen FOR Hidrocarburo IN(MetanoC1, EtanoC2, PropanoC3, ButanoC4)) AS unpvt
                            GROUP BY
                            CASE
                                    WHEN Hidrocarburo = 'MetanoC1' THEN 3
                                    WHEN Hidrocarburo = 'EtanoC2' THEN 4
                                    WHEN Hidrocarburo = 'PropanoC3' THEN 5
                                    WHEN Hidrocarburo = 'ButanoC4' THEN 6
                            END

                        INSERT INTO #SumValorContractual
                        (
                            tipohidrocarburo,
                            SumValorContractual
                        )
                        SELECT
                            VP.tipohidrocarburo,
                            SUM( VP.VolumenProduccion * MCH.Precio )
                            FROM
                            #VolumenProduccionT1T2          VP
                            JOIN
                            CP_MetodoCalculoHidrocarburoMes MCH
                            ON VP.tipohidrocarburo = MCH.IdTipoHidrocarburo
                            AND MCH.IdContrato      = @IdContrato
                     AND MCH.Mes BETWEEN DATEADD( MONTH, -2, @Mes ) AND DATEADD( MONTH, -1, @Mes )
                            GROUP BY
                            VP.tipohidrocarburo

                    END
                    ELSE
                    BEGIN
                        -- Volumen produccion de los condensados en el punto en los periodos t, t-1
                        INSERT INTO #VolumenProduccionT1T2
                        (
                            tipohidrocarburo,
                            VolumenProduccion
                        )
                        SELECT
                            CASE
                                    WHEN Hidrocarburo = 'MetanoC1' THEN 3
                                    WHEN Hidrocarburo = 'EtanoC2' THEN 4
                                    WHEN Hidrocarburo = 'PropanoC3' THEN 5
                                    WHEN Hidrocarburo = 'ButanoC4' THEN 6
                            END,
                            --SUM( ROUND( Volumen, 0 ))
							SUM( CONVERT(DECIMAL(14,2), Volumen ))
                            FROM
                            (
                                SELECT
                                    IdContrato,
                                    MesReporte,
                                    MetanoC1,
                                    EtanoC2,
                                    PropanoC3,
                                    ButanoC4
                                    FROM
                                    PR_VolumenMensualProduccionPetroleo
                                    WHERE
                                    IdContrato = @IdContrato
                                    AND MesReporte BETWEEN DATEADD( MONTH, -1, @Mes ) AND @Mes
                            ) p UNPIVOT(Volumen FOR Hidrocarburo IN(MetanoC1, EtanoC2, PropanoC3, ButanoC4)) AS unpvt
                            GROUP BY
                            CASE
                                    WHEN Hidrocarburo = 'MetanoC1' THEN 3
                                    WHEN Hidrocarburo = 'EtanoC2' THEN 4
                                    WHEN Hidrocarburo = 'PropanoC3' THEN 5
                                    WHEN Hidrocarburo = 'ButanoC4' THEN 6
                            END

                        INSERT INTO #SumValorContractual
                        (
                            tipohidrocarburo,
                            SumValorContractual
                        )
                        SELECT
                            VP.tipohidrocarburo,
                            SUM( VP.VolumenProduccion * MCH.Precio )
                            FROM
                            #VolumenProduccionT1T2          VP
                            JOIN
                            CP_MetodoCalculoHidrocarburoMes MCH
                            ON VP.tipohidrocarburo = MCH.IdTipoHidrocarburo
                            AND MCH.IdContrato      = @IdContrato
                            AND MCH.Mes             = DATEADD( MONTH, -1, @Mes )
                            GROUP BY
                            VP.tipohidrocarburo

                    END

                    -- Guardamos el precio observado para validar la diferencia con el calculado
                    INSERT INTO #PrecioObservado
                    (
                        tipohidrocarburo,
                        PrecioObservado
                    )
                    SELECT
                        tipohidrocarburo,
                        PrecioContractual
                        FROM
                        #PrecioContractual

                    -- BORRAMOS LA TABLA PARA GUARDAR EL NUEVO PRECIO CALCULADO
                    DELETE	#PrecioContractual

                    -- ( PRECIO COMERCIALIZACION * SUM VP - SUM VC ) / VP
                    INSERT INTO #PrecioContractual
                    (
                        tipohidrocarburo,
                        PrecioContractual
                    )
                    SELECT
                        PC.tipohidrocarburo,
                        (PC.PrecioContractual * VPT12.VolumenProduccion - SUMVC.SumValorContractual)
                        / VE.VolumenEntregado
                        FROM
                        #PrecioContractual     PC
                        JOIN
                        #VolumenProduccionT1T2 VPT12
                       ON PC.tipohidrocarburo    = VPT12.tipohidrocarburo
       JOIN
                        #SumValorContractual   SUMVC
                        ON VPT12.tipohidrocarburo = SUMVC.tipohidrocarburo
                        JOIN
                        #VolumenEntregado      VE
                        ON SUMVC.tipohidrocarburo = VE.tipohidrocarburo

                    --SELECT @PrecioContractualGases = (@PrecioContractualGases * @VolumenProduccionT1T2 - @SumValor) / @VolumenGasesEntregado
                    SELECT
                        @PrecioContractualGases = AVG( PrecioContractual )
                        FROM
                        #PrecioContractual

                    SELECT
                        @PrecioObservadoGases = AVG( PrecioObservado )
                        FROM
                        #PrecioObservado

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

                            UPDATE	PC
                                SET
                                PrecioContractual = PrecioObservado * 1.5
                                FROM
                                #PrecioContractual PC
                                JOIN
                                #PrecioObservado   PO
                                ON PC.tipohidrocarburo = PO.tipohidrocarburo
                        END	--IF @PrecioContractualGases > @PrecioObservadoGases
                        -- SI EL PRECIO ESTIMADO ES MENOR AL OBSERVADO
                        IF @PrecioContractualGases < @PrecioObservadoGases
                        BEGIN
                            SELECT
                                @PrecioContractualGases = @PrecioObservadoGases * 0.5,
                                @Metodo                 = '2',
                                @IdMetodoCalculo        = 6

                            UPDATE	PC
                                SET	PrecioContractual = PrecioObservado * 0.5
                            FROM
                                #PrecioContractual PC
                            JOIN
                                #PrecioObservado   PO
                                ON PC.tipohidrocarburo = PO.tipohidrocarburo
                        END	-- IF @PrecioContractualGases < @PrecioObservadoGases
                    END
                END
            END
        SELECT
            CASE
                    WHEN @Metodo = 'B' THEN 'a) Promedio Ponderado'
                    WHEN @Metodo = 'C' THEN 'C) Penalizacion'
                    WHEN @Metodo = 'i' THEN 'C) Penalizacion i'
                    WHEN @Metodo = '2' THEN 'C) Penalizacion ii'
            END                                                    AS Metodo,
            --@VolumenGasesEntregado AS VolumenEntregado,
            VE.VolumenEntregado               AS VolumenEntregado,
            --@VolumenComercializadoBaseReglasMercado AS VolumenComercializadoBaseReglasMercado,
            VC.VolumenComercializado                               AS VolumenComercializadoBaseReglasMercado,
            --(@VolumenComercializadoBaseReglasMercado * 100) / @VolumenGasesEntregado AS PorcentajeComercializado,
            CASE WHEN VE.VolumenEntregado = 0 THEN 0
			ELSE (VC.VolumenComercializado * 100) / VE.VolumenEntregado END  AS PorcentajeComercializado,
            PrecioContractual                                      AS PrecioContractualPetroleo
            --                @PrecioContractualGases AS PrecioContractualPetroleo
            FROM
            #PrecioContractual     PC
            JOIN
            #VolumenEntregado      VE
            ON PC.tipohidrocarburo = VE.tipohidrocarburo
            JOIN
            #VolumenComercializado VC
            ON PC.tipohidrocarburo = VC.tipohidrocarburo
    END
ELSE
    BEGIN
        -- VALIDAMOS SI EXISTEN COMERCIALIZACIONES DEL GAS
        IF 0 <   (  SELECT SUM( VolumenComercializado ) FROM #VolumenComercializado    )
        BEGIN
            INSERT INTO #PrecioContractual
            (
                tipohidrocarburo,
                PrecioContractual
            )
            SELECT --@PrecioContractualGases = SUM(PrecioVentaUnitario * CONVERT( DECIMAL(14, 0), VolumenVendido) / @VolumenComercializadoBaseReglasMercado)
                TH.TipoHidrocarburo,
                SUM( CONVERT( DECIMAL (18, 4), (OP.PrecioVentaUnitario - OP.CostoUnitarioComercializacion))
                        * ROUND( OP.VolumenVendido, 0 ) / VC.VolumenComercializado
                    )
				--SUM( CONVERT( DECIMAL (18, 4), (OP.PrecioVentaUnitario - OP.CostoUnitarioComercializacion))
    --                    * CONVERT( DECIMAL (18, 4),OP.VolumenVendido ) / VC.VolumenComercializado
    --                )
                FROM
                COM_OperacionComercializacion AS OP
                JOIN
                CO_TipoHidrocarburo           AS TH
                ON OP.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
                JOIN
                #VolumenComercializado        VC
                ON TH.TipoHidrocarburo   = VC.tipohidrocarburo
                WHERE
                TH.TipoHidrocarburo IN ( 3, 4, 5, 6 )
                AND OP.MesReporte                 = @Mes
                AND OP.IdContrato                 = @IdContrato
                AND OP.OperacionBajoReglasMercado = 1
                GROUP BY
                TH.TipoHidrocarburo

            SELECT
                @PrecioContractualGases = AVG( PrecioContractual )
                FROM
                #PrecioContractual

            SELECT   @IdMetodoCalculo = 7
            SELECT
                'c) Promedio Ponderado con Comercializacion < 50%'     AS Metodo,
                --@VolumenGasesEntregado AS VolumenEntregado,
                VE.VolumenEntregado                                    AS VolumenEntregado,
                --@VolumenComercializadoBaseReglasMercado AS VolumenComercializadoBaseReglasMercado,
                VC.VolumenComercializado                               AS VolumenComercializadoBaseReglasMercado,
                --(@VolumenComercializadoBaseReglasMercado * 100) / @VolumenGasesEntregado AS PorcentajeComercializado,
                (VC.VolumenComercializado * 100) / VE.VolumenEntregado AS PorcentajeComercializado,
                --@PrecioContractualGases AS PrecioContractualPetroleo
                PrecioContractual                                      AS PrecioContractualPetroleo
                --                @PrecioContractualGases AS PrecioContractualPetroleo
			FROM
                #PrecioContractual     PC
            JOIN
                #VolumenEntregado      VE
                ON PC.tipohidrocarburo = VE.tipohidrocarburo
            JOIN
                #VolumenComercializado VC
                ON PC.tipohidrocarburo = VC.tipohidrocarburo
        END
        ELSE
            BEGIN
                -- Comercializacion fuera de las reglas del mercado
                DELETE
                #VolumenComercializado

                INSERT INTO #VolumenComercializado
                (
                    tipohidrocarburo,
                    VolumenComercializado
                )
                SELECT
                    TH.TipoHidrocarburo,
                    --SUM( ROUND( VolumenVendido, 0 ))
					SUM(  VolumenVendido)
                    FROM
                    COM_OperacionComercializacion AS OP
                    JOIN
                    CO_TipoHidrocarburo           AS TH
					ON OP.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
                    WHERE
                    TH.TipoHidrocarburo IN ( 3, 4, 5, 6 )
                    AND OP.MesReporte                 = @Mes
                    AND OP.IdContrato                 = @IdContrato
                    AND OP.OperacionBajoReglasMercado = 0
                    GROUP BY
                    TH.TipoHidrocarburo

                -- IF TEMPORAL POR SI NO SE COMERCIALIZO
                IF 0 =
                (
                    SELECT COUNT( 1 ) FROM #VolumenComercializado
                )
                    BEGIN
                        INSERT INTO #VolumenComercializado
                        (
                            tipohidrocarburo,
                            VolumenComercializado
                        )
                        SELECT
                            TH.TipoHidrocarburo,
                            SUM( ROUND( VolumenVendido, 0 ))
							--SUM( VolumenVendido)
                            FROM
                            COM_OperacionComercializacion AS OP
                            JOIN
                            CO_TipoHidrocarburo           AS TH
                            ON OP.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
                            WHERE
                            TH.TipoHidrocarburo IN ( 3, 4, 5, 6 )
                            AND OP.MesReporte                 = @Mes
                            AND OP.IdContrato                 = @IdContrato
                            AND OP.OperacionBajoReglasMercado = 1
                            GROUP BY
                            TH.TipoHidrocarburo
                    END

                INSERT INTO #PrecioContractual
                (
                    tipohidrocarburo,
                    PrecioContractual
                )
                SELECT
                    VC.tipohidrocarburo,
                    SUM( CONVERT( DECIMAL (18, 6), Gases.Precio ) * ROUND( OC.VolumenVendido, 0 )
                            / VC.VolumenComercializado     )
					--SUM( CONVERT( DECIMAL (18, 6), Gases.Precio ) * CONVERT( DECIMAL (18, 4), OC.VolumenVendido)
     --                       / VC.VolumenComercializado     )
                    FROM
                    #VolumenComercializado        VC
                    JOIN
                    CO_Marcador                   M
                    ON VC.tipohidrocarburo   = M.TipoHidrocarburo
                    JOIN
                    CO_PrecioMarcadorDiario       Gases
                    ON M.IdMarcador          = Gases.IdMarcador
                    AND Gases.IdContrato      = @IdContrato
                    JOIN
                    COM_OperacionComercializacion OC
                    ON Gases.IdContrato      = OC.IdContrato
                    AND Gases.Mes             = OC.FechaTransaccion
                    JOIN
                    CO_TipoHidrocarburo           AS TH
                    ON OC.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
                    AND M.TipoHidrocarburo    = TH.TipoHidrocarburo
                    WHERE
                    Gases.IdContrato = @IdContrato
                    AND OC.MesReporte = @Mes
                    GROUP BY
                    VC.tipohidrocarburo

                SELECT
                    @IdMetodoCalculo = 3
                SELECT
                    'b) Formula comercializacion < 50%'                    AS Metodo,
                    VE.VolumenEntregado                                    AS VolumenEntregado,
                    VC.VolumenComercializado                               AS VolumenComercializadoBaseReglasMercado,
                    CASE WHEN VE.VolumenEntregado = 0 THEN 0
					ELSE (VC.VolumenComercializado * 100) / VE.VolumenEntregado END AS PorcentajeComercializado,
                    PrecioContractual                                      AS PrecioContractualPetroleo
				FROM
                    #PrecioContractual     PC
                JOIN
                    #VolumenEntregado      VE
                    ON PC.tipohidrocarburo = VE.tipohidrocarburo
                JOIN
                    #VolumenComercializado VC
                    ON PC.tipohidrocarburo = VC.tipohidrocarburo
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
		UPDATE	#PrecioContractual
			SET	Regalia	=	(ROUND(PrecioContractual,2,2) / @Cn)*100
END
-- SI ES GAS NO ASOCIADO:
ELSE
BEGIN
	UPDATE	#PrecioContractual
		SET	Regalia	=	CASE WHEN PrecioContractual <= @Dn 
								THEN 0
							WHEN PrecioContractual > @Dn AND PrecioContractual < @En
								THEN (((ROUND(PrecioContractual,2,2) - @Dn) * 60.5)/ROUND(PrecioContractual,2,2) )
							WHEN PrecioContractual >= @En
								THEN (ROUND(PrecioContractual,2,2) / @Fn)*100
						END             
END

/*
-- SE ACTUALIZAN LOS VALORES YA EXISTENTES
UPDATE    MC
    SET
    IdMetodo = @IdMetodoCalculo,
    Precio = PC.PrecioContractual,
    Volumen = VE.VolumenEntregado,
	Valor	=	CONVERT(DECIMAL(16,2),PrecioContractual * VE.VolumenEntregado),
	TasaRegalia	=	PC.Regalia
FROM
    CP_MetodoCalculoHidrocarburoMes MC
JOIN
    #PrecioContractual              PC
    ON MC.IdContrato         = @IdContrato
    AND MC.Mes                = @Mes
    AND MC.IdTipoHidrocarburo = PC.tipohidrocarburo
JOIN
    #VolumenEntregado               VE
    ON PC.tipohidrocarburo   = VE.tipohidrocarburo

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
	TasaRegalia
)
*/
SELECT
    @IdContrato	AS IdContrato,
    PC.tipohidrocarburo,
    @IdMetodoCalculo AS IdMetodoCalculo,
    @Mes AS Mes,
    PC.PrecioContractual,
    VE.VolumenEntregado,
	CONVERT(DECIMAL(16,4),PrecioContractual * VE.VolumenEntregado) AS ValorHidrocarburos,
	PC.Regalia
--	CONVERT(DECIMAL(7,6), PC.Regalia/100) AS RegaliaDecimal,
--	CONVERT(DECIMAL(7,6), PC.Regalia/100) * CONVERT(DECIMAL(16,2),PrecioContractual * VE.VolumenEntregado) AS [MontoRegalia]
FROM
    #PrecioContractual              PC
JOIN
    #VolumenEntregado               VE
    ON PC.tipohidrocarburo = VE.tipohidrocarburo
--LEFT JOIN
--    CP_MetodoCalculoHidrocarburoMes MCHM
--    ON @IdContrato         = MCHM.IdContrato
--	AND	@Mes				=	MCHM.Mes
--    AND PC.tipohidrocarburo = MCHM.IdTipoHidrocarburo
--WHERE
--    MCHM.IdTipoHidrocarburo IS NULL


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
