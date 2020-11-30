-- =============================================
-- Author: Daniel AC
-- Update date: 05/12/2019
-- Description:	Se agrega el retorno de los compradores separados por coma  
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultarAdministradoresCompras] 
@IdProveedor INT ,
@IdContrato INT = NULL, 
@IdUsuario INT = NULL

AS
	BEGIN
		
			DECLARE @IdAdministradoresCompras NVARCHAR(MAX)

		SELECT	@IdAdministradoresCompras =
			( SELECT	STUFF (
							(	SELECT		CAST(' ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), ADC.IdUsuario )
								FROM		dbo.CC_AdministradorCompras AS ADC								
								INNER JOIN	dbo.S_Usuario AS U
									ON U.IdUsuario = ADC.IdUsuario
								INNER JOIN dbo.S_UsuarioProveedor UP ON UP.IdUsuario = U.IdUsuario																
								WHERE
											ADC.IdProveedor = @IdProveedor											
											AND U.Activo = 1
											AND ADC.Activo=1
								ORDER BY	U.Nombre
								FOR XML PATH ( '' )), 1, 1, '' ) AS IdUsuario )
	   

		SELECT @IdProveedor AS IdProveedor,'Administradores de compras' AS TipoAdministrador, @IdAdministradoresCompras AS IdUsuarios
        
		
	END

