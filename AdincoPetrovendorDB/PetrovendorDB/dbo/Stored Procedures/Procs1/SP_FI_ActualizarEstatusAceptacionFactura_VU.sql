-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017 - UPDATE 13/08/2017
-- Description:	Permite agregar un condicion a un flujo de tareas
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ActualizarEstatusAceptacionFactura_VU] 
-- Add the parameters for the stored procedure here

@IdUsuario          INT, 
@IdAceptacionPedido INT
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        DECLARE @IdAceptacionFactura INT=
        (
            SELECT IdAceptacionFactura
            FROM MM_AceptacionFactura
            WHERE IdAceptacionPedido = @IdAceptacionPedido
        );
        UPDATE MM_AceptacionFactura
          SET 
              [IdEstatusXML] = 1, 
              [IdEstatusPDF] = 1, 
              [ModificadoPor] = @IdUsuario, 
              [ModificadoEl] = GETDATE()
        WHERE IdAceptacionFactura = @IdAceptacionFactura;
        DECLARE @IdProveedor INT=
        (
            SELECT IdProveedor
            FROM dbo.MM_AceptacionPedido
            WHERE IdAceptacionPedido = @IdAceptacionPedido
        );
        DECLARE @IdFlujoAprobacion INT;
        IF EXISTS -- se valida si el proveedor es de DEA
        (
            SELECT 1
            FROM dbo.DEA_Proveedor
            WHERE IdProveedor = @IdProveedor
        )
            BEGIN
                -- consultamos el flujo de aprobacion de fatura relacionado con el centro de costo de la requisicion
                SET @IdFlujoAprobacion =
                (
                    SELECT RCFA.IdFlujoFactura
                    FROM dbo.MM_SolicitudPedido SP
                         LEFT JOIN dbo.MM_Pedido P ON P.IdSolicitudPedido = SP.IdSolicitudPedido
                         LEFT JOIN dbo.MM_AceptacionPedido AP ON AP.IdPedido = P.IdPedido
                         LEFT JOIN dbo.MM_SolicitudPedidoDetalle SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
                         LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL ON SPDL.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
                         LEFT JOIN dbo.RelacionCentroCostoFlujoAprob RCFA ON RCFA.IdCentroCosto = SPDL.IdCentroCosto
                    WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
                          AND RCFA.IdFlujoFactura IS NOT NULL
                          AND RCFA.Activo = 1
                    GROUP BY RCFA.IdFlujoFactura, 
                             RCFA.IdCentroCosto
                );
        END;
            ELSE
            BEGIN
                SET @IdFlujoAprobacion =
                (
                    SELECT FT.IdFlujoTarea
                    FROM MM_AceptacionFactura AS AF
                         INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                         INNER JOIN MM_Pedido AS P ON P.IdPedido = AP.IdPedido
                         INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = P.IdProveedorCompras
                         INNER JOIN TA_FlujoTarea AS FT ON FT.IdProveedor = P.IdProveedorCompras
                    WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
                          AND FT.IdTipoOperacion = 10
                          AND FT.Activo = 1
                          AND FT.Predeterminado = 1
                );
        END;

        ---IdTipoOperacion --> Operación de Aprobación Factura

        SELECT @IdAceptacionFactura, 
               ISNULL(@IdFlujoAprobacion, 0) AS RESPONSE;
    END;