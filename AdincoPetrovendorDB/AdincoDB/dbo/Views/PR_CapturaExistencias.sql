/****** Object:  View [dbo].[CapturaExistencias]    Script Date: 26/03/2017 06:42:54 p. m. ******/
CREATE VIEW [dbo].[PR_CapturaExistencias]
AS
SELECT        TOP (100) PERCENT PR_Estacion.Nombre, PR_Tanque.Nombre AS Tanque, PR_Tanque.Altura, PR_Tanque.Constante, 0 AS lineal
FROM            PR_Estacion (NOLOCK)
		INNER JOIN
                 PR_Tanque (NOLOCK)
				 ON PR_Estacion.Id = PR_Tanque.Estacion