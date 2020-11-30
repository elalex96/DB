-- =============================================
-- Author:		Pedro, Acuña
-- Create date: 31/01/2018
-- Description:	Consultar los documentos registrados para mostrarlos en el grid de oferta de adjudicacion directa (Justificacion)
-- =============================================
CREATE PROCEDURE SP_AD_ConsultarJustificacion
    @IdSolPed INT,
    @IdContrato INT,
    @Idusuario INT,
    @FchRegistro DATETIME
AS
BEGIN
    DECLARE @tablaPedido TABLE (IdPedido INT)

    INSERT INTO @tablaPedido
    (
        IdPedido
    )
    SELECT IdPedido
    FROM dbo.MM_Pedido
    WHERE IdSolicitudPedido = @IdSolPed

    SELECT Id, IdPedido, Justificacion
    FROM dbo.AD_Documento
    WHERE IdPedido IN (
                          SELECT IdPedido FROM @tablaPedido
                      )
END
