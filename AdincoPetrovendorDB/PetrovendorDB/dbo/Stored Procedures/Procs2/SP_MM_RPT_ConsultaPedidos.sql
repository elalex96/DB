-- =============================================
-- Author:		Alexander Gomez
-- Create date: 02-04-2018
-- Description:	Consultar Pedidos por proveedor para reporte
-- Author:		Daniel AC
-- Create date: 05-06-2018
-- Description:	Agregue columna de activo o eliminado
-- =============================================
-- Author:		Marcos Neri
-- Create date: 10-06-2019
-- Description:	Agregar en Descripcion Corta Numero de Material
-- =============================================
-- Author:		Marcos Neri
-- Create date: 24-06-2019
-- Description:	Agregar en TipoPedido(Tipo de Compra) el tipo de pedido (Capex /Opex)
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_RPT_ConsultaPedidos] 
	-- Add the parameters for the stored procedure here
	@IdProveedor int,
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--  PG.IdTipoPedido = 2 --> Pedido de Tipo Mercadeo

			SELECT 
			 CASE
				WHEN APD.IdAceptacionPedido IS NULL THEN 'Aceptación en Espera'
				ELSE CAST(APD.IdAceptacionPedido AS NVARCHAR(MAX))
			 END AS IdAceptacionPedido,
			 PG.IdPedido,
			 P.IdSolicitudPedido,
			 P.CreadoEl AS CreadoEl, 
			 P.FechaEnvioPedido AS FechaEnvioPedido,
			 SUM(PD.Subtotal) AS TotalPedido,
			 ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS Proveedor,
			 CONCAT('Numero de Servicio/Material: ',MA.IdMaterial,' | Descripcion: ', MA.DescripcionCorta) AS DescripcionCorta ,
			 CASE 
				WHEN P.RecepcionServicio = 1 THEN 'Confirmación Aceptada' 
				WHEN P.RecepcionServicio  = 0 THEN 'Confirmación Rechazada' 
				WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  >= 0 AND O.IdEstatusOperacion = 2 THEN	
					 'Confirmación Vencida '  
				WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  <= 0 AND O.IdEstatusOperacion = 2 THEN	
					 'En Confirmación'  
				ELSE 	  
					 'Confirmación No Iniciada ' 
			   END AS RecepcionServicio,
			 E.Nombre,
			 P.Version,
			 TM.TipoMonedaCorto AS TipoMoneda,
			 PG.IdPedido AS IdPedidoGeneral,
			 CONCAT('Tipo de Compra: ',TP.TipoPedido,' | Tipo de Pedido: ',TG.TipoGasto)AS TipoPedido,
			 TP.IdTipoPedido,
			 CASE WHEN ISNULL(P.IdEstatusEliminado,0)<> 1 THEN   
			 'Activo'
			 WHEN ISNULL(P.IdEstatusEliminado,0) = 1 THEN 
			 'Eliminado'
			 END AS Activo
			FROM MM_Pedido AS P
			LEFT JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
			LEFT JOIN dbo.MM_TipoGastos AS TG ON TG.IdTipoGasto = SP.IdTipoGasto
			INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
			INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
			INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
			INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
			INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
			INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
			INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
			INNER JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido
			INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda			
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
			LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
			LEFT JOIN dbo.MM_AceptacionPedido AS APD ON APD.IdPedido = P.IdPedido
			LEFT JOIN dbo.MM_Material AS MA ON MA.IdMaterial = PD.IdMaterial
			WHERE O.IdTipoOperacion = 9 
			AND O.IdProveedor = @IdProveedor						 
			AND P.Version=O.NoVersion
			GROUP BY 
				IdAceptacionPedido,
				P.IdPedido, 
				P.IdSolicitudPedido, 
				P.FechaEnvioPedido, 
				MA.IdMaterial,
				RazonSocial,
				RegimenCapital, 
				P.RecepcionServicio,  
				E.Nombre,
				P.Version,
				TM.TipoMonedaCorto,
				HV.FechaVigencia, 
				O.IdEstatusOperacion,
				P.CreadoEl,
				PG.IdPedido,
				TP.TipoPedido,
				TG.TipoGasto,
				TP.IdTipoPedido,
				MA.DescripcionCorta,
				P.IdEstatusEliminado
			ORDER BY PG.IdPedido DESC

		
		
	--- IdTipoOperacion = 7--> Pedido


END


