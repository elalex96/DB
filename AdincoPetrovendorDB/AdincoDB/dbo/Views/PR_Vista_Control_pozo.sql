/****** Object:  View [dbo].[Vista_Control_pozo]    Script Date: 26/03/2017 06:42:54 p. m. ******/
CREATE VIEW [dbo].[PR_Vista_Control_pozo]
AS
SELECT     PR_Pozo.Id, PR_Pozo.Clave, PR_Pozo.Nombre, PR_ControlPozo.Id AS IdControl, PR_ControlPozo.Fecha, PR_ControlPozo.Pozo, CAST(PR_ControlPozo.Pozo AS int) 
                      AS Pozoprueba, PR_ControlPozo.ProduccionBruta, PR_ControlPozo.pctAgua, PR_ControlPozo.ProduccionNeta, PR_ControlPozo.Valido, PR_ControlPozo.Oficial, 
                      PR_ControlPozo.HoraInicio, PR_ControlPozo.HoraFin, PR_ControlPozo.Duracion, PR_ControlPozo.MedidaInicio, PR_ControlPozo.MedidaFin, 
                      PR_ControlPozo.Tanque, PR_ControlPozo.RPM, PR_ControlPozo.Gas, PR_ControlPozo.PresionTP, PR_ControlPozo.PresionTR, PR_ControlPozo.PresionLinea, 
                      PR_ControlPozo.GolpeMn, PR_ControlPozo.Carrera, PR_ControlPozo.PresionInyeccion, PR_ControlPozo.Modificado, PR_ControlPozo.ModificadoPor, 
                      PR_ControlPozo.ModificadoServer, PR_ControlPozo.FechaValidacion, PR_ControlPozo.AperturaShaffer
FROM         PR_ControlPozo INNER JOIN
                      PR_Pozo ON PR_ControlPozo.Pozo = PR_Pozo.Id

