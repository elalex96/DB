USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'DEA_ReporteTransacciones'
)
    DROP VIEW DEA_ReporteTransacciones;
	
/****** Object:  View [dbo].[DEA_ReporteTransacciones]    Script Date: 30/08/2022 04:54:21 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DEA_ReporteTransacciones]
AS
	SELECT  Bloque AS BLOQUE, 
			IdSolicitudPedido AS SOLPEDS, 
			SPDetalleRegistro AS [Registro de SOLPED (OPERACIONES)],
			SPCentroCosto AS [Centros de costo], 
			SPDetalleAprobador1 AS [Aprobacion de SOLPED (PROCURA)], 
            SPDetalleAprobador2 AS [Aprobacion de SOLPED (OPERACIONES)], 
			SPSolicitante AS Solicitante, SPEstatus AS [Estatus SOLPED],
			SPComprador AS [Asignacion de comprador (PROCURA)], 
            EnvioCotizacion AS [Envio de solicitud de cotizacion por comprador (PROCURA)], 
			FinalizacionCotizacion AS [Proveedor envìa su cotizacion (PROVEEDOR)], 
			DetalleNoPedido AS pedido, NumPO, 
            PedidoDetalleRegistro AS [Registro el pedido], 
			PedidoEstatusRelacionPO AS [Relacion PO], 
			PedidoEstatus AS [Estatus de pedido], 
			PedidoDetalleAprobador1 AS [Aprobacion de PEDIDO (PROCURA)], 
            PedidoEstatusConfirmacion AS [Confirmacion pedido PROVEEDOR], 
			SASDetalleRegistro AS [Solicitud Aceptacion Pedido], 
			SASAprobadorSolitante AS [SAS Aprobacion Solicitante], 
			SASAprobadorOBS AS [SAS Aprobacion OBS], 
            AceptacionPedido AS [Aceptacion de pedido], 
			CargaCartaCN AS [Carga de Carta Contenido Nacional], 
			AceptacionCartaCN AS [Aceptacion de Carta de Contenido Nacional], 
			EstatusCartaCN AS [Estatus Carta CN], 
            CargaFactura AS [Carga de Factura], 
			AceptacionFactura AS [Aceptacion de Factura], 
			AceptacionAP AS [Aceptacion de AP], 
			EstatusFinal AS [Status], 
			PeriodoEnADINCO AS [Periodo en ADINCO]
		FROM dbo.APP_TransaccionesProcura
GO

