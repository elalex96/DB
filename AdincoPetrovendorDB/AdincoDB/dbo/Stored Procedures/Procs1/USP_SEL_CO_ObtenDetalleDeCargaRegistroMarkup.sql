IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_ObtenDetalleDeCargaRegistroMarkup'
    )
    DROP PROCEDURE USP_SEL_CO_ObtenDetalleDeCargaRegistroMarkup;
GO
CREATE PROCEDURE [dbo].[USP_SEL_CO_ObtenDetalleDeCargaRegistroMarkup]
    @IdUsuario  INT,
    @IdContrato INT,
    @IdCarga    INT = 0
AS
    BEGIN
        SELECT
            CO_BitacoraCargaRegistroMarkupDetalle.Id,
            CO_BitacoraCargaRegistroMarkupDetalle.FilaExcel,
            CO_BitacoraCargaRegistroMarkupDetalle.IdRegistroExcel,
            CO_BitacoraCargaRegistroMarkupDetalle.PorcentajeExcel,
            CO_BitacoraCargaRegistroMarkupDetalle.TipoCambioExcel,
            CO_BitacoraCargaRegistroMarkupDetalle.Detalle,
            CO_BitacoraCargaRegistroMarkupDetalle.Correcto,
            CO_BitacoraCargaRegistroMarkup.GastosNoEncontrados,
            CO_BitacoraCargaRegistroMarkup.ContieneMarkup,
            CO_BitacoraCargaRegistroMarkup.CorrectosPorActualizar AS PorActualizar
        FROM
            CO_BitacoraCargaRegistroMarkupDetalle (NOLOCK)
            JOIN
                CO_BitacoraCargaRegistroMarkup (NOLOCK)
                    ON CO_BitacoraCargaRegistroMarkupDetalle.IdCarga = CO_BitacoraCargaRegistroMarkup.Id
        WHERE
            CO_BitacoraCargaRegistroMarkupDetalle.IdCarga = @IdCarga;

    END