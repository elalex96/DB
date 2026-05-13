IF EXISTS
(
    SELECT 1
    FROM sysobjects
    WHERE name = 'USP_SEL_FMP_CalculadoraGasPorMes'
)
    DROP PROCEDURE USP_SEL_FMP_CalculadoraGasPorMes;
GO

CREATE PROCEDURE [dbo].[USP_SEL_FMP_CalculadoraGasPorMes]
    @ContratoId INT,
    @UsuarioId INT,
    @Mes DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ISNULL(FI_Factura.UUID, '') FolioCFDI,
           FI_Factura.Fecha FechaCFDI,
           '20' Temperatura,
           'millones de pies cúbicos' Unidad,
           PR_ProduccionMensualSipac.VolumenProgramado Cantidad,
           'USD' Unidad2,
           CO_CromatografiaValores.PrecioGas Importe,
           1 TipoCambio,
           ISNULL(CO_CromatografiaValores.MOL_h2S, 0) H2S,
           ISNULL(CO_CromatografiaValores.MOL_CO2, 0) CO2,
           ISNULL(CO_CromatografiaValores.MOL_N2, 0) N2,
           ISNULL(CO_CromatografiaValores.O2, 0) O2,
           ISNULL(CO_CromatografiaValores.H2O, 0) H2O,
           ISNULL(CO_CromatografiaValores.C1, 0) C1,
           ISNULL(CO_CromatografiaValores.C2, 0) C2,
           ISNULL(CO_CromatografiaValores.C3, 0) C3,
           ISNULL(CO_CromatografiaValores.lC4, 0) lC4,
           ISNULL(CO_CromatografiaValores.NC4, 0) NC4,
           ISNULL(CO_CromatografiaValores.lC5, 0) lC5,
           ISNULL(CO_CromatografiaValores.NC5, 0) NC5,
           ISNULL(CO_CromatografiaValores.C6_plus, 0) C6,
           ISNULL(CO_CromatografiaValores.C7, 0) C7,
           ISNULL(CO_CromatografiaValores.C8, 0) C8,
           ISNULL(CO_CromatografiaValores.C9, 0) C9,
           ISNULL(CO_CromatografiaValores.C10, 0) C10
    FROM CO_Cromatografia (NOLOCK)
        JOIN CO_CromatografiaValores (NOLOCK)
            ON CO_Cromatografia.IdContrato = @ContratoId
               AND CO_Cromatografia.Anio = YEAR(@Mes)
               AND CO_Cromatografia.Mes = MONTH(@Mes)
               AND CO_Cromatografia.IdCromatografia = CO_CromatografiaValores.IdCromatografia
        JOIN CO_PuntosdeEntregaContrato (NOLOCK)
            ON CO_Cromatografia.IdContrato = CO_PuntosdeEntregaContrato.idContrato
               AND ISNULL(CO_PuntosdeEntregaContrato.Activo, 0) = 1
               AND CO_CromatografiaValores.IdPuntoEntregaContrato = CO_PuntosdeEntregaContrato.PuntoEntregaContratoID
        JOIN CO_ClasificacionProductoNominacion (NOLOCK)
            ON CO_ClasificacionProductoNominacion.NombreCNH = 'Gas'
        JOIN PR_ProduccionMensualSipac (NOLOCK)
            ON CO_Cromatografia.IdContrato = PR_ProduccionMensualSipac.idContrato
               AND PR_ProduccionMensualSipac.idHidrocarburo = CO_ClasificacionProductoNominacion.ProductoNominacionID
               AND DATEFROMPARTS(CO_Cromatografia.Anio, CO_Cromatografia.Mes, 1) = PR_ProduccionMensualSipac.idFecha
               AND CO_PuntosdeEntregaContrato.PuntoEntregaID = PR_ProduccionMensualSipac.PuntoEntregaID
        JOIN CO_TipoHidrocarburo (NOLOCK)
            ON CO_TipoHidrocarburo.Hidrocarburo IN ( 'Metano', 'Etano', 'Propano', 'Butano' )
        JOIN COM_OperacionComercializacion (NOLOCK)
            ON CO_PuntosdeEntregaContrato.PuntoEntregaID = COM_OperacionComercializacion.PuntoEntregaId
               AND COM_OperacionComercializacion.IdTipoHidrocarburo = CO_TipoHidrocarburo.IdTipoHidrocarburo
               AND CO_Cromatografia.IdContrato = COM_OperacionComercializacion.idContrato
               AND DATEFROMPARTS(CO_Cromatografia.Anio, CO_Cromatografia.Mes, 1) = COM_OperacionComercializacion.MesReporte
        JOIN FI_Factura (NOLOCK)
            ON COM_OperacionComercializacion.IdFactura = FI_Factura.IdFactura
    GROUP BY ISNULL(FI_Factura.UUID, ''),
             FI_Factura.Fecha,
             PR_ProduccionMensualSipac.VolumenProgramado,
             CO_CromatografiaValores.PrecioGas,
             ISNULL(CO_CromatografiaValores.MOL_h2S, 0),
             ISNULL(CO_CromatografiaValores.MOL_CO2, 0),
             ISNULL(CO_CromatografiaValores.MOL_N2, 0),
             ISNULL(CO_CromatografiaValores.O2, 0),
             ISNULL(CO_CromatografiaValores.H2O, 0),
             ISNULL(CO_CromatografiaValores.C1, 0),
             ISNULL(CO_CromatografiaValores.C2, 0),
             ISNULL(CO_CromatografiaValores.C3, 0),
             ISNULL(CO_CromatografiaValores.lC4, 0),
             ISNULL(CO_CromatografiaValores.NC4, 0),
             ISNULL(CO_CromatografiaValores.lC5, 0),
             ISNULL(CO_CromatografiaValores.NC5, 0),
             ISNULL(CO_CromatografiaValores.C6_plus, 0),
             ISNULL(CO_CromatografiaValores.C7, 0),
             ISNULL(CO_CromatografiaValores.C8, 0),
             ISNULL(CO_CromatografiaValores.C9, 0),
             ISNULL(CO_CromatografiaValores.C10, 0)
    ORDER BY FolioCFDI DESC
END;