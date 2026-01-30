IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'CO_GuardaProduccionMensualSipac'
    )
    DROP PROCEDURE CO_GuardaProduccionMensualSipac;
GO
CREATE PROCEDURE [dbo].[CO_GuardaProduccionMensualSipac]
    @fechaMesDiaAño    DATE,
    @hidrocarburo      INT,
    @PuntoEntrega      INT,
    @VolumenProgramado FLOAT,
    @idContrato        INT,
    @GradosAPI         FLOAT = NULL,
    @idUsuario         INT
AS
    BEGIN
        -- =============================================
        -- Author:		Reyna Olvera
        -- Create date: 22/02/18
        -- Description:Agrega la produccion Mensual
        -- =============================================
        -- 20190906	BAAC	Se modifica para volver a calcular el importe total de los hidricarburos, si se actualiza el volumen desde la pantalla de produccion mensual
        SET NOCOUNT ON;

        --********************Fue comentado los grados api ya que seran tomados de otra tabla

        IF EXISTS
            (
                SELECT
                    *
                FROM
                    PR_ProduccionMensualSipac (NOLOCK)
                WHERE
                    [idFecha] = @fechaMesDiaAño
                    AND [idHidrocarburo] = @hidrocarburo
                    AND [PuntoEntregaID] = @PuntoEntrega
                    AND idContrato = @idContrato
            )
            --IF (@Insertado > 0)
            BEGIN

                -- SE ACTUALIZA EL IMPORTE TOTAL EN CASO DE QUE SE TRATE DE PETROLEO, CONDENSADO O GAS, ANTES DE ACTUALIZAR EL VOLUMEN, YA QUE EN LA TABLA DE CROMATOGRAFIA SE GUARDA EL IMPORTE TOTAL
                -- EN CASO QUE SE HAYA ACTUALIZADO EL VOLUMEN DE GAS:
                UPDATE
                    CV
                SET
                    PrecioGas = CASE
                                    WHEN ISNULL(PM.VolumenProgramado, 0) = 0
                                        THEN 0
                                    ELSE
                    (CV.PrecioGas / ISNULL(PM.VolumenProgramado, 0) / 1000) * 1000 * @VolumenProgramado
                                END
                FROM
                    CO_Cromatografia               C
                    JOIN
                        CO_CromatografiaValores    CV
                            ON C.IdContrato = @idContrato
                               AND C.Anio = YEAR(@fechaMesDiaAño)
                               AND C.Mes = MONTH(@fechaMesDiaAño)
                               AND C.IdCromatografia = CV.IdCromatografia
                    JOIN
                        CO_PuntosdeEntregaContrato PE
                            ON C.IdContrato = PE.idContrato
                               AND CV.IdPuntoEntregaContrato = PE.PuntoEntregaContratoID
                    JOIN
                        PR_ProduccionMensualSipac  PM
                            ON C.IdContrato = PM.idContrato
                               AND DATEFROMPARTS(C.Anio, C.Mes, 1) = PM.idFecha
                               AND PE.PuntoEntregaID = PM.PuntoEntregaID
                               AND PM.idHidrocarburo = 1000
                WHERE
                    PM.idHidrocarburo = @hidrocarburo
                    AND PM.PuntoEntregaID = @PuntoEntrega

                -- EN CASO QUE SE HAYA ACTUALIZADO EL VOLUMEN DE PETROLEO:
                UPDATE
                    CV
                SET
                    PrecioPetroleo = CASE
                                         WHEN ISNULL(PM.VolumenProgramado, 0) = 0
                                             THEN 0
                                         ELSE
                    (CV.PrecioPetroleo / ISNULL(PM.VolumenProgramado, 0)) * @VolumenProgramado
                                     END
                FROM
                    CO_Cromatografia               C
                    JOIN
                        CO_CromatografiaValores    CV
                            ON C.IdContrato = @idContrato
                               AND C.Anio = YEAR(@fechaMesDiaAño)
                               AND C.Mes = MONTH(@fechaMesDiaAño)
                               AND C.IdCromatografia = CV.IdCromatografia
                    JOIN
                        CO_PuntosdeEntregaContrato PE
                            ON C.IdContrato = PE.idContrato
                               AND CV.IdPuntoEntregaContrato = PE.PuntoEntregaContratoID
                    JOIN
                        PR_ProduccionMensualSipac  PM
                            ON C.IdContrato = PM.idContrato
                               AND DATEFROMPARTS(C.Anio, C.Mes, 1) = PM.idFecha
                               AND PE.PuntoEntregaID = PM.PuntoEntregaID
                               AND PM.idHidrocarburo = 1001
                WHERE
                    PM.idHidrocarburo = @hidrocarburo
                    AND PM.PuntoEntregaID = @PuntoEntrega

                -- EN CASO QUE SE HAYA ACTUALIZADO EL VOLUMEN DE CONDENSADO:
                UPDATE
                    CV
                SET
                    PrecioCondensado = CASE
                                           WHEN ISNULL(PM.VolumenProgramado, 0) = 0
                                               THEN 0
                                           ELSE
                    (CV.PrecioCondensado / ISNULL(PM.VolumenProgramado, 0)) * @VolumenProgramado
                                       END
                FROM
                    CO_Cromatografia               C
                    JOIN
                        CO_CromatografiaValores    CV
                            ON C.IdContrato = @idContrato
                               AND C.Anio = YEAR(@fechaMesDiaAño)
                               AND C.Mes = MONTH(@fechaMesDiaAño)
                               AND C.IdCromatografia = CV.IdCromatografia
                    JOIN
                        CO_PuntosdeEntregaContrato PE
                            ON C.IdContrato = PE.idContrato
                               AND CV.IdPuntoEntregaContrato = PE.PuntoEntregaContratoID
                    JOIN
                        PR_ProduccionMensualSipac  PM
                            ON C.IdContrato = PM.idContrato
                               AND DATEFROMPARTS(C.Anio, C.Mes, 1) = PM.idFecha
                               AND PE.PuntoEntregaID = PM.PuntoEntregaID
                               AND PM.idHidrocarburo = 1002
                WHERE
                    PM.idHidrocarburo = @hidrocarburo
                    AND PM.PuntoEntregaID = @PuntoEntrega


                UPDATE
                    PR_ProduccionMensualSipac
                SET
                    [VolumenProgramado] = @VolumenProgramado,
                    ModificadoPor = @idUsuario,
                    ModificadoEl = GETDATE(),
                    Activo = 1
                WHERE
                    [idFecha] = @fechaMesDiaAño
                    AND [idHidrocarburo] = @hidrocarburo
                    AND [PuntoEntregaID] = @PuntoEntrega
                    AND idContrato = @idContrato;

            END;
        ELSE
            BEGIN
                INSERT INTO PR_ProduccionMensualSipac
                    (
                        [idFecha],
                        [idHidrocarburo],
                        [PuntoEntregaID],
                        [VolumenProgramado],
                        [idUnidadMedida],
                        [idContrato],
                        CreadoPor,
                        CreadoEl,
                        Activo
                    )
                VALUES
                    (
                        @fechaMesDiaAño,
                        @hidrocarburo,
                        @PuntoEntrega,
                        @VolumenProgramado,
                        CASE
                            WHEN @hidrocarburo IN (
                                                      1000, 1003
                                                  )
                                THEN 1002
                            ELSE
                                1001
                        END,
                        @idContrato,
                        @idUsuario,
                        GETDATE(),
                        1
                    );

            END;

    END;
