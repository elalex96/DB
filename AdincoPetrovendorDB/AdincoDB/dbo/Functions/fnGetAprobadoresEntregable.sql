CREATE FUNCTION [dbo].[fnGetAprobadoresEntregable]
(
	@IdContratoEntregable INT
)
RETURNS varchar(350)
AS
BEGIN
	DECLARE @Aprobadores VARCHAR (2000) = ''

	SELECT @Aprobadores = @Aprobadores + RTRIM(LTRIM(ISNULL(U.Nombre,''))) + ', '
		FROM dbo.EN_Actividad AS TA 
		 LEFT JOIN dbo.AP_Usuario AS U 
		 ON TA.idUsuario	=	U.UsuarioID
	WHERE TA.IdContratoEntregable = @IdContratoEntregable
		AND TA.EstadoID	=	10003
	ORDER BY TA.ActividadID

	SELECT
		@Aprobadores	= CASE WHEN @Aprobadores <> '' THEN ISNULL(SUBSTRING(@Aprobadores,1,LEN(@Aprobadores)-1),'') ELSE @Aprobadores END

	RETURN @Aprobadores --ISNULL(SUBSTRING(@Aprobadores,1,LEN(@Aprobadores)-1),'')
END