-- =============================================  
-- Author:  <Abel Rivera>  
-- Create date: <27/11/19>  
-- Description: <Inserta el layout de orden de compra AX>  
-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: <28/11/19>  
-- Description: <Actualizacion de los registros existentes>  
-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: <06/12/2019>  
-- Description: <Actualizacion de los registros existentes>  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_InsLayoutAX] @LayoutAX dbo.Layout_anexo_AX_V4 READONLY
AS
BEGIN

    DECLARE @TablaPedidosEliminar TABLE
    (
        Id INT IDENTITY,
        IdPedido INT,
        IdProveedor INT,
        TieneRegistros BIT,
        TieneTransferencia BIT
    )
    DECLARE @TablaPedidosEliminarValidado TABLE (Id INT IDENTITY, IdPedido INT, IdProveedor INT, IdContrato INT)
    DECLARE @TablaValidacion TABLE
    (
        IdValidacion INT,
        IdAceptacionPedido INT,
        IdAceptacionFactura INT,
        IdFacturaPetronvendor INT,
        IdFacturaAdinco INT,
        TieneGastos BIT,
        TieneTransferencias BIT,
        TIPO NVARCHAR(MAX)
    )
    DECLARE @Contador INT = 1,
            @Cantidad INT,
            @IdProveedorAux INT,
            @IdPedidoAux INT
    DECLARE @ContadorValidado INT = 1,
            @CantidadValidado INT,
            @IdProveedorValidado INT,
            @IdPedidoValidado INT,
            @IdContratoValidado INT,
			@IdSolicitudPedido INT,
			@IdComparativa NVARCHAR(MAX),
			@Comentario NVARCHAR(MAX)

    --SE ACTUALIZAN LOS QUE YA ESTAN GUARDADOS  
    UPDATE dbo.AX_Layout
    SET Empresa = AXU.Empresa,
        NoOrden = AXU.NoOrden,
        Estatus = AXU.Status,
        FechaRegistroCompra = AXU.FechaRegistroOC,
        FechaEntrega = AXU.FechaEntrega,
        FechaMod = GETDATE()
    FROM @LayoutAX AS AXU
    WHERE AX_Layout.NoPedidoADINCO = AXU.NoPedidoADINCO
          AND AXU.NoPedidoADINCO <> '';

    --SE INSERTAN LOS NUEVOS  
    INSERT INTO dbo.AX_Layout
    (
        Empresa,
        NoOrden,
        Estatus,
        FechaRegistroCompra,
        FechaEntrega,
        NoPedidoADINCO,
        FechaReg
    )
    SELECT AX.Empresa,
           AX.NoOrden,
           AX.Status,
           AX.FechaRegistroOC,
           AX.FechaEntrega,
           AX.NoPedidoADINCO,
           GETDATE()
    FROM @LayoutAX AS AX
    WHERE AX.NoPedidoADINCO NOT IN ( SELECT NoPedidoADINCO FROM dbo.AX_Layout )
          AND AX.NoPedidoADINCO <> '';


    --SE CUENTAN LOS REGISTROS AFECTADOS 
    -- no lo muievo para que sea el primer retorno ya que asi lo espera en el servidor 
    SELECT COUNT(IdLayoutAX)
    FROM dbo.AX_Layout
    WHERE NoPedidoADINCO IN ( SELECT NoPedidoADINCO FROM @LayoutAX );

    INSERT INTO @TablaPedidosEliminar (IdPedido)
	SELECT p.IdPedido FROM dbo.AX_Layout l 
	INNER JOIN dbo.MM_Pedido p ON l.NoPedidoADINCO = LTRIM(p.IdPedido)
	INNER JOIN dbo.AX_ComparativaEmpresa emp ON emp.IdProveedor = p.IdProveedorCompras
	WHERE ISNULL(p.IdEstatusEliminado, 0) = 0
	AND UPPER(RTRIM(LTRIM(l.Estatus))) = UPPER('cancelado')
	GROUP BY p.IdPedido

    UPDATE t
    SET t.IdProveedor = p.IdProveedorCompras
    FROM dbo.MM_Pedido p
        INNER JOIN @TablaPedidosEliminar t
            ON t.IdPedido = p.IdPedido


    SELECT @Cantidad = COUNT(1)
    FROM @TablaPedidosEliminar

    WHILE (@Cantidad >= @Contador)
    BEGIN
        SELECT @IdPedidoAux = IdPedido,
               @IdProveedorAux = IdProveedor
        FROM @TablaPedidosEliminar
        WHERE Id = @Contador

        INSERT INTO @TablaValidacion
        (
            IdValidacion,
            IdAceptacionPedido,
            IdAceptacionFactura,
            IdFacturaPetronvendor,
            IdFacturaAdinco,
            TieneGastos,
            TieneTransferencias,
            TIPO
        )
        EXEC dbo.SP_MM_ConsultaValidacionEliminacion_Pedido @IDPEDIDO = @IdPedidoAux,
                                                            @IDPROVEEDOR = @IdProveedorAux,
                                                            @IDCONTRATO = 0


        SET @Contador += 1
        SET @IdPedidoAux = NULL
        SET @IdProveedorAux = NULL
    END


    INSERT INTO dbo.Ax_LayoutNoEliminados (IdPedido, Motivo, FechaCreacion)
    SELECT ap.IdPedido,
           CASE
               WHEN val.TieneGastos = 1 THEN
                   'La factura tiene gastos en Adinco'
               WHEN val.TieneTransferencias = 1 THEN
                   'La factura tiene transferencia en Adinco'
           END,
           GETDATE()
    FROM @TablaValidacion val
        INNER JOIN dbo.MM_AceptacionPedido ap
            ON ap.IdAceptacionPedido = val.IdAceptacionPedido
        INNER JOIN dbo.AX_Layout l
            ON LTRIM(ap.IdPedido) = LTRIM(RTRIM(l.NoPedidoADINCO))

    INSERT INTO @TablaPedidosEliminarValidado (IdPedido, IdProveedor, IdContrato)
    SELECT t.IdPedido,
           t.IdProveedor,
           p.IdContrato
    FROM @TablaPedidosEliminar t
        LEFT JOIN dbo.Ax_LayoutNoEliminados noEliminado
            ON noEliminado.IdPedido = t.IdPedido
        LEFT JOIN dbo.MM_Pedido p
            ON p.IdPedido = t.IdPedido
    WHERE noEliminado.IdPedido IS NULL

    SELECT @CantidadValidado = COUNT(1)
    FROM @TablaPedidosEliminarValidado


    WHILE (@CantidadValidado >= @ContadorValidado)
    BEGIN

        SELECT @IdPedidoValidado = IdPedido,
               @IdProveedorValidado = IdProveedor,
               @IdContratoValidado = IdContrato
        FROM @TablaPedidosEliminarValidado
        WHERE Id = @ContadorValidado

		SELECT @IdSolicitudPedido = p.IdSolicitudPedido FROM dbo.MM_Pedido p WHERE p.IdPedido = @IdPedidoValidado

		SELECT TOP 1 @IdComparativa = c.IdComparativa FROM dbo.AX_Comparativa c WHERE c.IdSolicitudPedido = @IdSolicitudPedido ORDER BY c.IdComparativa

		SELECT @Comentario = CONCAT('Eliminado por sistema Layout, Comparativa: ', @IdComparativa)

        EXEC dbo.SP_MM_Eliminar_Pedido @IDPEDIDO = @IdPedidoValidado,                         -- int
                                       @IDPROVEEDOR = @IdProveedorValidado,                   -- int
                                       @IDCONTRATO = @IdContratoValidado,                     -- int
                                       @COMENTARIO_INTERNO = @Comentario, -- nvarchar(max)
                                       @COMENTARIO_EXTERNO = @Comentario, -- nvarchar(max)
                                       @IDUSUARIO = 1,                                        -- int
                                       @CONFIRMACION = 1                                      -- bit


        SET @Comentario = NULL	
        SET @IdPedidoValidado = NULL
        SET @IdProveedorValidado = NULL
		SET @IdContratoValidado = NULL
		SET @ContadorValidado += 1
    END 
END
