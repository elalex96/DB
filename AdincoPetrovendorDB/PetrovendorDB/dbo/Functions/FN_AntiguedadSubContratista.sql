USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'FN_AntiguedadSubContratista'
)
    DROP FUNCTION FN_AntiguedadSubContratista;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30/01/2020>
-- Description:	<consultar el tiempo que tiene un subcontratista en la plataforma petrovendor>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <05/07/2023>
-- Description:	<Optimizacion del sp>
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
	FROM dbo.S_Proveedor AS PR (NOLOCK)
		LEFT JOIN dbo.S_UsuarioProveedor AS UP (NOLOCK)
			ON PR.IdProveedor = UP.IdProveedor
				AND UP.IsAdmin = 1
				AND PR.IdProveedor = @IdProveedor
		LEFT JOIN dbo.S_Usuario AS U (NOLOCK)
			ON UP.IdUsuario = U.IdUsuario
				AND U.IdTipoUsuario = 3
				AND U.Activo = 1
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

