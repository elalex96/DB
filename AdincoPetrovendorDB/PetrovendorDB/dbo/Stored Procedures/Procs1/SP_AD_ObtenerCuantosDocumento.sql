-- =============================================
-- Author:		Pedro Acuña
-- Create date: 26/01/2018
-- Description:	devuelve la cantidad de documentos que esta registrados con la solped requerida
-- =============================================
CREATE PROCEDURE [dbo].SP_AD_ObtenerCuantosDocumento
    @IdSolicitudPedido INT,
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME
AS
BEGIN
    DECLARE @tablaPedido TABLE (idPedido INT)

    INSERT INTO @tablaPedido
    (
        idPedido
    )
    SELECT IdPedido
    FROM dbo.MM_Pedido
    WHERE IdSolicitudPedido = @IdSolicitudPedido


    SELECT COUNT(Id)
    FROM dbo.AD_Documento
    WHERE IdPedido IN (
                          SELECT idPedido FROM @tablaPedido
                      )
END