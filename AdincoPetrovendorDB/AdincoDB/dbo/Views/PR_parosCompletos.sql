/****** Object:  View [dbo].[parosCompletos]    Script Date: 26/03/2017 06:42:54 p. m. ******/
CREATE VIEW [dbo].[PR_parosCompletos]
AS
SELECT     Pozo, Inicio, Duracion
FROM         PR_Paro
WHERE     (Duracion <> 0)

