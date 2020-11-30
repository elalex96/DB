-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <25/11/19>
-- Description:	<Notifica al usuario si existe una nueva factura sin flujo de aprobacion asignado>
-- =============================================
CREATE PROCEDURE SP_FI_NotificacionFacturaSinFlujo @IdProveedor   INT, 
                                                   @IdUsuario     INT, 
                                                   @IdContrato    INT      = NULL, 
                                                   @FechaRegistro DATETIME = NULL
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        DECLARE @FacturasComprobantes TABLE
        (IdOperacion        INT, 
         IdFactura          INT, 
         IdComprobante      INT, 
         IdAceptacionPedido INT, 
         UUID               NVARCHAR(MAX), 
         Proveedor          NVARCHAR(500), 
         [message]          NVARCHAR(MAX), 
         [date]             NVARCHAR(100), 
         FechaRegistro      DATETIME
        );
        INSERT INTO @FacturasComprobantes
        (IdOperacion, 
         IdFactura, 
         IdComprobante, 
         IdAceptacionPedido, 
         UUID, 
         Proveedor, 
         message, 
         date, 
         FechaRegistro
        )
               SELECT O.IdOperacion, 
                      AF.IdFactura, 
                      NULL, 
                      AP.IdAceptacionPedido, 
                      FI.UUID, 
                      P.RazonSocial AS Proveedor, 
                      'Factura ' + LTRIM(AP.IdAceptacionPedido) + ' sin flujo de aprobación,pendiente de asignar' AS [message],
                      CASE
                          WHEN DATEDIFF(DAY, O.FechaRegistro, GETDATE()) = 1
                          THEN 'Hace ' + LTRIM(DATEDIFF(DAY, O.FechaRegistro, GETDATE())) + ' día'
                          WHEN DATEDIFF(DAY, O.FechaRegistro, GETDATE()) > 1
                          THEN 'Hace ' + LTRIM(DATEDIFF(DAY, O.FechaRegistro, GETDATE())) + ' dias'
                          WHEN DATEDIFF(DAY, O.FechaRegistro, GETDATE()) < 1
                          THEN CASE
                                   WHEN DATEDIFF(HOUR, O.FechaRegistro, GETDATE()) = 1
                                   THEN 'Hace ' + LTRIM(DATEDIFF(HOUR, O.FechaRegistro, GETDATE())) + ' hora'
                                   WHEN DATEDIFF(HOUR, O.FechaRegistro, GETDATE()) > 1
                                   THEN 'Hace ' + LTRIM(DATEDIFF(HOUR, O.FechaRegistro, GETDATE())) + ' horas'
                                   WHEN DATEDIFF(HOUR, O.FechaRegistro, GETDATE()) < 1
                                   THEN CASE
                                            WHEN DATEDIFF(MINUTE, O.FechaRegistro, GETDATE()) = 1
                                            THEN 'Hace ' + LTRIM(DATEDIFF(MINUTE, O.FechaRegistro, GETDATE())) + ' minuto'
                                            WHEN DATEDIFF(MINUTE, O.FechaRegistro, GETDATE()) > 1
                                            THEN 'Hace ' + LTRIM(DATEDIFF(MINUTE, O.FechaRegistro, GETDATE())) + ' minutos'
                                            ELSE 'Hace menos de 1 minuto'
                                        END
                                   ELSE ''
                               END
                          ELSE ''
                      END AS [date], 
                      O.FechaRegistro
               FROM dbo.TA_Operacion O
                    LEFT JOIN dbo.MM_AceptacionFactura AF ON O.IdDocumento = AF.IdAceptacionFactura
                    LEFT JOIN dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                    LEFT JOIN dbo.FI_Factura FI ON FI.IdFactura = AF.IdFactura
                    LEFT JOIN dbo.S_Proveedor P ON P.IdProveedor = AP.IdProveedor
               WHERE AP.IdProveedor = @IdProveedor
                     AND IdTipoOperacion = 10
                     AND IdFlujoTarea IS NULL
                     AND IdEstadoFlujo IS NULL
                     AND IdEstatusOperacion = 9;
        INSERT INTO @FacturasComprobantes
        (IdOperacion, 
         IdFactura, 
         IdComprobante, 
         IdAceptacionPedido, 
         UUID, 
         Proveedor, 
         message, 
         date, 
         FechaRegistro
        )
               SELECT O.IdOperacion, 
                      NULL, 
                      PC.IdPedimentoComprobante, 
                      AP.IdAceptacionPedido, 
                      NULL, 
                      P.RazonSocial AS Proveedor, 
                      'Pedimento/comprobante ' + LTRIM(AP.IdAceptacionPedido) + ' sin flujo de aprobación,pendiente de asignar' AS [message],
                      CASE
                          WHEN DATEDIFF(DAY, O.FechaRegistro, GETDATE()) = 1
                          THEN 'Hace ' + LTRIM(DATEDIFF(DAY, O.FechaRegistro, GETDATE())) + ' día'
                          WHEN DATEDIFF(DAY, O.FechaRegistro, GETDATE()) > 1
                          THEN 'Hace ' + LTRIM(DATEDIFF(DAY, O.FechaRegistro, GETDATE())) + ' dias'
                          WHEN DATEDIFF(DAY, O.FechaRegistro, GETDATE()) < 1
                          THEN CASE
                                   WHEN DATEDIFF(HOUR, O.FechaRegistro, GETDATE()) = 1
                                   THEN 'Hace ' + LTRIM(DATEDIFF(HOUR, O.FechaRegistro, GETDATE())) + ' hora'
                                   WHEN DATEDIFF(HOUR, O.FechaRegistro, GETDATE()) > 1
                                   THEN 'Hace ' + LTRIM(DATEDIFF(HOUR, O.FechaRegistro, GETDATE())) + ' horas'
                                   WHEN DATEDIFF(HOUR, O.FechaRegistro, GETDATE()) < 1
                                   THEN CASE
                                            WHEN DATEDIFF(MINUTE, O.FechaRegistro, GETDATE()) = 1
                                            THEN 'Hace ' + LTRIM(DATEDIFF(MINUTE, O.FechaRegistro, GETDATE())) + ' minuto'
                                            WHEN DATEDIFF(MINUTE, O.FechaRegistro, GETDATE()) > 1
                                            THEN 'Hace ' + LTRIM(DATEDIFF(MINUTE, O.FechaRegistro, GETDATE())) + ' minutos'
                                            ELSE 'Hace menos de 1 minuto'
                                        END
                                   ELSE ''
                               END
                          ELSE ''
                      END AS [date], 
                      O.FechaRegistro
               FROM dbo.TA_Operacion O
                    LEFT JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC ON O.IdDocumento = APC.IdPedimentoComprobante
                    LEFT JOIN dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
                    LEFT JOIN dbo.FI_PedimentoComprobante PC ON PC.IdPedimentoComprobante = APC.IdPedimentoComprobante
                    LEFT JOIN dbo.S_Proveedor P ON P.IdProveedor = AP.IdProveedor
               WHERE AP.IdProveedor = @IdProveedor
                     AND O.IdTipoOperacion = 16
                     AND O.IdFlujoTarea IS NULL
                     AND O.IdEstadoFlujo IS NULL
                     AND O.IdEstatusOperacion = 9;
        SELECT *
        FROM @FacturasComprobantes
        ORDER BY FechaRegistro DESC;
    END;
