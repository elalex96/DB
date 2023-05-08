CREATE PROCEDURE [dbo].[sp_Obten_AP_LogPantallaPorFechasContrato]--10007,1,'20220201','20220509'
	@IdContrato INT,
	@IdUsuario INT,
	@FechaInicial date,
	@FechaFinal date
AS
BEGIN
    SET NOCOUNT ON;

	SELECT  U.Nombre,U.Usuario, L.Fecha,
	ISNULL(M.InnerHtml,REPLACE(REPLACE(REPLACE(NombrePantalla,'ASP.',''),'_aspx','.aspx'),'_','/')) AS Pantalla,
	IdContrato
	FROM 
		AP_LogPantalla L
	JOIN AP_Usuario U  (NOLOCK)
					ON L.IdUsuario=U.UsuarioID
					AND	  U.Usuario NOT LIKE '%@smps%' 
					AND	  U.Usuario NOT LIKE '%@ogss%'
					AND	  U.Usuario NOT LIKE '%@adinco%'
	LEFT JOIN 
		AP_MenuD M ON '../..'+REPLACE(REPLACE(REPLACE( L.NombrePantalla,'ASP.',''),'_aspx','.aspx'),'_','/')= M.Url
	WHERE 
		IdContrato	=	@IdContrato
	AND 
		CAST(L.Fecha AS DATE) BETWEEN CAST(@FechaInicial AS DATE) AND  CAST(@FechaFinal AS DATE)
	 ORDER BY L.Fecha DESC;
	END;
