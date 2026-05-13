
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <27-04-2018>
-- Description:	<Se valida que no exista una aprobacion de carta nacional iniciada en una aceptacion de servicio>
-- Create date: <05-09-2018>
-- Description:	<Si no se solicita una carta de CN, se revisa que no exista una aprobacion de factura iniciada>
-- =============================================

CREATE PROCEDURE MM_ValidarInicioAprobacionCN
    @IdAceptacionPedido INT,
    /*--------------------parametros contrato  --------------------*/
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
BEGIN
    DECLARE @CartaCN BIT

    SELECT @CartaCN = rel.PedirCarta
        FROM dbo.RelacionCartaCNPedido rel
            INNER JOIN dbo.MM_AceptacionPedido ap
                ON ap.IdAceptacionPedido = rel.IdAceptacionPedido
                   AND ap.IdPedido = rel.IdPedido
        WHERE ap.IdAceptacionPedido = @IdAceptacionPedido
             
	--ya que antes el campo NoCarta cuando es 1 es que no quiere carta 
    IF (ISNULL(@CartaCN, 0) = 1) --Se valida si se solicita CN o no.
    BEGIN
        SELECT ac.IdAceptacionCartaPCN
        FROM dbo.MM_AceptacionCartaPCN ac
        WHERE ac.IdAceptacionPedido = @IdAceptacionPedido
              AND ac.IdEstatus <> 3
              AND ISNULL(ac.IdEstatusEliminado, 0) <> 1
    END
    ELSE
    BEGIN
        SELECT IdAceptacionFactura
        FROM dbo.MM_AceptacionFactura
        WHERE IdAceptacionPedido = @IdAceptacionPedido
              AND IdEstatus <> 3
              AND ISNULL(IdEstatusEliminado, 0) <> 1
    END
END


