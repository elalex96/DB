-- =============================================
-- Author:	Daniel AC
-- Create date: <14/10/2019>
-- Description:	<Consulta las relaciones de PR - PO Detalle>
-- =============================================
CREATE PROCEDURE [dbo].[DEA_SP_ConsultaRelacionDetalle_PR_PO] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdUsuario INT,
	@IdRelacionPOPR INT,
	@IdPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		R.ID_R_PR_PO,
		PO.ID_PO,
		PR.ID_PR AS ID_PR,
		SP.IdSolicitudPedido,
		PS.IdPedido,
		PRS.RazonSocial AS Proveedor,
		SUM(PD.Cantidad * PD.PrecioUnitario) AS MontoTotalPedido,
		TM.TipoMonedaCorto AS TipoMoneda,
		R.FechaAltaRelacion,
		US.Nombre AS RelacionCreadaPor,
		PO.IdAdjuntoPO,
		PR.IdAjuntoPr,
		P.IdPedido AS IdPedidoInterno
	FROM dbo.DEA_Relacion_PR_PO AS R
		INNER JOIN dbo.DEA_AdjuntoPO AS PO 
			ON PO.ID_PO = R.PO --> PO DEBE SER IGUAL A LA DE LA RELACIÓN
			AND  R.IdAdjuntoPO=PO.IdAdjuntoPO --> LA DIFERENCIA ES EL IDADJUNTOPO
		INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = R.IdPedido
		INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
		LEFT JOIN dbo.DEA_AdjuntoPR AS PR ON PR.IdSolicitudPedido = SP.IdSolicitudPedido
		LEFT JOIN dbo.DEA_Documento_S3 DR ON DR.IdDocumentoTabla=PR.IdAjuntoPr AND DR.IdTipoDocumento=1 --> Documento de tipo PR
		LEFT JOIN dbo.MM_Pedidos AS PS ON PS.IdIdentificador = P.IdPedido 
		LEFT JOIN dbo.S_Proveedor AS PRS ON PRS.IdProveedor = P.IdSubcontratista
		LEFT JOIN dbo.MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
		LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda		
		LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = R.CreadoPor
	WHERE SP.IdProveedor = @IdProveedor 
		AND PS.IdProveedorCliente = @IdProveedor
		AND R.ID_R_PR_PO =@IdRelacionPOPR
		AND p.IdPedido=@IdPedido
		AND ISNULL(R.Activo,0) = 1
		AND ISNULL(R.IsEliminado,0) = 0
		AND ISNULL(P.IdEstatusEliminado,0)=0 --> El pedido no este eliminado
	GROUP BY R.ID_R_PR_PO,
             PO.ID_PO,
             PR.ID_PR,
             SP.IdSolicitudPedido,
             PS.IdPedido,
             PRS.RazonSocial,
             R.FechaAltaRelacion,
             US.Nombre,
             PO.IdDocumento,
			 TM.TipoMonedaCorto,
             DR.IdDocumento,
			 PR.IdAjuntoPr,
			 PO.IdAdjuntoPO,
			 PR.IdAjuntoPr,
			 P.IdPedido
	ORDER BY R.ID_R_PR_PO DESC

END



