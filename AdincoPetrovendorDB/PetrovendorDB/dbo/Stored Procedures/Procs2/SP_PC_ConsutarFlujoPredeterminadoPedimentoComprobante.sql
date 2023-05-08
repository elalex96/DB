-- =============================================
-- Author:		DANIEL AC
-- Create date: 28-03-18
-- Description:	Agregar o actualiza documento pdf de comprobante o pedimento 
-- =============================================
-- =============================================
-- Author:		Abel Rivera
-- Create date: 26/11/19
-- Description:	Se agrego la validacion de DEA para seleccionar el flujo de aprobacion asociado al centro de costos de la solped
-- =============================================

CREATE PROCEDURE [dbo].[SP_PC_ConsutarFlujoPredeterminadoPedimentoComprobante]
-- Add the parameters for the stored procedure here

@IdProveedor        INT, 
@IdContrato         INT, 
@IdUsuario          INT, 
@IdAceptacionPedido INT
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        DECLARE @IdProveedorOperador INT= 0;
        DECLARE @IdFlujoTarea INT;
        SELECT @IdProveedorOperador = P.IdProveedorCompras
        FROM dbo.MM_AceptacionPedido AP
             INNER JOIN dbo.MM_Pedido P ON P.IdPedido = AP.IdPedido
        WHERE AP.IdAceptacionPedido = @IdAceptacionPedido;
        IF EXISTS -- se valida si el proveedor es de DEA
        (
            SELECT 1
            FROM dbo.DEA_Proveedor
            WHERE IdProveedor = @IdProveedorOperador
        )
            BEGIN
                SET @IdFlujoTarea =
                (
                    SELECT RCFA.IdFlujoComprobante
                    FROM dbo.MM_SolicitudPedido SP
                         LEFT JOIN dbo.MM_Pedido P ON P.IdSolicitudPedido = SP.IdSolicitudPedido
                         LEFT JOIN dbo.MM_AceptacionPedido AP ON AP.IdPedido = P.IdPedido
                         LEFT JOIN dbo.MM_SolicitudPedidoDetalle SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
                         LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL ON SPDL.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
                         LEFT JOIN dbo.RelacionCentroCostoFlujoAprob RCFA ON RCFA.IdCentroCosto = SPDL.IdCentroCosto
                    WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
                          AND RCFA.IdFlujoComprobante IS NOT NULL
                          AND RCFA.Activo = 1
                    GROUP BY RCFA.IdFlujoComprobante, 
                             RCFA.IdCentroCosto
                );
        END;
            ELSE
            BEGIN
                SET @IdFlujoTarea =
                (
                    SELECT FT.IdFlujoTarea
                    FROM dbo.TA_FlujoTarea FT
                    WHERE FT.IdProveedor = @IdProveedorOperador
                          AND FT.Predeterminado = 1
                          AND FT.IdTipoOperacion = 16
                ); --DONDE 16 ES PEDIMENTO/COMPROBANTE 
        END;
        SELECT ISNULL(@IdFlujoTarea, 0);
    END;