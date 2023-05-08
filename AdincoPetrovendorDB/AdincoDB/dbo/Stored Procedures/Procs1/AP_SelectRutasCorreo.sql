
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 03-08-2018
-- Description: Extrae las rutas
-- =============================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Edición:	20 de Febrero del 2023
-- Descripción:			Ajuste de order by por ruta en orden alfabetico como mejora Ruta
-- =============================================
CREATE PROCEDURE [dbo].[AP_SelectRutasCorreo]
	@IdUsuario INT = 0,
	@idContrato INT = 0
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #AP_Rutas (
		[idRuta] INT NULL,
		[Ruta] NVARCHAR(100) NULL,
		[Id] INT IDENTITY NOT NULL
		);

	INSERT INTO #AP_Rutas (
		idRuta,
		Ruta
		)
	SELECT idRuta,
		Ruta
	FROM AP_Rutas (NOLOCK)
	WHERE Ruta IN (RTRIM(LTRIM('sindefinir')))

	INSERT INTO #AP_Rutas (
		idRuta,
		Ruta
		)
	SELECT 
		idRuta,
		Ruta
	FROM AP_Rutas (NOLOCK)
	WHERE Ruta NOT IN (RTRIM(LTRIM('sindefinir')))
	ORDER BY Ruta ASC

	SELECT 
		idRuta,
		Ruta
	FROM #AP_Rutas
	ORDER BY Id ASC
END