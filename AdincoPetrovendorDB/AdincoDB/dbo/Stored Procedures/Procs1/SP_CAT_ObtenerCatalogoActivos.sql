
-- =============================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Edición:	02 de Marzo del 2023
-- Descripción:			Obtener catalogo de activos
-- =============================================
CREATE PROCEDURE [dbo].[SP_CAT_ObtenerCatalogoActivos]
	@ContratoId INT = 0,
	@UsuarioId INT = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CAT_Activos TABLE (
		Activo BIT,
		Nombre VARCHAR(20),
		NombreCorto VARCHAR(10)
		)

	INSERT INTO @CAT_Activos (
		Activo,
		Nombre,
		NombreCorto
		)
	VALUES (
		1,
		'Activo',
		'Si'
		),
		(
		0,
		'Inactivo',
		'No'
		)

	SELECT Activo,
		Nombre,
		NombreCorto
	FROM @CAT_Activos
END