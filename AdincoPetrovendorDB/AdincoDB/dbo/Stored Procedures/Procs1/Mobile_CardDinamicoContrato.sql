CREATE PROCEDURE [dbo].[Mobile_CardDinamicoContrato]
@IdContrato INT,
@Idioma INT,
@IdUsuario INT,
@IdApp INT = 0
AS
BEGIN
DECLARE 
	@ConfigC  INT,
	@ConfigU INT;
IF	@IdApp = 1 
BEGIN
--SET @ConfigU = (SELECT COUNT(IdMnu) AS 'Conf' FROM dbo.AM_MenuUsuario WHERE IdUsuario = @IdUsuario)
--SET @ConfigC = (SELECT COUNT(Id) AS 'Conf' FROM AM_MenuContrato WHERE IdContrato =@IdContrato)

--IF	@ConfigU > 0
--BEGIN
--		SELECT 
--	MC.IdMenu,
--	CASE when @Idioma = 1 
--		THEN MC.TituloEs ELSE MC.TituloEn END AS 'Titulo',
--		CASE when @Idioma = 1 
--		THEN MC.SubtituloEs ELSE MC.SubtituloEn END AS 'Subitulo',
--	MC.CardIcon,
--	MC.AlertColor
--	FROM dbo.AM_MenuUsuario AS Mu
--	JOIN dbo.AM_MenuCard AS Mc
--	ON Mc.IdMenu = Mu.IdMenu
--	WHERE Mu.IdUsuario = @IdUsuario
--	ORDER BY Mc.IdMenu ASC
    
--	RETURN;
--END
--IF	@ConfigC > 0 
--BEGIN
--	SELECT 
--	MC.IdMenu,
--	CASE when @Idioma = 1 
--		THEN MC.TituloEs ELSE MC.TituloEn END AS 'Titulo',
--		CASE when @Idioma = 1 
--		THEN MC.SubtituloEs ELSE MC.SubtituloEn END AS 'Subitulo',
--	MC.CardIcon,
--	MC.AlertColor
--	FROM AM_MenuCard AS MC
--	JOIN AM_MenuContrato AS MenC
--	ON MC.IdMenu = MenC.IdMenu
--	WHERE MenC.IdContrato = @IdContrato
--	AND MC.IsEnabled = 1
--	ORDER BY Mc.IdMenu ASC;
--END
--ELSE
--BEGIN
		SELECT 
		MC.IdMenu,
		CASE when @Idioma = 1 
		THEN MC.TituloEs ELSE MC.TituloEn END AS 'Titulo',
		CASE when @Idioma = 1 
		THEN MC.SubtituloEs ELSE MC.SubtituloEn END AS 'Subitulo',
		MC.CardIcon,
		MC.AlertColor
	FROM AM_MenuCard AS MC
	WHERE MC.IsEnabled = 1
	AND MC.IdMenu IN (1,3,4,5);
END
--END

IF	@IdApp = 2 
BEGIN
SELECT 
		MC.IdMenu,
		CASE when @Idioma = 1 
		THEN MC.TituloEs ELSE MC.TituloEn END AS 'Titulo',
		CASE when @Idioma = 1
		THEN MC.SubtituloEs ELSE MC.SubtituloEn END AS 'Subitulo',
		MC.CardIcon,
		MC.AlertColor
	FROM AM_MenuCard AS MC
	WHERE MC.IsEnabled = 1
	AND MC.IdMenu IN (7,2)
	ORDER BY MC.IdMenu DESC
END
END
