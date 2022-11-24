CREATE VIEW dbo.AvancesPMT
AS

	SELECT Actividad, Unidad, Cantidad, UnidadesActividad, UnidadesTrabajo, Estatus, MesCarga
	FROM co_CargaProgramadaTrabajo
	WHERE IdContrato = 10058
	AND Activo = 1