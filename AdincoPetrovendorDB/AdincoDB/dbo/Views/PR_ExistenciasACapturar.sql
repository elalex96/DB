/****** Object:  View [dbo].[ExistenciasACapturar]    Script Date: 26/03/2017 06:42:54 p. m. ******/
CREATE VIEW [dbo].[PR_ExistenciasACapturar]
AS
SELECT        DATEADD(DAY, - 1, GETDATE()) AS Fecha, PR_Estacion.Nombre AS Estacion, PR_Tanque.Nombre AS Tanque, PR_Tanque.Altura, PR_Tanque.Constante, '' AS Lineal, 
                         0 AS ExistenciaBrutaHoy, 0 AS PctAgua, 0 AS ExistenciaBrutaAyer, 0 AS ExistenciaDiferencia, 0 AS BombeosM3, 0 AS Bombeos
FROM     PR_Estacion (NOLOCK)
		LEFT OUTER JOIN PR_Tanque (NOLOCK)
		ON PR_Estacion.Id = PR_Tanque.Estacion