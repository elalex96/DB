-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Pedido por busqueda de solicitud de pedido 
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ConsultaProcesosFiltro]  
	-- Add the parameters for the stored procedure here
	@IdProveedor INT, 	
    @IdContrato  INT = NULL,   
    @IdSolicitudPedido INT = NULL,
	@IdUsuario INT =NULL,
	@IdPedido INT = NULL,
	@IdAceptacionPedido INT = NULL,
	@IdProveedorVentas INT = NULL,
	@TipoFiltro NVARCHAR(200)  
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;	
  
  -- TipoOperacion --> 2 = Solicitud de Pedido

  IF @TipoFiltro  ='SOLICITUD_PEDIDO'
  BEGIN 
		SELECT 
			SP.IdSolicitudPedido, 
			SP.MotivoUrgencia,
			TSP.TipoSolicitudPedido, 
			SP.FechaAlta,
			TE.Nombre,
			CC.CentroCosto,
			U.Nombre AS NombreUsuario,
			TAO.Descripcion,
			AC.NombreAreaContractual AS AreaContractual 				 
		FROM MM_SolicitudPedido AS SP 
			INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido =SP.IdTipoSolicitudPedido 
			INNER JOIN TA_Operacion AS TAO ON TAO.IdDocumento= SP.IdSolicitudPedido  
			INNER JOIN TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion  
			LEFT JOIN CC_CentroCosto AS CC ON SP.IdCentroCosto = CC.IdCentroCosto
			INNER JOIN S_Usuario AS U ON SP.IdUsuarioSolicitante = U.IdUsuario
			LEFT JOIN Adinco.dbo.CO_Contrato AS C ON SP.IdContrato = C.IdContrato    
			LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON C.IdAreaContractual = AC.IdAreaContractual
		WHERE
			SP.IdProveedor = @IdProveedor 
			AND TAO.IdTipoOperacion=2 
			AND ISNULL(SP.Visible,1)=1
			AND ISNULL(SP.IdEstatusEliminado,0)<>1	
			AND SP.IdSolicitudPedido =@IdSolicitudPedido 	
			AND @IdSolicitudPedido <> 0
		ORDER BY SP.FechaAlta DESC
	END 

  IF @TipoFiltro  ='PEDIDO' AND (@IdPedido <>0 OR @IdSolicitudPedido <>0 OR @IdProveedorVentas <>0)
  BEGIN 
		
		SELECT P.IdPedido,
			 P.IdSolicitudPedido,
			 P.CreadoEl AS CreadoEl, 
			 P.FechaEnvioPedido AS FechaEnvioPedido,
			 SUM(PD.Subtotal) AS TotalPedido,
			 ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS Proveedor,
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
			 CAST(P.Version as NVARCHAR(200))  
			 AS Version ,
			 TM.TipoMonedaCorto AS TipoMoneda,
			 PG.IdPedido AS IdPedidoGeneral,
			 TP.TipoPedido,
			 TP.IdTipoPedido
			FROM MM_Pedido AS P
			INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
			INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
			INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
			INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
			INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
			INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
			INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
			INNER JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido
			LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda			
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
			LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
			WHERE O.IdTipoOperacion = 9 
			AND O.IdProveedor = @IdProveedor
			AND P.Version=O.NoVersion
			AND ISNULL(P.IdEstatusEliminado,0) <> 1
			AND CASE WHEN  P.IdSubcontratista = @IdProveedorVentas 
			 THEN 1
			  WHEN @IdProveedorVentas = 0 AND P.IdSubcontratista IS NOT NULL  THEN 
					1
				ELSE 
					0
			  END  = 1
			AND CASE WHEN  P.IdSolicitudPedido = @IdSolicitudPedido 
			 THEN 1
			  WHEN @IdSolicitudPedido = 0 AND P.IdSolicitudPedido IS NOT NULL  THEN 
					1
				ELSE 
					0
			  END  = 1
			AND CASE WHEN  PG.IdPedido = @IdPedido 
			 THEN 1
			  WHEN @IdPedido = 0 AND PG.IdPedido IS NOT NULL  THEN 
					1
				ELSE 
					0
			  END  = 1
			GROUP BY P.IdPedido, P.IdSolicitudPedido, P.FechaEnvioPedido, RazonSocial,+RegimenCapital, P.RecepcionServicio,  E.Nombre,P.Version,TM.TipoMonedaCorto,HV.FechaVigencia, O.IdEstatusOperacion,P.CreadoEl,PG.IdPedido,TP.TipoPedido,TP.IdTipoPedido,P.IdEstatusEliminado
			ORDER BY PG.IdPedido DESC
	END 


	IF @TipoFiltro  ='PROVEEDORES_PEDIDOS' 
	BEGIN 

		SELECT   P.IdProveedor, CONCAT(p.RazonSocial,' ', ISNULL(p.RegimenCapital,'')) AS Proveedor
		FROM dbo.MM_Pedido PE
		LEFT  JOIN dbo.S_Proveedor P ON p.IdProveedor=PE.IdSubcontratista
		WHERE PE.IdProveedorCompras=@IdProveedor AND p.IdProveedor IS NOT NULL
		GROUP BY   p.IdProveedor, p.RazonSocial,p.RegimenCapital
		ORDER BY p.RazonSocial ASC

	END 
	

	IF @TipoFiltro  ='ACEPTACIONES_PEDIDO' AND (@IdPedido <>0 OR @IdAceptacionPedido <>0 OR @IdProveedorVentas <>0)
	BEGIN 
		SELECT 
                AP.IdAceptacionPedido,
                AP.IdPedido,				
				AP.Comentario,
                AP.Creado,
				CONCAT(LE.[Calle],' ',LE.[NoExterior],' ',LE.[NoInterior],' ',LE.[Colonia],' ',LE.[Municipio],' ',LE.[Estado], ' ', PAIS.Pais) AS LugarEntrega,
                TD.TipoDomicilio,
				CONCAT(P.RazonSocial,' ', P.RegimenCapital) As Proveedor,
				PG.IdPedido AS IdPedidoGeneral,
				TP.TipoPedido,
				MP.IdSolicitudPedido
         FROM MM_AceptacionPedido AS AP
		 INNER JOIN MM_Pedido AS MP ON MP.IdPedido = AP.IdPedido
		 INNER JOIN DG_Domicilio AS LE ON LE.IdDomicilio = AP.IdDomicilioEntrega
		 INNER JOIN DG_TipoDomicilio AS  TD ON TD.IdTipoDomicilio = LE.IdTipoDomicilio
		 INNER JOIN PV_PaisRepublica AS PAIS ON PAIS.id = LE.IdPais
		 INNER JOIN S_Proveedor AS P ON P.IdProveedor =  MP.IdSubcontratista
		 INNER JOIN MM_Pedidos AS PG ON MP.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
		 LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
         WHERE AP.IdProveedor = @IdProveedor	
		 AND ISNULL(AP.IdEstatusEliminado,0) <> 1 --> MOSTRAR ACEPTACIONES NO ELIMINADAS	
		 AND CASE WHEN  MP.IdSubcontratista = @IdProveedorVentas 
			 THEN 1
			  WHEN @IdProveedorVentas = 0 AND MP.IdSubcontratista IS NOT NULL  THEN 
					1
				ELSE 
					0
			  END  = 1 
		AND CASE WHEN  PG.IdPedido = @IdPedido 
			 THEN 1
			  WHEN @IdPedido = 0 AND PG.IdPedido IS NOT NULL  THEN 
					1
				ELSE 
					0
			  END  = 1
		AND CASE WHEN  AP.IdAceptacionPedido = @IdAceptacionPedido 
			 THEN 1
			  WHEN @IdAceptacionPedido = 0 AND AP.IdAceptacionPedido IS NOT NULL  THEN 
					1
				ELSE 
					0
			  END  = 1
		 ORDER BY IdAceptacionPedido DESC
		

	END 

END


