CREATE PROCEDURE [dbo].[sp_InsUpd_PC_VolumenProduccionPeriodo] --3,'20190801'
    --@pIdCromatografia        INT OUT,
    @pIdContrato                            INT,
    @pIdPuntoEntregaContrato                INT,
    @pAnio                                  SMALLINT,
    @pMes                                   TINYINT,
    @pGradosAPI                             FLOAT,
    @pAzufre                                FLOAT,
    @pCreadoPor                             INT,
    @pEsPetroleo                            BIT,
    @VolumenPetroleoPuntoMedicionPeriodo1   FLOAT,
    @VolumenPetroleoPuntoMedicionPeriodo2   FLOAT,
    @VolumenCondensadoPuntoMedicionPeriodo1 FLOAT,
    @VolumenCondensadoPuntoMedicionPeriodo2 FLOAT,
    @VolumenGasMMPCPeriodo1                 FLOAT,
    @VolumenGasMMPCPeriodo2                 FLOAT
AS
    BEGIN
        DECLARE
            @FechaFinPeriodo1    DATE,
            @FechaInicioPeriodo2 DATE,
            @FechaInicioPeriodo1 DATE,
            @FechaFinPeriodo2    DATE,
            @MesReporte          DATE,
            @ExistePeriodo1      INT,
            @ExistePeriodo2      INT,
            @Error               VARCHAR(MAX) = '',
            @pIdPuntoEntrega     INT;

        SELECT
            @FechaFinPeriodo1    = IdFecha,
            @FechaInicioPeriodo2 = DATEADD(DAY, 1, IdFecha),
            @FechaInicioPeriodo1 = PrimerDiaMes,
            @FechaFinPeriodo2    = UltimoDiaMes
        FROM
            AP_Calendario
        WHERE
            Anio = @pAnio
            AND Mes = @pMes
            AND Descripcion = 'Resultados y Elementos del Cálculo (Fecha máxima)';
        SELECT
            @MesReporte = CONVERT(DATE, LTRIM(@pAnio) + '-' + LTRIM(@pMes) + '-' + '01');



        UPDATE
            PC_VolumenProduccionPeriodo
        SET
            VolumenPetroleoPuntoMedicion = CASE
                                               WHEN @pEsPetroleo = 1
                                                   THEN
                                                   @VolumenPetroleoPuntoMedicionPeriodo1
                                               ELSE
                                                   VolumenPetroleoPuntoMedicion
                                           END,
            GradosAPI = CASE
                            WHEN @pEsPetroleo = 1
                                THEN
                                @pGradosAPI
                            ELSE
                                GradosAPI
                        END,
            ContenidoAzufre = CASE
                                  WHEN @pEsPetroleo = 1
                                      THEN
                                      @pAzufre
                                  ELSE
                                      ContenidoAzufre
                              END,
            VolumenCondensadoPuntoMedicion = CASE
                                                 WHEN @pEsPetroleo = 1
                                                     THEN
                                                     @VolumenCondensadoPuntoMedicionPeriodo1
                                                 ELSE
                                                     VolumenCondensadoPuntoMedicion
                                             END,
            ModificadoPor = @pCreadoPor,
            ModificadoEn = GETDATE(),
            VolumenGasMMPC = CASE
                                 WHEN @pEsPetroleo = 0
                                     THEN
                                     @VolumenGasMMPCPeriodo1
                                 ELSE
                                     VolumenGasMMPC
                             END
        WHERE
            IdContrato = @pIdContrato
            AND MesReporte = @MesReporte
            AND FechaInicio = @FechaInicioPeriodo1
            AND FechaFin = @FechaFinPeriodo1;

        SELECT
            @ExistePeriodo1 = @@ROWCOUNT;
        IF (@ExistePeriodo1 = 0)
            BEGIN
                /*Periodo 1*/
                INSERT INTO dbo.PC_VolumenProduccionPeriodo
                    (
                        IdContrato,
                        MesReporte,
                        FechaInicio,
                        FechaFin,
                        VolumenPetroleoPuntoMedicion,
                        GradosAPI,
                        ContenidoAzufre,
                        VolumenCondensadoPuntoMedicion,
                        CreadoPor,
                        CreadoEn,
                        ModificadoPor,
                        ModificadoEn,
                        VolumenGasMMPC
                    )
                VALUES
                    (
                        @pIdContrato,                            -- IdContrato - int
                        @MesReporte,                             -- MesReporte - date
                        @FechaInicioPeriodo1,                    -- FechaInicio - date
                        @FechaFinPeriodo1,                       -- FechaFin - date
                        @VolumenPetroleoPuntoMedicionPeriodo1,   -- VolumenPetroleoPuntoMedicion - float
                        @pGradosAPI,                             -- GradosAPI - float
                        @pAzufre,                                -- ContenidoAzufre - float
                        @VolumenCondensadoPuntoMedicionPeriodo1, -- VolumenCondensadoPuntoMedicion - float
                        @pCreadoPor,                             -- CreadoPor - int
                        GETDATE(),                               -- CreadoEn - datetime
                        @pCreadoPor,                             -- ModificadoPor - int
                        GETDATE(),                               -- ModificadoEn - datetime
                        @VolumenGasMMPCPeriodo1                  -- VolumenGasMMPC
                    );
            END;


        UPDATE
            PC_VolumenProduccionPeriodo
        SET
            VolumenPetroleoPuntoMedicion = CASE
                                               WHEN @pEsPetroleo = 1
                                                   THEN
                                                   @VolumenPetroleoPuntoMedicionPeriodo2
                                               ELSE
                                                   VolumenPetroleoPuntoMedicion
                                           END,
            GradosAPI = CASE
                            WHEN @pEsPetroleo = 1
                                THEN
                                @pGradosAPI
                            ELSE
                                GradosAPI
                        END,
            ContenidoAzufre = CASE
                                  WHEN @pEsPetroleo = 1
                                      THEN
                                      @pAzufre
                                  ELSE
                                      ContenidoAzufre
                              END,
            VolumenCondensadoPuntoMedicion = CASE
                                                 WHEN @pEsPetroleo = 1
                                                     THEN
                                                     @VolumenCondensadoPuntoMedicionPeriodo2
                                                 ELSE
                                                     VolumenCondensadoPuntoMedicion
                                             END,
            ModificadoPor = @pCreadoPor,
            ModificadoEn = GETDATE(),
            VolumenGasMMPC = CASE
                                 WHEN @pEsPetroleo = 0
                                     THEN
                                     @VolumenGasMMPCPeriodo2
                                 ELSE
                                     VolumenGasMMPC
                             END
        WHERE
            IdContrato = @pIdContrato
            AND MesReporte = @MesReporte
            AND FechaInicio = @FechaInicioPeriodo2
            AND FechaFin = @FechaFinPeriodo2;
        SELECT
            @ExistePeriodo2 = @@ROWCOUNT;
        IF (@ExistePeriodo2 = 0)
            BEGIN
                /*Periodo 2*/
                INSERT INTO dbo.PC_VolumenProduccionPeriodo
                    (
                        IdContrato,
                        MesReporte,
                        FechaInicio,
                        FechaFin,
                        VolumenPetroleoPuntoMedicion,
                        GradosAPI,
                        ContenidoAzufre,
                        VolumenCondensadoPuntoMedicion,
                        CreadoPor,
                        CreadoEn,
                        ModificadoPor,
                        ModificadoEn,
                        VolumenGasMMPC
                    )
                VALUES
                    (
                        @pIdContrato,                            -- IdContrato - int
                        @MesReporte,                             -- MesReporte - date
                        @FechaInicioPeriodo2,                    -- FechaInicio - date
                        @FechaFinPeriodo2,                       -- FechaFin - date
                        @VolumenPetroleoPuntoMedicionPeriodo2,   -- VolumenPetroleoPuntoMedicion - float
                        @pGradosAPI,                             -- GradosAPI - float
                        @pAzufre,                                -- ContenidoAzufre - float
                        @VolumenCondensadoPuntoMedicionPeriodo2, -- VolumenCondensadoPuntoMedicion - float
                        @pCreadoPor,                             -- CreadoPor - int
                        GETDATE(),                               -- CreadoEn - datetime
                        @pCreadoPor,                             -- ModificadoPor - int
                        GETDATE(),                               -- ModificadoEn - datetime
                        @VolumenGasMMPCPeriodo2                  -- VolumenGasMMPC
                    );
            END;

        SELECT
            @pIdPuntoEntrega = PuntoEntregaID
        FROM
            dbo.CO_PuntosdeEntregaContrato
        WHERE
            PuntoEntregaContratoID = @pIdPuntoEntregaContrato;

        EXEC SP_CO_PC_ProduccionCalcularEnergia
            @pIdContrato,
            @MesReporte,
            @pIdPuntoEntrega,
            @pCreadoPor,
            0;

        IF @@ERROR <> 0
            SELECT
                CAST(@@ERROR AS NVARCHAR(8)) AS error;
        ELSE
            SELECT
                '' AS error;
    END;