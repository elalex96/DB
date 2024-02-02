USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_EN_FiltrosImportacion'
)
    DROP PROCEDURE SP_EN_FiltrosImportacion;
/****** Object:  StoredProcedure [dbo].[SP_EN_FiltrosImportacion]    Script Date: 01/02/2024 04:35:49 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <01/06/2021>
-- Description:	<Consulta de filtros de importacion de entregables>
-- =============================================
-- =============================================
-- Author:	Daniel Ac 
-- Create date: <01/02/2024>
-- Description:	<Se agrega los usuarios de grupos a la lista de elaboradores>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_FiltrosImportacion] 
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@FILTRO NVARCHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	create table #todos
	(
		Id			int,
		Descripcion	varchar(10)
	)

	insert into #todos values (-1,'Todos')

    -- Insert statements for procedure here
	IF @FILTRO = 'ML'
	BEGIN
		
		SELECT		ML.IdMarcoLegal,
					ML.MarcoLegal
		FROM		dbo.EN_ContratoEntregable	CE
		inner join	dbo.EN_Entregable			E 
		ON			CE.IdEntregable				=	E.IdEntregable
		AND			ISNULL(E.IsActivo,0)		=	1
		AND			CE.Activo					=	1
		inner join	dbo.EN_MarcoLegal			ML 
		ON			E.IdMarcoLegal				=	ML.IdMarcoLegal
		and			ML.Activo					=	1
		WHERE		CE.IdContrato				=	@IdContrato
		GROUP BY	ML.IdMarcoLegal,
					ML.MarcoLegal
		union		
		select		Id,
					Descripcion
		from		#todos
		order by 1

	END

	IF @FILTRO = 'AR'
	BEGIN
		
		SELECT		A.idArea,
					A.NombreArea
		FROM		dbo.EN_Area		A
		WHERE		A.idContrato	=	@IdContrato    
		and			A.Activo		=	1
		GROUP BY	A.idArea,
					A.NombreArea
		union		
		select		Id,
					Descripcion
		from		#todos

	END

	IF @FILTRO = 'E'
	BEGIN
		
		select		u.UsuarioID,  
					u.Nombre   
		from		Ap_Usuario			u  
		inner join	AP_PerfilUsuario	pu  
		on			u.UsuarioID			=	pu.UsuarioID 
		and			u.IsActivo			=	1
		inner join	AP_Perfil			p  
		on			pu.PerfilID  		=	 p.IdPerfil
		where		p.IdContrato		=	@IdContrato  
		and			ISNULL(IsGrupo,0)	=	0
		union		
		select		Id,
					Descripcion
		from		#todos

		union 

		SELECT DISTINCT
	    UG.UsuarioID,		
		UG.Nombre
		FROM	EN_GruposUsuarios GU
		JOIN	AP_Usuario AS UG
			ON	GU.IdGrupo	=	UG.UsuarioID
		WHERE	GU.Activo	=	1
			AND	UG.IsActivo	=	1
			AND	GU.IdContrato	= @IdContrato


	END


END
