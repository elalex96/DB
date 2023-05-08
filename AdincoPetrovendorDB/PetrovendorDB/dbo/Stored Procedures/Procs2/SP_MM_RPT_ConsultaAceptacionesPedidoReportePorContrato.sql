-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21/02/2023
-- Description:	Consultar aceptaciones para descarga de informacion
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_RPT_ConsultaAceptacionesPedidoReportePorContrato]
	-- Add the parameters for the stored procedure here
	@FechaInicio DATE,
	@FechaFin DATE,
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		CON.NumeroContrato AS Contrato,
		AP.IdAceptacionPedido,
		ISNULL(CAST(SAP.IdSolicitudAceptacionPedido AS nvarchar),'N/A') as IdSolicitudAceptacionPedido,
		P.IdSolicitudPedido AS Requisicion,
		AP.Comentario,
		AP.Creado AS FechaRegistro,
		PR.RazonSocial AS Proveedor
	FROM MM_AceptacionPedido AS AP (NOLOCK)
		JOIN MM_Pedido AS P (NOLOCK)
			ON  AP.IdPedido = P.IdPedido
			AND P.IdContrato = @IdContrato
			AND AP.Creado BETWEEN @FechaInicio AND @FechaFin
			AND AP.Activo = 1
			AND ISNULL(AP.IdEliminado,0) = 0		
		JOIN Adinco..CO_Contrato  AS CON  (NOLOCK)
			ON P.IdContrato = CON.IdContrato
		JOIN MM_SolicitudAceptacionPedido AS SAP (NOLOCK)
			ON P.IdPedido = SAP.IdPedido
			AND SAP.Activo = 1
		JOIN S_Proveedor AS PR (NOLOCK)
			ON P.IdSubcontratista = PR.IdProveedor

END
