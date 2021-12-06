USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[MM_SP_ConsultaDetalleMaterialesReciclaje]    Script Date: 26/11/2021 01:50:18 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Jose Roman>
-- Create date: <10-01-2018>
-- Description:	<Consulta de detalle de materiales en el reciclaje de una solicitud de pedido>
-- =============================================

ALTER procedure [dbo].[MM_SP_ConsultaDetalleMaterialesReciclaje]
	@IdSolicitudPedidoDetalle INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
  /*---------------------------------------------------------------*/
AS
BEGIN
	SELECT IdSolicitudPedidoDetalleLineaPresupuesto, IdCentroCosto, IdInstalacion, IdLineaPresupuesto
	FROM dbo.MM_SolicitudPedidoDetalleLineaPresupuesto (NOLOCK)
	WHERE IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle
END
