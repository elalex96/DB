CREATE procedure [dbo].[SP_MPY_InsPedidoImportado]
	-- Add the parameters for the stored procedure here
	@Version NVARCHAR(MAX), 
	@IdProveedor NVARCHAR(MAX), 
	@IdMaterial NVARCHAR(MAX),
	@Partida NVARCHAR(MAX), 
	@Cantidad FLOAT, 
	@PrecioUnitario FLOAT, 
	@Moneda NVARCHAR(MAX), 
	--@SubTotal NVARCHAR(MAX), 
	@DomicilioEntrega NVARCHAR(MAX), 
	@IdPedido NVARCHAR(MAX), 
	@FechaEntrega NVARCHAR(MAX), 
	@Observaciones NVARCHAR(MAX), 
	@CostObjetc NVARCHAR(MAX), 
	@MaterialGroup NVARCHAR(MAX), 
	@MaterialGroupDesc2 NVARCHAR(MAX), 
	@ServiceLineNumber NVARCHAR(MAX), 
	@Qty NVARCHAR(MAX), 
	@Price NVARCHAR(MAX), 
	@costobject2 NVARCHAR(MAX), 
	@servicegroup NVARCHAR(MAX),
	@IdProveedorC NVARCHAR(MAX),
	@IdUsuario INT,
	@IdContrato NVARCHAR(MAX),
	--
	@ShortText varchar(100)='NA',
	@ParentLineUOM varchar(50)='NA',
	@ServiceShortText varchar(50)='NA',
	@ServicesUOM varchar(50)='NA'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IDACEPTACIONPEDIDO INT;
	DECLARE @IDACEPTACIONPEDIDODETALLE INT;
    -- Insert statements for procedure here

	/*DATOS VENDOR*/
	declare @RazonSocial NVARCHAR(MAX), 
			@RFC NVARCHAR(MAX), 
			@Pais NVARCHAR(MAX), 
			@Direccion NVARCHAR(MAX), 
			@Contacto NVARCHAR(MAX), 
			@EmailContacto NVARCHAR(MAX), 
			@ID NVARCHAR(MAX)

	select @RazonSocial = VendorName,
		@RFC = TaxID,
		@Pais = Country,
		@Direccion = Address,
		@Contacto = ContactName,
		@EmailContacto = ContactEmail
	from Adinco.dbo.CO_SAPVendor
	where RTRIM(VendorIDSAP) = RTRIM(@IdProveedor)

	SET @IDACEPTACIONPEDIDO = (SELECT max(IdAceptacionPedido)
									FROM dbo.MPY_MM_AceptacionPedido 
									WHERE 
									--IdSubContratista =  @IdProveedorC
									 IdProveedor =  @IdProveedor AND
									 IdPedido = @IdPedido)

	IF ISNULL(@IDACEPTACIONPEDIDO,0) = 0
	BEGIN 
		INSERT INTO dbo.MPY_MM_AceptacionPedido
		(
		IdProveedor,
	    IdSubContratista,
	    IdPedido,
	    Comentario,
	    Activo,
	    Creado,
	    IdDomicilioEntrega,
	    CreadorPor,
	    Version,
	    CostObject,
	    MaterialGroup,
	    MaterialgroupDesc2,
	    Qty,
	    Price,
	    costobject2,
	    ServiceGroup,
		IdContrato,
		VendorsName ,
		VendorAddress ,
		Contacto  ,
		CorreoContacto,
		PaisSAP ,
		ServiceLineNumber,
		ShortText,
		ParentLineUOM,
		ServiceShortText,
		ServicesUOM
		)
		VALUES
		(
		@IdProveedorC,
		@IdProveedor,       -- IdProveedor - nvarchar(20)
	    @IdPedido,       -- IdPedido - nvarchar(20)
	    @Observaciones,        -- Comentario - varchar(1500)
	    1,
		GETDATE(),
		@DomicilioEntrega,
		@IdUsuario,
		@Version,
		@CostObjetc,
		@MaterialGroup,
		@MaterialGroupDesc2,
		@Qty,
		@Price,
		@costobject2,
		@servicegroup,
		@IdContrato,
		@RazonSocial,
		@Direccion,
		@Contacto,
		@EmailContacto,
		@Pais,
		@ServiceLineNumber,
		@ShortText,
		@ParentLineUOM,
		@ServiceShortText,
		@ServicesUOM)

		SET @IDACEPTACIONPEDIDO = (@@IDENTITY)
	END
	Else
	Begin
		update MPY_MM_AceptacionPedido
		set Comentario=@Observaciones,	    	    
	    IdDomicilioEntrega=@DomicilioEntrega,	    
	    Version=@Version,
	    CostObject = @CostObjetc,
	    MaterialGroup=@MaterialGroup,
	    MaterialgroupDesc2=@MaterialGroupDesc2,
	    Qty=@Qty,
	    Price=@Price,
	    costobject2=@costobject2,
	    ServiceGroup=@servicegroup,
		IdContrato=@IdContrato,
		VendorsName =@RazonSocial,
		VendorAddress =@Direccion,
		Contacto  =@Contacto,
		CorreoContacto=@EmailContacto,
		PaisSAP =@Pais ,
		ServiceLineNumber=@ServiceLineNumber,
		ShortText = @ShortText,
		ParentLineUOM=@ParentLineUOM,
		ServiceShortText = @ServiceShortText,
		ServicesUOM = @ServicesUOM
		where IdAceptacionPedido = @IDACEPTACIONPEDIDO
	End

	if not exists (
		select 1
		from MPY_MM_AceptacionPedidoDetalle
		where IdAceptacionPedido = @IDACEPTACIONPEDIDO and
		Partida = @Partida
	)
	begin

		INSERT INTO dbo.MPY_MM_AceptacionPedidoDetalle
		(
			IdAceptacionPedido,
			Cantidad,
			Detalle,
			Creado,
			PrecioUnitario,
			IdMoneda,
			Partida
		)
		VALUES
		(   
	
			@IDACEPTACIONPEDIDO,         -- IdAceptacionPedido - int
			@Cantidad,
			@IdMaterial,
			GETDATE(),
			@PrecioUnitario,
			@Moneda,
			@Partida
		)

		SET @IDACEPTACIONPEDIDODETALLE = (@@IDENTITY)

	end
	Else
	Begin
		update MPY_MM_AceptacionPedidoDetalle
		set Cantidad=@Cantidad,
			Detalle = @IdMaterial,			
			PrecioUnitario=@PrecioUnitario,
			IdMoneda = @Moneda
		where IdAceptacionPedido = @IDACEPTACIONPEDIDO and
		Partida = @Partida
	End

	


	SELECT @IDACEPTACIONPEDIDO,@IDACEPTACIONPEDIDODETALLE
END

