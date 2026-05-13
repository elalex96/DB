-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Oferta  
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaOfertas]
	-- Add the parameters for the stored procedure here
@IdProveedor INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT SP.IdSolicitudPedido,
                TSP.TipoSolicitudPedido,
                O.Descripcion,
                O.FechaRegistro,
                DATEADD(day, V.DiaVencimiento, O.FechaRegistro) AS FechaFinOferta,
                CASE E.Nombre
                    WHEN 'Aprobada'
                    THEN 'Completada'
                    ELSE E.Nombre
                END AS Nombre
         FROM MM_SolicitudPedido AS SP
              INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
              INNER JOIN TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
                                              AND O.IdTipoOperacion = 6
              INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = o.IdVigencia
              INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
         WHERE SP.IdProveedor = @IdProveedor
         ORDER BY SP.IdSolicitudPedido DESC;


	--- IdTipoOperacion = 6 --> Peticion Oferta


     END;
