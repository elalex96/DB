
-- =============================================
-- Author: Daniel AC
-- Date: 21/11/2019
-- Description: Validación de administradores de compras 
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ConsultarValidacionesDefault]
    @IdProveedor INT,
    @IdUsuario INT
AS
BEGIN

    DECLARE @IdTipoUsuario INT;


    SELECT @IdTipoUsuario = IdTipoUsuario
    FROM dbo.S_Usuario
    WHERE IdUsuario = @IdUsuario;

	IF @IdTipoUsuario = 3 --> CTE ADMIN 
	BEGIN 
		
		--TABLA 1
		SELECT 'ES_ADMINISTRADOR'

		DECLARE @CentrosCostosSinCompradores NVARCHAR(MAX)
		SET @CentrosCostosSinCompradores =(SELECT	ISNULL(STUFF (
		(	SELECT		CAST(', ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), CONCAT(CC.CentroCosto,' (',CC.numero,')' ))
			FROM		dbo.CC_CentroCosto CC 
			LEFT JOIN dbo.CC_CentroCostoGrupoCompras CG 
				ON CG.IdCentroCosto=CC.IdCentroCosto
				AND CG.Activo=1								
			WHERE CC.IdProveedor=@IdProveedor
				AND CC.IsActivo=1
				AND CG.IdCentroCostoGrupoCompras IS NULL
			ORDER BY CC.CentroCosto ASC
			FOR XML PATH ( '' )), 1, 1, '' ),''))  

		--TABLA 2
		SELECT COUNT(IdAdministradorCompras) AS NumeroAdmiCompras, @CentrosCostosSinCompradores AS CentrosCostosSinCompradores
		FROM dbo.CC_AdministradorCompras 
		WHERE IdProveedor=@IdProveedor 
		AND Activo=1


		

		 

	END 


END;
