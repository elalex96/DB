CREATE  PROCEDURE dbo.P_CO_CromatografiaImportacionResultado --'50'
 @pIdsCromatografia VARCHAR(100)
AS
    BEGIN
        ----------------------------------------------------------------
        --Modificado por: Reyna Olvera
        --Fecha 20180817
        --Comentarios: para que muestre el poder calorifico en el grid
        ----------------------------------------------------------------
        SET NOCOUNT ON;

        SELECT
            id = splitdata
        INTO
            #tmpCromatogarfias
        FROM
            [dbo].[fnSplitString](@pIdsCromatografia, ',')
        GROUP BY
            splitdata;

        SELECT
                Contrato          = co.NumeroContrato,
                AreaContractual   = ac.Descripcion,
                PuntoEntrega      = pe.Nombre,
                Anio              = c.Anio,
                Mes               = CASE
                                        WHEN c.Mes = 1
                                            THEN
                                            'Enero'
                                        WHEN c.Mes = 2
                                            THEN
                                            'Febrero'
                                        WHEN c.Mes = 3
                                            THEN
                                            'Marzo'
                                        WHEN c.Mes = 4
                                            THEN
                                            'Abril'
                                        WHEN c.Mes = 5
                                            THEN
                                            'Mayo'
                                        WHEN c.Mes = 6
                                            THEN
                                            'Junio'
                                        WHEN c.Mes = 7
                                            THEN
                                            'Julio'
                                        WHEN c.Mes = 8
                                            THEN
                                            'Agosto'
                                        WHEN c.Mes = 9
                                            THEN
                                            'Septiembre'
                                        WHEN c.Mes = 10
                                            THEN
                                            'Octubre'
                                        WHEN c.Mes = 11
                                            THEN
                                            'Noviembre'
                                        WHEN c.Mes = 12
                                            THEN
                                            'Diciembre'
                                    END,
                C1,
                C2,
                C3,
                nC4,
                lC4,
                nC5,
                lC5,
                C6_plus,
                C7                = ISNULL(C7, 0),
                C8                = ISNULL(C8, 0),
                C9                = ISNULL(C9, 0),
                C10               = ISNULL(C10, 0),
                MOL_CO2,
                MOL_N2,
                MOL_h2S,
                cv.GradosAPI,
                AguaSedimento,
                ViscosidadSSU,
                SalLBS_1000BLS,
                Azufre,
                PresionEntrega,
                PrecioPetroleo,
                PrecioCondensado,
                PrecioGas,
                PoderCalorifico,
                PoderCalorificoGas,
                Mensaje           = CASE
                                        WHEN cv.ModificadoPor > 0
                                            THEN
                                            'Valores Actualizados'
                                        ELSE
											'Valores Insertados'
                END,
                FechaUltimoCambio = CASE
                                        WHEN cv.ModificadoEl IS NOT NULL
                                            THEN
                                            cv.ModificadoEl
                                        ELSE
                                            cv.CreadoEl
                                    END,
                c.CreadoEl,
                --cv.PrecioUnitarioDLS,
                cv.PrecioUnitarioCondensadoDLS,
                CASE
                    WHEN ISNULL(PMS.VolumenProgramado, 0) = 0
                        THEN
                        0
                    ELSE
                        PrecioPetroleo / PMS.VolumenProgramado
                END               AS PrecioUnitarioDLS,
				--PMSG.VolumenProgramado,cv.PrecioGas ,
                CASE
                    WHEN ISNULL(PMSG.VolumenProgramado, 0) = 0
                        THEN
                        0
                    ELSE
                        cv.PrecioGas / PMSG.VolumenProgramado / 1000
                END               AS PrecioUnitarioGas,
				cv.H2O,
				cv.O2,
				cv.TemperaturaPrecioPetroleo,
				cv.TemperaturaPrecioCondensado
        FROM
                CO_Cromatografia                   c
            INNER JOIN
                CO_CromatografiaValores            cv
                    ON cv.IdCromatografia = c.IdCromatografia
            INNER JOIN
                CO_Contrato                        co
                    ON co.IdContrato = c.IdContrato
            INNER JOIN
                CO_AreaContractual                 ac
                    ON ac.IdAreaContractual = co.IdAreaContractual
            INNER JOIN
                [dbo].[CO_PuntosdeEntregaContrato] pec
                    ON pec.[PuntoEntregaContratoID] = cv.IdPuntoEntregaContrato
            INNER JOIN
                [dbo].[CO_PuntosdeEntrega]         pe
                    ON pe.PuntoEntregaID = pec.PuntoEntregaID
            INNER JOIN
                #tmpCromatogarfias                 tmp
                    ON tmp.id = c.IdCromatografia
            LEFT JOIN
                PR_ProduccionMensualSipac          PMS
                    ON c.IdContrato = PMS.idContrato
                       AND pec.PuntoEntregaID = PMS.PuntoEntregaID
                       AND DATEFROMPARTS(c.Anio, c.Mes, 1) = PMS.idFecha
                       AND PMS.idHidrocarburo = 1001
            LEFT JOIN
                PR_ProduccionMensualSipac          PMSG
                    ON c.IdContrato = PMSG.idContrato
                       AND pec.PuntoEntregaID = PMSG.PuntoEntregaID
                       AND DATEFROMPARTS(c.Anio, c.Mes, 1) = PMSG.idFecha
                       AND PMSG.idHidrocarburo = 1000;
    END;
