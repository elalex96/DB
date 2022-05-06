--Modificado por: Daniel Moreno
--Modificado El: 05/05/2022
--Descripción: Se agregan campos de temperatura periodos para que se consideren en el calculo de precio
CREATE PROC dbo.p_InsUpdCromatografiaImportacion
    @pIdCromatografia             INT OUT,
    @pIdContrato                  INT,
    @pIdPuntoEntregaContrato      INT,
    @pAnio                        SMALLINT,
    @pMes                         TINYINT,
    @pC1                          FLOAT,
    @pC2                          FLOAT,
    @pC3                          FLOAT,
    @pnC4                         FLOAT,
    @plC4                         FLOAT,
    @pnC5                         FLOAT,
    @plC5                         FLOAT,
    @pC6_plus                     FLOAT,
    @pMOL_CO2                     FLOAT,
    @pMOL_N2                      FLOAT,
    @pMOL_h2S                     FLOAT,
    @pGradosAPI                   FLOAT,
    @pAguaSedimento               FLOAT,
    @pViscosidadSSU               FLOAT,
    @pSalLBS_1000BLS              FLOAT,
    @pAzufre                      FLOAT,
    @pPresionEntrega              FLOAT,
    @pPrecioPetroleo              FLOAT,
    @pPrecioCondensado            FLOAT,
    @pPrecioGas                   FLOAT,
    @pCreadoPor                   INT,
    @pEsPetroleo                  BIT,
    @pVolumen                     FLOAT,
    @pPrecioUnitDLS               DECIMAL(12, 4),
    @PoderCalorifico              FLOAT,     --Se añadio para Poder Calorifico
    @PoderCalorificoGas           FLOAT = 0, --Se añadio para Poder Calorifico del Gas
    @pC7                          FLOAT,
    @pC8                          FLOAT,
    @pC9                          FLOAT,
    @pC10                         FLOAT,
    @pPrecioUnitarioCondensadoDLS FLOAT,
    @pVolumenCondensado           FLOAT,
	@H2O                          FLOAT, --Se añadio por ROlvera el 20190913
	@O2                           FLOAT, --Se añadio por ROlvera el 20190913
	@pTemperaturaPrecioPetroleo		FLOAT=0,
	@pTemperaturaPrecioCondensado	FLOAT=0,
	@pTemperaturaPetroleo			FLOAT=0,
	@pTemperaturaCondensado			FLOAT=0
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE
            @pIdCromatografiaValor INT,
            @IdTipoHidrocarburo    INT,
            @IdUnidad              INT,
            @IdPuntoEntrega        INT;

		----SI LAS TEMPERATURA DEL PETROLEO SON DIFERENTES		
		IF ISNULL(@pTemperaturaPetroleo,0) >0 AND  ISNULL(@pTemperaturaPrecioPetroleo,0) > 0
		BEGIN
			--SI LA TEMPERATURA DE VOL. PETROLEO ES MENOR QUE LA TEMP. PRECIO PETROLEO
			IF ISNULL(@pTemperaturaPetroleo,0) < ISNULL(@pTemperaturaPrecioPetroleo,0) 
			BEGIN
				SET @pVolumen = 
				@pTemperaturaPetroleo 
				/ 
				EXP( -(341.0957 / POWER(((141.5 / (@pGradosAPI + 131.5)) * 999.012), 2 )) * 8 * (1 + 0.8 * (341.0957 / POWER( ((141.5 / (@pGradosAPI + 131.5)) * 999.012), 2 )) * 8))
			END
			--SI LA TEMPERATURA DE VOL. PETROLEO ES MAYOR QUE LA TEMP. PRECIO PETROLEO
			IF ISNULL(@pTemperaturaPetroleo,0) > ISNULL(@pTemperaturaPrecioPetroleo,0) 
			BEGIN
				SET @pVolumen = 
				@pTemperaturaPrecioPetroleo 
				/ 
				EXP( -(341.0957 / POWER(((141.5 / (@pGradosAPI + 131.5)) * 999.012), 2 )) * 8 * (1 + 0.8 * (341.0957 / POWER( ((141.5 / (@pGradosAPI + 131.5)) * 999.012), 2 )) * 8))
			END
		END

		----SI LAS TEMPERATURA DEL CONDENSADO SON DIFERENTES		
		IF ISNULL(@pTemperaturaCondensado,0) >0 AND  ISNULL(@pTemperaturaPrecioCondensado,0) > 0
		BEGIN
			--SI LA TEMPERATURA DE VOL. PETROLEO ES MENOR QUE LA TEMP. PRECIO PETROLEO
			IF ISNULL(@pTemperaturaCondensado,0) < ISNULL(@pTemperaturaPrecioCondensado,0) 
			BEGIN
				SET @pVolumenCondensado = 
				@pTemperaturaCondensado 
				/ 
				EXP( -(341.0957 / POWER(((141.5 / (@pGradosAPI + 131.5)) * 999.012), 2 )) * 8 * (1 + 0.8 * (341.0957 / POWER( ((141.5 / (@pGradosAPI + 131.5)) * 999.012), 2 )) * 8))
			END
			--SI LA TEMPERATURA DE VOL. PETROLEO ES MAYOR QUE LA TEMP. PRECIO PETROLEO
			IF ISNULL(@pTemperaturaCondensado,0) > ISNULL(@pTemperaturaPrecioCondensado,0) 
			BEGIN
				SET @pVolumenCondensado = 
				@pTemperaturaPrecioCondensado 
				/ 
				EXP( -(341.0957 / POWER(((141.5 / (@pGradosAPI + 131.5)) * 999.012), 2 )) * 8 * (1 + 0.8 * (341.0957 / POWER( ((141.5 / (@pGradosAPI + 131.5)) * 999.012), 2 )) * 8))
			END
		END

        SELECT
            @pPrecioPetroleo   = CASE
                                     WHEN @pEsPetroleo = 1
										THEN												
										ISNULL(@pVolumen, 0) * ISNULL(@pPrecioUnitDLS, 0)
									  ELSE
                                         0
                                 END,
            @pPrecioCondensado = CASE
                                     WHEN @pEsPetroleo = 1
                                         THEN
                                         ISNULL(@pVolumenCondensado, 0) * ISNULL(@pPrecioUnitarioCondensadoDLS, 0)
                                     ELSE
                                         0
                                 END,
            @pPrecioGas        = CASE
                                     WHEN @pEsPetroleo = 1
                                         THEN
                                         0
                                     ELSE
            (ISNULL(@pVolumen, 0) * ISNULL(@pPrecioUnitDLS, 0)) * 1000
                                 END;

        SELECT
            @IdPuntoEntrega = PuntoEntregaID
        FROM
            [CO_PuntosdeEntregaContrato]
        WHERE
            PuntoEntregaContratoID = @pIdPuntoEntregaContrato;


        BEGIN TRAN;

        /***********ENCABEZADO CROMATOGRAFIA******************/
        IF NOT EXISTS
            (
                SELECT
                    1
                FROM
                    CO_Cromatografia
                WHERE
                    IdContrato = @pIdContrato
                    AND Anio = @pAnio
                    AND Mes = @pMes
            )
            BEGIN

                SELECT
                    @pIdCromatografia = ISNULL(MAX(IdCromatografia), 0) + 1
                FROM
                    CO_Cromatografia;

                INSERT INTO CO_Cromatografia
                    (
                        IdCromatografia,
                        IdContrato,
                        Anio,
                     Mes,
                        CreadoEl,
                        CreadoPor,
                        ModificadoEl,
                        ModificadoPor
                    )
                            SELECT
                                @pIdCromatografia,
                                @pIdContrato,
                                @pAnio,
                                @pMes,
                                GETDATE(),
                                @pCreadoPor,
                                NULL,
                                NULL;

                IF @@error <> 0
                    BEGIN
                        ROLLBACK TRAN;
                        GOTO fin;
                    END;

            END;
        ELSE
            BEGIN
                SELECT
                    @pIdCromatografia = IdCromatografia
                FROM
                    CO_Cromatografia
                WHERE
                    IdContrato = @pIdContrato
                    AND Anio = @pAnio
                    AND Mes = @pMes;
            END;

        /**************VALORES***********************/
        IF NOT EXISTS
            (
                SELECT
                        1
                FROM
                        [dbo].[CO_CromatografiaValores] cv
                    INNER JOIN
                        CO_Cromatografia                c
                            ON c.IdCromatografia = cv.IdCromatografia
                WHERE
                        c.IdContrato = @pIdContrato
                        AND c.Anio = @pAnio
                        AND c.Mes = @pMes
                        AND cv.[IdPuntoEntregaContrato] = @pIdPuntoEntregaContrato
            )
            BEGIN

                SELECT
                    @pIdCromatografiaValor = ISNULL(MAX(IdCromatografiaValor), 0) + 1
                FROM
                    [CO_CromatografiaValores];



                INSERT INTO [CO_CromatografiaValores]
                    (
                        IdCromatografiaValor,
                        IdCromatografia,
                        IdPuntoEntregaContrato,
                        C1,
                        C2,
                        C3,
                        nC4,
                        lC4,
                        nC5,
                        lC5,
                        C6_plus,
                        MOL_CO2,
                        MOL_N2,
                        CreadoEl,
                        CreadoPor,
                        ModificadoPor,
                        ModificadoEl,
                        [PrecioPetroleo],
                        [PrecioCondensado],
                        [PrecioGas],
                        MOL_h2S,
                        GradosAPI,
                        AguaSedimento,
                        ViscosidadSSU,
                        SalLBS_1000BLS,
                        Azufre,
                        PresionEntrega,
                        PrecioUnitarioDLS,
                        PoderCalorifico, --Se añadio para Poder Calorifico
                        PoderCalorificoGas,
                        C7,
                        C8,
                        C9,
                        C10,
                        PrecioUnitarioCondensadoDLS,
						H2O,
						O2,
						TemperaturaPrecioPetroleo,
						TemperaturaPrecioCondensado
                    )
                            SELECT
                                @pIdCromatografiaValor,
                                @pIdCromatografia,
                                @pIdPuntoEntregaContrato,
                                @pC1,
                                @pC2,
                                @pC3,
                                @pnC4,
                                @plC4,
                                @pnC5,
                               @plC5,
                                @pC6_plus,
                                @pMOL_CO2,
                                @pMOL_N2,
                                GETDATE(),
                                @pCreadoPor,
                                NULL,
                                NULL,
                                @pPrecioPetroleo,
                                @pPrecioCondensado,
                                @pPrecioGas,
                                @pMOL_h2S,
                                @pGradosAPI,
                                @pAguaSedimento,
                                @pViscosidadSSU,
                                @pSalLBS_1000BLS,
                                @pAzufre,
                                @pPresionEntrega,
                                @pPrecioUnitDLS,
                                @PoderCalorifico, --Se añadio para Poder Calorifico
                                @PoderCalorificoGas,
                                @pC7,
                                @pC8,
                                @pC9,
                                @pC10,
                                ISNULL(@pPrecioUnitarioCondensadoDLS, 0),
								@H2O,
								@O2,
								ISNULL(@pTemperaturaPrecioPetroleo,0),
								ISNULL(@pTemperaturaPrecioCondensado,0)


                IF @@error <> 0
                    BEGIN
                        ROLLBACK TRAN;
                        GOTO fin;
                    END;


            END;
        ELSE
            BEGIN

                SELECT
                        @pIdCromatografiaValor = IdCromatografiaValor,
                        @pIdCromatografia      = cv.IdCromatografia
                FROM
                        [dbo].[CO_CromatografiaValores] cv
                    INNER JOIN
                        CO_Cromatografia                c
                            ON c.IdCromatografia = cv.IdCromatografia
                WHERE
                        c.IdContrato = @pIdContrato
                        AND c.Anio = @pAnio
                        AND c.Mes = @pMes
                        AND cv.[IdPuntoEntregaContrato] = @pIdPuntoEntregaContrato;

                UPDATE
                    [CO_CromatografiaValores]
                SET
                    C1 = CASE
                             WHEN @pEsPetroleo = 0
                                 THEN
                                 @pC1
                             ELSE
                                 C1
                         END,
                    C2 = CASE
                             WHEN @pEsPetroleo = 0
                                 THEN
                                 @pC2
                             ELSE
                                 C2
                         END,
                    C3 = CASE
                             WHEN @pEsPetroleo = 0
                                 THEN
                                 @pC3
                             ELSE
                                 C3
                         END,
                    nC4 = CASE
                              WHEN @pEsPetroleo = 0
                                  THEN
                                  @pnC4
                              ELSE
                                  nC4
                          END,
                    lC4 = CASE
                              WHEN @pEsPetroleo = 0
                                  THEN
                                  @plC4
                              ELSE
                                  lC4
                          END,
                    nC5 = CASE
                              WHEN @pEsPetroleo = 0
                                  THEN
                                  @pnC5
                              ELSE
                                  nC5
                          END,
                    lC5 = CASE
                              WHEN @pEsPetroleo = 0
                                  THEN
									@plC5
                              ELSE
                                  lC5
                          END,
                    C6_plus = CASE
							 WHEN @pEsPetroleo = 0
                                      THEN
                                      @pC6_plus
                                  ELSE
                                      C6_plus
                              END,
                    C7 = CASE
                             WHEN @pEsPetroleo = 0
                                 THEN
                                 @pC7
                             ELSE
                                 C7
                         END,
                    C8 = CASE
                             WHEN @pEsPetroleo = 0
                                 THEN
                                 @pC8
                             ELSE
                                 C8
                         END,
                    C9 = CASE
                             WHEN @pEsPetroleo = 0
                                 THEN
                                 @pC9
                             ELSE
                                 C9
                         END,
                    C10 = CASE
                              WHEN @pEsPetroleo = 0
                                  THEN
                                  @pC10
                              ELSE
                                  C10
                          END,
                    MOL_CO2 = CASE
                                  WHEN @pEsPetroleo = 0
                                      THEN
                                      @pMOL_CO2
                                  ELSE
                                      MOL_CO2
                              END,
                    MOL_N2 = CASE
                                 WHEN @pEsPetroleo = 0
                                     THEN
                                     @pMOL_N2
                                 ELSE
                                     MOL_N2
                             END,
                    MOL_H2S = CASE
                                  WHEN @pEsPetroleo = 0
                                      THEN
                                      @pMOL_h2S
                                  ELSE
                                      MOL_H2S
                              END,
                    PrecioPetroleo = CASE
                                         WHEN @pEsPetroleo = 1
                                             THEN
                                             ISNULL(@pVolumen, 0) * ISNULL(@pPrecioUnitDLS, 0)
                                         ELSE
                                             PrecioPetroleo
                                     END,
                    PrecioCondensado = CASE
                                           WHEN @pEsPetroleo = 1
                                               THEN
                                               ISNULL(@pVolumenCondensado, 0)
                                               * ISNULL(@pPrecioUnitarioCondensadoDLS, 0)
                                           ELSE
                                               PrecioCondensado
                                       END,
                    PrecioGas = CASE
                                    WHEN @pEsPetroleo = 1
                                        THEN
                                        PrecioGas
                                    ELSE
                    (ISNULL(@pVolumen, 0) * ISNULL(@pPrecioUnitDLS, 0)) * 1000
                                END,
                    ModificadoEl = GETDATE(),
                    ModificadoPor = @pCreadoPor,
                    GradosAPI = CASE
                                    WHEN @pEsPetroleo = 1
                                        THEN
                                        @pGradosAPI
                                    ELSE
                    GradosAPI
                                END,
                    AguaSedimento = CASE
                                        WHEN @pEsPetroleo = 1
                                            THEN
                                            @pAguaSedimento
                                        ELSE
                                            AguaSedimento
                                    END,
                    ViscosidadSSU = CASE
                                        WHEN @pEsPetroleo = 1
                                            THEN
                                            @pViscosidadSSU
                                        ELSE
                                            ViscosidadSSU
                                    END,
                    SalLBS_1000BLS = CASE
                                         WHEN @pEsPetroleo = 1
                                             THEN
                                             @pSalLBS_1000BLS
                                         ELSE
                                             SalLBS_1000BLS
                                     END,
                    Azufre = CASE
                                 WHEN @pEsPetroleo = 1
                                     THEN
                                     @pAzufre
                                 ELSE
                                     Azufre
                             END,
                    PresionEntrega = CASE
                                         WHEN @pEsPetroleo = 1
                                             THEN
                                             @pPresionEntrega
                                         ELSE
                                             PresionEntrega
                                     END,
                    PrecioUnitarioDLS = @pPrecioUnitDLS,
                    PoderCalorifico = CASE
                                          WHEN @pEsPetroleo = 1
                                              THEN
                                              ISNULL(@PoderCalorifico, 0)
                                          ELSE
                                              PoderCalorifico
                                      END, --Se añadio para Poder Calorifico
                    PoderCalorificoGas = CASE
                                             WHEN @pEsPetroleo = 0
                                                 THEN
                                                 @PoderCalorificoGas
                                             ELSE
                                                 PoderCalorificoGas
                                         END,
                    PrecioUnitarioCondensadoDLS = ISNULL(@pPrecioUnitarioCondensadoDLS, 0),
					--Se añadio el H2o y O2 por R Olvera el 20190913
					H2O = CASE
                             WHEN @pEsPetroleo = 0
                                 THEN
                                 @H2O
                             ELSE
                                 H2O
                         END,
						 O2 = CASE
                             WHEN @pEsPetroleo = 0
                                 THEN
                                 @O2
                             ELSE
                                 O2
                         END,
					TemperaturaPrecioPetroleo = ISNULL(@pTemperaturaPrecioPetroleo,0),
					TemperaturaPrecioCondensado = ISNULL(@pTemperaturaPrecioCondensado,0)
                WHERE
                    IdCromatografiaValor = @pIdCromatografiaValor;

                IF @@error <> 0
                    BEGIN
                        ROLLBACK TRAN;
                        GOTO fin;
                    END;
            END;


        /***********PRODUCCIÓN MENSUAL PETROLEO****************/
        SELECT
            @IdTipoHidrocarburo = CASE
                                      WHEN @pEsPetroleo = 1
                                          THEN
                                          1001
                                      ELSE
                  1000
                                  END,
            @IdUnidad           = CASE
                                      WHEN @pEsPetroleo = 1
                                          THEN
                                          1001 /*BL*/
                                      ELSE
                                          1002 /*MMPC*/
                                  END;

        IF NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PR_ProduccionMensualSipac
                WHERE
                    IdContrato = @pIdContrato
                    AND DATEPART(YEAR, IdFecha) = @pAnio
                    AND DATEPART(MONTH, IdFecha) = @pMes
                    AND idHidrocarburo = @IdTipoHidrocarburo
                    AND PuntoEntregaID = @IdPuntoEntrega --@pIdPuntoEntregaContrato
            )
            BEGIN
                INSERT INTO PR_ProduccionMensualSipac
                    (
                        idFecha,
                        idHidrocarburo,
                        PuntoEntregaID,
                        VolumenProgramado,
                        GradosAPI,
                        idUnidadMedida,
                        idContrato,
                        CreadoPor,
                        CreadoEl,
                        ModificadoPor,
                        ModificadoEl,
                        Activo,
						TemperaturaPetroleo,
						TemperaturaCondensado
                    )
                            SELECT
                                CAST(CAST(@pAnio * 10000 + @pMes * 100 + 1 AS VARCHAR(255)) AS DATE),
                                @IdTipoHidrocarburo,
                                @IdPuntoEntrega,
                                @pVolumen,
                                @pGradosAPI,
                                @IdUnidad,
                                @pIdContrato,
                                @pCreadoPor,
                                GETDATE(),
                                NULL,
                                NULL,
                                1,
								isnull(@pTemperaturaPetroleo,0),
								ISNULL(@pTemperaturaCondensado,0);

                IF @@error <> 0
                    BEGIN
                        ROLLBACK TRAN;
                        GOTO fin;
                    END;

            END;
        ELSE
            BEGIN

                UPDATE
                    PR_ProduccionMensualSipac
                SET
                    VolumenProgramado = @pVolumen,
                    GradosAPI = @pGradosAPI,
                    ModificadoPor = @pCreadoPor,
                    ModificadoEl = GETDATE(),
					TemperaturaPetroleo = ISNULL(@pTemperaturaPetroleo,0),
					TemperaturaCondensado = ISNULL(@pTemperaturaCondensado,0)
                WHERE
                    IdContrato = @pIdContrato
                    AND DATEPART(YEAR, IdFecha) = @pAnio
                    AND DATEPART(MONTH, IdFecha) = @pMes
                    AND idHidrocarburo = @IdTipoHidrocarburo
                    AND PuntoEntregaID = @IdPuntoEntrega;

                IF @@error <> 0
                    BEGIN
                        ROLLBACK TRAN;
                        GOTO fin;
                    END;
            END;


        /**************************************************************/



        /***********PRODUCCIÓN MENSUAL CONDENSADO****************/
        IF (
               @pVolumenCondensado > 0
               AND @pEsPetroleo = 1
           )
            BEGIN
                SELECT
                    @IdTipoHidrocarburo = 1002, --CONDENSADO,
                    @IdUnidad           = 1001; /*BL*/

                IF NOT EXISTS
                    (
                        SELECT
                            1
                        FROM
                            PR_ProduccionMensualSipac
                        WHERE
                            IdContrato = @pIdContrato
                            AND DATEPART(YEAR, IdFecha) = @pAnio
                            AND DATEPART(MONTH, IdFecha) = @pMes
                            AND idHidrocarburo = @IdTipoHidrocarburo
                            AND PuntoEntregaID = @IdPuntoEntrega --@pIdPuntoEntregaContrato
                    )
                    BEGIN
                        INSERT INTO PR_ProduccionMensualSipac
                            (
                                idFecha,
                                idHidrocarburo,
                                PuntoEntregaID,
                                VolumenProgramado,
                                GradosAPI,
                                idUnidadMedida,
                                idContrato,
                                CreadoPor,
                                CreadoEl,
                                ModificadoPor,
                               ModificadoEl,
                                Activo,
								TemperaturaPetroleo,
								TemperaturaCondensado

                            )
                                    SELECT
                                        CAST(CAST(@pAnio * 10000 + @pMes * 100 + 1 AS VARCHAR(255)) AS DATE),
                                        @IdTipoHidrocarburo,
                                        @IdPuntoEntrega,
                                        @pVolumenCondensado,
                                        @pGradosAPI,
                                        @IdUnidad,
                                        @pIdContrato,
                                        @pCreadoPor,
                                        GETDATE(),
                                        NULL,
                                        NULL,
                                        1,
										isnull(@pTemperaturaPetroleo,0),
										ISNULL(@pTemperaturaCondensado,0)

                        IF @@error <> 0
                            BEGIN
                                ROLLBACK TRAN;
                                GOTO fin;
                            END;

                    END;
                ELSE
                    BEGIN
                        UPDATE
                            PR_ProduccionMensualSipac
                        SET
                            VolumenProgramado = @pVolumenCondensado,
                            GradosAPI = @pGradosAPI,
                            ModificadoPor = @pCreadoPor,
                            ModificadoEl = GETDATE(),
							TemperaturaPetroleo = ISNULL(@pTemperaturaPetroleo,0),
							TemperaturaCondensado = ISNULL(@pTemperaturaCondensado,0)
                        WHERE
                            IdContrato = @pIdContrato
                            AND DATEPART(YEAR, IdFecha) = @pAnio
                            AND DATEPART(MONTH, IdFecha) = @pMes
                            AND idHidrocarburo = @IdTipoHidrocarburo
                            AND PuntoEntregaID = @IdPuntoEntrega;

                        IF @@error <> 0
                            BEGIN
                                ROLLBACK TRAN;
                                GOTO fin;
                            END;
                    END;

            END;
        ELSE
            BEGIN
                IF (
                       @pVolumenCondensado = 0
                       AND @pEsPetroleo = 1
                   )
                    BEGIN
                        DELETE FROM
                        PR_ProduccionMensualSipac
                        WHERE
                            IdContrato = @pIdContrato
                            AND DATEPART(YEAR, IdFecha) = @pAnio
                            AND DATEPART(MONTH, IdFecha) = @pMes
                            AND idHidrocarburo = 1002
                            AND PuntoEntregaID = @IdPuntoEntrega;
                        IF @@error <> 0
                            BEGIN
                                ROLLBACK TRAN;
                                GOTO fin;
                            END;
                    END;
            END;

        /**************************************************************/
        COMMIT TRAN;
        fin:

    END;



