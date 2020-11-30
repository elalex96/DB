
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <22-11-2018>
-- Description:	<Se actualiza una SolPed>
-- =============================================

CREATE PROCEDURE MM_SP_ActualizacionSolPed	
	@IdSolicitudPedido INT,
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
	@Controlados BIT,
	/*---------------------Parametros contrato---------------------*/
	--@IdContrato INT = NULL,
	--@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
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

	UPDATE dbo.MM_SolicitudPedido
		SET	IdTipoSolicitudPedido = @IdTipoSolicitudPedido,
			IdUsuarioSolicitante = @IdUsuarioSolicitante,
			AdjudicableParcialmente = @AdjudicableParcialmente, 
			IdPrioridadSolicitudPedido = @IdPrioridad,
			MotivoUrgencia = @MotivoUrgencia,
			VisitaRequerida = @VisitaRequerida,
			JuntaAclaracionesRequerida = @JuntaAclaracionesRequerida,
			UnaSolaEntregaRequerida = @UnaSolaEntregaRequerida,
			Activo = @Activo,
			FechaEntregaRequerida = @FechaEntregaRequerida,
			FechaEntregaFinRequerida = @FechaEntregaFinRequeridaF,
			IdProveedor = @IdProveedor,
			EntregasParciales = @EntregasParciales,
			IdContrato = @IdContrato,
			IdPeriodo = @IdPeriodo,
			IdPresupuesto = @IdPresupuesto,
			IdLineaPresupuesto = @IdLineaPresupuesto,
			IdTerminoInternacionales = @IdTerminosInternacionalesF,
			UnicoDomicilioEntrega = @EntregaUnicoDomicilio,
			IdDomicilioEntrega =@IdDomiclioEntregaF,
			IdCentroCosto = @IdCentroCosto,
			Fianza = @Fianza,
			Controlados = @Controlados
		WHERE IdSolicitudPedido = @IdSolicitudPedido

	SELECT @IdSolicitudPedido
END