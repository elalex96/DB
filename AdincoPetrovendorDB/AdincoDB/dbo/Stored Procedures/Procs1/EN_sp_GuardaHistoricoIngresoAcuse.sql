-- =============================================
-- Author:		Reyna Olvera
-- Create date: 31/03/2020
-- Description:
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Update date: 22/10/2020
-- Description:Se agrego sp de avance de entregable Equinor
-- =============================================
CREATE PROCEDURE [dbo].[EN_sp_GuardaHistoricoIngresoAcuse]
    @IdUsuario INT,
    @IdContrato INT,
    @IdInstanciaEntregable INT,
    @ContieneArchivo INT,
    @UrlAcuse VARCHAR(5000),
    @FechaRealEntregaRegulador DATETIME,
    @ContieneFechaRealEntregaRegulador INT,
    @ObligacionEsAcuse INT
AS
BEGIN

    DECLARE @IdLineaTiempo INT,
            @Error VARCHAR(MAX);

    SELECT TOP 1
           @IdLineaTiempo = MAX(IdLineaTiempo)
    FROM EN_HistorialAprobacionesLineaTiempo
    WHERE idInstanciaEntregable = @IdInstanciaEntregable
          --AND	idTipoOperacion	=	2
          AND Activo = 1;


    IF (
           @ObligacionEsAcuse = 0
           AND
           (
               @ContieneArchivo = 1
               OR ISNULL(@UrlAcuse, '') <> ''
           )
           AND @IdLineaTiempo > 0
       )
    BEGIN

        INSERT INTO EN_HistorialAprobacionesLineaTiempo
        (
            IdLineaTiempo,
            idInstanciaEntregable,
            idContrato,
            Comentario,
            Rechazado,
            idTipoOperacion,
            CreadoPor,
            CreadoEn,
            Activo,
            ActualizadoByApp,
            URLRepositorio,
            ContieneURLRepositorio
        )
        VALUES
        (   @IdLineaTiempo, @IdInstanciaEntregable, @IdContrato, 'Ingreso de Acuse', 0, 7, @IdUsuario, GETDATE(), 1, 0,
            CASE ISNULL(@UrlAcuse, '')
                WHEN '' THEN
                    'No se ingreso URL de repositorio'
                ELSE
                    @UrlAcuse
            END, CASE ISNULL(@UrlAcuse, '')
                     WHEN '' THEN
                         0
                     ELSE
                         1
                 END);


        UPDATE EN_InstanciasEntregable
        SET BitContieneAcuse = 1
        WHERE idInstanciaEntregable = @IdInstanciaEntregable;

    END;
    ELSE IF (@ObligacionEsAcuse = 1)
    BEGIN
        UPDATE EN_InstanciasEntregable
        SET BitContieneAcuse = 1
        WHERE idInstanciaEntregable = @IdInstanciaEntregable;
    END;



    UPDATE EN_InstanciasEntregable
    SET FechaRealEntregaRegulador = CASE @ContieneFechaRealEntregaRegulador
                                        WHEN 1 THEN
                                            @FechaRealEntregaRegulador
                                        ELSE
                                            FechaRealEntregaRegulador
                                    END
    WHERE idInstanciaEntregable = @IdInstanciaEntregable;

    /*SE VALIDA QUE EL AVANCE DEL ENTREGABLE ESTE EN 100%, SI NO, SE DEBE ACTUALIZAR AL 100%, AL IGUAL % POR USUARIO DEL FLUJO*/
    EXEC dbo.SP_EN_GuardarAvanceEntregableSeguimiento @EntregableInstanciaId = @IdInstanciaEntregable, -- int
                                                      @ClaveAvance = '',                               -- float
                                                      @UsuarioId = @IdUsuario,                         -- int
                                                      @ContratoId = @IdContrato,                       -- int
                                                      @Estado = '',                                    -- varchar(max)
                                                      @TipoGuardado = 'SISTEMA-ACUSE',                 -- varchar(max)
                                                      @Comentario = '';

    SELECT @Error AS Error;

END;
