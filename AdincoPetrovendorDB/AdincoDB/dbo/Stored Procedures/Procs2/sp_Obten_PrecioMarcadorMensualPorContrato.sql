CREATE PROCEDURE [dbo].[sp_Obten_PrecioMarcadorMensualPorContrato]--10007,1,'20220201','20220509'
	@IdContrato INT,
	@IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
	 SET LANGUAGE spanish;
	SELECT M.IdPrecioMarcadorMensual,
			M.IdMarcador,
			M.IdContrato,
			CAST(CONCAT( datename(month, M.Mes), ' ', YEAR(M.Mes)) AS varchar) AS Mes,
			M.Precio,
			M.CreadoPor,
			M.CreadoEn,
			M.ModificadoPor,
			M.ModificadoEl,
			M.Mes as Fecha,
			U.Nombre AS CreadoPorUsuario,
			UM.Nombre AS ModificadoPorUsuario
	FROM 
		CO_PrecioMarcadorMensual  M
	JOIN
		CO_Contrato C
		ON	M.IdContrato	=	C.IdContrato
		AND M.Mes >= C.InicioVigencia
	LEFT	JOIN
		AP_Usuario U
		ON	M.CreadoPor	=	U.UsuarioID
	LEFT	JOIN
		AP_Usuario UM
		ON	M.ModificadoPor	=	UM.UsuarioID
	WHERE 
		M.IdContrato = @IdContrato
	 ORDER BY M.Mes DESC;
	END;

