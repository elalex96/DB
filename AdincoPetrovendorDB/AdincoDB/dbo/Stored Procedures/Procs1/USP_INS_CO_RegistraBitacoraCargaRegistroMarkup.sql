USE Adinco
GO
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_UPD_CO_ActualizaMarkupRegistros'
    )
    DROP PROCEDURE USP_INS_UPD_CO_ActualizaMarkupRegistros;
GO
CREATE PROCEDURE [dbo].[USP_INS_UPD_CO_ActualizaMarkupRegistros]
    @IdUsuario  INT = 0,
    @IdContrato INT,
    @IdCarga    INT
AS
    BEGIN
        --drop table #BitacoraCorrectos
        CREATE TABLE #BitacoraCorrectos
            (
                FilaExcel         int,
                IdRegistro        int,
                IdContrato        INT,
                Porcentaje        float,
                TipoCambio        float,
                PorcentajeDecimal float,
                MontoRegistro     FLOAT,
                MontoEquivalente  FLOAT
            );

        INSERT INTO #BitacoraCorrectos
            (
                FilaExcel,
                IdRegistro,
                Porcentaje,
                TipoCambio,
                MontoRegistro,
                IdContrato
            )
                    SELECT
                        CO_BitacoraCargaRegistroMarkupDetalle.FilaExcel,
                        CO_BitacoraCargaRegistroMarkupDetalle.IdRegistro,
                        CO_BitacoraCargaRegistroMarkupDetalle.Porcentaje,
                        CO_BitacoraCargaRegistroMarkupDetalle.TipoCambio,
                        CO_Registro.MontoRegistro,
                        CO_BitacoraCargaRegistroMarkup.IdContrato
                    FROM
                        CO_BitacoraCargaRegistroMarkupDetalle (NOLOCK)
                        JOIN
                            CO_BitacoraCargaRegistroMarkup (NOLOCK)
                                ON CO_BitacoraCargaRegistroMarkupDetalle.IdCarga = CO_BitacoraCargaRegistroMarkup.Id
                                   AND CO_BitacoraCargaRegistroMarkup.Id = @IdCarga
                        JOIN
                            CO_Registro (NOLOCK)
                                ON CO_BitacoraCargaRegistroMarkupDetalle.IdRegistro = CO_Registro.IdRegistro
                    WHERE
                        IdCarga = @IdCarga
                        AND Correcto = 1;

        UPDATE
            #BitacoraCorrectos
        SET
            PorcentajeDecimal = Porcentaje / 100;

        UPDATE
            #BitacoraCorrectos
        SET
            MontoEquivalente = MontoRegistro * PorcentajeDecimal;

        UPDATE
            CO_RegistroMarkup
        SET
            CO_RegistroMarkup.Porcentaje = BC.PORCENTAJE,
            CO_RegistroMarkup.MONTOEQUIVALENTE = BC.MONTOEQUIVALENTE,
            CO_RegistroMarkup.TipoCambio = BC.TipoCambio,
            CO_RegistroMarkup.MontoGasto = BC.MONTOREGISTRO,
            ModificadoPor = @IdUsuario,
            ModificadoEn = GETDATE()
        FROM
            #BitacoraCorrectos BC
            JOIN
                CO_RegistroMarkup
                    ON BC.IdRegistro = CO_RegistroMarkup.GastoId
                       AND CO_RegistroMarkup.Porcentaje = 0
        WHERE
            CO_RegistroMarkup.Activo = 1;


        INSERT INTO CO_RegistroMarkup
            (
                GastoId,
                Porcentaje,
                MontoEquivalente,
                MontoGasto,
                TipoCambio,
                Activo,
                CreadoPor,
                CreadoEn,
                ContratoId
            )
                    SELECT
                        BC.IdRegistro,
                        BC.PORCENTAJE,
                        BC.MONTOEQUIVALENTE,
                        BC.MONTOREGISTRO,
                        BC.TipoCambio,
                        1,
                        @IdUsuario,
                        GETDATE(),
                        BC.IdContrato
                    FROM
                        #BitacoraCorrectos BC
                        LEFT JOIN
                            CO_RegistroMarkup (NOLOCK)
                                ON BC.IdRegistro = CO_RegistroMarkup.GastoId
                    WHERE
                        CO_RegistroMarkup.GastoId IS NULL;


        UPDATE
            CO_BitacoraCargaRegistroMarkup
        SET
            MarkupRegistrado = 1
        WHERE
            Id = @IdCarga;

    END;
