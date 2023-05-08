-- [p_TableroContrato_Sel] 10054 ,10402,'10002,10007,10182'
CREATE PROCEDURE [dbo].[p_TableroContrato_Sel]
    @idContrato INT,
	@idUsuario INT, 
	@IdTableroContrato varchar(1000)
AS
BEGIN
   
   DECLARE @Rol INT



   -- SE OBTIENE EL ROL DEL USUARIO EN EL CONTRATO PARA DETERMINAR QUE TABLERO LE CORRESPONDE
   SELECT
		@Rol	=	P.IdRol
	FROM
		AP_PerfilUsuario	PU
	JOIN
		AP_Perfil	P
			ON	PU.UsuarioID	=	@idUsuario
			AND PU.PerfilID	=	P.IdPerfil
			AND P.IdContrato	=	@idContrato

	-- SE OBTIENE EL IDTABLEROCONTRATO PARA MOSTRAR EL TABLERO CORRECTO
	SELECT @IdTableroContrato = LTRIM(TC.IdTableroContrato)
	FROM dbo.EN_TableroContrato TC
	JOIN AP_Usuario U ON U.UsuarioID	=	@idUsuario
	WHERE IdContrato = @idContrato
	AND Activo=1 AND IdRol = @Rol

   select IdTablero = CAST(splitdata AS INT)
   into #tmpTablerosID
   from [dbo].[fnSplitString](@IdTableroContrato,',')

   select	tab.IdTableroContrato,
			 tab.IdContrato,
			 tab.Workbook,
			 tab.Sheet,
			 tab.Tabs,
			 CASE Site 
						WHEN ''
	

					THEN ''
						ELSE
						'/t/'+ Site
					END AS SiteT,
			 tab.Site,
			 tab.DNS,
			 tab.CreadoPor,
			 tab.CreadoEn,
			 tab.ModificadoPor,
			 tab.ModificadoEn,
			 tab.Activo,
			 tab.IdRol,
			 tab.HeightPX,
			 ISNULL(tab.NombreMostrar, '') as NombreMostrar,
			 ISNULL(REPLACE(Parametros,'##Usuario##',U.Nombre),'') as Parametros,
			 UserTableau = isnull(tab.UserTableau,'admin'),
			 tab.MuestraToolbar,
			 ISNULL(REPLACE(Parametros,'##Usuario##',U.Nombre),'') AS Parametros,
					CASE WHEN Isnull(MuestraToolbar,0) = 1 and ISNULL(UserTableau,'admin') <> 'admin'
							THEN 'si'
						ELSE 'no'
					END AS Toolbar
   from EN_TableroContrato tab
   inner join AP_PerfilUsuario pu 
		on pu.UsuarioID = @idUsuario
		AND tab.IdRol	=	@Rol
   inner join [dbo].[AP_Perfil] p 
		on p.IdPerfil = pu.PerfilID AND
										p.IdContrato = TAB.IdContrato
   INNER JOIN AP_Usuario u on u.Usuarioid = pu.UsuarioID
   INNER JOIN #tmpTablerosID tmp on tmp.IdTablero = tab.IdTableroContrato
   where tab.IdContrato = @idContrato 
   group by tab.IdTableroContrato,
			 tab.IdContrato,
			 tab.Workbook,
			 tab.Sheet,
			 tab.Tabs,
			 tab.Site,
			 tab.DNS,
			 tab.CreadoPor,
			 tab.CreadoEn,
			 tab.ModificadoPor,
			 tab.ModificadoEn,
			 tab.Activo,
			 tab.IdRol,
			 tab.HeightPX,
			 tab.NombreMostrar,
			 tab.Parametros,
			 tab.UserTableau,
			 tab.MuestraToolbar,
			 U.Nombre
   END
