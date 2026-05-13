USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_AgregarAceptacionPedidoDetalle'
)
    DROP PROCEDURE SP_MM_AgregarAceptacionPedidoDetalle; 
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_AgregarAceptacionPedidoDetalle]    Script Date: 01/03/2024 02:27:15 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		DANIEL AC
-- Create date: 03/07/2017
-- Description:	ALTA ACEPTACION DE PEDIDO 
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 29/02/2023
-- Description:	FUNCIONALIDAD PARA PREFERENCIA DE CONTRATO FuncionalidadDetallePresupuestoAceptacionServicio
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
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME = NULL,
	@IdClienteProyecto INT  = NULL,
	@IdActividadClasificacionGasto INT  = NULL,
	@IdActividadClasificacionGasto2 INT  = NULL,
	@AplicaFuncDetallePresupuestoAP BIT = NULL
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



	IF ISNULL(@AplicaFuncDetallePresupuestoAP,0) = 1
	BEGIN 
		INSERT INTO MM_AceptacionPedidoDetalleCriterios(
		AceptacionPedidoDetalleId, 
		ClienteProyectoId, 
		ActividadClasificacionGastoId, 
		ActividadClasificacionGasto2Id, 
		CreadoEl 
		)
		VALUES(
		@IdAceptacionPedidoDetalle,
		@IdClienteProyecto,
		@IdActividadClasificacionGasto,
		CASE WHEN ISNULL(@IdActividadClasificacionGasto2,0)=0 THEN NULL ELSE @IdActividadClasificacionGasto2 END,
		GETDATE()
		)
	END 
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
