-- =============================================
-- Author:  Daniel A Cruz
-- Create date: 11-04-17
-- Description: SP que agrega Cabecera de Solicitud de Pedido
-- =============================================
-- Author:  Alexander Gomez
-- Create date: 01/12/2020
-- Description: validacion de contrato nulo 
-- Actualización 03/02/2021 - DAC --> obtener contrato mediante el periodo
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
        @Controlados bit,
		@IdSolicitante INT = NULL
AS
BEGIN
    DECLARE @IdSolicitudPedido int
    DECLARE @IdDomiclioEntregaF int 
    DECLARE @IdTerminosInternacionalesF int
    DECLARE @FechaEntregaFinRequeridaF nvarchar(max)
    DECLARE @RFC NVARCHAR(100)
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
    --VALIDACION DE CONTRATO VACIO
    IF ISNULL(@IdContrato,0) = 0
    BEGIN
        /*OBTENER EL CONTRATO POR MEDIO DEL PERIODO SELECCIONADO*/
		SELECT   @IdContrato=IdContrato 
		FROM      Adinco..CO_PeriodoContrato  
		WHERE    (IdPeriodo = @IdPeriodo)    

		IF ISNULL(@IdContrato,0) = 0
		BEGIN
		/*SI NO SE ENCONTRO EL CONTRATO POR MEDIO DEL PERIODO, BUSCARLO POR MEDIO DEL PROVEEDOR*/
        SET @RFC = (SELECT RFC FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor);
        SET @IdContrato = (SELECT TOP 1
                                IdContrato 
                            FROM Adinco.dbo.CO_Contratista AS CON
                            JOIN Adinco.dbo.CO_Contrato AS CO
                                ON CON.IdContratista = CO.IdContratista
                            WHERE CON.RFC = @RFC);
		END 
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
		   ,[Solicitante]
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
			,@IdSolicitante
            )
    
    set @IdSolicitudPedido= (select @@IDENTITY)
    select @IdSolicitudPedido as IdSolicitudPedido
END