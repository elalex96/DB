USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'MM_SP_ConsultaSolicitudPedido'
)
    DROP PROCEDURE MM_SP_ConsultaSolicitudPedido;
/****** Object:  StoredProcedure [dbo].[MM_SP_ConsultaSolicitudPedido]    Script Date: 04/09/2023 06:09:11 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
-- Author:		Daniel AC
-- Create date: 04/09/2023
-- Description:	Se agrega left para consultar si tiene localidad relacionada
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
									SPLP.IdLineaPresupuesto 
									FROM dbo.MM_SolicitudPedido AS SPC (NOLOCK)
									LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
										ON SPC.IdSolicitudPedido = SPD.IdSolicitudPedido
									LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPLP (NOLOCK)
										ON SPD.IdSolicitudPedidoDetalle = SPLP.IdSolicitudPedidoDetalle
										WHERE SPC.IdSolicitudPedido = @IdSolicitudPedido
										GROUP BY SPLP.IdLineaPresupuesto);

		DECLARE @IdPresupuesto INT = (SELECT TOP 1 IdPresupuesto 
										FROM Adinco.dbo.CO_LineaPresupuestoMes (NOLOCK)
										WHERE IdLineaPresupuestoMes = @IdLineaPresupuesto);

		DECLARE @IdPeriodo INT = (select TOP 1 PC.IdPeriodo
									from Adinco.dbo.CO_LineaPresupuestoMes LPM (NOLOCK)
										join Adinco.dbo.CO_Presupuesto P (NOLOCK)
											on LPM.IdPresupuesto = P.IdPresupuesto
										join Adinco.dbo.CO_ProgramaActividad PA (NOLOCK)
											on P.IdProgramaActividad = PA.IdProgramaActividad
										join Adinco.dbo.CO_PeriodoContrato PC (NOLOCK)
											on PA.IdPeriodoContrato = PC.IdPeriodo
											WHERE LPM.IdLineaPresupuestoMes = @IdLineaPresupuesto);

		SELECT		@ExistenBases = CASE WHEN F.IdDocBases IS NULL THEN 0 ELSE 1 END
		FROM		TA_DocBasesOperacion F (NOLOCK)
		LEFT JOIN	TA_Operacion O(NOLOCK)
			ON F.IdOperacion = O.IdOperacion
		LEFT JOIN	MM_SolicitudPedido SP (NOLOCK)
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
					ISNULL(TFO.Nombre,'') AS TipoFlujoAprobacion,
					ISNULL(L.Nombre,'N/A') AS Localidad					
		FROM		MM_SolicitudPedido AS SP (NOLOCK)
		INNER JOIN	MM_TipoSolicitudPedido AS TSP(NOLOCK)
			ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido 
		INNER JOIN	TA_Operacion AS TAO (NOLOCK)
			ON SP.IdSolicitudPedido = TAO.IdDocumento 
		INNER JOIN	TA_Estatus AS TE (NOLOCK)
			ON  TAO.IdEstatusOperacion = TE.IdEstatus 
		INNER JOIN	MM_PrioridadSolicitudPedido AS PSP (NOLOCK)
			ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido 
		INNER JOIN	S_Usuario AS U (NOLOCK)
			ON TAO.IdAsignador = U.IdUsuario 
		LEFT JOIN S_Usuario AS USO(NOLOCK)
			ON SP.Solicitante = USO.IdUsuario 
		INNER JOIN	TA_TipoOperacion AS TiOp (NOLOCK)
			ON TAO.IdTipoOperacion = TiOp.IdTipoOperacion 
		LEFT JOIN	CC_CentroCosto AS CC (NOLOCK)
			ON SP.IdCentroCosto = CC.IdCentroCosto 
		LEFT JOIN	MM_TerminoComercio AS TC (NOLOCK)
			ON SP.IdTerminoInternacionales = TC.IdTerminoComercio
		LEFT JOIN	MM_TipoGastos AS TG (NOLOCK)
			ON SP.IdTipoGasto = TG.IdTipoGasto
		LEFT JOIN dbo.S_Proveedor AS PR  (NOLOCK)
			ON SP.IdProveedor = PR.IdProveedor
		LEFT JOIN TA_FlujoTarea FT(NOLOCK)
			ON TAO.IdFlujoTarea	= FT.IdFlujoTarea		
		LEFT JOIN TA_TipoFlujoTarea TFO(NOLOCK)
			ON FT.IdTipoFlujo = TFO.IdTipoFlujoTarea
		LEFT JOIN MM_Localidades L(NOLOCK)
			ON SP.IdLocalidad = L.Id
		WHERE
		TAO.IdTipoOperacion = 2
		AND SP.IdSolicitudPedido = @IdSolicitudPedido
	END