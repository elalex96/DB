USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ConsultarCentroCostoSolicitudPedido'
)
    DROP PROCEDURE SP_MM_ConsultarCentroCostoSolicitudPedido;

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 06/02/2024
-- Description:	Consultar centros de costos de una solicitud de pedido
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ConsultarCentroCostoSolicitudPedido] 

@IdUsuario INT, 
@IdProveedor INT,
@IdSolicitudPedido INT 

AS
	BEGIN

			
		SELECT CC.CentroCosto
		FROM dbo.MM_SolicitudPedidoDetalle SPD (NOLOCK)
		INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPLP   (NOLOCK)
			ON SPD.IdSolicitudPedidoDetalle  = SPLP.IdSolicitudPedidoDetalle
		INNER JOIN dbo.CC_CentroCosto CC (NOLOCK)
			ON SPLP.IdCentroCosto = CC.IdCentroCosto 
		WHERE IdSolicitudPedido= @IdSolicitudPedido
		GROUP BY CC.CentroCosto
		ORDER BY  CC.CentroCosto ASC

			
	END