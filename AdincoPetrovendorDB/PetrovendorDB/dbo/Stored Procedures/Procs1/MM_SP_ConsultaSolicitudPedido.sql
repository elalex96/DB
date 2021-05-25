-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Pedido  
-- =============================================

-- =============================================
-- Author:		Abel Rivera
-- Create date: 25-01-18
-- Description:	Se agrego a la consulta el campo IdTipoProceso de la solicitud de pedido  
-- =============================================
-- =============================================
-- Author:		Pedro, Acuña
-- Create date: 06/02/2018
-- Description:	se agrega un bit para saber si existen las bases para mostrar o no el boton de descarga de bases
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 20/05/2021
-- Description:	se agrega el dato de solicitante
-- =============================================

ALTER PROCEDURE [dbo].[MM_SP_ConsultaSolicitudPedido]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT
AS
	BEGIN
		SET NOCOUNT ON 

		DECLARE @ExistenBases BIT = 0

		SELECT		@ExistenBases = CASE WHEN F.IdDocBases IS NULL THEN 0 ELSE 1 END
		FROM		TA_DocBasesOperacion F
		LEFT JOIN	TA_Operacion O
			ON F.IdOperacion = O.IdOperacion
		LEFT JOIN	MM_SolicitudPedido SP
			ON O.IdDocumento = SP.IdSolicitudPedido
		WHERE
					O.IdTipoOperacion = 6
					AND SP.IdSolicitudPedido = @IdSolicitudPedido
					AND F.Activo = 1

		SELECT		SP.IdSolicitudPedido, 
					SP.MotivoUrgencia, 
					TSP.TipoSolicitudPedido, 
					SP.FechaAlta ,
					SP.AdjudicableParcialmente, 
					SP.VisitaRequerida, 
					SP.JuntaAclaracionesRequerida ,
					SP.UnaSolaEntregaRequerida, 
					SP.FechaEntregaRequerida, 
					SP.FechaEntregaFinRequerida, 
					TE.Nombre ,
					PSP.Prioridad, 
					TAO.IdEstatusOperacion, 
					ISNULL(USO.Nombre,U.Nombre),
					--U.Nombre, 
					TAO.IdOperacion ,
					ISNULL ( SP.PeticionEnviada, 'false' ) AS PeticionEnviada, 
					TiOp.NombreOperacion, 
					CC.CentroCosto ,
					ISNULL ( TC.Termino, 'No aplica' ) AS Termino, 
					SP.IdContrato, 
					SP.IdPeriodo, 
					SP.IdPresupuesto ,
					SP.IdLineaPresupuesto, 
					TG.TipoGasto, 
					ISNULL ( SP.Fianza, 'false' ), 
					ISNULL ( SP.Controlados, 'false' ) ,
					SP.UnicoDomicilioEntrega, 
					SP.EntregasParciales, 
					ISNULL ( SP.IdTipoProceso, 0 ) ,
					ISNULL ( @ExistenBases, 0 ),
					ISNULL(PR.CotizacionesRestringidas,0), 
					ISNULL(SP.IdTipoGasto, 0)
		FROM		MM_SolicitudPedido AS SP
		INNER JOIN	MM_TipoSolicitudPedido AS TSP
			ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
		INNER JOIN	TA_Operacion AS TAO
			ON TAO.IdDocumento = SP.IdSolicitudPedido
		INNER JOIN	TA_Estatus AS TE
			ON TE.IdEstatus = TAO.IdEstatusOperacion
		INNER JOIN	MM_PrioridadSolicitudPedido AS PSP
			ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
		INNER JOIN	S_Usuario AS U
			ON U.IdUsuario = TAO.IdAsignador
		LEFT JOIN S_Usuario AS USO
			ON USO.IdUsuario = SP.Solicitante
		INNER JOIN	TA_TipoOperacion AS TiOp
			ON TiOp.IdTipoOperacion = TAO.IdTipoOperacion
		LEFT JOIN	CC_CentroCosto AS CC
			ON CC.IdCentroCosto = SP.IdCentroCosto
		LEFT JOIN	MM_TerminoComercio AS TC
			ON TC.IdTerminoComercio = SP.IdTerminoInternacionales
		LEFT JOIN	MM_TipoGastos AS TG
			ON TG.IdTipoGasto = SP.IdTipoGasto
		LEFT JOIN dbo.S_Proveedor AS PR 
			ON PR.IdProveedor = SP.IdProveedor
		--INNER JOIN dbo.PV_TipoCompra PTC ON PTC.IdTipoCompra = SP.IdTipoProceso
		WHERE
					TAO.IdTipoOperacion = 2
					AND SP.IdSolicitudPedido = @IdSolicitudPedido
	END
