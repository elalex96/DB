-- =============================================
-- Author:		Pedro Acuña
-- Create date: 26/01/2018
-- Description:	saber si se paso de los 20 millones de dolares en la carga de la pagina
-- =============================================
CREATE PROCEDURE SP_MM_RevisarTope
    @IdSolped INT,
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME
AS
BEGIN
    DECLARE @dolar DECIMAL(12, 4),
            @total DECIMAL,
            @veinte DECIMAL = 20000000, --20 millones de dolares
            @precio DECIMAL,
            @idPedido INT

    DECLARE @tablaPedido TABLE (IdPedido INT)

    SELECT @dolar = TipoCambio
    FROM Adinco.dbo.CO_TipoCambioDiario
    WHERE CONVERT(DATE, GETDATE()) = Fecha
          AND IdMoneda = 1

    IF (@dolar IS NULL)
        SELECT TOP 1
            @dolar = TipoCambio
        FROM Adinco.dbo.CO_TipoCambioDiario
        WHERE IdMoneda = 1
        ORDER BY IdTipoCambio DESC

    SELECT @total = SUM(   CASE
                               WHEN POD.IdMoneda = 2 THEN
                                   POD.PrecioUnitario * POD.AddCantidadTemp
                               WHEN POD.IdMoneda = 1 THEN
                                   ROUND(((POD.PrecioUnitario * POD.AddCantidadTemp) / @dolar), 2)
                           END
                       )
    FROM MM_PeticionOfertaDetalle AS POD
        INNER JOIN MM_PeticionOferta AS PO
            ON PO.IdPeticionOferta = POD.IdPeticionOferta
    WHERE PO.IdSolicitudPedido = @IdSolped
          AND AddPedidoTemp = 1

    IF (@total IS NULL)
    BEGIN
        --se isertan los pedido que tienen relacion con la solped, en caso de que ya se haya adjudicaco el pedido, ya que se borran los temporales de la tabla anterior
        INSERT INTO @tablaPedido
        (
            IdPedido
        )
        SELECT IdPedido
        FROM dbo.MM_Pedido
        WHERE IdSolicitudPedido = @IdSolped

        SELECT @total = SUM(   CASE
                                   WHEN Ped.IdMoneda = 2 THEN
                                       Ped.PrecioUnitario * Ped.Cantidad
                                   WHEN Ped.IdMoneda = 1 THEN
                                       ROUND(((Ped.PrecioUnitario * Ped.Cantidad) / @dolar), 2)
                               END
                           )
        FROM dbo.MM_PedidoDetalle AS Ped
        WHERE Ped.IdPedido IN (
                                  SELECT IdPedido FROM @tablaPedido
                              )
              AND Ped.Activo = 1
    END

    IF (ISNULL(@total, 0) > @veinte)
        SELECT 20 --mayor a 20 millones
    ELSE
        SELECT -1 -- menor a 20M

END