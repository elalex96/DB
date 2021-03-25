-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <22/03/2021>
-- Description:	<Consulta de validacion de correo electronico registrado>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ValidarPreRegistroProveedor]
	-- Add the parameters for the stored procedure here
	@Correo NVARCHAR(200),
	@IdSolicitudPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ProveedorEncontrado INT = (SELECT TOP 1
											PR.IdProveedor
										FROM dbo.S_Usuario AS US
											JOIN dbo.S_UsuarioProveedor AS USPR ON US.IdUsuario = USPR.IdUsuario
											JOIN dbo.S_Proveedor AS PR ON USPR.IdProveedor = PR.IdProveedor
										WHERE US.Correo = @Correo
											AND US.Activo = 1
											AND US.IdUsuarioADINCO IS NULL)

	DECLARE @PETICIONPROVEEDOR INT = 0;

	--SE VALIDA QUE EL CORREO ES DE UN PROVEEDOR REGISTRADO
	IF(ISNULL(@ProveedorEncontrado,0) > 0)
	BEGIN
		
		--SE BUSCA QUE EL PROVEEDOR NO TENGA NINGUNA PETICION OFERTA ENVIADA
		SET @PETICIONPROVEEDOR = (SELECT TOP 1
										IdPeticionOferta
									FROM dbo.MM_PeticionOferta AS PO
									WHERE IdSubcontratista = @ProveedorEncontrado
										AND IdSolicitudPedido = @IdSolicitudPedido)
		
		--SE VALIDA LA PETICION OFERTA EN CASO QUE EXISTA SI NO SE REGRESA EL SELECT
		IF(ISNULL(@PETICIONPROVEEDOR,0) = 0)
		BEGIN
			
			SELECT TOP 1
				'PROVEEDOR_EXISTENTE_NO_AGREGADO',
				US.Correo,
				US.IdUsuario,
				PR.RazonSocial,
				PR.IdProveedor,
				PR.RFC
			FROM dbo.S_Usuario AS US
				JOIN dbo.S_UsuarioProveedor AS USPR ON US.IdUsuario = USPR.IdUsuario
				JOIN dbo.S_Proveedor AS PR ON USPR.IdProveedor = PR.IdProveedor
			WHERE US.Correo = @Correo
				AND US.Activo = 1
				AND US.IdUsuarioADINCO IS NULL

		END
		ELSE
		BEGIN
			--EXISTE YA UNA OFERTA PARA EL PROVEEDOR
			SELECT 'PROVEDOR_PREVIAMENTE_AGREGADO'

		END

	END

	
END
