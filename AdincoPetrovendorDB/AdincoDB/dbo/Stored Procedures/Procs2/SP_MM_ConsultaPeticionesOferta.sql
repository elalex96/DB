-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Pedido  
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaPeticionesOferta]
	-- Add the parameters for the stored procedure here
@IdProveedor INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	--SELECT PO.IdPeticionOferta, PO.IdSolicitudPedido, PO.CreadoEl, TSP.TipoSolicitudPedido,SP.MotivoUrgencia, PO.Iniciada
	--FROM MM_PeticionOferta AS PO
	--INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
	--INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido =SP.IdTipoSolicitudPedido
	--WHERE PO.IdSubcontratista=44 
	
	---- OT.IdEstatusOperacion= 2 ---> Aprobada por aprobadores internos
	---- PeticionEnviada Cuando la Solicitud de pedido es enviada a una petición de oferta con sus respectivos proveedores de ventas

         SELECT SP.IdSolicitudPedido,
                SP.MotivoUrgencia,
                TSP.TipoSolicitudPedido,
                PSP.Prioridad,
                ISNULL(SP.PeticionEnviada, 'false') AS PeticionEnviada,
                SP.FechaAlta,
                (CASE SP.UnaSolaEntregaRequerida
                     WHEN 1
                     THEN CONVERT(NVARCHAR, SP.FechaEntregaRequerida, 103)
                     WHEN 0
                     THEN CONCAT(CONVERT(NVARCHAR, SP.FechaEntregaRequerida, 103), ' -- ', CONVERT(NVARCHAR, SP.FechaEntregaFinRequerida, 103))
                 END) AS FechaEntrega
                --CONCAT(CONVERT(NVARCHAR, SP.FechaEntregaRequerida, 103), ' -- ', CONVERT(NVARCHAR, SP.FechaEntregaFinRequerida, 103)) AS Fechas
         FROM MM_SolicitudPedido AS SP
              INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
              INNER JOIN MM_PrioridadSolicitudPedido AS PSP ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
              INNER JOIN TA_Operacion AS OT ON OT.IdDocumento = SP.IdSolicitudPedido
         WHERE SP.IdProveedor = @IdProveedor
               AND OT.IdEstatusOperacion = 2
               AND SP.Activo = 1
		 ORDER BY SP.IdSolicitudPedido DESC 
     END;
