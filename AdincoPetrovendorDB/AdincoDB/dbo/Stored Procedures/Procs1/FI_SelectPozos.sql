
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180825
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE FI_SelectPozos
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT id,
           Clave,
           dbo.PR_Pozo.Nombre AS nombrePozo,
           Descripcion,
           RegionFiscal,
		   CO_PuntosdeEntrega.PuntoEntregaID AS nombrePE,
        --   dbo.CO_PuntosdeEntrega.Nombre AS nombrePE,
		   TipoFluidoGas ,
		   TipoFluidoPetroleo
    FROM PR_Pozo
        JOIN dbo.CO_PuntosdeEntrega
            ON CO_PuntosdeEntrega.PuntoEntregaID = PR_Pozo.PuntoEntregaID
        JOIN dbo.CO_PuntosdeEntregaContrato
            ON CO_PuntosdeEntregaContrato.PuntoEntregaID = CO_PuntosdeEntrega.PuntoEntregaID
    WHERE dbo.CO_PuntosdeEntregaContrato.idContrato =@IdContrato;
END;
