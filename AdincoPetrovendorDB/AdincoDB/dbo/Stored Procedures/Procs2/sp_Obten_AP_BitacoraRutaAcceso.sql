
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20200206
-- Description:	BITACORA DE ACCESO
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 19/01/2022
-- Description:	Optimizacion
-- =============================================
CREATE PROCEDURE [dbo].[sp_Obten_AP_BitacoraRutaAcceso]--10061,3,0,'20200202','20200317',1
    @IdUsuarioSession INT,
	@IdContrato INT,
	@IdUsuario INT=0,
	@FechaInicial date,
	@FechaFinal date,
	@Idioma int=0
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE  @IsAdminGeneral INT

	SELECT @IsAdminGeneral =
			CASE @IdContrato
				WHEN 3
					THEN 1
				ELSE
					COUNT(1)
				END
			FROM   AP_Usuario U  (NOLOCK)
			JOIN   AP_perfilUsuario PU	 (NOLOCK) 
				ON U.UsuarioID = PU.UsuarioID AND U.UsuarioID = @IdUsuarioSession
			JOIN   AP_Perfil P			 (NOLOCK) 
				ON PU.PerfilID = P.IdPerfil	AND P.IdContrato = @IdContrato
			JOIN   AP_Rol R				 (NOLOCK) 
				ON P.IdRol = R.IdRol
			WHERE R.Rol LIKE '%Administra%general%Entregabl%'

	IF(@IdUsuario=0) --0 TODOS LOS USUARIOS
	BEGIN
			 IF(@IsAdminGeneral>0)--ES ADMINISTRADOR GENERAL DE ENTREGABLES O ES DEL CONTRATO MÉXICO
			 BEGIN
				SELECT	DISTINCT
						IdBitacoraRutaAcceso,
						CreadoEl,
						Ruta,
						Replace(RIGHT(Ruta, CHARINDEX('/', REVERSE(Ruta)) - 1),'.aspx','' )as Aspx,
						IdUsuario,
						dbo.fnGetPantallasMenu(M.Url,@Idioma) as InnerHtml
				FROM AP_BitacoraRutaAcceso BRA  (NOLOCK)
				LEFT JOIN AP_MenuD M  (NOLOCK)
					ON '../..'+BRA.Ruta= M.Url
				WHERE IdContrato=@IdContrato
				     AND CreadoEl BETWEEN @FechaInicial AND (DATEADD(DAY,1,@FechaFinal))
				ORDER BY CreadoEl DESC;
			END
		ELSE
		BEGIN -- SIN DOMINIOS ADINCO
			SELECT	    DISTINCT
						IdBitacoraRutaAcceso,
						CreadoEl,
						Ruta,
						Replace(RIGHT(Ruta, CHARINDEX('/', REVERSE(Ruta)) - 1),'.aspx','' )as Aspx,
						IdUsuario,
						dbo.fnGetPantallasMenu(M.Url,@Idioma) as InnerHtml
				FROM AP_BitacoraRutaAcceso BRA  (NOLOCK)
				JOIN AP_Usuario U  (NOLOCK)
					ON BRA.IdUsuario=U.UsuarioID
					AND	  U.Usuario NOT LIKE '%@smps%' 
					AND	  U.Usuario NOT LIKE '%@ogss%'
					AND	  U.Usuario NOT LIKE '%@adinco%'
				LEFT JOIN AP_MenuD M ON '../..'+BRA.Ruta= M.Url
				WHERE IdContrato=@IdContrato
				     AND CreadoEl BETWEEN @FechaInicial AND(DATEADD(DAY,1,@FechaFinal))
				ORDER BY CreadoEl DESC;
		END
	END
	ELSE
	BEGIN --USUARIO PREDETERMINADO DEL COMBO 
		SELECT	DISTINCT
				IdBitacoraRutaAcceso,
				CreadoEl,
				Ruta,
				Replace(RIGHT(Ruta, CHARINDEX('/', REVERSE(Ruta)) - 1),'.aspx','' )as Aspx,
				IdUsuario,
				dbo.fnGetPantallasMenu(M.Url,@Idioma) as InnerHtml
		FROM AP_BitacoraRutaAcceso BRA  (NOLOCK)
		LEFT JOIN AP_MenuD M  (NOLOCK)
			ON '../..'+BRA.Ruta=M.Url
		WHERE IdUsuario=@IdUsuario 
			AND	IdContrato=@IdContrato
			AND CreadoEl BETWEEN @FechaInicial AND (DATEADD(DAY,1,@FechaFinal))
		ORDER BY CreadoEl DESC;
	END
	END;
