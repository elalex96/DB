USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ValidarPreRegistroProveedor'
)
    DROP PROCEDURE SP_MM_ValidarPreRegistroProveedor;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <22/03/2021>
-- Description:	<Consulta de validacion de correo electronico registrado>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19-07-2023>
-- Description:	aplicacion de optimizaciones y estandares de desarrollo issue:https://github.com/Adinco/petrovendor/issues/2379
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

	DECLARE @ProveedorEncontrado INT;
	DECLARE @PETICIONPROVEEDOR INT = 0;

	SET @ProveedorEncontrado = (SELECT TOP 1
											PR.IdProveedor
										FROM dbo.S_Usuario AS US (NOLOCK)
											JOIN dbo.S_UsuarioProveedor AS USPR (NOLOCK) 
												ON US.IdUsuario = USPR.IdUsuario
											JOIN dbo.S_Proveedor AS PR (NOLOCK) 
												ON USPR.IdProveedor = PR.IdProveedor
										WHERE US.Correo = @Correo
											AND US.Activo = 1
											AND US.IdUsuarioADINCO IS NULL)

	--SE VALIDA QUE EL CORREO ES DE UN PROVEEDOR REGISTRADO
	IF(ISNULL(@ProveedorEncontrado,0) > 0)
	BEGIN
		
		--SE BUSCA QUE EL PROVEEDOR NO TENGA NINGUNA PETICION OFERTA ENVIADA
		SET @PETICIONPROVEEDOR = (SELECT TOP 1
										IdPeticionOferta
									FROM dbo.MM_PeticionOferta AS PO (NOLOCK)
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
			FROM dbo.S_Usuario AS US (NOLOCK)
				JOIN dbo.S_UsuarioProveedor AS USPR (NOLOCK) 
					ON US.IdUsuario = USPR.IdUsuario
				JOIN dbo.S_Proveedor AS PR (NOLOCK) 
					ON USPR.IdProveedor = PR.IdProveedor
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
