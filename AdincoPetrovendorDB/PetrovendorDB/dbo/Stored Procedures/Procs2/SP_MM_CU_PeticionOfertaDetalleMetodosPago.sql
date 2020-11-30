-- =============================================
-- Author:  Daniel AC
-- Create date: 16-10-2019
-- Description:Consultar métodos de pago Y ACTUALIZAR EN LA COTIZACIÓN DETALLE 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MM_CU_PeticionOfertaDetalleMetodosPago] --2822,44
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdUsuario INT,
	@IdPeticionOfertaDetalle INT , 
	@IdPeticionOferta INT, 
	@Accion NVARCHAR(MAX),
	@IdCondicionPago INT,
	@DiasCredito INT
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets  from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;
		DECLARE @HayPedidos INT 
		DECLARE @IdSolicitudPedido INT 
		SELECT @IdSolicitudPedido=IdSolicitudPedido FROM dbo.MM_PeticionOferta WHERE IdPeticionOferta =@IdPeticionOferta

		SET @HayPedidos =(SELECT COUNT(IdPedido) 
							FROM dbo.MM_Pedido 
							WHERE IdSolicitudPedido =@IdSolicitudPedido 
							AND ISNULL(IdEstatusEliminado,0)=0)
		
		IF @Accion='CONSULTAR'
		BEGIN 			
			
			SELECT POD.IdCondicionPago, POD.DiasCredito, POD.IdPeticionOfertaDetalle, POD.Cotizado,@HayPedidos
			FROM dbo.MM_PeticionOfertaDetalle POD 
			WHERE POD.IdPeticionOfertaDetalle=@IdPeticionOfertaDetalle
			AND POD.IdPeticionOferta=@IdPeticionOferta			

		END 

		IF @Accion='ACTUALIZAR'
		BEGIN 
			
			IF @HayPedidos =0
			BEGIN 


			DECLARE @Detalle NVARCHAR(MAX)=''
			DECLARE @IdCondicionDePago_Actual INT 
			DECLARE @DiasCredito_Actual INT
			
			SELECT @IdCondicionDePago_Actual = POD.IdCondicionPago,@DiasCredito_Actual= POD.DiasCredito
			FROM dbo.MM_PeticionOfertaDetalle POD 
			WHERE POD.IdPeticionOfertaDetalle=@IdPeticionOfertaDetalle
			AND POD.IdPeticionOferta=@IdPeticionOferta	

			IF ISNULL(@IdCondicionDePago_Actual,0) <> @IdCondicionPago 
						BEGIN 
							SET @Detalle
									= ( @Detalle + ' *Cambio condicion de pago de: '
										+ CAST(ISNULL ((SELECT CondicionPago FROM dbo.MM_CondicionPago WHERE IdCondicionPago=ISNULL(@IdCondicionDePago_Actual,0)), 'Sin registrar' ) AS NVARCHAR (MAX)) + ' a: '
										+ CAST(ISNULL ( (SELECT CondicionPago FROM dbo.MM_CondicionPago WHERE IdCondicionPago=ISNULL(@IdCondicionPago,0)), '' ) AS NVARCHAR (MAX)) + ' ' ) ;
						END 

			IF ISNULL(@DiasCredito_Actual,0) <>  @DiasCredito
			BEGIN 
				SET @Detalle
						= ( @Detalle + ' *Cambio días de crédito de: '
							+ CAST(ISNULL (@DiasCredito_Actual, 0) AS NVARCHAR (MAX)) + ' a: '
							+ CAST(ISNULL (@DiasCredito,0) AS NVARCHAR (MAX)) + ' ' ) ;
			END 

			IF @Detalle <>''
			BEGIN 
			INSERT INTO dbo.MM_EdicionCotizacion
			( IdPeticionOferta,IdProveedor, CreadoEl,IdCreadorPor,IdEstatus)
			VALUES
			(   @IdPeticionOferta,@IdProveedor,GETDATE(),@IdUsuario,NULL)

			DECLARE @IdEdicionCotizacion INT = (SELECT @@IDENTITY)
			INSERT INTO MM_HistorialEdicionCotizacion
							( [IdEdicionCotizacion], [IdUsuario], [IdProveedor], [Fecha], [IdPeticionOfertaDetalle] ,
							  [Descripcion] )
						VALUES
							( @IdEdicionCotizacion, @IdUsuario, @IdProveedor, GETDATE () ,
							  @IdPeticionOfertaDetalle , ISNULL ( @Detalle, 'Cambio no identificado.' ))
			END 

			UPDATE dbo.MM_PeticionOfertaDetalle 
			SET IdCondicionPago=@IdCondicionPago,
			DiasCredito=@DiasCredito
			WHERE IdPeticionOfertaDetalle=@IdPeticionOfertaDetalle
			AND IdPeticionOferta=@IdPeticionOferta

			SELECT 'SUCCESS',IdPeticionOfertaDetalle
			FROM dbo.MM_PeticionOfertaDetalle POD 
			WHERE POD.IdPeticionOfertaDetalle=@IdPeticionOfertaDetalle
			AND POD.IdPeticionOferta=@IdPeticionOferta
			END 
			ELSE 
			BEGIN 
				SELECT 'HAY_PEDIDOS'
			END 

		END 
	
	END
