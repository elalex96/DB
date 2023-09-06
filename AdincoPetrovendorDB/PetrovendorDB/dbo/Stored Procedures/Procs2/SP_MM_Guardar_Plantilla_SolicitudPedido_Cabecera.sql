USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_Guardar_Plantilla_SolicitudPedido_Cabecera'
)
    DROP PROCEDURE SP_MM_Guardar_Plantilla_SolicitudPedido_Cabecera;
/****** Object:  StoredProcedure [dbo].[SP_MM_Guardar_Plantilla_SolicitudPedido_Cabecera]    Script Date: 05/09/2023 11:18:37 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19/11/2019>
-- Description:	<Guardado de plantilla de la solped>
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: <05/09/2023>
-- Description:	<Guardado de plantilla de la solped con columna IdLocalidad>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Guardar_Plantilla_SolicitudPedido_Cabecera]
	-- Add the parameters for the stored procedure here
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
		@IdPeriodo int, --
		@IdPresupuesto int, --
		@IdContrato INT,
		@IdMatrizEvaluacion INT,
		@IdPorcentajeETEC INT,
		@IdLocalidad INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.MM_Plantillas_SolicitudPedido
	(
	    IdTipoSolicitudPedido,
	    IdUsuarioSolicitante,
	    AdjudicableParcialmente,
	    IdPrioridadSolicitante,
	    MotivoUrgencia,
	    UnaSolaEntregaRequerida,
	    Activo,
	    FechaEntregaRequerida,
	    FechaEntregaFinRequerida,
	    IdProveedor,
	    EntregasParciales,
	    IdContrato,
	    IdPeriodo,
	    IdPresupuesto,
	    CreadoPor,
	    CreadoEl,
		IdMatrizEvaluacion,
		IdPorcentajeETEC,
		IdLocalidad
	)
	VALUES
	(   @IdTipoSolicitudPedido,         -- IdTipoSolicitudPedido - int
	    @IdUsuarioSolicitante,         -- IdUsuarioSolicitante - int
	    @AdjudicableParcialmente,      -- AdjudicableParcialmente - bit
	    @IdPrioridad,         -- IdPrioridadSolicitante - int
	    @MotivoUrgencia,       -- MotivoUrgencia - nvarchar(max)
	    @UnaSolaEntregaRequerida,      -- UnaSolaEntregaRequerida - bit
	    1,      -- Activo - bit
	    @FechaEntregaRequerida, -- FechaEntregaRequerida - datetime
	    @FechaEntregaFinRequerida, -- FechaEntregaFinRequerida - datetime
	    @IdProveedor,         -- IdProveedor - int
	    @EntregasParciales,      -- EntregasParciales - bit
	    @IdContrato,         -- IdContrato - int
	    @IdPeriodo,         -- IdPeriodo - int
	    @IdPresupuesto,         -- IdPresupuesto - int
	    @IdUsuarioSolicitante,         -- CreadoPor - int
	    GETDATE(),          -- CreadoEl - int
		@IdMatrizEvaluacion,
		@IdPorcentajeETEC,
		@IdLocalidad
	    )

	DECLARE @IDSOLPEDPLANTILLA_CABECERA INT = (SCOPE_IDENTITY());

	SELECT @IDSOLPEDPLANTILLA_CABECERA;
END
