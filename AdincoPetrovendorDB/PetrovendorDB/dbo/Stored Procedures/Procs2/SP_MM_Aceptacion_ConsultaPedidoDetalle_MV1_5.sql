USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_Aceptacion_ConsultaPedidoDetalle_MV1_5]    Script Date: 19/08/2021 06:45:35 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author: Daniel AC  
-- Create date: 05-01-2021  
-- Description: Se agrego información del yacimiento, en la columna de observación  
-- =============================================  
ALTER PROCEDURE [dbo].[SP_MM_Aceptacion_ConsultaPedidoDetalle_MV1_5] --22521,1835
-- Add the parameters for the stored procedure here  
@IdPedido      INT,
@IdProveedor   INT,
@IdContrato    INT = NULL,
@IdUsuario     INT = NULL,
@FechaRegistro DATETIME = NULL
AS  
     BEGIN

		  SELECT 
		  PD.IdPedidoDetalle,   
          PD.IdMaterialVendedor,   
          CONCAT( 'No. Material: ',spd.idmaterial, ' ',     
          M.DescripcionCorta,  
          ' Marca: ', CASE WHEN ISNULL(LEN(M.Marca),0)>0 THEN M.Marca ELSE ' S/M' END,  
          ' Modelo: ', CASE WHEN ISNULL(LEN(M.Modelo),0)>0 THEN M.Modelo ELSE ' S/M' END,  
          ' No. Parte: ',CASE WHEN ISNULL(LEN(M.NumeroParte),0)>0 THEN M.NumeroParte  ELSE ' S/NP' END) AS MaterialSolicitadoCorto,   
          M.DescripcionLarga AS MaterialSolicitadoLarga,   
          CONCAT('Instalación: ', INS.NombreInstalacion COLLATE DATABASE_DEFAULT,' / Yacimiento: ', ISNULL(Y.NombreYacimiento COLLATE DATABASE_DEFAULT,''),  
          ' / Requisitor: ', US.Nombre, ' / Comentarios: ', spd.observaciones ) AS observaciones,   
          CONCAT('P.U. $', POD.PrecioUnitario, ' Cantidad: ', pd.Cantidad, ' ' , POD.MaterialCotizadoTextoC ) AS DescripcionCortaCotizado,  
          --ISNULL(PD.Cantidad,0) AS CantidadEnPedido,  
		  CAST( SUM(ISNULL(APD.Cantidad,0)) AS NVARCHAR(100) ) AS CantidadAceptada,  
		  CAST( (ISNULL(PD.Cantidad,0) - SUM(ISNULL(APD.Cantidad,0))) AS NVARCHAR(100) ) AS CantidadRestante,  
		  ROW_NUMBER() OVER (ORDER BY PD.IdPedidoDetalle ASC) AS Partida  
          FROM dbo.MM_Pedido AS P WITH (NOLOCK)  
              JOIN dbo.MM_PedidoDetalle AS pd WITH (NOLOCK) ON P.IdPedido = pd.IdPedido AND PD.RecepcionPedido = 1   
              JOIN dbo.MM_PeticionOfertaDetalle AS POD WITH (NOLOCK) ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle  
              JOIN dbo.MM_SolicitudPedidoDetalle AS spd WITH (NOLOCK) ON POD.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle  
              JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPLP WITH (NOLOCK) ON spd.IdSolicitudPedidoDetalle = SPLP.IdSolicitudPedidoDetalle  
              JOIN Adinco.dbo.CO_Instalacion INS WITH (NOLOCK) ON SPLP.IdInstalacion = INS.IdInstalacion  
              JOIN dbo.MM_Material m WITH (NOLOCK) ON spd.IdMaterial = m.IdMaterial  
              JOIN dbo.MM_SolicitudPedido SOL WITH (NOLOCK) ON P.IdSolicitudPedido = SOL.IdSolicitudPedido  
			  LEFT JOIN Adinco..CO_Yacimiento Y ON INS.IdYacimiento=Y.IdYacimiento  
              LEFT JOIN dbo.S_Usuario US WITH (NOLOCK) ON SOL.IdUsuarioSolicitante = US.IdUsuario  
              LEFT JOIN dbo.MM_AceptacionPedido AP WITH (NOLOCK) ON AP.IdPedido=P.IdPedido AND AP.IdEstatusEliminado IS NULL --> QUE LA ACEPTACIÓN NO ESTE ELIMINADA  
              LEFT JOIN dbo.MM_AceptacionPedidoDetalle APD WITH (NOLOCK) ON PD.IdPedidoDetalle = APD.IdPedidoDetalle   
																		AND AP.IdAceptacionPedido=APD.IdAceptacionPedido  
          WHERE P.IdPedido = @IdPedido  
                AND P.IdProveedorCompras = @IdProveedor  
                AND P.RecepcionServicio = 1  
			    AND ISNULL(AP.IdEstatusEliminado,0)<>1  
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
		  M.NumeroParte,
		  Y.NombreYacimiento
END;