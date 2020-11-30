/****** Object:  View [dbo].[VEstatusPozos]    Script Date: 26/03/2017 06:42:54 p. m. ******/
CREATE VIEW [dbo].[PR_VEstatusPozos]
AS
SELECT     PR_Bloque.Id AS Bloque, PR_Ramal.Id AS Ramal, PR_Zona.Id AS Zona, PR_Pozo.Id AS Pozo, PR_Estacion.Id AS Estacion, PR_Pozo.Estatus, PR_Bloque.Id
FROM         PR_Zona INNER JOIN
                      PR_Pozo INNER JOIN
                      PR_Estacion ON PR_Pozo.Estacion = PR_Estacion.Id ON PR_Zona.Id = PR_Estacion.Zona INNER JOIN
                      PR_Ramal INNER JOIN
                      PR_Bloque ON PR_Ramal.Bloque = PR_Bloque.Id ON PR_Zona.Ramal = PR_Ramal.Id

