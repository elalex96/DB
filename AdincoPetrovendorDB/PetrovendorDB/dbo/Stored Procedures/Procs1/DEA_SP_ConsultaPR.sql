-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <20/08/2019>
-- Description:	<Consulta de las PR>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: <31/05/2022>
-- Description:	<Se ordena llamadas a tablas y filtro por tipos de pedido>
-- =============================================
create PROCEDURE [dbo].[DEA_SP_ConsultaPR] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

			SELECT 
			SPR.ID_PR AS ID_PR,
			P.IdSolicitudPedido,
			PG.IdPedido AS IdPedido,
			SP.MotivoUrgencia, 	
			P.IdPedido AS PedidoInterno,
			TSP.TipoSolicitudPedido, 
			SP.FechaAlta AS FechaAltaSolPed,
			'' AS Nombre,		
			'' AS CentroCosto,
			U.Nombre AS NombreUsuario,
			'' AS Descripcion,
			ISNULL(PV.RazonSocial,'') AS Proveedor,
			'' AS AreaContractual,			
			SUM(PD.Cantidad * PD.PrecioUnitario) AS TotalPedido,	
			P.IdPedido AS IdPedidoInterno,
			P.Version,
			O.IdOperacion,
			P.CreadoEl AS FechaEnvioPedido,	
			E.Nombre AS Estatus,			
			P.RecepcionServicio,
			TM.TipoMonedaCorto AS TipoMoneda,			
			TP.TipoPedido,
			TP.IdTipoPedido,
			R.ID_R_PR_PO, 
			P.CreadoEl AS PedidoCreadoEl,
			DPR.IdDocumento,
			SPR.IdAjuntoPr,
			Contrato = c.NumeroContrato
		FROM MM_Pedido AS P
		INNER JOIN dbo.MM_SolicitudPedido SP ON  P.IdSolicitudPedido = SP.IdSolicitudPedido
		LEFT JOIN dbo.DEA_AdjuntoPR SPR ON SP.IdSolicitudPedido = SPR.IdSolicitudPedido 
		LEFT JOIN dbo.DEA_Documento_S3 DPR ON SPR.IdAjuntoPr = DPR.IdDocumentoTabla  AND DPR.IdTipoDocumento=1 --AdjuntoPR 
		LEFT JOIN S_Usuario AS U ON SP.IdUsuarioSolicitante = U.IdUsuario
		INNER JOIN MM_TipoSolicitudPedido AS TSP ON SP.IdTipoSolicitudPedido  = TSP.IdTipoSolicitudPedido
		INNER JOIN MM_PedidoDetalle AS PD ON P.IdPedido = PD.IdPedido 
		INNER JOIN MM_PeticionOferta AS PO ON  P.IdPeticionOferta = PO.IdPeticionOFerta 
		INNER JOIN S_Proveedor AS PV ON P.IdSubcontratista = PV.IdProveedor  
		INNER JOIN TA_Operacion AS O ON P.IdSolicitudPedido = O.IdDocumento		
		INNER JOIN TA_Estatus AS E ON O.IdEstatusOperacion = E.IdEstatus
		INNER JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido
		INNER JOIN PV_TipoMoneda AS TM ON P.IdMoneda = TM.IdMoneda 
		INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador  AND P.IdProveedorCompras = PG.IdProveedorCliente  AND PG.IdTipoPedido IN (2,4,6)
		LEFT  JOIN dbo.MM_TipoPedido AS TP ON  PG.IdTipoPedido = TP.IdTipoPedido
		LEFT JOIN dbo.DEA_Relacion_PR_PO R ON P.IdPedido  = R.IdPedido AND R.Activo = 1
		LEFT JOIN Adinco..OT_Estimacion est on p.IdPedido = est.IdPedido 
		inner JOIN	Adinco.dbo.CO_Contrato	AS	C 	ON	SP.IdContrato	=	C.IdContrato 
		WHERE 
		O.IdTipoOperacion =9 --> APROBACIÓN DE PEDIDO
		AND ISNULL(P.IdEstatusEliminado,0)<>1 --> QUE NO ESTE ELIMINADO EL PEDIDO		
		AND O.IdProveedor = @IdProveedor 
		--DMW si tiene recepcion a null o si es un pedido de control de obra
		--AND (
		--	P.RecepcionServicio IS NULL OR est.IdPedido > 0
		--)  
		AND (O.IdEstatusOperacion = 2 OR O.IdEstatusOperacion=11)  --> EN ESTATUS DE APROBADO O APROBADO SIN DOCUMENTO		
		AND P.Version=O.NoVersion
		AND R.ID_R_PR_PO IS NULL ---> QUE NO TENGA RELACION EN LA TABLE DE PEDIDOS 
		GROUP BY 
		P.IdPedido, 
		P.IdSolicitudPedido, 
		P.CreadoEl, 
		PV.RazonSocial,		
		SP.MotivoUrgencia,
		P.RecepcionServicio,  
		E.Nombre,
		P.Version,
		TM.TipoMonedaCorto, 
		PG.IdPedido,
		TP.TipoPedido,
		TP.IdTipoPedido,
		R.ID_R_PR_PO,
		TSP.TipoSolicitudPedido,
		U.Nombre,
		P.Version,
		SP.FechaAlta,
		O.IdOperacion,
		P.CreadoEl,
		SPR.ID_PR,
		DPR.IdDocumento,
		P.CreadoEl,
		SPR.IdAjuntoPr,
		c.IdContrato,
		c.NumeroContrato
		ORDER BY  PG.IdPedido DESC 
 
 
END