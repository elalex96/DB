-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30/01/2020>
-- Description:	<consultar el tiempo que tiene un subcontratista en la plataforma petrovendor>
-- =============================================
CREATE FUNCTION [dbo].[FN_AntiguedadSubContratista]
(
	-- Add the parameters for the function here
	@IdProveedor INT
)
RETURNS NVARCHAR(20)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ANTIGUEDAD NVARCHAR(20);
	DECLARE @MESES INT;
	DECLARE @AÑOS INT;

	-- Add the T-SQL statements to compute the return value here
	SELECT TOP 1
		 @MESES = DATEDIFF(MONTH,U.FechaRegistro,GETDATE()),
		 @AÑOS = DATEDIFF(YEAR,U.FechaRegistro,GETDATE())
	FROM dbo.S_Proveedor AS PR
		LEFT JOIN dbo.S_UsuarioProveedor AS UP
			ON UP.IdProveedor = PR.IdProveedor
				AND UP.IsAdmin = 1
		LEFT JOIN dbo.S_Usuario AS U
			ON U.IdUsuario = UP.IdUsuario
				AND U.IdTipoUsuario = 3
				AND U.Activo = 1
	WHERE PR.IdProveedor = @IdProveedor
	ORDER BY U.FechaRegistro ASC;

	IF @MESES <= 12
	BEGIN
	    SET @ANTIGUEDAD = CONCAT(@AÑOS,' Meses con nostros')
	END

	IF @AÑOS > 0
	BEGIN
	    SET @ANTIGUEDAD = CONCAT(@AÑOS,' Años con nosotros')
	END

	IF @ANTIGUEDAD IS NULL
	BEGIN
	    SET @ANTIGUEDAD = 'Nuevo Proveedor';
	END

	-- Return the result of the function
	RETURN @ANTIGUEDAD;

END

