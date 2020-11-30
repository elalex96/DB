-- =============================================
-- Author:	DANIEL AC
-- Create date: 09/10/2017
-- Description:	 
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarAccesoPaginaActual]
@PaginaActual nvarchar(300),
@IdUsuario int
AS

BEGIN


	SET NOCOUNT ON;
	DECLARE @ACCESO NVARCHAR(300) = 'SIN_PERMISOS'
	DECLARE @IdTipoUsuario INT =0

	SET @IdTipoUsuario = (SELECT IdTipoUsuario
						  FROM S_Usuario AS U
						  WHERE U.IdUsuario= @IdUsuario)

	IF @IdTipoUsuario > 0 
	BEGIN 

		  SET @ACCESO =  (SELECT  TOP 1
			CASE WHEN PM.Activo = 0 THEN 
					'PERMITIDO'
				 WHEN PM.Activo  = 1 THEN 
					'DENEGADO'
				 ELSE 
					'SIN_PERMISOS'
				END 			 
		  FROM Modulo M
		  INNER JOIN PerfilModulo PM  ON M.IdModulo = PM.IdModulo 
		  WHERE PM.IdPerfil = @IdTipoUsuario
		  AND M.URL_MODULO = @PaginaActual)

	  END 

	  SELECT ISNULL(@ACCESO,'SIN_PERMISOS') 
END

