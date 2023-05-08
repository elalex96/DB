-- =============================================
-- Author:		Daniel AC
-- Create date: 24-10-17
-- Description:	Agregar/Editar registro de edición de cotización
 
CREATE PROCEDURE [dbo].[SP_MM_AgregarEditarCotizacion]  
	-- Add the parameters for the stored procedure here

@IdPeticionOferta INT,
@IdProveedor INT,
@IdUsuario INT,
@IdEdicionCotizacion INT,
@ACCION NVARCHAR(350)
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

         SET NOCOUNT ON;
		 DECLARE @EXIST_REGISTRO INT
		 DECLARE @NOMBRE_USUARIO NVARCHAR(350)
		 DECLARE @DETALLE NVARCHAR(MAX)
		

		IF @ACCION = 'INICIAR_EDICION'
		BEGIN
		 SET @EXIST_REGISTRO = (SELECT COUNT(EC.IdEdicionCotizacion)
								FROM dbo.MM_EdicionCotizacion AS EC
								INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = EC.IdPeticionOferta
								WHERE EC.IdPeticionOferta= @IdPeticionOferta)
		
		 IF @EXIST_REGISTRO = 0 
		 BEGIN 
			INSERT INTO dbo.MM_EdicionCotizacion
			(
			    IdPeticionOferta,
			    IdProveedor,
			    CreadoEl,
			    IdCreadorPor,			   
			    IdEstatus
			)
			VALUES
			(   @IdPeticionOferta,    -- IdPeticionOferta - int
			    @IdProveedor,         -- IdProveedor - int
			    GETDATE(),   	 	  -- CreadoEl - datetime
			    @IdUsuario,				
			    1                        -- IdEstatus - int
			    )

			SET @IdEdicionCotizacion = (SELECT @@IDENTITY)
			
			
			SET @DETALLE = ('Edición iniciada')
			 INSERT INTO MM_HistorialEdicionCotizacion(
			 [IdEdicionCotizacion],		     
			 [IdUsuario],
		     [IdProveedor],
			 [Fecha],
		     [EdicionCabecera],
			 [Descripcion]
			 )
			 VALUES(
			 @IdEdicionCotizacion,
			 @IdUsuario,
			 @IdProveedor,
			 GETDATE(),
			 1,
			 @DETALLE
			 )

			  SELECT 'SUCCESS',@IdEdicionCotizacion

		 END
		 ELSE
		 BEGIN 

		 UPDATE dbo.MM_EdicionCotizacion
		 SET ModificadoEl = GETDATE(),
		 ModificadoPor = @IdUsuario,
		 IdEstatus = 1 --ESTATUS PENDIENTE = EN EDICION
		 WHERE IdEdicionCotizacion = @IdEdicionCotizacion

		
		 SET @DETALLE = ('Edición iniciada')
		  INSERT INTO MM_HistorialEdicionCotizacion(
			 [IdEdicionCotizacion],		     
			 [IdUsuario],
		     [IdProveedor],
			 [Fecha],
		     [EdicionCabecera],
			 [Descripcion]
			 )
			 VALUES(
			 @IdEdicionCotizacion,
			 @IdUsuario,
			 @IdProveedor,
			 GETDATE(),
			 1,
			 @DETALLE
			 )

			 SELECT 'SUCCESS',@IdEdicionCotizacion
		 END 
		END 

		IF @ACCION='TERMINAR_EDICION'
		BEGIN 

	     UPDATE dbo.MM_EdicionCotizacion
		 SET ModificadoEl = GETDATE(),
		 ModificadoPor = @IdUsuario,
		 IdEstatus = 2 --ESTATUS APROBADO = EN EDICION FINALIZADA
		 WHERE IdEdicionCotizacion = @IdEdicionCotizacion

		 SET @NOMBRE_USUARIO = (SELECT Nombre FROM S_Usuario WHERE IdUsuario=@IdUsuario)
		 SET @DETALLE = ('Edición finalizada')

		  INSERT INTO MM_HistorialEdicionCotizacion(
			 [IdEdicionCotizacion],		     
			 [IdUsuario],
		     [IdProveedor],
			 [Fecha],
		     [EdicionCabecera],
			 [Descripcion]
			 )
			 VALUES(
			 @IdEdicionCotizacion,
			 @IdUsuario,
			 @IdProveedor,
			 GETDATE(),
			 1,
			 @DETALLE
			 )

			SELECT 'SUCCESS', @IdEdicionCotizacion
		END 

     END;

