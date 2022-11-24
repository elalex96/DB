-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 11/09/2019
-- Description:	Permite agregar LA OPERACION para hacer relacion con un flujo de tareas
-- =============================================
-- Author:		Luis David
-- Create date: 04/11/2021
-- Description:	Reacomodo de tablas para optimización
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultarNotaCreditoProveedor]
    -- Add the parameters for the stored procedure here
	@IdProveedor INT,
    @IdUsuario INT,
    @IdAceptacionPedido INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    SELECT O.Descripcion,
           E.Nombre AS Estatus,
           NC.CreadoEl,
           UC.Nombre AS CargadoPor,
           F.IdFactura,
           F.SubTotal,
           F.MontoConIva,
           NC.IdAceptacionNotaCredito,
           O.IdOperacion,
           O.FechaModificacion AS FechaCambioEstatus,
           '' AS ComentarioAprobador,
           F.Moneda,
           F.UUID,
           NC.CFDIRelacionados
    FROM dbo.MM_AceptacionNotaCredito NC
        LEFT JOIN dbo.MM_AceptacionPedido AP
            ON NC.IdAceptacionPedido = AP.IdAceptacionPedido 
        LEFT JOIN dbo.MM_Pedido P
            ON AP.IdPedido = P.IdPedido
        LEFT JOIN dbo.TA_Operacion O
            ON NC.IdAceptacionNotaCredito = O.IdDocumento
               AND 17 = O.IdTipoOperacion --> APROBACIÓN NOTA DE CREDITO
        LEFT JOIN dbo.TA_Estatus E
            ON O.IdEstatusOperacion = E.IdEstatus
        LEFT JOIN dbo.FI_Factura F
            ON NC.IdFacturaNotaCredito = F.IdFactura
        LEFT JOIN dbo.S_Usuario UC
            ON NC.CreadoPor = UC.IdUsuario
    WHERE NC.IdAceptacionPedido = @IdAceptacionPedido
          AND P.IdSubcontratista = @IdProveedor
          AND ISNULL(NC.IdEstatusEliminada, 0) = 0
    GROUP BY O.Descripcion,
             E.Nombre,
             NC.CreadoEl,
             UC.Nombre,
             F.IdFactura,
             NC.IdAceptacionNotaCredito,
             O.IdOperacion,
             F.SubTotal,
             F.MontoConIva,
             O.FechaModificacion,
             F.Moneda,
             F.UUID,
             NC.CFDIRelacionados
	ORDER BY NC.CreadoEl DESC

END;