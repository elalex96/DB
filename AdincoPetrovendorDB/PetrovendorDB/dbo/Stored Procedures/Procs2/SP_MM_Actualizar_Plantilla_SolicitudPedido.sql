USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_Actualizar_Plantilla_SolicitudPedido'
)
    DROP PROCEDURE SP_MM_Actualizar_Plantilla_SolicitudPedido;
/****** Object:  StoredProcedure [dbo].[SP_MM_Actualizar_Plantilla_SolicitudPedido]    Script Date: 05/09/2023 11:16:32 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <25/11/2019>
-- Description:	<Actualizacion de datos de una plantilla de solicitud de pedido>
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: <05/09/2023>
-- Description:	<Guardado de plantilla de la solped con columna IdLocalidad>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Actualizar_Plantilla_SolicitudPedido]
	-- Add the parameters for the stored procedure here
		@IdPlantillaSolcitudPedido INT,
		@IdTipoSolicitudPedido int,
		@IdProveedor int, 
        @IdUsuarioSolicitante int,
        @AdjudicableParcialmente bit, 
        @IdPrioridad int,
        @MotivoUrgencia nvarchar(max),
        @UnaSolaEntregaRequerida bit,
        @FechaEntregaRequerida DATETIME, 
		@FechaEntregaFinRequerida DATETIME,
		@EntregasParciales bit,
		@IdPeriodo int, 
		@IdPresupuesto int, 
		@IdMatrizEvaluacion INT,
		@IdPorcentajeETEC INT,
		@IdLocalidad INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	UPDATE dbo.MM_Plantillas_SolicitudPedido
	SET IdTipoSolicitudPedido = @IdTipoSolicitudPedido,
	    IdUsuarioSolicitante = @IdUsuarioSolicitante,
	    AdjudicableParcialmente = @AdjudicableParcialmente,
	    IdPrioridadSolicitante = @IdPrioridad,
	    MotivoUrgencia = @MotivoUrgencia,
	    UnaSolaEntregaRequerida = @UnaSolaEntregaRequerida,
	    FechaEntregaRequerida = @FechaEntregaRequerida,
	    FechaEntregaFinRequerida = @FechaEntregaFinRequerida,
	    EntregasParciales = @EntregasParciales,
	    IdPeriodo = @IdPeriodo,
	    IdPresupuesto = @IdPresupuesto,
		IdMatrizEvaluacion = @IdMatrizEvaluacion,
		IdPorcentajeETEC = @IdPorcentajeETEC,
		IdLocalidad = @IdLocalidad
	WHERE IdPlantillaSolicitudPedido = @IdPlantillaSolcitudPedido;

	--SE INACTIVAN LOS DETALLES DE LA SOLPED PARA DESCARTAR LOS ELIMINADOS(EN CASO DE)
	UPDATE dbo.MM_Plantilla_SolicitudPedidoDetalle
	SET Activo = 0
	WHERE IdPlantillaSolicitudPedido = @IdPlantillaSolcitudPedido;

END