-- =============================================
-- Author:		DAC
-- Create date: 08/11/2017
-- Description:	 ACTUALIZAR OPERACIONES INVOLUCRADAS EN UNA OPERACIÓN DE COMPRA DIRECTA
-- =============================================
create PROCEDURE [dbo].[SP_CD_AgregarPedidoCompraDirecta] 
	-- Add the parameters for the stored procedure here

	 @IdSolicitudPedido INT,
	 @IdPeticionOferta INT,
	 @IdOperacionSP INT,
	 @IdOperacionPeticion INT,
	 @IdProveedorCompraDirecta INT,
	 @IdProveedor INT,
	 @IdUsuario INT,
	 @IdFlujo INT,
	 @IdVigencia INT,
	 @IdPrioridad INT, 
	 @IdMoneda INT,
	 @IdFactura INT
	  

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @VERSION INT
	DECLARE @IdPedidoActual INT 
	DECLARE @IdTipoOperacionPedido INT = 9 
	DECLARE @IdOperacionActual INT 
	DECLARE @IdTipoCompra INT = 3

	UPDATE dbo.TA_Operacion 
	SET IdEstatusOperacion= 2,
	IdEstadoFlujo =3,
	FechaModificacion = GETDATE()
	WHERE IdOperacion = @IdOperacionSP;

	UPDATE dbo.MM_PeticionOferta 
	SET Cotizado = 2,
	NoCotizar = 0,
	ModificadoPor = @IdUsuario,
    ModificadoEl = GETDATE(),
    IdEstatus = 2,
	Visto=1,
	Activo=1,
    FechaFinalizado= GETDATE()
	WHERE IdPeticionOferta=  @IdPeticionOferta


	UPDATE dbo.TA_Operacion 
	SET IdEstatusOperacion= 2,
	IdEstadoFlujo = 2,
	FechaModificacion = GETDATE()
	WHERE IdOperacion =@IdOperacionPeticion;

	UPDATE dbo.MM_SolicitudPedido 
	SET IdTipoCompra =  @IdTipoCompra
	WHERE IdSolicitudPedido =@IdSolicitudPedido
	 
	---#AGREGAR PEDIDO DIRECTO ---
	SET @VERSION =(SELECT TOP 1 P.Version
						   FROM MM_Pedido AS P
						   WHERE IdSolicitudPedido = @IdSolicitudPedido
						   ORDER BY Version DESC) 

			SET  @VERSION = ISNULL(@VERSION,0) + 1

	INSERT INTO MM_Pedido(IdPeticionOferta,Comentarios, IdSolicitudPedido,IdSubcontratista, IdContrato,  Editado, CreadoEl, CreadoPor,IdProveedorCompras,Version,IdMoneda, RecepcionServicio)
	SELECT    PO.IdPeticionOferta,'', SP.IdSolicitudPedido, PO.IdSubcontratista, SP.IdContrato,0 AS editado,GETDATE(), @IdUsuario, @IdProveedor,@VERSION,@IdMoneda, 1
	FROM MM_PeticionOferta AS PO
	INNER JOIN MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
	INNER JOIN MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle 
	wHERE PO.IdSolicitudPedido= @IdSolicitudPedido AND PO.IdSubcontratista= @IdProveedorCompraDirecta  AND PO.IdPeticionOferta = @IdPeticionOferta
	GROUP BY PO.IdPeticionOferta,SP.IdSolicitudPedido, PO.IdSubcontratista, SP.IdContrato
	
	SET @IdPedidoActual = (SELECT @@IDENTITY)

	INSERT INTO dbo.MM_HorasVigenciaPedido(IdPedido,HorasVigencia,FechaVigencia)
			VALUES
			(@IdPedidoActual,  -- IdPedido - int
			 0,                -- HorasVigencia - int
			 GETDATE()		   -- FechaCreacionPedido - smalldatetime
			)
	
	INSERT INTO MM_PedidoDetalle(IdPedido, IdMaterial,IdMaterialVendedor, IdPeticionOfertaDetalle, PrecioUnitario,Cantidad,IdMoneda, Subtotal, Activo, ComentariosCompras, CreadoPor, CreadoEl, RecepcionPedido,FechaRecepcionPedido)

	SELECT   @IdPedidoActual AS IdPedido, POD.IdMaterial,POD.IdMaterialVendedor, POD.IdPeticionOfertaDetalle, POD.PrecioUnitario,POD.Disponibilidad,POD.IdMoneda,POD.SubTotal,1,'', @IdUsuario AS CreadoPor, GETDATE() As CreadoEl, 1,GETDATE() 
	FROM MM_PeticionOferta AS PO
	INNER JOIN MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
	INNER JOIN MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle 
	wHERE PO.IdSolicitudPedido= @IdSolicitudPedido AND PO.IdSubcontratista=@IdProveedorCompraDirecta  AND PO.IdPeticionOferta=  @IdPeticionOferta
			
	INSERT INTO TA_Operacion(IdDocumento,IdTipoOperacion,IdFlujoTarea,IdEstadoFlujo,IdEstatusOperacion,IdProveedor,IdAsignador,FechaRegistro,Descripcion, IdVigencia, IdPrioridad,NoVersion)
	VALUES(@IdSolicitudPedido,@IdTipoOperacionPedido,@IdFlujo,2,2,@IdProveedor,@IdUsuario,GETDATE(),'Aprobación de pedido Compra Directa',@IdVigencia, @IdPrioridad,@VERSION)
			
	SET @IdOperacionActual = (SELECT @@IDENTITY) 

	INSERT INTO TA_Tarea(IdAprobador, IdEstatus,NombreTarea ,Visto,FechaRegistro, Activo, NoSecuencia,IdOperacion,FechaCambioEstatus)
	SELECT A.IdUsuario,2 AS  Estatus,'Aprobación de pedido Compra Directa', 0 as Visto,getdate() AS FechaRegistro,1, A.NoSecuencia, @IdOperacionActual AS IdOperacion, GETDATE() AS FechaCambioEstatus
	FROM TA_Aprobador AS A
	INNER JOIN TA_FlujoTarea AS FT ON FT.IdFlujoTarea = A.IdFlujoTarea
	INNER JOIN S_Usuario AS U on U.IdUsuario = A.IdUsuario
	WHERE A.IdFlujoTarea = @IdFlujo
	ORDER BY  NoSecuencia ASC

	INSERT INTO dbo.CO_RegistroPedido
	(
	    IdFactura,
	    IdSolicitudPedido,
	    CreadorEl,
	    CreadoPor
	)
	VALUES
	(   @IdFactura,         -- IdFactura - int
	    @IdSolicitudPedido,         -- IdSolicitudPedido - int
	    GETDATE(), -- CreadorEl - datetime
	    @IdUsuario         -- CreadoPor - int
	    )


	SELECT 'SUCCESS'
END




