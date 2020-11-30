-- =============================================
-- Author:		DANIEL AC
-- Create date: 25/01/2019
-- Description:	Consulta el estatus de la distribución de un detalle de orden de compra 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PP_AgregarDetalleDistribucionOCDetalle]
    --SP_PP_AgregarDetalleDistribucionOCDetalle 10002,10002,10001,1111,1,0,0,1
    -- Add the parameters for the stored procedure here
    @IdPedidoDetalle INT,
    @IdPedido INT,
    @IdProveedor INT = 0,
    @IdUsuario INT = 0,
    @Cantidad FLOAT,
    @IdProyecto INT,
    @IdCentroCosto INT,
    @IdDistribucionRequisicion INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @CantidadPedido FLOAT,
            @IsDistribucionCantidad BIT,
            @CantidadRequisicion FLOAT,
            @CantidadClasificadaOC FLOAT,
			@CantidadAsignadaDistribucion FLOAT,
            @CantidadClasificadaRequisicion FLOAT,
            @CantidadDisponibleRequisicion FLOAT,
            @cantidadDisponibleOrdenCompra FLOAT,
            @IsExist INT,
			@IdSolicitudPedidoDetalle INT,
			@IdCotizacionDetalle INT			


    SELECT @CantidadPedido = PD.Cantidad,
           @IsDistribucionCantidad = SPD.DistribucionCantidad,
           @CantidadRequisicion = SPD.Cantidad,
		   @CantidadAsignadaDistribucion=SPDD.Cantidad,
           @IsExist = SPDD.IdSolicitudDistribucion,
           @IdProyecto = SPDD.IdProyecto,
           @IdCentroCosto = SPDD.IdCentroCosto,
		   @IdSolicitudPedidoDetalle=SPD.IdSolicitudPedidoDetalle,
		   @IdCotizacionDetalle=CD.IdCotizacionDetalle
    FROM dbo.PP_PedidoDetalle PD
        LEFT JOIN dbo.PP_Pedido P
            ON P.IdPedido = PD.IdPedido
        LEFT JOIN dbo.PP_Cotizacion C
            ON C.IdCotizacion = P.IdCotizacion
        LEFT JOIN dbo.PP_CotizacionDetalle CD
            ON CD.IdCotizacion = C.IdCotizacion
               AND CD.IdCotizacionDetalle = PD.IdCotizacionDetalle
        LEFT JOIN dbo.PP_SolicitudPedidoDetalle SPD
            ON SPD.IdSolicitudPedidoDetalle = CD.IdSolicitudPedidoDetalle
        LEFT JOIN dbo.PP_SolicitudPedidoDetalleDistribucionCantidad SPDD
            ON SPDD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
    WHERE PD.IdPedidoDetalle = @IdPedidoDetalle
          AND P.IdPedido = @IdPedido
          AND P.IdProveedorCliente = @IdProveedor
          AND SPDD.IdSolicitudDistribucion = @IdDistribucionRequisicion
		  AND ISNULL(P.IsEliminado,0)=0


    -- VALIDAR QUE EXISTA LA DISTRIBUCION 
    IF ISNULL(@IsExist, 0) > 0
    BEGIN


        IF @Cantidad > 0
        BEGIN
			-- CANTIDAD YA DISTRIBUIDA DE ESTE PEDIDO DETALLE EN X DISTRIBUCIONES
            SELECT @CantidadClasificadaOC = ISNULL(SUM(PDD.Cantidad), 0)
            FROM dbo.PP_PedidoDetalleDistribucionCantidad PDD
                LEFT JOIN dbo.PP_PedidoDetalle PD
                    ON PD.IdPedidoDetalle = PDD.IdPedidoDetalle
				LEFT JOIN dbo.PP_Pedido P ON P.IdPedido=PD.IdPedido
            WHERE PDD.IdPedidoDetalle = @IdPedidoDetalle
                  AND PDD.Activo = 1
				  AND ISNULL(P.IsEliminado,0)=0

			--CANTIDAD DE ESTA DISTRIBUCION DE SOLICITUD PEDIDO DETALLE YA CLASIFICADA 
            SELECT @CantidadClasificadaRequisicion = COUNT(PDD.Cantidad)
            FROM dbo.PP_PedidoDetalleDistribucionCantidad PDD
			LEFT JOIN dbo.PP_PedidoDetalle PD ON PD.IdPedidoDetalle=PDD.IdPedidoDetalle
			LEFT JOIN dbo.PP_Pedido P ON P.IdPedido=PD.IdPedido
            WHERE IdDistribucionRequisicion = @IdDistribucionRequisicion
                  AND Activo = 1
				  AND ISNULL(P.IsEliminado,0)=0

            -- VALIDAR QUE EXISTA CANTIDAD DISPONIBLE PARA DISTRIBUIR DE LA REQUISICION
            -- TOTAL_DISPONIBLE_GRAL = CANTIDAD SOLICITADA EN LA REQUISICION - TOTAL ACUMUADO DE LA DISTRIBUCION EN LAS ORDENES DE COMPRA 

            SET @CantidadDisponibleRequisicion = @CantidadAsignadaDistribucion - @CantidadClasificadaRequisicion;

            IF @CantidadDisponibleRequisicion >= @Cantidad
            BEGIN

                -- VALIDAR QUE EXISTA CANTIDAD DISPONIBLE DE LA ORDEN DE COMPRA PARA DISTRIBUIR 
                -- TOTAL_DISPONIBLE_GRAL_DETALLE =TOTAL DE PRODUCTOS EN ESTA ORDEN DE COMPRA  - TOTAL DE PRODUCTOS DE ESTA ORDEN ORDEN DE COMPRA DETALLE QUE YA ESTA EN UNA DISTRIBUCION
                SET @cantidadDisponibleOrdenCompra = @CantidadPedido - @CantidadClasificadaOC;

                IF @cantidadDisponibleOrdenCompra >= @Cantidad
                BEGIN
                    INSERT INTO dbo.PP_PedidoDetalleDistribucionCantidad
                    (
                        IdPedidoDetalle,
                        IdDistribucionRequisicion,
                        Cantidad,
                        IdProyecto,
                        IdCentroCosto,
                        CreadoEl,
                        CreadoPor,
                        Activo,
                        IsEliminado,
						IdSolicitudPedidoDetalle,
						DistribucionCantidad,
						CantidadTotalSolicitudPedidoDetalleDistribucion,
						IdCotizacionDetalle
                    )
                    VALUES
                    (   @IdPedidoDetalle,                      -- IdPedidoDetalle - int
                        @IdDistribucionRequisicion, @Cantidad, -- Cantidad - float
                        @IdProyecto,                           -- IdProyecto - int
                        @IdCentroCosto,                        -- IdCentroCosto - int
                        GETDATE(),                             -- CreadoEl - datetime
                        @IdUsuario,                            -- CreadoPor - int
                        1,                                     -- Activo - bit	    
                        0 ,                                     -- IsEliminado - bit	
						@IdSolicitudPedidoDetalle,						
						@IsDistribucionCantidad,
						@CantidadAsignadaDistribucion,
						@IdCotizacionDetalle
                        );

                    SELECT 'SUCCESS' AS RESPONSE
                END;
                ELSE
                BEGIN
                    SELECT 'CANTIDAD_MAYOR_DISPONIBLE_ORDENCOMPRA'  AS RESPONSE, CONCAT('La cantidad disponible para agregar a la distribución de este proyecto es ',CAST(@cantidadDisponibleOrdenCompra AS nvarchar(max))) AS MENSAJE
                END;
            END;
            ELSE
            BEGIN
                SELECT 'CANTIDAD_MAYOR_DISPONIBLE_REQUISICION'  AS RESPONSE, CONCAT('La cantidad disponible para agregar al proyecto actual es ', CAST(@CantidadDisponibleRequisicion AS NVARCHAR(MAX))) AS MENSAJE
            END;

        END;
        ELSE
        BEGIN
            SELECT 'CANTIDAD_MENORCERO' AS RESPONSE, 'La cantidad debe ser mayor que 0' AS MENSAJE
        END;
    END;
    ELSE
    BEGIN
        SELECT 'DISTRIBUCION_NOENCONTRADA' AS RESPONSE, 'No se ha encontrado la distribución de este proyecto' AS MENSAJE
    END;


END;

