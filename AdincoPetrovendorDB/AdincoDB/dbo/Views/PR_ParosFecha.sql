/****** Object:  View [dbo].[ParosFecha]    Script Date: 26/03/2017 06:42:54 p. m. ******/
CREATE VIEW [dbo].[PR_ParosFecha]
AS
SELECT        CAST(PR_ParoDetalle.Inicio AS date) AS Fecha, PR_Ramal.Nombre AS Ramal, PR_Estacion.Nombre AS Estacion, PR_Pozo.Nombre AS Pozo, PR_ListaGeneral.Nombre AS Sistema, PR_ParoDetalle.Inicio, 
                         PR_ParoDetalle.Fin, PR_RubroParo.Rubros, PR_RubroParo.Tipo, PR_ParoDetalle.Duracion / 60 AS Duracion, PR_ParoDetalle.ProduccionDiferida AS Diferida_Neta, PR_Paro.Comentarios, 
                         CASE PR_ParoDetalle.Finalizado WHEN 0 THEN 'No' ELSE 'Si' END AS Finalizado, PR_ParoDetalle.ProduccionDiferidaB AS Diferida_Bruta
FROM            PR_Paro INNER JOIN
                         PR_ParoDetalle ON PR_Paro.Id = PR_ParoDetalle.IdParo INNER JOIN
                         PR_Pozo ON PR_Paro.Pozo = PR_Pozo.Id INNER JOIN
                         PR_Estacion ON PR_Pozo.Estacion = PR_Estacion.Id INNER JOIN
                         PR_Ramal ON PR_Estacion.Ramal = PR_Ramal.Id INNER JOIN
                         PR_ListaGeneral ON PR_Pozo.TipoSistema = PR_ListaGeneral.Id INNER JOIN
                         PR_RubroParo ON PR_Paro.Motivo = PR_RubroParo.Id

