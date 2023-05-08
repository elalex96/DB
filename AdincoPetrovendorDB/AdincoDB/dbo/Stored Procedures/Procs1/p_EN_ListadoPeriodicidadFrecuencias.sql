create PROCEDURE p_EN_ListadoPeriodicidadFrecuencias
as
BEGIN
	select * from [dbo].[EN_FrecuenciaEntregable]
	where 
	FrecuenciaEntregable like 'Anual%' OR 
	FrecuenciaEntregable like '%Mensual%' OR
	FrecuenciaEntregable like '%Semestral%' OR
	FrecuenciaEntregable like '%Trimestral%' OR
	FrecuenciaEntregable like '%Evento%' OR
	FrecuenciaEntregable like 'Quincenal%' OR
	FrecuenciaEntregable like 'Quinquenal%' OR
	FrecuenciaEntregable like '%-%' 
	OR upper(rtrim(FrecuenciaEntregable)) = 'OTRO'
END

