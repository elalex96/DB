-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 11/09/2019
-- Description:	Permite agregar LA OPERACION para hacer relacion con un flujo de tareas
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 27-04-2022
-- Description:	Issue #1739  Optimizacion pantallas se ordena y revisa joins 
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultarNotaCreditoOperadora]
    -- Add the parameters for the stored procedure here
	
    @IdProveedor INT,
    @IdUsuario INT,
    @IdAceptacionPedido INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    SELECT		  
		   O.Descripcion,
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
		   F.UUID
    FROM dbo.MM_AceptacionNotaCredito NC (NOLOCK)
        JOIN dbo.MM_AceptacionPedido AP  (NOLOCK)
            ON  NC.IdAceptacionPedido = AP.IdAceptacionPedido
        JOIN dbo.MM_Pedido P  (NOLOCK)
            ON  AP.IdPedido = P.IdPedido
        JOIN dbo.TA_Operacion O  (NOLOCK)
            ON NC.IdAceptacionNotaCredito = O.IdDocumento 
               AND O.IdTipoOperacion = 17 --> CTE APROBACIÓN NOTA DE CREDITO
        JOIN dbo.TA_Estatus E  (NOLOCK)
            ON  O.IdEstatusOperacion = E.IdEstatus
        JOIN dbo.FI_Factura F  (NOLOCK)
            ON NC.IdFacturaNotaCredito = F.IdFactura 
        LEFT JOIN dbo.S_Usuario UC  (NOLOCK)
            ON NC.CreadoPor = UC.IdUsuario 
    WHERE NC.IdAceptacionPedido = @IdAceptacionPedido
          AND P.IdProveedorCompras = @IdProveedor
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
			 F.UUID
	ORDER BY NC.CreadoEl DESC
    

END;

