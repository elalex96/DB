-- =============================================
-- Author:	Daniel A Cruz
-- Create date: 11-04-17
-- Description:	SP que agrega Cabecera de Solicitud de Pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_AgregarSolicitudPedido]
		
		@IdTipoSolicitudPedido int,
		@IdProveedor int, 
        @IdUsuarioSolicitante int,
        @AdjudicableParcialmente bit, 
        @IdPrioridad int,
        @MotivoUrgencia nvarchar(max),
        @VisitaRequerida bit,
        @JuntaAclaracionesRequerida bit,
        @UnaSolaEntregaRequerida bit,
        @Activo bit,
        @FechaEntregaRequerida nvarchar(max), 
		@FechaEntregaFinRequerida nvarchar(max),
		@EntregasParciales bit,
		@IdPeriodo int, 
		@IdPresupuesto int, 
		@IdLineaPresupuesto int, 
		@IdCentroCosto int,
		@IdTipoGasto int, 
		@IdTerminosInternacionales int, 
		@EntregaUnicoDomicilio bit, 
		@IdDomiclioEntrega int, 
		@IdContrato int,
		@Fianza bit,
		@Controlados bit


AS
BEGIN
	DECLARE @IdSolicitudPedido int
	DECLARE @IdDomiclioEntregaF int 
	DECLARE @IdTerminosInternacionalesF int
	DECLARE @FechaEntregaFinRequeridaF nvarchar(max)
	SET NOCOUNT ON;
	

	--- Validar Domicilios Entrega
	IF @IdDomiclioEntrega = 0 
		BEGIN
			SET @IdDomiclioEntregaF = NULL
		END  
	ELSE 
		BEGIN
			SET @IdDomiclioEntregaF = @IdDomiclioEntrega
		END 
	 

	 --- Validar Tipo de Intercom
	 IF @IdTerminosInternacionales = 0 
		BEGIN
			SET @IdTerminosInternacionalesF = NULL
		END  
	ELSE 
		BEGIN
			SET @IdTerminosInternacionalesF = @IdTerminosInternacionales
		END 

	--- Validar EntregasParciales ----

	IF @EntregasParciales =  0
		BEGIN
			SET @FechaEntregaFinRequeridaF = NULL
		END  
	ELSE 
		BEGIN
			SET @FechaEntregaFinRequeridaF = @FechaEntregaFinRequerida
		END 

	


	INSERT INTO [dbo].[MM_SolicitudPedido]
           ([IdTipoSolicitudPedido]
           ,[IdUsuarioSolicitante]
           ,[AdjudicableParcialmente]
           ,[IdPrioridadSolicitudPedido]
           ,[MotivoUrgencia]
           ,[VisitaRequerida]
           ,[JuntaAclaracionesRequerida]
           ,[UnaSolaEntregaRequerida]
           ,[Activo]
           ,[FechaEntregaRequerida]
		   ,[FechaEntregaFinRequerida]
		   ,[IdProveedor]
		   ,[FechaAlta]
		   ,[EntregasParciales]
		   ,[IdContrato]
		   ,[IdPeriodo]
		   ,[IdPresupuesto]
		   ,[IdLineaPresupuesto]
		   ,[IdTipoGasto]
		   ,[IdTerminoInternacionales]
		   ,[UnicoDomicilioEntrega]
		   ,[IdDomicilioEntrega]
		   ,[IdCentroCosto]
		   ,[Fianza]
		   ,[Controlados]
		   )
     VALUES
           (
		    @IdTipoSolicitudPedido,
			@IdUsuarioSolicitante,
			@AdjudicableParcialmente, 
			@IdPrioridad,
			@MotivoUrgencia,
			@VisitaRequerida,
			@JuntaAclaracionesRequerida,
			@UnaSolaEntregaRequerida,
			@Activo,
			@FechaEntregaRequerida,
			@FechaEntregaFinRequeridaF,
			@IdProveedor,
			GETDATE(),
			@EntregasParciales
			,@IdContrato
			,@IdPeriodo
			,@IdPresupuesto
			,@IdLineaPresupuesto
			,0 --@IdTipoGasto
			,@IdTerminosInternacionalesF
			,@EntregaUnicoDomicilio
			,@IdDomiclioEntregaF
			,@IdCentroCosto
			,@Fianza
			,@Controlados
			)

	
	set @IdSolicitudPedido= (select @@IDENTITY)
	select @IdSolicitudPedido as IdSolicitudPedido

END

