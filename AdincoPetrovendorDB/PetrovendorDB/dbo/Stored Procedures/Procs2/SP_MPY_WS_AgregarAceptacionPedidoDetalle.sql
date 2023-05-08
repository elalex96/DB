-- =============================================
-- Author:		Alexander Gomez
-- Create date: 03/07/2018
-- Description:	Insertar los detalles(conceptos) del pedido mediante webservice
-- =============================================
CREATE procedure [dbo].[SP_MPY_WS_AgregarAceptacionPedidoDetalle]
	-- Add the parameters for the stored procedure here
	@IdAceptacionPedido INT,
	@Cantidad FLOAT,
	@Detalle NVARCHAR(MAX),
	@Exedente FLOAT,
	@PrecioUnitario FLOAT,
	@IdMoneda NVARCHAR(MAX),
	@Unidad NVARCHAR(MAX),
	@id INT,
	@ordenId INT,
    @articuloCodigoInterno NVARCHAR(MAX),
    @importe FLOAT,
    @ocTareaId INT,
    @ocTareaCodigo NVARCHAR(MAX),
    @ocTareaNombre NVARCHAR(MAX),
    @articuloUnidadId INT,
    @monedaId INT,
    @ocProductoCompaniaId INT,
    @ocProductoNombre NVARCHAR(MAX),
    @ocProductoCodigo NVARCHAR(MAX),
    @articuloNombre NVARCHAR(MAX),
    @articuloId INT,
    @observaciones NVARCHAR(MAX),
    @textNav NVARCHAR(MAX),
    @fechaRecepcion DATE,
    @recibido BIT,
    @proyectoOtId INT,
    @proyectoOtNombre NVARCHAR(MAX),
    @ocSubTareaId INT,
    @ocSubTareaNombre NVARCHAR(MAX),
    @ocActividadPetroleraId INT,
    @ocActividadPetroleraNombre NVARCHAR(MAX),
    @tipoTareaId INT,
    @tipoTareaNombre NVARCHAR(MAX),
    @descuento FLOAT,
    @ocSubTareaCodigo NVARCHAR(MAX),
    @cuentaContable NVARCHAR(MAX)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.MPY_MM_AceptacionPedidoDetalle
	(
	    IdAceptacionPedido,
	    Cantidad,
	    Detalle,
	    Creado,
	    Excedente,
	    PrecioUnitario,
	    IdMoneda,
	    Unidad,
		[id]
		  ,[ordenId]
		  ,[articuloCodigoInterno]
		  ,[importe]
		  ,[ocTareaId]
		  ,[ocTareaCodigo]
		  ,[ocTareaNombre]
		  ,[articuloUnidadId]
		  ,[monedaId]
		  ,[ocProductoCompaniaId]
		  ,[ocProductoNombre]
		  ,[ocProductoCodigo]
		  ,[articuloNombre]
		  ,[articuloId]
		  ,[observaciones]
		  ,[textNav]
		  ,[fechaRecepcion]
		  ,[recibido]
		  ,[proyectoOtId]
		  ,[proyectoOtNombre]
		  ,[ocSubTareaId]
		  ,[ocSubTareaNombre]
		  ,[ocActividadPetroleraId]
		  ,[ocActividadPetroleraNombre]
		  ,[tipoTareaId]
		  ,[tipoTareaNombre]
		  ,[descuento]
		  ,[ocSubTareaCodigo]
		  ,[cuentaContable]
	)
	VALUES
	(   @IdAceptacionPedido,         -- IdAceptacionPedido - int
	    @Cantidad,       -- Cantidad - float
	    @Detalle,        -- Detalle - varchar(1500)
	    GETDATE(), -- Creado - datetime
	    @Exedente,       -- Excedente - float
	    @PrecioUnitario,       -- PrecioUnitario - float
	    @IdMoneda,         -- IdMoneda - int
		@Unidad,
		@id,
		@ordenId,
		@articuloCodigoInterno,
		@importe,
		@ocTareaId,
		@ocTareaCodigo,
		@ocTareaNombre,
		@articuloUnidadId,
		@monedaId,
		@ocProductoCompaniaId,
		@ocProductoNombre,
		@ocProductoCodigo,
		@articuloNombre,
		@articuloId,
		@observaciones,
		@textNav,
		@fechaRecepcion,
		@recibido,
		@proyectoOtId,
		@proyectoOtNombre,
		@ocSubTareaId,
		@ocSubTareaNombre,
		@ocActividadPetroleraId,
		@ocActividadPetroleraNombre,
		@tipoTareaId,
		@tipoTareaNombre,
		@descuento,
		@ocSubTareaCodigo,
		@cuentaContable
	    )

		SELECT @@IDENTITY
END
