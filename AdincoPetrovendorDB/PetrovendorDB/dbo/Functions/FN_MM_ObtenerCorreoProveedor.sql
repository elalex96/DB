USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'FN_MM_ObtenerCorreoProveedor'
)
    DROP FUNCTION FN_MM_ObtenerCorreoProveedor;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <05/07/2023>
-- Description:	<obtener el correo de contacto de un proveedor>
-- =============================================
CREATE FUNCTION FN_MM_ObtenerCorreoProveedor
(
	-- Add the parameters for the function here
	@IdProveedor INT
)
RETURNS NVARCHAR
AS
BEGIN
	-- Declare the return variable here
	DECLARE @CORREO NVARCHAR(100)

	-- Add the T-SQL statements to compute the return value here
	SET @CORREO = (SELECT TOP 1
						US.Correo
					FROM dbo.S_UsuarioProveedor AS UPR
						LEFT JOIN dbo.S_Usuario AS US 
						ON UPR.IdUsuario = US.IdUsuario
						AND UPR.IdProveedor = @IdProveedor
						AND US.IdTipoUsuario = 3
						AND US.Activo = 1
					ORDER BY US.FechaRegistro DESC)

	-- Return the result of the function
	RETURN ISNULL(@CORREO,'');

END
GO

