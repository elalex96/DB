CREATE PROCEDURE [dbo].[sp_JOA_ObtenClasificaciones]--10061,3
    @idUsuario INT,
	@idContrato INT
AS
BEGIN
    SET NOCOUNT ON;

	SELECT  
			IdClasificacion,
			NombreClasificacion
	FROM  
		En_Clasificacion
	WHERE
		Activo	=	1
	AND
		BitJOA	=	1
	
END

