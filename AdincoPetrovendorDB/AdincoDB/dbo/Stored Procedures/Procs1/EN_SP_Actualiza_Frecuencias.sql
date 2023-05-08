CREATE PROCEDURE EN_SP_Actualiza_Frecuencias
@IdFrecuenciaEntregable int,
@FrecuenciaEntregable varchar(max),
@FrecuenciaIngles varchar(max),
@IdContrato int = null,
@IdUsuario int = null
AS
BEGIN
	update EN_FrecuenciaEntregable
	set FrecuenciaEntregable = @FrecuenciaEntregable,
	FrecuenciaIngles = @FrecuenciaIngles
	where IdFrecuenciaEntregable = @IdFrecuenciaEntregable
END