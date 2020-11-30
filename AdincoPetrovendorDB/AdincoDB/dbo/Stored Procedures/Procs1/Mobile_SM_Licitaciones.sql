
create PROCEDURE [dbo].[Mobile_SM_Licitaciones]
@IdRonda int 
AS
BEGIN
	SELECT LI.IdLicitacion,LI.NombreLicitacion,TL.NombreTipoArea,TL.Icon FROM dbo.AM_Licitacion AS LI
	INNER JOIN dbo.AM_RondasTipoLicitacion AS TL ON TL.IdRondasTipoLicitacion = LI.IdTipoLicitacion
	WHERE IdRonda = @IdRonda
END
