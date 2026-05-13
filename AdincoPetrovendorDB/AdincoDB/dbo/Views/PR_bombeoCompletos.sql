/****** Object:  View [dbo].[bombeoCompletos]    Script Date: 26/03/2017 06:42:54 p. m. ******/
CREATE VIEW [dbo].[PR_bombeoCompletos]
AS
SELECT     Fecha, Duracion, EstacionOrigen
FROM         PR_Bombeo (NOLOCK)
WHERE     (Duracion <> 0)