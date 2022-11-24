-- =============================================
-- Author:		Pedro, Acuña
-- Create date: 06/02/2018
-- Description:	se agrega un bit para saber si existen las bases para mostrar o no el boton de descarga de bases
-- =============================================
-- Author:		Luis David
-- Create date: 06/02/2018
-- Description:	se agrega un bit para saber si existen las bases para mostrar o no el boton de descarga de bases
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/07/2022
-- Description:	se obtienen los datos de presupuesto y periodo de la linea de presupuesto
-- =============================================

CREATE PROCEDURE [dbo].[MM_SP_ConsultaSolicitudPedido] --26352
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT
AS
	BEGIN
		SET NOCOUNT ON 

		DECLARE @ExistenBases BIT = 0,
		@IdLineaPresupuesto int = (SELECT  
									TOP 1
									SPLP.IdLineaPresupuesto FROM 
									dbo.MM_SolicitudPedido AS SPC
										LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD 
											ON SPC.IdSolicitudPedido = SPD.IdSolicitudPedido
										LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPLP
											ON SPD.IdSolicitudPedidoDetalle = SPLP.IdSolicitudPedidoDetalle
											WHERE SPC.IdSolicitudPedido = @IdSolicitudPedido
											GROUP BY SPLP.IdLineaPresupuesto);

		DECLARE @IdPresupuesto INT = (SELECT TOP 1 IdPresupuesto FROM Adinco.dbo.CO_LineaPresupuestoMes WHERE IdLineaPresupuestoMes = @IdLineaPresupuesto);

		DECLARE @IdPeriodo INT = (select TOP 1 PC.IdPeriodo
									from Adinco.dbo.CO_LineaPresupuestoMes LPM
										join Adinco.dbo.CO_Presupuesto P on LPM.IdPresupuesto = P.IdPresupuesto
										join Adinco.dbo.CO_ProgramaActividad PA on P.IdProgramaActividad = PA.IdProgramaActividad
										join Adinco.dbo.CO_PeriodoContrato PC on PA.IdPeriodoContrato = PC.IdPeriodo
											WHERE LPM.IdLineaPresupuestoMes = @IdLineaPresupuesto);

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
					U.Nombre,
					--U.Nombre, 
					TAO.IdOperacion ,
					ISNULL ( SP.PeticionEnviada, 'false' ) AS PeticionEnviada, 
					TiOp.NombreOperacion, 
					CC.CentroCosto ,
					ISNULL ( TC.Termino, 'No aplica' ) AS Termino, 
					SP.IdContrato, 
					@IdPeriodo AS IdPeriodo, 
					@IdPresupuesto AS IdPresupuesto ,
					@IdLineaPresupuesto, 
					TG.TipoGasto, 
					ISNULL ( SP.Fianza, 'false' ), 
					ISNULL ( SP.Controlados, 'false' ) ,
					SP.UnicoDomicilioEntrega, 
					SP.EntregasParciales, 
					ISNULL ( SP.IdTipoProceso, 0 ) ,
					ISNULL ( @ExistenBases, 0 ),
					ISNULL(PR.CotizacionesRestringidas,0), 
					ISNULL(SP.IdTipoGasto, 0),
					ISNULL(USO.Nombre,'N/A') AS NombreSolicitante,
					ISNULL(FT.Nombre,'') AS FlujoAprobacion,
					ISNULL(TFO.Nombre,'') AS TipoFlujoAprobacion
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
		LEFT JOIN TA_FlujoTarea FT
			ON TAO.IdFlujoTarea	= FT.IdFlujoTarea		
		LEFT JOIN TA_TipoFlujoTarea TFO
			ON FT.IdTipoFlujo = TFO.IdTipoFlujoTarea
		WHERE
					TAO.IdTipoOperacion = 2
					AND SP.IdSolicitudPedido = @IdSolicitudPedido
	END