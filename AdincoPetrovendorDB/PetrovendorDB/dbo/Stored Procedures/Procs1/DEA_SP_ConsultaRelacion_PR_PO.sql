USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'DEA_SP_ConsultaRelacion_PR_PO'
)
    DROP PROCEDURE DEA_SP_ConsultaRelacion_PR_PO;
	GO
/****** Object:  StoredProcedure [dbo].[DEA_SP_ConsultaRelacion_PR_PO]    Script Date: 30/05/2022 06:12:12 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: <14/08/2019>
-- Description:	<Consulta las relaciones de PR - PO>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: <31/05/2022>
-- Description:	<Se agrega filtro de tipos de pedidos y se elimina relación de  PO.ID_PO = R.PO >
-- =============================================
CREATE PROCEDURE [dbo].[DEA_SP_ConsultaRelacion_PR_PO]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT
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
		P.IdPedido AS IdPedidoInterno,
		Contrato = c.NumeroContrato
	FROM dbo.DEA_Relacion_PR_PO AS R
		INNER JOIN dbo.DEA_AdjuntoPO AS PO 
			ON R.IdAdjuntoPO=PO.IdAdjuntoPO --> LA DIFERENCIA ES EL IDADJUNTOPO
		INNER JOIN dbo.MM_Pedido AS P ON R.IdPedido = P.IdPedido 
		INNER JOIN dbo.MM_SolicitudPedido AS SP ON P.IdSolicitudPedido = SP.IdSolicitudPedido 
		LEFT JOIN dbo.DEA_AdjuntoPR AS PR ON SP.IdSolicitudPedido = PR.IdSolicitudPedido AND  P.IdSolicitudPedido = PR.IdSolicitudPedido
		LEFT JOIN dbo.DEA_Documento_S3 DR ON PR.IdAjuntoPr = DR.IdDocumentoTabla AND DR.IdTipoDocumento=1 --> Documento de tipo PR
		LEFT JOIN dbo.MM_Pedidos AS PS ON P.IdPedido  = PS.IdIdentificador AND P.IdProveedorCompras= PS.IdProveedorCliente  AND PS.IdTipoPedido IN (2,4,6) --> CTES TIPOS DE PEDIDO
		LEFT JOIN dbo.S_Proveedor AS PRS ON P.IdSubcontratista = PRS.IdProveedor 
		LEFT JOIN dbo.MM_PedidoDetalle AS PD ON P.IdPedido = PD.IdPedido 
		LEFT JOIN PV_TipoMoneda AS TM ON P.IdMoneda		 = TM.IdMoneda 
		LEFT JOIN dbo.S_Usuario AS US ON R.CreadoPor = US.IdUsuario 
		left JOIN	Adinco.dbo.CO_Contrato	AS	C 	ON	P.IdContrato	=	C.IdContrato 
	WHERE SP.IdProveedor = @IdProveedor 
		AND PS.IdProveedorCliente = @IdProveedor
		AND R.ID_R_PR_PO IS NOT NULL
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
			 P.IdPedido,
			 c.IdContrato,
			 c.NumeroContrato
	ORDER BY R.ID_R_PR_PO DESC

END
