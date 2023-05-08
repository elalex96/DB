-- =============================================
-- Author:		Reyna Olvera
-- Create date: 06/09/17
-- Description:	Obtiene Menu Dinamico por Rol del usuario
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_ObtenerMenuDinamico]
	-- Add the parameters for the stored procedure here
	@usuarioId int,  
	@Idcontrato int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
Declare @Rol Int		
SELECT Top 1 @Rol= idRol
	from Ap_Usuario usu
	inner join AP_PerfilUsuario perfilUsu on usu.UsuarioID=perfilUsu.UsuarioID
	inner join ap_perfil perfil on perfilUsu.PerfilID=perfil.idPerfil
		where usu.UsuarioID=@usuarioId And idContrato=@Idcontrato
	
	


IF @Rol=1
BEGIN

			SELECT [MenuId]
		  ,[MenuKey]
		  ,[Link]
		  ,[Texto]
		  ,[Titulo]
		  ,[CssClass]
		  ,[ImagenRuta]
		  ,[MenuKeyPadre]
		  ,[Tipo]
		  ,[CreadoPor]
	  FROM [dbo].[AP_Menu]
	  WHERE Visible=1
	  order by MenuKey;
		 
End
ELSE
BEGIN

				IF OBJECT_ID('tempdb..#tablaTemporalDatos') IS NOT NULL
				DROP TABLE #tablaTemporalDatos
	

				 IF OBJECT_ID('tempdb..#tablaTemporalLinks') IS NOT NULL
				DROP TABLE #tablaTemporalLinks

				CREATE TABLE #tablaTemporalDatos( id INT primary key identity(1,1) , Idmenu [bigint]);

				CREATE TABLE #tablaTemporalLinks([MenuId] [bigint]  NOT NULL,
				[MenuKey] [varchar](30) NULL,
				[Link] [varchar](150) NULL,
				[Texto] [varchar](100) NULL,
				[Titulo] [varchar](100) NULL,
				[CssClass] [varchar](70) NULL,
				[ImagenRuta] [varchar](150) NULL,
				[MenuKeyPadre] [varchar](30) NULL,
				[Tipo] [int] NOT NULL,
				[Visible] [bit] NOT NULL,
				[CreadoPor] [int] NULL, )
			---------------------------------

			--Cambiar variable
				INSERT INTO #tablaTemporalDatos(Idmenu)
						SELECT  MenuId from ap
			where idRol=@Rol

			---------------------------------------------------------------------------------------------
			--Cambiar a variable 

				Declare @Var Int
					Declare @IdMenu bigint 
			SELECT @Var=Count(MenuId) from ap 
			where idRol=@Rol

					declare @i int
					SET @i = 1

					while(@i<=@Var)
					BEGIN
				SELECT @IdMenu= Idmenu
					from #tablaTemporalDatos 
					where id=@i
				----------------------------------------
				--Insertando de AP_menu
					INSERT INTO #tablaTemporalLinks ([MenuId]
					  ,[MenuKey]
					  ,[Link]
					  ,[Texto]
					  ,[Titulo]
					  ,[CssClass]
					  ,[ImagenRuta]
					  ,[MenuKeyPadre]
					  ,[Tipo]
					  ,[Visible]
					  ,[CreadoPor])
					SELECT [MenuId]
					  ,[MenuKey]
					  ,[Link]
					  ,[Texto]
					  ,[Titulo]
					  ,[CssClass]
					  ,[ImagenRuta]
					  ,[MenuKeyPadre]
					  ,[Tipo]
					  ,[Visible]
					  ,[CreadoPor]
				  FROM [dbo].[AP_Menu]
					WHERE Menuid=@IdMenu
				----------------------------------------
						SET @i = @i+ 1
						END
			--Seleccion de datos por rol
				SELECT [MenuId]
					  ,[MenuKey]
					  ,[Link]
					  ,[Texto]
					  ,[Titulo]
					  ,[CssClass]
					  ,[ImagenRuta]
					  ,[MenuKeyPadre]
					  ,[Tipo]
					  ,[CreadoPor]
				  FROM #tablaTemporalLinks
				  WHERE Visible=1
				  order by MenuKey;
			END	  

END

