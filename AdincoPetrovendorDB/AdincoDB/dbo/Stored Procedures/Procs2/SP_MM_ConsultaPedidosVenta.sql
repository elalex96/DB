-- =============================================
-- Author:		Daniel AC
-- Create date: 25-05-17
-- Description:	Consulta detalle Pedido vendedor
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaPedidosVenta]
	-- Add the parameters for the stored procedure here
@IdProveedor INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT P.IdPedido,
                S.RazonSocial+' '+S.RegimenCapital AS Cliente,
                O.Descripcion,
                O.FechaRegistro,
                FechaEntregaRequerida,
                FechaEntregaFinRequerida
         FROM MM_Pedido AS P
              INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
              INNER JOIN PV_Subcontratista AS S ON S.IdSubcontratista = SP.IdProveedor
              INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
         WHERE P.IdSubcontratista = @IdProveedor
               AND O.IdTipoOperacion = 7;
     END;
