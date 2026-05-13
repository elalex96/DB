-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 11/09/2019
-- Description:	Permite agregar LA OPERACION para hacer relacion con un flujo de tareas
-- =============================================

-- [p_MPY_TA_ConsultarNotaCreditoOperadora] 1,88
crEATE PROCEDURE [dbo].[p_MPY_TA_ConsultarNotaCreditoOperadora]
    -- Add the parameters for the stored procedure here   
    @IdUsuario INT,
    @IdAceptacionPedido INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    SELECT		  
		   Descripcion = isnull(nc.Comentario,'')  ,
           E.Nombre AS Estatus,
           NC.CreadoEl,
           UC.Nombre AS CargadoPor,
           F.IdFactura,
           F.SubTotal,
           F.MontoConIva,
           NC.IdAceptacionNotaCredito,
           O.IdOperacion,
           nc.FechaAprobacion AS FechaCambioEstatus,
           isnull(nc.Comentario,'') AS ComentarioAprobador,
		   F.Moneda,
		   F.UUID
    FROM dbo.MPY_MM_AceptacionNotaCredito NC
        LEFT JOIN dbo.MPY_MM_AceptacionPedido AP
            ON AP.IdAceptacionPedido = NC.IdAceptacionPedido
        --LEFT JOIN dbo.MM_Pedido P
        --    ON P.IdPedido = AP.IdPedido
        LEFT JOIN dbo.TA_Operacion O
            ON O.IdDocumento = NC.IdAceptacionNotaCredito
               AND O.IdTipoOperacion = 17 --> APROBACIÓN NOTA DE CREDITO
        LEFT JOIN dbo.TA_Estatus E
            ON E.IdEstatus = NC.IdEstatus
        LEFT JOIN dbo.FI_Factura F
            ON F.IdFactura = NC.IdFacturaNotaCredito
        LEFT JOIN dbo.S_Usuario UC
            ON UC.IdUsuario = NC.CreadoPor
    WHERE NC.IdAceptacionPedido = @IdAceptacionPedido
          --AND P.IdProveedorCompras = @IdProveedor
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
			 nc.Comentario,
			 nc.FechaAprobacion
	ORDER BY NC.CreadoEl DESC
    

END;


