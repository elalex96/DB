-- =============================================
-- Author:		Daniel AC
-- Update date: 01-06-2018
-- Description:	Se agrego condición para no mostrar cotizaciones del proveedor con estatus eliminadas y se modifico condicion de la cotización [Abierta, Cerrada]
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Update date: 02-07-2018
-- Description:	Se agrega al grid el numero de la solicitud de pedido (Num requisicion)
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 18/02/2019
-- Description:	Se elimino de la consulta el regimen capital (ya no se usa)
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaSolicitudesPorEstatus] 
    @IdProveedor INT,
    @Estatus INT
AS
BEGIN

    IF (@Estatus = 1) ---Cotizaciones con un estatus diferente de cotizado = true & nocotizado = true
    BEGIN

        SELECT PO.IdPeticionOferta,
               PO.CreadoEl,
               O.FechaFinalizacion AS FechaLimite,
               RazonSocial AS RazonSocial,              
               O.Descripcion AS MotivoUrgencia,
               TSP.TipoSolicitudPedido,
			   SP.IdSolicitudPedido      
        FROM MM_PeticionOferta AS PO
            INNER JOIN MM_SolicitudPedido AS SP
                ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            INNER JOIN TA_Operacion AS O
                ON O.IdDocumento = PO.IdSolicitudPedido            
            INNER JOIN S_Proveedor AS P
                ON P.IdProveedor = SP.IdProveedor
            INNER JOIN MM_TipoSolicitudPedido AS TSP
                ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido       
        WHERE PO.IdSubcontratista = @IdProveedor
              AND O.IdTipoOperacion = 6
			  AND ISNULL(PO.Visible,1)=1
			  AND ISNULL(PO.IdEstatusEliminado,0)<>1 --> ESTATUS ELIMINADO
              AND DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) < 0
              AND
              (
                  PO.Cotizado = 0
                  OR PO.Cotizado IS NULL
              )
              AND
              (
                  PO.NoCotizar = 0
                  OR PO.NoCotizar IS NULL
              )
        ORDER BY PO.CreadoEl DESC;

    END;
    IF (@Estatus = 2) ---Cotizaciones con un estatus cotizado = true 
    BEGIN

        SELECT PO.IdPeticionOferta,
               PO.CreadoEl,
               O.FechaFinalizacion AS FechaLimite,
               RazonSocial AS RazonSocial,              
               O.Descripcion AS MotivoUrgencia,
               TSP.TipoSolicitudPedido,
			   SP.IdSolicitudPedido       
        FROM MM_PeticionOferta AS PO
            INNER JOIN MM_SolicitudPedido AS SP
                ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            INNER JOIN TA_Operacion AS O
                ON O.IdDocumento = PO.IdSolicitudPedido            
            INNER JOIN S_Proveedor AS P
                ON P.IdProveedor = SP.IdProveedor
            INNER JOIN MM_TipoSolicitudPedido AS TSP
                ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido        
        WHERE PO.IdSubcontratista = @IdProveedor
              AND O.IdTipoOperacion = 6
              AND PO.Cotizado = 1
			  AND ISNULL(PO.Visible,1)=1
			  AND ISNULL(PO.IdEstatusEliminado,0)<>1 --> ESTATUS ELIMINADO
        ORDER BY PO.CreadoEl DESC;

    END;
    IF (@Estatus = 3) -----Cotizaciones con un estatus false y no cotizar false pero conf fecha limite vencida---
    BEGIN

        SELECT PO.IdPeticionOferta,
               PO.CreadoEl,
               O.FechaFinalizacion AS FechaLimite,
               RazonSocial AS RazonSocial,             
               O.Descripcion AS MotivoUrgencia,
               TSP.TipoSolicitudPedido,
			   SP.IdSolicitudPedido      
        FROM MM_PeticionOferta AS PO
            INNER JOIN MM_SolicitudPedido AS SP
                ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            INNER JOIN TA_Operacion AS O
                ON O.IdDocumento = PO.IdSolicitudPedido           
            INNER JOIN S_Proveedor AS P
                ON P.IdProveedor = SP.IdProveedor
            INNER JOIN MM_TipoSolicitudPedido AS TSP
                ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido      
        WHERE PO.IdSubcontratista = @IdProveedor
              AND O.IdTipoOperacion = 6
			  AND ISNULL(PO.Visible,1)=1
			  AND ISNULL(PO.IdEstatusEliminado,0)<>1 --> ESTATUS ELIMINADO
              AND DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) >= 0
              AND
              (
                  PO.Cotizado = 0
                  OR PO.Cotizado IS NULL
              )
              AND
              (
                  PO.NoCotizar = 0
                  OR PO.NoCotizar IS NULL
              )
        ORDER BY PO.CreadoEl DESC;

    END;

    IF (@Estatus = 4) -----Cotizaciones con un estatus false y no cotizar true  
    BEGIN

        SELECT PO.IdPeticionOferta,
               PO.CreadoEl,
               O.FechaFinalizacion AS FechaLimite,
               RazonSocial AS RazonSocial,             
               O.Descripcion AS MotivoUrgencia,
               TSP.TipoSolicitudPedido,
			   SP.IdSolicitudPedido       
        FROM MM_PeticionOferta AS PO
            INNER JOIN MM_SolicitudPedido AS SP
                ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            INNER JOIN TA_Operacion AS O
                ON O.IdDocumento = PO.IdSolicitudPedido           
            INNER JOIN S_Proveedor AS P
                ON P.IdProveedor = SP.IdProveedor
            INNER JOIN MM_TipoSolicitudPedido AS TSP
                ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido      
        WHERE PO.IdSubcontratista = @IdProveedor
              AND O.IdTipoOperacion = 6
              AND PO.Cotizado = 0
              AND PO.NoCotizar = 1
			  AND ISNULL(PO.IdEstatusEliminado,0)<>1 --> ESTATUS ELIMINADO
			  AND ISNULL(PO.Visible,1)=1
        ORDER BY PO.CreadoEl DESC;

    END;

    IF (@Estatus = 0) -----Todas las Cotizaciones
    BEGIN

        SELECT PO.IdPeticionOferta,
               PO.CreadoEl,
               O.FechaFinalizacion AS FechaLimite,
               RazonSocial AS RazonSocial,
               O.Descripcion AS MotivoUrgencia,
               TSP.TipoSolicitudPedido,
               CASE
                   WHEN PO.Cotizado = 1  THEN
                       'Cotizada'
                   WHEN PO.Cotizado = 0  THEN
                       'No Cotizada'
                   WHEN PO.Cotizado IS NULL AND PO.NoCotizar IS NULL
                        AND DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) < 0 THEN
                       'En cotización'
                   WHEN PO.Cotizado IS NULL AND DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) >= 0 THEN
                       'Vencida'				    
               END AS EstatusCotizacion,
			   CASE
                   WHEN COUNT(PED.IdPedido) = 0 THEN 
				   /*SE CAMBIO A COUNT YA QUE SI COOCAS EL IDPEDIDO SE DUPLICA LA COTIZACIÓN DEACUERSDO A LA CANTIDAD DE PEDIDO EXISTENTES*/
                       'Cotización Abierta'
                   WHEN COUNT(PED.IdPedido) > 0 THEN
                       'Cotización Cerrada'
               END AS Disponibilidad,
			   SP.IdSolicitudPedido
        FROM MM_PeticionOferta AS PO
            LEFT JOIN MM_SolicitudPedido AS SP
                ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            LEFT JOIN TA_Operacion AS O
                ON O.IdDocumento = PO.IdSolicitudPedido
            LEFT JOIN S_Proveedor AS P
                ON P.IdProveedor = SP.IdProveedor
            LEFT JOIN MM_TipoSolicitudPedido AS TSP
                ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
			LEFT JOIN dbo.MM_Pedido AS PED
				ON PED.IdSolicitudPedido = PO.IdSolicitudPedido AND ISNULL(PED.IdEstatusEliminado,0) = 0
			LEFT JOIN dbo.MM_Pedido AS PEDD
				ON PEDD.IdPeticionOferta = PO.IdPeticionOferta
        WHERE PO.IdSubcontratista = @IdProveedor AND
              O.IdTipoOperacion = 6
              AND O.FechaFinalizacion IS NOT NULL 
			  AND ISNULL(PO.Visible,1)=1
			  AND ISNULL(PO.IdEstatusEliminado,0)<> 1 --> QUE NO ESTE ELIMINADO
		GROUP BY 
		      PO.IdPeticionOferta,
               PO.CreadoEl,
               O.FechaFinalizacion,
               RazonSocial,
			   RegimenCapital,
               O.Descripcion,
               TSP.TipoSolicitudPedido,
			   PO.Cotizado,
			   PO.IdEstatusEliminado,			  
			   O.FechaFinalizacion,
			   PO.NoCotizar,
			   SP.IdSolicitudPedido
        ORDER BY PO.CreadoEl DESC;

    END;
END;



