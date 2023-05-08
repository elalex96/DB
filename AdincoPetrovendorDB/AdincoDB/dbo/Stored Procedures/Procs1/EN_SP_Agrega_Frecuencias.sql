CREATE PROCEDURE EN_SP_Agrega_Frecuencias
@FrecuenciaEntregable varchar(max),
@FrecuenciaIngles varchar(max),
@IdContrato int = null,
@IdUsuario int = null
AS
BEGIN
	INSERT INTO EN_FrecuenciaEntregable
	(FrecuenciaEntregable,FrecuenciaIngles) 
	VALUES
	(@FrecuenciaEntregable,@FrecuenciaIngles);
END