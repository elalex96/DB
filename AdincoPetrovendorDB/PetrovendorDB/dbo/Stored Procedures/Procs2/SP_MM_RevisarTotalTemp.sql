-- =============================================
-- Author:		Pedro Acuña
-- Create date: 25/01/2018
-- Description:	saber si se paso de los 20 millones de dolares lo agregado al carrito
-- =============================================
CREATE PROCEDURE SP_MM_RevisarTotalTemp
    @IdSolped INT,
    @IdPeticionOfertaDetalle INT,
    @cantidadAdd DECIMAL,
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME
AS
BEGIN
    DECLARE @dolar DECIMAL(12, 4),
            @total DECIMAL,
            @veinte DECIMAL = 20000000 --20 millones de dolares

    SELECT @dolar = TipoCambio
    FROM Adinco.dbo.CO_TipoCambioDiario
    WHERE CONVERT(DATE, GETDATE()) = Fecha
          AND IdMoneda = 1
          AND Activo = 1

    IF (@dolar IS NULL)
        SELECT TOP 1
            @dolar = TipoCambio
        FROM Adinco.dbo.CO_TipoCambioDiario
        WHERE IdMoneda = 1
              AND Activo = 1
        ORDER BY IdTipoCambio DESC

    SELECT @total = SUM(   CASE
                               WHEN POD.IdMoneda = 2 THEN
                                   POD.PrecioUnitario * POD.NoMaterialesRequeridos
                               ELSE
                                   CASE
                                       WHEN POD.IdMoneda = 1 THEN
                           ((POD.PrecioUnitario * POD.NoMaterialesRequeridos) / @dolar)
                                   END
                           END
                       )
    FROM MM_PeticionOfertaDetalle AS POD
        INNER JOIN MM_PeticionOferta AS PO
            ON PO.IdPeticionOferta = POD.IdPeticionOferta
    WHERE PO.IdSolicitudPedido = @IdSolped
          AND AddPedidoTemp = 1
          AND PO.Activo = 1

    SELECT @total = ISNULL(@total, 0)

    IF (ISNULL(@total, 0) > @veinte)
        SELECT 20 --mayor a 20 millones
    ELSE
        SELECT -1 -- menor a 20M

END