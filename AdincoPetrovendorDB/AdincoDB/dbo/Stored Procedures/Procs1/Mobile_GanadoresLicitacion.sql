
create PROCEDURE [dbo].[Mobile_GanadoresLicitacion]
@IdLicitacion INT 
AS
BEGIN
SELECT IdGanadorLicitacion
	,IdArea
	,Ronda
	,IdLicitacion
	,Contratista
	,convert(nvarchar(MAX), FechaFirma, 101) AS FechaFirma
	,Modalidad
	,NombreContrato
	,ValorRegalia
	,PaisOrigen
	,ImagenBD
	,Imagen
	,Descripcion FROM dbo.AM_LicitacionesGanadores
	WHERE IdLicitacion = @IdLicitacion
END 


