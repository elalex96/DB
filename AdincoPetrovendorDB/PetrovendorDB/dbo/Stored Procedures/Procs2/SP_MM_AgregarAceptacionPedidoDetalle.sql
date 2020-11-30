-- =============================================
-- Author:		DANIEL AC
-- Create date: 03/07/2017
-- Description:	ALTA ACEPTACION DE PEDIDO 
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_AgregarAceptacionPedidoDetalle]
    @IdPedidoDetalle INT,
    @CreadoPor INT,
    @IdAceptacionPedido INT,
    @Detalle VARCHAR(1500),
    @Cantidad FLOAT,
    @Excedente FLOAT,
    @IdInstalacion INT = NULL,
    @IdLineaPresupuesto INT = NULL,
    /*--------------------parametros contrato  --------------------*/
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
BEGIN
    DECLARE @IdAceptacionPedidoDetalle INT,
            @IdMaterial INT,
            @IdProveedor INT


    INSERT INTO MM_AceptacionPedidoDetalle
    (
        [IdAceptacionPedido],
        [IdPedidoDetalle],
        [Cantidad],
        [Detalle],
        [CreadoPor],
        [Creado],
        [Excedente]
    )
    VALUES
    (@IdAceptacionPedido, @IdPedidoDetalle, @Cantidad, @Detalle, @CreadoPor, GETDATE(), @Excedente)


    SELECT @IdAceptacionPedidoDetalle = SCOPE_IDENTITY()


    SELECT @IdMaterial = IdMaterial,
           @IdProveedor = p.IdProveedorCompras
    FROM dbo.MM_PedidoDetalle pd
        INNER JOIN dbo.MM_Pedido p
            ON p.IdPedido = pd.IdPedido
    WHERE IdPedidoDetalle = @IdPedidoDetalle


    INSERT INTO dbo.MM_AceptacionPedidoDetalleInstalacion
    (
        IdAceptacionPedido,
        IdAceptacionPedidoDetalle,
        IdPedidoDetalle,
        IdProveedor,
        IdMaterial,
        Cantidad,
        IdInstalacion,
        IdLineaPresupuesto
    )
    VALUES
    (   @IdAceptacionPedido,        -- IdAceptacionPedido - int
        @IdAceptacionPedidoDetalle, -- IdAceptacionPedidoDetalle - int
        @IdPedidoDetalle,           -- IdPedidoDetalle - int
        @IdProveedor,               -- IdProveedor - int
        @IdMaterial,                -- IdMaterial - int
        @Cantidad,                  -- Cantidad - float
        @IdInstalacion,             -- IdInstalacion - int
        @IdLineaPresupuesto         -- IdLineaPresupuesto - int
        )


    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.MM_AceptacionPedidoDetalleInstalacion
        WHERE IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle
    )
    BEGIN
        RAISERROR(
                     'Valor no insertado en MM_AceptacionPedidoDetalleInstalacion por eso es el error para que coincida el valor en MM_AceptacionPedidoDetalle',
                     16,
                     1
                 )
    END

    SELECT @IdAceptacionPedidoDetalle
END
