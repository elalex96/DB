    
-- =============================================
-- Author:             Daniel AC
-- Create date: 20-12-17
-- Description: CONSULTA materiales para Aceptación de Pedido
-- =============================================
-- Author:             Jose Roman
-- Create date: 15-10-18
-- Description: CONSULTA materiales para Aceptación de Pedido
-- =============================================
-- =============================================
-- Author:           Daniel AC
-- Create date: 02-10-2019
-- Description: Add Marca, Modelo, No Parte a Descripción material, Add Numero de Partida
-- =============================================
-- =============================================
-- Author:           Daniel AC
-- Create date: 02-10-2019
-- Description: Se agrego validación para descartar las aceptaciones eliminadas y no contarlas en los inficadores de aceptado y restante
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Aceptacion_ConsultaPedidoDetalle_MV1_5]  
-- Add the parameters for the stored procedure here
@IdPedido      INT, 
@IdProveedor   INT,
@IdContrato    INT, 
@IdUsuario     INT, 
@FechaRegistro DATETIME

AS
     BEGIN

	 	SELECT PD.IdPedidoDetalle, 
                PD.IdMaterialVendedor, 
                CONCAT( 'No. Material: ',spd.idmaterial, ' ',   
						M.DescripcionCorta,
                        ' Marca: ', CASE WHEN ISNULL(LEN(M.Marca),0)>0 THEN M.Marca ELSE ' S/M' END,
                        ' Modelo: ', CASE WHEN ISNULL(LEN(M.Modelo),0)>0 THEN M.Modelo ELSE ' S/M' END,
                        ' No. Parte: ',CASE WHEN ISNULL(LEN(M.NumeroParte),0)>0 THEN M.NumeroParte  ELSE ' S/NP' END) AS MaterialSolicitadoCorto, 
                M.DescripcionLarga AS MaterialSolicitadoLarga, 
                CONCAT('Instalación: ', INS.NombreInstalacion COLLATE DATABASE_DEFAULT,
					' / Requisitor: ', US.Nombre, ' / Comentarios: ', spd.observaciones ) AS observaciones, 
                 CONCAT('P.U. $', POD.PrecioUnitario, ' Cantidad: ', pd.Cantidad, ' ' , POD.MaterialCotizadoTextoC ) AS DescripcionCortaCotizado,
				 --ISNULL(PD.Cantidad,0) AS CantidadEnPedido,
				 CAST( SUM(ISNULL(APD.Cantidad,0)) AS NVARCHAR(100) ) AS CantidadAceptada,
				 CAST( (ISNULL(PD.Cantidad,0) - SUM(ISNULL(APD.Cantidad,0))) AS NVARCHAR(100) ) AS CantidadRestante,
				 ROW_NUMBER() OVER (ORDER BY PD.IdPedidoDetalle ASC) AS Partida
         FROM dbo.MM_Pedido AS P
              INNER JOIN dbo.MM_PedidoDetalle AS pd ON pd.IdPedido = P.IdPedido
              INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
              INNER JOIN dbo.MM_SolicitudPedidoDetalle AS spd ON spd.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
              LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPLP ON SPLP.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
              LEFT JOIN Adinco.dbo.CO_Instalacion INS ON INS.IdInstalacion = SPLP.IdInstalacion
              INNER JOIN dbo.MM_Material m ON m.IdMaterial = spd.IdMaterial
              LEFT JOIN dbo.MM_SolicitudPedido SOL ON SOL.IdSolicitudPedido = P.IdSolicitudPedido
              LEFT JOIN dbo.S_Usuario US ON US.IdUsuario = SOL.IdUsuarioSolicitante
			  LEFT JOIN dbo.MM_AceptacionPedido AP ON AP.IdPedido=P.IdPedido AND AP.IdEstatusEliminado IS NULL --> QUE LA ACEPTACIÓN NO ESTE ELIMINADA
			  LEFT JOIN dbo.MM_AceptacionPedidoDetalle APD ON PD.IdPedidoDetalle = APD.IdPedidoDetalle 
			  AND AP.IdAceptacionPedido=APD.IdAceptacionPedido
         WHERE P.IdPedido = @IdPedido
               AND P.IdProveedorCompras = @IdProveedor
               AND P.RecepcionServicio = 1
               AND PD.RecepcionPedido = 1
			   GROUP BY 
			   spd.idmaterial, 
			   m.DescripcionCorta,
               INS.NombreInstalacion,
               US.Nombre,
               spd.observaciones,
               POD.PrecioUnitario,
			   POD.MaterialCotizadoTextoC,
               pd.Cantidad,
			   pd.IdPedidoDetalle,
			   pd.IdMaterialVendedor,
			   m.DescripcionLarga,
			   M.Marca,
			   M.Modelo,
			   M.NumeroParte
     END;



