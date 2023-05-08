CREATE PROCEDURE [dbo].[Mobile_M_Rondas]
AS
BEGIN
	SELECT IdRonda AS 'IdRonda', Descripcion AS 'NombreRonda' FROM dbo.CO_Rondas
END